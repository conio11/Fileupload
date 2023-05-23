<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="vo.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	// 파일 업로드 위치
	String dir = request.getServletContext().getRealPath("/upload"); // 경로 오류 발생 시 PC에 오류 주소 복사 후 upload 폴더 직접 생성
	System.out.println(dir + " <-- dir(addBoardAction)");
	
	// 업로드 파일 최대 용량 (100Mb)
	int max = 10 * 1024 * 1024;
	
	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 래핑
	// MultipartRequest() 내 첫 번째 인자: 폼에서 가져온 인자 값을 얻기 위해 request 객체 전달
	// 두 번째 인자: 업로드될 파일의 위치
	// 세 번째 인자: 파일 업로드 최대 용량의 크기 (넘을 경우 Exception 발생)
	// 네 번째 인자: 한글 이름이 넘어올 경우 문제되지 않도록 인코딩 설정
	// 다섯 번째 인자: 파일 중복 이름 방지(ex: a.jpg 파일 중복 -> 나중에 저장된 파일 이름을 a1.jpg로 변경)
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "UTF-8", new DefaultFileRenamePolicy()); // new DefaultFileRenamePolicy(): 중복값 방지
	
	// MultipartRequest API를 사용하여 스트림 내에서 문자값을 반환받을 수 있음
	
	// 업로드 파일이 pdf 파일이 아니면
	if (mRequest.getContentType("boardFile").equals("application/pdf") == false) {
		// 위에서 저장된 파일을 삭제
		System.out.println("PDF 파일이 아닙니다.");
		String saveFilename = mRequest.getFilesystemName("boardFile");
		File f = new File(dir + "\\" + saveFilename); // 경로(dir) 없으면 파일 찾을 수 없음
		if (f.exists()) {
			f.delete();
			System.out.println(saveFilename + " 파일 삭제");
		}
		return; // 실행 종료
	}

	// 1) input type="text" 반환 API -> board 테이블 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberID = mRequest.getParameter("memberID");
	
	System.out.println(boardTitle + " <-- boardTitle(addBoardAction)");
	System.out.println(memberID + " <-- memberID(addBoardAction)");
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberID(memberID);
	
	// 2) input type="file" 값(파일 메타 정보) 반환 API (원본 파일 이름, 저장된 파일 이름, 컨텐츠 타입)
	// -> board_file 테이블 저장
	// 파일(바이너리)은 이미 MultipartRequest 객체 생성 시 (request 랩핑 시, 21라인) 먼저 저장
	// .getFile().length() 파일의 크기 반환 (long 타입)
	String type = mRequest.getContentType("boardFile"); // .getContentType(): 업로드된 파일의 타입 반환
	String originFilename = mRequest.getOriginalFileName("boardFile"); // .getOriginalFileName(): 사용자가 업로드한 파일명 반환
	String saveFilename = mRequest.getFilesystemName("boardFile"); // .getFilesystemName() 서버에 업로드된 파일명 반환
	
	System.out.println(type + " <-- type(addBoardAction)");
	System.out.println(originFilename + " <-- originFilename(addBoardAction)");
	System.out.println(saveFilename + " <-- saveFilename(addBoardAction)");
	
	BoardFile boardFile = new BoardFile();
	// boardFile.setBoardNo(boardNo)
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	/* 
	INSERT INTO board(board_title, member_id, updatedate, createdate)
	VALUES (?, ?, NOW(), NOW());
	
	INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
	VALUES(?, ?, ?, ?, ?, NOW());

	INSERT 쿼리 실행 후 기본키값 받아오는 JDBC API
	String sql = "INSERT 쿼리문";
	pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
	int row = pstmt.executeUpdate(); // insert 쿼리 실행
	ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select 쿼리 진행
	int keyValue = 0;
	if (keyRs.next()) {
		keyValue = rs.getInt(1);
	}		
	*/
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(addBoardAction)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(addBoardAction)");
	
	// PreparedStatement.RETURN_GENERATED_KEYS: PreparedStatement 객체를 사용하여 SQL 쿼리를 실행할 때, 자동으로 생성된 키(보통 AUTO_INCREMENT 열의 값)를 검색하기 위한 상수
	String msg = "";
	String boardSql = "INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES (?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS); 
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberID);
	int boardRow = boardStmt.executeUpdate(); // board 입력 후 키값 저장
	System.out.println(boardRow + " <-- boardRow(addBoardAction)");
	if (boardRow == 1) { // board에서 삭제 성공
		System.out.println("입력 성공");
		msg = URLEncoder.encode("자료를 업로드했습니다.", "UTF-8");
	} else {
		System.out.println("입력 실패");
		msg = URLEncoder.encode("자료를 업로드하지 못했습니다.", "UTF-8");
	}
	
	// String sql = "SELECT MAX(board_no) FROM board";
	ResultSet keyRs = boardStmt.getGeneratedKeys();
	int boardNo = 0;
	if (keyRs.next()) {
		boardNo = keyRs.getInt(1);
	}
	
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	fileStmt.executeUpdate(); // board_file 입력
	
	response.sendRedirect(request.getContextPath() + "/boardList.jsp?msg=" + msg); // boardList.jsp 파일로 이동
	
	System.out.println("================================================");	
%>