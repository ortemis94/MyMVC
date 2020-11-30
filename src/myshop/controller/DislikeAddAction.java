package myshop.controller;

import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import common.controller.AbstractController;
import myshop.model.*;

public class DislikeAddAction extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String pnum = request.getParameter("pnum");
		String userid = request.getParameter("userid");
		
		Map<String, String> paraMap = new HashMap<>();
		paraMap.put("pnum", pnum);
		paraMap.put("userid", userid);
		
		InterProductDAO pdao = new ProductDAO();
		int	n = pdao.dislikeAdd(paraMap);
		// n => 1이라면 정상투표, n => 0이라면 중복투표.
		
		String msg = "";
		if (n == 1) {
			msg = "해당제품에\n 싫어요를 클릭하셨습니다."; 
		}else {
			msg = "이미 싫어요를 클릭하셨기에\n 두 번 이상 싫어요는 불가합니다.";
		}
		
		JSONObject jsonObj = new JSONObject();
		jsonObj.put("msg", msg); // {"msg":"해당제품에\n 싫어요를 클릭하셨습니다."} 또는 {"msg":"이미 싫어요를 클릭하셨기에\n 두 번 이상 싫어요는 불가합니다."}
		
		String json = jsonObj.toString(); // "{"msg":"해당제품에\n 싫어요를 클릭하셨습니다."}" 또는 "{"msg":"이미 싫어요를 클릭하셨기에\n 두 번 이상 싫어요는 불가합니다."}"
		
		request.setAttribute("json", json);
		
		super.setRedirect(false);
		super.setViewPage("/WEB-INF/jsonview.jsp");
		
	}

}
