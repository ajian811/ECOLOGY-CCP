<%@page pageEncoding="UTF-8" language="java" contentType="text/html; UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="net.sf.json.JSONObject" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<%
    rs.writeLog("进入SO装卸计划刷新暂估单REFRESH_ZGD_SOZXJH.jsp");
    String id=request.getParameter("id");
    String sql="";
    sql="SELECT ZXJHH,sfzf FROM formtable_main_45 where id="+id;
    rs.writeLog(">>sql>>"+sql+"<<<");
    rs.execute(sql);
    String zxjhh="";
    String sfzf="";
    String message="";
    JSONObject jsonObject=new JSONObject();
    if (rs.next()){
        zxjhh= Util.null2String(rs.getString("zxjhh"));
        sfzf= Util.null2String(rs.getString("sfzf"));
    }
    if ("1".equals(sfzf)){
        message="该装卸计划已经作废了，不能刷新暂估单";
        jsonObject=returnJson(message);
        rs.writeLog(message);
        out.write(jsonObject.toString());
        return;
    }

        String lx="0";
        String type="1";
        request.getRequestDispatcher("/weightJsp/SHORT_LIST.jsp?zxjhh=" + zxjhh + "&lx=" + lx+"&type="+type).forward(request,response);

%>
<%!public JSONObject returnJson(String message)  {
    JSONObject jsonObject=new JSONObject();
    jsonObject.put("message",message);
    return  jsonObject;
}

%>