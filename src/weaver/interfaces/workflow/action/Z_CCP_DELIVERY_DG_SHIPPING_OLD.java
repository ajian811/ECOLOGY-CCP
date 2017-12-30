package weaver.interfaces.workflow.action;

import java.text.SimpleDateFormat;
import java.util.*;

import com.sap.mw.jco.IFunctionTemplate;
import com.sap.mw.jco.JCO;
import com.weaver.integration.datesource.SAPInterationDateSourceImpl;
import com.weaver.integration.log.LogInfo;

import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.hrm.resource.ResourceComInfo;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.workflow.WorkflowComInfo;

/**
 *
 * @author jisuqiang
 * @date 2017-11-10
 */
public class Z_CCP_DELIVERY_DG_SHIPPING_OLD extends BaseBean implements Action {
	// shipping柜号输入接口
	public String execute(RequestInfo request) {
		BaseBean log = new BaseBean();

		log.writeLog("调用Z_CCP_DELIVERY_DG_SHIPPING开始");
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
			// e-weaver字段
			String SHIPADVSTATUS = "";// shippingadvice状态
			String SHIPADVICENO = "";// shippingadvice单号
			String ETD = "";// 预计开航日ETD
			String DELIVERYNO = "";// 交运单号
			String DELIVERYITEM = "";// 交运单项次
			String SALEORDER = "";// 销售订单号
			String ORDERITEM = "";// 销售订单项次
			String STOCKNO = "";// 物料号
			String STOCKDESC = "";// 物料描述
			String LOCATION = "";// 库位
			String SHIPNUM = "";// 出货数量
			String SALEUNIT = "";// 出货单位
			String SHIPTO = "";// 送达方名称
			String SHIPTOADDR = "";// 送达方地址
			String REALSHIPNUM = "";// 实际出货数量
			String COSTCENTER = "";// 成本中心
			String REMARK = "";// 备注
			String PROCATEGORY = "";// 产品大类
			String LCEN = "";// 利润中心
			String SHIPM = "";// ShippingMark
			String SPECNEED = "";// 特殊需求
			String MATERDES = "";// 客户物料描述
			String CUSORDNO = "";// 客户订单编号
			String ORDERADVICENO = "";// OrderAdvice编号
			String SOLDTO = "";// 售达方名称
			String SOLDTOADDR = "";// 售达方地址
			String sfyg = "";// 是否有柜
			String COMCODE = "";// 公司代码
			String CONTAINTYPE = "";// 货柜预定类型
			String CONTAINQUAN = "";// 柜数
			String ETA = "";// ETA
			String EREQUESTID = "";// e-weaver的requestid

			// sap字段
			String AUART = "";// 销售凭证类型
			String BSTNK = "";// 客户采购订单编号
			String KUNAG = "";// 售达方简码
			String KUNNR = "";// 运达方简码
			String TEL_NUMBER = "";// 第一个电话号码：区号 + 号码
			String LGOBE = "";// 仓储地点的描述 （库位描述）
			String MAKTX = "";// 物料描述
			String LFIMG = "";// 实际已交货量（按销售单位）
			String MSEHT = "";// 度量单位文本(最多10个字符)
			String BRGEW = "";// 毛重
			String WERKS = "1010";// 工厂
			String KDMAT = "";// 客户物料
			String VKAUS = "";// 散装固定包装(包装别)
			String WADAT = "";// 计划货物移动日期
			String SPECS = "";// 规格
			String CHARG = "";// 批号
			String PACK = "";// 包装性质
			String AESKD = "";// 客户工程修改状态
			String VSTEL = "";// 装运点/接收点
			String LPRIO = "";// 交货优先级
			String SDABW = "";// 特殊处理标记
			String NTGEW = "";// 净重量
			String SGTXT = "";// 项目文本
			String TKNUM = "";// 装运编号
			String EXTI1 = "";// 外部识别 1
			String SIGNI = "";// 容器 ID
			String TNDR_TRKID = "";// 货运代理追踪标识
			String ADD01 = "";// 供应量 1
			String ADD02 = "";// 供应量 2
			String ADD03 = "";// 供应量 3
			String TEXT1 = "";// 附加文本 1
			String NAME1 = "";// 名称 1
			String BSTKD = "";// 客户采购订单编号
			String KOSTK = "";// 全部拣配/堆放状态
			String FERTH = "";// 生产/检验备忘录
			String SPART = "";// 产品组
			String ORMNG = "";// 装运通知/内向交货的原始数量
			String ZGMZBH = "";// 购买证编号
			String ZADDFLAG = "";// 是否为苏州大市（X=是）
			String ZYSZBH = "";// 运输证编号
			String ZMENGE1 = "";// 采购订单数量1
			String ZMENGE2 = "";// 采购订单数量2
			String ZMEINS1 = "";// 采购订单计量单位1
			String ZMEINS2 = "";// 采购订单计量单位2
			String ZMATNR = "";// 物料编号
			String ZKUNNR = "";// 运输公司编号
			String ZKUNNRTXT = "";// 运输公司名称
			String ZDATELOW1 = "";// 可用（可供货的）开始日期
			String ZDATEHIGH1 = "";// 可用(可供货的)截至日期
			String ZDATELOW2 = "";// 可用（可供货的）开始日期
			String ZDATEHIGH2 = "";// 可用(可供货的)截至日期
			String ZCARS = "";// 车号,逗号区分
			String ZYUP = "";// 是否上传sap
			String UEBTO = "";// 过量交货限度
			String UEBTK = "";// 标识：允许未限制的过量交货 X
			String UNTTO = "";// 交货不足限度 5%
			String ZCHARG = "";// 批次备注
			String ZDEL = "";// 删除
			String REMARK1 = "";// beizhu1
			String REMARK2 = "";// beizhu2
			String REMARK3 = "";// beizhu3
			String ZWEIGHT = "";// 包材重量

			String VBELN_VL = "";// sap交运单号
			String POSNR_VL = "";// sap交运项次

			/*
			 * update shipping
			 */
			String[] shippings = null;// 主表shipping
			String mainSql = "select * from " + tablename + " where requestid = '" + requestid + "'";
			if (rs3.execute(mainSql)) {
				if (rs3.next()) {
					shippings = rs3.getString("shipping").split(",");
				}
			}

			/*
			 * 更新shipping update by jisuqiang
			 * 
			 * @data 2017-12-23 情况分析 : 1.当数据库没有shipping时，直接插入
			 * 2.当数据库shipping的运货数量=0时，删除数据库原有的，插入新的
			 * 3.当数据库shipping>0时，去匹配数据库的的单号和项次，如果提交的单号和项次与数据库不匹配，则返回error，如果全部匹配
			 * ，则更新部分字段（注：字段由SAP提供）
			 */
			boolean falg = true;
			String type = "0";
			List<Map<String, String>> list = new ArrayList<Map<String, String>>();
			if (shippings.length > 0) {
				for (int i = 0; i < shippings.length; i++) {
					Map<String, String> map = new HashMap<String, String>();
					String sql = "select sum(ychl) as count,shipadviceno from UF_SPGHSR group by shipadviceno having shipadviceno = '"
							+ shippings[i] + "'";
					rs3.execute(sql);
					if (rs3.next()) {
						String count = rs3.getString("count");
						if ("0".equals(count)) {
							type = "0";// 数据库中shipping的数量=0
							map.put("shipadviceno", shippings[i]);
							map.put("type", type);
						} else {
							type = "1";// 数据库中shipping的数量=0
							map.put("shipadviceno", shippings[i]);
							map.put("type", type);
						}

					} else {
						type = "-1";// 数据库没有shipping
						map.put("shipadviceno", shippings[i]);
						map.put("type", type);
					}
					list.add(map);
				}
			}

			for (int i = 0; i < list.size(); i++) {
				String sql1 = "select t2.* from " + tablename + " t1";
				sql1 += " left join " + tablename + "_dt2 t2 on t1.id = t2.mainid";
				sql1 += " where 1=1";
				sql1 += " and t1.requestid= " + requestid;
				sql1 += " and t2.shipadviceno= " + list.get(i).get("shipadviceno");
				log.writeLog("查询明细执行的log" + sql1);
				rs.executeSql(sql1);

				if ("-1".equals(list.get(i).get("type"))) {
					// 数据库没有这个shipping，直接插入
				}
			}

			String sql1 = "select t2.* from " + tablename + " t1";
			sql1 += " left join " + tablename + "_dt2 t2 on t1.id = t2.mainid";
			sql1 += " where t1.requestid= " + requestid;
			log.writeLog("查询明细执行的log" + sql1);
			rs.executeSql(sql1);

			String sources = "";
			if (!workflowId.equals("")) {
				rs1.executeSql("select SAPSource from workflow_base where id=" + workflowId);
				if (rs1.next())
					sources = rs1.getString(1);
			}
			log.writeLog("sources=" + sources);

			SAPInterationDateSourceImpl sapidsi = new SAPInterationDateSourceImpl();
			sapconnection = (JCO.Client) sapidsi.getConnection(sources, new LogInfo());
			log.writeLog("创建SAP连接");
			String strFunc = "Z_DELIVERY_TRAN_OA";
			// List list = new ArrayList();
			while (rs.next()) {
				DELIVERYNO = Util.null2String(rs.getString("DELIVERYNO"));// 交运单号
				DELIVERYITEM = formatString(Util.null2String(rs.getString("DELIVERYITEM")));// 交运项次

				SHIPADVSTATUS = Util.null2String(rs.getString("SHIPADVSTATUS"));// shippingadvice状态
				SHIPADVICENO = Util.null2String(rs.getString("SHIPADVICENO"));// shippingadvice单号
				ETD = Util.null2String(rs.getString("ETD"));// 预计开航日ETD
				SALEORDER = Util.null2String(rs.getString("SALEORDER"));// 销售订单号
				ORDERITEM = Util.null2String(rs.getString("ORDERITEM"));// 销售订单项次
				STOCKNO = Util.null2String(rs.getString("STOCKNO"));// 物料号
				STOCKDESC = Util.null2String(rs.getString("STOCKDESC"));// 物料描述
				LOCATION = Util.null2String(rs.getString("LOCATION"));// 库位
				SHIPNUM = Util.null2String(rs.getString("SHIPNUM"));// 出货数量
				SALEUNIT = Util.null2String(rs.getString("SALEUNIT"));// 出货单位
				SHIPTO = Util.null2String(rs.getString("SHIPTO"));// 送达方名称
				SHIPTOADDR = Util.null2String(rs.getString("SHIPTOADDR"));// 送达方地址
				REALSHIPNUM = Util.null2String(rs.getString("REALSHIPNUM"));// 实际出货数量
				COSTCENTER = Util.null2String(rs.getString("COSTCENTER"));// 成本中心
				REMARK = Util.null2String(rs.getString("REMARK"));// 备注
				PROCATEGORY = Util.null2String(rs.getString("PROCATEGORY"));// 产品大类
				LCEN = Util.null2String(rs.getString("LCEN"));// 利润中心
				SHIPM = Util.null2String(rs.getString("SHIPM"));// ShippingMark
				SPECNEED = Util.null2String(rs.getString("SPECNEED"));// 特殊需求
				MATERDES = Util.null2String(rs.getString("MATERDES"));// 客户物料描述
				CUSORDNO = Util.null2String(rs.getString("CUSORDNO"));// 客户订单编号
				ORDERADVICENO = Util.null2String(rs.getString("ORDERADVICENO"));// OrderAdvice编号
				SOLDTO = Util.null2String(rs.getString("SOLDTO"));// 售达方名称
				SOLDTOADDR = Util.null2String(rs.getString("SOLDTOADDR"));// 售达方地址
				// sfyg = Util.null2String(rs.getString("sfyg"));//是否有柜
				COMCODE = Util.null2String(rs.getString("COMCODE"));// 公司代码
				CONTAINTYPE = Util.null2String(rs.getString("CONTAINTYPE"));// 货柜预定类型
				CONTAINQUAN = Util.null2String(rs.getString("CONTAINQUAN"));// 柜数
				ETA = Util.null2String(rs.getString("ETA"));// ETA
				EREQUESTID = Util.null2String(rs.getString("EREQUESTID"));// EREQUESTID

				// 填写参数
				JCO.Repository myRepository = new JCO.Repository("Repository", sapconnection);
				IFunctionTemplate ft = myRepository.getFunctionTemplate(strFunc.toUpperCase());
				JCO.Function function = ft.getFunction();
				function.getImportParameterList().setValue("DOWN", "FLAG");
				JCO.Table inTableParams = function.getTableParameterList().getTable("IT_HEAD_O");
				inTableParams.appendRow();
				inTableParams.setValue(DELIVERYNO, "VBELN_VL");
				inTableParams.setValue(DELIVERYNO, "VBELN_VT");
				inTableParams.setValue(DELIVERYITEM, "POSNR");
				inTableParams.setValue(COMCODE, "WERKS");
				sapconnection.execute(function);
				log.writeLog("执行function获取sap数据");

				// 获取数据
				JCO.Table output = function.getTableParameterList().getTable("IT_ITEM_O");

				for (int i = 0; i < output.getNumRows(); i++) {
					String ychl = "";// 已出货量
					// HashMap tempMap = new HashMap();
					// sap数据
					VBELN_VL = output.getString("VBELN_VL");// 交货
					POSNR_VL = output.getString("POSNR_VL");// 交货项目
					log.writeLog("VBELN_VL:" + VBELN_VL);
					log.writeLog("POSNR_VL:" + POSNR_VL);

					// // 判断建模表里面是否有数据
					// rs1.executeSql("select * from UF_SPGHSR where DELIVERYNO
					// ='" + DELIVERYNO + "' and DELIVERYITEM ='"
					// + DELIVERYITEM + "'");
					// int count = 0;
					// if (rs1.next()) {
					// ychl = Util.null2String(rs1.getString("ychl"));
					// count++;
					// }
					// log.writeLog("count", count);// 交运单项

					// 用交运单号和交运项次和sap的数据进行匹配
					if (DELIVERYNO.equals(VBELN_VL) && DELIVERYITEM.equals(POSNR_VL)) {

						AUART = output.getString("AUART");// 销售凭证类型
						BSTNK = output.getString("BSTNK");// 客户采购订单编号
						KUNAG = output.getString("KUNAG");// 售达方简码
						KUNNR = output.getString("KUNNR");// 运达方简码
						TEL_NUMBER = output.getString("TEL_NUMBER");// 第一个电话号码：区号
																	// +
																	// 号码
						LGOBE = output.getString("LGOBE");// 仓储地点的描述 （库位描述）
						MAKTX = output.getString("MAKTX");// 物料描述
						LFIMG = output.getString("LFIMG");// 实际已交货量（按销售单位）
						MSEHT = output.getString("MSEHT");// 度量单位文本(最多10个字符)
						BRGEW = output.getString("BRGEW");// 毛重
						WERKS = output.getString("WERKS");// 工厂
						KDMAT = output.getString("KDMAT");// 客户物料
						VKAUS = output.getString("VKAUS");// 散装固定包装(包装别)
						WADAT = output.getString("WADAT");// 计划货物移动日期
						SPECS = output.getString("SPECS");// 规格
						CHARG = output.getString("CHARG");// 批号
						PACK = output.getString("PACK");// 包装性质
						AESKD = output.getString("AESKD");// 客户工程修改状态
						VSTEL = output.getString("VSTEL");// 装运点/接收点
						LPRIO = output.getString("LPRIO");// 交货优先级
						SDABW = output.getString("SDABW");// 特殊处理标记
						NTGEW = output.getString("NTGEW");// 净重量
						SGTXT = output.getString("SGTXT");// 项目文本
						TKNUM = output.getString("TKNUM");// 装运编号
						EXTI1 = output.getString("EXTI1");// 外部识别 1
						SIGNI = output.getString("SIGNI");// 容器 ID
						TNDR_TRKID = output.getString("TNDR_TRKID");// 货运代理追踪标识
						ADD01 = output.getString("ADD01");// 供应量 1
						ADD02 = output.getString("ADD02");// 供应量 2
						ADD03 = output.getString("ADD03");// 供应量 3
						TEXT1 = output.getString("TEXT1");// 附加文本 1
						NAME1 = output.getString("NAME1");// 名称 1
						BSTKD = output.getString("BSTKD");// 客户采购订单编号
						KOSTK = output.getString("KOSTK");// 全部拣配/堆放状态
						FERTH = output.getString("FERTH");// 生产/检验备忘录
						SPART = output.getString("SPART");// 产品组
						ORMNG = output.getString("ORMNG");// 装运通知/内向交货的原始数量
						ZGMZBH = output.getString("ZGMZBH");// 购买证编号
						ZADDFLAG = output.getString("ZADDFLAG");// 是否为苏州大市（X=是）
						ZYSZBH = output.getString("ZYSZBH");// 运输证编号
						ZMENGE1 = output.getString("ZMENGE1");// 采购订单数量1
						ZMENGE2 = output.getString("ZMENGE2");// 采购订单数量2
						ZMEINS1 = output.getString("ZMEINS1");// 采购订单计量单位1
						ZMEINS2 = output.getString("ZMEINS2");// 采购订单计量单位2
						ZMATNR = output.getString("ZMATNR");// 物料编号
						ZKUNNR = output.getString("ZKUNNR");// 运输公司编号
						ZKUNNRTXT = output.getString("ZKUNNRTXT");// 运输公司名称
						ZDATELOW1 = output.getString("ZDATELOW1");// 可用（可供货的）开始日期
						ZDATEHIGH1 = output.getString("ZDATEHIGH1");// 可用(可供货的)截至日期
						ZDATELOW2 = output.getString("ZDATELOW2");// 可用（可供货的）开始日期
						ZDATEHIGH2 = output.getString("ZDATEHIGH2");// 可用(可供货的)截至日期
						ZCARS = output.getString("ZCARS");// 车号,逗号区分
						ZYUP = output.getString("ZYUP");// 是否上传sap
						UEBTO = output.getString("UEBTO");// 过量交货限度
						UEBTK = output.getString("UEBTK");// 标识：允许未限制的过量交货 X
						UNTTO = output.getString("UNTTO");// 交货不足限度 5%
						// ZCHARG = output.getString("ZCHARG");//批次备注
						ZDEL = output.getString("ZDEL");// 删除
						REMARK1 = output.getString("REMARK1");// beizhu1
						REMARK2 = output.getString("REMARK2");// beizhu2
						REMARK3 = output.getString("REMARK3");// beizhu3
						ZWEIGHT = output.getString("ZWEIGHT");// 包材重量

						// 打印log
						log.writeLog("VBELN_VL", VBELN_VL);// 交运单号
						log.writeLog("POSNR_VL", POSNR_VL);// 交运项次
						log.writeLog("SHIPADVSTATUS", SHIPADVSTATUS);// shippingadvice状态
						log.writeLog("SHIPADVICENO", SHIPADVICENO);// shippingadvice单号
						log.writeLog("ETD", ETD);// 预计开航日ETD
						log.writeLog("DELIVERYNO", DELIVERYNO);// 交运单号
						log.writeLog("DELIVERYITEM", DELIVERYITEM);// 交运单项次
						log.writeLog("SALEORDER", SALEORDER);// 销售订单号
						log.writeLog("ORDERITEM", ORDERITEM);// 销售订单项次
						log.writeLog("STOCKNO", STOCKNO);// 物料号
						log.writeLog("STOCKDESC", STOCKDESC);// 物料描述
						log.writeLog("LOCATION", LOCATION);// 库位
						log.writeLog("SHIPNUM", SHIPNUM);// 出货数量
						log.writeLog("SALEUNIT", SALEUNIT);// 出货单位
						log.writeLog("SHIPTO", SHIPTO);// 送达方名称
						log.writeLog("SHIPTOADDR", SHIPTOADDR);// 送达方地址
						log.writeLog("REALSHIPNUM", REALSHIPNUM);// 实际出货数量
						log.writeLog("COSTCENTER", COSTCENTER);// 成本中心
						log.writeLog("REMARK", REMARK);// 备注
						log.writeLog("PROCATEGORY", PROCATEGORY);// 产品大类
						log.writeLog("LCEN", LCEN);// 利润中心
						log.writeLog("SHIPM", SHIPM);// ShippingMark
						log.writeLog("SPECNEED", SPECNEED);// 特殊需求
						log.writeLog("MATERDES", MATERDES);// 客户物料描述
						log.writeLog("CUSORDNO", CUSORDNO);// 客户订单编号
						log.writeLog("ORDERADVICENO", ORDERADVICENO);// OrderAdvice编号
						log.writeLog("SOLDTO", SOLDTO);// 售达方名称
						log.writeLog("SOLDTOADDR", SOLDTOADDR);// 售达方地址
						log.writeLog("AUART", AUART);// 销售凭证类型
						log.writeLog("BSTNK", BSTNK);// 客户采购订单编号
						log.writeLog("KUNAG", KUNAG);// 售达方简码
						log.writeLog("KUNNR", KUNNR);// 运达方简码
						log.writeLog("TEL_NUMBER", TEL_NUMBER);// 第一个电话号码：区号
																// +
																// 号码
						// log.writeLog("sfyg", sfyg);// 是否有柜
						log.writeLog("COMCODE", COMCODE);// 公司代码
						log.writeLog("CONTAINTYPE", CONTAINTYPE);// 货柜预定类型
						log.writeLog("CONTAINQUAN", CONTAINQUAN);// 柜数

						log.writeLog("LGOBE", LGOBE);// 仓储地点的描述 （库位描述）
						log.writeLog("MAKTX", MAKTX);// 物料描述
						log.writeLog("LFIMG", LFIMG);// 实际已交货量（按销售单位）
						log.writeLog("MSEHT", MSEHT);// 度量单位文本(最多10个字符)
						log.writeLog("BRGEW", BRGEW);// 毛重
						log.writeLog("WERKS", WERKS);// 工厂
						log.writeLog("KDMAT", KDMAT);// 客户物料
						log.writeLog("VKAUS", VKAUS);// 散装固定包装(包装别)
						log.writeLog("WADAT", WADAT);// 计划货物移动日期
						log.writeLog("SPECS", SPECS);// 规格
						log.writeLog("CHARG", CHARG);// 批号
						log.writeLog("PACK", PACK);// 包装性质
						log.writeLog("AESKD", AESKD);// 客户工程修改状态
						log.writeLog("VSTEL", VSTEL);// 装运点/接收点
						log.writeLog("LPRIO", LPRIO);// 交货优先级
						log.writeLog("SDABW", SDABW);// 特殊处理标记
						log.writeLog("NTGEW", NTGEW);// 净重量
						log.writeLog("SGTXT", SGTXT);// 项目文本
						log.writeLog("TKNUM", TKNUM);// 装运编号
						log.writeLog("EXTI1", EXTI1);// 外部识别 1
						log.writeLog("SIGNI", SIGNI);// 容器 ID
						log.writeLog("TNDR_TRKID", TNDR_TRKID);// 货运代理追踪标识
						log.writeLog("ADD01", ADD01);// 供应量 1
						log.writeLog("ADD02", ADD02);// 供应量 2
						log.writeLog("ADD03", ADD03);// 供应量 3
						log.writeLog("TEXT1", TEXT1);// 附加文本 1
						log.writeLog("NAME1", NAME1);// 名称 1
						log.writeLog("BSTKD", BSTKD);// 客户采购订单编号
						log.writeLog("KOSTK", KOSTK);// 全部拣配/堆放状态
						log.writeLog("FERTH", FERTH);// 生产/检验备忘录
						log.writeLog("SPART", SPART);// 产品组
						log.writeLog("ORMNG", ORMNG);// 装运通知/内向交货的原始数量
						log.writeLog("ZGMZBH", ZGMZBH);// 购买证编号
						log.writeLog("ZADDFLAG", ZADDFLAG);// 是否为苏州大市（X=是）
						log.writeLog("ZYSZBH", ZYSZBH);// 运输证编号
						log.writeLog("ZMENGE1", ZMENGE1);// 采购订单数量1
						log.writeLog("ZMENGE2", ZMENGE2);// 采购订单数量2
						log.writeLog("ZMEINS1", ZMEINS1);// 采购订单计量单位1
						log.writeLog("ZMEINS2", ZMEINS2);// 采购订单计量单位2
						log.writeLog("ZMATNR", ZMATNR);// 物料编号
						log.writeLog("ZKUNNR", ZKUNNR);// 运输公司编号
						log.writeLog("ZKUNNRTXT", ZKUNNRTXT);// 运输公司名称
						log.writeLog("ZDATELOW1", ZDATELOW1);// 可用（可供货的）开始日期
						log.writeLog("ZDATEHIGH1", ZDATEHIGH1);// 可用(可供货的)截至日期
						log.writeLog("ZDATELOW2", ZDATELOW2);// 可用（可供货的）开始日期
						log.writeLog("ZDATEHIGH2", ZDATEHIGH2);// 可用(可供货的)截至日期
						log.writeLog("ZCARS", ZCARS);// 车号,逗号区分
						log.writeLog("ZYUP", ZYUP);// 是否上传sap
						log.writeLog("UEBTO", UEBTO);// 过量交货限度
						log.writeLog("UEBTK", UEBTK);// 标识：允许未限制的过量交货 X
						log.writeLog("UNTTO", UNTTO);// 交货不足限度 5%
						log.writeLog("ZCHARG", ZCHARG);// 批次备注
						log.writeLog("ZDEL", ZDEL);// 删除
						log.writeLog("REMARK1", REMARK1);// beizhu1
						log.writeLog("REMARK2", REMARK2);// beizhu2
						log.writeLog("REMARK3", REMARK3);// beizhu3
						log.writeLog("ZWEIGHT", ZWEIGHT);// 包材重量

						StringBuffer buffer = new StringBuffer();

						buffer.append("insert into UF_SPGHSR");
						buffer.append(
								"(REQUESTID,SHIPADVSTATUS,SHIPADVICENO,ETD,ETA,EREQUESTID,DELIVERYNO,DELIVERYITEM,SALEORDER,ORDERITEM,STOCKNO,STOCKDESC,LOCATION,SHIPNUM,SALEUNIT,SHIPTO,SHIPTOADDR,REALSHIPNUM,COSTCENTER,REMARK,PROCATEGORY,LCEN,SHIPM,SPECNEED,MATERDES,CUSORDNO,ORDERADVICENO,SOLDTO,SOLDTOADDR,AUART,BSTNK,KUNAG,KUNNR,TEL_NUMBER,LGOBE,MAKTX,LFIMG,MSEHT,BRGEW,WERKS,KDMAT,VKAUS,WADAT,SPECS,CHARG,PACK,AESKD,VSTEL,LPRIO,SDABW,NTGEW,SGTXT,TKNUM,EXTI1,SIGNI,TNDR_TRKID,ADD01,ADD02,ADD03,TEXT1,NAME1,BSTKD,KOSTK,FERTH,SPART,ORMNG,ZGMZBH,ZADDFLAG,ZYSZBH,ZMENGE1,ZMENGE2,ZMEINS1,ZMEINS2,ZMATNR,ZKUNNR,ZKUNNRTXT,ZDATELOW1,ZDATEHIGH1,ZDATELOW2,ZDATEHIGH2,ZCARS,ZYUP,UEBTO,UEBTK,UNTTO,ZCHARG,ZDEL,COMCODE,CONTAINTYPE,CONTAINQUAN,ZWEIGHT,FORMMODEID,MODEDATACREATER,REMARK1,REMARK2,REMARK3) values");
						buffer.append("('").append(requestid).append("',");
						buffer.append("'").append(SHIPADVSTATUS).append("',");
						buffer.append("'").append(SHIPADVICENO).append("',");
						buffer.append("'").append(ETD).append("',");
						buffer.append("'").append(ETA).append("',");
						buffer.append("'").append(EREQUESTID).append("',");
						buffer.append("'").append(DELIVERYNO).append("',");
						buffer.append("'").append(DELIVERYITEM).append("',");
						buffer.append("'").append(SALEORDER).append("',");
						buffer.append("'").append(ORDERITEM).append("',");
						buffer.append("'").append(STOCKNO).append("',");
						buffer.append("'").append(STOCKDESC).append("',");
						buffer.append("'").append(LOCATION).append("',");
						buffer.append("'").append(SHIPNUM).append("',");
						buffer.append("'").append(SALEUNIT).append("',");
						buffer.append("'").append(SHIPTO).append("',");
						buffer.append("'").append(SHIPTOADDR).append("',");
						buffer.append("'").append(REALSHIPNUM).append("',");
						buffer.append("'").append(COSTCENTER).append("',");
						buffer.append("'").append(REMARK).append("',");
						buffer.append("'").append(PROCATEGORY).append("',");
						buffer.append("'").append(LCEN).append("',");
						buffer.append("'").append(SHIPM).append("',");
						buffer.append("'").append(SPECNEED).append("',");
						buffer.append("'").append(MATERDES).append("',");
						buffer.append("'").append(CUSORDNO).append("',");
						buffer.append("'").append(ORDERADVICENO).append("',");
						buffer.append("'").append(SOLDTO).append("',");
						buffer.append("'").append(SOLDTOADDR).append("',");
						buffer.append("'").append(AUART).append("',");
						buffer.append("'").append(BSTNK).append("',");
						buffer.append("'").append(KUNAG).append("',");
						buffer.append("'").append(KUNNR).append("',");
						buffer.append("'").append(TEL_NUMBER).append("',");
						buffer.append("'").append(LGOBE).append("',");
						buffer.append("'").append(MAKTX).append("',");
						buffer.append("'").append(LFIMG).append("',");
						buffer.append("'").append(MSEHT).append("',");
						buffer.append("'").append(BRGEW).append("',");
						buffer.append("'").append(WERKS).append("',");
						buffer.append("'").append(KDMAT).append("',");
						buffer.append("'").append(VKAUS).append("',");
						buffer.append("'").append(WADAT).append("',");
						buffer.append("'").append(SPECS).append("',");
						buffer.append("'").append(CHARG).append("',");
						buffer.append("'").append(PACK).append("',");
						buffer.append("'").append(AESKD).append("',");
						buffer.append("'").append(VSTEL).append("',");
						buffer.append("'").append(LPRIO).append("',");
						buffer.append("'").append(SDABW).append("',");
						buffer.append("'").append(NTGEW).append("',");
						buffer.append("'").append(SGTXT).append("',");
						buffer.append("'").append(TKNUM).append("',");
						buffer.append("'").append(EXTI1).append("',");
						buffer.append("'").append(SIGNI).append("',");
						buffer.append("'").append(TNDR_TRKID).append("',");
						buffer.append("'").append(ADD01).append("',");
						buffer.append("'").append(ADD02).append("',");
						buffer.append("'").append(ADD03).append("',");
						buffer.append("'").append(TEXT1).append("',");
						buffer.append("'").append(NAME1).append("',");
						buffer.append("'").append(BSTKD).append("',");
						buffer.append("'").append(KOSTK).append("',");
						buffer.append("'").append(FERTH).append("',");
						buffer.append("'").append(SPART).append("',");
						buffer.append("'").append(ORMNG).append("',");
						buffer.append("'").append(ZGMZBH).append("',");
						buffer.append("'").append(ZADDFLAG).append("',");
						buffer.append("'").append(ZYSZBH).append("',");
						buffer.append("'").append(ZMENGE1).append("',");
						buffer.append("'").append(ZMENGE2).append("',");
						buffer.append("'").append(ZMEINS1).append("',");
						buffer.append("'").append(ZMEINS2).append("',");
						buffer.append("'").append(ZMATNR).append("',");
						buffer.append("'").append(ZKUNNR).append("',");
						buffer.append("'").append(ZKUNNRTXT).append("',");
						buffer.append("'").append(ZDATELOW1).append("',");
						buffer.append("'").append(ZDATEHIGH1).append("',");
						buffer.append("'").append(ZDATELOW2).append("',");
						buffer.append("'").append(ZDATEHIGH2).append("',");
						buffer.append("'").append(ZCARS).append("',");
						buffer.append("'").append(ZYUP).append("',");
						buffer.append("'").append(UEBTO).append("',");
						buffer.append("'").append(UEBTK).append("',");
						buffer.append("'").append(UNTTO).append("',");
						buffer.append("'").append(ZCHARG).append("',");
						buffer.append("'").append(ZDEL).append("',");
						buffer.append("'").append(COMCODE).append("',");
						buffer.append("'").append(CONTAINTYPE).append("',");
						buffer.append("'").append(CONTAINQUAN).append("',");
						buffer.append("'").append(ZWEIGHT).append("',");
						buffer.append("'").append("421").append("',");
						buffer.append("'").append("1").append("',");
						buffer.append("'").append(REMARK1).append("',");
						buffer.append("'").append(REMARK2).append("',");
						buffer.append("'").append(REMARK3).append("')");
						log.writeLog("插入建模表的sql:" + buffer.toString());
						rs2.executeSql(buffer.toString());

						StringBuffer sb = new StringBuffer();// 插入权限表
						sb.append("insert into MODEDATASHARE_421");
						sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
						sb.append("(").append("(select id from UF_SPGHSR where DELIVERYNO = '" + DELIVERYNO
								+ "' and DELIVERYITEM = '" + DELIVERYITEM + "')").append(",");
						sb.append("'").append("1").append("',");
						sb.append("'").append("1").append("',");
						sb.append("'").append("0").append("',");
						sb.append("'").append("3").append("')");
						log.writeLog("插入权限执行的sql:" + sb.toString());
						rs1.executeSql(sb.toString());// 先插入主表
						// } else {
						// StringBuffer buffer = new StringBuffer();
						// buffer.append("update UF_SPGHSR set ");
						// buffer.append("ychl").append("='").append(ychl).append("',");//
						// 已出货量
						// buffer.append("VBELN_VL").append("='").append(VBELN_VL).append("',");//
						// 交运单号
						// buffer.append("SHIPADVSTATUS").append("='").append(SHIPADVSTATUS).append("',");//
						// shippingadvice状态
						// buffer.append("SHIPADVICENO").append("='").append(SHIPADVICENO).append("',");//
						// shippingadvice单号
						// buffer.append("POSNR_VL").append("='").append(POSNR_VL).append("',");//
						// 交运项次
						// buffer.append("ETD").append("='").append(ETD).append("',");//
						// 预计开航日ETD
						// buffer.append("SALEORDER").append("='").append(SALEORDER).append("',");//
						// 销售订单号
						// buffer.append("ORDERITEM").append("='").append(ORDERITEM).append("',");//
						// 销售订单项次
						// buffer.append("STOCKNO").append("='").append(STOCKNO).append("',");//
						// 物料号
						// buffer.append("STOCKDESC").append("='").append(STOCKDESC).append("',");//
						// 物料描述
						// buffer.append("LOCATION").append("='").append(LOCATION).append("',");//
						// 库位
						// buffer.append("SHIPNUM").append("='").append(SHIPNUM).append("',");//
						// 出货数量
						// buffer.append("SALEUNIT").append("='").append(SALEUNIT).append("',");//
						// 出货单位
						// buffer.append("SHIPTO").append("='").append(SHIPTO).append("',");//
						// 送达方名称
						// buffer.append("SHIPTOADDR").append("='").append(SHIPTOADDR).append("',");//
						// 送达方地址
						// buffer.append("REALSHIPNUM").append("='").append(REALSHIPNUM).append("',");//
						// 实际出货数量
						// buffer.append("COSTCENTER").append("='").append(COSTCENTER).append("',");//
						// 成本中心
						// buffer.append("REMARK").append("='").append(REMARK).append("',");//
						// 备注
						// buffer.append("PROCATEGORY").append("='").append(PROCATEGORY).append("',");//
						// 产品大类
						// buffer.append("LCEN").append("='").append(LCEN).append("',");//
						// 利润中心
						// buffer.append("SHIPM").append("='").append(SHIPM).append("',");//
						// ShippingMark
						// buffer.append("SPECNEED").append("='").append(SPECNEED).append("',");//
						// 特殊需求
						// buffer.append("MATERDES").append("='").append(MATERDES).append("',");//
						// 客户物料描述
						// buffer.append("CUSORDNO").append("='").append(CUSORDNO).append("',");//
						// 客户订单编号
						// buffer.append("ORDERADVICENO").append("='").append(ORDERADVICENO).append("',");//
						// OrderAdvice编号
						// buffer.append("SOLDTO").append("='").append(SOLDTO).append("',");//
						// 售达方名称
						// buffer.append("SOLDTOADDR").append("='").append(SOLDTOADDR).append("',");//
						// 售达方地址
						// buffer.append("AUART").append("='").append(AUART).append("',");//
						// 销售凭证类型
						// buffer.append("BSTNK").append("='").append(BSTNK).append("',");//
						// 客户采购订单编号
						// buffer.append("KUNAG").append("='").append(KUNAG).append("',");//
						// 售达方简码
						// buffer.append("KUNNR").append("='").append(KUNNR).append("',");//
						// 运达方简码
						// buffer.append("TEL_NUMBER").append("='").append(TEL_NUMBER).append("',");//
						// 第一个电话号码：区号
						// // +
						// // 号码
						// buffer.append("LGOBE").append("='").append(LGOBE).append("',");//
						// 仓储地点的描述
						// // （库位描述）
						// buffer.append("MAKTX").append("='").append(MAKTX).append("',");//
						// 物料描述
						// buffer.append("LFIMG").append("='").append(LFIMG).append("',");//
						// 实际已交货量（按销售单位）
						// buffer.append("BRGEW").append("='").append(BRGEW).append("',");//
						// 毛重
						// buffer.append("WERKS").append("='").append(WERKS).append("',");//
						// 工厂
						// buffer.append("KDMAT").append("='").append(KDMAT).append("',");//
						// 客户物料
						// buffer.append("VKAUS").append("='").append(VKAUS).append("',");//
						// 散装固定包装(包装别)
						// buffer.append("WADAT").append("='").append(WADAT).append("',");//
						// 计划货物移动日期
						// buffer.append("SPECS").append("='").append(SPECS).append("',");//
						// 规格
						// buffer.append("CHARG").append("='").append(CHARG).append("',");//
						// 批号
						// buffer.append("PACK").append("='").append(PACK).append("',");//
						// 包装性质
						// buffer.append("AESKD").append("='").append(AESKD).append("',");//
						// 客户工程修改状态
						// buffer.append("VSTEL").append("='").append(VSTEL).append("',");//
						// 装运点/接收点
						// buffer.append("LPRIO").append("='").append(LPRIO).append("',");//
						// 交货优先级
						// buffer.append("SDABW").append("='").append(SDABW).append("',");//
						// 特殊处理标记
						// buffer.append("NTGEW").append("='").append(NTGEW).append("',");//
						// 净重量
						// buffer.append("SGTXT").append("='").append(SGTXT).append("',");//
						// 项目文本
						// buffer.append("TKNUM").append("='").append(TKNUM).append("',");//
						// 装运编号
						// buffer.append("EXTI1").append("='").append(EXTI1).append("',");//
						// 外部识别
						// // 1
						// buffer.append("SIGNI").append("='").append(SIGNI).append("',");//
						// 容器
						// // ID
						// buffer.append("TNDR_TRKID").append("='").append(TNDR_TRKID).append("',");//
						// 货运代理追踪标识
						// buffer.append("ADD01").append("='").append(ADD01).append("',");//
						// 供应量
						// // 1
						// buffer.append("ADD02").append("='").append(ADD02).append("',");//
						// 供应量
						// // 2
						// buffer.append("ADD03").append("='").append(ADD03).append("',");//
						// 供应量
						// // 3
						// buffer.append("TEXT1").append("='").append(TEXT1).append("',");//
						// 附加文本
						// // 1
						// buffer.append("NAME1").append("='").append(NAME1).append("',");//
						// 名称
						// // 1
						// buffer.append("BSTKD").append("='").append(BSTKD).append("',");//
						// 客户采购订单编号
						// buffer.append("KOSTK").append("='").append(KOSTK).append("',");//
						// 全部拣配/堆放状态
						// buffer.append("FERTH").append("='").append(FERTH).append("',");//
						// 生产/检验备忘录
						// buffer.append("SPART").append("='").append(SPART).append("',");//
						// 产品组
						// buffer.append("ORMNG").append("='").append(ORMNG).append("',");//
						// 装运通知/内向交货的原始数量
						// buffer.append("ZGMZBH").append("='").append(ZGMZBH).append("',");//
						// 购买证编号
						// buffer.append("ZADDFLAG").append("='").append(ZADDFLAG).append("',");//
						// 是否为苏州大市（X=是）
						// buffer.append("ZYSZBH").append("='").append(ZYSZBH).append("',");//
						// 运输证编号
						// buffer.append("ZMENGE1").append("='").append(ZMENGE1).append("',");//
						// 采购订单数量1
						// buffer.append("ZMENGE2").append("='").append(ZMENGE2).append("',");//
						// 采购订单数量2
						// buffer.append("ZMEINS1").append("='").append(ZMEINS1).append("',");//
						// 采购订单计量单位1
						// buffer.append("ZMEINS2").append("='").append(ZMEINS2).append("',");//
						// 采购订单计量单位2
						// buffer.append("ZMATNR").append("='").append(ZMATNR).append("',");//
						// 物料编号
						// buffer.append("ZKUNNR").append("='").append(ZKUNNR).append("',");//
						// 运输公司编号
						// buffer.append("ZKUNNRTXT").append("='").append(ZKUNNRTXT).append("',");//
						// 运输公司名称
						// buffer.append("ZDATELOW1").append("='").append(ZDATELOW1).append("',");//
						// 可用（可供货的）开始日期
						// buffer.append("ZDATEHIGH1").append("='").append(ZDATEHIGH1).append("',");//
						// 可用(可供货的)截至日期
						// buffer.append("ZDATELOW2").append("='").append(ZDATELOW2).append("',");//
						// 可用（可供货的）开始日期
						// buffer.append("ZDATEHIGH2").append("='").append(ZDATEHIGH2).append("',");//
						// 可用(可供货的)截至日期
						// buffer.append("ZCARS").append("='").append(ZCARS).append("',");//
						// 车号,逗号区分
						// buffer.append("ZYUP").append("='").append(ZYUP).append("',");//
						// 是否上传sap
						// buffer.append("UEBTO").append("='").append(UEBTO).append("',");//
						// 过量交货限度
						// buffer.append("UEBTK").append("='").append(UEBTK).append("',");//
						// 标识：允许未限制的过量交货
						// // X
						// buffer.append("UNTTO").append("='").append(UNTTO).append("',");//
						// 交货不足限度
						// // 5%
						// buffer.append("ZCHARG").append("='").append(ZCHARG).append("',");//
						// 批次备注
						// buffer.append("ZDEL").append("='").append(ZDEL).append("',");//
						// 删除
						// buffer.append("REMARK1").append("='").append(REMARK1).append("',");//
						// beizhu1
						// buffer.append("REMARK2").append("='").append(REMARK2).append("',");//
						// beizhu2
						// buffer.append("REMARK3").append("='").append(REMARK3).append("',");//
						// beizhu3
						// buffer.append("COMCODE").append("='").append(COMCODE).append("',");//
						// 公司代码
						// buffer.append("CONTAINTYPE").append("='").append(CONTAINTYPE).append("',");//
						// 货柜预定类型
						// buffer.append("CONTAINQUAN").append("='").append(CONTAINQUAN).append("',");//
						// 柜数
						// buffer.append("MSEHT").append("='").append(MSEHT).append("',");//
						// 度量单位文本(最多10个字符)
						// buffer.append("ZWEIGHT").append("='").append(ZWEIGHT).append("',");//
						// 包材重量
						// buffer.append("ETA").append("='").append(ETA).append("',");//
						// ETA
						// buffer.append("EREQUESTID").append("='").append(EREQUESTID).append("',");//
						// EREQUESTID
						// buffer.append(" where 1 =1 ");
						// buffer.append(" and DELIVERYNO =
						// ").append("='").append(DELIVERYNO).append("'");
						// buffer.append(" and DELIVERYITEM =
						// ").append("='").append(DELIVERYITEM).append("'");
						//
						// if ("0".equals(ychl)) {
						//
						// } else if ("1".equals(ychl)) {
						//
						// }
						// }
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

	public void insertShipping(String requestid, String shipadviceno, String tablename, String workflowId) {
		JCO.Client sapconnection = null;
		BaseBean log = new BaseBean();
		try {

			Date d = new Date();
			SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
			String currdate1 = format.format(d);
			// e-weaver字段
			String SHIPADVSTATUS = "";// shippingadvice状态
			String SHIPADVICENO = "";// shippingadvice单号
			String ETD = "";// 预计开航日ETD
			String DELIVERYNO = "";// 交运单号
			String DELIVERYITEM = "";// 交运单项次
			String SALEORDER = "";// 销售订单号
			String ORDERITEM = "";// 销售订单项次
			String STOCKNO = "";// 物料号
			String STOCKDESC = "";// 物料描述
			String LOCATION = "";// 库位
			String SHIPNUM = "";// 出货数量
			String SALEUNIT = "";// 出货单位
			String SHIPTO = "";// 送达方名称
			String SHIPTOADDR = "";// 送达方地址
			String REALSHIPNUM = "";// 实际出货数量
			String COSTCENTER = "";// 成本中心
			String REMARK = "";// 备注
			String PROCATEGORY = "";// 产品大类
			String LCEN = "";// 利润中心
			String SHIPM = "";// ShippingMark
			String SPECNEED = "";// 特殊需求
			String MATERDES = "";// 客户物料描述
			String CUSORDNO = "";// 客户订单编号
			String ORDERADVICENO = "";// OrderAdvice编号
			String SOLDTO = "";// 售达方名称
			String SOLDTOADDR = "";// 售达方地址
			String sfyg = "";// 是否有柜
			String COMCODE = "";// 公司代码
			String CONTAINTYPE = "";// 货柜预定类型
			String CONTAINQUAN = "";// 柜数
			String ETA = "";// ETA
			String EREQUESTID = "";// e-weaver的requestid

			// sap字段
			String AUART = "";// 销售凭证类型
			String BSTNK = "";// 客户采购订单编号
			String KUNAG = "";// 售达方简码
			String KUNNR = "";// 运达方简码
			String TEL_NUMBER = "";// 第一个电话号码：区号 + 号码
			String LGOBE = "";// 仓储地点的描述 （库位描述）
			String MAKTX = "";// 物料描述
			String LFIMG = "";// 实际已交货量（按销售单位）
			String MSEHT = "";// 度量单位文本(最多10个字符)
			String BRGEW = "";// 毛重
			String WERKS = "1010";// 工厂
			String KDMAT = "";// 客户物料
			String VKAUS = "";// 散装固定包装(包装别)
			String WADAT = "";// 计划货物移动日期
			String SPECS = "";// 规格
			String CHARG = "";// 批号
			String PACK = "";// 包装性质
			String AESKD = "";// 客户工程修改状态
			String VSTEL = "";// 装运点/接收点
			String LPRIO = "";// 交货优先级
			String SDABW = "";// 特殊处理标记
			String NTGEW = "";// 净重量
			String SGTXT = "";// 项目文本
			String TKNUM = "";// 装运编号
			String EXTI1 = "";// 外部识别 1
			String SIGNI = "";// 容器 ID
			String TNDR_TRKID = "";// 货运代理追踪标识
			String ADD01 = "";// 供应量 1
			String ADD02 = "";// 供应量 2
			String ADD03 = "";// 供应量 3
			String TEXT1 = "";// 附加文本 1
			String NAME1 = "";// 名称 1
			String BSTKD = "";// 客户采购订单编号
			String KOSTK = "";// 全部拣配/堆放状态
			String FERTH = "";// 生产/检验备忘录
			String SPART = "";// 产品组
			String ORMNG = "";// 装运通知/内向交货的原始数量
			String ZGMZBH = "";// 购买证编号
			String ZADDFLAG = "";// 是否为苏州大市（X=是）
			String ZYSZBH = "";// 运输证编号
			String ZMENGE1 = "";// 采购订单数量1
			String ZMENGE2 = "";// 采购订单数量2
			String ZMEINS1 = "";// 采购订单计量单位1
			String ZMEINS2 = "";// 采购订单计量单位2
			String ZMATNR = "";// 物料编号
			String ZKUNNR = "";// 运输公司编号
			String ZKUNNRTXT = "";// 运输公司名称
			String ZDATELOW1 = "";// 可用（可供货的）开始日期
			String ZDATEHIGH1 = "";// 可用(可供货的)截至日期
			String ZDATELOW2 = "";// 可用（可供货的）开始日期
			String ZDATEHIGH2 = "";// 可用(可供货的)截至日期
			String ZCARS = "";// 车号,逗号区分
			String ZYUP = "";// 是否上传sap
			String UEBTO = "";// 过量交货限度
			String UEBTK = "";// 标识：允许未限制的过量交货 X
			String UNTTO = "";// 交货不足限度 5%
			String ZCHARG = "";// 批次备注
			String ZDEL = "";// 删除
			String REMARK1 = "";// beizhu1
			String REMARK2 = "";// beizhu2
			String REMARK3 = "";// beizhu3
			String ZWEIGHT = "";// 包材重量

			String VBELN_VL = "";// sap交运单号
			String POSNR_VL = "";// sap交运项次

			RecordSet rs = new RecordSet();
			RecordSet rs1 = new RecordSet();
			RecordSet rs2 = new RecordSet();
			String sql1 = "select t2.* from " + tablename + " t1";
			sql1 += " left join " + tablename + "_dt2 t2 on t1.id = t2.mainid";
			sql1 += " where 1=1";
			sql1 += " and t1.requestid= " + requestid;
			sql1 += " and t2.shipadviceno= " + shipadviceno;
			log.writeLog("查询明细执行的log" + sql1);
			rs.executeSql(sql1);

			String sources = "";
			if (!workflowId.equals("")) {
				rs1.executeSql("select SAPSource from workflow_base where id=" + workflowId);
				if (rs1.next())
					sources = rs1.getString(1);
			}
			log.writeLog("sources=" + sources);

			SAPInterationDateSourceImpl sapidsi = new SAPInterationDateSourceImpl();
			sapconnection = (JCO.Client) sapidsi.getConnection(sources, new LogInfo());
			log.writeLog("创建SAP连接");
			String strFunc = "Z_DELIVERY_TRAN_OA";

			while (rs.next()) {
				DELIVERYNO = Util.null2String(rs.getString("DELIVERYNO"));// 交运单号
				DELIVERYITEM = formatString(Util.null2String(rs.getString("DELIVERYITEM")));// 交运项次

				SHIPADVSTATUS = Util.null2String(rs.getString("SHIPADVSTATUS"));// shippingadvice状态
				SHIPADVICENO = Util.null2String(rs.getString("SHIPADVICENO"));// shippingadvice单号
				ETD = Util.null2String(rs.getString("ETD"));// 预计开航日ETD
				SALEORDER = Util.null2String(rs.getString("SALEORDER"));// 销售订单号
				ORDERITEM = Util.null2String(rs.getString("ORDERITEM"));// 销售订单项次
				STOCKNO = Util.null2String(rs.getString("STOCKNO"));// 物料号
				STOCKDESC = Util.null2String(rs.getString("STOCKDESC"));// 物料描述
				LOCATION = Util.null2String(rs.getString("LOCATION"));// 库位
				SHIPNUM = Util.null2String(rs.getString("SHIPNUM"));// 出货数量
				SALEUNIT = Util.null2String(rs.getString("SALEUNIT"));// 出货单位
				SHIPTO = Util.null2String(rs.getString("SHIPTO"));// 送达方名称
				SHIPTOADDR = Util.null2String(rs.getString("SHIPTOADDR"));// 送达方地址
				REALSHIPNUM = Util.null2String(rs.getString("REALSHIPNUM"));// 实际出货数量
				COSTCENTER = Util.null2String(rs.getString("COSTCENTER"));// 成本中心
				REMARK = Util.null2String(rs.getString("REMARK"));// 备注
				PROCATEGORY = Util.null2String(rs.getString("PROCATEGORY"));// 产品大类
				LCEN = Util.null2String(rs.getString("LCEN"));// 利润中心
				SHIPM = Util.null2String(rs.getString("SHIPM"));// ShippingMark
				SPECNEED = Util.null2String(rs.getString("SPECNEED"));// 特殊需求
				MATERDES = Util.null2String(rs.getString("MATERDES"));// 客户物料描述
				CUSORDNO = Util.null2String(rs.getString("CUSORDNO"));// 客户订单编号
				ORDERADVICENO = Util.null2String(rs.getString("ORDERADVICENO"));// OrderAdvice编号
				SOLDTO = Util.null2String(rs.getString("SOLDTO"));// 售达方名称
				SOLDTOADDR = Util.null2String(rs.getString("SOLDTOADDR"));// 售达方地址
				// sfyg = Util.null2String(rs.getString("sfyg"));//是否有柜
				COMCODE = Util.null2String(rs.getString("COMCODE"));// 公司代码
				CONTAINTYPE = Util.null2String(rs.getString("CONTAINTYPE"));// 货柜预定类型
				CONTAINQUAN = Util.null2String(rs.getString("CONTAINQUAN"));// 柜数
				ETA = Util.null2String(rs.getString("ETA"));// ETA
				EREQUESTID = Util.null2String(rs.getString("EREQUESTID"));// EREQUESTID

				// 填写参数
				JCO.Repository myRepository = new JCO.Repository("Repository", sapconnection);
				IFunctionTemplate ft = myRepository.getFunctionTemplate(strFunc.toUpperCase());
				JCO.Function function = ft.getFunction();
				function.getImportParameterList().setValue("DOWN", "FLAG");
				JCO.Table inTableParams = function.getTableParameterList().getTable("IT_HEAD_O");
				inTableParams.appendRow();
				inTableParams.setValue(DELIVERYNO, "VBELN_VL");
				inTableParams.setValue(DELIVERYNO, "VBELN_VT");
				inTableParams.setValue(DELIVERYITEM, "POSNR");
				inTableParams.setValue(COMCODE, "WERKS");
				sapconnection.execute(function);
				log.writeLog("执行function获取sap数据");

				// 获取数据
				JCO.Table output = function.getTableParameterList().getTable("IT_ITEM_O");

				for (int i = 0; i < output.getNumRows(); i++) {
					String ychl = "";// 已出货量
					// HashMap tempMap = new HashMap();
					// sap数据
					VBELN_VL = output.getString("VBELN_VL");// 交货
					POSNR_VL = output.getString("POSNR_VL");// 交货项目
					log.writeLog("VBELN_VL:" + VBELN_VL);
					log.writeLog("POSNR_VL:" + POSNR_VL);

					// 用交运单号和交运项次和sap的数据进行匹配
					if (DELIVERYNO.equals(VBELN_VL) && DELIVERYITEM.equals(POSNR_VL)) {

						AUART = output.getString("AUART");// 销售凭证类型
						BSTNK = output.getString("BSTNK");// 客户采购订单编号
						KUNAG = output.getString("KUNAG");// 售达方简码
						KUNNR = output.getString("KUNNR");// 运达方简码
						TEL_NUMBER = output.getString("TEL_NUMBER");// 第一个电话号码：区号
																	// +
																	// 号码
						LGOBE = output.getString("LGOBE");// 仓储地点的描述 （库位描述）
						MAKTX = output.getString("MAKTX");// 物料描述
						LFIMG = output.getString("LFIMG");// 实际已交货量（按销售单位）
						MSEHT = output.getString("MSEHT");// 度量单位文本(最多10个字符)
						BRGEW = output.getString("BRGEW");// 毛重
						WERKS = output.getString("WERKS");// 工厂
						KDMAT = output.getString("KDMAT");// 客户物料
						VKAUS = output.getString("VKAUS");// 散装固定包装(包装别)
						WADAT = output.getString("WADAT");// 计划货物移动日期
						SPECS = output.getString("SPECS");// 规格
						CHARG = output.getString("CHARG");// 批号
						PACK = output.getString("PACK");// 包装性质
						AESKD = output.getString("AESKD");// 客户工程修改状态
						VSTEL = output.getString("VSTEL");// 装运点/接收点
						LPRIO = output.getString("LPRIO");// 交货优先级
						SDABW = output.getString("SDABW");// 特殊处理标记
						NTGEW = output.getString("NTGEW");// 净重量
						SGTXT = output.getString("SGTXT");// 项目文本
						TKNUM = output.getString("TKNUM");// 装运编号
						EXTI1 = output.getString("EXTI1");// 外部识别 1
						SIGNI = output.getString("SIGNI");// 容器 ID
						TNDR_TRKID = output.getString("TNDR_TRKID");// 货运代理追踪标识
						ADD01 = output.getString("ADD01");// 供应量 1
						ADD02 = output.getString("ADD02");// 供应量 2
						ADD03 = output.getString("ADD03");// 供应量 3
						TEXT1 = output.getString("TEXT1");// 附加文本 1
						NAME1 = output.getString("NAME1");// 名称 1
						BSTKD = output.getString("BSTKD");// 客户采购订单编号
						KOSTK = output.getString("KOSTK");// 全部拣配/堆放状态
						FERTH = output.getString("FERTH");// 生产/检验备忘录
						SPART = output.getString("SPART");// 产品组
						ORMNG = output.getString("ORMNG");// 装运通知/内向交货的原始数量
						ZGMZBH = output.getString("ZGMZBH");// 购买证编号
						ZADDFLAG = output.getString("ZADDFLAG");// 是否为苏州大市（X=是）
						ZYSZBH = output.getString("ZYSZBH");// 运输证编号
						ZMENGE1 = output.getString("ZMENGE1");// 采购订单数量1
						ZMENGE2 = output.getString("ZMENGE2");// 采购订单数量2
						ZMEINS1 = output.getString("ZMEINS1");// 采购订单计量单位1
						ZMEINS2 = output.getString("ZMEINS2");// 采购订单计量单位2
						ZMATNR = output.getString("ZMATNR");// 物料编号
						ZKUNNR = output.getString("ZKUNNR");// 运输公司编号
						ZKUNNRTXT = output.getString("ZKUNNRTXT");// 运输公司名称
						ZDATELOW1 = output.getString("ZDATELOW1");// 可用（可供货的）开始日期
						ZDATEHIGH1 = output.getString("ZDATEHIGH1");// 可用(可供货的)截至日期
						ZDATELOW2 = output.getString("ZDATELOW2");// 可用（可供货的）开始日期
						ZDATEHIGH2 = output.getString("ZDATEHIGH2");// 可用(可供货的)截至日期
						ZCARS = output.getString("ZCARS");// 车号,逗号区分
						ZYUP = output.getString("ZYUP");// 是否上传sap
						UEBTO = output.getString("UEBTO");// 过量交货限度
						UEBTK = output.getString("UEBTK");// 标识：允许未限制的过量交货 X
						UNTTO = output.getString("UNTTO");// 交货不足限度 5%
						// ZCHARG = output.getString("ZCHARG");//批次备注
						ZDEL = output.getString("ZDEL");// 删除
						REMARK1 = output.getString("REMARK1");// beizhu1
						REMARK2 = output.getString("REMARK2");// beizhu2
						REMARK3 = output.getString("REMARK3");// beizhu3
						ZWEIGHT = output.getString("ZWEIGHT");// 包材重量

						// 打印log
						log.writeLog("VBELN_VL", VBELN_VL);// 交运单号
						log.writeLog("POSNR_VL", POSNR_VL);// 交运项次
						log.writeLog("SHIPADVSTATUS", SHIPADVSTATUS);// shippingadvice状态
						log.writeLog("SHIPADVICENO", SHIPADVICENO);// shippingadvice单号
						log.writeLog("ETD", ETD);// 预计开航日ETD
						log.writeLog("DELIVERYNO", DELIVERYNO);// 交运单号
						log.writeLog("DELIVERYITEM", DELIVERYITEM);// 交运单项次
						log.writeLog("SALEORDER", SALEORDER);// 销售订单号
						log.writeLog("ORDERITEM", ORDERITEM);// 销售订单项次
						log.writeLog("STOCKNO", STOCKNO);// 物料号
						log.writeLog("STOCKDESC", STOCKDESC);// 物料描述
						log.writeLog("LOCATION", LOCATION);// 库位
						log.writeLog("SHIPNUM", SHIPNUM);// 出货数量
						log.writeLog("SALEUNIT", SALEUNIT);// 出货单位
						log.writeLog("SHIPTO", SHIPTO);// 送达方名称
						log.writeLog("SHIPTOADDR", SHIPTOADDR);// 送达方地址
						log.writeLog("REALSHIPNUM", REALSHIPNUM);// 实际出货数量
						log.writeLog("COSTCENTER", COSTCENTER);// 成本中心
						log.writeLog("REMARK", REMARK);// 备注
						log.writeLog("PROCATEGORY", PROCATEGORY);// 产品大类
						log.writeLog("LCEN", LCEN);// 利润中心
						log.writeLog("SHIPM", SHIPM);// ShippingMark
						log.writeLog("SPECNEED", SPECNEED);// 特殊需求
						log.writeLog("MATERDES", MATERDES);// 客户物料描述
						log.writeLog("CUSORDNO", CUSORDNO);// 客户订单编号
						log.writeLog("ORDERADVICENO", ORDERADVICENO);// OrderAdvice编号
						log.writeLog("SOLDTO", SOLDTO);// 售达方名称
						log.writeLog("SOLDTOADDR", SOLDTOADDR);// 售达方地址
						log.writeLog("AUART", AUART);// 销售凭证类型
						log.writeLog("BSTNK", BSTNK);// 客户采购订单编号
						log.writeLog("KUNAG", KUNAG);// 售达方简码
						log.writeLog("KUNNR", KUNNR);// 运达方简码
						log.writeLog("TEL_NUMBER", TEL_NUMBER);// 第一个电话号码：区号
																// +
																// 号码
						// log.writeLog("sfyg", sfyg);// 是否有柜
						log.writeLog("COMCODE", COMCODE);// 公司代码
						log.writeLog("CONTAINTYPE", CONTAINTYPE);// 货柜预定类型
						log.writeLog("CONTAINQUAN", CONTAINQUAN);// 柜数

						log.writeLog("LGOBE", LGOBE);// 仓储地点的描述 （库位描述）
						log.writeLog("MAKTX", MAKTX);// 物料描述
						log.writeLog("LFIMG", LFIMG);// 实际已交货量（按销售单位）
						log.writeLog("MSEHT", MSEHT);// 度量单位文本(最多10个字符)
						log.writeLog("BRGEW", BRGEW);// 毛重
						log.writeLog("WERKS", WERKS);// 工厂
						log.writeLog("KDMAT", KDMAT);// 客户物料
						log.writeLog("VKAUS", VKAUS);// 散装固定包装(包装别)
						log.writeLog("WADAT", WADAT);// 计划货物移动日期
						log.writeLog("SPECS", SPECS);// 规格
						log.writeLog("CHARG", CHARG);// 批号
						log.writeLog("PACK", PACK);// 包装性质
						log.writeLog("AESKD", AESKD);// 客户工程修改状态
						log.writeLog("VSTEL", VSTEL);// 装运点/接收点
						log.writeLog("LPRIO", LPRIO);// 交货优先级
						log.writeLog("SDABW", SDABW);// 特殊处理标记
						log.writeLog("NTGEW", NTGEW);// 净重量
						log.writeLog("SGTXT", SGTXT);// 项目文本
						log.writeLog("TKNUM", TKNUM);// 装运编号
						log.writeLog("EXTI1", EXTI1);// 外部识别 1
						log.writeLog("SIGNI", SIGNI);// 容器 ID
						log.writeLog("TNDR_TRKID", TNDR_TRKID);// 货运代理追踪标识
						log.writeLog("ADD01", ADD01);// 供应量 1
						log.writeLog("ADD02", ADD02);// 供应量 2
						log.writeLog("ADD03", ADD03);// 供应量 3
						log.writeLog("TEXT1", TEXT1);// 附加文本 1
						log.writeLog("NAME1", NAME1);// 名称 1
						log.writeLog("BSTKD", BSTKD);// 客户采购订单编号
						log.writeLog("KOSTK", KOSTK);// 全部拣配/堆放状态
						log.writeLog("FERTH", FERTH);// 生产/检验备忘录
						log.writeLog("SPART", SPART);// 产品组
						log.writeLog("ORMNG", ORMNG);// 装运通知/内向交货的原始数量
						log.writeLog("ZGMZBH", ZGMZBH);// 购买证编号
						log.writeLog("ZADDFLAG", ZADDFLAG);// 是否为苏州大市（X=是）
						log.writeLog("ZYSZBH", ZYSZBH);// 运输证编号
						log.writeLog("ZMENGE1", ZMENGE1);// 采购订单数量1
						log.writeLog("ZMENGE2", ZMENGE2);// 采购订单数量2
						log.writeLog("ZMEINS1", ZMEINS1);// 采购订单计量单位1
						log.writeLog("ZMEINS2", ZMEINS2);// 采购订单计量单位2
						log.writeLog("ZMATNR", ZMATNR);// 物料编号
						log.writeLog("ZKUNNR", ZKUNNR);// 运输公司编号
						log.writeLog("ZKUNNRTXT", ZKUNNRTXT);// 运输公司名称
						log.writeLog("ZDATELOW1", ZDATELOW1);// 可用（可供货的）开始日期
						log.writeLog("ZDATEHIGH1", ZDATEHIGH1);// 可用(可供货的)截至日期
						log.writeLog("ZDATELOW2", ZDATELOW2);// 可用（可供货的）开始日期
						log.writeLog("ZDATEHIGH2", ZDATEHIGH2);// 可用(可供货的)截至日期
						log.writeLog("ZCARS", ZCARS);// 车号,逗号区分
						log.writeLog("ZYUP", ZYUP);// 是否上传sap
						log.writeLog("UEBTO", UEBTO);// 过量交货限度
						log.writeLog("UEBTK", UEBTK);// 标识：允许未限制的过量交货 X
						log.writeLog("UNTTO", UNTTO);// 交货不足限度 5%
						log.writeLog("ZCHARG", ZCHARG);// 批次备注
						log.writeLog("ZDEL", ZDEL);// 删除
						log.writeLog("REMARK1", REMARK1);// beizhu1
						log.writeLog("REMARK2", REMARK2);// beizhu2
						log.writeLog("REMARK3", REMARK3);// beizhu3
						log.writeLog("ZWEIGHT", ZWEIGHT);// 包材重量

						StringBuffer buffer = new StringBuffer();

						buffer.append("insert into UF_SPGHSR");
						buffer.append(
								"(REQUESTID,SHIPADVSTATUS,SHIPADVICENO,ETD,ETA,EREQUESTID,DELIVERYNO,DELIVERYITEM,SALEORDER,ORDERITEM,STOCKNO,STOCKDESC,LOCATION,SHIPNUM,SALEUNIT,SHIPTO,SHIPTOADDR,REALSHIPNUM,COSTCENTER,REMARK,PROCATEGORY,LCEN,SHIPM,SPECNEED,MATERDES,CUSORDNO,ORDERADVICENO,SOLDTO,SOLDTOADDR,AUART,BSTNK,KUNAG,KUNNR,TEL_NUMBER,LGOBE,MAKTX,LFIMG,MSEHT,BRGEW,WERKS,KDMAT,VKAUS,WADAT,SPECS,CHARG,PACK,AESKD,VSTEL,LPRIO,SDABW,NTGEW,SGTXT,TKNUM,EXTI1,SIGNI,TNDR_TRKID,ADD01,ADD02,ADD03,TEXT1,NAME1,BSTKD,KOSTK,FERTH,SPART,ORMNG,ZGMZBH,ZADDFLAG,ZYSZBH,ZMENGE1,ZMENGE2,ZMEINS1,ZMEINS2,ZMATNR,ZKUNNR,ZKUNNRTXT,ZDATELOW1,ZDATEHIGH1,ZDATELOW2,ZDATEHIGH2,ZCARS,ZYUP,UEBTO,UEBTK,UNTTO,ZCHARG,ZDEL,COMCODE,CONTAINTYPE,CONTAINQUAN,ZWEIGHT,FORMMODEID,MODEDATACREATER,REMARK1,REMARK2,REMARK3) values");
						buffer.append("('").append(requestid).append("',");
						buffer.append("'").append(SHIPADVSTATUS).append("',");
						buffer.append("'").append(SHIPADVICENO).append("',");
						buffer.append("'").append(ETD).append("',");
						buffer.append("'").append(ETA).append("',");
						buffer.append("'").append(EREQUESTID).append("',");
						buffer.append("'").append(DELIVERYNO).append("',");
						buffer.append("'").append(DELIVERYITEM).append("',");
						buffer.append("'").append(SALEORDER).append("',");
						buffer.append("'").append(ORDERITEM).append("',");
						buffer.append("'").append(STOCKNO).append("',");
						buffer.append("'").append(STOCKDESC).append("',");
						buffer.append("'").append(LOCATION).append("',");
						buffer.append("'").append(SHIPNUM).append("',");
						buffer.append("'").append(SALEUNIT).append("',");
						buffer.append("'").append(SHIPTO).append("',");
						buffer.append("'").append(SHIPTOADDR).append("',");
						buffer.append("'").append(REALSHIPNUM).append("',");
						buffer.append("'").append(COSTCENTER).append("',");
						buffer.append("'").append(REMARK).append("',");
						buffer.append("'").append(PROCATEGORY).append("',");
						buffer.append("'").append(LCEN).append("',");
						buffer.append("'").append(SHIPM).append("',");
						buffer.append("'").append(SPECNEED).append("',");
						buffer.append("'").append(MATERDES).append("',");
						buffer.append("'").append(CUSORDNO).append("',");
						buffer.append("'").append(ORDERADVICENO).append("',");
						buffer.append("'").append(SOLDTO).append("',");
						buffer.append("'").append(SOLDTOADDR).append("',");
						buffer.append("'").append(AUART).append("',");
						buffer.append("'").append(BSTNK).append("',");
						buffer.append("'").append(KUNAG).append("',");
						buffer.append("'").append(KUNNR).append("',");
						buffer.append("'").append(TEL_NUMBER).append("',");
						buffer.append("'").append(LGOBE).append("',");
						buffer.append("'").append(MAKTX).append("',");
						buffer.append("'").append(LFIMG).append("',");
						buffer.append("'").append(MSEHT).append("',");
						buffer.append("'").append(BRGEW).append("',");
						buffer.append("'").append(WERKS).append("',");
						buffer.append("'").append(KDMAT).append("',");
						buffer.append("'").append(VKAUS).append("',");
						buffer.append("'").append(WADAT).append("',");
						buffer.append("'").append(SPECS).append("',");
						buffer.append("'").append(CHARG).append("',");
						buffer.append("'").append(PACK).append("',");
						buffer.append("'").append(AESKD).append("',");
						buffer.append("'").append(VSTEL).append("',");
						buffer.append("'").append(LPRIO).append("',");
						buffer.append("'").append(SDABW).append("',");
						buffer.append("'").append(NTGEW).append("',");
						buffer.append("'").append(SGTXT).append("',");
						buffer.append("'").append(TKNUM).append("',");
						buffer.append("'").append(EXTI1).append("',");
						buffer.append("'").append(SIGNI).append("',");
						buffer.append("'").append(TNDR_TRKID).append("',");
						buffer.append("'").append(ADD01).append("',");
						buffer.append("'").append(ADD02).append("',");
						buffer.append("'").append(ADD03).append("',");
						buffer.append("'").append(TEXT1).append("',");
						buffer.append("'").append(NAME1).append("',");
						buffer.append("'").append(BSTKD).append("',");
						buffer.append("'").append(KOSTK).append("',");
						buffer.append("'").append(FERTH).append("',");
						buffer.append("'").append(SPART).append("',");
						buffer.append("'").append(ORMNG).append("',");
						buffer.append("'").append(ZGMZBH).append("',");
						buffer.append("'").append(ZADDFLAG).append("',");
						buffer.append("'").append(ZYSZBH).append("',");
						buffer.append("'").append(ZMENGE1).append("',");
						buffer.append("'").append(ZMENGE2).append("',");
						buffer.append("'").append(ZMEINS1).append("',");
						buffer.append("'").append(ZMEINS2).append("',");
						buffer.append("'").append(ZMATNR).append("',");
						buffer.append("'").append(ZKUNNR).append("',");
						buffer.append("'").append(ZKUNNRTXT).append("',");
						buffer.append("'").append(ZDATELOW1).append("',");
						buffer.append("'").append(ZDATEHIGH1).append("',");
						buffer.append("'").append(ZDATELOW2).append("',");
						buffer.append("'").append(ZDATEHIGH2).append("',");
						buffer.append("'").append(ZCARS).append("',");
						buffer.append("'").append(ZYUP).append("',");
						buffer.append("'").append(UEBTO).append("',");
						buffer.append("'").append(UEBTK).append("',");
						buffer.append("'").append(UNTTO).append("',");
						buffer.append("'").append(ZCHARG).append("',");
						buffer.append("'").append(ZDEL).append("',");
						buffer.append("'").append(COMCODE).append("',");
						buffer.append("'").append(CONTAINTYPE).append("',");
						buffer.append("'").append(CONTAINQUAN).append("',");
						buffer.append("'").append(ZWEIGHT).append("',");
						buffer.append("'").append("421").append("',");
						buffer.append("'").append("1").append("',");
						buffer.append("'").append(REMARK1).append("',");
						buffer.append("'").append(REMARK2).append("',");
						buffer.append("'").append(REMARK3).append("')");
						log.writeLog("插入建模表的sql:" + buffer.toString());
						rs2.executeSql(buffer.toString());

						StringBuffer sb = new StringBuffer();// 插入权限表
						sb.append("insert into MODEDATASHARE_421");
						sb.append("(SOURCEID,TYPE,CONTENT,SECLEVEL,SHARELEVEL) values");
						sb.append("(").append("(select id from UF_SPGHSR where DELIVERYNO = '" + DELIVERYNO
								+ "' and DELIVERYITEM = '" + DELIVERYITEM + "')").append(",");
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
			// TODO: handle exception
		}
	}

	public String formatString(String input) {
		int length = input.length();
		String result = "";
		if (length == 5) {
			result = input;
		} else if (length == 4) {
			result = "0" + input;
		} else if (length == 3) {
			result = "00" + input;
		} else if (length == 2) {
			result = "000" + input;
		} else {
			result = input;
		}
		return result;
	}
}
