package myshop.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.*;

import common.controller.AbstractController;
import myshop.model.*;

public class CommentListAction extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String fk_pnum = request.getParameter("fk_pnum"); // 제품번호
		
		InterProductDAO pdao = new ProductDAO();
		
		JSONArray jsArr = new JSONArray(); // []
		
		List<PurchaseReviewsVO> commentList = pdao.commentList(fk_pnum);
		
		if (commentList != null && commentList.size() > 0) {
			for (PurchaseReviewsVO reviewsvo : commentList) {
				JSONObject jsObj = new JSONObject();				// {}  {}
				jsObj.put("contents", reviewsvo.getContents());		// {"contents":"제품후기내용물1"}  {"contents":"제품후기내용물2"}
				jsObj.put("name", reviewsvo.getMvo().getName());	// {"contents":"제품후기내용물1", "name":"작성자이름1"}  {"contents":"제품후기내용물2", "name":"작성자이름2"}
				jsObj.put("writeDate", reviewsvo.getWriteDate()); 	// {"contents":"제품후기내용물1", "name":"작성자이름1", "writeDate":"작성일자1"}  {"contents":"제품후기내용물2", "name":"작성자이름2", "writeDate":"작성일자2"}
		
				jsArr.put(jsObj); // [{"contents":"제품후기내용물1", "name":"작성자이름1", "writeDate":"작성일자1"} {"contents":"제품후기내용물2", "name":"작성자이름2", "writeDate":"작성일자2"}]
			}
		}

		String json = jsArr.toString(); // 문자열 형태로 변환해줌.
		
		request.setAttribute("json", json);
		
		super.setRedirect(false);
		super.setViewPage("/WEB-INF/jsonview.jsp");
	}

}
