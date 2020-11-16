<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!-- 
// iFrame에는 JQuery가 적용되지 않기 때문에 라이브러리를 넣어주어야 한다.
<script type="text/javascript">
	$(document).ready(function() {
		$("hahaha").val("하하하"); 
	});// end of $(document).ready(function() {});------------------------------
</script>

<input type="text" id="hahaha" value="">    
 -->

<%
    String ctxPath = request.getContextPath();
    //    /MyMVC
%>    

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="<%= ctxPath%>/css/style.css" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>


<style>
   #div_name {
      width: 70%;
      height: 15%;
      margin-bottom: 5%;
      margin-left: 10%;
      position: relative;
   }
   
   #div_email {
      width: 70%;
      height: 15%;
      margin-bottom: 5%;
      margin-left: 10%;
      position: relative;
   }
   
   #div_findResult {
      width: 70%;
      height: 15%;
      margin-bottom: 5%;
      margin-left: 10%;      
      position: relative;
   }
   
   #div_btnFind {
      width: 70%;
      height: 15%;
      margin-bottom: 5%;
      margin-left: 10%;
      position: relative;
   }
   
</style>

<script type="text/javascript">
   
	$(document).ready(function(){
	  
		var method = "${method}"; 

//		console.log("method : " + method);
	  
		if (method == "GET") {
			$("#div_findResult").hide();
	  	}else if (method == "POST") {
			$("input#name").val("${name}");
			$("input#email").val("${email}");
		}
		
	  	$("#btnFind").click(function() {
		// 성명 및 e메일에 대한 유효성 검사는 생략하겠습니다.
		
			var frm = document.idFindFrm;
			frm.action = "<%=ctxPath%>/login/idFind.up"
			frm.method = "POST";
			frm.submit();
			
		});// end of $("#btnFind").click(function() {});-------------------

		
	}); // end of $(document).ready(function(){});------------------------
</script>

<form name="idFindFrm">
   <div id="div_name" align="center">
      <span style="color: blue; font-size: 12pt;">성명</span><br/> 
      <input type="text" name="name" id="name" size="15" placeholder="홍길동" autocomplete="off" required /> <!-- autocomplete="off" => 자동완성기능 끄기. 해당 창을 눌렀을 때 기존에 기입했던 데이터들이 나오는 것을 끔. -->
   </div>
   
   <div id="div_email" align="center">
        <span style="color: blue; font-size: 12pt;">이메일</span><br/>
      <input type="text" name="email" id="email" size="15" placeholder="abc@def.com" autocomplete="off" required />
   </div>
   
   <div id="div_findResult" align="center">
        ID : <span style="color: red; font-size: 16pt; font-weight: bold;">${requestScope.userid}</span> 
   </div>
   
   <div id="div_btnFind" align="center">
         <button type="button" class="btn btn-success" id="btnFind">찾기</button>
   </div>
   
</form>