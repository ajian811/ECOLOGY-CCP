<%@ page import="weaver.general.Util" %>
<%@ page import="org.json.JSONObject" %>
<%@ page language="java" contentType="text/html; UTF-8" pageEncoding="UTF-8" %>
<jsp:useBean id="log" class="weaver.general.BaseBean"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet"/>
<%
    log.writeLog("进入发票管理作废，FPGL_ZF.jsp");
    String sql="";
    String reqid="";
    String yddzddh="";//月度对账单号
    String sqbh="";//发票申请编号
    JSONObject jsonObject=new JSONObject();
    reqid=request.getParameter("reqid");
    sql="SELECT yddzddh FROM uf_invocemag where id="+reqid;
    log.writeLog(sql);
    rs.execute(sql);
    if (rs.next()){
        yddzddh= Util.null2String(rs.getString("yddzddh"));
    }
    if("".equals(yddzddh)){
        jsonObject.put("message","报错！月度对账单单号为空");
        out.write(jsonObject.toString());
        return;
    }
    sql="SELECT sqbh FROM uf_qkqz where sfzf='0' and yddzd='"+yddzddh+"'";
    log.writeLog(sql);
    rs.execute(sql);
    while (rs.next()){
        sqbh=Util.null2String(rs.getString("sqbh"));
    }
    if (!"".equals(sqbh)){
        jsonObject.put("message","该发票申请所关联的月度对账单号："+yddzddh+",还关联了请款申请："+sqbh+",请先作废该请款申请");
        out.write(jsonObject.toString());
        return;
    }
    sql="update uf_invocemag set sfzf='1' where id="+reqid;
    log.writeLog(sql);
    Boolean result=rs.execute(sql);
    if (result){
        jsonObject.put("message","发票作废成功");
        out.write(jsonObject.toString());
    }else{
        jsonObject.put("message","发票作废作废失败，请联系管理员");
        out.write(jsonObject.toString());
    }
    return;



%>