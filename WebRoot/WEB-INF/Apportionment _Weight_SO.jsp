<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="weaver.general.StaticObj"%>
<%@page import="weaver.interfaces.datasource.DataSource"%>
<%@page import="java.sql.Connection"%>
<%@page import="weaver.general.Util"%>>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page import="com.sap.mw.jco.IFunctionTemplate"%>
<%@page import="weaver.general.BaseBean"%>
<%@page import="com.sap.mw.jco.JCO"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page
	import="com.weaver.integration.datesource.SAPInterationDateSourceImpl;"%>

<%
	BaseBean log = new BaseBean();
	JSONObject objectresult = new JSONObject();
	log.writeLog("调用CheckRecords_JGD开始");
	String zxjhh = request.getParameter("zxjhh");//装卸计划号
	String message=request.getParameter("message");//消息
	
	log.writeLog("获得数据装卸计划号:"+zxjhh);
	log.writeLog("获得消息数据："+message);
	try {
		if ("".equals(zxjhh)) {
			log.writeLog("装卸计划号为空");
			return;
		}
		String zgz = "";//总柜重量
		String bzclzzl = "";//包装材料总重量
		String gbzl = "";//过磅重量（总净重）
		double zhwjz = 0.00;//总货物净重
		String sfyg = "";//是否有柜
		String id = "";//主表id
		double jhlljz = 0.00;//计划理论净重
		double sjjz = 0.00;//实际净重
		String dtid = "";//明细表2的id
		double total = 0.00;//理论净重合计
		/*
		*总货物净重计算，计算公式
		*总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
		*/
		RecordSet rs = new RecordSet();
		RecordSet rs1 = new RecordSet();
		RecordSet dtrs = new RecordSet();

		String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "'";
		log.writeLog("查询主表Sql:" + sql);
		if (rs.execute(sql)) {
			if (rs.next()) {
				zgz = Util.null2String(rs.getString("zgz"));//总柜重量
				bzclzzl = Util.null2String(rs.getString("bzclzzl"));//包装材料总重量
				gbzl = Util.null2String(rs.getString("gbzl"));//过磅重量
				sfyg = Util.null2String(rs.getString("sfyg"));//是否有柜
				id = Util.null2String(rs.getString("id"));//主表id

				log.writeLog("zgz " + zgz);
				log.writeLog("bzclzzl " + bzclzzl);
				log.writeLog("gbzl " + gbzl);

			}
		} else {			
			log.writeLog("数据库查询错误");
		}
		if ("1".equals(sfyg)) {
			//有柜情况
			zhwjz = Double.parseDouble(gbzl) - Double.parseDouble(zgz) - Double.parseDouble(bzclzzl);//总货物净重
			log.writeLog("计算出的总货物净重:" + zhwjz);
			/*
			*每条明细计划理论净重，计算公式
			*（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
			*/
			if (zhwjz > 0) {
				String dtSql = "select * from formtable_main_45_dt2 where mainid = '" + id + "'";
				log.writeLog("查询明细表2sql:" + dtSql);
				dtrs.execute(dtSql);

				List<Map<String, String>> list = new ArrayList<Map<String, String>>();
				while (dtrs.next()) {
					Map<String, String> map = new HashMap<String, String>();
					String sl = dtrs.getString("sl");//数量
					String jhyzl = dtrs.getString("jhyzl");//计划运载量
					String jzl = dtrs.getString("jzl");//净重量
					dtid = dtrs.getString("id");//每条明细id

					log.writeLog("sl " + sl);
					log.writeLog("jhyzl " + jhyzl);
					log.writeLog("jzl " + jzl);

					jhlljz = (Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
					total += jhlljz;
					map.put("jhlljz", "" + jhlljz);
					map.put("dtid", dtid);
					list.add(map);
				}
				for (int i = 0; i < list.size(); i++) {
					/*
					*明细的实际分摊净重，计算公式
					*（计划理论净重/计划理论净重合计）*过磅总货物净重
					*/
					sjjz = (Double.parseDouble(list.get(i).get("jhlljz")) / total) * zhwjz;
					String updateSql = "update formtable_main_45_dt2 set sjftjz = '" + sjjz + "' where id = '"
							+ list.get(i).get("dtid") + "'";
					log.writeLog("更新明细sql: " + updateSql);
					rs1.executeSql(updateSql);
				}
			}
		} else if("0".equals(sfyg)){
			//无柜情况
			zhwjz = Double.parseDouble(gbzl) - Double.parseDouble(zgz) - Double.parseDouble(bzclzzl);//总货物净重
			log.writeLog("计算出的总货物净重:" + zhwjz);
			/*
			*每条明细计划理论净重，计算公式
			*（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
			*/
			if (zhwjz > 0) {
				String dtSql = "select * from formtable_main_45_dt3 where mainid = '" + id + "'";
				log.writeLog("查询明细表3sql:" + dtSql);
				dtrs.execute(dtSql);

				List<Map<String, String>> list = new ArrayList<Map<String, String>>();
				while (dtrs.next()) {
					Map<String, String> map = new HashMap<String, String>();
					String sl = dtrs.getString("sl");//数量
					String jhyzl = dtrs.getString("jhyzl");//计划运载量
					String jzl = dtrs.getString("jzl");//净重量
					dtid = dtrs.getString("id");//每条明细id

					log.writeLog("sl " + sl);
					log.writeLog("jhyzl " + jhyzl);
					log.writeLog("jzl " + jzl);

					jhlljz = (Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
					total += jhlljz;
					map.put("jhlljz", "" + jhlljz);
					map.put("dtid", dtid);
					list.add(map);
				}
				for (int i = 0; i < list.size(); i++) {
					/*
					*明细的实际分摊净重，计算公式
					*（计划理论净重/计划理论净重合计）*过磅总货物净重
					*/
					sjjz = (Double.parseDouble(list.get(i).get("jhlljz")) / total) * zhwjz;
					String updateSql = "update formtable_main_45_dt3 set sjftjz = '" + sjjz + "' where id = '"
							+ list.get(i).get("dtid") + "'";
					log.writeLog("更新明细sql: " + updateSql);
					rs1.executeSql(updateSql);
				}
				
				
			}
			
		}
		message+="运费计算完成";
		
		
	} catch (Exception e) {
		// TODO: handle exception
		///out.write("fail" + e);
		message+="运费计算失败："+e;
		log.writeLog(e);
		e.printStackTrace();

	}
	objectresult=addJson(message, "", "", "");
	log.writeLog(objectresult.toString());
	out.write(objectresult.toString());

%>

<%!public JSONObject addJson(String message, String newcp, String trdStatus, String ptStatus) {
		JSONObject jsonobj = new JSONObject();
		jsonobj.put("message", message);
		jsonobj.put("cp", newcp);
		jsonobj.put("trdStatus", trdStatus);
		jsonobj.put("ptStatus", ptStatus);
		return jsonobj;
	}%>


