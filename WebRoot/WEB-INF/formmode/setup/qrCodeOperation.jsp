
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util"%>
<%@ page import="weaver.system.code.*"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}
%>
<%
  String modeId=  Util.null2String(request.getParameter("modeId"));
  int txtUserUse=  Util.getIntValue(request.getParameter("txtUserUse"),0);
  String targetType=  Util.null2String(request.getParameter("targetType"));
  String targetUrl=  Util.null2String(request.getParameter("targetUrl"));
  String w=  Util.null2String(request.getParameter("w"));
  String h=  Util.null2String(request.getParameter("h"));
  String baseinfo=  Util.null2String(request.getParameter("baseinfo")); 
  rs.executeSql("select 1 from ModeQRCode where modeid="+modeId); 
  if (rs.next()) { //如果已经有数据了，就更新
  	  rs.executeSql("update ModeQRCode set isuse='"+txtUserUse+"',targetType='"+targetType+"',targetUrl='"+targetUrl+"',width="+w+",height="+h+",qrCodeDesc='"+baseinfo+"' where modeid="+modeId);
  } else {
  	  rs.executeSql("insert into ModeQRCode(modeid,isuse,targetType,targetUrl,width,height,qrCodeDesc) values("+modeId+",'"+txtUserUse+"','"+targetType+"','"+targetUrl+"',"+w+","+h+",'"+baseinfo+"')");
  }
  response.sendRedirect("QRCode.jsp?modeId="+modeId);
%>