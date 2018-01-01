<%@page import="java.math.BigDecimal"%>
<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page import="weaver.general.Util"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%

	String action = request.getParameter("action");
	RecordSet rs = new RecordSet();
	rs.writeLog("VGM1");
	String ksrq=request.getParameter("ksrq");
	String jsrq=request.getParameter("jsrq");
	String shipping=request.getParameter("shipping");
	String lx = request.getParameter("lx");
	JSONArray jsonArr = new JSONArray();
	JSONObject jsonObject= new JSONObject();
	//billid= Util.null2String(request.get1Parameter("billid"));//billid
	String sql="";
	String message="";
	
	try {
		if(lx == "0"){
			if(!shipping.equals("")){
				sql+="SELECT c.shipping,a.gh,c.cabtype,a.cz,a.rz,a.jz from UF_GBJL a,UF_GHLR_DT1 b,UF_GHLR c where c.id = b.MAINID and a.GH = b.code and ";
				sql+="c.shipping = '"+shipping+"'";
				sql+="and a.gh is not null and a.jz is not null order by a.gbrq desc,a.gbsj desc";
				
				rs.writeLog(sql);
				rs.execute(sql);
				while(rs.next()){
					JSONObject obj=new JSONObject();
					obj.put("shipping", Util.null2String(rs.getString("shipping")));
					obj.put("gh", Util.null2String(rs.getString("gh")));
					obj.put("cabtype", Util.null2String(rs.getString("cabtype")));
					obj.put("jz", Util.null2String(rs.getString("jz")));
					jsonArr.add(obj);
				}
			}
		}
		
		
	} catch (Exception e) {
		// TODO: handle exception
		//out.write("fail" + e);
		rs.writeLog("fail--" + e);
		message+="fail"+e;
		e.printStackTrace();
		

	}
	rs.writeLog("返回json："+jsonArr.toString());
	out.write(jsonArr.toString());
%>

<%!public Double calculateJZ(String rz,String cz){
	Util.getDoubleValue("0.00");
	if(rz.equals("")||rz==null){
		
		rz="0.00";
	}
	if(cz.equals("")||rz==null){
		
		cz="0.00";
	}
	//计算净重的绝对值
	BigDecimal b1=new BigDecimal(rz);
	BigDecimal b2=new BigDecimal(cz);
	Double b3=b1.subtract(b2).doubleValue();
	return Math.abs(b3);
	}%>

<%!public String null2Double(String str){
	String d1="0.00";
	if(str.equals("")||str==null){
		return d1;
	}
	return str;
	
	
	}%>

<%!public JSONObject addJsonJZ(String message) {

		return addJson(message, null, null, null);
	}%>
<%!public JSONObject addJson(String message, String newcp, String trdStatus, String ptStatus) {
		JSONObject jsonobj = new JSONObject();
		jsonobj.put("message", message);
		jsonobj.put("cp", newcp);
		jsonobj.put("trdStatus", trdStatus);
		jsonobj.put("ptStatus", ptStatus);
		return jsonobj;
	}%>
<%!public RecordSet getGBZJ(String planNo) {
		RecordSet rs = new RecordSet();
		String sql = "select * from uf_gbjl where 1=1";
		if (planNo != null) {
			sql += "and zxjhh = " + planNo;
		}
		rs.executeSql(sql);
		return rs;
	}%>