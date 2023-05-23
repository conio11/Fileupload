<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>add board + file</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
  		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	<!-- 	<style type="text/css">
			table, th, td {
				border: 1px solid #FF0000;
			}
		</style> -->
	</head>
	<body>
		<a href="<%=request.getContextPath()%>/boardList.jsp" class="btn btn-outline-warning">목록으로</a>
		<div class="text-center">
			<h1>자료 업로드</h1>
		</div>
		<form action="<%=request.getContextPath()%>/addBoardAction.jsp" method="post" enctype="multipart/form-data">
			<table class="table">
				<!-- 자료 업로드 글 제목  -->
				<tr>
					<th class="table-warning text-center">boardTitle</th>
					<td>
						<textarea rows="3" cols="50" name="boardTitle" required="required" class="form-control"></textarea> <!-- required: null값 submit 시 경고창 출력 -->
					</td>
				</tr>
				<!-- 로그인 사용자 아이디 -->
			<%
				// String memberID = String(session.getAttribute("loginMemberID");
				String memberID = "test";
			%>
				<tr>
					<th class="table-warning text-center">memberID</th>
					<td>
						<input type="text" name="memberID" value="<%=memberID%>" readonly="readonly" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-warning text-center">boardFile</th>
					<td>
						<input type="file" name="boardFile" required="required" class="form-control"> <!-- multiple="multiple": 복수 선택 가능  --> <!-- required: null값 submit 시 경고창 출력 -->
					</td>
				</tr>
			</table>
			<button type="submit" class="btn btn-outline-warning">업로드</button>
		</form>
	</body>
</html>