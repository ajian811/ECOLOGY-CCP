<%@page import="weaver.general.Util"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Map"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="weaver.general.BaseBean"%>
<%@page import="com.sap.mw.jco.IFunctionTemplate"%>
<%@page import="com.sap.mw.jco.JCO"%>
<%@page import="weaver.interfaces.datasource.DataSource"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page
	import="com.weaver.integration.datesource.SAPInterationDateSourceImpl"%>

<%
	RecordSet rs = new RecordSet();
	BaseBean log = new BaseBean();
	log.writeLog("进入QZ_UP_SAP.jsp");
	JCO.Client sapconnection = null;
	JSONObject jsonResult = new JSONObject();
	JSONArray jsonArr = new JSONArray();
	try {
		Date d = new Date();
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		String currdate = format.format(d);
		
		String DOC_DATE = Util.null2String(request.getParameter("DOC_DATE")).replaceAll("-", "");//凭证日期
		String PSTNG_DATE = currdate;//记账日期 当前日期
		String DOC_TYPE = Util.null2String(request.getParameter("DOC_TYPE"));//凭证类型
		String COMP_CODE = Util.null2String(request.getParameter("COMP_CODE"));//公司代码		
		String CURRENCY = Util.null2String(request.getParameter("CURRENCY"));//货币代码
		String EXCHNG_RATE = Util.null2String(request.getParameter("EXCHNG_RATE"));//汇率
		//String NOTESID = Util.null2String(request.getParameter("NOTESID"));//NOTESID
		String NOTESID = System.currentTimeMillis() + "";

		String REF_DOC_NO = Util.null2String(request.getParameter("REF_DOC_NO"));//参考凭证号
		String HEADER_TXT = Util.null2String(request.getParameter("HEADER_TXT"));//凭证抬头文本		
		String PSTNG_PERIOD = currdate.substring(4, 6);//记账期间
		String USER_NAME = Util.null2String(request.getParameter("USER_NAME"));//用户名			
		String RUN_MODE = "N";//调试模式	默认N		调试模式A

		String lists1 = request.getParameter("list1");
		String lists2 = request.getParameter("list2");
		JSONArray json1 = JSONArray.fromObject(lists1);
		JSONArray json2 = JSONArray.fromObject(lists2);

		List<Map<String, String>> list1 = new ArrayList<Map<String, String>>();
		for (int i = 0; i < json1.size(); i++) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("VC_FLAG", Util.null2String((String) json1.getJSONObject(i).get("VC_FLAG")));//供应商客户标识
			map.put("VC_NO", Util.null2String((String) json1.getJSONObject(i).get("VC_NO")));//供应商或客户编号
			map.put("SGL_FLAG", Util.null2String((String) json1.getJSONObject(i).get("SGL_FLAG")));//特殊总账标识
			map.put("DOC_NO", Util.null2String((String) json1.getJSONObject(i).get("DOC_NO")));//需清帐凭证编号
			map.put("DOC_YEAR", Util.null2String((String) json1.getJSONObject(i).get("DOC_YEAR")));//会计年度
			map.put("DOC_ITEM", Util.null2String((String) json1.getJSONObject(i).get("DOC_ITEM")));//行项目号
			map.put("CL_MONEY", Util.null2String((String) json1.getJSONObject(i).get("CL_MONEY")));//清帐金额
			map.put("CL_TEXT", Util.null2String((String) json1.getJSONObject(i).get("CL_TEXT")));//清帐文本
			list1.add(map);
		}

		List<Map<String, String>> list2 = new ArrayList<Map<String, String>>();
		for (int i = 0; i < json2.size(); i++) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("PSTNG_CODE", Util.null2String((String) json2.getJSONObject(i).get("PSTNG_CODE")));//记账码
			map.put("GL_ACCOUNT", Util.null2String((String) json2.getJSONObject(i).get("GL_ACCOUNT")));//总账科目
			map.put("MONEY", Util.null2String((String) json2.getJSONObject(i).get("MONEY")));//金额
			map.put("TAX_CODE", Util.null2String((String) json2.getJSONObject(i).get("TAX_CODE")));//税码
			map.put("COST_CENTER", Util.null2String((String) json2.getJSONObject(i).get("COST_CENTER")));//成本中心
			map.put("NO", Util.null2String((String) json2.getJSONObject(i).get("NO")));//订单号 
			map.put("ITEM", Util.null2String((String) json2.getJSONObject(i).get("ITEM")));//订单项次
			map.put("ITEM_TEXT", Util.null2String((String) json2.getJSONObject(i).get("ITEM_TEXT")));//行项目文本

			map.put("BANK_TYPE", Util.null2String((String) json2.getJSONObject(i).get("BANK_TYPE")));//合作银行类型
			map.put("PAY_LOCK", Util.null2String((String) json2.getJSONObject(i).get("PAY_LOCK")));//冻结付款
			map.put("PAY_TERMS", Util.null2String((String) json2.getJSONObject(i).get("PAY_TERMS")));//付款条款
			map.put("PAY_WAY", Util.null2String((String) json2.getJSONObject(i).get("PAY_WAY")));//付款方式
			map.put("PAY_DATE", Util.null2String((String) json2.getJSONObject(i).get("PAY_DATE")).replaceAll("-", ""));//到期日
			map.put("PAY_CUR", Util.null2String((String) json2.getJSONObject(i).get("PAY_CUR")));//支付货币 
			map.put("PAY_MONEY", Util.null2String((String) json2.getJSONObject(i).get("CL_MONEY")));//支付金额
			map.put("MATERIAL", Util.null2String((String) json2.getJSONObject(i).get("MATERIAL")));//物理号
			list2.add(map);
		}

		String sources = "1";
		SAPInterationDateSourceImpl sapidsi = new SAPInterationDateSourceImpl();
		sapconnection = (JCO.Client) sapidsi.getConnection(sources, new LogInfo());
		log.writeLog("创建SAP连接");
		String strFunc = "ZOA_FI_CDOC_CREATE";
		JCO.Function function = null;
		JCO.Repository myRepository = new JCO.Repository("Repository", sapconnection);
		IFunctionTemplate ft = myRepository.getFunctionTemplate(strFunc.toUpperCase());
		function = ft.getFunction();

		if (function == null) {
			log.writeLog("链接SAP失败");
			return;
		}
		
		log.writeLog("打印主表log");

		function.getImportParameterList().setValue(COMP_CODE, "COMP_CODE");//公司代码		
		log.writeLog("COMP_CODE=" + COMP_CODE);
		function.getImportParameterList().setValue(PSTNG_DATE, "PSTNG_DATE");//记账日期
		log.writeLog("PSTNG_DATE=" + PSTNG_DATE);
		function.getImportParameterList().setValue(DOC_TYPE, "DOC_TYPE");//凭证类型
		log.writeLog("DOC_TYPE=" + DOC_TYPE);
		function.getImportParameterList().setValue(DOC_DATE, "DOC_DATE");//凭证日期
		log.writeLog("DOC_DATE=" + DOC_DATE);
		function.getImportParameterList().setValue(CURRENCY, "CURRENCY");//货币代码
		log.writeLog("CURRENCY=" + CURRENCY);
		function.getImportParameterList().setValue(EXCHNG_RATE, "EXCHNG_RATE");//汇率
		log.writeLog("EXCHNG_RATE=" + EXCHNG_RATE);
		function.getImportParameterList().setValue(REF_DOC_NO, "REF_DOC_NO");//参考凭证号		
		log.writeLog("REF_DOC_NO=" + REF_DOC_NO);
		function.getImportParameterList().setValue(HEADER_TXT, "HEADER_TXT");//凭证抬头文本
		log.writeLog("HEADER_TXT=" + HEADER_TXT);
		function.getImportParameterList().setValue(PSTNG_PERIOD, "PSTNG_PERIOD");//记账期间
		log.writeLog("PSTNG_PERIOD=" + PSTNG_PERIOD);
		function.getImportParameterList().setValue(USER_NAME, "USER_NAME");//用户名
		log.writeLog("USER_NAME=" + USER_NAME);
		function.getImportParameterList().setValue(RUN_MODE, "RUN_MODE");//调试模式
		log.writeLog("RUN_MODE=" + RUN_MODE);
		function.getImportParameterList().setValue(NOTESID, "NOTESID");//NOTESID\
		log.writeLog("NOTESID=" + NOTESID);

		log.writeLog("参数表1打印log");
		for (Map<String, String> m : list1) {
			for (String k : m.keySet()) {
				log.writeLog(k + " = " + m.get(k));
			}
		}
		JCO.Table inTableParams1 = function.getTableParameterList().getTable("FI_DOC_CLEAR");
		for (int i = 0; i < list1.size(); i++) {

			inTableParams1.appendRow();
			inTableParams1.setValue(list1.get(i).get("VC_FLAG"), "VC_FLAG");//供应商客户标识
			inTableParams1.setValue(list1.get(i).get("VC_NO"), "VC_NO");//供应商或客户编号
			inTableParams1.setValue(list1.get(i).get("SGL_FLAG"), "SGL_FLAG");//特殊总账标识
			inTableParams1.setValue(list1.get(i).get("DOC_NO"), "DOC_NO");//需清帐凭证编号

			inTableParams1.setValue(list1.get(i).get("DOC_YEAR"), "DOC_YEAR");//会计年度
			inTableParams1.setValue(list1.get(i).get("DOC_ITEM"), "DOC_ITEM");//行项目号
			inTableParams1.setValue(list1.get(i).get("CL_MONEY"), "CL_MONEY");//清帐金额
			inTableParams1.setValue(list1.get(i).get("CL_TEXT"), "CL_TEXT");//清障文本
		}

// 		log.writeLog("参数表2打印log");
// 		for (Map<String, String> m : list2) {
// 			for (String k : m.keySet()) {
// 				rs.writeLog(k + " = " + m.get(k));
// 			}
// 		}
		JCO.Table inTableParams2 = function.getTableParameterList().getTable("FI_DOC_ITEMS");
		for (int i = 0; i < list2.size(); i++) {
			log.writeLog("参数表2打印log");
			inTableParams2.appendRow();
			inTableParams2.setValue(list2.get(i).get("PSTNG_CODE"), "PSTNG_CODE");//记账码
			log.writeLog("PSTNG_CODE="+list2.get(i).get("PSTNG_CODE"));
			inTableParams2.setValue(list2.get(i).get("GL_ACCOUNT"), "GL_ACCOUNT");//总账科目
			log.writeLog("GL_ACCOUNT="+list2.get(i).get("GL_ACCOUNT"));
			inTableParams2.setValue(list2.get(i).get("MONEY"), "MONEY");//金额
			log.writeLog("MONEY="+list2.get(i).get("MONEY"));
			inTableParams2.setValue(list2.get(i).get("TAX_CODE"), "TAX_CODE");//税码		
			log.writeLog("TAX_CODE="+list2.get(i).get("TAX_CODE"));
			inTableParams2.setValue(list2.get(i).get("COST_CENTER"), "COST_CENTER");//成本中心
			log.writeLog("COST_CENTER="+list2.get(i).get("COST_CENTER"));
			inTableParams2.setValue(list2.get(i).get("NO"), "PO_NO");//订单号  
			log.writeLog("PO_NO="+list2.get(i).get("NO"));
			inTableParams2.setValue(list2.get(i).get("ITEM"), "PO_ITEM");//订单项次
			log.writeLog("PO_ITEM="+list2.get(i).get("ITEM"));
			inTableParams2.setValue(list2.get(i).get("ITEM_TEXT"), "ITEM_TEXT");//行项目文本		
			log.writeLog("ITEM_TEXT="+list2.get(i).get("ITEM_TEXT"));
			inTableParams2.setValue(list2.get(i).get("BANK_TYPE"), "BANK_TYPE");//合作银行类型
			log.writeLog("BANK_TYPE="+list2.get(i).get("BANK_TYPE"));
			inTableParams2.setValue(list2.get(i).get("PAY_LOCK"), "PAY_LOCK");//冻结付款
			log.writeLog("PAY_LOCK="+list2.get(i).get("PAY_LOCK"));
			inTableParams2.setValue(list2.get(i).get("PAY_TERMS"), "PAY_TERMS");//付款条款   
			log.writeLog("PAY_TERMS="+list2.get(i).get("PAY_TERMS"));
			inTableParams2.setValue(list2.get(i).get("PAY_WAY"), "PAY_WAY");//付款方式		
			log.writeLog("PAY_WAY="+list2.get(i).get("PAY_WAY"));
			inTableParams2.setValue(list2.get(i).get("PAY_DATE"), "PAY_DATE");//到期日
			log.writeLog("PAY_DATE="+list2.get(i).get("PAY_DATE"));
			inTableParams2.setValue(list2.get(i).get("PAY_CUR"), "PAY_CUR");//支付货币
			log.writeLog("PAY_CUR="+list2.get(i).get("PAY_CUR"));
			inTableParams2.setValue(list2.get(i).get("PAY_MONEY"), "PAY_MONEY");//支付金额
			log.writeLog("PAY_MONEY="+list2.get(i).get("PAY_MONEY"));
			inTableParams2.setValue(list2.get(i).get("MATERIAL"), "MATERIAL");//物理号
			log.writeLog("MATERIAL="+list2.get(i).get("MATERIAL"));
		}
		
		log.writeLog("执行function上传sap数据");
		sapconnection.execute(function);
		

		String FLAG = function.getExportParameterList().getValue("FLAG").toString();
		String ERR_MSG = function.getExportParameterList().getValue("ERR_MSG").toString();
		String AC_DOC_NO = function.getExportParameterList().getValue("AC_DOC_NO").toString();
		// 获取数据
		log.writeLog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		log.writeLog("FLAG: " + FLAG);
		log.writeLog("ERR_MSG: " + ERR_MSG);
		log.writeLog("AC_DOC_NO: " + AC_DOC_NO);
		log.writeLog("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
		jsonResult.put("FLAG", FLAG);
		jsonResult.put("ERR_MSG", ERR_MSG);
		jsonResult.put("AC_DOC_NO", AC_DOC_NO);
	} catch (Exception e) {
		// TODO: handle exception
		jsonResult.put("flag", "E");
		out.write("fail" + e);
		e.printStackTrace();
	}

	response.getWriter().write(jsonResult.toString());
	response.getWriter().flush();
	response.getWriter().close();
%>