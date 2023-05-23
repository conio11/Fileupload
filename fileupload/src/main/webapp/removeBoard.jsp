<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%
	// 요청값 유효성 검사
	// boardNo, boardFileNo의 값 중 하나라도 공백 또는 null이면 boardList.jsp로 이동
	if (request.getParameter("boardNo") == null
	|| request.getParameter("boardNo").equals("")
	|| request.getParameter("boardFileNo") == null
	|| request.getParameter("boardFileNo").equals("")) {
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	}

	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	
	System.out.println(boardNo + " <-- boardNo(removeBoard)");
	System.out.println(boardFileNo + " <-- boardFileNo(removeBoard)");
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(removeBoard)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(removeBoard)");
	
	/*  
	// 테이블 1:1 연결
	// board의 board_no, board_file의 board_no 비교하여 같으면 출력
	SELECT 
		b.board_title boardTitle, 
		f.origin_filename originFilename,
		f.save_filename saveFilename,
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no;
	WHERE b.board_no=? AND f.board_file_no=?
	*/
	
	String boardSql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no=? AND f.board_file_no=?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	boardStmt.setInt(2, boardFileNo);
	
	ResultSet boardRs = boardStmt.executeQuery();
	HashMap<String, Object> map = null;
	if (boardRs.next()) { // 한 행만 출력
		map = new HashMap<>();
		map.put("boardNo", boardRs.getInt("boardNo"));
		map.put("boardTitle", boardRs.getString("boardTitle"));
		map.put("boardFileNo", boardRs.getInt("boardFileNo"));
		map.put("originFilename", boardRs.getString("originFilename"));
		map.put("saveFilename", boardRs.getString("saveFilename"));
	}
	
	System.out.println(map.get("boardNo") + " <-- map.get(\"boardNo\")(removeBoard)");
	System.out.println(map.get("boardTitle") + " <-- map.get(\"boardTitle\")(removeBoard)");
	System.out.println(map.get("boardFileNo") + " <-- map.get(\"boardFileNo\")(removeBoard)");
	System.out.println(map.get("originFilename") + " <-- map.get(\"originFilename\")(removeBoard)");
	System.out.println(map.get("saveFilename") + " <-- map.get(\"saveFilename\")(removeBoard)");
	
	System.out.println("=====================================");
%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>removeBoard</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
  		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	</head>
	<body>
		<a href="<%=request.getContextPath()%>/boardList.jsp" class="btn btn-outline-warning">목록으로</a>
		<div class="text-center">
			<h1>board 삭제</h1>
		</div>
		<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post" enctype="multipart/form-data">
			<!-- 테이블에 출력은 하지 않지만 action 파일에 boardNo, boardFileNo값 넘김 -->
			<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
			<input type="hidden" name="saveFilename" value="<%=map.get("saveFilename")%>">
			<table class="table">
				<tr>
					<th class="table-warning text-center">boardTitle</th>
					<td>
						<textarea rows="3" cols="50" name="boardTitle" readonly="readonly" class="form-control"><%=map.get("boardTitle")%></textarea> 
					</td>
				</tr>
				<tr>
					<th class="table-warning text-center">boardFile</th>
					<td>
						<input type="text" name="originFilename" value="<%=map.get("originFilename")%>" readonly="readonly" class="form-control">
					</td>
				</tr>
			
			</table>
			<button type="submit" class="btn btn-outline-warning">삭제</button>
		</form>
	</body>
</html>