package myshop.controller;

import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import common.controller.AbstractController;
import myshop.model.*;

public class LocationJSONAction extends AbstractController {

	@Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
      
		InterProductDAO pdao = new ProductDAO();
      
		// tbl_map(위,경도) 테이블에 있는 정보 가져오기(select)  
		List<HashMap<String,String>> storeMapList = pdao.selectStoreMap();
      
		JSONArray jsonArr = new JSONArray();
      
		if(storeMapList.size() > 0) {
			for(HashMap<String,String> storeMap : storeMapList) {
	            JSONObject jsonObj = new JSONObject();
	            
	            String storeurl = storeMap.get("STOREURL");
	            String storename = storeMap.get("STORENAME");
	            String storeimg = storeMap.get("STOREIMG");
	            String storeaddress = storeMap.get("STOREADDRESS");
	            double lat = Double.parseDouble(storeMap.get("LAT"));
	            double lng = Double.parseDouble(storeMap.get("LNG"));
	            int zIndex = Integer.parseInt(storeMap.get("ZINDEX"));
	                        
	            jsonObj.put("storeurl", storeurl);
	            jsonObj.put("storename", storename);
	            jsonObj.put("storeimg", storeimg);
	            jsonObj.put("storeaddress", storeaddress);
	            jsonObj.put("lat", lat);
	            jsonObj.put("lng", lng);
	            jsonObj.put("zIndex", zIndex);
	            
	            jsonArr.put(jsonObj);
			}
		}
      
		String json = jsonArr.toString();
		request.setAttribute("json", json);
      
		// super.setRedirect(false);
		super.setViewPage("/WEB-INF/jsonview.jsp");
	}

}
