<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>

<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<%
	int modeId=  Util.getIntValue(request.getParameter("modeId"));
    int isused = Util.getIntValue(request.getParameter("isused"));
    String resolution = Util.null2String(request.getParameter("resolution"));
    String size = Util.null2String(request.getParameter("size"));
    String codenum = Util.null2String(request.getParameter("codenum"));
	String info=  Util.null2String(request.getParameter("info")); 
	rs.executeSql("select 1 from mode_barcode where modeid="+modeId); 
	if (rs.next()) { //如果已经有数据了，就更新
		  rs.executeSql("update mode_barcode set isused="+isused+",resolution='"+resolution+"',codesize='"+size+"',codenum='"+codenum+"',info='"+info+"' where modeid="+modeId);
	} else {
		  rs.executeSql("insert into mode_barcode(modeid,isused,resolution,codesize,codenum,info) values("+modeId+","+isused+",'"+resolution+"','"+size+"','"+codenum+"','"+info+"')");
	}
	response.sendRedirect("BarCode.jsp?modeId="+modeId);
%>
