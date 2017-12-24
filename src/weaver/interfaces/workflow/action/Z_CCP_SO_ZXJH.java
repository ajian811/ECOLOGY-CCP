package weaver.interfaces.workflow.action;

import java.math.BigDecimal;
import com.weaver.general.BaseBean;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

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
			if (isbill == 0) {
				tablename = "workflow_form";
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}
			sql = "select id,sfyg,ygshipno,sfzf from " + tablename + " where requestid=" + requestid;
			rs.writeLog(sql);
			rs.execute(sql);
			if (rs.next()) {
				String sfyg = Util.null2String(rs.getString("sfyg"));
				RecordSet rs1 = new RecordSet();
				String id = Util.null2String(rs.getString("id"));
				String sfzf=Util.null2String(rs.getString("sfzf"));
				//如果作废则直接返回
				if(sfzf.equals("1")){
					return Action.SUCCESS;
				}
				
				// 有柜情况
				if (sfyg.equals("1")) {
					String shipno = Util.null2String(rs.getString("ygshipno"));
					sql = "select gbh,fqh from " + tablename + "_dt1 where mainid=" + id;
					rs1.writeLog(sql);
					rs1.execute(sql);
					while (rs1.next()) {
						String gh = Util.null2String(rs1.getString("gbh"));
						String fqh = Util.null2String(rs1.getString("fqh"));

						sql = "SELECT b.id FROM UF_GHLR a,UF_GHLR_DT1 b where a.id=b.MAINID and a.SHIPPING='" + shipno
								+ "' and b.code='" + gh + "'";
						RecordSet rs2 = new RecordSet();
						rs2.writeLog(sql);
						rs2.execute(sql);
						String ghid = "";
						if (rs2.next()) {
							ghid = Util.null2String(rs2.getString("id"));
						}
						sql = "update UF_GHLR_DT1 set fqh='" + fqh + "' where id=" + ghid;
						rs2.writeLog(sql);
						rs2.execute(sql);
					}
				}
				// 无柜情况
				if (sfyg.equals("0")) {
					sql = "select jydh,xc,jhyzl from " + tablename + "_dt3 where mainid=" + id;
					rs.writeLog(sql);
					rs.execute(sql);
					while (rs.next()) {
						RecordSet rs3 = new RecordSet();
						String sono = Util.null2String(rs.getString("jydh"));
						String soitem = Util.null2String(rs.getString("xc"));
						String jhyzl = Util.null2String(rs.getString("jhyzl"));
						sql = "select ychl from uf_spghsr where DELIVERYNO='" + sono + "' and DELIVERYITEM='"
								+ soitem + "'";
						rs3.writeLog(sql);
						rs3.execute(sql);
						String ychl = "";
						if (rs3.next()) {
							ychl = Util.null2String(rs3.getString("ychl"));
						}
						Double insertSL2 = calCulate(jhyzl, ychl, "add");
						sql = "UPDATE uf_spghsr SET ychl='" + insertSL2 + "' WHERE DELIVERYNO='" + sono
								+ "' and DELIVERYITEM='" + soitem + "'";
						rs3.writeLog(sql);
						rs3.execute(sql);
					}

				}
			}
			return Action.SUCCESS;
		} catch (Exception e) {
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
