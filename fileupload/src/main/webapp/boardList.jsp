<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>

<%
	// post 방식 인코딩 설정
	// request.setCharacterEncoding("UTF-8");

	// 페이징
	int currentPage = 1;
	if (request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + " <-- currentPage(boardList)");
	
	// 한 페이지에 출력되는 행의 수
	// ... LIMIT startRow, rowPerPage (0, 10), (10, 10), ...
	int rowPerPage = 10;
	int startRow = (currentPage - 1) * rowPerPage;
	System.out.println(startRow + " <-- startRow(boardList)");

	//DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(boardList)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(boardList)");
	
	/*  
	// 테이블 1:1 연결
	// board의 board_no, board_file의 board_no 비교하여 같으면 출력?
	SELECT 
		b.board_title boardTitle, 
		f.origin_filename originFilename,
		f.save_filename saveFilename,
		path
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no
	ORDER BY b.createdate DESC;
	*/
	
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle,f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while (rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
	
	// board의 전체 행의 수, 마지막 페이지
	String pageSql = "SELECT COUNT(*) FROM board";
	PreparedStatement pageStmt = conn.prepareStatement(pageSql);
	ResultSet pageRs = pageStmt.executeQuery();
	int totalRow = 0;
	if (pageRs.next()) {
		totalRow = pageRs.getInt(1); // COUNT(*) 대신 인덱스 사용 가능 (구하는 행이 1개)
	}
	
	int lastPage = totalRow / rowPerPage;
	if (totalRow % rowPerPage != 0) {
		lastPage += 1;
	}
	
	// 디버깅
	System.out.println(totalRow + " <-- totalRow(boardList)");
	System.out.println(lastPage + " <-- lastPage(boardList)");
	
	System.out.println("================================");
%>

<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>boardList</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
  		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	</head>
	<body>
		<%
			if (session.getAttribute("loginMemberID") == null) { // 로그인 상태에서는 보이지 않음
		%>
				<a href="<%=request.getContextPath()%>/login.jsp" class="btn btn-outline-warning">로그인</a>
		<%		
			}
		%>
		
		<div class="text-center">
			<h1>PDF 자료 목록</h1>
		</div>
		
		<%
			if (session.getAttribute("loginMemberID") != null) {
		%>
			<div>
				<h5>현재 로그인 아이디: <%=session.getAttribute("loginMemberID")%></h5>
			</div>
		<%		
			}
		%>
		
		<%
			if (request.getParameter("msg") != null) {
		%>
				<%=request.getParameter("msg")%>
		<%
			} 
		%>
		
 		<% 
			if (request.getParameter("msg2") != null) { 
		%>
				<%=request.getParameter("msg2")%>
		<%
			}
		%> 
		<br>
		
		<table class="table">
			<tr class="table-warning text-center">
				<th>boardTitle</th>
				<th>originFilename</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
		<%
			for (HashMap<String, Object> m : list) {
		%>
			<tr class="text-center">
				<td><%=(String)m.get("boardTitle")%></td>
				<td>
					<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>" class="btn btn-outline-light text-dark">
						<%=(String)m.get("originFilename")%>
					</a>
				</td>
				<td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>" class="btn btn-outline-light text-dark">수정</a></td>
				<td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>" class="btn btn-outline-light text-dark">삭제</a></td>
			</tr>
		<%
			}
		%>
		</table>
		
		<%
			// 테이블 하단 페이징
			// [이전] 1 2 3 4 5... [다음]
			int pagePerPage = 5;
		
			// minPage: [이전] [다음] 탭 사이 가장 작은 숫자
			// maxPage: [이전] [다음] 탭 사이 가장 큰 숫자
			int minPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1; 
			int maxPage = minPage + (pagePerPage - 1);
			// 1, 6, 11, 16, ...
			// 5, 10, 15
			if (maxPage > lastPage) {
				maxPage = lastPage;
			}
					
		%>
		
		<%
			if (minPage > 1) { // 현재 페이지의 minPage가 1보다 크면 (5, 11, ...) 이전 버튼 생성
		%>

		<%
			}
		%>		
		
		
		
		<%
			if (session.getAttribute("loginMemberID") != null) { // 로그인 상태가 아니면 보이지 않음
		%>
				<a href="<%=request.getContextPath()%>/addBoard.jsp" class="btn btn-outline-warning">새 자료 업로드</a>
				<a href="<%=request.getContextPath()%>/logoutAction.jsp" class="btn btn-outline-warning">로그아웃</a>	
		<%		
			}
		%>
		
	</body>
</html>