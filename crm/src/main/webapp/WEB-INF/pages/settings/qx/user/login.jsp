<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
	<script type="text/javascript">
		$(function () {
		    //回车键登录 这里document对象也可以
            $(window).keydown(function (event) {
                //alert(event.keyCode); 回车键13
                if(event.keyCode==13){
                    $("#loginBtn").click(); //这里手动调用click很妙
                }
            })
            //登录按钮点击事件
			$("#loginBtn").click(function () {
				var loginAct=$.trim($("#loginAct").val());
				var loginPwd=$.trim($("#loginPwd").val());
				var isRemPwd=$("#isRemPwd").prop("checked");
				if (loginAct==""){
					$("#msg").html("<font color='red'>用户名不能为空</font>");
					return;
				}
				if (loginPwd==""){
					$("#msg").html("<font color='red'>密码不能为空</font>");
					return;
				}
				$.ajax({
					url:"${APP_PATH}/settings/qx/user/login.do",
					data:{
						"loginAct":loginAct,
						"loginPwd":loginPwd,
						"isRemPwd":isRemPwd
					},
					type:"POST",
					dataType:"json",
					success:function (data) {
						if (data.code=="0"){
							$("#msg").html("<font color='red'>"+data.message+"</font>");
						}else if (data.code=="1"){
							window.location.href="${APP_PATH}/workbench/index.do";
						}
					},
					beforeSend:function () {
						$("#msg").html("<font color='green'>验证中...</font>");
						return true;//返回true才会发送ajax请求-
					}
				})
			})
		})
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="../../../image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2019&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="../../../workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" value="${cookie.loginAct.value}" id= "loginAct" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" value="${cookie.loginPwd.value}" id="loginPwd" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd" checked="checked"> 十天内免登录
							</c:if>
							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd"> 十天内免登录
							</c:if>
						</label>
						&nbsp;&nbsp;
						<span id="msg"></span>
					</div>
					<button type="button" class="btn btn-primary btn-lg btn-block" id="loginBtn" style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>