<%@page import="java.math.BigDecimal"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="weaver.general.StaticObj"%>
<%@page import="weaver.interfaces.datasource.DataSource"%>
<%@page import="java.sql.Connection"%>
<%@page import="weaver.general.Util"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="weaver.file.Prop"%>
<%@page import="net.sf.json.JSONObject"%>
<jsp:useBean id="log" class="weaver.general.BaseBean" scope="page" ></jsp:useBean>

<%@ include file="/systeminfo/init_wev8.jsp" %><!--引入系统页面，用于判断是否登录，以及获取user对象-->
<%@ page import="weaver.formmode.setup.ModeRightInfo" %>
<%@ page import="weaver.general.BaseBean" %>

<%
    /**
     *
     * @author jisuqiang
     * @date 2017-12-08
     */
    int userid=user.getUID();


    String config_wf = "CCP_ZGD";// 暂估单
    log.writeLog("调用SHORT_LIST.jsp开始");
    log.writeLog("获得uid："+userid);
    try {
        String zxjhh = request.getParameter("zxjhh");//装卸计划号
        String lx = request.getParameter("lx");//类型 0 so 1 po
        String type=request.getParameter("type");//type 1--需要进行费用重算
        if ("".equals(zxjhh) || "".equals(lx)) {
            log.writeLog("装卸计划号为空，或者类型为空");
            return;
        }

        String dtname1 = "";
        String dtname2 = "";
        String fieldname = "";
        String tablename = "";
        String dtname = "";
        String djlx = "0";//单据类型   SO/PO/非sap
        if ("0".equals(lx)) {
            //SO
            tablename = "formtable_main_45";
            djlx = "0";
        } else if ("1".equals(lx)) {
            //po
            tablename = "formtable_main_61";
            djlx = "1";
        }else if ("2".equals(lx)) {
            //po
            tablename = "uf_fsapzxjh";
            djlx = "2";
        }
        else {
            log.writeLog("分配错误");
            return;
        }
        log.writeLog("zxjhh = " + zxjhh + ", lx = " + lx + ",表名 = " + tablename);

        RecordSet rs = new RecordSet();
        RecordSet rs1 = new RecordSet();
        RecordSet dtrs = new RecordSet();
        RecordSet inrs = new RecordSet();
        RecordSet ckrs = new RecordSet();
        JSONObject jsonObject = new JSONObject();

        String currentdate="";
        String currentdate1="";
        String currentdate0="";

        Date date = new Date();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM");

        SimpleDateFormat format2=new SimpleDateFormat("yyyy-MM-dd");


            currentdate0 = format2.format(date);//当前日期

            currentdate = format.format(date);//当前日期



        SimpleDateFormat format1 = new SimpleDateFormat("yyyyMMdd");

            currentdate1=format1.format(date);

            //currentdate0 = format1.format(date);//当前日期

        //主表数据
        String sfyg = "";//是否有柜
        String id = "";//主表id
        String requestid = "";//请求Id

        //建模表主数据
        String jmid = "";//建模主表id
        String feename = "1";//费用名称
        String djstatus = "0";//单据状态   已审核/已上传/已对账/已清账/已作废

        String djttlx="";
        String shipno="";

        //SO情况的单据抬头文本需要去eweaver数据源查询
        if ("0".equals(lx)) {
            //根据类型及装卸计划号获取明细的第一个shipno
            shipno = getShipNO(zxjhh);
            //根据shipno连接eweaer数据源获取抬头文本
            if (!"".equals(shipno)) {
                djttlx = getDjttlx(shipno);
            }
        } else{
            //其他情况的抬头文本固定为"Transport Fee"
            djttlx="Transport Fee";
        }

        String djtitle =djttlx+" "+ currentdate;//单据抬头

        String zxplanno = zxjhh;//装卸计划单号
        String comname = "";//公司名称
        String comcode = "";//公司代码
        String hbkpyz = "";//合并开票原则  //明细获取
        String pztype = "SA";//凭证类型
        String currency = "MYR";//货币码
        String carno = "";//车牌号码
        String dw = "";//吨位
        String notaxamt = "";//未税金额    明细合计
        String amount = "";//暂估金额
        String zgfylx = "1";//暂估费用类型   异常费用/正常费用
        String credate = currentdate0;//创建日期
        String cysname = "";//承运商名称
        String cyscode = "";//承运商代码
        String creditpsn = "";//制单人
        String remark = "";//备注
        String djbh = "";//单据编号    公司代码+FYZG+201701+3流水

        String hl = "1";//汇率   默认为1
        String creditdate = currentdate0;//凭证日期
        String fylx = "1";//费用类型   1运费2吊柜费3装柜劳务费4柜费
        String cx = "";//车型
        String sz = "1";//税则 默认为1
        double sum = 0.00;

        //建模表明细数据
        String jzdm = "40";//记帐代码
        String account = "55060600";//科目
        String dtnotaxamt = "";//未税金额
        String taxcode = "";//销售税代码
        String costcenter = "";//成本中心
        String pono = "";//订单号
        String orderitem = "";//订单行项目
        String itemtext = djtitle;//项目文本
        String wlh = "";//物料号
        String zl = "";//分摊重量
        String khdz = "";//客户地址

        List<Map<String, String>> list = new ArrayList<Map<String, String>>();
        Map<String, String> mainMap = new HashMap<String, String>();
        if ("0".equals(lx) || "1".equals(lx)||"2".equals(lx)) {
            String sql = "select * from " + tablename + " where zxjhh = '" + zxjhh + "'";
            if("0".equals(lx)){
                sql+=" and requestid is null";
            }
            log.writeLog("查询主表Sql:" + sql);
            if (rs.execute(sql)) {
                if (rs.next()) {
                    //主表数据
                    requestid = Util.null2String(rs.getString("requestid"));//请求Id
                    comname = Util
                            .null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".comname")));//公司名称
                    comcode = Util
                            .null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".comcode")));//公司代码
                    carno = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".carnos")));//车牌
                    dw = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".dw")));//吨位
                    cysname = Util
                            .null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cysname")));//承运商名称
                    cyscode = Util
                            .null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cyscode")));//承运商简码
                    creditpsn = Util
                            .null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".creditpsn")));//申请人
                    cx = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".cx")));//车型
                    //djlx = "1";//单据类型

                    sfyg = Util.null2String(rs.getString(Prop.getPropValue(config_wf, tablename + ".sfyg")));//是否有柜
                    id = Util.null2String(rs.getString("id"));//主表id
                    log.writeLog("调用存储过程CREATE_ZGDLS");
                    rs1.executeProc("CREATE_ZGDLS", "");
                    if (rs1.next()) {
                        djbh = comcode + "FYZG" + currentdate1.substring(2, 6) + formatString(rs1.getInt(1));
                    }
                    log.writeLog("requestid:" + requestid);//请求Id
                    log.writeLog("feename:" + feename);//费用名称
                    log.writeLog("djtitle:" + djtitle);//单据抬头
                    log.writeLog("djstatus:" + djstatus);//单据状态
                    log.writeLog("zxplanno:" + zxplanno);//装卸计划单号
                    log.writeLog("comname:" + comname);//公司名称
                    log.writeLog("comcode:" + comcode);//公司代码
                    log.writeLog("hbkpyz:" + hbkpyz);//合并开票原则
                    log.writeLog("pztype:" + pztype);//凭证类型
                    log.writeLog("currency:" + currency);//货币码
                    log.writeLog("carno:" + carno);//车牌号码
                    log.writeLog("dw:" + dw);//吨位
                    log.writeLog("notaxamt:" + notaxamt);//未税金额
                    log.writeLog("amount:" + amount);//暂估金额
                    log.writeLog("zgfylx:" + zgfylx);//暂估费用类型
                    log.writeLog("credate:" + credate);//创建日期
                    log.writeLog("cysname:" + cysname);//承运商名称
                    log.writeLog("cyscode:" + cyscode);//承运商代码
                    log.writeLog("creditpsn:" + creditpsn);//制单人
                    log.writeLog("creditdate:" + creditdate);//凭证日期
                    log.writeLog("remark:" + remark);//备注
                    log.writeLog("djbh:" + djbh);//单据编号
                    log.writeLog("djlx:" + djlx);//单据类型
                    log.writeLog("hl:" + hl);//汇率
                    log.writeLog("sfyg:" + sfyg);//是否有柜
                    log.writeLog("id:" + id);//主表Id
                    log.writeLog("fylx:" + fylx);//费用类型
                    log.writeLog("cx:" + cx);//车型
                    log.writeLog("sz:" + sz);//税则

                    mainMap.put("requestid", requestid);//请求id
                    mainMap.put("feename", feename);//费用名称
                    mainMap.put("djtitle", djtitle);//单据抬头
                    mainMap.put("djstatus", djstatus);//单据状态
                    mainMap.put("zxplanno", zxplanno);//装卸计划单号
                    mainMap.put("comname", comname);//公司名称
                    mainMap.put("comcode", comcode);//公司代码
                    mainMap.put("hbkpyz", hbkpyz);//合并开票原则
                    mainMap.put("pztype", pztype);//凭证类型
                    mainMap.put("currency", currency);//货币码
                    mainMap.put("carno", carno);//车牌号码
                    mainMap.put("dw", dw);//吨位
                    mainMap.put("notaxamt", notaxamt);//未税金额
                    mainMap.put("amount", amount);//暂估金额
                    mainMap.put("zgfylx", zgfylx);//暂估费用类型
                    mainMap.put("credate", credate);//创建日期
                    mainMap.put("cysname", cysname);//承运商名称
                    mainMap.put("cyscode", cyscode);//承运商代码
                    mainMap.put("creditpsn", creditpsn);//制单人
                    mainMap.put("creditdate", creditdate);//凭证日期
                    mainMap.put("remark", remark);//备注
                    mainMap.put("djbh", djbh);//单据编号
                    mainMap.put("djlx", djlx);//单据类型
                    mainMap.put("hl", hl);//汇率
                    mainMap.put("fylx", fylx);//费用类型
                    mainMap.put("cx", cx);//车型
                    mainMap.put("sz", sz);//税则
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
                    dtname = "formtable_main_45_dt3";
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
            }else if ("2".equals(lx)) {

                    dtname = "uf_fsapzxjh_dt1";

            }

            String dtsql = "select * from " + dtname + " where mainid = '" + id + "'";
            log.writeLog("调用明细sql:" + dtsql);

            if (dtrs.execute(dtsql)) {
                while (dtrs.next()) {
                    Map<String, String> map = new HashMap<String, String>();
                    dtnotaxamt = Util
                            .null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".fee")));//分摊费用
                    costcenter = Util
                            .null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".costcenter")));//成本中心
                    if (!"2".equals(lx)) {
                        pono = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".no")));//订单号
                        orderitem = Util
                                .null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".item")));//订单行项目
                        wlh = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".wlh")));//物料号
                    }
                    zl = Util.null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".ftzl")));//重量
                    khdz = Util
                            .null2String(dtrs.getString(Prop.getPropValue(config_wf, dtname + ".shiptoaddr")));//客户地址
                    //itemtext = "";


                    dtnotaxamt = dtnotaxamt == "" ? "0.00" : dtnotaxamt;
                    sum = sum + Double.parseDouble(dtnotaxamt);

                    map.put("jzdm", jzdm);//记帐代码
                    map.put("account", account);//科目
                    map.put("dtnotaxamt", dtnotaxamt);//分摊费用
                    map.put("costcenter", costcenter);//成本中心
                    map.put("pono", pono);//订单号
                    map.put("orderitem", orderitem);//订单行项目
                    map.put("wlh", wlh);//物料号
                    map.put("itemtext", itemtext);//项目文本
                    map.put("zl", zl);//重量
                    map.put("khdz", khdz);//客户地址
                    map.put("ddlx", lx);//订单类型

                    list.add(map);
                }
            } else {
                log.writeLog("明细数据错误");
                return;
            }
        } else {
            //TODO
            //非SAP
            return;
        }
        double total = 0.00;
        boolean flag = false;
        if (list.size() > 0 && mainMap.size() > 0) {
            /**
             * 如果已生成有效暂估单，则进行更新
             */
            String sql="SELECT id,ZXPLANNO FROM UF_ZGFY WHERE DJSTATUS!='4' and ZXPLANNO='"+zxjhh+"'";
            rs.writeLog(">>>sql>>>"+sql+"<<<");
            rs.execute(sql);
            String billid="";
            if (rs.next()){
                billid=Util.null2String(rs.getString("id"));
            }
            if(!"".equals(billid)) {
                StringBuffer buffer0 = new StringBuffer();
                buffer0.append(
                        "update  UF_ZGFY set ");
                buffer0.append("REQUESTID='").append(mainMap.get("requestid")).append("',");//费用名称
                buffer0.append("feename='").append(mainMap.get("feename")).append("',");//费用名称
                buffer0.append("djtitle='").append(mainMap.get("djtitle")).append("',");//单据抬头
                buffer0.append("djstatus='").append(mainMap.get("djstatus")).append("',");//单据状态
                buffer0.append("zxplanno='").append(mainMap.get("zxplanno")).append("',");//装卸计划单号
                buffer0.append("comcode='").append(mainMap.get("comcode")).append("',");//公司名称
                buffer0.append("comname='").append(mainMap.get("comname")).append("',");//公司代码
                buffer0.append("hbkpyz='").append(mainMap.get("hbkpyz")).append("',");//合并开票原则
                buffer0.append("pztype='").append(mainMap.get("pztype")).append("',");//凭证类型
                buffer0.append("currency='").append(mainMap.get("currency")).append("',");//货币码
                buffer0.append("carno='").append(mainMap.get("carno")).append("',");//车牌号码
                buffer0.append("dw='").append(mainMap.get("dw")).append("',");//吨位
                buffer0.append("notaxamt='").append(sum).append("',");//未税金额
                buffer0.append("amount='").append(mainMap.get("amount")).append("',");//暂估金额
                buffer0.append("zgfylx='").append(mainMap.get("zgfylx")).append("',");//暂估费用类型
                buffer0.append("credate='").append(mainMap.get("credate")).append("',");//创建日期
                buffer0.append("cysname='").append(mainMap.get("cysname")).append("',");//承运商名称
                buffer0.append("cyscode='").append(mainMap.get("cyscode")).append("',");//承运商代码
                buffer0.append("creditpsn='").append(mainMap.get("creditpsn")).append("',");//制单人
                buffer0.append("creditdate='").append(mainMap.get("creditdate")).append("',");//凭证日期
                buffer0.append("remark='").append(mainMap.get("remark")).append("',");//备注
                buffer0.append("djbh='").append(mainMap.get("djbh")).append("',");//单据编号
                buffer0.append("djlx='").append(mainMap.get("djlx")).append("',");//单据类型
                buffer0.append("fylx='").append(mainMap.get("fylx")).append("',");//费用类型
                buffer0.append("cx='").append(mainMap.get("cx")).append("',");//车型
                buffer0.append("sz='").append(mainMap.get("sz")).append("',");//税则
                buffer0.append("FORMMODEID='").append("721").append("',");
                buffer0.append("hl='").append(mainMap.get("hl")).append("'");//汇率、
                buffer0.append(" where id="+billid);


                log.writeLog("更新建模主表的sql:" + buffer0.toString());

                inrs.executeSql(buffer0.toString());
                jsonObject.put("message", "暂估单已存在，UPDATESUCCESS");
                log.writeLog(jsonObject.toString());
                //out.print(jsonObject.toString());
                out.clear();
                out.write(jsonObject.toString());
                //System.out.println(jo.toString());
               out.flush();
               out.close();
                return;
            }


            StringBuffer buffer = new StringBuffer();
            buffer.append(
                    "Insert into UF_ZGFY (REQUESTID,feename,djtitle,djstatus,zxplanno,comcode,comname,hbkpyz,pztype,currency,carno,dw,notaxamt,amount,zgfylx,credate,cysname,cyscode,creditpsn,creditdate,remark,djbh,djlx,fylx,cx,sz,FORMMODEID,hl," +
                            "MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid) values (");
            buffer.append("'").append(mainMap.get("requestid")).append("',");//费用名称
            buffer.append("'").append(mainMap.get("feename")).append("',");//费用名称
            buffer.append("'").append(mainMap.get("djtitle")).append("',");//单据抬头
            buffer.append("'").append(mainMap.get("djstatus")).append("',");//单据状态
            buffer.append("'").append(mainMap.get("zxplanno")).append("',");//装卸计划单号
            buffer.append("'").append(mainMap.get("comcode")).append("',");//公司名称
            buffer.append("'").append(mainMap.get("comname")).append("',");//公司代码
            buffer.append("'").append(mainMap.get("hbkpyz")).append("',");//合并开票原则
            buffer.append("'").append(mainMap.get("pztype")).append("',");//凭证类型
            buffer.append("'").append(mainMap.get("currency")).append("',");//货币码
            buffer.append("'").append(mainMap.get("carno")).append("',");//车牌号码
            buffer.append("'").append(mainMap.get("dw")).append("',");//吨位
            buffer.append("'").append(sum).append("',");//未税金额
            buffer.append("'").append(mainMap.get("amount")).append("',");//暂估金额
            buffer.append("'").append(mainMap.get("zgfylx")).append("',");//暂估费用类型
            buffer.append("'").append(mainMap.get("credate")).append("',");//创建日期
            buffer.append("'").append(mainMap.get("cysname")).append("',");//承运商名称
            buffer.append("'").append(mainMap.get("cyscode")).append("',");//承运商代码
            buffer.append("'").append(mainMap.get("creditpsn")).append("',");//制单人
            buffer.append("'").append(mainMap.get("creditdate")).append("',");//凭证日期
            buffer.append("'").append(mainMap.get("remark")).append("',");//备注
            buffer.append("'").append(mainMap.get("djbh")).append("',");//单据编号
            buffer.append("'").append(mainMap.get("djlx")).append("',");//单据类型
            buffer.append("'").append(mainMap.get("fylx")).append("',");//费用类型
            buffer.append("'").append(mainMap.get("cx")).append("',");//车型
            buffer.append("'").append(mainMap.get("sz")).append("',");//税则
            buffer.append("'").append("721").append("',");
            buffer.append("'").append(mainMap.get("hl")).append("',");//汇率、

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
                sql = "select id from UF_ZGFY where djbh = '" + mainMap.get("djbh") + "'";
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
                String sqlx="select id from UF_ZGFY where modeuuid='"+str1+"'";
                log.writeLog(sqlx);
                rs1.execute(sqlx);
                String id0="";
                if(rs1.next()){
                    id0=Util.null2String(rs1.getString("id"));
                }
                ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
                localModeRightInfo1.setNewRight(true);
                localModeRightInfo1.editModeDataShare(userid, 721, Integer.parseInt(id0));




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
                                insertSql += "'" + list.get(i).get("dtnotaxamt") + "',";//未税金额
                                insertSql += "'" + list.get(i).get("costcenter") + "',";
                                insertSql += "'" + list.get(i).get("pono") + "',";
                                insertSql += "'" + list.get(i).get("orderitem") + "',";
                                insertSql += "'" + list.get(i).get("wlh") + "',";
                                insertSql += "'" + list.get(i).get("zl") + "',";
                                insertSql += "'" + list.get(i).get("khdz") + "',";
                                insertSql += "'" + list.get(i).get("ddlx") + "',";
                                insertSql += "'" + list.get(i).get("itemtext") + "')";

                                total += Double.parseDouble(list.get(i).get("dtnotaxamt"));//计算合计
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
                                    insertSql += "'" + total + "',";//未税金额
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
        //如果类型为1 需要跳转到REFRESH_ZGD.jsp 进行运费分摊
        if("1".equals(type)){
            String billids=jmid;
            request.getRequestDispatcher("/weightJsp/REFRESH_ZGD.jsp?billids=" + billids ).forward(request,response);

        }

        jsonObject.put("message", "SUCCESS");

        log.writeLog(jsonObject.toString());
        //out.print(jsonObject.toString());
        response.getWriter().write(jsonObject.toString());
        //System.out.println(jo.toString());
        response.getWriter().flush();
        response.getWriter().close();
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
<%!
    private String getShipNO(String zxjhh) {
        String sql="";
        String shipno="";
        sql="SELECT t2.SHIPPING FROM formtable_main_45 T1,FORMTABLE_MAIN_45_DT1 T2 WHERE t1.id=T2.mainid and T1.REQUESTID is null and t1.zxjhh='"+zxjhh+"'";
        RecordSet recordSet=new RecordSet();
        recordSet.writeLog(sql);
        recordSet.execute(sql);
        if (recordSet.next()){
            shipno= recordSet.getString("shipping");
        }
        return shipno;
    }

    private String getDjttlx(String shipno) {

        String djttlx="";
        Connection conn=null;
        DataSource ds= (DataSource) StaticObj.getServiceByFullname(("datasource.eweaverFormalOA"),DataSource.class);
        String sql="select a.expno,a.fxchannel,a.isvalid from uf_dmsd_expboxmain a where " +
                "a.isvalid='40288098276fc2120127704884290210' and exists(select 1 from requestbase where id=a.requestid and isdelete=0)"+
                " and a.expno='"+shipno+"'";
        BaseBean log=new BaseBean();
        log.writeLog(sql);
       log.writeLog(ds);
        try{
           conn= ds.getConnection();
            ResultSet rs=conn.createStatement().executeQuery(sql);
            while (rs.next()){
                djttlx=rs.getString("fxchannel");
            }

        }catch (SQLException e){
            e.printStackTrace();

        }finally {
            if (conn!=null){
                try {
                    conn.close();
                }catch (SQLException e){
                    e.printStackTrace();
                }
            }
        }

        return djttlx;
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
}%>



