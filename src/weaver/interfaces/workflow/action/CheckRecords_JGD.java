package weaver.interfaces.workflow.action;

import com.sap.mw.jco.JCO;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class CheckRecords_JGD extends BaseBean implements Action {
	// shipping柜号输入接口
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用CheckRecords_JGD开始");
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
			RecordSet rs2 = new RecordSet();
			
			//定义字段
			String 	gys	="";//	供应商
			String 	hgc	="";//	DEPOH（货柜厂）
			String 	ksrq ="";//	开始日期
			String 	jsrq ="";//	结束日期
			String  wrongError = "";
			
			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}
			if(formid == -11){
				//吊柜费只需要供应商和日期做判断
				//TODO
			}
			String sql = "select * from " + tablename + " where requestId=" + requestid;
			log.writeLog("查询数据sql :" + sql);
			rs1.execute(sql);
			if (rs1.next()) {
				gys = Util.null2String(rs1.getString("gys"));//供应商
				hgc = Util.null2String(rs1.getString("hgc"));//DEPOH（货柜厂）
				ksrq = Util.null2String(rs1.getString("ksrq"));//开始日期
				jsrq = Util.null2String(rs1.getString("jsrq"));//结束日期
			}
			
			String checkSql = "select a.* from "+tablename  + " a,";
			checkSql += " (select * from "+tablename+" where requestid ='"+ requestid+"')b"; 
			checkSql += " where a.gys = b.gys";
			checkSql += " and a.hgc = b.hgc";
			checkSql += " and a.requestid != b.requestid";
			checkSql += " and not(";
			checkSql += " b.jsrq <= a.ksrq";
			checkSql += " or b.ksrq >= a.jsrq)";
			log.writeLog("校验sql :" + checkSql);
			rs2.execute(checkSql);
			while(rs2.next()){
				wrongError += rs2.getString("lcbh")+"\t";
			}
			if(wrongError.length() > 0 ){
				request.getRequestManager().setMessagecontent("您提交的表单与以下流程编号的表单有冲突,流程编号: " + wrongError);
				request.getRequestManager().setMessageid("Error");
				return "1";
			}
		} catch (Exception e) {
			e.printStackTrace();
			log.writeLog(e);
			request.getRequestManager().setMessagecontent("推送SAP失败，请联系系统管理员！");
			return "0";
		} finally {
			if (null != sapconnection) {
				JCO.releaseClient(sapconnection);
			}
		}
		return Action.SUCCESS;
	}
}
