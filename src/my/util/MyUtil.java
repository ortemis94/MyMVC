package my.util;

import javax.servlet.http.HttpServletRequest;

public class MyUtil {
	
	// *** ? 다음의 데이터까지 포함한 현재 URL 주소를 알려주는 메소드를 생성 *** //
	public static String getCurrentURL(HttpServletRequest request) {
		
		String currentURL = request.getRequestURL().toString(); // 파라미터 부분이 없는 URL이 리턴됨.
		// http://localhost:9090/MyMVC/member/memberList.up
		
		String queryString = request.getQueryString(); // URL다음부터 나오는 파라미터 부분이 리턴됨.
		// currentShowPageNo=3&sizePerPage=10&searchType=name&searchWord=아이유
		
		
		if (queryString != null) {
			currentURL += "?" + queryString;
			// http://localhost:9090/MyMVC/member/memberList.up?currentShowPageNo=3&sizePerPage=10&searchType=name&searchWord=아이유
		}

		String ctxPath = request.getContextPath();
		//	   /MyMVC
		
		int beginIndex = 0;
		
		
		beginIndex = currentURL.indexOf(ctxPath) + ctxPath.length();
					 // 			21			 +		6
		
		currentURL = currentURL.substring(beginIndex + 1);
		// 			 member/memberList.up?currentShowPageNo=3&sizePerPage=10&searchType=name&searchWord=아이유
		
/*		
		beginIndex = currentURL.indexOf("/");
		
		currentURL = currentURL.substring(beginIndex + 1);
		
		System.out.println(currentURL);
		
*/
		return currentURL;
	}
	
}
