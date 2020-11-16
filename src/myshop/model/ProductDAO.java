package myshop.model;

import java.sql.*;
import java.util.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class ProductDAO implements InterProductDAO {

	private DataSource ds; // DataSource ds 는 아파치톰캣이 제공하는 DBCP(DB Connection Pool) 이다.
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	// 생성자
	public ProductDAO() {
		try {
	         Context initContext = new InitialContext();
	         Context envContext  = (Context)initContext.lookup("java:/comp/env");
	         ds = (DataSource)envContext.lookup("jdbc/mymvc_oracle");
	      } catch(NamingException e) {
	         e.printStackTrace();
	      }
	} 
	
	// 사용한 자원을 반납하는 close() 메소드 생성하기
	private void close() {
	      try {
	         if(rs != null)    {rs.close(); rs=null;}
	         if(pstmt != null) {pstmt.close(); pstmt=null;}
	         if(conn != null)  {conn.close(); conn=null;}
	      } catch(SQLException e) {
	         e.printStackTrace();
	      }
	}// end of private void close() {}--------------------------------------
	
	@Override
	public List<ImageVO> imageSelectAll() throws SQLException {
		
		List<ImageVO> imgList = new ArrayList<ImageVO>();
		
		try {
			
			conn = ds.getConnection();
			
			String sql = "SELECT imgno, imgfilename\n"+
						 "FROM tbl_main_image\n"+
						 "ORDER BY imgno ASC";
			
			pstmt = conn.prepareStatement(sql);
			
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				ImageVO imgvo = new ImageVO();
				
				imgvo.setImgno(rs.getInt(1));
				imgvo.setImgfilename(rs.getString(2));
				
				imgList.add(imgvo);
				
				
			}// end of while (rs.next()) {}-----------------------
			
			
			
		} finally {
			close(); // 무조건 자원은 반납해야한다.
		}
		
		return imgList;
	}

	
	// Ajax(JSON)를 사용하여 HIT 상품목록을 "더보기" 방식으로 페이징처리 해주기 위해 스펙별로 제품의 전체개수 알아오기.
	@Override
	public int totalPspecCount(String fk_snum) throws SQLException {

		int totalCount = 0;
		
		try {
			
			conn = ds.getConnection();
			
			String sql = " SELECT count(*) "+
						 " FROM tbl_product "+
						 " WHERE fk_snum = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, fk_snum);
			
			rs = pstmt.executeQuery();
			
			rs.next();
			
			totalCount = rs.getInt(1);
			
		} finally {
			close(); // 무조건 자원은 반납해야한다.
		}
		
		
		return totalCount;
	}

	
	// Ajax(JSON)를 이용한 더보기 방식(페이징처리)으로 상품 정보를 8개씩 잘라서 (start ~ end) 조회해오기
	@Override
	public List<ProductVO> selectBySpecName(Map<String, String> paraMap) throws SQLException {

		List<ProductVO> prodList = new ArrayList<>();
		
		try {
			conn = ds.getConnection();
	         
			String sql = "select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate "+
	                "from "+
	                "( "+
	                " select row_number() over(order by pnum asc) AS RNO "+
	                "      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  "+
	                "      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate "+
	                " from tbl_product P "+
	                " JOIN tbl_category C "+
	                " ON P.fk_cnum = C.cnum "+
	                " JOIN tbl_spec S "+
	                " ON P.fk_snum = S.snum"+
	                " where S.sname = ? "+
	                ") V "+
	                "where RNO between ? and ?";
	         
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, paraMap.get("sname"));
			pstmt.setString(2, paraMap.get("start"));
			pstmt.setString(3, paraMap.get("end"));
	         
			rs = pstmt.executeQuery();
	         
			while( rs.next() ) {
				ProductVO pvo = new ProductVO();
	        	 
				pvo.setPnum(rs.getInt(1)); 			 // 제품번호
				pvo.setPname(rs.getString(2));		 // 제품명
	        	 
				CategoryVO categvo = new CategoryVO();
				categvo.setCode(rs.getString(3));
	        	 
				pvo.setCategvo(categvo);  			 // 카테고리코드(Foreign Key)의 시퀀스번호 참조
				pvo.setPcompany(rs.getString(4));	 // 제조회사명
				pvo.setPimage1(rs.getString(5));	 // 제품이미지1   이미지파일명
				pvo.setPimage2(rs.getString(6));     // 제품이미지2   이미지파일명 
				pvo.setPqty(rs.getInt(7));   		 // 제품 재고량
				pvo.setPrice(rs.getInt(8)); 		 // 제품 정가
				pvo.setSaleprice(rs.getInt(9));  	 // 제품 판매가(할인해서 팔 것이므로)
				
				SpecVO spvo = new SpecVO();
				spvo.setSname(rs.getString(10));
				
				pvo.setSpvo(spvo); 					 // 스펙
				
				pvo.setPcontent(rs.getString(11));	 // 제품설명 
				pvo.setPoint(rs.getInt(12));	     // 포인트 점수                                         
				pvo.setPinputdate(rs.getString(13)); // 제품입고일자	
				
	        	prodList.add(pvo); 
			}// end of while------------------------------------------------
	         
		} finally {
			close();
		}
		
		
		return prodList;
	}


	// tbl_category 테이블에서 카테고리 대분류 번호(cnum), 카테고리코드(code), 카테고리명(cname)을 조회해오기 
	// VO 를 사용하지 않고 Map 으로 처리해보겠습니다.
	@Override
	public List<HashMap<String, String>> getCategoryList() throws SQLException {
		
		List<HashMap<String, String>> categoryList = new ArrayList<>(); 
		
		try {
			 conn = ds.getConnection();
			 
			 String sql = " select cnum, code, cname "  
			 		    + " from tbl_category "
			 		    + " order by cnum asc ";
			 		    
			pstmt = conn.prepareStatement(sql);
					
			rs = pstmt.executeQuery();
						
			while(rs.next()) {
				HashMap<String, String> map = new HashMap<>();
				map.put("cnum", rs.getString(1));
				map.put("code", rs.getString(2));
				map.put("cname", rs.getString(3));
				
				categoryList.add(map);
			}// end of while(rs.next())----------------------------------
			
		} finally {
			close();
		}	
			
		return categoryList;
	}

	
	// spec 목록을 보여주고자 한다.
	@Override
	public List<SpecVO> selectSpecList() throws SQLException {
		
		List<SpecVO> specList = new ArrayList<>();
		
		try {
			conn = ds.getConnection();
			
			String sql = " select snum, sname " + 
					     " from tbl_spec " + 
					     " order by snum asc ";
			
			pstmt = conn.prepareStatement(sql);
			
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				SpecVO spvo = new SpecVO();
				spvo.setSnum(rs.getInt(1));
				spvo.setSname(rs.getString(2));
				
				specList.add(spvo);
			}
						
		} finally {
			close();
		}
		
		return specList;
	}

	
	
	
	
}
