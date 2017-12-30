package weaver.interfaces.workflow.action;

import com.sap.mw.jco.JCO;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CCP_UPDATE_PO_LHSQ extends BaseBean implements Action {
	// shipping柜号输入接口
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_UPDATE_PO_LHSQ开始");
		JCO.Client sapconnection = null;
		try {
			ResourceComInfo resourceComInfo = new ResourceComInfo();
			// 获取输入参数
			WorkflowComInfo workflowComInfo = new WorkflowComInfo();
			int requestid = Util.getIntValue(request.getRequestid());
			// 得到流程id
			String workflowId = request.getWorkflowid();
			int formid = Util.getIntValue(workflowComInfo.getFormId("" + workflowId), 0);
			int isbill = Util.getIntValue(workflowComInfo.getIsBill("" + workflowId), 0);
			String tablename = "";
			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}
			// 明细表
			String jydh = "";// 交运单号
			String xc = "";// 项次
			String bczxsl = "";// 本次装卸数量
			String zsl = "";// 数量
			double sysl = 0.00;// 剩余数量

			String selectSql = " select t2.* from " + tablename + " t1";
			selectSql += " left join " + tablename + "_dt1  t2 on t1.id = t2.mainid";
			selectSql += " where t1.requestid= " + requestid;
			log.writeLog("查询流程表单的sql:" + selectSql);
			rs.execute(selectSql);
			while (rs.next()) {
				bczxsl = Util.null2String(rs.getString("bczxsl"));// 本次装卸数量
				zsl = Util.null2String(rs.getString("zsl"));// 总数量
				jydh = Util.null2String(rs.getString("jydh"));// 交运单号
				xc = Util.null2String(rs.getString("xc"));// 项次
				sysl = Double.parseDouble(zsl) - Double.parseDouble(bczxsl);// 计算剩余数量
				log.writeLog("计算剩余数量:" + sysl);
				if (sysl >= 0) {
					String updateSql = "update uf_spghsr set shipnum = '" + sysl + "' where DELIVERYNO = '" + jydh
							+ "' and DELIVERYITEM = '" + xc + "'";
					rs1.executeSql(updateSql);
				} else {
					request.getRequestManager().setMessagecontent("更新产品数量失败，请联系管理员");
					return "1";
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			log.writeLog(e);
			request.getRequestManager().setMessagecontent("插入失败，请联系管理员");
			return "0";
		} finally {
			if (null != sapconnection) {
				JCO.releaseClient(sapconnection);
			}
		}
		return Action.SUCCESS;
	}
}
