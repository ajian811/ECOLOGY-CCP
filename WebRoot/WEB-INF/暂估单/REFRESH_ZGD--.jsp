<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="weaver.general.Util"%>
<%@ page import="weaver.interfaces.workflow.action.CCPService.ZGDService" %>
<%@ page import="weaver.interfaces.workflow.action.CCPServiceImpl.ZGDServiceImpl"
%>
<%
	ZGDService zgdService=new ZGDServiceImpl();
	String billids = request.getParameter("billids");
	String config_wf = "CCP_ZGD";// 暂估单
	JSONArray jsonArr = new JSONArray();
	JSONObject objectresult = new JSONObject();
	String djstatus = "";//单据状态
	String lgbh = "";//理柜编号
	String zxplanno = "";//装卸计划号
	String djlx = "";//单据类型
	String tablename = "";
	String djbh = "";//暂估单据编号
	String djtitle = "";//费用名称
	String lx = "";//类型
	String isNull="";//SO装卸计划更新建模表，requestid is null

	try {
		RecordSet rs = new RecordSet();
		RecordSet rs1 = new RecordSet();
		RecordSet rs2 = new RecordSet();
		RecordSet rs3 = new RecordSet();
		String[] billid = billids.split(",");
		rs.writeLog("进入REFRESH_ZGD.jsp");
		Date d = new Date();
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String currdate = format.format(d);
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (int i = 0; i < billid.length; i++) {
			String sql = "select * from uf_zgfy " + " where id= '" + billid[i] + "'";
			rs.writeLog("查询的sql:" + sql);
			rs.execute(sql);
			while (rs.next()) {
				Map<String, String> map = new HashMap<String, String>();
				//更新sql
				djstatus = Util.null2String(rs.getString("djstatus"));//单据状态  0和4可以重算
				lgbh = Util.null2String(rs.getString("lgbh"));//理柜编号
				zxplanno = Util.null2String(rs.getString("zxplanno"));//装卸计划号
				djlx = Util.null2String(rs.getString("djlx"));//单据类型
				djbh = Util.null2String(rs.getString("djbh"));//单据编号
				djtitle = Util.null2String(rs.getString("djtitle"));//费用名称

				if ("1".equals(djlx)) {//po
					tablename = "formtable_main_61";
					lx = "0";
				} else if ("0".equals(djlx) && "".equals(lgbh)) {//so
					tablename = "formtable_main_45";
					isNull=" and requestid is null";
					lx = "0";
				} else if ("0".equals(djlx) && !"".equals(lgbh)) {
					lx = "1";
				}
				map.put("billid", billid[i]);
				map.put("lx", lx);
				map.put("djtitle", djtitle);
				map.put("djbh", djbh);
				map.put("djstatus", djstatus);
				map.put("lgbh", lgbh);
				map.put("zxplanno", zxplanno);
				map.put("djlx", djlx);
				map.put("tablename", tablename);
				list.add(map);
			}
		}

		for (int i = 0; i < list.size(); i++) {
			Map m1 = list.get(i);

			for (int j = i + 1; j < list.size(); j++) {
				Map m2 = list.get(j);
				if (m1.get("lgbh").equals(m2.get("lgbh")) && "1".equals(m1.get("lx"))
						&& "1".equals(m2.get("lx"))) {
					list.remove(j);
					continue;
				}
			}
		}
		// 打印log
		rs.writeLog("遍历明细");
		for (Map<String, String> m : list) {
			rs.writeLog("--------------");
			for (String k : m.keySet()) {
				rs.writeLog(k + " = " + m.get(k));
			}
		}

		String cysjm = "";//承运商简码
		String cx = "";//车型
		String jflx = "";//计费类型
		String xllx = "0";//线路类型
		String yslx = "";//运输类型
		String xlxz = "";//线路选择
		String sjysrq = "";//实际运输日期
		String jgd = "";//价格档
		String id = "";//数据Id

		if (list.size() > 0) {
			for (int i = 0; i < list.size(); i++) {
				JSONObject object = new JSONObject();
				String sql = "";
				tablename = list.get(i).get("tablename");
				lgbh = list.get(i).get("lgbh");
				zxplanno = list.get(i).get("zxplanno");
				djstatus = list.get(i).get("djstatus");
				djtitle = list.get(i).get("djtitle");
				djbh = list.get(i).get("djbh");
				djlx = list.get(i).get("djlx");
				id = list.get(i).get("billid");
				lx = list.get(i).get("lx");//1为理货
				if ("0".equals(djstatus) || "4".equals(djstatus)) {
					if ("".equals(lgbh)) {
							if ("0".equals(lx)) {
								String jgdid=zgdService.getJgdId(zxplanno,tablename);
								String newSql="select price from uf_yfjgwhd where id ="+jgdid;
								rs1.writeLog(newSql);
								if (rs1.execute(newSql)) {
									if (rs1.next()) {
										jgd = Util.null2String(rs1.getString("price"));
										String updateSql = "update " + tablename + " set jgd = '" + jgd
												+ "' where zxjhh = '" + zxplanno + "'"+isNull;
										rs2.writeLog(updateSql);
										if (rs2.execute(updateSql)) {
											object.put("cysjm", cysjm);
											object.put("djbh", djbh);
											object.put("djtitle", djtitle);
											object.put("lgbh", lgbh);
											object.put("zxplanno", zxplanno);
											object.put("djstatus", djstatus);
											object.put("type", "1");
											object.put("msg", "更新价格档成功");
											jsonArr.add(object);
											zgdService.calZGDFreight(zxplanno,tablename,jgdid);
											//分摊运费
											//calFreightService.calAllocateFrieght(zxplanno,djlx);
											zgdService.calZGDAllocateFrieght(zxplanno,djlx);
											String changeSql = "update uf_zgfy set djstatus = '5' where id = '"
													+ id + "'";
											rs3.execute(changeSql);
										} else {
											object.put("cysjm", cysjm);
											object.put("djbh", djbh);
											object.put("djtitle", djtitle);
											object.put("lgbh", lgbh);
											object.put("zxplanno", zxplanno);
											object.put("djstatus", djstatus);
											object.put("type", "0");
											object.put("msg", "更新失败");
											jsonArr.add(object);
										}
									} else {
										object.put("cysjm", cysjm);
										object.put("djbh", djbh);
										object.put("djtitle", djtitle);
										object.put("lgbh", lgbh);
										object.put("zxplanno", zxplanno);
										object.put("djstatus", djstatus);
										object.put("type", "0");
										object.put("msg", "没有获取到价格档");
										jsonArr.add(object);
									}
								}
							}else{
								object.put("cysjm", cysjm);
								object.put("djbh", djbh);
								object.put("djtitle", djtitle);
								object.put("lgbh", lgbh);
								object.put("zxplanno", zxplanno);
								object.put("djstatus", djstatus);
								object.put("type", "0");
								object.put("msg", "理货申请无需费用重算");
								jsonArr.add(object);
							}
						} else {
							object.put("cysjm", cysjm);
							object.put("djbh", djbh);
							object.put("djtitle", djtitle);
							object.put("lgbh", lgbh);
							object.put("zxplanno", zxplanno);
							object.put("djstatus", djstatus);
							object.put("type", "0");
							object.put("msg", "没有在查询到该流程，无法进行费用重算");
							jsonArr.add(object);
						}

				} else {
					object.put("cysjm", cysjm);
					object.put("djbh", djbh);
					object.put("djtitle", djtitle);
					object.put("lgbh", lgbh);
					object.put("zxplanno", zxplanno);
					object.put("djstatus", djstatus);
					object.put("type", "0");
					object.put("msg", "暂估单已经上抛或者已经重算过，不能进行费用重算");
					jsonArr.add(object);
				}

			}
		}
		String modeid = "881";
		for (int i = 0; i < jsonArr.size(); i++) {
			String bh = System.currentTimeMillis() + "";
			JSONObject job = jsonArr.getJSONObject(i);
			StringBuffer buffer = new StringBuffer();
			buffer.append(
					"Insert into uf_zgfylog (ry,ysrq,yssj,zxjh,fymc,gysjm,yzgdh,sfyg,csjg,sbyy,bh,FORMMODEID,MODEDATACREATER) values (");
			buffer.append("'").append("1").append("',");// 人员
			buffer.append("'").append(currdate.substring(0, 10)).append("',");// 运算日期
			buffer.append("'").append(currdate.substring(11, 16)).append("',");// 运算时间
			buffer.append("'").append(job.get("zxplanno") == ""?job.get("lgbh"):job.get("zxplanno")).append("',");// 装卸计划号
			buffer.append("'").append(job.get("djtitle")).append("',");// 费用名称
			buffer.append("'").append(job.get("cysjm")).append("',");// 供应商简码
			buffer.append("'").append(job.get("djbh")).append("',");// 原暂估单号
			buffer.append("'").append("1").append("',");// 是否有运费
			buffer.append("'").append(job.get("type")).append("',");// 重算结果
			buffer.append("'").append(job.get("msg")).append("',");// 失败原因
			buffer.append("'").append(bh).append("',");// 编号
			buffer.append("'").append("881").append("',");
			buffer.append("'").append("1").append("')");

			rs.writeLog("插入建模表的sql:" + buffer.toString());
			rs.executeSql(buffer.toString());

			StringBuffer sb = new StringBuffer();// 插入权限表
			sb.append("insert into MODEDATASHARE_881");
			sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
			sb.append("(").append("(select id from uf_zgfylog where bh = '" + bh + "')").append(",");
			sb.append("'").append("1").append("',");
			sb.append("'").append("1").append("',");
			sb.append("'").append("0").append("',");
			sb.append("'").append("3").append("')");
			rs1.writeLog("插入权限执行的sql:" + sb.toString());
			rs1.executeSql(sb.toString());// 先插入主表			
		}
		objectresult.put("result", jsonArr);

	} catch (Exception e) {
		// TODO: handle exception
		out.write("fail" + e);
		e.printStackTrace();

	}
	response.getWriter().write(objectresult.toString());
	//System.out.println(jo.toString());
	response.getWriter().flush();
	response.getWriter().close();
%>


