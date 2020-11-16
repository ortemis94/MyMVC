package common.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import myshop.model.ImageVO;
import myshop.model.InterProductDAO;
import myshop.model.ProductDAO;

public class IndexController extends AbstractController {

	@Override
	public String toString() {
		return "@@@ 클래스 IndexController의 인스턴스 메소드 toString() 호출함 @@@";
	}
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

	//	System.out.println("@@@ 확인용 IndexController의 인스턴스 메소드 execute()가 호출됨 @@@");
		
		InterProductDAO pdao = new ProductDAO();
		List<ImageVO> imgList = pdao.imageSelectAll();
		
		request.setAttribute("imgList", imgList);
		
		//	super.setRedirect(false); // false의 경우, default값이므로 굳이 넣을필요 없음.
		//	this.setRedirect(false);
		//	setRedirect(false); // this 생략된 것.
		//  위에 세 코드는 모두 동일함.
		
		super.setViewPage("/WEB-INF/index.jsp");
		
		
	}

}
