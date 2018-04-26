package weaver.interfaces.workflow.action;/*
 *CREATE BY chen
 *AT 2018/3/14 0014 18:58
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

public class Z_CCP_NON_SAP_ZXJH extends BaseBean implements Action {
    @Override
    public String execute(RequestInfo requestInfo) {
        // TODO Auto-generated method stub
        RecordSet rs = new RecordSet();
        writeLog("进入Z_CCP_NON_SAP_ZXJH,requestid:" + requestInfo.getRequestid());
        String sql = "";
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
            sql = "select id,sfzf from " + tablename + " where requestid=" + requestid;
            writeLog(sql);
            rs.execute(sql);
            String id="";//主表id
            String sfyg="";//是否有柜
            String sfzf="";//是否作废
            if (rs.next()) {
                id = Util.null2String(rs.getString("id"));
                sfzf = Util.null2String(rs.getString("sfzf"));
            }
            //如果作废则直接返回
            if (sfzf.equals("1")) {
                return SUCCESS;
            }


                sql="select ysddh AS PONO,ddxc AS POITEM,bczxsl AS JHYZL from formtable_main_88_DT1 where MAINID=" + id;;

            writeLog(sql);
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
            writeLog("获得jsonArray2：" + jsonArray2.toString());
            for (int i = 0; i < jsonArray2.size(); i++) {
                JSONObject jsObject = jsonArray2.getJSONObject(i);
                sql = "select T1.ID,T1.quantity AS LFIMG,T1.hadquan AS YCHL from uf_fsapclxq_DT1 T1,uf_fsapclxq T2" +
                        " where T1.MAINID=T2.ID AND T2.flowno='" + jsObject.getString("ddh")
                        + "' and T1.item='" + jsObject.getString("xc") + "'";
                writeLog(sql);
                rs.execute(sql);
                while (rs.next()) {
                    RecordSet rs2 = new RecordSet();
                    String YCHL = rs.getString("YCHL");// 已出货量
                    String LFIMG = rs.getString("LFIMG");// 总数量
                    Double nowCounts = calCulate(LFIMG, YCHL, "sub");
                    rs2.writeLog("已出货为：" + YCHL + ",总数量为：" + LFIMG + ",剩余数量为：" + nowCounts);
                    Double insertSL2 = calCulate(YCHL, jsObject.getString("bczxsl"), "add");
                    String id0=rs.getString("id");

                    sql = "UPDATE uf_fsapclxq_DT1 SET hadquan='" + insertSL2 + "' WHERE id="+id0;
                    rs2.writeLog(sql);
                    rs2.execute(sql);
                }

            }



            // 无柜情况





            return Action.SUCCESS;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            writeLog("fail--" + e);
            requestInfo.getRequestManager().setMessagecontent("数据更新失败，请联系系统管理员！");
            return Action.FAILURE_AND_CONTINUE;
        }
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
        }
        return b3;
    }
}
