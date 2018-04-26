package weaver.interfaces.workflow.action;

import java.text.SimpleDateFormat;
import java.util.*;

import com.sap.mw.jco.JCO;

import org.apache.poi.hssf.record.Record;
import weaver.conn.RecordSet;
import weaver.formmode.setup.ModeRightInfo;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

public class Z_CCP_INSERT_TRD extends BaseBean implements Action {
	// shipping柜号输入接口
    @Override
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_INSERT_TRD开始");
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
			RecordSet rs3 = new RecordSet();
			int userid = request.getRequestManager().getUser().getUID();
			String currentnodetype = "";
			String sql0="SELECT currentnodetype FROM workflow_requestbase where REQUESTID="+requestid;
			rs.writeLog(sql0);
			rs.execute(sql0);
			while (rs.next()){
				currentnodetype=Util.null2String(rs.getString("currentnodetype"));
			}
			writeLog("当前流程节点类型id："+currentnodetype);
			if (isbill == 0) {
				tablename = "workflow_form";// 老表单的主表单名字
			} else {
				rs.execute("select tablename,detailkeyfield from workflow_bill where id=" + formid);
				if (rs.next()) {
					// 新表单的主表单名字
					tablename = Util.null2String(rs.getString("tablename"));
				}
			}

			Date d = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
			String currdate1 = format.format(d);
			// 主表
			String dycs = "";// 打印次数
			String zxjhh = "";// 装卸计划号
			String lcid = "";// 流程id
			String lcbh = "";// 流程编号
			String yjyssj = "";// 预计运输时间
			String sfdy = "";// 是否打印
			String sfyg = "";// 是否有柜
			String yjysrq = "";// 运行运输日期
			String trdh = "";// 提入单号
			String carno = "";// 车牌
			String sfzf = "";// 是否作废
			// 明细表
			String cp = "";// 产品
			String shipping = "";// shipping编码
			String sl = "";// 数量
			String gbm = "";// 柜编码

			String pono = "";// 采购订单号
			String poitem = "";// 采购订单项次
			String wlh = "";// 物料号码
			String wlname = "";// 物料描述
			String ph = "";//批号
			String bzxz="";//包装性质
			String shipno = "";//shipno编号
			String str1 = "";//uuid
			String sdfmc="";//送达方名称
			List<Map<String, String>> list = new ArrayList<Map<String, String>>();

			String selectsql = "select * from " + tablename + " where requestid = '" + requestid + "'";
			log.writeLog("查询流程表单的sql:" + selectsql);
			rs.execute(selectsql);
			if (rs.next()) {
				sfyg = Util.null2String(rs.getString("sfyg"));// 是否有柜

				zxjhh = Util.null2String(rs.getString("zxjhh"));// 装卸计划号
				lcbh = Util.null2String(rs.getString("lcbh"));// 流程编号
				yjysrq = Util.null2String(rs.getString("ysrq"));// 运行运输日期
				yjyssj = Util.null2String(rs.getString("yjyssj"));// 预计运输时间
				carno = Util.null2String(rs.getString("cp"));// 车牌
				sfzf = Util.null2String(rs.getString("sfzf"));// 是否作废
			}
				log.writeLog("是否有柜:" + sfyg);

				String unitdesc="";
						String sql = "select DISTINCT t2.TRDH from " + tablename + " t1 ";
						sql += " left join " + tablename + "_dt3 t2 on t1.id = t2.mainid";
						sql += " where t1.requestid= '" + requestid + "'";
						sql += " group by t2.TRDH";
						log.writeLog("查询明细3的sql:" + sql);
						rs2.execute(sql);
						while (rs2.next()) {
							trdh = rs2.getString("trdh");
							StringBuffer buffer = new StringBuffer();

							buffer.append("insert into UF_TRDPLDY");
							buffer.append(
									"(TRDH,ZXJHH,LCID,LCBH,DYCS,SFDY,SFYG,YJYSRQ,YJYSSJ,FORMMODEID,LX,cp,sfzf,MODEDATACREATER," +
											"modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid) values");
							buffer.append("('").append(trdh).append("',");
							buffer.append("'").append(zxjhh).append("',");
							buffer.append("'").append(requestid).append("',");
							buffer.append("'").append(lcbh).append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(sfyg).append("',");
							buffer.append("'").append(yjysrq).append("',");
							buffer.append("'").append(yjyssj).append("',");
							buffer.append("'").append("381").append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(carno).append("',");
							buffer.append("'").append("0").append("',");
							buffer.append("'").append(userid).append("',");

							buffer.append("'").append("0").append("',");
							Date d1=new Date();
							SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
							SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");
							buffer.append("'").append(dateFormat.format(d1)).append("',");
							buffer.append("'").append(dateFormat1.format(d1)).append("',");
							str1 = UUID.randomUUID().toString();
							buffer.append("'").append(str1).append("')");

							log.writeLog("插入建模主表执行的sql :" + buffer.toString());
							rs1.executeSql(buffer.toString());// 先插入主表

                            sql="select id from UF_TRDPLDY where modeuuid='"+str1+"'";
                            log.writeLog(sql);
                            rs1.execute(sql);
                            String id="";
                            if(rs1.next()){
                                id=Util.null2String(rs1.getString("id"));
                            }
                            ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
                            localModeRightInfo1.setNewRight(true);
                            localModeRightInfo1.editModeDataShare(userid, 381, Integer.parseInt(id));


							String dt3Sql = "select gbm,cp,jhyzl,shipno,jydh,xc,wlhm,wlms,sdfmc,dwms,ph from " + tablename + "_dt3 where trdh = '" + trdh + "'";
							rs.writeLog(dt3Sql);
							rs.execute(dt3Sql);

							while (rs.next()) {
								// 明细数据
								cp = Util.null2String(rs.getString("cp"));// 产品
								sl = Util.null2String(rs.getString("jhyzl"));// 数量
								// trdh =
								// Util.null2String(rs.getString("trdh"));//
								// 提入单号
								shipping = Util.null2String(rs.getString("shipno"));// shipping编码

								pono = Util.null2String(rs.getString("jydh"));// 交运单号
								poitem = Util.null2String(rs.getString("xc"));// 订单项次
								wlh = Util.null2String(rs.getString("wlhm"));// 物料号码
								wlname = Util.null2String(rs.getString("wlms"));// 物料描述
								sdfmc = Util.null2String(rs.getString("sdfmc"));// 送达方名称
								unitdesc = Util.null2String(rs.getString("dwms"));// 单位描述
								ph = Util.null2String(rs.getString("ph"));// 批号
								gbm = Util.null2String(rs.getString("gbm"));// 批号

								gbm=getSJGH(gbm,shipping,requestid);//获得实际编号，根据明细3中的柜号 在明细1中获取实际柜号，如果实际柜号为空 则返回原柜号



								String insertSql = "insert into uf_trdpldy_dt1(mainid,cp,shipping,jydh,ddxc,wlhm,wlms,ph,bzfs,sl,gbm) values ";
								insertSql += "(" + id + ",";
								insertSql += "'" + cp + "',";
								insertSql += "'" + shipping + "',";
								insertSql += "'" + pono + "',";
								insertSql += "'" + poitem + "',";
								insertSql += "'" + wlh + "',";
								insertSql += "'" + wlname + "',";
								insertSql += "'" + ph + "',";
								insertSql += "'" + unitdesc + "',";
								insertSql += "'" + sl + "',";
								insertSql += "'" + gbm + "')";
								log.writeLog("插入建模明细执行的sql :" + insertSql);
								rs3.executeSql(insertSql);// 后插入明细
							}
							Boolean result=updateKhmc(sdfmc,str1);
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

	private String getSJGH(String gbm,String shipping,int requestid) {
    	String sjgh="";
		RecordSet recordSet =new RecordSet();
		String sql="SELECT sjgh FROM FORMTABLE_MAIN_45_DT1 where gbh='"+gbm+"'" ;
				if(!"".equals(shipping)) {
					sql+=" and shipping='" + shipping + "'";
				}
				if(requestid>0) {
					sql+=" and mainid=(select id from FORMTABLE_MAIN_45 where requestid=" + requestid + ")";
				}
		recordSet.writeLog(sql);
		recordSet.execute(sql);
		if (recordSet.next()){
			sjgh= recordSet.getString("sjgh");
		}
		if ("".equals(sjgh)){
			sjgh=gbm;
		}

    	return  sjgh;
	}

	public Boolean updateKhmc(String khmc,String uuid){
    	Boolean result=false;
    	String sql="update uf_trdpldy set khmc='"+khmc+"' where modeuuid='"+uuid+"'";
    	RecordSet recordSet=new RecordSet();
    	recordSet.writeLog(sql);
    	result=recordSet.execute(sql);
    	return result;
	}
}
