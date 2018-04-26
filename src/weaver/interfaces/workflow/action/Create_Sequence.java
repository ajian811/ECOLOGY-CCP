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
			String selectSql = "select t1.*,t2.trdh from " + tablename + " t1 ";
			selectSql += " left join " + tablename + "_dt3 t2 on t1.id = t2.mainid";
			selectSql += " where t1.requestid= '" + requestid + "'";
			selectSql += " and t2.trdh is null";
			log.writeLog("查询主表的selectSql:" + selectSql);
			// String selectSql = "select * from " + tablename + " where
			// requestid = '" + requestid + "'";
			rs2.execute(selectSql);
			if (rs2.next()) {
				mainid = rs2.getString("id");
				trdh = rs2.getString("trdh");
				crzt = rs2.getString("crzt");
				gsdm = rs2.getString("gsdm");
				sfyg = rs2.getString("sfyg");


				if (!"".equals(crzt)) {
					if ("0".equals(crzt)) {
						crzt = "I";
					} else {
						crzt = "O";
					}
				}
			}

				String updateSql = "";
			/**提入单生成规则
			 * 装卸计划
			 * 无柜情况：
			 * 按shipping+送达方简码、城市点进行分组，有几组生成几个提入单
			 * 有柜情况：
			 * 按s城市点进行分组，有几组生成几个提入单

			 *
			 */
			if ("".equals(trdh)) {
				String sqlstr="";
				if ("0".equals(sfyg)) {
					sqlstr= "SELECT DISTINCT SHIPNO,SDF,SDCS FROM FORMTABLE_MAIN_45_DT3 where mainid='" + mainid + "'";
				} else if("1".equals(sfyg)){
					sqlstr= "SELECT DISTINCT SDCS FROM FORMTABLE_MAIN_45_DT3 where mainid='" + mainid + "'";
				}
						rs2.writeLog(sqlstr);
					rs2.execute(sqlstr);
					String shipno="";//shipping号
					String SDF="";//送达方
					String SDCS="";//送达城市


					while (rs2.next()) {
						if ("0".equals(sfyg)) {
							shipno = Util.null2String(rs2.getString("shipno"));
							SDF = Util.null2String(rs2.getString("sdf"));
						}
						SDCS=Util.null2String(rs2.getString("sdcs"));


						String lcbh = gsdm + crzt + currdate1;
						// 调用存储过程自编号
						log.writeLog("调用存储过程fn_no_make");
						rs1.executeProc("fn_no_make", "");
						rs1.next();
						lcbh += formatString(rs1.getInt(1));
						if (!"".equals(mainid)) {

							updateSql = "update " + tablename + "_dt3 set trdh = '" + lcbh + "' where mainid = '" + mainid +"'";
							if (!"".equals(shipno)){
								updateSql+=" and shipno='"+shipno+"'";
							}
							if (!"".equals(SDF)) {
								updateSql+=" and sdf = '"+SDF+"'";
							}
							if (!"".equals(SDCS)){
								updateSql+=" and sdcs='"+SDCS+"'";
							}

							log.writeLog("更新语句:" + updateSql);
							rs2.executeSql(updateSql);
						}


						log.writeLog("更新语句:" + updateSql);
						rs2.executeSql(updateSql);

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

	public String getMaid(int requestid){
		String mainid="";
		RecordSet recordSet=new RecordSet();
		String sql="";
		sql="select id from formtable_main_45 where lcid='"+requestid+"'";
		recordSet.writeLog(sql);
		recordSet.execute(sql);
		if (recordSet.next()){
			mainid=Util.null2String(recordSet.getString("id"));
		}
		return mainid;
	}
}


