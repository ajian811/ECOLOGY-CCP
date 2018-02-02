package weaver.interfaces.workflow.action;

import java.math.BigDecimal;

import com.weaver.general.BaseBean;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CCP_SO_ZXJH_ZF extends BaseBean implements Action {
	@Override
	public String execute(RequestInfo requestInfo) {
		RecordSet rs = new RecordSet();
		writeLog("进入Z_CCP_SO_ZXJH_ZF,requestid:" + requestInfo.getRequestid());
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
			sql = "select id,sfyg,zxjhh,sfyyf,sfzf,YGSHIPNO from " + tablename + " where requestid=" + requestid;
			rs.writeLog(sql);
			rs.execute(sql);
			String sfyg = "";
			String id = "";
			String zxjhh = "";
			String sfyyf = "";
			String sfzf="";
			String shipno="";
			if (rs.next()) {
				sfyg = Util.null2String(rs.getString("sfyg"));
				id = Util.null2String(rs.getString("id"));
				sfyyf = Util.null2String(rs.getString("sfyyf"));
				sfzf=Util.null2String(rs.getString("sfzf"));
				zxjhh=Util.null2String(rs.getString("zxjhh"));
				shipno=Util.null2String(rs.getString("YGSHIPNO"));
			} else {
				message = "查询不到该流程";
				requestInfo.getRequestManager().setMessagecontent(message);
				return "0";
			}
			
			if(sfzf.equals("0")){
				return "1";
			}
				// 根据装卸计划号查询运费暂估单是否上抛，没上抛可直接作废装卸计划和暂估单(暂估单作废方式: 暂估表单状态（是否作废）改为YES)；
				if (sfyyf.equals("1")) {
				

				sql = "select DJSTATUS,djbh from uf_zgfy where zxplanno='" + zxjhh + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				String DJSTATUS = "";
				String djbh = "";
				while (rs.next()) {
					DJSTATUS = Util.null2String(rs.getString("DJSTATUS"));
					djbh = Util.null2String(rs.getString("djbh"));
					RecordSet rs2=new RecordSet();
					if (DJSTATUS.equals("0")) {
						sql = "update uf_zgfy set DJSTATUS='4' where zxplanno='" + zxjhh + "'";
						rs2.writeLog(sql);
						rs2.execute(sql);
					}

					if (DJSTATUS.equals("2") || DJSTATUS.equals("1") || DJSTATUS.equals("3")) {
						message = "报错：装卸计划号" + zxjhh + "的关联运费暂估单" + djbh + "已上抛SAP,请先作废该运费暂估单";
						requestInfo.getRequestManager().setMessagecontent(message);
						return "0";
					}
				}
				sql = "select DJSTATUS,djbh from uf_zgfy where zxplanno='" + zxjhh + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				while (rs.next()) {
					DJSTATUS = Util.null2String(rs.getString("DJSTATUS"));
					djbh = Util.null2String(rs.getString("djbh"));
					RecordSet rs2=new RecordSet();
					if (DJSTATUS.equals("0")) {
						sql = "update uf_zgfy set DJSTATUS='4' where zxplanno='" + zxjhh + "'";
						rs2.writeLog(sql);
						rs2.execute(sql);
					}
				}
				
				
				}
			//有柜情况无操作
			if (sfyg.equals("1")) {
				sql="select gbh from formtable_main_45_DT1 where mainid="+id;
				rs.writeLog(sql);
				rs.execute(sql);

				String gbh="";
				while (rs.next()) {
					gbh = Util.null2String(rs.getString("gbh"));

					if (!gbh.equals("")) {
						sql = "SELECT b.id FROM UF_GHLR a,UF_GHLR_DT1 b where a.id=b.MAINID and a.SHIPPING='" + shipno
								+ "' and b.code='" + gbh + "'";
						RecordSet rs2 = new RecordSet();
						rs2.writeLog(sql);
						rs2.execute(sql);
						String ghid = "";
						if (rs2.next()) {
							ghid = Util.null2String(rs2.getString("id"));
						}
						sql = "update UF_GHLR_DT1 set fqh=null where id=" + ghid;
						rs2.writeLog(sql);
						rs2.execute(sql);
					}
				}
			}
			// 无柜情况
			//if (sfyg.equals("0")) {
			//	//根据装卸计划查询理货清单是否作废,如果没有作废，则该为作废
			//	sql="select sfzf,lcbh from formtable_main_43 where zxjhh='"+zxjhh+"'";
			//	rs.writeLog(sql);
			//	rs.execute(sql);
			//	String lcbh2="";
			//	if(rs.next()){
			//		sfzf=Util.null2String(rs.getString("sfzf"));
			//		lcbh2=Util.null2String(rs.getString("lcbh2"));
			//	}
			//	if(sfzf.equals("0")){
			//		message = "报错：装卸计划号" + zxjhh + "的关联理货申请" + lcbh2 + "尚未作废,请先作废";
			//		requestInfo.getRequestManager().setMessagecontent(message);
			//		return "0";
			//	}
			//
			//	//
			//	sql="select jhyzl,jydh,xc from FORMTABLE_MAIN_45_DT3 where mainid="+id+"";
			//
			//	rs.writeLog(sql);
			//	rs.execute(sql);
			//	JSONArray jsonArray = new JSONArray();
			//	while (rs.next()) {
			//		String jydh = Util.null2String(rs.getString("jydh"));
			//		String xc = Util.null2String(rs.getString("xc"));
			//		String bczxsl = Util.null2String(rs.getString("jhyzl"));
			//		if (jsonArray.size() == 0) {
			//			JSONObject jsonObject = new JSONObject();
			//			jsonObject.put("jydh", jydh);
			//			jsonObject.put("xc", xc);
			//			jsonObject.put("bczxsl", bczxsl);
			//			jsonArray.add(jsonObject);
			//		} else {
			//			Boolean ifcz=false;
			//			for (int i = 0; i < jsonArray.size(); i++) {
			//				JSONObject jsonObject = jsonArray.getJSONObject(i);
			//				if (jydh.equals(jsonObject.get("jydh")) && xc.equals(jsonObject.get("xc"))) {
			//					Double total = calCulate(bczxsl, jsonObject.get("bczxsl").toString(), "add");
			//					jsonObject.put("bczxsl", total.toString());
			//					ifcz=true;
			//				}
			//			}
			//			if (!ifcz){
			//				JSONObject jsonObject = new JSONObject();
			//				jsonObject.put("jydh", jydh);
			//				jsonObject.put("xc", xc);
			//				jsonObject.put("bczxsl", bczxsl);
			//				jsonArray.add(jsonObject);
			//			}
			//		}
            //
			//	}
			//	writeLog("获得单号项次总装卸数量：" + jsonArray.toString());
			//	// 获得批号项次数量的json数组更新同步表
			//	for (int i = 0; i < jsonArray.size(); i++) {
			//		JSONObject jsonObject = jsonArray.getJSONObject(i);
			//		String jydh = jsonObject.getString("jydh");
			//		String xc = jsonObject.getString("xc");
			//		String bczxsl = jsonObject.getString("bczxsl");
			//		sql = "select YCHL FROM UF_SPGHSR where DELIVERYNO='" + jydh + "' and DELIVERYITEM='" + xc + "'";
			//		rs.writeLog(sql);
			//		rs.execute(sql);
			//		String ychl = "";
			//		if (rs.next()) {
			//			ychl = Util.null2String(rs.getString("ychl"));
			//		}
			//		Double newcyl = calCulate(ychl, bczxsl, "sub");
			//		sql = "update UF_SPGHSR set ychl='" + newcyl + "' where DELIVERYNO='" + jydh + "' and DELIVERYITEM='" + xc + "'";
			//		rs.writeLog(sql);
			//		rs.execute(sql);
			//	}
			//}

		} catch (Exception e){
			e.printStackTrace();
			rs.writeLog("fail--" + e);
			requestInfo.getRequestManager().setMessagecontent("数据更新失败，请联系系统管理员！");
			return "0";
		}
		return "1";

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
