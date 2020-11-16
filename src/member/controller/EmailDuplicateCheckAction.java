package member.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import common.controller.AbstractController;
import member.model.InterMemberDAO;
import member.model.MemberDAO;

public class EmailDuplicateCheckAction extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String email = request.getParameter("email");
		
		InterMemberDAO mdao = new MemberDAO();
		boolean isExists = mdao.emailDuplicateCheck(email); 
		
		JSONObject jsonObj = new JSONObject();
		jsonObj.put("isExists", isExists);
		
		String json = jsonObj.toString();
		
		System.out.println("2 " + email );
		System.out.println(">>> 확인용 json ==> " + json);
		
		request.setAttribute("json", json);
		
	//	super.setRedirect(false);
		super.setViewPage("/WEB-INF/jsonview.jsp");

	}

}
