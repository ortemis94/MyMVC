package member.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import common.controller.AbstractController;
import member.model.InterMemberDAO;
import member.model.MemberDAO;
import member.model.MemberVO;

public class MemberEditEndAction extends AbstractController {

   @Override
   public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

      String method = request.getMethod();
      
      if("POST".equalsIgnoreCase(method)) {
         // **** POST 방식으로 넘어온 것이라면 **** //
         //System.out.println("확인 " +method);
         
         String name = request.getParameter("name");
         String userid = request.getParameter("userid");
         String pwd = request.getParameter("pwd");
         String email = request.getParameter("email");
         String hp1 = request.getParameter("hp1");
         String hp2 = request.getParameter("hp2");
         String hp3 = request.getParameter("hp3");
         String postcode = request.getParameter("postcode");
         String address = request.getParameter("address");
         String detailAddress = request.getParameter("detailAddress");
         String extraAddress = request.getParameter("extraAddress");
         
         String mobile = hp1+hp2+hp3;
         
         //super.setRedirect(true); // sendRedirect방식
         //super.setViewPage(request.getContextPath()+"/index.up"); //sendRedirect로 옮겨가야할 page url를 적어줘야함 (절대경로)
         
         MemberVO member = new MemberVO(userid, pwd, name, email, mobile, postcode, address, detailAddress, extraAddress);
         
         InterMemberDAO mdao = new MemberDAO();
         int n = mdao.updateMember(member);
         
         String message = "";
         String loc = "javascript:history.back()";
         
         if(n==1) {
            
        	// session에 저장된  loginUser를 변경된 사용자의 정보값으로 변경해주어야 한다.
        	HttpSession session = request.getSession();
            
        	MemberVO loginUser = (MemberVO)session.getAttribute("loginUser");
        	
        	loginUser.setName(name);
        	loginUser.setPwd(pwd);
        	loginUser.setEmail(email);
        	loginUser.setMobile(mobile);
        	loginUser.setAddress(address);
        	loginUser.setDetailaddress(detailAddress);
        	loginUser.setExtraaddress(extraAddress);
        	
        	message = "회원정보 수정 성공!!";

         }
         else {
            message = "회원정보 수정 실패";
         }
         
             request.setAttribute("message", message);
              request.setAttribute("loc", loc);
               
              super.setViewPage("/WEB-INF/msg.jsp");
         //System.out.println("확인용 : " +name);
         
         // DAO --> name 변경
      }
      else {
         String message = "비정상적인 경로를 통해 들어왔습니다.!!";
           String loc = "javascript:history.back()";
            
           request.setAttribute("message", message);
           request.setAttribute("loc", loc);
            
           super.setViewPage("/WEB-INF/msg.jsp");
           return;
      }
   }
   
   

}