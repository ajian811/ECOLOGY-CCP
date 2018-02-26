<%@page import="javax.servlet.jsp.tagext.TryCatchFinally" %>
<%@page import="java.math.BigDecimal" %>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@page import="com.weaver.integration.log.LogInfo" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.SQLException" %>
<%@page import="java.sql.Statement" %>
<%@page import="weaver.general.StaticObj" %>
<%@page import="weaver.interfaces.datasource.DataSource" %>
<%@page import="java.sql.Connection" %>
<%@page import="weaver.general.Util" %>
>
<%@page import="weaver.conn.RecordSet" %>
<%@page import="com.weaver.integration.log.LogInfo" %>
<%@page import="com.sap.mw.jco.IFunctionTemplate" %>
<%@page import="weaver.general.BaseBean" %>
<%@page import="com.sap.mw.jco.JCO" %>
<%@page import="java.text.DecimalFormat" %>

<%@page
        import="com.weaver.integration.datesource.SAPInterationDateSourceImpl" %>

<%
    /**
     *
     * @author jisuqiang
     * @date 2017-12-07
     */
    BaseBean log = new BaseBean();

    log.writeLog("调用Apportionment_Weight.jsp开始");
    String zxjhh = request.getParameter("zxjhh");//装卸计划号
    String lx = request.getParameter("lx");//类型 0 so 1 po
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

        double zgz = 0.00;//总柜重量
        double bzclzzl = 0.00;//包装材料总重量
        double gbzl = 0.00;//过磅重量（总净重）
        double zhwjz = 0.00;//总货物净重
        String sfyg = "";//是否有柜
        String id = "";//主表id
        double jhlljz = 0.00;//计划理论净重
        double sjjz = 0.00;//实际净重
        String dtid = "";//明细表2的id
        double total = 0.00;//理论净重合计

        List<Map<String, String>> list = new ArrayList<Map<String, String>>();
        if ("0".equals(lx)) {
            log.writeLog("进入so分摊重量");

            /*
             *总货物净重计算，计算公式
             *总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
             */

            String sql = "select * from formtable_main_45 where zxjhh = '" + zxjhh + "'";
            log.writeLog("查询主表Sql:" + sql);
            if (rs.execute(sql)) {
                if (rs.next()) {
                    zgz = rs.getDouble("zgz") == -1.0 ? 0.00 : rs.getDouble("zgz");//总柜重量
                    bzclzzl = rs.getDouble("bzclzzl") == -1.0 ? 0.00 : rs.getDouble("bzclzzl");//包装材料总重量
                    gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");//过磅重量
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
                zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);//总货物净重
                log.writeLog("计算出的总货物净重:" + zhwjz);
                /*
                 *每条明细计划理论净重，计算公式
                 *（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
                 */
                if (zhwjz > 0) {
                    String dtSql = "select * from formtable_main_45_dt3 where mainid = '" + id + "'";
                    log.writeLog("查询明细表2sql:" + dtSql);
                    dtrs.execute(dtSql);

                    while (dtrs.next()) {
                        Map<String, String> map = new HashMap<String, String>();
                        String sl = dtrs.getString("sl");//数量
                        String jhyzl = dtrs.getString("jhyzl");//计划运载量
                        String jzl = dtrs.getString("jzl") == "" ? "0" : dtrs.getString("jzl");//净重量
                        dtid = dtrs.getString("id");//每条明细id

                        log.writeLog("sl " + sl);
                        log.writeLog("jhyzl " + jhyzl);
                        log.writeLog("jzl " + jzl);

                        jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));//(Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
                        total += jhlljz;
                        map.put("jhlljz", "" + jhlljz);
                        map.put("dtid", dtid);
                        list.add(map);
                    }
                }
            } else if ("0".equals(sfyg)) {
                //无柜情况
                zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);//Double.parseDouble(gbzl) - Double.parseDouble(zgz) - Double.parseDouble(bzclzzl);//总货物净重
                log.writeLog("计算出的总货物净重:" + zhwjz);
                /*
                 *每条明细计划理论净重，计算公式
                 *（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
                 */
                if (zhwjz > 0) {
                    String dtSql = "select * from formtable_main_45_dt3 where mainid = '" + id + "'";
                    log.writeLog("查询明细表3sql:" + dtSql);
                    dtrs.execute(dtSql);

                    //List<Map<String, String>> list = new ArrayList<Map<String, String>>();
                    while (dtrs.next()) {
                        Map<String, String> map = new HashMap<String, String>();
                        String sl = dtrs.getString("sl");//数量
                        String jhyzl = dtrs.getString("jhyzl");//计划运载量
                        String jzl = dtrs.getString("jzl");//净重量
                        dtid = dtrs.getString("id");//每条明细id

                        log.writeLog("sl " + sl);
                        log.writeLog("jhyzl " + jhyzl);
                        log.writeLog("jzl " + jzl);

                        jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)), Double.parseDouble(jhyzl));//(Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
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
                    zgz = 0.00;//柜重默认为0
                    bzclzzl = rs.getDouble("bzclzzl") == -1.0 ? 0.00 : rs.getDouble("bzclzzl");//包装材料总重量
                    gbzl = rs.getDouble("gbzl") == -1.0 ? 0.00 : rs.getDouble("gbzl");//过磅重量
                    sfyg = Util.null2String(rs.getString("sfyg"));//是否有柜
                    id = Util.null2String(rs.getString("id"));//主表id

                    log.writeLog("zgz " + zgz);
                    log.writeLog("bzclzzl " + bzclzzl);
                    log.writeLog("gbzl " + gbzl);

                } else {
                    log.writeLog("数据库查询错误");
                    return;
                }

                if ("1".equals(sfyg) && !"".equals(sfyg)) {
                    //有柜情况
                    /*
                     *总货物净重计算，计算公式
                     *总货物净重=总净重-对应柜号的柜子重量-货物包装材料的理论重量
                     */
                    zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);//总货物净重
                    log.writeLog("计算出的总货物净重:" + zhwjz);
                    /*
                     *每条明细计划理论净重，计算公式
                     *（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
                     */
                    if (zhwjz > 0) {
                        String dtSql = "select * from formtable_main_61_dt1 where mainid = '" + id + "'";
                        log.writeLog("查询明细表1sql:" + dtSql);
                        dtrs.execute(dtSql);

                        //List<Map<String, String>> list = new ArrayList<Map<String, String>>();
                        while (dtrs.next()) {
                            Map<String, String> map = new HashMap<String, String>();
                            String sl = dtrs.getString("sl");//数量
                            String jhyzl = dtrs.getString("jhyzl");//计划运载量
                            String jzl = dtrs.getString("jzl");//净重量
                            dtid = dtrs.getString("id");//每条明细id

                            log.writeLog("sl " + sl);
                            log.writeLog("jhyzl " + jhyzl);
                            log.writeLog("jzl " + jzl);

                            jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)),
                                    Double.parseDouble(jhyzl));//(Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
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
                    //无柜情况
                    zhwjz = calculateJZ(calculateJZ(gbzl, zgz), bzclzzl);//Double.parseDouble(gbzl) - Double.parseDouble(zgz) - Double.parseDouble(bzclzzl);//总货物净重
                    log.writeLog("计算出的总货物净重:" + zhwjz);
                    /*
                     *每条明细计划理论净重，计算公式
                     *（SAP交运单项次上的净重/SAP交运单项次上的实际交货数量）*计划运载量
                     */
                    if (zhwjz > 0) {
                        String dtSql = "select * from formtable_main_61_dt2 where mainid = '" + id + "'";
                        log.writeLog("查询明细表2sql:" + dtSql);
                        dtrs.execute(dtSql);

                        //List<Map<String, String>> list = new ArrayList<Map<String, String>>();
                        while (dtrs.next()) {
                            Map<String, String> map = new HashMap<String, String>();
                            String sl = dtrs.getString("sl");//数量
                            String jhyzl = dtrs.getString("jhyzl");//计划运载量
                            String jzl = dtrs.getString("jzl");//净重量
                            dtid = dtrs.getString("id");//每条明细id

                            log.writeLog("sl " + sl);
                            log.writeLog("jhyzl " + jhyzl);
                            log.writeLog("jzl " + jzl);

                            jhlljz = mul(div(Double.valueOf(jzl), Double.valueOf(sl)),
                                    Double.parseDouble(jhyzl));//(Double.parseDouble(jzl) / Double.parseDouble(sl)) * Double.parseDouble(jhyzl);//每条明细计划净重
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
            //SO
            if ("0".equals(sfyg)) {
                dtname = "formtable_main_45_dt3";
            } else {
                dtname = "formtable_main_45_dt3";
            }
            fieldname = "sjftjz";
        } else if ("1".equals(lx) && !"".equals(sfyg)) {
            //po

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
        log.writeLog(list.toString());

        for (int i = 0; i < list.size(); i++) {
            /*
             *明细的实际分摊净重，计算公式
             *（计划理论净重/计划理论净重合计）*过磅总货物净重
             */
            log.writeLog("jhlljz:" + jhlljz + ",total:" + total + ",zhwjz:" + zhwjz);
            sjjz = mul(div(Double.parseDouble(list.get(i).get("jhlljz")), total), zhwjz);
            log.writeLog("sjjz:" + sjjz);
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
            request.getRequestDispatcher("/weightJsp/CALC_MAINYF.jsp?zxjhh=" + zxjhh + "&lx=" + lx)
                    .forward(request, response);
        } else {
            log.writeLog("获取分摊运费页面错误");
            return;
        }
        //out.print("end");
    } catch (Exception e) {
        // TODO: handle exception
        out.write("fail" + e);
        e.printStackTrace();

    }
%>
<%!
    public Double add(double v1, double v2) {
        //计算净重的绝对值
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
        return b1.add(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
%>
<%!
    public Double calculateJZ(double v1, double v2) {
        //计算净重的绝对值
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
        return b1.subtract(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
%>
<%!
    public Double mul(double v1, double v2) {
        //计算乘法
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

        return b1.multiply(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
%>
<%!
    public Double div(double v1, double v2) {
        //计算除法
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

        return b1.divide(b2, 2, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
%>


