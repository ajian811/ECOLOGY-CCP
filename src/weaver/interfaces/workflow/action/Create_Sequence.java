package weaver.interfaces.workflow.action;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.sap.mw.jco.JCO;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Create_Sequence extends BaseBean implements Action {
	// shipping柜号输入接口
	@Override
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Create_Sequence开始");
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
			Date d = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyyMM");
			String currdate1 = format.format(d);
			// 定义字段
			String gys = "";// 供应商
			String hgc = "";// DEPOH（货柜厂）
			String ksrq = "";// 开始日期
			String jsrq = "";// 结束日期
			String wrongError = "";
			String sfyg = "";// 是否有柜
			String mainid = "";// 数据id
			String trdh = "";// 提入单号
			String crzt = "";// 出入状态
			String sfzf = "";// 是否作废
			String gsdm="";//公司代码

			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}
			String currentnodetype = "";
			String sql0="SELECT currentnodetype FROM workflow_requestbase where REQUESTID="+requestid;
			rs.writeLog(sql0);
			rs.execute(sql0);
			while (rs.next()){
				currentnodetype=Util.null2String(rs.getString("currentnodetype"));
			}
			writeLog("获得当前节点类型id："+currentnodetype);
			String selectSql = "select t1.*,t2.trdh from " + tablename + " t1 ";
			selectSql += " left join " + tablename + "_dt2 t2 on t1.id = t2.mainid";
			selectSql += " where t1.requestid= '" + requestid + "'";
			selectSql += " and t2.trdh is null";
			log.writeLog("查询主表的selectSql:" + selectSql);
			// String selectSql = "select * from " + tablename + " where
			// requestid = '" + requestid + "'";
			rs2.execute(selectSql);
			if (rs2.next()) {
				sfyg = rs2.getString("sfyg");
				mainid = rs2.getString("id");
				trdh = rs2.getString("trdh");
				crzt = rs2.getString("crzt");
				sfzf = rs2.getString("sfzf");
				gsdm = rs2.getString("gsdm");


				if (!"".equals(crzt)) {
					if ("0".equals(crzt)) {
						crzt = "I";
					} else {
						crzt = "O";
					}
				}
			}
			if (!"1".equals(sfzf)) {
				String updateSql = "";
				if ("0".equals(sfyg)) {
					if("0".equals(currentnodetype)){
						return SUCCESS;
					}
					String sql = "select t2.shipno from " + tablename + " t1 ";
					sql += " left join " + tablename + "_dt3 t2 on t1.id = t2.mainid";
					sql += " where t1.requestid= '" + requestid + "'";
					sql += " and t2.trdh is null";
					sql += " group by t2.shipno";
					log.writeLog("查询明细3的sql:" + sql);
					rs.execute(sql);
					while (rs.next()) {
						String lcbh = gsdm + crzt + currdate1;
						// String id = rs.getString("id");// 获取明细表id
						String shipno = rs.getString("shipno");// 获取shippingno
						// 调用存储过程自编号
						log.writeLog("调用存储过程fn_no_make");
						rs1.executeProc("fn_no_make", "");
						rs1.next();
						lcbh += formatString(rs1.getInt(1));

						updateSql = "update " + tablename + "_dt3 set trdh = '" + lcbh + "' where shipno = '" + shipno
								+ "' and  mainid = '" + mainid
								+ "'";
						log.writeLog("更新语句:" + updateSql);
						rs2.executeSql(updateSql);
					}
				} else if ("1".equals(sfyg) && "".equals(trdh)) {
					if(!"0".equals(currentnodetype)){
						return  SUCCESS;
					}
					String lcbh = gsdm + crzt + currdate1;
					// 调用存储过程自编号
					log.writeLog("调用存储过程fn_no_make");
					rs1.executeProc("fn_no_make", "");
					rs1.next();
					lcbh += formatString(rs1.getInt(1));
					if (!"".equals(mainid)) {
						updateSql = "update " + tablename + "_dt2 set trdh = '" + lcbh + "' where mainid = '" + mainid
								+ "'";
						log.writeLog("更新语句:" + updateSql);
						rs2.executeSql(updateSql);
					}
				}
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

	/**
	 * 将数字转换为字符串(当不足4位时高位补0)
	 * 
	 * @param input
	 * @return
	 */
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
	}
}
