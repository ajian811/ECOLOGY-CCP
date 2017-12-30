<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@page import="java.math.BigDecimal"%>
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
<%@page import="java.text.DecimalFormat"%>

<%@page
        import="com.weaver.integration.datesource.SAPInterationDateSourceImpl;"%>

<%
    /**
     *
     * @author jisuqiang
     * @date 2017-12-06
     */
    BaseBean log = new BaseBean();
    log.writeLog("调用CALC_MAINYF.jsp开始");

    try {
        String zxjhh = request.getParameter("zxjhh");//装卸计划号
        String lx = request.getParameter("lx");//类型 0 so 1 po
        if ("".equals(zxjhh) || "".equals(lx)) {
            log.writeLog("装卸计划号为空，或者类型为空");
            return;
        }
        log.writeLog("zxjhh = " + zxjhh + ", lx = " + lx);
        String dtname1 = "";
        String dtname2 = "";
        String fieldname = "";
        if ("0".equals(lx)) {
            //SO
            dtname1 = "formtable_main_45_dt2";
            dtname2 = "formtable_main_45_dt3";
            fieldname = "ftfy";
        } else if ("1".equals(lx)) {
            //po
            dtname1 = "formtable_main_61_dt1";
            dtname2 = "formtable_main_61_dt2";
            fieldname = "fee";
        } else {
            log.writeLog("分配错误");
            return;
        }

        String jfms = "";//计费模式 0包车 1配载 2计件 3 byweight（kg） 4 byweight（T） 5 bytrip（km）
        double gbzl = 0.00;//过磅重量（总净重）
        double jgd = 0.00;//价格档（单价）
        double lc = 0.00;//里程
        double mainPrice = 0.00;//一般运费
        String sfyg = "";//是否有柜  1 有柜 2无柜
        double cuont = 0.00;//计件数
        double total = 0.00;//总运费
        double flxzj = 0.00;//辅线路运费
        double tczyf = 0.00;//同城费用

        RecordSet rs = new RecordSet();
        RecordSet rs1 = new RecordSet();
        RecordSet dtrs = new RecordSet();
        RecordSet uprs = new RecordSet();

        List<Map<String, Double>> list = new ArrayList<Map<String, Double>>();

        if ("0".equals(lx)) {
            log.writeLog("进入so分摊运费");

            /*
             *类型算主线路运费：
             *包车： 直接取单价
             *计件（按个数）： 单价*计件数量
             *按重量计算（按吨的话）： 单价*过磅重量（KG）/1000
             *按重量计算（按KG的话）： 单价*过磅重量（KG）
             *配载（按重量和里程, 每吨每KM多少钱）：主路线的到达城市点的里程数（KM）*(过磅重量（KG）/1000)*单价
             */

            //DecimalFormat df = new DecimalFormat("#");

            String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "'";
            log.writeLog("查询主表Sql:" + sql);
            if (rs.execute(sql)) {
                if (rs.next()) {
                    jfms = Util.null2String(rs.getString("jfms"));//计费模式
                    gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");//过磅重量
                    jgd = rs.getDouble("jgd") == -1.0 ? 0.00 : rs.getDouble("jgd");//价格档（单价）
                    lc = rs.getDouble("id") == -1.0 ? 0.00 : rs.getDouble("id");//里程
                    tczyf = rs.getDouble("tczyf") == -1.0 ? 0.00 : rs.getDouble("tczyf");//同城费用
                    flxzj = rs.getDouble("flxzj") == -1.0 ? 0.00 : rs.getDouble("flxzj");//辅线路费用
                    sfyg = rs.getString("sfyg");//是否有柜

                    if ("0".equals(jfms)) {//包车
                        mainPrice = jgd;
                    } else if ("1".equals(jfms)) {//配载
                        mainPrice = mul(mul(lc, div(gbzl, 1000)), gbzl);
                    } else if ("2".equals(jfms)) {
                        //TODO
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
                        //byweight（kg）
                        mainPrice = mul(jgd, gbzl);
                    } else if ("4".equals(jfms)) {
                        mainPrice = div(mul(jgd, gbzl), 1000);
                    } else if ("5".equals(jfms)) {
                        //5 bytrip（km）
                        mainPrice = mul(lc, mul(div(gbzl, 1000), jgd));
                    } else {
                        mainPrice = 0.00;
                    }
                }
            } else {
                log.writeLog("数据库查询错误");
            }

            //总运费计算公式：总运费=一般运费+同城加价单价*同城个数+辅线路的所有运费
            total = mainPrice + tczyf + flxzj;
            log.writeLog("计算出的总运费:" + total);
            log.writeLog("sfyg:" + sfyg);
            double zqz = 0.00;//总权重
            double dtlc = 0.00;//明细里程
            double sjftjz = 0.00;//实际分摊净重
            double dtid = 0;//明细表id
            //总权重计算 = ∑各产品明细的送达城市点的里程数*实际分摊净重
            //List<Map<String, Double>> list = new ArrayList<Map<String, Double>>();

            if (total > 0 && "1".equals(sfyg)) {
                //有柜情况下计算 	总权重
                String dtsql = "select t2.* from formtable_main_45 t1";
                dtsql += " left join formtable_main_45_dt2 t2 on t1.id = t2.mainid";
                dtsql += " where t1.zxjhh = '" + zxjhh + "'";
                dtsql += " order by t2.id";
                if (dtrs.execute(dtsql)) {
                    while (dtrs.next()) {
                        Map<String, Double> map = new HashMap<String, Double>();
                        dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");//里程
                        sjftjz = dtrs.getDouble("sjftjz") == -1.0 ? 0.00 : dtrs.getDouble("sjftjz");//实际分摊净重
                        zqz += mul(dtlc, sjftjz);//总权重
                        dtid = Double.parseDouble(dtrs.getString("id"));//明细数据Id

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
                        dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");//里程
                        sjftjz = dtrs.getDouble("sjftjz") == -1.0 ? 0.00 : dtrs.getDouble("sjftjz");//实际分摊净重
                        zqz += mul(dtlc, sjftjz);
                        dtid = Double.parseDouble(dtrs.getString("id"));//明细数据Id

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
            //DecimalFormat df = new DecimalFormat("#");

            String sql = "select * from formtable_main_61 where zxjhh = '" + zxjhh + "'";
            log.writeLog("查询主表Sql:" + sql);
            if (rs.execute(sql)) {
                if (rs.next()) {
                    jfms = Util.null2String(rs.getString("jfms"));//计费模式
                    gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");//过磅重量
                    jgd = rs.getDouble("jgd") == -1.0 ? 0.00 : rs.getDouble("jgd");//价格档（单价）
                    lc = rs.getDouble("lc") == -1.0 ? 0.00 : rs.getDouble("lc");//里程
                    tczyf = rs.getDouble("tczyf") == -1.0 ? 0.00 : rs.getDouble("tczyf");//同城费用
                    flxzj = rs.getDouble("flxzj") == -1.0 ? 0.00 : rs.getDouble("flxzj");//辅线路费用
                    sfyg = rs.getString("sfyg");//是否有柜

                    if ("0".equals(jfms)) {//包车
                        mainPrice = jgd;
                    } else if ("1".equals(jfms)) {//配载
                        mainPrice = mul(mul(lc, div(gbzl, 1000)), gbzl);
                    } else if ("2".equals(jfms)) {
                        //TODO
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
                        //byweight（kg）
                        mainPrice = mul(jgd, gbzl);
                    } else if ("4".equals(jfms)) {
                        mainPrice = div(mul(jgd, gbzl), 1000);
                    } else if ("5".equals(jfms)) {
                        //5 bytrip（km）
                        mainPrice = mul(lc, mul(div(gbzl, 1000), jgd));
                    } else {
                        mainPrice = 0.00;
                    }
                }
            } else {
                log.writeLog("数据库查询错误");
            }

            //总运费计算公式：总运费=一般运费+同城加价单价*同城个数+辅线路的所有运费
            total = mainPrice + tczyf + flxzj;
            log.writeLog("计算出的总运费:" + total);
            log.writeLog("sfyg:" + sfyg);
            double zqz = 0.00;//总权重
            double dtlc = 0.00;//明细里程
            double sjftjz = 0.00;//实际分摊净重
            double dtid = 0;//明细表id
            //总权重计算 = ∑各产品明细的送达城市点的里程数*实际分摊净重

            if (total > 0 && "1".equals(sfyg)) {
                //有柜情况下计算 	总权重
                String dtsql = "select t2.* from formtable_main_61 t1";
                dtsql += " left join formtable_main_61_dt1 t2 on t1.id = t2.mainid";
                dtsql += " where t1.zxjhh = '" + zxjhh + "'";
                dtsql += " order by t2.id";
                if (dtrs.execute(dtsql)) {
                    while (dtrs.next()) {
                        Map<String, Double> map = new HashMap<String, Double>();
                        dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");//里程
                        sjftjz = dtrs.getDouble("ftzl") == -1.0 ? 0.00 : dtrs.getDouble("ftzl");//实际分摊净重
                        zqz += mul(dtlc, sjftjz);//总权重
                        dtid = Double.parseDouble(dtrs.getString("id"));//明细数据Id

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
                        dtlc = dtrs.getDouble("lc") == -1.0 ? 0.00 : dtrs.getDouble("lc");//里程
                        sjftjz = dtrs.getDouble("ftzl") == -1.0 ? 0.00 : dtrs.getDouble("ftzl");//实际分摊净重
                        zqz += mul(dtlc, sjftjz);
                        dtid = Double.parseDouble(dtrs.getString("id"));//明细数据Id

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

        //各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
		/*
		*各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
		   假设有n行明细：
		   第1~n-1行：
		  产品明细的分摊运费 =产品明细的权重比例*总运费, 保留2位小数，四舍五入
		   第n行：
		  产品明细的分摊运费 =总运费-∑第1~n-1行产品明细的分摊运费
		  如果计算出来第n行的分摊运费=0或者小于0， 则第n行的运费强制改为0.01，然后将差的金额调整到上一行；如果调整后上一行金额=0，则还要强制改为0.01，再将差的金额调到上上一行，依次类推。
		*/

        if (list.size() <= 0) {
            log.writeLog("数据获取失败，list中没有数据");
            return;
        }

        double totalFtyf = 0.00;//总分摊运费
        for (int i = 0; i < list.size() - 1; i++) {
            double qzbl = div(mul(list.get(i).get("dtlc"), list.get(i).get("sjftjz")),
                    list.get(list.size() - 1).get("zqz"));
            double ftyf = mul(qzbl, list.get(i).get("total"));
            log.writeLog("权重比例：" + qzbl + ",ftyf: " + ftyf);
            list.get(i).put("ftyf", ftyf);
            totalFtyf += ftyf;//1~n-1之前的分摊运费的和
        }
        log.writeLog("1~n-1之前的分摊运费的和,totalFtyf:" + totalFtyf);
        //第N行分摊运费
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

        //打印log
        for (Map<String, Double> m : list) {
            log.writeLog("--------------");
            for (String k : m.keySet()) {
                log.writeLog(k + " : " + m.get(k));
            }
        }
        boolean flag = false;
        if ("1".equals(sfyg)) {

            //打印log
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
            //打印log
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
            request.getRequestDispatcher("/weightJsp/SHORT_LIST.jsp?zxjhh=" + zxjhh + "&lx=" + lx)
                    .forward(request, response);
        } else {
            log.writeLog("调用暂估单页面错误！");
            return;
        }

        out.print("end");
    } catch (Exception e) {
        // TODO: handle exception
        out.write("fail" + e);
        e.printStackTrace();

    }
%>
<%!public Double add(double v1, double v2) {
    //计算净重的绝对值
    BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
    BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
    return b1.add(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
}%>
<%!public Double calculateJZ(double v1, double v2) {
    //计算净重的绝对值
    BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
    BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
    return b1.subtract(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
}%>
<%!public Double mul(double v1, double v2) {
    //计算乘法
    BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
    BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

    return b1.multiply(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
}%>
<%!public Double div(double v1, double v2) {
    //计算除法
    BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
    BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

    return b1.divide(b2, 2, BigDecimal.ROUND_HALF_UP).doubleValue();
}%>



