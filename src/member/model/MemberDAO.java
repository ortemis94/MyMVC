package member.model;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.sql.*;
import java.util.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import util.security.AES256;
import util.security.SecretMyKey;
import util.security.Sha256;

public class MemberDAO implements InterMemberDAO {

	private DataSource ds; // DataSource ds 는 아파치톰캣이 제공하는 DBCP(DB Connection Pool) 이다.
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	// 생성자
	public MemberDAO() {
		try {
	         Context initContext = new InitialContext();
	         Context envContext  = (Context)initContext.lookup("java:/comp/env");
	         ds = (DataSource)envContext.lookup("jdbc/mymvc_oracle");
	         
			 aes = new AES256(SecretMyKey.KEY); 
			 // SecretMyKey.KEY은 우리가 만든 비밀키이다. 
	         
	      } catch(NamingException e) {
	         e.printStackTrace();
	      } catch(UnsupportedEncodingException e) {
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

	
	// 회원 가입을 해주는 메소드 (tbl_member 테이블에 insert)
	@Override
	public int registerMember(MemberVO member) throws SQLException {

		int result = 0;
		
		try {
			conn = ds.getConnection();
			
			String sql = "INSERT INTO tbl_member(userid, pwd, name, email, mobile, postcode, address, detailaddress, extraaddress, gender, birthday)\n"+
					"VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			
			pstmt = conn.prepareStatement(sql);
			
			pstmt.setString(1, member.getUserid());
			pstmt.setString(2, Sha256.encrypt(member.getPwd()) ); // 암호를 SHA256 알고리즘으로 단방향 암호화 시킨다.
			pstmt.setString(3, member.getName());
			pstmt.setString(4, aes.encrypt(member.getEmail()) );  // 이메일을 AES256 알고리즘으로 양방향 암호화 시킨다.
			pstmt.setString(5, aes.encrypt(member.getMobile()) ); // 휴대폰 번호를 AES256 알고리즘으로 양방향 암호화 시킨다.
			pstmt.setString(6, member.getPostcode());
			pstmt.setString(7, member.getAddress());
			pstmt.setString(8, member.getDetailaddress());
			pstmt.setString(9, member.getExtraaddress());
			pstmt.setString(10, member.getGender());
			pstmt.setString(11, member.getBirthday());
			
			result = pstmt.executeUpdate();
		} catch(GeneralSecurityException | UnsupportedEncodingException e) {
			e.printStackTrace();
		} finally {
			close();
		}
		
		
		return result;
	}// end of public int registerMember(MemberVO member) throws SQLException {}----------------------------

	
	// ID 중복검사(tbl_member 테이블에서 userid가 존재하면 true를 리턴해주고, userid가 존재하지 않으면 false를 리턴) 메소드
	@Override
	public boolean idDuplicateCheck(String userid) throws SQLException {

		boolean isExist = false;
		
		try {
			conn = ds.getConnection();
			
			String sql = "SELECT userid\n"+
					"FROM tbl_member\n"+
					"WHERE userid=?";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			
			rs = pstmt.executeQuery();
			
			isExist = rs.next(); // 행이 있으면(중복된 userid) true,
								 // 행이 없으면(사용가능한 userid) false.
			/*
			if (rs.next()) { // userid와 일치하는 행이 있다면 
				isExist = true; // isExist를 true로 바꿔준다. 
			}
			*/
			
		} finally {
			close();
		}
		
		return isExist;
	}// end of public boolean idDuplicateCheck(String userid) throws SQLException {}------------------------

	
	// email 중복검사(tbl_member 테이블에서 email이 존재하면 true를 리턴해주고, email이 존재하지 않으면 false를 리턴) 메소드
	@Override
	public boolean emailDuplicateCheck(String email) throws SQLException {
		
		boolean isExist = false;
		
		try {
			conn = ds.getConnection();
			
			String sql = "SELECT email\n"+
					"FROM tbl_member\n"+
					"WHERE email=?";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, email);
			
			System.out.println("1 " + email);
			
			rs = pstmt.executeQuery();
			
			isExist = rs.next(); // 행이 있으면(중복된 email) true,
								 // 행이 없으면(사용가능한 email) false.
			/*
			if (rs.next()) { // email와 일치하는 행이 있다면 
				isExist = true; // isExist를 true로 바꿔준다. 
			}
			*/
			
		} finally {
			close();
		}
		
		return isExist;
	}

	
	// 입력받은 paraMap을 가지고 한명의 회원정보를 리턴시켜주는 메소드(로그인 처리)
	@Override
	public MemberVO selectOneMember(Map<String, String> paraMap) throws SQLException {
		
		MemberVO member = null;
		
		try {
			
			conn = ds.getConnection();
			
			String sql = "SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender "+
					"     , birthyyyy, birthmm, birthdd, coin, point, registerday, pwdchangegap "+
					"     , nvl(lastlogingap, TRUNC( months_between(sysdate, registerday) ) ) AS lastlogingap "+
					"FROM "+
					"( "+
					"SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender "+
					"          , substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd "+
					"          , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday "+
					"          , TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap "+
					"FROM tbl_member "+
					"WHERE status=1 AND  userid = ? AND pwd = ?  "+
					") M "+
					"CROSS JOIN "+
					"( "+
					"SELECT TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap "+
					"FROM tbl_loginhistory "+
					"WHERE fk_userid = ?  "+
					") H";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, paraMap.get("userid"));
			pstmt.setString(2, Sha256.encrypt(paraMap.get("pwd")));
			pstmt.setString(3, paraMap.get("userid"));
			
			rs = pstmt.executeQuery();
			
			if (rs.next()) {
				member = new MemberVO();
				
				member.setUserid(rs.getString(1));
				member.setName(rs.getString(2));
				member.setEmail( aes.decrypt(rs.getString(3)) ); // 복호화
				member.setMobile( aes.decrypt(rs.getString(4)) ); // 복호화
				member.setPostcode(rs.getString(5));
				member.setAddress(rs.getString(6));
				member.setDetailaddress(rs.getString(7));
				member.setExtraaddress(rs.getString(8));
				member.setGender(rs.getString(9));
				member.setBirthday(rs.getString(10)+rs.getString(11)+rs.getString(12));
				member.setCoin(rs.getInt(13));
				member.setPoint(rs.getInt(14));
				member.setRegisterday(rs.getString(15));
				 
				if (rs.getInt(16) >= 3) {
					// 마지막으로 암호를 변경한 날짜가 현재시각으로부터 3개월이 지났으면 true 
					// 마지막으로 암호를 변경한 날짜가 현재시각으로부터 3개월이 지나지 않았으면 false 
					member.setRequirePwdChange(true); // 로그인시 암호를 변경하라는 alert를 띄우도록 한다.
				}
				
				if (rs.getInt(17) >= 12) {
					// 마지막으로 로그인한 날짜시간이 현재시각으로부터 1년이 지났으면 휴면으로 지정
					member.setIdle(1);
					
					// === tbl_member 테이블의 idle 컬럼의 값을 1로 변경하기 === //
					sql = " UPDATE tbl_member SET idle = 1 "
					    + " WHERE userid = ? ";
					
					pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, paraMap.get("userid"));
					
					pstmt.executeUpdate();
				}
				
				
				if (member.getIdle() != 1) {
					// === 행이 존재한다면 tbl_loginhistory 로그인 기록 테이블에 회원 로그인 정보 insert 하기 === //
					sql = "INSERT INTO tbl_loginhistory(fk_userid, clientip) "
							+ " VALUES(?, ?) ";
					
					pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, paraMap.get("userid"));
					pstmt.setString(2, paraMap.get("clientip"));
					
					pstmt.executeUpdate();
				}

			}
			
		} catch(GeneralSecurityException | UnsupportedEncodingException e) {	
			e.printStackTrace();
		} finally {
			close();
		}
		
		return member;
	}

	
	// 아이디 찾기(성명, 이메일을 입력받아서 해당 사용자의 아이디를 알려준다). 
	@Override
	public String findUserid(Map<String, String> paraMap) throws SQLException {

		String userid = null;
		
		try {
			conn = ds.getConnection();
			
			String sql = "SELECT userid\n"+
						 "FROM tbl_member\n"+
						 "WHERE status = 1 AND name = ? AND email = ? ";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, paraMap.get("name"));
			pstmt.setString(2, aes.encrypt(paraMap.get("email")));
			
			rs = pstmt.executeQuery();
			
			if (rs.next()) {
				userid = rs.getString(1);
			} 
			
		} catch (UnsupportedEncodingException | GeneralSecurityException e) {
			e.printStackTrace();
		} finally {
			close();
		}
		
		return userid;
	}

	
	// 비밀번호 찾기(아이디, 이메일을 입력받아서 해당 사용자가 존재하는지 유무를 알려준다) 	
	@Override
	public boolean isUserExist(Map<String, String> paraMap) throws SQLException {

		boolean isUserExist = false;
		
		try {
			conn = ds.getConnection();
			
			String sql = "SELECT userid\n"+
						 "FROM tbl_member\n"+
						 "WHERE status = 1 AND userid = ? AND email = ? ";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, paraMap.get("userid"));
			pstmt.setString(2, aes.encrypt(paraMap.get("email")));
			
			rs = pstmt.executeQuery();
			
			isUserExist = rs.next();
			
		} catch (UnsupportedEncodingException | GeneralSecurityException e) {
			e.printStackTrace();
		} finally {
			close();
		}
		
		return isUserExist;
	}

	
	// 암호 변경하기
	@Override
	public int pwdUpdate(Map<String, String> paraMap) throws SQLException {

		int result = 0;

		try {
			conn = ds.getConnection();
			
			String sql = "UPDATE tbl_member SET pwd = ? " +
					"WHERE userid = ? ";
			
			pstmt = conn.prepareStatement(sql);
			
			pstmt.setString(1, Sha256.encrypt( paraMap.get("pwd") )); // 암호를 SHA256 알고리즘으로 단방향 암호화 시킨다.
			pstmt.setString(2, paraMap.get("userid"));
			
			result = pstmt.executeUpdate();
			
		} finally {
			close();
		}
		
		return result;
	}

	
	// 회원의 coin 변경하기
	@Override
	public int coinUpdate(Map<String, String> paraMap) throws SQLException {

		int result = 0;
		

		try {
			conn = ds.getConnection();
			
			String sql = "UPDATE tbl_member SET coin = coin + ?, point =  point + ? " +
					"WHERE userid = ? ";
			
			pstmt = conn.prepareStatement(sql);
			
			pstmt.setString(1, paraMap.get("coinmoney")); 
			pstmt.setInt(2, (int)(Integer.parseInt(paraMap.get("coinmoney")) * 0.01)); // 300000 * 0.01 ==> 3000.0 ==> (int)3000.0 ==> 3000
			pstmt.setString(3, paraMap.get("userid")); 
			
			result = pstmt.executeUpdate();
			
		} finally {
			close();
		}
		
		return result;
	}
	
	
	// 회원의 개인정보 변경하기
	@Override
	public int updateMember(MemberVO member) throws SQLException {
	      
		int result = 0;

	    try {

	    	conn = ds.getConnection();

	        String sql = "update tbl_member set name = ?, pwd = ?, email = ?, mobile = ?, postcode = ?, address = ?, detailaddress = ?, extraaddress = ? "
	              + "where userid = ?";

	        pstmt = conn.prepareStatement(sql);

	        pstmt.setString(1, member.getName());
	        pstmt.setString(2, Sha256.encrypt(member.getPwd()));
	        pstmt.setString(3, aes.encrypt(member.getEmail()));
	        pstmt.setString(4, aes.encrypt(member.getMobile()));
	        pstmt.setString(5, member.getPostcode());
	        pstmt.setString(6, member.getAddress());
	        pstmt.setString(7, member.getDetailaddress());
	        pstmt.setString(8, member.getExtraaddress());
	        pstmt.setString(9, member.getUserid());

	        result = pstmt.executeUpdate();
	        
	    } catch (GeneralSecurityException | UnsupportedEncodingException e) {
	    	e.printStackTrace();
	    } finally {
	    	close();
	    }
	      
	    return result;
	}

	
	// *** 페이징 처리를 안한 모든 회원 또는 검색한 회원 목록 보여주기 *** //
	@Override
	public List<MemberVO> selectMember(Map<String, String> paraMap) throws SQLException {

		List<MemberVO> memberList = new ArrayList<>();
		

		try {
			conn = ds.getConnection();
			
			String sql = " SELECT userid, name, email, gender "+
						 " FROM tbl_member "+
						 " WHERE userid != 'admin' ";
			
			String colName = paraMap.get("searchType");
			String searchWord = paraMap.get("searchWord");
			
			if (colName.equals("email")) { // 검색대상이 email인 경우
				searchWord = aes.encrypt("searchWord");
			}
			
			
			
			if ( searchWord != null && !searchWord.trim().isEmpty() ) {
				sql += " AND "+ colName +" LIKE '%'|| ? ||'%' ";
			}
			
			sql += " ORDER BY registerday DESC ";

			pstmt = conn.prepareStatement(sql);
			
			if ( searchWord != null && !searchWord.trim().isEmpty() ) {
				pstmt.setString(1, searchWord);
			}
			
			
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				MemberVO mvo = new MemberVO();
			
				mvo.setUserid(rs.getString(1));
				mvo.setName(rs.getString(2));
				mvo.setEmail( aes.decrypt(rs.getString(3)) ); // 복호화
				mvo.setGender(rs.getString(4));
				
				memberList.add(mvo);
			}
			
	    } catch (GeneralSecurityException | UnsupportedEncodingException e) {
	    	e.printStackTrace();	
		} finally {
			close();
		}
		
		
		return memberList;
	}

	
	//페이징 처리를 하여 모든 회원목록 또는 검색조건에 해당하는 회원목록 보여주기 
	@Override
	public List<MemberVO> selectPagingMember(Map<String, String> paraMap) throws SQLException {
		  
		List<MemberVO> memberList = new ArrayList<>();
	      
	    try {
	    	conn = ds.getConnection();
	         
	    	String sql = "select userid, name, email, gender "+
	    			 "from "+
	    			 "( "+
	    			 "    select rownum as RNO, userid, name, email, gender "+
	    			 "    from  "+
	    			 "    ( "+
	    			 "        select userid, name, email, gender "+
	    			 "        from tbl_member "+
	    			 "        where userid != 'admin' ";
	    	

	    	String colname = paraMap.get("searchType");
	    	String searchWord = paraMap.get("searchWord");

	    	if("email".equals(colname)) { // 검색대상이 email인 경우
	    		searchWord = aes.encrypt(searchWord);
	    	}

	    	if( searchWord != null && !searchWord.trim().isEmpty() ) { 
	    		sql += " and "+ colname +" like '%'|| ? ||'%' ";
	    	}

	    	sql += "     order by registerday desc "+
	    			"    ) V "+
	    			") T "+
	    			" where T.rno between ? and ? ";

	    	pstmt = conn.prepareStatement(sql);

	    	int currentShowPageNo = Integer.parseInt(paraMap.get("currentShowPageNo"));
	    	int sizePerPage = Integer.parseInt(paraMap.get("sizePerPage"));

	    	if( searchWord != null && !searchWord.trim().isEmpty() ) {
	    		pstmt.setString(1, searchWord);
	    		pstmt.setInt(2, (currentShowPageNo * sizePerPage) - (sizePerPage - 1)); // 페이징 처리 공식
	    		pstmt.setInt(3, (currentShowPageNo * sizePerPage)); // 페이징 처리 공식
	    	}else {
	    		pstmt.setInt(1, (currentShowPageNo * sizePerPage) - (sizePerPage - 1)); // 페이징 처리 공식
	    		pstmt.setInt(2, (currentShowPageNo * sizePerPage)); // 페이징 처리 공식
	    	}

	    	rs = pstmt.executeQuery();

	    	while(rs.next()) {
	    		MemberVO mvo = new MemberVO();
	    		mvo.setUserid(rs.getString(1));
	    		mvo.setName(rs.getString(2));
	    		mvo.setEmail( aes.decrypt(rs.getString(3)) ); // 복호화
	    		mvo.setGender(rs.getString(4));

	    		memberList.add(mvo);
	    	}
	    	
	    }catch (GeneralSecurityException | UnsupportedEncodingException e) {
	    	e.printStackTrace();
	    }finally {
	    	close();
	    }      
	      
	    return memberList;
	}

	
	// 페이징 처리를 위해서 전체회원에 대한 총페이지 개수 알아오기(select)
	@Override
	public int getTotalPage(Map<String, String> paraMap) throws SQLException {

		int totalPage = 0;
		
		try {
			conn = ds.getConnection();
			
				String sql = " SELECT ceil( COUNT(*) / ? ) "
		    			   + " FROM tbl_member "
		    			   + " WHERE userid != 'admin' ";
		        
		        String colname = paraMap.get("searchType");
		        String searchWord = paraMap.get("searchWord");
		         
		        if("email".equals(colname)) { // 검색대상이 email인 경우
		        	searchWord = aes.encrypt(searchWord);
		        }
		         
		        if( searchWord != null && !searchWord.trim().isEmpty() ) { 
		        	sql += " and "+ colname +" like '%'|| ? ||'%' ";
		        }
		         
		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, paraMap.get("sizePerPage"));
		         
		        if (searchWord != null && !searchWord.trim().isEmpty()) {
		        	pstmt.setString(2, searchWord);
				}
		        
		        rs = pstmt.executeQuery();

		        rs.next();
		        
		        totalPage = rs.getInt(1);
		        
		}catch (GeneralSecurityException | UnsupportedEncodingException e) {
			e.printStackTrace();
		}finally {
			close();
		}      
			
		return totalPage;
	}

	
	// userid 값을 입력받아서 회원 1명에 대한 상세정보를 알아오기(select)
	@Override
	public MemberVO memberOneDetail(String userid) throws SQLException {

		MemberVO mvo = null;

		try {
			conn = ds.getConnection();
			
			String sql = " SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender " + 
					     " 		, substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd " + 
					     " 		, coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday " + 
					     " 		, TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap " +
					     " FROM tbl_member "+
					     " WHERE userid = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			
			rs = pstmt.executeQuery();
			
			if (rs.next()) {
				mvo = new MemberVO();
				
				mvo.setUserid(rs.getString(1));
				mvo.setName(rs.getString(2));
				mvo.setEmail( aes.decrypt(rs.getString(3)) ); // 복호화
				mvo.setMobile( aes.decrypt(rs.getString(4)) ); // 복호화
				mvo.setPostcode(rs.getString(5));
				mvo.setAddress(rs.getString(6));
				mvo.setDetailaddress(rs.getString(7));
				mvo.setExtraaddress(rs.getString(8));
				mvo.setGender(rs.getString(9));
				mvo.setBirthday(rs.getString(10)+rs.getString(11)+rs.getString(12));
				mvo.setCoin(rs.getInt(13));
				mvo.setPoint(rs.getInt(14));
				mvo.setRegisterday(rs.getString(15));
			}
			
	    } catch (GeneralSecurityException | UnsupportedEncodingException e) {
	    	e.printStackTrace();	
		} finally {
			close();
		}
		return mvo;
	}

	
	
}
