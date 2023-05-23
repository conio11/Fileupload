<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.io.*"%>
<%@ page import="vo.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 10 * 1024 * 1024;
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "UTF-8", new DefaultFileRenamePolicy());
	// System.out.println(mRequest.getOriginalFileName("boardFile") + " <-- boardFile()");
	// String originFilename = mRequest.getOriginalFileName("boardFile") 값이 null이면 board 테이블 title만 수정
	
	// 1) board_title 수정
	String msg = "";
	String msg2 = "";
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	
	System.out.println(boardNo + " <-- boardNo(modifyBoardAction)");
	System.out.println(boardFileNo + " <-- boardFileNo(modifyBoardAction)");
	System.out.println(boardTitle + " <-- boardTitle(modifyBoardAction)");
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	System.out.println("드라이버 로딩 성공(modifyBoardAction)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(modifyBoardAction)");
	
	String boardSql = "UPDATE board SET board_title=? WHERE board_no=?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	
	int boardRow = boardStmt.executeUpdate();
	System.out.println(boardRow + " <-- boardRow(modifyBoardAction)");
	if (boardRow == 1) {
		System.out.println("게시글명 변경 성공");
		msg = URLEncoder.encode("게시글명 변경이 완료되었습니다.", "UTF-8");
	} else {
		System.out.println("게시글명 변경 실패");
		msg = URLEncoder.encode("게시글명 변경이 완료되었습니다.", "UTF-8");
	}

	// 2) 이전 boardFile 삭제, 새 boardFile 추가, 테이블 수정
			
	if (mRequest.getOriginalFileName("boardFile") != null) {
		// 수정할 파일이 있으면 
		String originFilename = mRequest.getOriginalFileName("boardFile");
		// PDF 파일 유효성 검사
		// PDF 형식이 아니면 새로 업로드한 파일 삭제
		if (mRequest.getContentType("boardFile").equals("application/pdf") == false) {
			System.out.println("PDF 파일이 아닙니다.");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			File f = new File(dir + "\\" + saveFilename); // 경로(dir) 없으면 파일 찾을 수 없음
			if (f.exists()) {
				f.delete();
				System.out.println(saveFilename + " 파일 삭제");
			}
		} else { // PDF 형식 파일이면 이전 파일(saveFilename) 삭제 후 DB 수정(update)
			String type = mRequest.getContentType("boardFile");
			originFilename = mRequest.getOriginalFileName("boardFile");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			// 2-1) 이전파일 삭제
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no=?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			
			// String prePath = "";
			String preSaveFilename = "";
			if (saveFilenameRs.next()) {
				// prePath = saveFilenameRs.getString("path");
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			// String dir = request.getServletPath().getRealPath("/" + prePath);
			File f = new File(dir + "/" + preSaveFilename);
			if (f.exists()) {
				f.delete();
			}
			
			// 2-2) 수정된 파일의 정보로 DB를 수정
			String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			
			int boardFileRow = boardFileStmt.executeUpdate();
			System.out.println(boardFileRow + " <-- boardFileRow(modifyBoardAction)");
			if (boardFileRow == 1) {
				System.out.println("PDF 자료 변경 성공");
				msg2 = URLEncoder.encode("PDF 자료 변경이 완료되었습니다.", "UTF-8");
			} else {
				System.out.println("PDF 자료 변경 실패");
				msg2 = URLEncoder.encode("PDF 자료 변경이 완료되었습니다.", "UTF-8");
			}
		}
	}	
	response.sendRedirect(request.getContextPath() + "/boardList.jsp?msg=" + msg + "&msg2=" + msg2);
	
	System.out.println("================================");
%>