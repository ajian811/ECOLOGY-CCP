package weaver.interfaces.workflow.action;/*
 *CREATE BY chen
 *AT 2018/3/14 0014 19:02
 *IN ECOLOGY开发
 */

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class Z_CCP_NON_SAP_ZXJH_ZF extends BaseBean implements Action{
    @Override
    public String execute(RequestInfo requestInfo) {
        RecordSet rs = new RecordSet();
        writeLog("进入Z_CCP_PO_ZXJH_ZF,requestid:" + requestInfo.getRequestid());
        String sql = "";
        String message = "";// 错误返回消息
        try {
            WorkflowComInfo workflowComInfo = new WorkflowComInfo();
            int requestid = Util.getIntValue(requestInfo.getRequestid());

            String workflowId = requestInfo.getWorkflowid();
            int formid = Util.getIntValue(workflowComInfo.getFormId(workflowId), 0);
            int isbill = Util.getIntValue(workflowComInfo.getIsBill(workflowId), 0);
            String tablename = "";
            if (isbill == 0) {
                tablename = "workflow_form";
            } else {
                rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
                if (rs.next()) {
                    tablename = Util.null2String(rs.getString("tablename"));
                }
            }
            sql = "select id,zxjhh,sfyyf as jfyyf,sfzf from " + tablename + " where requestid=" + requestid;
            rs.writeLog(sql);
            rs.execute(sql);
            String sfyg = "";//是否有柜
            String id = "";//id
            String zxjhh = "";//装卸计划号
            String jfyyf = "";//是否有运费
            String sfzf = "";//是否作废
            if (rs.next()) {
                id = Util.null2String(rs.getString("id"));
                jfyyf = Util.null2String(rs.getString("jfyyf"));
                sfzf = Util.null2String(rs.getString("sfzf"));
                zxjhh = Util.null2String(rs.getString("zxjhh"));
            } else {
                message = "查询不到该流程";
                return message;
            }
            sql="select id from uf_fsapzxjh where zxjhh='"+zxjhh+"'";
            rs.writeLog(sql);
            rs.execute(sql);
            if (rs.next()){
                id=rs.getString("id");
            }


            if (sfzf.equals("1")) {
                return "该装卸计划已作废";
            }
            // 根据装卸计划号查询运费暂估单是否上抛，没上抛可直接作废装卸计划和暂估单(暂估单作废方式: 暂估表单状态（是否作废）改为YES)；
            if (jfyyf.equals("1")) {


                sql = "select DJSTATUS,djbh from uf_zgfy where zxplanno='" + zxjhh + "'";
                rs.writeLog(sql);
                rs.execute(sql);
                String DJSTATUS = "";
                String djbh = "";
                while (rs.next()) {
                    DJSTATUS = Util.null2String(rs.getString("DJSTATUS"));
                    djbh = Util.null2String(rs.getString("djbh"));
                    RecordSet rs2 = new RecordSet();
                    if (DJSTATUS.equals("0")) {
                        sql = "update uf_zgfy set DJSTATUS='4' where zxplanno='" + zxjhh + "'";
                        rs2.writeLog(sql);
                        rs2.execute(sql);
                    }

                    if (DJSTATUS.equals("2") || DJSTATUS.equals("1") || DJSTATUS.equals("3")) {
                        message = "报错：装卸计划号" + zxjhh + "的关联运费暂估单" + djbh + "已上抛SAP,请先作废该运费暂估单";
                        return message;
                    }
                }
                sql = "select DJSTATUS,djbh from uf_zgfy where zxplanno='" + zxjhh + "'";
                rs.writeLog(sql);
                rs.execute(sql);
                while (rs.next()) {
                    DJSTATUS = Util.null2String(rs.getString("DJSTATUS"));
                    djbh = Util.null2String(rs.getString("djbh"));
                    RecordSet rs2 = new RecordSet();
                    if (DJSTATUS.equals("0")) {
                        sql = "update uf_zgfy set DJSTATUS='4' where zxplanno='" + zxjhh + "'";
                        rs2.writeLog(sql);
                        rs2.execute(sql);
                    }
                }
            }



                sql = "select ysddh AS PONO,ddxc AS POITEM,bczxsl AS JHYZL from uf_fsapzxjh_dt1 where MAINID=" + id;

            rs.writeLog(sql);
            rs.execute(sql);
            Map<String, String> hp = new HashMap<String, String>();
            while (rs.next()) {
                String ddh = Util.null2String(rs.getString("PONO"));
                String xc = Util.null2String(rs.getString("POITEM"));
                String bczxsl = Util.null2String(rs.getString("JHYZL"));

                if (hp.containsKey(ddh + "-" + xc)) {
                    String oldSl = hp.get(ddh + "-" + xc);
                    String newSl = (calCulate(oldSl, bczxsl, "add")).toString();
                    hp.put(ddh + "-" + xc, newSl);

                } else {

                    hp.put(ddh + "-" + xc, bczxsl);
                }
            }

            JSONArray jsonArray2 = new JSONArray();
            Iterator iterator = hp.entrySet().iterator();
            while (iterator.hasNext()) {
                JSONObject jsonObject = new JSONObject();
                Map.Entry entry = (Map.Entry) iterator.next();
                String key = entry.getKey().toString();
                String val = entry.getValue().toString();
                String[] strs2 = key.split("-");
                jsonObject.put("ddh", strs2[0]);
                jsonObject.put("xc", strs2[1]);
                jsonObject.put("bczxsl", val);
                jsonArray2.add(jsonObject);
            }
            rs.writeLog("获得jsonArray2：" + jsonArray2.toString());
            for (int i = 0; i < jsonArray2.size(); i++) {
                JSONObject jsObject = jsonArray2.getJSONObject(i);
                sql = "select T1.ID,T1.quantity AS LFIMG,T1.hadquan AS YCHL from uf_fsapclxq_DT1 T1,uf_fsapclxq T2" +
                        " where T1.MAINID=T2.ID AND T2.FLOWNO='" + jsObject.getString("ddh")
                        + "' and T1.item='" + jsObject.getString("xc") + "'";
                rs.writeLog(sql);
                rs.execute(sql);
                //作废回写已运载量
                while (rs.next()) {
                    RecordSet rs2 = new RecordSet();
                    String YCHL = rs.getString("YCHL");// 已出货量
                    String LFIMG = rs.getString("LFIMG");// 总数量
                    Double nowCounts = calCulate(LFIMG, YCHL, "sub");
                    rs2.writeLog("已出货为：" + YCHL + ",总数量为：" + LFIMG + ",剩余数量为：" + nowCounts);
                    Double insertSL2 = calCulate(YCHL, jsObject.getString("bczxsl"), "sub");
                    String id0=rs.getString("id");

                    sql = "UPDATE uf_fsapclxq_DT1 SET hadquan='" + insertSL2 + "' WHERE id="+id0;
                    rs2.writeLog(sql);
                    rs2.execute(sql);
                }

            }
            updateTrdStatus(zxjhh);
            updateZxjhStatus(zxjhh);
        } catch (Exception e) {
            e.printStackTrace();
            rs.writeLog("fail--" + e);
            message="数据更新失败，请联系系统管理员！";
            return message;
        }
        return "1";

    }

    private void updateZxjhStatus(String zxjhh) {
        RecordSet rs=new RecordSet();
        String sql="update uf_fsapzxjh set sfzf='1' where zxjhh='"+zxjhh+"'";
        rs.writeLog(sql);
        rs.execute(sql);
        sql="update formtable_main_88 set sfzf='1' where zxjhh='"+zxjhh+"'";
        rs.writeLog(sql);
        rs.execute(sql);


    }

    private void updateTrdStatus(String zxjhh) {
        String sql="";
        RecordSet rs=new RecordSet();
        sql="update UF_TRDPLDY set sfzf='1' where zxjhh='"+zxjhh+"'";
        rs.writeLog(sql);
        rs.execute(sql);
    }

    public Double calCulate(String str1, String str2, String action) {
        if (str1.equals("") || str1 == null) {

            str1 = "0.00";
        }
        if (str2.equals("") || str2 == null) {

            str2 = "0.00";
        }
        // 计算净重的绝对值
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal(str2);
        Double b3 = 0.00;
        if (action.equals("add")) {
            b3 = b1.add(b2).doubleValue();
        }
        if (action.equals("sub")) {
            b3 = b1.subtract(b2).doubleValue();
            if (b3 < 0) {
                b3 = 0.00;
            }
        }
        return b3;
    }

}
