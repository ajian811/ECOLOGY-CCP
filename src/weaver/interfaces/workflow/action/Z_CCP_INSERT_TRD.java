package weaver.interfaces.workflow.action;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.sap.mw.jco.JCO;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CCP_INSERT_TRD extends BaseBean implements Action {
	// shipping柜号输入接口
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_INSERT_TRD开始");
		JCO.Client sapconnection = null;
		try {
			ResourceComInfo resourceComInfo = new ResourceComInfo();
			// 获取输入参数
			WorkflowComInfo workflowComInfo = new WorkflowComInfo();
			int requestid = Util.getIntValue(request.getRequestid());
			// 得到流程id
			String workflowId = request.getWorkflowid();
			int formid = Util.getIntValue(workflowComInfo.getFormId("" + workflowId), 0);
			int isbill = Util.getIntValue(workflowComInfo.getIsBill("" + workflowId), 0);
			String tablename = "";
			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet rs2 = new RecordSet();
			RecordSet rs3 = new RecordSet();
			int userid = request.getRequestManager().getUser().getUID();
			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}

			Date d = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
			String currdate1 = format.format(d);
			// 主表
			String dycs = "";// 打印次数
			String zxjhh = "";// 装卸计划号
			String lcid = "";// 流程id
			String lcbh = "";// 流程编号
			String yjyssj = "";// 预计运输时间
			String sfdy = "";// 是否打印
			String sfyg = "";// 是否有柜
			String yjysrq = "";// 运行运输日期
			String trdh = "";// 提入单号
			String carno = "";// 车牌
			String sfzf = "";// 是否作废
			// 明细表
			String cp = "";// 产品
			String shipping = "";// shipping编码
			String sl = "";// 数量
			String gbm = "";// 柜编码

			String pono = "";// 采购订单号
			String poitem = "";// 采购订单项次
			String wlh = "";// 物料号码
			String wlname = "";// 物料描述
			List<Map<String, String>> list = new ArrayList<Map<String, String>>();

			String selectsql = "select * from " + tablename + " where requestid = '" + requestid + "'";
			log.writeLog("查询流程表单的sql:" + selectsql);
			rs.execute(selectsql);
			if (rs.next()) {
				sfyg = Util.null2String(rs.getString("sfyg"));// 是否有柜

				zxjhh = Util.null2String(rs.getString("zxjhh"));// 装卸计划号
				lcbh = Util.null2String(rs.getString("lcbh"));// 流程编号
				yjysrq = Util.null2String(rs.getString("yjysrq"));// 运行运输日期
				yjyssj = Util.null2String(rs.getString("yjyssj"));// 预计运输时间
				carno = Util.null2String(rs.getString("cp"));// 车牌
				sfzf = Util.null2String(rs.getString("sfzf"));// 是否作废
				log.writeLog("是否有柜:" + sfyg);
				if (!"1".equals(sfzf)) {
					if ("0".equals(sfyg)) {
						String sql = "select t2.TRDH from " + tablename + " t1 ";
						sql += " left join " + tablename + "_dt3 t2 on t1.id = t2.mainid";
						sql += " where t1.requestid= '" + requestid + "'";
						sql += " group by t2.TRDH";
						log.writeLog("查询明细3的sql:" + sql);
						rs2.execute(sql);
						while (rs2.next()) {
							trdh = rs2.getString("trdh");
							StringBuffer buffer = new StringBuffer();

							buffer.append("insert into UF_TRDPLDY");
							buffer.append(
									"(TRDH,ZXJHH,LCID,LCBH,DYCS,SFDY,SFYG,YJYSRQ,YJYSSJ,FORMMODEID,LX,cp,sfzf,MODEDATACREATER) values");
							buffer.append("('").append(trdh).append("',");
							buffer.append("'").append(zxjhh).append("',");
							buffer.append("'").append(requestid).append("',");
							buffer.append("'").append(lcbh).append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(sfyg).append("',");
							buffer.append("'").append(yjysrq).append("',");
							buffer.append("'").append(yjyssj).append("',");
							buffer.append("'").append("381").append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(carno).append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(userid).append("')");
							log.writeLog("插入建模主表执行的sql :" + buffer.toString());
							rs1.executeSql(buffer.toString());// 先插入主表

							StringBuffer sb = new StringBuffer();// 插入权限表
							sb.append("insert into MODEDATASHARE_381");
							sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
							sb.append("(").append("(select id from uf_trdpldy where trdh = '" + trdh + "')")
									.append(",");
							sb.append("'").append("1").append("',");
							sb.append("'").append("1").append("',");
							sb.append("'").append("0").append("',");
							sb.append("'").append("3").append("')");
							log.writeLog("插入权限执行的sql:" + sb.toString());
							rs1.executeSql(sb.toString());// 先插入主表

							String dt3Sql = "select * from " + tablename + "_dt3 where trdh = '" + trdh + "'";
							rs.execute(dt3Sql);
							while (rs.next()) {
								// 明细数据
								cp = Util.null2String(rs.getString("cp"));// 产品
								sl = Util.null2String(rs.getString("jhyzl"));// 数量
								// trdh =
								// Util.null2String(rs.getString("trdh"));//
								// 提入单号
								shipping = Util.null2String(rs.getString("shipno"));// shipping编码

								pono = Util.null2String(rs.getString("jydh"));// 交运单号
								poitem = Util.null2String(rs.getString("xc"));// 订单项次
								wlh = Util.null2String(rs.getString("wlh"));// 物料号码
								wlname = Util.null2String(rs.getString("wlname"));// 物料描述

								String insertSql = "insert into uf_trdpldy_dt1(mainid,cp,shipping,jydh,ddxc,wlhm,wlms,sl) values ";
								insertSql += "((select id from uf_trdpldy where trdh = '" + trdh + "'),";
								insertSql += "'" + cp + "',";
								insertSql += "'" + shipping + "',";
								insertSql += "'" + pono + "',";
								insertSql += "'" + poitem + "',";
								insertSql += "'" + wlh + "',";
								insertSql += "'" + wlname + "',";
								insertSql += "'" + sl + "')";
								log.writeLog("插入建模明细执行的sql :" + insertSql);
								rs3.executeSql(insertSql);// 后插入明细
							}
						}
					} else {
						String selectSql = " select t2.jydh as d2jydh,t2.ddxc as d2ddxc,t2.wlhm as d2wlhm,t2.wlms as d2wlms,t2.cp as d2cp,t2.trdh as d2trdh,t2.jhyzl as d2jhyzl,t2.gbm as d2gbm,t1.* from "
								+ tablename + " t1";
						selectSql += " left join " + tablename + "_dt2  t2 on t1.id = t2.mainid";
						selectSql += " where t1.requestid= " + requestid;
						log.writeLog("查询流程表单的sql:" + selectSql);
						rs1.execute(selectSql);

						while (rs1.next()) {
							// dt2,一个提入单号多个产品
							Map<String, String> map = new HashMap<String, String>();

							cp = Util.null2String(rs1.getString("d2cp"));// 产品
							sl = Util.null2String(rs1.getString("d2jhyzl"));// 数量
							trdh = Util.null2String(rs1.getString("d2trdh"));// 提入单号
							gbm = Util.null2String(rs1.getString("d2gbm"));// 柜编码

							pono = Util.null2String(rs1.getString("jydh"));// 交运单号
							poitem = Util.null2String(rs1.getString("xc"));// 订单项次
							wlh = Util.null2String(rs1.getString("wlh"));// 物料号码
							wlname = Util.null2String(rs1.getString("wlname"));// 物料描述

							map.put("cp", cp);
							map.put("sl", sl);
							map.put("gbm", gbm);
							map.put("pono", pono);
							map.put("poitem", poitem);
							map.put("wlh", wlh);
							map.put("wlname", wlname);
							list.add(map);
						}
					}
				}
			}
			if (!"1".equals(sfzf)) {
				if ("1".equals(sfyg)) {
					StringBuffer buffer = new StringBuffer();
					buffer.append("insert into UF_TRDPLDY");
					buffer.append(
							"(TRDH,ZXJHH,LCID,LCBH,DYCS,SFDY,SFYG,YJYSRQ,YJYSSJ,FORMMODEID,LX,cp,sfzf,MODEDATACREATER) values");
					buffer.append("('").append(trdh).append("',");
					buffer.append("'").append(zxjhh).append("',");
					buffer.append("'").append(requestid).append("',");
					buffer.append("'").append(lcbh).append("',");
					buffer.append("'").append("0").append("',");
					buffer.append("'").append("0").append("',");
					buffer.append("'").append(sfyg).append("',");
					buffer.append("'").append(yjysrq).append("',");
					buffer.append("'").append(yjyssj).append("',");
					buffer.append("'").append("381").append("',");
					buffer.append("'").append("0").append("',");
					buffer.append("'").append(carno).append("',");
					buffer.append("'").append("0").append("',");
					buffer.append("'").append(userid).append("')");
					log.writeLog("插入建模主表执行的sql :" + buffer.toString());
					rs1.executeSql(buffer.toString());// 先插入主表

					StringBuffer sb = new StringBuffer();// 插入权限表
					sb.append("insert into MODEDATASHARE_381");
					sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
					sb.append("(").append("(select id from uf_trdpldy where trdh = '" + trdh + "')").append(",");
					sb.append("'").append("1").append("',");
					sb.append("'").append("1").append("',");
					sb.append("'").append("0").append("',");
					sb.append("'").append("3").append("')");
					log.writeLog("插入权限执行的sql:" + sb.toString());
					rs1.executeSql(sb.toString());// 先插入主表

					for (int i = 0; i < list.size(); i++) {
						String insertSql = "insert into uf_trdpldy_dt1(mainid,cp,gbm,jydh,ddxc,wlhm,wlms,sl) values ";
						insertSql += "((select id from uf_trdpldy where trdh = '" + trdh + "'),";
						insertSql += "'" + list.get(i).get("cp") + "',";
						insertSql += "'" + list.get(i).get("gbm") + "',";
						insertSql += "'" + list.get(i).get("pono") + "',";
						insertSql += "'" + list.get(i).get("poitem") + "',";
						insertSql += "'" + list.get(i).get("wlh") + "',";
						insertSql += "'" + list.get(i).get("wlname") + "',";
						insertSql += "'" + list.get(i).get("sl") + "')";
						log.writeLog("插入建模明细执行的sql :" + insertSql);
						rs1.executeSql(insertSql);// 后插入明细
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			log.writeLog(e);
			request.getRequestManager().setMessagecontent("插入失败，请联系管理员");
			return "0";
		} finally {
			if (null != sapconnection) {
				JCO.releaseClient(sapconnection);
			}
		}
		return Action.SUCCESS;
	}
}
