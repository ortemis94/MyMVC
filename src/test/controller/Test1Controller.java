package test.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import common.controller.AbstractController;

public class Test1Controller extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		// super.setRedirect(false);
		request.setAttribute("introduce", "안녕하세요?<br>권오윤의 개인홈페이지에 오신 것을 환영합니다.");
		
		super.setViewPage("/WEB-INF/test/test1.jsp");
	}

}
