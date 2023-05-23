<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%@ page import="vo.*"%>
<%
	// post 방식 인코딩 설정
	request.setCharacterEncoding("UTF-8");

	// 세션 유효성 확인 후 요청값 유효성 확인
	
	// 세션 유효성 확인
	// 세션 없을 경우 로그인 폼으로 이동
	if (session.getAttribute("loginMemberID") != null) {
		response.sendRedirect(request.getContextPath() + "/login.jsp");
		return; // 실행 종료
	}
	
	// 요청값 유효성 확인
	// 아이디, 비밀번호 중 하나라도 null값이거나 공백값일 경우 로그인 폼으로 이동
	if (request.getParameter("memberID") == null 
	|| request.getParameter("memberID").equals("")
	|| request.getParameter("memberPW") == null
	|| request.getParameter("memberPW").equals("")) {
		response.sendRedirect(request.getContextPath() + "/login.jsp");
		return;
	}
	
	String memberID = request.getParameter("memberID");
	String memberPW = request.getParameter("memberPW");
	
	// 디버깅
	System.out.println(memberID + " <-- memberID(loginAction)");
	System.out.println(memberPW + " <-- memberPW(loginAction)");
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);    
	System.out.println("드라이버 로딩 성공(loginAction)");
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println("DB 접속 성공(loginAction)");
	
	String loginSql = "SELECT member_id memberID FROM member WHERE member_id=? AND member_pw=PASSWORD(?)";
	PreparedStatement loginStmt = conn.prepareStatement(loginSql);
%>