package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import com.weaver.general.BaseBean;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CPP_SO_LHSQ_ZF extends BaseBean implements Action {

	@Override
	public String execute(RequestInfo requestInfo) {
		RecordSet rs = new RecordSet();
		writeLog("进入Z_CPP_SO_LHSQ_ZF,requestid:" + requestInfo.getRequestid());
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
			sql = "select id,sfyg,GH,SHIPPING,lcbh,zxjhh,sfzf from " + tablename + " where requestid=" + requestid;
			rs.writeLog(sql);
			rs.execute(sql);
			String sfyg = "";
			String id = "";
			String shipno = "";
			String lcbh = "";
			String gh="";
			String zxjhh="";
			String sfzf="";
			if (rs.next()) {
				sfyg = Util.null2String(rs.getString("sfyg"));
				id = Util.null2String(rs.getString("id"));
				shipno = Util.null2String(rs.getString("shipping"));
				lcbh = Util.null2String(rs.getString("lcbh"));
				gh = Util.null2String(rs.getString("gh"));
				zxjhh=Util.null2String(rs.getString("ZXJHH"));
				sfzf=Util.null2String(rs.getString("sfzf"));
			} else {
				message = "查询不到该流程";
				requestInfo.getRequestManager().setMessagecontent(message);
				return Action.FAILURE_AND_CONTINUE;
			}
			if(sfzf.equals("0")){
				return Action.SUCCESS;
			}
			// 有柜情况
			if (sfyg.equals("1")) {
				// 1.根据Shipping和柜号查询装卸计划是否作废
				
				sql = "select requestid,zxjhh,SFZF from formtable_main_45 where ghcx='" + gh
						+ "' AND SFYG='1' AND YGSHIPNO='" + shipno + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				String SFZF = "";
				String requestid1 = "";
				if (rs.next()) {
					zxjhh = Util.null2String(rs.getString("zxjhh"));
					SFZF = Util.null2String(rs.getString("SFZF"));
					requestid1 = Util.null2String(rs.getString("requestid"));
					if (!SFZF.equals("1")) {
						message = "报错：装卸计划号为：" + zxjhh + "的SO装卸计划尚未作废";
						requestInfo.getRequestManager().setMessagecontent(message);
						return Action.FAILURE_AND_CONTINUE;
					}
					// 根据requestid在workflow_requestbase表中查询当前节点状态 0--创建
					// 3--归档
					RecordSet rs1=new RecordSet();
					sql = "SELECT currentnodetype FROM workflow_requestbase where requestid='" + requestid1 + "'";
					rs1.writeLog(sql);
					rs1.execute(sql);
					String dqjd = "";
					if (rs1.next()) {
						dqjd = rs1.getString("currentnodetype");
						
					}
					writeLog("获得节点："+dqjd);
					if (!dqjd.equals("3")) {
						String jdname = "";
						if (dqjd.equals("0")) {
							jdname = "创建";
						}
						if (dqjd.equals("1")) {
							jdname = "审批";
						}
						message = "报错：装卸计划号为：" + zxjhh + "的SO装卸计划尚已作废，但尚未归档，目前仍在" + jdname + "节点";
						requestInfo.getRequestManager().setMessagecontent(message);
						return Action.FAILURE_AND_CONTINUE;
					}
				}
				
				/*
				 * 2.根据理货单号查询柜费/装柜劳务/吊柜费暂估单是否均已上抛，如果全部未上抛的，则作废理货清单时，将相关的柜费/装柜劳务/
				 * 吊柜费暂估单全部作废。
				 * 如果全部已作废的，则只需作废理货清单。如果部分已上抛的，则提示“关联的暂估单号XXXX已上抛，请先作废暂估单！”
				 */
				sql = "select DJSTATUS,djbh from uf_zgfy where lgbh='" + lcbh + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				while (rs.next()) {
					String djstatus = Util.null2String(rs.getString("DJSTATUS"));
					String djbh = Util.null2String(rs.getString("djbh"));
					if ((!djstatus.equals("0")) && (!djstatus.equals("4"))) {
						message = "报错：暂估单编号为：" + djbh + "已上抛SAP，请先作废该暂估单后再操作";
						requestInfo.getRequestManager().setMessagecontent(message);
						return Action.FAILURE_AND_CONTINUE;
					}
				}
				sql = "select DJSTATUS from uf_zgfy where lgbh='" + lcbh + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				while (rs.next()) {
					String djstatus = Util.null2String(rs.getString("DJSTATUS"));
					RecordSet rs2 = new RecordSet();
					if (djstatus.equals("4")) {
						break;
					} else if (djstatus.equals("0")) {
						sql = "update uf_zgfy set DJSTATUS='4' where lgbh='" + lcbh + "'";
						rs2.writeLog(sql);
						rs2.execute(sql);
					}
				}

				// 3.根据明细表里的单号、项次回写同步表里的已装卸数量和剩余数量
				sql = "SELECT JYDH,XC,BCZXSL FROM FORMTABLE_MAIN_43_DT1 where MAINID='" + id + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				JSONArray jsonArray = new JSONArray();
				while (rs.next()) {
					String jydh = Util.null2String(rs.getString("jydh"));
					String xc = Util.null2String(rs.getString("xc"));
					String bczxsl = Util.null2String(rs.getString("BCZXSL"));
					if (jsonArray.size() == 0) {
						JSONObject jsonObject = new JSONObject();
						jsonObject.put("jydh", jydh);
						jsonObject.put("xc", xc);
						jsonObject.put("bczxsl", bczxsl);
						jsonArray.add(jsonObject);
					} else {
						Boolean ifcz=false;
						for (int i = 0; i < jsonArray.size(); i++) {
							JSONObject jsonObject = jsonArray.getJSONObject(i);
							if (jydh.equals(jsonObject.get("jydh")) && xc.equals(jsonObject.get("xc"))) {
								Double total = calCulate(bczxsl, jsonObject.get("bczxsl").toString(), "add");
								jsonObject.put("bczxsl", total.toString());
								ifcz=true;
							}
						}
						if (!ifcz){
							JSONObject jsonObject = new JSONObject();
							jsonObject.put("jydh", jydh);
							jsonObject.put("xc", xc);
							jsonObject.put("bczxsl", bczxsl);
							jsonArray.add(jsonObject);
						}
					}

				}
				writeLog("获得单号项次总装卸数量：" + jsonArray.toString());
				// 获得批号项次数量的json数组更新同步表
				for (int i = 0; i < jsonArray.size(); i++) {
					JSONObject jsonObject = jsonArray.getJSONObject(i);
					String jydh = jsonObject.getString("jydh");
					String xc = jsonObject.getString("xc");
					String bczxsl = jsonObject.getString("bczxsl");
					sql = "select YCHL FROM UF_SPGHSR WHERE DELIVERYNO='" + jydh + "' and DELIVERYITEM='" + xc + "'";
					rs.writeLog(sql);
					rs.execute(sql);
					String ychl = "";
					if (rs.next()) {
						ychl = Util.null2String(rs.getString("ychl"));
					}
					Double newcyl = calCulate(ychl, bczxsl, "sub");
					sql = "update UF_SPGHSR set ychl='" + newcyl + "' WHERE DELIVERYNO='" + jydh + "' and DELIVERYITEM='" + xc + "'";
					rs.writeLog(sql);
					rs.execute(sql);
				}


			}
			// 无柜情况无操作

		} catch (

		Exception e)

		{
			e.printStackTrace();
			rs.writeLog("fail--" + e);
			requestInfo.getRequestManager().setMessagecontent("数据更新失败，请联系系统管理员！");
			return Action.FAILURE_AND_CONTINUE;
		}
		return Action.SUCCESS;

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
