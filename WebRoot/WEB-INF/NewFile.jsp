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
String[] strs=request.getParameterValues("ghs[]");
RecordSet rs=new RecordSet();
String sql="SELECT SHIPADVICENO,PROCATEGORY FROM uf_spghsr WHERE 1=1 ";
for(int i=0;i<strs.length;i++){
 if(i==0)
 sql+="and SHIPADVICENO="+strs[i];
 else
  sql+="or SHIPADVICENO="+strs[i];
}
//out.print(sql);
rs.executeSql(sql);
rs.writeLog(sql);



	JSONArray jsonArr = new JSONArray();
	while(rs.next()){
		Map<String,String> map = new HashMap<String,String>();
		 map.put("SHIPADVICENO", rs.getString("SHIPADVICENO"));
            map.put("PROCATEGORY", rs.getString("PROCATEGORY"));
            
            jsonArr.add(map);
	}
	PrintWriter pw = response.getWriter();
	rs.writeLog(jsonArr.toString());
	pw.write(jsonArr.toString());
	pw.flush();
	pw.close();
	rs.executeSql("");

%>