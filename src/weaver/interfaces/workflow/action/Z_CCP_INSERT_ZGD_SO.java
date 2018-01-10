package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

import weaver.conn.RecordSet;
import weaver.formmode.setup.ModeRightInfo;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

/**
 *
 * @author jisuqiang
 * @date 2017-12-18
 */
public class Z_CCP_INSERT_ZGD_SO extends BaseBean implements Action {
	private static int userid=0;
	// shipping柜号输入接口
	@Override
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_INSERT_ZGD_SO开始");
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
			RecordSet dtrs = new RecordSet();

			userid = request.getRequestManager().getUser().getUID();
			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}

			Date date = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
			String currentdate = format.format(date);// 当前日期

			SimpleDateFormat format1 = new SimpleDateFormat("yyyyMMdd");
			String currentdate1 = format1.format(date);// 当前日期

			// 主表数据
			String sfyg = "";// 是否有柜
			//String id = "";// 主表id
			String sfzf = "";// 是否作废

			String yggys = "";// 运柜供应商
			String dj1 = "";// 运柜单价（/柜）
			String bz1 = "";// 运柜费币种

			String zggys = "";// 装柜供应商
			String dj2 = "";// 装柜单价（/柜）
			String bz2 = "";// 装柜费币种

			String dggys = "";// 吊柜供应商
			String dj3 = "";// 吊柜单价（/柜）
			String bz3 = "";// 吊柜费币种

			String lcbh = "";// 流程编号
			String gsdm = "";// 公司代码
			String gsb = "";// 公司别
			String sfdg = "";// 是否吊柜
			String zxjhh = "";// 装卸计划号
			String shipping = "";// Shipping

			// 建模表主数据
			String jmid = "";// 建模主表id
			String feename = "1";// 费用名称
			String djstatus = "0";// 单据状态 已审核/已上传/已对账/已清账/已作废
			String djtitle = currentdate;// 单据抬头
			// String zxplanno = zxjhh;//装卸计划单号
			String comname = "";// 公司名称
			String comcode = "";// 公司代码
			String hbkpyz = "";// 合并开票原则 //明细获取
			String pztype = "SA";// 凭证类型
			String currency = "MYR";// 货币码
			String carno = "";// 车牌号码
			String dw = "";// 吨位
			String notaxamt = "";// 未税金额 明细合计
			String amount = "";// 暂估金额
			String zgfylx = "1";// 暂估费用类型 异常费用/正常费用
			String credate = currentdate;// 创建日期
			String cysname = "";// 承运商名称
			String cyscode = "";// 承运商代码
			String creditpsn = "";// 制单人
			String remark = "";// 备注
			String djbh = "";// 单据编号 公司代码+FYZG+201701+3流水
			String djlx = "0";// 单据类型

			String hl = "1";// 汇率 默认为1
			String creditdate = currentdate;// 凭证日期
			String fylx = "1";// 费用类型 1运费2吊柜费3装柜劳务费4柜费
			String cx = "";// 车型
			String sz = "1";// 税则 默认为1
			double sum = 0.00;

			// 建模表明细数据
			String jzdm = "40";// 记帐代码
			String account = "55060600";// 科目
			String dtnotaxamt = "";// 未税金额
			String taxcode = "";// 销售税代码
			String costcenter = "";// 成本中心
			String pono = "";// 订单号
			String orderitem = "";// 订单行项目
			String itemtext = "";// 项目文本
			String wlh = "";// 物料号
			String zl = "";// 分摊重量
			String khdz = "";// 客户地址

			List<Map<String, String>> list = new ArrayList<Map<String, String>>();
			Map<String, String> mainMap = new HashMap<String, String>();
			String selectsql = "select * from " + tablename + " where requestid = '" + requestid + "'";
			log.writeLog("查询流程表单的sql:" + selectsql);
			rs.execute(selectsql);
			if (rs.next()) {
				sfzf = Util.null2String(rs.getString("sfzf"));// 是否作废
				sfyg = Util.null2String(rs.getString("sfyg"));// 是否有柜
				yggys = Util.null2String(rs.getString("yggys"));// 运柜供应商
				dj1 = Util.null2String(rs.getString("dj1")) == "" ? "0.00" : rs.getString("dj1");// 运柜单价（/柜）
				dj3 = Util.null2String(rs.getString("dj3")) == "" ? "0.00" : rs.getString("dj3");// 吊柜单价（/柜）
				bz1 = Util.null2String(rs.getString("bz1"));// 运柜费币种
				bz2 = Util.null2String(rs.getString("bz2"));// 装柜费币种
				sfdg = Util.null2String(rs.getString("sfdg"));// 是否吊柜
				zxjhh = Util.null2String(rs.getString("zxjhh"));// 装卸计划号
				zggys = Util.null2String(rs.getString("zggys"));// 装柜供应商
				gsb = Util.null2String(rs.getString("gsb"));// 公司别
				gsdm = Util.null2String(rs.getString("gsdm"));// 公司代码
				lcbh = Util.null2String(rs.getString("lcbh"));// 流程编号
				bz3 = Util.null2String(rs.getString("bz3"));// 吊柜费币种
				gsb = Util.null2String(rs.getString("gsb"));// 公司别
				dggys = Util.null2String(rs.getString("dggys"));// 吊柜供应商
				shipping = Util.null2String(rs.getString("shipping"));// Shipping
				dj2 = Util.null2String(rs.getString("dj2")) == "" ? "0.00" : rs.getString("dj2");// 装柜单价（/柜）
				creditpsn = Util.null2String(rs.getString("sqr"));

				mainMap.put("lcbh", lcbh);// 流程编号
				mainMap.put("requestid", requestid + "");// 请求id
				mainMap.put("feename", feename);// 费用名称
				mainMap.put("djtitle", djtitle);// 单据抬头
				mainMap.put("djstatus", djstatus);// 单据状态
				mainMap.put("comname", gsb);// 公司名称
				mainMap.put("comcode", gsdm);// 公司代码
				mainMap.put("hbkpyz", hbkpyz);// 合并开票原则
				mainMap.put("pztype", pztype);// 凭证类型
				mainMap.put("currency", currency);// 货币码
				mainMap.put("carno", carno);// 车牌号码
				mainMap.put("dw", dw);// 吨位
				mainMap.put("notaxamt", notaxamt);// 未税金额
				mainMap.put("amount", amount);// 暂估金额
				mainMap.put("zgfylx", zgfylx);// 暂估费用类型
				mainMap.put("credate", credate);// 创建日期
				mainMap.put("cysname", cysname);// 承运商名称
				mainMap.put("cyscode", cyscode);// 承运商代码
				mainMap.put("creditpsn", creditpsn);// 制单人
				mainMap.put("creditdate", creditdate);// 凭证日期
				mainMap.put("remark", remark);// 备注
				mainMap.put("djbh", djbh);// 单据编号
				mainMap.put("djlx", djlx);// 单据类型
				mainMap.put("hl", hl);// 汇率
				mainMap.put("zxplanno", zxjhh);// 装卸计划号
				// mainMap.put("fylx", fylx);// 费用类型
				mainMap.put("cx", cx);// 车型
				mainMap.put("sz", sz);// 税则
			}
			if (!"1".equals(sfzf)) {
				if ("1".equals(sfyg)) {
					String dtsql = " select t2.SALEORDER,t2.ORDERITEM as ,sum(LLJZ) as lljz,max(dw) as wlh from formtable_main_43 t1 left join";
					dtsql += " formtable_main_43_dt1 t2 on t1.id = t2.mainid";
					dtsql += " group by t2.SALEORDER,t2.ORDERITEM,t1.requestid";
					dtsql += " having t1.requestid = '" + requestid + "'";
					log.writeLog(dtsql);
					if (dtrs.execute(dtsql)) {
						double total = 0.00;
						String lljz = "";
						while (dtrs.next()) {
							Map<String, String> map = new HashMap<String, String>();
							map.put("pono", dtrs.getString("SALEORDER"));
							map.put("orderitem", dtrs.getString("ORDERITEM"));
							map.put("wlh", dtrs.getString("wlh"));// 物料号
							map.put("zl", dtrs.getString("lljz"));// 重量

							map.put("jzdm", jzdm);// 记帐代码
							map.put("account", account);// 科目
							map.put("dtnotaxamt", dtnotaxamt);// 分摊费用
							map.put("costcenter", costcenter);// 成本中心
							map.put("itemtext", itemtext);// 项目文本
							map.put("khdz", khdz);// 客户地址
							map.put("ddlx", "0");// 订单类型

							lljz = dtrs.getString("lljz");
							map.put("lljz", lljz);
							total += Double.parseDouble(lljz);
							map.put("total", total + "");
							list.add(map);
						}
						log.writeLog("明细表查询完毕");
						if (Double.parseDouble(dj1) > 0) {
							// 运柜
							mainMap.put("sum", dj1 + "");
							mainMap.put("djtitle", djtitle + "运柜费");
							mainMap.put("currency", bz1);// 货币码
							mainMap.put("cysname", yggys);// 承运商名称
							mainMap.put("fylx", "4");// 费用类型
							mainMap.put("feename", "4");// 费用名称
							double all = 0.00;
							for (int i = 0; i < list.size(); i++) {
								if (i == list.size() - 1) {
									dtnotaxamt = calculateJZ(Double.parseDouble(dj1), all) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
								} else {
									dtnotaxamt = mul(
											div(Double.parseDouble(lljz),
													Double.parseDouble(list.get(list.size() - 1).get("total"))),
											Double.parseDouble(dj1)) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
									all += Double.parseDouble(dtnotaxamt);// n-1次的和
								}
							}
							createZGD(mainMap, list);

						}
						if (Double.parseDouble(dj2) > 0) {
							// 装柜
							mainMap.put("sum", dj2 + "");
							mainMap.put("djtitle", djtitle + "装柜费");
							mainMap.put("currency", bz2);// 货币码
							mainMap.put("cysname", zggys);// 承运商名称
							mainMap.put("fylx", "3");// 费用类型
							mainMap.put("feename", "3");// 费用名称
							double all = 0.00;
							for (int i = 0; i < list.size(); i++) {
								if (i == list.size() - 1) {
									dtnotaxamt = calculateJZ(Double.parseDouble(dj2), all) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
								} else {
									dtnotaxamt = mul(
											div(Double.parseDouble(lljz),
													Double.parseDouble(list.get(list.size() - 1).get("total"))),
											Double.parseDouble(dj2)) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
									all += Double.parseDouble(dtnotaxamt);// n-1次的和
								}
							}
							createZGD(mainMap, list);
						}
						if ("1".equals(sfdg) && Double.parseDouble(dj3) > 0) {
							// 吊柜
							mainMap.put("sum", dj3 + "");
							mainMap.put("djtitle", djtitle + "吊柜费");
							mainMap.put("currency", bz3);// 货币码
							mainMap.put("cysname", dggys);// 承运商名称
							mainMap.put("fylx", "2");// 费用类型
							mainMap.put("feename", "2");// 费用名称
							double all = 0.00;
							for (int i = 0; i < list.size(); i++) {
								if (i == list.size() - 1) {
									dtnotaxamt = calculateJZ(Double.parseDouble(dj3), all) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
								} else {
									dtnotaxamt = mul(
											div(Double.parseDouble(lljz),
													Double.parseDouble(list.get(list.size() - 1).get("total"))),
											Double.parseDouble(dj3)) + "";
									list.get(i).put("dtnotaxamt", dtnotaxamt);
									all += Double.parseDouble(dtnotaxamt);// n-1次的和
								}
							}
							createZGD(mainMap, list);
						}

						// 打印log
						log.writeLog("遍历主表");
						for (String k : mainMap.keySet()) {
							log.writeLog(k + " = " + mainMap.get(k));
						}

						// 打印log
						log.writeLog("遍历明细");
						for (Map<String, String> m : list) {
							log.writeLog("--------------");
							for (String k : m.keySet()) {
								log.writeLog(k + " = " + m.get(k));
							}
						}

					} else {
						log.writeLog("查询明细sql错误");
					}

				} else {
					log.writeLog("无柜不会有装柜费用");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			log.writeLog(e);
			request.getRequestManager().setMessagecontent("插入失败，请联系管理员");
			return "0";
		}
		return Action.SUCCESS;
	}

	public boolean createZGD(Map mainMap, List<Map<String, String>> list) {
		BaseBean log = new BaseBean();
		Date date = new Date();
		SimpleDateFormat format1 = new SimpleDateFormat("yyyyMMdd");
		String currentdate1 = format1.format(date);// 当前日期
		boolean flag = false;
		RecordSet rs = new RecordSet();
		RecordSet rs1 = new RecordSet();
		RecordSet rs2 = new RecordSet();
		RecordSet rs3 = new RecordSet();
		RecordSet inrs = new RecordSet();
		String jmid = "";
		double total = 0.00;
		log.writeLog("调用存储过程CREATE_ZGDLS");
		rs1.executeProc("CREATE_ZGDLS", "");
		if (rs1.next()) {
			String djbh = mainMap.get("comcode") + "FYZG" + currentdate1.substring(2, 6) + formatString(rs1.getInt(1));
			mainMap.put("djbh", djbh);
		}
		if (mainMap.size() > 0) {
			StringBuffer buffer = new StringBuffer();
			buffer.append(
					"Insert into UF_ZGFY (REQUESTID,lgbh,feename,djtitle,djstatus,zxplanno,comcode,comname,hbkpyz,pztype,currency,carno,dw,notaxamt,amount,zgfylx,credate,cysname,cyscode,creditpsn,creditdate,remark,djbh,djlx,fylx,cx,sz,FORMMODEID,hl," +
							"MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid) values (");
			buffer.append("'").append(mainMap.get("requestid")).append("',");// 流程Id
			buffer.append("'").append(mainMap.get("lcbh")).append("',");// 理柜编号
			buffer.append("'").append(mainMap.get("feename")).append("',");// 费用名称
			buffer.append("'").append(mainMap.get("djtitle")).append("',");// 单据抬头
			buffer.append("'").append(mainMap.get("djstatus")).append("',");// 单据状态
			buffer.append("'").append(mainMap.get("zxplanno")).append("',");// 装卸计划单号
			buffer.append("'").append(mainMap.get("comcode")).append("',");// 公司名称
			buffer.append("'").append(mainMap.get("comname")).append("',");// 公司代码
			buffer.append("'").append(mainMap.get("hbkpyz")).append("',");// 合并开票原则
			buffer.append("'").append(mainMap.get("pztype")).append("',");// 凭证类型
			buffer.append("'").append(mainMap.get("currency")).append("',");// 货币码
			buffer.append("'").append(mainMap.get("carno")).append("',");// 车牌号码
			buffer.append("'").append(mainMap.get("dw")).append("',");// 吨位
			buffer.append("'").append(mainMap.get("sum")).append("',");// 未税金额
			buffer.append("'").append(mainMap.get("amount")).append("',");// 暂估金额
			buffer.append("'").append(mainMap.get("zgfylx")).append("',");// 暂估费用类型
			buffer.append("'").append(mainMap.get("credate")).append("',");// 创建日期
			buffer.append("'").append(mainMap.get("cysname")).append("',");// 承运商名称
			buffer.append("'").append(mainMap.get("cyscode")).append("',");// 承运商代码
			buffer.append("'").append(mainMap.get("creditpsn")).append("',");// 制单人
			buffer.append("'").append(mainMap.get("creditdate")).append("',");// 凭证日期
			buffer.append("'").append(mainMap.get("remark")).append("',");// 备注
			buffer.append("'").append(mainMap.get("djbh")).append("',");// 单据编号
			buffer.append("'").append(mainMap.get("djlx")).append("',");// 单据类型
			buffer.append("'").append(mainMap.get("fylx")).append("',");// 费用类型
			buffer.append("'").append(mainMap.get("cx")).append("',");// 车型
			buffer.append("'").append(mainMap.get("sz")).append("',");// 税则
			buffer.append("'").append("721").append("',");
			buffer.append("'").append(mainMap.get("hl")).append("',");// 汇率、

			buffer.append("'").append(userid).append("',");

			buffer.append("'").append("0").append("',");
			Date d1=new Date();
			SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
			SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");
			buffer.append("'").append(dateFormat.format(d1)).append("',");
			buffer.append("'").append(dateFormat1.format(d1)).append("',");
			String str1 = UUID.randomUUID().toString();
			buffer.append("'").append(str1).append("')");

			log.writeLog("插入建模主表的sql:" + buffer.toString());
			if (inrs.executeSql(buffer.toString())) {
				String sql = "select id from UF_ZGFY where djbh = '" + mainMap.get("djbh") + "'";


				String sqlx="select id from UF_ZGFY where modeuuid='"+str1+"'";
				log.writeLog(sqlx);
				rs1.execute(sqlx);
				String id="";
				if(rs1.next()){
					id=Util.null2String(rs1.getString("id"));
				}
				ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
				localModeRightInfo1.setNewRight(true);
				localModeRightInfo1.editModeDataShare(userid, 721, Integer.parseInt(id));

				/*
				StringBuffer sb = new StringBuffer();// 插入权限表
				sb.append("insert into MODEDATASHARE_721");
				sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
				sb.append("(").append("(select id from UF_ZGFY where djbh = '" + mainMap.get("djbh") + "')")
						.append(",");
				sb.append("'").append("1").append("',");
				sb.append("'").append("1").append("',");
				sb.append("'").append("0").append("',");
				sb.append("'").append("3").append("')");
				log.writeLog("插入权限执行的sql:" + sb.toString());
				rs1.executeSql(sb.toString());
				*/
				if (rs.execute(sql)) {
					if (rs.next()) {
						jmid = Util.null2String(rs.getString("id"));
						if (!"".equals(jmid)) {
							for (int i = 0; i < list.size(); i++) {
								log.writeLog("dtid:" + jmid);
								String insertSql = "Insert into UF_ZGFY_DT1 (mainid,jzdm,account,notaxamt,costcenter,pono,orderitem,wlh,zl,khdz,ddlx,itemtext) values(";
								insertSql += "'" + jmid + "',";
								insertSql += "'" + list.get(i).get("jzdm") + "',";
								insertSql += "'" + list.get(i).get("account") + "',";
								insertSql += "'" + list.get(i).get("dtnotaxamt") + "',";// 未税金额
								insertSql += "'" + list.get(i).get("costcenter") + "',";
								insertSql += "'" + list.get(i).get("pono") + "',";
								insertSql += "'" + list.get(i).get("orderitem") + "',";
								insertSql += "'" + list.get(i).get("wlh") + "',";
								insertSql += "'" + list.get(i).get("zl") + "',";
								insertSql += "'" + list.get(i).get("khdz") + "',";
								insertSql += "'" + list.get(i).get("ddlx") + "',";
								insertSql += "'" + list.get(i).get("itemtext") + "')";

								total += Double.parseDouble(list.get(i).get("dtnotaxamt"));// 计算合计
								log.writeLog("插入建模明细的sql:" + insertSql);
								flag = inrs.execute(insertSql);
								if (!flag) {
									log.writeLog("单据编号：" + list.get(i).get("djbh") + "，插入明细错误");
									break;
								}
								if (i == list.size() - 1) {
									insertSql = "Insert into UF_ZGFY_DT1 (mainid,jzdm,account,notaxamt,costcenter)values(";
									insertSql += "'" + jmid + "',";
									insertSql += "'50',";
									insertSql += "'21810999',";
									insertSql += "'" + total + "',";// 未税金额
									insertSql += "'" + list.get(i).get("costcenter") + "')";
									flag = inrs.execute(insertSql);
									if (!flag) {
										log.writeLog("单据编号：" + list.get(i).get("djbh") + "，插入明细错误");
										break;
									}
								}
							}
						} else {
							log.writeLog("插入建模主表Id失败");
						}
					}
				}
			}

		}
		return flag;
	}

	public String formatString(int input) {
		String result;
		// 大于1000时直接转换成字符串返回
		if (input > 1000) {
			result = input + "";
		} else {// 根据位数的不同前边补不同的0
			int length = (input + "").length();

			if (length == 1) {
				result = "000" + input;
			} else if (length == 2) {
				result = "00" + input;
			} else {
				result = "0" + input;
			}
		}
		return result;
	}

	public Double add(double v1, double v2) {
		// 计算净重的绝对值
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
		return b1.add(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public Double calculateJZ(double v1, double v2) {
		// 计算净重的绝对值
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
		return b1.subtract(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public Double mul(double v1, double v2) {
		// 计算乘法
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

		return b1.multiply(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public Double div(double v1, double v2) {
		// 计算除法
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

		return b1.divide(b2, 2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}
}