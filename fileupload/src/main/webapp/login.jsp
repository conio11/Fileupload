<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	// post 방식 인코딩 설정
	request.setCharacterEncoding("UTF-8");

	System.out.println("==========login==========");
%>
<!DOCTYPE html>
	<html>
	<head>
		<meta charset="UTF-8">
		<title>login</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
  		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	</head>
	<body>
		<div class="container mt-3">
	<%
		if (session.getAttribute("loginMemberID") == null) { // 로그인 상태가 아닐 경우에만 로그인폼 출력
	%>
	
			<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
				<a href="<%=request.getContextPath()%>/boardList.jsp" class="btn btn-outline-warning">비회원으로 접속</a>
				<div class="text-center">
					<h1>로그인</h1>
				</div>
				<%
					if (request.getParameter("msg") != null) {
				%>
						<%=request.getParameter("msg")%>
				<%
					}
				%>
				<table class="table">	
					<tr>
						<th class="table-warning text-center">아이디</th>
						<td><input type="text" name="memberID" class="form-control w-75" placeholder="아이디를 입력하세요."></td>
					</tr>
					<tr>
						<th class="table-warning text-center">비밀번호</th>
						<td><input type="password" name="memberPW" class="form-control w-75" placeholder="비밀번호를 입력하세요."></td>
					</tr>
				</table>
				<button type="submit" class="btn btn-outline-warning">로그인</button>
	<%
		} else { // 로그인 상태인 경우 boardList.jsp로 이동
			response.sendRedirect(request.getContextPath() + "/boardList.jsp");
			// response.sendRedirect(request.getContextPath() + "/boardList.jsp?msg=" + msg);
		}
	%>
		</form>
		</div>
	</body>
</html>