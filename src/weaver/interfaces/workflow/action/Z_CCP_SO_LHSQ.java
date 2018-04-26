package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.weaver.general.BaseBean;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CCP_SO_LHSQ extends BaseBean implements Action {

	@Override
	public String execute(RequestInfo requestInfo) {
		// TODO Auto-generated method stub
		RecordSet rs = new RecordSet();
		writeLog("进入Z_CCP_SO_LHSQ,requestid:" + requestInfo.getRequestid());
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
			sql = "select id,sfyg,SHIPPING,sfzf,gh,wgshipping,xngh from " + tablename + " where requestid=" + requestid;
			rs.writeLog(sql);
			rs.execute(sql);
			String sfyg = "";
			String id = "";
			String sfzf = "";
			String gh="";
			String xngh="";
			String wgshipping="";
			String shipping="";
			if (rs.next()) {
				sfyg = Util.null2String(rs.getString("sfyg"));
				id = Util.null2String(rs.getString("id"));
				sfzf = Util.null2String(rs.getString("sfzf"));
				if("1".equals(sfyg)){
					gh=Util.null2String(rs.getString("gh"));
					shipping=Util.null2String(rs.getString("shipping"));
				}
				if ("0".equals(sfyg)){
					xngh=Util.null2String(rs.getString("xngh"));
					wgshipping=Util.null2String(rs.getString("wgshipping"));
				}
			}
			// 如果作废则直接返回
			if (sfzf.equals("1")) {
				return Action.SUCCESS;
			}
			// 有柜情况
			if (sfyg.equals("1")) {
				sql = "select JYDH,XC,BCZXSL from FORMTABLE_MAIN_43_DT1 where MAINID=" + id;
				rs.writeLog(sql);
				rs.execute(sql);
				Map<String, String> hp = new HashMap<String, String>();
				while (rs.next()) {
					String ddh = Util.null2String(rs.getString("jydh"));
					String xc = Util.null2String(rs.getString("xc"));
					String bczxsl = Util.null2String(rs.getString("BCZXSL"));

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
					sql = "select LFIMG,YCHL from uf_spghsr where DELIVERYNO='" + jsObject.getString("ddh")
							+ "' and DELIVERYITEM='" + jsObject.getString("xc") + "'";
					rs.writeLog(sql);
					rs.execute(sql);
					while (rs.next()) {
						RecordSet rs2 = new RecordSet();
						String YCHL = rs.getString("YCHL");// 已出货量
						String LFIMG = rs.getString("LFIMG");// 总数量
						Double nowCounts = calCulate(LFIMG, YCHL, "sub");
						rs2.writeLog("已出货为：" + YCHL + ",总数量为：" + LFIMG + ",剩余数量为：" + nowCounts);
						Double insertSL2 = calCulate(YCHL, jsObject.getString("bczxsl"), "add");

						sql = "UPDATE uf_spghsr SET YCHL='" + insertSL2 + "' WHERE DELIVERYNO='"
								+ jsObject.getString("ddh") + "' and DELIVERYITEM='" + jsObject.getString("xc") + "'";
						rs2.writeLog(sql);
						rs2.execute(sql);
					}

				}
				//更新柜号录入该shipping的柜号为已使用
				if((!"".equals(gh)&&(!"".equals(shipping)))) {
					sql = "SELECT T1.ID FROM UF_GHLR_DT1 T1,UF_GHLR T2 WHERE T1.MAINID=T2.ID " +
							"AND T1.CODE='" + gh + "' and t2.shipping='" + shipping + "' and t1.sfyx='1'";
					writeLog(sql);
					rs.execute(sql);
					String detailId = "";
					if (rs.next()) {
						detailId = Util.null2String(rs.getString("id"));
					}
					if (!"".equals(detailId)) {
						sql = "update uf_ghlr_dt1 set sfsy='1' where id=" + detailId;
						writeLog(sql);
						rs.execute(sql);
					}
				}



			} else {//无柜
				sql = "select JYDH,XC,BPCZXSL from FORMTABLE_MAIN_43_DT2 where MAINID=" + id;
				rs.writeLog(sql);
				rs.execute(sql);
				Map<String, String> hp = new HashMap<String, String>();
				while (rs.next()) {
					String ddh = Util.null2String(rs.getString("jydh"));
					String xc = Util.null2String(rs.getString("xc"));
					String bczxsl = Util.null2String(rs.getString("BpCZXSL"));

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
					sql = "select LFIMG,YCHL from uf_spghsr where DELIVERYNO='" + jsObject.getString("ddh")
							+ "' and DELIVERYITEM='" + jsObject.getString("xc") + "'";
					rs.writeLog(sql);
					rs.execute(sql);
					while (rs.next()) {
						RecordSet rs2 = new RecordSet();
						String YCHL = rs.getString("YCHL");// 已出货量
						String LFIMG = rs.getString("LFIMG");// 总数量
						Double nowCounts = calCulate(LFIMG, YCHL, "sub");
						rs2.writeLog("已出货为：" + YCHL + ",总数量为：" + LFIMG + ",剩余数量为：" + nowCounts);
						Double insertSL2 = calCulate(YCHL, jsObject.getString("bczxsl"), "add");

						sql = "UPDATE uf_spghsr SET YCHL='" + insertSL2 + "' WHERE DELIVERYNO='"
								+ jsObject.getString("ddh") + "' and DELIVERYITEM='" + jsObject.getString("xc") + "'";
						rs2.writeLog(sql);
						rs2.execute(sql);
					}

				}

				if((!"".equals(xngh))&&(!"".equals(wgshipping))) {
					sql = "SELECT T1.ID FROM UF_GHLR_DT2 T1,UF_GHLR T2 WHERE T1.MAINID=T2.ID " +
							"AND T1.CODE='" + xngh + "' and t2.shipping='" + wgshipping + "' and t1.sfyx='1'";
					writeLog(sql);
					rs.execute(sql);
					String detailId = "";
					if (rs.next()) {
						detailId = Util.null2String(rs.getString("id"));
					}
					if (!"".equals(detailId)) {
						sql = "update uf_ghlr_dt2 set sfsy='1' where id=" + detailId;
						writeLog(sql);
						rs.execute(sql);
					}
				}
			}
			return Action.SUCCESS;
		} catch (

		Exception e)

		{
			// TODO Auto-generated catch block
			e.printStackTrace();
			rs.writeLog("fail--" + e);
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