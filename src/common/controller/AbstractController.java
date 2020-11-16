package common.controller;

import java.sql.SQLException;
import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import member.model.MemberVO;
import myshop.model.*;

public abstract class AbstractController implements InterCommand {

/*
    === 다음의 나오는 것은 우리끼리한 약속이다. ===

        ※ view 단 페이지(.jsp)로 이동시 forward 방법(dispatcher)으로 이동시키고자 한다라면 
          자식클래스에서는 부모클래스에서 생성해둔 메소드 호출시 아래와 같이 하면 되게끔 한다.
     
    super.setRedirect(false); 
    super.setViewPage("/WEB-INF/index.jsp");
    
    
        ※ URL 주소를 변경하여 페이지 이동시키고자 한다라면
          즉, sendRedirect(데이터를 포함하지 않고 URL페이지를 이동하는 것) 를 하고자 한다라면    
          자식클래스에서는 부모클래스에서 생성해둔 메소드 호출시 아래와 같이 하면 되게끔 한다.
          
    super.setRedirect(true);
    super.setViewPage("registerMember.up");               
*/		
	
	private boolean isRedirect = false; 
	// isRedirect 변수의 값이 false라면 view단 페이지(.jsp)로 forward 방법(dispatcher)으로 이동시킨다.
	// isRedirect 변수의 값이 true라면 sendRedirect로 페이지 이동을 시킨다.
	
	private String viewPage;
	// viewPage는 isRedirect값이 false라면 view단 페이지(.jsp)의 경로명이고,
	// isRedirect값이 true라면 이동해야할 페이지 URL주소이다.

	public boolean isRedirect() {
		return isRedirect;
	}

	public void setRedirect(boolean isRedirect) {
		this.isRedirect = isRedirect;
	}

	public String getViewPage() {
		return viewPage;
	}

	public void setViewPage(String viewPage) {
		this.viewPage = viewPage;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 로그인 유무를 검사해서 로그인 했으면 true를 리턴해주고
	// 로그인 안했으면 false를 리턴해주도록 한다.
	public boolean checkLogin(HttpServletRequest request) {
		
		HttpSession session = request.getSession();
		MemberVO loginUser = (MemberVO)session.getAttribute("loginUser");
		
		if (loginUser != null) {
			// 로그인 한 경우
			return true;
		}else {
			// 로그인 안한 경우
			return false;
		}
		
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ***** 제품목록 (Category)을 보여줄 메소드 생성하기 ***** //
	// VO를 사용하지 않고 Map으로 처리해보겠습니다.
	public void getCategoryList(HttpServletRequest request) throws SQLException{
		
		InterProductDAO pdao = new ProductDAO();
		List<HashMap<String, String>> categoryList = pdao.getCategoryList();
	
		request.setAttribute("categoryList", categoryList);
	}
	
	
	
}
