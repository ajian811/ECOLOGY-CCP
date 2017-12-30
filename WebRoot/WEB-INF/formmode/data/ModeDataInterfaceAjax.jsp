
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="weaver.formmode.data.ModeDataManager" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
User user = HrmUserVarify.getUser (request , response) ;
int pageexpandid = Util.getIntValue(request.getParameter("pageexpandid"),0);
int modeid = Util.getIntValue(request.getParameter("modeid"),-1);
int formid = Util.getIntValue(request.getParameter("formid"),-1);
int isbill = 1;
int billid = Util.getIntValue(request.getParameter("billid"),-1);
ModeDataManager ModeDataManager = new ModeDataManager(billid,modeid);
ModeDataManager.setPageexpandid(pageexpandid);
ModeDataManager.setUser(user);
ModeDataManager.doInterface(pageexpandid);
%>
<%=true%>
