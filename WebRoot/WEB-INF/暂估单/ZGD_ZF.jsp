<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@page import="com.weaver.general.BaseBean"%>
<%@page import="weaver.general.Util"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="com.sap.mw.jco.*"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page
	import="com.weaver.integration.datesource.SAPInterationDateSourceImpl"%>
<%
	String BELNR = request.getParameter("BELNR");//SAP凭证编号
	String BUKRS = request.getParameter("BUKRS");//公司代码
	String GJAHR = request.getParameter("GJAHR");//会计年度
	String djbh=request.getParameter("djbh");//
	BaseBean bs = new BaseBean();
	String sql="";
	
	
	try{
		
		if(BELNR.equals("")||BELNR==null){
			RecordSet rs=new RecordSet();
			sql="update uf_zgfy set djstatus='4' where djbh='"+djbh+"'";
			bs.writeLog(sql);
			rs.execute(sql);
			out.write("success");
			return;
		}
	
	JCO.Client sapconnection = null;
	SAPInterationDateSourceImpl sapidsi = new SAPInterationDateSourceImpl();
	sapconnection = (JCO.Client) sapidsi.getConnection("1", new LogInfo());
	bs.writeLog("创建SAP连接");
	String strFunc = "ZOA_FI_DOC_REV";

	JCO.Repository myRepository = new JCO.Repository("Repository", sapconnection);
	IFunctionTemplate ft = myRepository.getFunctionTemplate(strFunc.toUpperCase());
	JCO.Function function = ft.getFunction();
	bs.writeLog("SAP已连接，开始设定值...");
	function.getImportParameterList().setValue(BELNR, "BELNR");
	function.getImportParameterList().setValue(BUKRS, "BUKRS");
	function.getImportParameterList().setValue(GJAHR, "GJAHR");
	
	sapconnection.execute(function);
	bs.writeLog("获取返回参数>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	String FLAG=function.getExportParameterList().getValue("FLAG").toString();	//单一字符标识
	bs.writeLog("FLAG:"+FLAG);
	String ERR_MSG=function.getExportParameterList().getValue("ERR_MSG").toString();	//消息文本
	bs.writeLog("ERR_MSG:"+ERR_MSG);
	String STBLG=function.getExportParameterList().getValue("STBLG").toString();	//冲销凭证号
	bs.writeLog("STBLG:"+STBLG);
	bs.writeLog("获取返回参数结束<<<<<<<<<<<<<<<<<<<<<<<<<<");
	sapidsi.releaseC(sapconnection);
	JSONObject jsonObject=new JSONObject();
	jsonObject.put("FLAG", FLAG);
	jsonObject.put("ERR_MSG", ERR_MSG);
	jsonObject.put("STBLG", FLAG);
	out.write(jsonObject.toString());
	}catch(Exception e){
		bs.writeLog("报错了："+e);
		JSONObject jsonObject=new JSONObject();
		jsonObject.put("err", e+"");
		out.write(jsonObject.toString());
		
	}
	
	
	
%>