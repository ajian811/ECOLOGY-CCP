package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import com.weaver.general.BaseBean;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

import javax.persistence.Id;

public class Z_CCP_SO_ZXJH extends BaseBean implements Action {

	@Override
	public String execute(RequestInfo requestInfo) {
		// TODO Auto-generated method stub
		RecordSet rs = new RecordSet();
		writeLog("进入Z_CCP_SO_ZXJH,requestid:" + requestInfo.getRequestid());
		String sql = "";
		try {

			WorkflowComInfo workflowComInfo = new WorkflowComInfo();
			int requestid = Util.getIntValue(requestInfo.getRequestid());

			String workflowId = requestInfo.getWorkflowid();
			int formid = Util.getIntValue(workflowComInfo.getFormId(workflowId), 0);
			int isbill = Util.getIntValue(workflowComInfo.getIsBill(workflowId), 0);
			String tablename = "";
			String currentnodetype = "";
			String sql0="SELECT currentnodetype FROM workflow_requestbase where REQUESTID="+requestid;
			writeLog(sql0);
			rs.execute(sql0);
			while (rs.next()){
				currentnodetype=Util.null2String(rs.getString("currentnodetype"));
			}
			if (isbill == 0) {
				tablename = "workflow_form";
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}
			sql = "select sfyg,id from " + tablename + " where requestid=" + requestid;
			writeLog(sql);
			rs.execute(sql);
			if (rs.next()) {
				RecordSet rs1 = new RecordSet();
				String id = Util.null2String(rs.getString("id"));
				String sfyg = Util.null2String(rs.getString("sfyg"));

                String detailTableName="";
                if ("0".equals(sfyg)){
                    detailTableName="UF_GHLR_dt2";
                }
                if ("1".equals(sfyg)){
                    detailTableName="UF_GHLR_dt1";
                }

				// 根据明细表1中的柜号及shipping、封签号去更新柜号录入明细中的封签号，注意柜号录入表，有柜时更新明细，无柜为明细2
					sql = "select gbh,fqh,shipping from " + tablename + "_dt1 where mainid=" + id;
					rs1.writeLog(sql);
					rs1.execute(sql);
					while (rs1.next()) {
						String gh = Util.null2String(rs1.getString("gbh"));
						String fqh = Util.null2String(rs1.getString("fqh"));
						String shipno = Util.null2String(rs1.getString("shipping"));

						sql = "SELECT b.id FROM UF_GHLR a,"+detailTableName+" b where a.id=b.MAINID and a.SHIPPING='" + shipno
								+ "' and b.code='" + gh + "'";
						RecordSet rs2 = new RecordSet();
						rs2.writeLog(sql);
						rs2.execute(sql);
						String ghid = "";
						if (rs2.next()) {
							ghid = Util.null2String(rs2.getString("id"));
						}
						sql = "update "+detailTableName+" set fqh='" + fqh + "' where id=" + ghid;
						rs2.writeLog(sql);
						rs2.execute(sql);
					}
					//将明细1中的实际柜号值回写给理货申请建模
				sql="select SJGH,lhsqid from FORMTABLE_MAIN_45_DT1 where mainid="+ id;
					writeLog(sql);
					rs.execute(sql);
					String sjgh="";//是柜重
					String lhsqid="";//理货申请id
					if (rs.next()){
						sjgh=Util.null2String(rs.getString("sjgh"));
						lhsqid=Util.null2String(rs.getString("sjgh"));
						if (!"".equals(sjgh)&&!"".equals(lhsqid)){
							RecordSet recordSet=new RecordSet();
							sql="update uf_solhsq set ACTCONTAINER='"+sjgh+"' where id="+lhsqid ;
							writeLog(sql);
							rs.execute(sql);
						}
					}



			}

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
