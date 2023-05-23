<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.net.*"%>
<%
	session.invalidate(); // 기존 세션 삭제 후 갱신
	String msg = URLEncoder.encode("로그아웃 되었습니다.", "UTF-8");
	
	response.sendRedirect(request.getContextPath() + "/boardList.jsp?msg=" + msg);
%>