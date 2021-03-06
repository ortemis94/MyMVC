package member.controller;

import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import common.controller.AbstractController;
import member.model.*;

public class LoginAction extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String method = request.getMethod(); // "GET" or "POST"
		
		if (!method.equalsIgnoreCase("POST")) { 
			// "POST" 방식으로 들어온 것이 아니라면
			String message = "비정상적인 경로로 들어왔습니다.";
			String loc = "javascript:history.back()";
			
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
			
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/msg.jsp");
 			
			return; // execute(HttpServletRequest request, HttpServletResponse response) 메소드 종료함.
		}
		
		// POST 방식으로 넘어온 것이라면 
		String userid = request.getParameter("userid");
		String pwd = request.getParameter("pwd");
		
		String clientip = request.getRemoteAddr(); // 클라이언트의 IP 주소를 알아오는 것.
		
		Map<String, String> paraMap = new HashMap<>(); 
		
		paraMap.put("userid", userid);
		paraMap.put("pwd", pwd);
		paraMap.put("clientip", clientip);
		
		InterMemberDAO mdao = new MemberDAO();
		
		MemberVO loginUser = mdao.selectOneMember(paraMap);
		
		
		if(loginUser != null) {
	
			if (loginUser.getIdle() == 1) {
				String message = "로그인을 한지 1년이 지나서 휴면상태로 전환되었습니다. 관리자에게 문의 바랍니다.";
				String loc = request.getContextPath() + "/index.up";
				// 원래는 위와 같이 index.up이 아니라 휴면인 계정을 풀어주는 페이지로 잡아주어야 한다.
				
				request.setAttribute("message", message);
				request.setAttribute("loc", loc);
				
				super.setRedirect(false);
				super.setViewPage("/WEB-INF/msg.jsp");
				
				return; // 메소드 종료
			}
			
		    //로그인 성공시
		    // System.out.println(">>> 확인용 로그인한 사용자명 : " + loginUser.getName());
		      
			// !!!! session(세션)이라는 저장소에 로그인 되어진 loginUser 를 저장시켜두어야 한다. !!!!
			// session(세션)이란? WAS 컴퓨터의 메모리(RAM)의 일부분을 사용하는 것으로 접속한 클라이언트 컴퓨터에서 보내온 정보를 저장하는 용도로 쓰인다. 
			// 클라이언트 컴퓨터가 WAS 컴퓨터에 웹으로 접속을 하기만 하면 무조건 자동적으로 WAS 컴퓨터의 메모리(RAM)의 일부분에 session이 생성되어진다.
			// session은 클라이언트 컴퓨터 웹브라우저당 1개씩 생성되어진다.
			// 예를 들면 클라이언트 컴퓨터가 크롬웹브라우저로 WAS 컴퓨터에 웹으로 연결하면 session이 하나 생성되어지고,
			// 또 이어서 동일한 클라이언트 컴퓨터가 엣지웹브라우저로 WAS 컴퓨터에 웹으로 연결하면 또 하나의 새로운 session이 생성되어진다.
			/*
				-------------
				| 클라이언트     |
				| A 웹브라우저 |-------	-----------------
				-------------		|	WAS 서버	    |
									|			    |
				-------------		| RAM(A session)|
				| 클라이언트     |	--------|	 (B session)|
				| B 웹브라우저 |		-----------------
				-------------
				
			!!!! 세션(session)이라는 저장 영역에 loginUser 를 저장시켜두면 
			     Command.properties 파일에 기술된 모든 클래스 및  모든 JSP 페이지(파일)에서 
				  세션(session)에 저장되어진 loginUser 정보를 사용할 수 있게 된다. !!!!
				  그러므로 어떤 정보를 여러 클래스 또는 여러 jsp 페이지에서 공통적으로 사용하고자 한다라면
				  세션(session)에 저장해야 한다.
			*/
			
			HttpSession session = request.getSession(); 
			// 메모리에 생성되어져 있는 session을 불러오는 것이다.
			
			session.setAttribute("loginUser", loginUser);
			// session(세션)에 로그인 되어진 사용자 정보인 loginUser를 키 이름을 "loginUser"로 저장시킨다.
			
			if (loginUser.isRequirePwdChange() == true) {
				String message = "비밀번호를 변경하신지 3개월이 지났습니다. 암호를 변경하세요!!";
				String loc = request.getContextPath() + "/index.up";
				// 원래는 위와 같이 index.up이 아니라 사용자의 암호를 변경해주는 페이지로 잡아주어야 한다.
				
				request.setAttribute("message", message);
				request.setAttribute("loc", loc);
				
				super.setRedirect(false);
				super.setViewPage("/WEB-INF/msg.jsp");
				
				return;
			}else {
			
				// 막바로 페이지 이동을 시킨다.
				
				// 특정 제품상세 페이지를 보았을 경우 로그인을 하면 시작페이지로 가는 것이 아니라
				// 방금 보았던 특정 제품상세 페이지로 가기 위한 것이다.
				String goBackURL = (String)session.getAttribute("goBackURL");
				// shop/prodView.up?pnum=70
				// 또는 
				// null
				
				super.setRedirect(true);

				if (goBackURL != null) { // goBackURL이 null이 아니라면
					super.setViewPage(request.getContextPath()+"/"+goBackURL); // goBackURL에 있는 주소로 이동시키고
					session.removeAttribute("goBackURL"); // 반드시 session에 있는 goBackURL을 지워준다. 
				}else {
					super.setViewPage(request.getContextPath()+"/index.up");
				}
				
			}
			
		} else { 
			//로그인 실패시
		    // System.out.println(">>> 확인용 로그인 실패!!! <<<");
			String message = "로그인 실패";
			String loc = "javascript:history.back()";
			
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
			
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/msg.jsp");
			
		}

		
		
	}

}
