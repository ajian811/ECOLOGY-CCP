package weaver.interfaces.workflow.action;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.interfaces.workflow.action.CCPUtil.CalUtil;
import weaver.interfaces.workflow.action.CCPService.CalFreightService;
import weaver.interfaces.workflow.action.CCPServiceImpl.CalFreightServiceImpl;

/**
 *
 * @author jisuqiang
 * @date 2017-12-21
 */
public class CommClass {
	private static String config_wf = "CCP_ZGD";// 暂估单

	private static CalFreightService calFreightService=new CalFreightServiceImpl();

	private static CalUtil calUtil=new CalUtil();

	public static void apportionmentWeight(String zxjhh, String lx) {

		BaseBean log = new BaseBean();

		log.writeLog("进入CommClass");
		try {
			if ("".equals(zxjhh) || "".equals(lx)) {
				log.writeLog("装卸计划号为空，或者类型为空");
				return;
			}

			log.writeLog("zxjhh = " + zxjhh + ", lx = " + lx);

			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet dtrs = new RecordSet();
			DecimalFormat df = new DecimalFormat("#.00");

			double zgz = 0.00;// 总柜重量
			double bzclzzl = 0.00;// 包装材料总重量
			double gbzl = 0.00;// 过磅重量（总净重）
			double zhwjz = 0.00;// 总货物净重
			String sfyg = "";// 是否有柜
			String id = "";// 主表id
			double jhlljz = 0.00;// 计划理论净重
			double sjjz = 0.00;// 实际净重
			String dtid = "";// 明细表的id
			double total = 0.00;// 理论净重合计

			List<Map<String, String>> list = new ArrayList<Map<String, String>>();
			if ("0".equals(lx)) {
				log.writeLog("进入so分摊重量");

				/*
				 * 总货物净重计算，计算公式 总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
				 */

				String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "' and requestid is null";
				log.writeLog("查询主表Sql:" + sql);
				if (rs.execute(sql)) {
					if (rs.next()) {
						zgz = rs.getDouble("zgz") == -1.0 ? 0.00 : rs.getDouble("zgz");// 总柜重量
						bzclzzl = rs.getDouble("bzclzzl") == -1.0 ? 0.00 : rs.getDouble("bzclzzl");// 包装材料总重量
						gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");// 过磅重量
						sfyg = Util.null2String(rs.getString("sfyg"));// 是否有柜
						id = Util.null2String(rs.getString("id"));// 主表id

						log.writeLog("zgz " + zgz);
						log.writeLog("bzclzzl " + bzclzzl);
						log.writeLog("gbzl " + gbzl);

					}
				} else {
					log.writeLog("数据库查询错误");
				}
				if ("1".equals(sfyg)) {
					// 有柜情况
					zhwjz = calUtil.calculateJZ(calUtil.calculateJZ(gbzl, zgz), bzclzzl);// 总货物净重
					log.writeLog("计算出的总货物净重:" + zhwjz);
					/*
					 * 每条明细计划理论净重，计算公式 （SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
					 */
					if (zhwjz > 0) {
						String dtSql = "select * from formtable_main_45_dt3 where mainid = '" + id + "'";
						log.writeLog("查询明细表2sql:" + dtSql);
						dtrs.execute(dtSql);

						while (dtrs.next()) {
							Map<String, String> map = new HashMap<String, String>();
							String sl = dtrs.getString("sl");// 数量
							String jhyzl = dtrs.getString("jhyzl");// 计划运载量
							String jzl = dtrs.getString("jzl") == "" ? "0" : dtrs.getString("jzl");// 净重量
							dtid = dtrs.getString("id");// 每条明细id

							log.writeLog("sl " + sl);
							log.writeLog("jhyzl " + jhyzl);
							log.writeLog("jzl " + jzl);

							jhlljz = calUtil.mul(calUtil.div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
																													// /
																													// Double.parseDouble(sl))
																													// *
																													// Double.parseDouble(jhyzl);//每条明细计划净重
							total += jhlljz;
							map.put("jhlljz", "" + jhlljz);
							map.put("dtid", dtid);
							list.add(map);
						}
					}
				} else if ("0".equals(sfyg)) {
					// 无柜情况
					zhwjz = calUtil.calculateJZ(calUtil.calculateJZ(gbzl, zgz), bzclzzl);// Double.parseDouble(gbzl)
																			// -
																			// Double.parseDouble(zgz)
																			// -
																			// Double.parseDouble(bzclzzl);//总货物净重
					log.writeLog("计算出的总货物净重:" + zhwjz);
					/*
					 * 每条明细计划理论净重，计算公式 （SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
					 */
					if (zhwjz > 0) {
						String dtSql = "select * from formtable_main_45_dt3 where mainid = '" + id + "'";
						log.writeLog("查询明细表3sql:" + dtSql);
						dtrs.execute(dtSql);

						// List<Map<String, String>> list = new
						// ArrayList<Map<String, String>>();
						while (dtrs.next()) {
							Map<String, String> map = new HashMap<String, String>();
							String sl = dtrs.getString("sl");// 数量
							String jhyzl = dtrs.getString("jhyzl");// 计划运载量
							String jzl = dtrs.getString("jzl");// 净重量
							dtid = dtrs.getString("id");// 每条明细id

							log.writeLog("sl " + sl);
							log.writeLog("jhyzl " + jhyzl);
							log.writeLog("jzl " + jzl);

							jhlljz = calUtil.mul(calUtil.div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
																													// /
																													// Double.parseDouble(sl))
																													// *
																													// Double.parseDouble(jhyzl);//每条明细计划净重
							total += jhlljz;
							map.put("jhlljz", "" + jhlljz);
							map.put("dtid", dtid);
							list.add(map);
						}
					}

				}
			} else if ("1".equals(lx)) {
				log.writeLog("进入po分摊重量");

				String sql = "select * from formtable_main_61 where zxjhh = '" + zxjhh + "'";
				log.writeLog("查询主表Sql:" + sql);
				if (rs.execute(sql)) {
					if (rs.next()) {
						zgz = 0.00;// 柜重默认为0
						bzclzzl = rs.getDouble("bzclzzl") == -1.0 ? 0.00 : rs.getDouble("bzclzzl");// 包装材料总重量
						gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");// 过磅重量
						sfyg = Util.null2String(rs.getString("sfyg"));// 是否有柜
						id = Util.null2String(rs.getString("id"));// 主表id

						log.writeLog("zgz " + zgz);
						log.writeLog("bzclzzl " + bzclzzl);
						log.writeLog("gbzl " + gbzl);

					} else {
						log.writeLog("数据库查询错误");
						return;
					}

					if ("1".equals(sfyg) && !"".equals(sfyg)) {
						// 有柜情况
						/*
						 * 总货物净重计算，计算公式 总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
						 */
						zhwjz = calUtil.calculateJZ(calUtil.calculateJZ(gbzl, zgz), bzclzzl);// 总货物净重
						log.writeLog("计算出的总货物净重:" + zhwjz);
						/*
						 * 每条明细计划理论净重，计算公式 （SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
						 */
						if (zhwjz > 0) {
							String dtSql = "select * from formtable_main_61_dt1 where mainid = '" + id + "'";
							log.writeLog("查询明细表1sql:" + dtSql);
							dtrs.execute(dtSql);

							// List<Map<String, String>> list = new
							// ArrayList<Map<String, String>>();
							while (dtrs.next()) {
								Map<String, String> map = new HashMap<String, String>();
								String sl = dtrs.getString("sl");// 数量
								String jhyzl = dtrs.getString("jhyzl");// 计划运载量
								String jzl = dtrs.getString("jzl");// 净重量
								dtid = dtrs.getString("id");// 每条明细id

								log.writeLog("sl " + sl);
								log.writeLog("jhyzl " + jhyzl);
								log.writeLog("jzl " + jzl);

								jhlljz = calUtil.mul(calUtil.div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
																														// /
																														// Double.parseDouble(sl))
																														// *
																														// Double.parseDouble(jhyzl);//每条明细计划净重
								total += jhlljz;
								map.put("jhlljz", "" + jhlljz);
								map.put("dtid", dtid);
								list.add(map);
							}
						} else {
							log.writeLog("计算值为小于0");
							return;
						}
					} else if ("0".equals(sfyg) && !"".equals(sfyg)) {
						// 无柜情况
						zhwjz = calUtil.calculateJZ(calUtil.calculateJZ(gbzl, zgz), bzclzzl);// Double.parseDouble(gbzl)
																				// -
																				// Double.parseDouble(zgz)
																				// -
																				// Double.parseDouble(bzclzzl);//总货物净重
						log.writeLog("计算出的总货物净重:" + zhwjz);
						/*
						 * 每条明细计划理论净重，计算公式 （SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
						 */
						if (zhwjz > 0) {
							String dtSql = "select * from formtable_main_61_dt2 where mainid = '" + id + "'";
							log.writeLog("查询明细表2sql:" + dtSql);
							dtrs.execute(dtSql);

							// List<Map<String, String>> list = new
							// ArrayList<Map<String, String>>();
							while (dtrs.next()) {
								Map<String, String> map = new HashMap<String, String>();
								String sl = dtrs.getString("sl");// 数量
								String jhyzl = dtrs.getString("jhyzl");// 计划运载量
								String jzl = dtrs.getString("jzl");// 净重量
								dtid = dtrs.getString("id");// 每条明细id

								log.writeLog("sl " + sl);
								log.writeLog("jhyzl " + jhyzl);
								log.writeLog("jzl " + jzl);

								jhlljz = calUtil.mul(calUtil.div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
																														// /
																														// Double.parseDouble(sl))
																														// *
																														// Double.parseDouble(jhyzl);//每条明细计划净重
								total += jhlljz;
								map.put("jhlljz", "" + jhlljz);
								map.put("dtid", dtid);
								list.add(map);
							}
						}

					} else {
						log.writeLog("没有获取到是否有柜");
						return;
					}
				}
			}

			String dtname = "";
			String fieldname = "";
			if ("0".equals(lx) && !"".equals(sfyg)) {
				// SO
				if ("0".equals(sfyg)) {
					dtname = "formtable_main_45_dt3";
				} else {
					dtname = "formtable_main_45_dt3";
				}
				fieldname = "sjftjz";
			} else if ("1".equals(lx) && !"".equals(sfyg)) {
				// po

				if ("0".equals(sfyg)) {
					dtname = "formtable_main_61_dt2";
				} else {
					dtname = "formtable_main_61_dt1";
				}
				fieldname = "ftzl";
			} else {
				log.writeLog("分配错误");
				return;
			}

			if (list.size() <= 0) {
				log.writeLog("数据获取失败，list中没有数据");
				return;
			}

			boolean flag = false;
			for (int i = 0; i < list.size(); i++) {
				/*
				 * 明细的实际分摊净重，计算公式 （计划理论净重/计划理论净重合计）*过磅总货物净重
				 */
				sjjz =calUtil.mul(calUtil.div(Double.parseDouble(list.get(i).get("jhlljz")), total), zhwjz);
				String updateSql = "update " + dtname + " set " + fieldname + " = '" + df.format(sjjz)
						+ "' where id = '" + list.get(i).get("dtid") + "'";
				log.writeLog("更新明细sql: " + updateSql);
				flag = rs1.executeSql(updateSql);
				if (!flag) {
					log.writeLog("更新数据明细表" + dtname + ",id = " + list.get(i).get("dtid") + "失败，调用运费计算错误");
					break;
				}

			}
			if (flag) {
				calcMainYF(zxjhh, lx);
			} else {
				log.writeLog("获取分摊运费页面错误");
				return;
			}
			// out.print("end");
		} catch (Exception e) {
			// TODO: handle exception
			log.writeLog("fail" + e);
			e.printStackTrace();

		}

	}

	public static void calcMainYF(String zxjhh, String lx) {
		calFreightService.calAllocateFrieght(zxjhh,lx);
	}



}