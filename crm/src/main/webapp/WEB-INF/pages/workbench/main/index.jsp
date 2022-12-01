<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
	<%
		pageContext.setAttribute("APP_PATH",request.getContextPath());
	%>
<meta charset="UTF-8">
<link href="${APP_PATH}/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="${APP_PATH}/jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="${APP_PATH}/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

</head>
<body>
	<img src="${APP_PATH}/image/home.png" style="position: relative;top: -10px; left: -10px;"/>
</body>
</html>