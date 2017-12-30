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

/**
 *
 * @author jisuqiang date：2017-12-06
 */
public class Z_CCP_DELIVERY_DG_PO_OLD extends BaseBean implements Action {
	// shipping柜号输入接口
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_DELIVERY_DG_PO开始");
		JCO.Client sapconnection = null;
		try {
			ResourceComInfo resourceComInfo = new ResourceComInfo();
			// 获取输入参数
			WorkflowComInfo workflowComInfo = new WorkflowComInfo();
			int requestid = Util.getIntValue(request.getRequestid());
			int userid = request.getRequestManager().getUser().getUID();
			// 得到流程id
			String workflowId = request.getWorkflowid();
			int formid = Util.getIntValue(workflowComInfo.getFormId("" + workflowId), 0);
			int isbill = Util.getIntValue(workflowComInfo.getIsBill("" + workflowId), 0);
			String tablename = "";
			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet rs2 = new RecordSet();
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
			// 定义字段
			String pono = "";// 采购订单号
			String poitem = "";// 采购订单项次
			String prno = "";// 请购申请单号
			String pritem = "";// 请购申请项次
			String goodgroup = "";// 产品组
			String wlh = "";// 物料号码
			String wlname = "";// 物料描述
			String jhyzl = "";// 计划运载量
			String yyzl = "";// 已运载量
			String syyzl = "";// 剩余运载量
			String unitcode = "";// 单位代码（T/桶）
			String kwcode = "";// 库位代码
			String unitdesc = "";// 单位描述
			String kwdesc = "";// 库存地址
			String packxz = "";// 包装性质
			String shipto = "";// 送达方
			String shiptoname = "";// 送达方名称
			String shiptoaddr = "";// 送达地址描述
			String shipcity = "";// 送达城市点
			String soldto = "";// 售达方
			String soldtoname = "";// 售达方名称
			String sfgf = "";// 是否固废
			String isdanger = "";// 危险品标识
			String hbkpyz = "";// 合并开票原则
			String costcenter = "";// 成本中心
			String gyscode = "";// 供应商代码
			String gysname = "";// 供应商名称
			String packcode = "";// 包装代码
			String BUKRS = "";// 公司代码
			String EKORG = "";// 采购组织
			String BSART = "";// 采购凭证类型
			String WERKS = "";// 工厂
			String MENGE = "";// 采购订单数量
			String LFIMG = "";// LFIMG
			String EINDT = "";// 项目交货日期
			String EKGRP = "";// 采购组
			String MTART = "";// 物料类型
			String LOEKZ = "";// 采购凭证删除标识
			String UEBTO = "";// 过量交货限度
			String UEBTK = "";// 标识：允许未限制的过量交货
			String UNTTO = "";// 交货不足限度
			String BSART1 = "";// 订单类型（采购）
			String AFNAM = "";// 需求者/要求者名称
			String NAME2 = "";// 名称2
			String CHARG = "";// 批号
			String ANLN1 = "";// 主资产号
			String ZYUP = "";// 是否上传sap
			String ZGMZBH = "";// 购买证编号
			String ZMATNR = "";// 物料编号
			String ZMENGE1 = "";// 采购订单数量
			String ZMEINS1 = "";// 采购订单计量单位
			String ZDATELOW2 = "";// 可用（可供货的）开始日期
			String ZDATEHIGH2 = "";// 可用(可供货的)截至日期
			String ZCHARG = "";// ZCHARG
			String RETPO = "";// 退货项目
			String UMSON = "";// 免费项目
			String BEIZHU1 = "";// BEIZHU1
			String BEIZHU2 = "";// BEIZHU2
			String BEIZHU3 = "";// BEIZHU3
			String ZWEIGHT = "";// 包材重量

			String isfee = "";// 是否有运费
			String needtype = "";// 单据类型
			String inout = "";// 运入运出
			String plantransdate = "";// 预计运输日期
			String plantranstime = "";// 预计运输时间
			String transtype = "";// 运输方式
			
			
			String sql = "select t1.isfee,t1.inout,t1.transtype,t1.plantransdate,t1.plantranstime,t2.* from "
					+ tablename + " t1";
			sql += " left join " + tablename + "_dt1 t2 on t1.id = t2.mainid";
			sql += " where t1.requestid= " + requestid;
			log.writeLog("查询明细执行的log" + sql);
			rs.executeSql(sql);

			while (rs.next()) {

				pono = Util.null2String(rs.getString("pono"));// 采购订单号
				poitem = Util.null2String(rs.getString("poitem"));// 采购订单项次

				if (!"".equals(pono) && !"".equals(poitem)) {

					String checkSql = "select count(*) as count from uf_jmclxq where pono = '" + pono
							+ "' and poitem = '" + poitem + "'";
					log.writeLog("查询建模表里数据:" + checkSql);
					rs1.execute(checkSql);
					rs1.next();
					if (rs1.getInt(1) < 1) {
						// 主表字段
						isfee = Util.null2String(rs.getString("isfee"));// 是否有运费
						inout = Util.null2String(rs.getString("inout"));// 运入运出
						plantransdate = Util.null2String(rs.getString("plantransdate"));// 预计运输日期
						plantranstime = Util.null2String(rs.getString("plantranstime"));// 预计运输时间
						transtype = Util.null2String(rs.getString("transtype"));// 运输方式

						prno = Util.null2String(rs.getString("prno"));// 请购申请单号
						pritem = Util.null2String(rs.getString("pritem"));// 请购申请项次
						goodgroup = Util.null2String(rs.getString("goodgroup"));// 产品组
						wlh = Util.null2String(rs.getString("wlh"));// 物料号码
						wlname = Util.null2String(rs.getString("wlname"));// 物料描述
						jhyzl = Util.null2String(rs.getString("jhyzl"));// 计划运载量
						yyzl = Util.null2String(rs.getString("yyzl"));// 已运载量
						syyzl = Util.null2String(rs.getString("syyzl"));// 剩余运载量
						unitcode = Util.null2String(rs.getString("unitcode"));// 单位代码（T/桶）
						kwcode = Util.null2String(rs.getString("kwcode"));// 库位代码
						unitdesc = Util.null2String(rs.getString("unitdesc"));// 单位描述
						kwdesc = Util.null2String(rs.getString("kwdesc"));// 库存地址
						packxz = Util.null2String(rs.getString("packxz"));// 包装性质
						shipto = Util.null2String(rs.getString("shipto"));// 送达方
						shiptoname = Util.null2String(rs.getString("shiptoname"));// 送达方名称
						shiptoaddr = Util.null2String(rs.getString("shiptoaddr"));// 送达地址描述
						shipcity = Util.null2String(rs.getString("shipcity"));// 送达城市点
						soldto = Util.null2String(rs.getString("soldto"));// 售达方
						soldtoname = Util.null2String(rs.getString("soldtoname"));// 售达方名称
						sfgf = Util.null2String(rs.getString("sfgf"));// 是否固废
						isdanger = Util.null2String(rs.getString("isdanger"));// 危险品标识
						hbkpyz = Util.null2String(rs.getString("hbkpyz"));// 合并开票原则
						costcenter = Util.null2String(rs.getString("costcenter"));// 成本中心
						gyscode = Util.null2String(rs.getString("gyscode"));// 供应商代码
						gysname = Util.null2String(rs.getString("gysname"));// 供应商名称
						packcode = Util.null2String(rs.getString("packcode"));// 包装代码
						BUKRS = Util.null2String(rs.getString("BUKRS"));// 公司代码
						EKORG = Util.null2String(rs.getString("EKORG"));// 采购组织
						BSART = Util.null2String(rs.getString("BSART"));// 采购凭证类型
						WERKS = Util.null2String(rs.getString("WERKS"));// 工厂
						MENGE = Util.null2String(rs.getString("MENGE"));// 采购订单数量
						LFIMG = Util.null2String(rs.getString("LFIMG"));// LFIMG
						EINDT = Util.null2String(rs.getString("EINDT"));// 项目交货日期
						EKGRP = Util.null2String(rs.getString("EKGRP"));// 采购组
						MTART = Util.null2String(rs.getString("MTART"));// 物料类型
						LOEKZ = Util.null2String(rs.getString("LOEKZ"));// 采购凭证删除标识
						UEBTO = Util.null2String(rs.getString("UEBTO"));// 过量交货限度
						UEBTK = Util.null2String(rs.getString("UEBTK"));// 标识：允许未限制的过量交货
						UNTTO = Util.null2String(rs.getString("UNTTO"));// 交货不足限度
						BSART1 = Util.null2String(rs.getString("BSART1"));// 订单类型（采购）
						AFNAM = Util.null2String(rs.getString("AFNAM"));// 需求者/要求者名称
						NAME2 = Util.null2String(rs.getString("NAME2"));// 名称2
						CHARG = Util.null2String(rs.getString("CHARG"));// 批号
						ANLN1 = Util.null2String(rs.getString("ANLN1"));// 主资产号
						ZYUP = Util.null2String(rs.getString("ZYUP"));// 是否上传sap
						ZGMZBH = Util.null2String(rs.getString("ZGMZBH"));// 购买证编号
						ZMATNR = Util.null2String(rs.getString("ZMATNR"));// 物料编号
						ZMENGE1 = Util.null2String(rs.getString("ZMENGE1"));// 采购订单数量
						ZMEINS1 = Util.null2String(rs.getString("ZMEINS1"));// 采购订单计量单位
						ZDATELOW2 = Util.null2String(rs.getString("ZDATELOW2"));// 可用（可供货的）开始日期
						ZDATEHIGH2 = Util.null2String(rs.getString("ZDATEHIGH2"));// 可用(可供货的)截至日期
						ZCHARG = Util.null2String(rs.getString("ZCHARG"));// ZCHARG
						RETPO = Util.null2String(rs.getString("RETPO"));// 退货项目
						UMSON = Util.null2String(rs.getString("UMSON"));// 免费项目
						BEIZHU1 = Util.null2String(rs.getString("BEIZHU1"));// BEIZHU1
						BEIZHU2 = Util.null2String(rs.getString("BEIZHU2"));// BEIZHU2
						BEIZHU3 = Util.null2String(rs.getString("BEIZHU3"));// BEIZHU3

						log.writeLog("isfee:" + isfee);// 是否有运费
						log.writeLog("inout:" + inout);// 运入运出
						log.writeLog("plantransdate:" + plantransdate);// 预计运输日期
						log.writeLog("plantranstime:" + plantranstime);// 预计运输时间
						log.writeLog("transtype:" + transtype);// 运输方式

						log.writeLog("pono:" + pono);// 采购订单号
						log.writeLog("poitem:" + poitem);// 采购订单项次
						log.writeLog("prno:" + prno);// 请购申请单号
						log.writeLog("pritem:" + pritem);// 请购申请项次
						log.writeLog("goodgroup:" + goodgroup);// 产品组
						log.writeLog("wlh:" + wlh);// 物料号码
						log.writeLog("wlname:" + wlname);// 物料描述
						log.writeLog("jhyzl:" + jhyzl);// 计划运载量
						log.writeLog("yyzl:" + yyzl);// 已运载量
						log.writeLog("syyzl:" + syyzl);// 剩余运载量
						log.writeLog("unitcode:" + unitcode);// 单位代码（T/桶）
						log.writeLog("kwcode:" + kwcode);// 库位代码
						log.writeLog("unitdesc:" + unitdesc);// 单位描述
						log.writeLog("kwdesc:" + kwdesc);// 库存地址
						log.writeLog("packxz:" + packxz);// 包装性质
						log.writeLog("shipto:" + shipto);// 送达方
						log.writeLog("shiptoname:" + shiptoname);// 送达方名称
						log.writeLog("shiptoaddr:" + shiptoaddr);// 送达地址描述
						log.writeLog("shipcity:" + shipcity);// 送达城市点
						log.writeLog("soldto:" + soldto);// 售达方
						log.writeLog("soldtoname:" + soldtoname);// 售达方名称
						log.writeLog("sfgf:" + sfgf);// 是否固废
						log.writeLog("isdanger:" + isdanger);// 危险品标识
						log.writeLog("hbkpyz:" + hbkpyz);// 合并开票原则
						log.writeLog("costcenter:" + costcenter);// 成本中心
						log.writeLog("gyscode:" + gyscode);// 供应商代码
						log.writeLog("gysname:" + gysname);// 供应商名称
						log.writeLog("packcode:" + packcode);// 包装代码
						log.writeLog("BUKRS:" + BUKRS);// 公司代码
						log.writeLog("EKORG:" + EKORG);// 采购组织
						log.writeLog("BSART:" + BSART);// 采购凭证类型
						log.writeLog("WERKS:" + WERKS);// 工厂
						log.writeLog("MENGE:" + MENGE);// 采购订单数量
						log.writeLog("LFIMG:" + LFIMG);// LFIMG
						log.writeLog("EINDT:" + EINDT);// 项目交货日期
						log.writeLog("EKGRP:" + EKGRP);// 采购组
						log.writeLog("MTART:" + MTART);// 物料类型
						log.writeLog("LOEKZ:" + LOEKZ);// 采购凭证删除标识
						log.writeLog("UEBTO:" + UEBTO);// 过量交货限度
						log.writeLog("UEBTK:" + UEBTK);// 标识：允许未限制的过量交货
						log.writeLog("UNTTO:" + UNTTO);// 交货不足限度
						log.writeLog("BSART1:" + BSART1);// 订单类型（采购）
						log.writeLog("AFNAM:" + AFNAM);// 需求者/要求者名称
						log.writeLog("NAME2:" + NAME2);// 名称2
						log.writeLog("CHARG:" + CHARG);// 批号
						log.writeLog("ANLN1:" + ANLN1);// 主资产号
						log.writeLog("ZYUP:" + ZYUP);// 是否上传sap
						log.writeLog("ZGMZBH:" + ZGMZBH);// 购买证编号
						log.writeLog("ZMATNR:" + ZMATNR);// 物料编号
						log.writeLog("ZMENGE1:" + ZMENGE1);// 采购订单数量
						log.writeLog("ZMEINS1:" + ZMEINS1);// 采购订单计量单位
						log.writeLog("ZDATELOW2:" + ZDATELOW2);// 可用（可供货的）开始日期
						log.writeLog("ZDATEHIGH2:" + ZDATEHIGH2);// 可用(可供货的)截至日期
						log.writeLog("ZCHARG:" + ZCHARG);// ZCHARG
						log.writeLog("RETPO:" + RETPO);// 退货项目
						log.writeLog("UMSON:" + UMSON);// 免费项目
						log.writeLog("BEIZHU1:" + BEIZHU1);// BEIZHU1
						log.writeLog("BEIZHU2:" + BEIZHU2);// BEIZHU2
						log.writeLog("BEIZHU3:" + BEIZHU3);// BEIZHU3

						StringBuffer buffer = new StringBuffer();
						buffer.append("insert into uf_jmclxq");
						buffer.append(
								"(REQUESTID,FORMMODEID,MODEDATACREATER,pono,poitem,prno,pritem,goodgroup,wlh,wlname,jhyzl,yyzl,syyzl,unitcode,kwcode,unitdesc,kwdesc,packxz,shipto,shiptoname,shiptoaddr,shipcity,soldto,soldtoname,sfgf,isdanger,hbkpyz,costcenter,gyscode,gysname,packcode,BUKRS,EKORG,BSART,WERKS,MENGE,LFIMG,EINDT,EKGRP,MTART,LOEKZ,UEBTO,UEBTK,UNTTO,BSART1,AFNAM,NAME2,CHARG,ANLN1,ZYUP,ZGMZBH,ZMATNR,ZMENGE1,ZMEINS1,ZDATELOW2,ZDATEHIGH2,ZCHARG,RETPO,UMSON,BEIZHU1,BEIZHU2,BEIZHU3,isfee,inout,plantransdate,plantranstime,transtype) values");
						buffer.append("('").append(requestid).append("',");
						buffer.append("'").append("60").append("',");
						buffer.append("'").append(userid).append("',");
						buffer.append("'").append(pono).append("',");
						buffer.append("'").append(poitem).append("',");
						buffer.append("'").append(prno).append("',");
						buffer.append("'").append(pritem).append("',");
						buffer.append("'").append(goodgroup).append("',");
						buffer.append("'").append(wlh).append("',");
						buffer.append("'").append(wlname).append("',");
						buffer.append("'").append(jhyzl).append("',");
						buffer.append("'").append(yyzl).append("',");
						buffer.append("'").append(syyzl).append("',");
						buffer.append("'").append(unitcode).append("',");
						buffer.append("'").append(kwcode).append("',");
						buffer.append("'").append(unitdesc).append("',");
						buffer.append("'").append(kwdesc).append("',");
						buffer.append("'").append(packxz).append("',");
						buffer.append("'").append(shipto).append("',");
						buffer.append("'").append(shiptoname).append("',");
						buffer.append("'").append(shiptoaddr).append("',");
						buffer.append("'").append(shipcity).append("',");
						buffer.append("'").append(soldto).append("',");
						buffer.append("'").append(soldtoname).append("',");
						buffer.append("'").append(sfgf).append("',");
						buffer.append("'").append(isdanger).append("',");
						buffer.append("'").append(hbkpyz).append("',");
						buffer.append("'").append(costcenter).append("',");
						buffer.append("'").append(gyscode).append("',");
						buffer.append("'").append(gysname).append("',");
						buffer.append("'").append(packcode).append("',");
						buffer.append("'").append(BUKRS).append("',");
						buffer.append("'").append(EKORG).append("',");
						buffer.append("'").append(BSART).append("',");
						buffer.append("'").append(WERKS).append("',");
						buffer.append("'").append(MENGE).append("',");
						buffer.append("'").append(LFIMG).append("',");
						buffer.append("'").append(EINDT).append("',");
						buffer.append("'").append(EKGRP).append("',");
						buffer.append("'").append(MTART).append("',");
						buffer.append("'").append(LOEKZ).append("',");
						buffer.append("'").append(UEBTO).append("',");
						buffer.append("'").append(UEBTK).append("',");
						buffer.append("'").append(UNTTO).append("',");
						buffer.append("'").append(BSART1).append("',");
						buffer.append("'").append(AFNAM).append("',");
						buffer.append("'").append(NAME2).append("',");
						buffer.append("'").append(CHARG).append("',");
						buffer.append("'").append(ANLN1).append("',");
						buffer.append("'").append(ZYUP).append("',");
						buffer.append("'").append(ZGMZBH).append("',");
						buffer.append("'").append(ZMATNR).append("',");
						buffer.append("'").append(ZMENGE1).append("',");
						buffer.append("'").append(ZMEINS1).append("',");
						buffer.append("'").append(ZDATELOW2).append("',");
						buffer.append("'").append(ZDATEHIGH2).append("',");
						buffer.append("'").append(ZCHARG).append("',");
						buffer.append("'").append(RETPO).append("',");
						buffer.append("'").append(UMSON).append("',");
						buffer.append("'").append(BEIZHU1).append("',");
						buffer.append("'").append(BEIZHU2).append("',");
						buffer.append("'").append(BEIZHU3).append("',");
						buffer.append("'").append(isfee).append("',");
						buffer.append("'").append(inout).append("',");
						buffer.append("'").append(plantransdate).append("',");
						buffer.append("'").append(plantranstime).append("',");
						buffer.append("'").append(transtype).append("')");
						log.writeLog("插入建模表的sql:" + buffer.toString());
						rs2.executeSql(buffer.toString());

						StringBuffer sb = new StringBuffer();// 插入权限表
						sb.append("insert into MODEDATASHARE_421");
						sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
						sb.append("(").append("(select id from uf_jmclxq where REQUESTID = '" + requestid + "')")
								.append(",");
						sb.append("'").append("1").append("',");
						sb.append("'").append("1").append("',");
						sb.append("'").append("0").append("',");
						sb.append("'").append("3").append("')");
						log.writeLog("插入权限执行的sql:" + sb.toString());
						rs1.executeSql(sb.toString());// 先插入主表
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
}
