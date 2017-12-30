package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import weaver.conn.RecordSet;
import weaver.file.Prop;
import weaver.general.BaseBean;
import weaver.general.Util;

/**
 *
 * @author jisuqiang
 * @date 2017-12-21
 */
public class CommClass {
	private static String config_wf = "CCP_ZGD";// 暂估单

	public static void apportionmentWeight(String zxjhh, String lx) {

		BaseBean log = new BaseBean();

		log.writeLog("调用Apportionment_Weight.jsp开始");
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
			String dtid = "";// 明细表2的id
			double total = 0.00;// 理论净重合计

			List<Map<String, String>> list = new ArrayList<Map<String, String>>();
			if ("0".equals(lx)) {
				log.writeLog("进入so分摊重量");

				/*
				 * 总货物净重计算，计算公式 总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
				 */

				String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "'";
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
					zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);// 总货物净重
					log.writeLog("计算出的总货物净重:" + zhwjz);
					/*
					 * 每条明细计划理论净重，计算公式 （SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
					 */
					if (zhwjz > 0) {
						String dtSql = "select * from formtable_main_45_dt2 where mainid = '" + id + "'";
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

							jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
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
					zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);// Double.parseDouble(gbzl)
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

							jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
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
						zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);// 总货物净重
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

								jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
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
						zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);// Double.parseDouble(gbzl)
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

								jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));// (Double.parseDouble(jzl)
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
					dtname = "formtable_main_45_dt2";
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
				sjjz = mul(div(Double.parseDouble(list.get(i).get("jhlljz")), total), zhwjz);
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
		BaseBean log = new BaseBean();
		log.writeLog("调用CALC_MAINYF.jsp开始");

		try {
			if ("".equals(zxjhh) || "".equals(lx)) {
				log.writeLog("装卸计划号为空，或者类型为空");
				return;
			}
			log.writeLog("zxjhh = " + zxjhh + ", lx = " + lx);
			String dtname1 = "";
			String dtname2 = "";
			String fieldname = "";
			if ("0".equals(lx)) {
				// SO
				dtname1 = "formtable_main_45_dt2";
				dtname2 = "formtable_main_45_dt3";
				fieldname = "ftfy";
			} else if ("1".equals(lx)) {
				// po
				dtname1 = "formtable_main_61_dt1";
				dtname2 = "formtable_main_61_dt2";
				fieldname = "fee";
			} else {
				log.writeLog("分配错误");
				return;
			}

			String jfms = "";// 计费模式 0包车 1配载 2计件 3 byweight（kg） 4 byweight（T） 5
								// bytrip（km）
			double gbzl = 0.00;// 过磅重量（总净重）
			double jgd = 0.00;// 价格档（单价）
			double lc = 0.00;// 里程
			double mainPrice = 0.00;// 一般运费
			String sfyg = "";// 是否有柜 1 有柜 2无柜
			double cuont = 0.00;// 计件数
			double total = 0.00;// 总运费
			double flxzj = 0.00;// 辅线路运费
			double tczyf = 0.00;// 同城费用

			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet dtrs = new RecordSet();
			RecordSet uprs = new RecordSet();

			List<Map<String, Double>> list = new ArrayList<Map<String, Double>>();

			if ("0".equals(lx)) {
				log.writeLog("进入so分摊运费");

				/*
				 * 类型算主线路运费： 包车： 直接取单价 计件（按个数）： 单价*计件数量 按重量计算（按吨的话）：
				 * 单价*过磅重量（KG）/1000 按重量计算（按KG的话）： 单价*过磅重量（KG） 配载（按重量和里程,
				 * 每吨每KM多少钱）：主路线的到达城市点的里程数（KM）*(过磅重量（KG）/1000)*单价
				 */

				// DecimalFormat df = new DecimalFormat("#");

				String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "'";
				log.writeLog("查询主表Sql:" + sql);
				if (rs.execute(sql)) {
					if (rs.next()) {
						jfms = Util.null2String(rs.getString("jfms"));// 计费模式
						gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");// 过磅重量
						jgd = rs.getDouble("jgd") == -1.0 ? 0.00 : rs.getDouble("jgd");// 价格档（单价）
						lc = rs.getDouble("id") == -1.0 ? 0.00 : rs.getDouble("id");// 里程
						tczyf = rs.getDouble("tczyf") == -1.0 ? 0.00 : rs.getDouble("tczyf");// 同城费用
						flxzj = rs.getDouble("flxzj") == -1.0 ? 0.00 : rs.getDouble("flxzj");// 辅线路费用
						sfyg = rs.getString("sfyg");// 是否有柜

						if ("0".equals(jfms)) {// 包车
							mainPrice = jgd;
						} else if ("1".equals(jfms)) {// 配载
							mainPrice = mul(mul(lc, div(gbzl, 1000)), gbzl);
						} else if ("2".equals(jfms)) {
							// TODO
							String dtsql = "select sum(t2.sl)as d2sum, sum(t3.sl)as d3sum from formtable_main_45 t1";
							dtsql += " left join formtable_main_45_dt2 t2 on t1.id = t2.mainid";
							dtsql += " left join formtable_main_45_dt3 t3 on t1.id = t3.mainid";
							dtsql += " where t1.zxjhh = '" + zxjhh + "'";
							dtsql += " order by t2.id";
							log.writeLog("查询所有明细的log:" + dtsql);
							rs1.equals(dtsql);
							if (rs1.next()) {
								if ("1".equals(sfyg)) {
									cuont = rs1.getDouble("d2sum") == -1.0 ? 0.00 : rs1.getDouble("d2sum");
									mainPrice = mul(cuont, jgd);
								} else if ("0".equals(sfyg)) {
									cuont = rs1.getDouble("d3sum") == -1.0 ? 0.00 : rs1.getDouble("d3sum");
									mainPrice = mul(cuont, jgd);
								} else {
									mainPrice = 0.00;
								}
							}

						} else if ("3".equals(jfms)) {
							// byweight（kg）
							mainPrice = mul(jgd, gbzl);
						} else if ("4".equals(jfms)) {
							mainPrice = div(mul(jgd, gbzl), 1000);
						} else if ("5".equals(jfms)) {
							// 5 bytrip（km）
							mainPrice = mul(lc, mul(div(gbzl, 1000), jgd));
						} else {
							mainPrice = 0.00;
						}
					}
				} else {
					log.writeLog("数据库查询错误");
				}

				// 总运费计算公式：总运费=一般运费+同城加价单价*同城个数+辅线路的所有运费
				total = mainPrice + tczyf + flxzj;
				log.writeLog("计算出的总运费:" + total);
				log.writeLog("sfyg:" + sfyg);
				double zqz = 0.00;// 总权重
				double dtlc = 0.00;// 明细里程
				double sjftjz = 0.00;// 实际分摊净重
				double dtid = 0;// 明细表id
				// 总权重计算 = ∑各产品明细的送达城市点的里程数*实际分摊净重
				// List<Map<String, Double>> list = new ArrayList<Map<String,
				// Double>>();

				if (total > 0 && "1".equals(sfyg)) {
					// 有柜情况下计算 总权重
					String dtsql = "select t2.* from formtable_main_45 t1";
					dtsql += " left join formtable_main_45_dt2 t2 on t1.id = t2.mainid";
					dtsql += " where t1.zxjhh = '" + zxjhh + "'";
					dtsql += " order by t2.id";
					if (dtrs.execute(dtsql)) {
						while (dtrs.next()) {
							Map<String, Double> map = new HashMap<String, Double>();
							dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");// 里程
							sjftjz = dtrs.getDouble("sjftjz") == -1.0 ? 0.00 : dtrs.getDouble("sjftjz");// 实际分摊净重
							zqz += mul(dtlc, sjftjz);// 总权重
							dtid = Double.parseDouble(dtrs.getString("id"));// 明细数据Id

							map.put("dtid", dtid);
							map.put("dtlc", dtlc);
							map.put("sjftjz", sjftjz);
							map.put("zqz", zqz);
							map.put("total", total);
							list.add(map);
						}
					} else {
						log.writeLog("查询明细2发生错误");
					}
				} else if (total > 0 && "0".equals(sfyg)) {
					String dtsql = "select t3.* from formtable_main_45 t1";
					dtsql += " left join formtable_main_45_dt3 t3 on t1.id = t3.mainid";
					dtsql += " where t1.zxjhh = '" + zxjhh + "'";
					if (dtrs.execute(dtsql)) {
						while (dtrs.next()) {
							Map<String, Double> map = new HashMap<String, Double>();
							dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");// 里程
							sjftjz = dtrs.getDouble("sjftjz") == -1.0 ? 0.00 : dtrs.getDouble("sjftjz");// 实际分摊净重
							zqz += mul(dtlc, sjftjz);
							dtid = Double.parseDouble(dtrs.getString("id"));// 明细数据Id

							map.put("dtid", dtid);
							map.put("dtlc", dtlc);
							map.put("sjftjz", sjftjz);
							map.put("zqz", zqz);
							map.put("total", total);
							list.add(map);
						}
					} else {
						log.writeLog("查询明细3发生错误");
					}
				} else {
					log.writeLog("运费小于O或获取不到数据！");
				}
			} else if ("1".equals(lx)) {
				log.writeLog("进入PO分摊运费");
				// DecimalFormat df = new DecimalFormat("#");

				String sql = "select * from formtable_main_61 where zxjhh = '" + zxjhh + "'";
				log.writeLog("查询主表Sql:" + sql);
				if (rs.execute(sql)) {
					if (rs.next()) {
						jfms = Util.null2String(rs.getString("jfms"));// 计费模式
						gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");// 过磅重量
						jgd = rs.getDouble("jgd") == -1.0 ? 0.00 : rs.getDouble("jgd");// 价格档（单价）
						lc = rs.getDouble("lc") == -1.0 ? 0.00 : rs.getDouble("lc");// 里程
						tczyf = rs.getDouble("tczyf") == -1.0 ? 0.00 : rs.getDouble("tczyf");// 同城费用
						flxzj = rs.getDouble("flxzj") == -1.0 ? 0.00 : rs.getDouble("flxzj");// 辅线路费用
						sfyg = rs.getString("sfyg");// 是否有柜

						if ("0".equals(jfms)) {// 包车
							mainPrice = jgd;
						} else if ("1".equals(jfms)) {// 配载
							mainPrice = mul(mul(lc, div(gbzl, 1000)), gbzl);
						} else if ("2".equals(jfms)) {
							// TODO
							String dtsql = "select sum(t2.sl)as d2sum, sum(t3.sl)as d3sum from formtable_main_61 t1";
							dtsql += " left join formtable_main_61_dt1 t2 on t1.id = t2.mainid";
							dtsql += " left join formtable_main_61_dt3 t3 on t1.id = t3.mainid";
							dtsql += " where t1.zxjhh = '" + zxjhh + "'";
							dtsql += " order by t2.id";
							log.writeLog("查询所有明细的log:" + dtsql);
							rs1.equals(dtsql);
							if (rs1.next()) {
								if ("1".equals(sfyg)) {
									cuont = rs1.getDouble("d2sum") == -1.0 ? 0.00 : rs1.getDouble("d2sum");
									mainPrice = mul(cuont, jgd);
								} else if ("0".equals(sfyg)) {
									cuont = rs1.getDouble("d3sum") == -1.0 ? 0.00 : rs1.getDouble("d3sum");
									mainPrice = mul(cuont, jgd);
								} else {
									mainPrice = 0.00;
								}
							}

						} else if ("3".equals(jfms)) {
							// byweight（kg）
							mainPrice = mul(jgd, gbzl);
						} else if ("4".equals(jfms)) {
							mainPrice = div(mul(jgd, gbzl), 1000);
						} else if ("5".equals(jfms)) {
							// 5 bytrip（km）
							mainPrice = mul(lc, mul(div(gbzl, 1000), jgd));
						} else {
							mainPrice = 0.00;
						}
					}
				} else {
					log.writeLog("数据库查询错误");
				}

				// 总运费计算公式：总运费=一般运费+同城加价单价*同城个数+辅线路的所有运费
				total = mainPrice + tczyf + flxzj;
				log.writeLog("计算出的总运费:" + total);
				log.writeLog("sfyg:" + sfyg);
				double zqz = 0.00;// 总权重
				double dtlc = 0.00;// 明细里程
				double sjftjz = 0.00;// 实际分摊净重
				double dtid = 0;// 明细表id
				// 总权重计算 = ∑各产品明细的送达城市点的里程数*实际分摊净重

				if (total > 0 && "1".equals(sfyg)) {
					// 有柜情况下计算 总权重
					String dtsql = "select t2.* from formtable_main_61 t1";
					dtsql += " left join formtable_main_61_dt1 t2 on t1.id = t2.mainid";
					dtsql += " where t1.zxjhh = '" + zxjhh + "'";
					dtsql += " order by t2.id";
					if (dtrs.execute(dtsql)) {
						while (dtrs.next()) {
							Map<String, Double> map = new HashMap<String, Double>();
							dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");// 里程
							sjftjz = dtrs.getDouble("ftzl") == -1.0 ? 0.00 : dtrs.getDouble("ftzl");// 实际分摊净重
							zqz += mul(dtlc, sjftjz);// 总权重
							dtid = Double.parseDouble(dtrs.getString("id"));// 明细数据Id

							map.put("dtid", dtid);
							map.put("dtlc", dtlc);
							map.put("sjftjz", sjftjz);
							map.put("zqz", zqz);
							map.put("total", total);
							list.add(map);
						}
					} else {
						log.writeLog("查询明细2发生错误");
					}
				} else if (total > 0 && "0".equals(sfyg)) {
					String dtsql = "select t3.* from formtable_main_61 t1";
					dtsql += " left join formtable_main_61_dt2 t3 on t1.id = t3.mainid";
					dtsql += " where t1.zxjhh = '" + zxjhh + "'";
					if (dtrs.execute(dtsql)) {
						while (dtrs.next()) {
							Map<String, Double> map = new HashMap<String, Double>();
							dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");// 里程
							sjftjz = dtrs.getDouble("ftzl") == -1.0 ? 0.00 : dtrs.getDouble("ftzl");// 实际分摊净重
							zqz += mul(dtlc, sjftjz);
							dtid = Double.parseDouble(dtrs.getString("id"));// 明细数据Id

							map.put("dtid", dtid);
							map.put("dtlc", dtlc);
							map.put("sjftjz", sjftjz);
							map.put("zqz", zqz);
							map.put("total", total);
							list.add(map);
						}
					} else {
						log.writeLog("查询明细3发生错误");
					}
				} else {
					log.writeLog("运费小于O或获取不到数据！");
				}
			}

			// 各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
			/*
			 * 各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算 假设有n行明细： 第1~n-1行：
			 * 产品明细的分摊运费 =产品明细的权重比例*总运费, 保留2位小数，四舍五入 第n行： 产品明细的分摊运费
			 * =总运费-∑第1~n-1行产品明细的分摊运费 如果计算出来第n行的分摊运费=0或者小于0，
			 * 则第n行的运费强制改为0.01，然后将差的金额调整到上一行；如果调整后上一行金额=0，则还要强制改为0.01，
			 * 再将差的金额调到上上一行，依次类推。
			 */

			if (list.size() <= 0) {
				log.writeLog("数据获取失败，list中没有数据");
				return;
			}

			double totalFtyf = 0.00;// 总分摊运费
			for (int i = 0; i < list.size() - 1; i++) {
				double qzbl = div(mul(list.get(i).get("dtlc"), list.get(i).get("sjftjz")),
						list.get(list.size() - 1).get("zqz"));
				double ftyf = mul(qzbl, list.get(i).get("total"));
				log.writeLog("权重比例：" + qzbl + ",ftyf: " + ftyf);
				list.get(i).put("ftyf", ftyf);
				totalFtyf += ftyf;// 1~n-1之前的分摊运费的和
			}
			log.writeLog("1~n-1之前的分摊运费的和,totalFtyf:" + totalFtyf);
			// 第N行分摊运费
			double lastFtyf = calculateJZ(total, totalFtyf);
			list.get(list.size() - 1).put("ftyf", lastFtyf);

			for (int i = list.size() - 1; i < list.size(); i--) {
				if (i == 0) {
					break;
				}
				lastFtyf = list.get(i).get("ftyf");
				if (lastFtyf <= 0) {
					log.writeLog("第" + i + "行运费小于O");
					list.get(i).put("ftyf", 0.01);
					double overPrice = calculateJZ(lastFtyf, 0.01);
					list.get(i - 1).put("ftyf", add(list.get(i - 1).get("ftyf"), overPrice));
				} else {
					break;
				}
			}

			for (int i = list.size() - 1; i < list.size(); i--) {
				if (i == 0) {
					break;
				}
				lastFtyf = list.get(i).get("ftyf");
				if (lastFtyf <= 0) {
					log.writeLog("第" + i + "行运费小于O");
					list.get(i).put("ftyf", 0.01);
					double overPrice = calculateJZ(0.01, lastFtyf);
					list.get(i - 1).put("ftyf", list.get(i - 1).get("ftyf") - overPrice);
				} else {
					break;
				}
			}

			// 打印log
			for (Map<String, Double> m : list) {
				log.writeLog("--------------");
				for (String k : m.keySet()) {
					log.writeLog(k + " : " + m.get(k));
				}
			}
			boolean flag = false;
			if ("1".equals(sfyg)) {

				// 打印log
				for (Map<String, Double> m : list) {
					String updateSql = "update " + dtname1 + " set " + fieldname + " = '" + m.get("ftyf")
							+ "' where id = '" + String.valueOf(m.get("dtid")) + "'";
					rs.writeLog(updateSql);
					flag = uprs.execute(updateSql);
					if (!flag) {
						log.writeLog("执行明细表数据id" + String.valueOf(m.get("dtid")) + "错误");
						break;
					}

				}

			} else if ("0".equals(sfyg)) {
				// 打印log
				for (Map<String, Double> m : list) {
					String updateSql = "update " + dtname2 + " set " + fieldname + " = '" + m.get("ftyf")
							+ "' where id = '" + String.valueOf(m.get("dtid")) + "'";
					log.writeLog(updateSql);
					flag = uprs.executeSql(updateSql);
					if (!flag) {
						log.writeLog("执行明细表数据id" + String.valueOf(m.get("dtid")) + "错误");
						break;
					}
				}
			}
			if (flag) {
				shortList(zxjhh, lx);
			} else {
				log.writeLog("调用暂估单页面错误！");
				return;
			}

			log.writeLog("end");
		} catch (Exception e) {
			// TODO: handle exception
			log.writeLog("fail" + e);
			e.printStackTrace();

		}
	}

	public static void shortList(String zxjhh, String lx) {
		/**
		 *
		 * @author jisuqiang
		 * @date 2017-12-08
		 */

		BaseBean log = new BaseBean();
		log.writeLog("调用SHORT_LIST.jsp开始");

		try {
			if ("".equals(zxjhh) || "".equals(lx)) {
				log.writeLog("装卸计划号为空，或者类型为空");
				return;
			}

			String tablename = "";
			String dtname = "";
			String djlx = "0";// 单据类型 SO/PO/非sap
			if ("0".equals(lx)) {
				// SO
				tablename = "formtable_main_45";
				djlx = "0";
			} else if ("1".equals(lx)) {
				// po
				tablename = "formtable_main_61";
				djlx = "1";
			} else {
				log.writeLog("分配错误");
				return;
			}
			log.writeLog("zxjhh = " + zxjhh + ", lx = " + lx + ",表名 = " + tablename);

			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet dtrs = new RecordSet();
			RecordSet inrs = new RecordSet();

			Date date = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
			String currentdate = format.format(date);// 当前日期

			SimpleDateFormat format1 = new SimpleDateFormat("yyyyMMdd");
			String currentdate1 = format1.format(date);// 当前日期
			// 主表数据
			String sfyg = "";// 是否有柜
			String id = "";// 主表id
			String requestid = "";// 请求Id

			// 建模表主数据
			String jmid = "";// 建模主表id
			String feename = "1";// 费用名称
			String djstatus = "0";// 单据状态 已审核/已上传/已对账/已清账/已作废
			String djtitle = currentdate + "运费";// 单据抬头
			String zxplanno = zxjhh;// 装卸计划单号
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
			// String taxcode = "";//销售税代码
			String costcenter = "";// 成本中心
			String pono = "";// 订单号
			String orderitem = "";// 订单行项目
			String itemtext = "";// 项目文本
			String wlh = "";// 物料号
			String zl = "";// 分摊重量
			String khdz = "";// 客户地址

			List<Map<String, String>> list = new ArrayList<Map<String, String>>();
			Map<String, String> mainMap = new HashMap<String, String>();
			if ("0".equals(lx) || "1".equals(lx)) {
				String sql = "select * from " + tablename + " where zxjhh = '" + zxjhh + "'";
				log.writeLog("查询主表Sql:" + sql);
				if (rs.execute(sql)) {
					if (rs.next()) {
						// 主表数据
						requestid = Util.null2String(rs.getString("requestid"));// 请求Id
						comname = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".comname")));// 公司名称
						comcode = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".comcode")));// 公司代码
						carno = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".carnos")));// 车牌
						dw = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".dw")));// 吨位
						cysname = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cysname")));// 承运商名称
						cyscode = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cyscode")));// 承运商简码
						creditpsn = Util
								.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".creditpsn")));// 申请人
						cx = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cx")));// 车型
						// djlx = "1";//单据类型

						sfyg = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".sfyg")));// 是否有柜
						id = Util.null2String(rs.getString("id"));// 主表id
						log.writeLog("调用存储过程CREATE_ZGDLS");
						rs1.executeProc("CREATE_ZGDLS", "");
						if (rs1.next()) {
							djbh = comcode + "FYZG" + currentdate1.substring(2, 6) + formatString(rs1.getInt(1));
						}
						log.writeLog("requestid:" + requestid);// 请求Id
						log.writeLog("feename:" + feename);// 费用名称
						log.writeLog("djtitle:" + djtitle);// 单据抬头
						log.writeLog("djstatus:" + djstatus);// 单据状态
						log.writeLog("zxplanno:" + zxplanno);// 装卸计划单号
						log.writeLog("comname:" + comname);// 公司名称
						log.writeLog("comcode:" + comcode);// 公司代码
						log.writeLog("hbkpyz:" + hbkpyz);// 合并开票原则
						log.writeLog("pztype:" + pztype);// 凭证类型
						log.writeLog("currency:" + currency);// 货币码
						log.writeLog("carno:" + carno);// 车牌号码
						log.writeLog("dw:" + dw);// 吨位
						log.writeLog("notaxamt:" + notaxamt);// 未税金额
						log.writeLog("amount:" + amount);// 暂估金额
						log.writeLog("zgfylx:" + zgfylx);// 暂估费用类型
						log.writeLog("credate:" + credate);// 创建日期
						log.writeLog("cysname:" + cysname);// 承运商名称
						log.writeLog("cyscode:" + cyscode);// 承运商代码
						log.writeLog("creditpsn:" + creditpsn);// 制单人
						log.writeLog("creditdate:" + creditdate);// 凭证日期
						log.writeLog("remark:" + remark);// 备注
						log.writeLog("djbh:" + djbh);// 单据编号
						log.writeLog("djlx:" + djlx);// 单据类型
						log.writeLog("hl:" + hl);// 汇率
						log.writeLog("sfyg:" + sfyg);// 是否有柜
						log.writeLog("id:" + id);// 主表Id
						log.writeLog("fylx:" + fylx);// 费用类型
						log.writeLog("cx:" + cx);// 车型
						log.writeLog("sz:" + sz);// 税则

						mainMap.put("requestid", requestid);// 请求id
						mainMap.put("feename", feename);// 费用名称
						mainMap.put("djtitle", djtitle);// 单据抬头
						mainMap.put("djstatus", djstatus);// 单据状态
						mainMap.put("zxplanno", zxplanno);// 装卸计划单号
						mainMap.put("comname", comname);// 公司名称
						mainMap.put("comcode", comcode);// 公司代码
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
						mainMap.put("fylx", fylx);// 费用类型
						mainMap.put("cx", cx);// 车型
						mainMap.put("sz", sz);// 税则
					} else {
						log.writeLog("主表没有数据返回");
						return;
					}
				} else {
					log.writeLog("查询主表数据错误");
					return;
				}
				if ("0".equals(lx)) {
					if (!"".equals(sfyg) && "0".equals(sfyg)) {
						dtname = "formtable_main_45_dt3";
					} else if (!"".equals(sfyg) && "1".equals(sfyg)) {
						dtname = "formtable_main_45_dt2";
					} else {
						log.writeLog("是否有柜值为空，执行错误返回");
						return;
					}
				} else if ("1".equals(lx)) {
					if (!"".equals(sfyg) && "0".equals(sfyg)) {
						dtname = "formtable_main_61_dt2";
					} else if (!"".equals(sfyg) && "1".equals(sfyg)) {
						dtname = "formtable_main_61_dt1";
					} else {
						log.writeLog("是否有柜值为空，执行错误返回");
						return;
					}
				}

				String dtsql = "select * from " + dtname + " where mainid = '" + id + "'";
				log.writeLog("调用明细sql:" + dtsql);

				if (dtrs.execute(dtsql)) {
					while (dtrs.next()) {
						Map<String, String> map = new HashMap<String, String>();
						dtnotaxamt = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".fee")));// 分摊费用
						costcenter = Util
								.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".costcenter")));// 成本中心
						pono = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".no")));// 订单号
						orderitem = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".item")));// 订单行项目
						wlh = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".wlh")));// 物料号
						zl = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".ftzl")));// 重量
						khdz = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".shiptoaddr")));// 客户地址
						itemtext = "";// TODO 项目文本

						dtnotaxamt = dtnotaxamt == "" ? "0.00" : dtnotaxamt;
						sum = sum + Double.parseDouble(dtnotaxamt);

						map.put("jzdm", jzdm);// 记帐代码
						map.put("account", account);// 科目
						map.put("dtnotaxamt", dtnotaxamt);// 分摊费用
						map.put("costcenter", costcenter);// 成本中心
						map.put("pono", pono);// 订单号
						map.put("orderitem", orderitem);// 订单行项目
						map.put("wlh", wlh);// 物料号
						map.put("itemtext", itemtext);// 项目文本
						map.put("zl", zl);// 重量
						map.put("khdz", khdz);// 客户地址
						map.put("ddlx", lx);// 订单类型

						list.add(map);
					}
				} else {
					log.writeLog("明细数据错误");
					return;
				}
			} else {
				// TODO
				// 非SAP
				return;
			}
			double total = 0.00;
			boolean flag = false;
			if (list.size() > 0 && mainMap.size() > 0) {
				StringBuffer buffer = new StringBuffer();
				buffer.append(
						"Insert into UF_ZGFY (REQUESTID,feename,djtitle,djstatus,zxplanno,comcode,comname,hbkpyz,pztype,currency,carno,dw,notaxamt,amount,zgfylx,credate,cysname,cyscode,creditpsn,creditdate,remark,djbh,djlx,fylx,cx,sz,FORMMODEID,hl) values (");
				buffer.append("'").append(mainMap.get("requestid")).append("',");// 费用名称
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
				buffer.append("'").append(sum).append("',");// 未税金额
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
				buffer.append("'").append(mainMap.get("hl")).append("')");// 汇率、
				log.writeLog("插入建模主表的sql:" + buffer.toString());

				if (inrs.executeSql(buffer.toString())) {
					String sql = "select id from UF_ZGFY where djbh = '" + mainMap.get("djbh") + "'";

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
								return;
							}
						}
					}
				} else {
					log.writeLog("插入明细主表失败");
					return;
				}
			} else {
				log.writeLog("没有获取数据，插入失败");
				return;
			}

		} catch (Exception e) {
			// TODO: handle exception
			log.writeLog("fail" + e);
			e.printStackTrace();

		}
	}

	public static String formatString(int input) {
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

	public static Double add(double v1, double v2) {
		// 计算净重的绝对值
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
		return b1.add(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public static Double calculateJZ(double v1, double v2) {
		// 计算净重的绝对值
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
		return b1.subtract(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public static Double mul(double v1, double v2) {
		// 计算乘法
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

		return b1.multiply(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}

	public static Double div(double v1, double v2) {
		// 计算除法
		BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
		BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

		return b1.divide(b2, 2, BigDecimal.ROUND_HALF_UP).doubleValue();
	}
}