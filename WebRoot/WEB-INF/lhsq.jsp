<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%
String gh=request.getParameter("gh");
RecordSet rs=new RecordSet();
rs.writeLog("进入lhsq.jsp");
rs.writeLog("获得的柜号为："+gh);

String sql="";


rs.executeSql(sql);
rs.writeLog("装卸计划执行sql："+sql);


	JSONArray jsonArr = new JSONArray();
	while(rs.next()){
		Map<String,String> map = new HashMap<String,String>();
		 map.put("SHIPADVICENO", rs.getString("SHIPADVICENO"));
            map.put("PROCATEGORY", rs.getString("PROCATEGORY"));
            
            jsonArr.add(map);
	}
	PrintWriter pw = response.getWriter();
    rs.writeLog("装卸计划返回JSON:"+jsonArr.toString());
	pw.write(jsonArr.toString());
	pw.flush();
	pw.close();




%>