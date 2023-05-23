<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.io.*"%>
<%@ page import="vo.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	// 파일 업로드 위치
	String dir = request.getServletContext().getRealPath("/upload"); 
	System.out.println(dir + " <-- dir(removeBoardAction)");

	// 업로드 파일 최대 용량 (100Mb)
	int max = 10 * 1024 * 1024; 

	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 래핑
	/*
	 MultipartRequest() 내 인자
	 첫 번째: 폼에서 가져온 인자 값을 얻기 위해 request 객체 전달
	 두 번째: 업로드될 파일의 위치
	 세 번째: 파일 업로드 최대 용량의 크기 (넘을 경우 Exception 발생)
	 네 번째: 한글 이름이 넘어올 경우 문제되지 않도록 인코딩 설정
	 다섯 번째: 파일 중복 이름 방지(ex: a.jpg 파일 중복 -> 나중에 저장된 파일 이름을 a1.jpg로 변경)
	*/
	
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "UTF-8", new DefaultFileRenamePolicy());

	if (mRequest.getParameter("boardNo") == null
	|| mRequest.getParameter("boardNo").equals("")) {
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
	}
	
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	// int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	// String boardTitle = mRequest.getParameter("boardTitle");
	String saveFilename = mRequest.getParameter("saveFilename");
	
	System.out.println(boardNo + " <-- boardNo(removeBoardAction)");
	// System.out.println(boardFileNo + " <-- boardFileNo(removeBoardAction)");
	// System.out.println(boardTitle + " <-- boardTitle(removeBoardAction)");
	System.out.println(saveFilename + "< -- saveFilename(removeBoardAction)");

	// 1) file 삭제
	File f = new File(dir + "/" + saveFilename);
	if (f.exists()) {
		f.delete();
		System.out.println(saveFilename + " 파일 삭제");
	}
	
	// 2) board 삭제
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(removeBoardAction)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(removeBoardAction)");
	
	String msg = "";
	String boardSql = "DELETE FROM board WHERE board_no=?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	int boardRow = boardStmt.executeUpdate();
	System.out.println(boardRow + " <-- boardRow(removeBoardAction)");
	if (boardRow == 1) { // board에서 삭제 성공
		System.out.println("삭제 성공");
		msg = URLEncoder.encode("자료 삭제가 완료되었습니다.", "UTF-8");
	} else {
		System.out.println("삭제 실패");
		msg = URLEncoder.encode("자료를 삭제하지 못했습니다.", "UTF-8");
	}
	
	// 삭제 성공 결과 여부 상관없이 boardList.jsp로 이동
	response.sendRedirect(request.getContextPath() + "/boardList.jsp?msg=" + msg);
	
	System.out.println("=====================================");
%>