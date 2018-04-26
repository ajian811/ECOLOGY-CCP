<%@page import="java.math.BigDecimal"%>
<%@page import="javax.servlet.jsp.tagext.TryCatchFinally"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<%@page import="com.weaver.integration.log.LogInfo"%>
<%@page import="weaver.general.Util"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.*" %>
<%@ page import="weaver.formmode.setup.ModeRightInfo" %>
<%@ page import="weaver.general.BaseBean" %>
<jsp:useBean id="log" class="weaver.general.BaseBean" scope="page"></jsp:useBean>
<jsp:useBean id="cal" class="weaver.interfaces.workflow.action.CCPUtil.CalUtil" scope="page"></jsp:useBean>

<%@ page import="javax.transaction.Transaction" %>
<%@ page import="weaver.interfaces.workflow.action.CCPUtil.CalUtil" %>
<%@ page import="weaver.interfaces.workflow.action.CCPConstant.DCCMTableNameConstant" %>


<%
	BaseBean bs=new BaseBean();
	String action = request.getParameter("action");
	RecordSet rs = new RecordSet();
	rs.writeLog("进入gbcz");
	JSONArray jsonArr = new JSONArray();
	JSONObject objectresult = new JSONObject();
	try {
		if ("searchMX1".equals(action)) {
			rs.writeLog("进入searchMX1");
			String trdh = request.getParameter("plate").toUpperCase();//提入单号
			String carno = request.getParameter("carno1");//车牌
			String weighType=request.getParameter("weighType");//计重类型
			rs.writeLog("取得的数据为 提入单号为:" + trdh + ",车牌号为：" + carno+",计重类型为:"+weighType);
			String sql="";
			if("weighkg".equals(weighType)){
				sql="SELECT * FROM UF_GBJL WHERE CP='"+carno+"' AND ZXJHH is NULL and sfzf='0' ORDER BY id DESC";
			}else{
				String zxjhh=getZxjhhByTrdh(trdh);
				sql="select * from uf_gbjl where zxjhh='"+zxjhh+"' and sfzf='0' order by id desc";
			}
			rs.writeLog(sql);
			rs.executeSql(sql);
			while (rs.next()) {
				String trdh1 = Util.null2String(rs.getString("trdh"));//提入单号
				String zxjhh1 = Util.null2String(rs.getString("zxjhh"));//装卸计划号
				String cp = Util.null2String(rs.getString("cp"));//车牌
				String gh = Util.null2String(rs.getString("gh"));//柜号
				String gbrq = Util.null2String(rs.getString("gbrq"));//过磅日期
				String gbsj = Util.null2String(rs.getString("gbsj"));//过磅时间
				String rz = Util.null2String(rs.getString("rz"));//入重
				String cz = Util.null2String(rs.getString("cz"));//出重
				String jz = Util.null2String(rs.getString("jz"));//净重
				JSONObject object = new JSONObject();
				object.put("trdh", trdh1);
				object.put("planNo", zxjhh1);
				object.put("gh", gh);
				object.put("carno", cp);
				object.put("gbrq", gbrq);
				object.put("gbsj", gbsj);
				object.put("rz", rz);
				object.put("cz", cz);
				object.put("jz", jz);

				jsonArr.add(object);
				rs.writeLog(object.toString());

			}
		}
		if ("searchMX2".equals(action)) {
			rs.writeLog("进入searchMX2");
			String trdh = request.getParameter("plate").toUpperCase();//提入单号
			//String carno=request.getParameter("carno1");
			String sql = "SELECT b.CP,b.GBM,b.SL,b.SHIPPING,b.jydh,b.ddxc,b.wlhm,b.wlms,b.bzfs from uf_trdpldy a,UF_TRDPLDY_DT1 b where a.id=b.mainid";
			if (trdh != null) {
				sql += " and a.trdh = '" + trdh + "'";
			}
			rs.writeLog(sql);
			rs.executeSql(sql);
			while (rs.next()) {
				JSONObject object = new JSONObject();
				object.put("cp", Util.null2String(rs.getString("cp")));//产品
				object.put("sl", Util.null2String(rs.getString("sl")));//数量
				object.put("shipping", Util.null2String(rs.getString("shipping")));//shipping
				object.put("gbm", Util.null2String(rs.getString("gbm")));//柜编码
				object.put("ddh",Util.null2String(rs.getString("jydh")));
				object.put("xc",Util.null2String(rs.getString("ddxc")));
				object.put("wlh",Util.null2String(rs.getString("wlhm")));
				object.put("wlms",Util.null2String(rs.getString("wlms")));
				object.put("dwms",Util.null2String(rs.getString("bzfs")));

				jsonArr.add(object);
				rs.writeLog(object.toString());
			}
		}
		//计重插入表格，点击计重按钮
		if ("searchJZ".equals(action)) {
			rs.writeLog("进入insertJZ");
			String jzzl = "0.00";//计重重量

			jzzl = Util.null2String(request.getParameter("weight")).trim();//计重重量

			String trdh = Util.null2String(request.getParameter("plate").toUpperCase());//提入单号
			String carno = Util.null2String(request.getParameter("carno"));//车牌
			String weighType=Util.null2String(request.getParameter("weighType"));//计重类型
			String ggh=Util.null2String(request.getParameter("ggh"));//柜罐号
			String unloadingHead=Util.null2String(request.getParameter("unloadingHead"));//卸车头
			rs.writeLog("取得的数据为 提入单号为:" + trdh + ",车牌号为：" + carno + ",计重重量为：" + jzzl+",计重类型为："+weighType
			+",卸车头："+unloadingHead);

			JSONObject jsonObject = new JSONObject();
			String message = "";
			//计重空柜情况
			if("weighkg".equals(weighType)){
				Date date = new Date();
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				String currentDate = sdf.format(date);
				String gbrq = currentDate.substring(0, 10);
				String gbsj = currentDate.substring(11, 16);
				String[] gghs=ggh.split(",");
				rs.writeLog("获得数组："+gghs);
				int sl=0;
				for (int i = 0; i <gghs.length ; i++) {
				    String ggh0=gghs[i];
				    if(!"".equals(ggh0)){
				        sl++;
					}
				}
				String sql = "INSERT INTO UF_GBJL (CP,GBRQ,GBSJ,RZ,GH,KGSL" +
						",FORMMODEID,MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid" +
						") VALUES (";

				sql += "'" + carno + "',";
				sql += "'" + gbrq + "',";
				sql += "'" + gbsj + "',";
				sql += "'" + jzzl + "',";
				sql += "'" + ggh+ "'";
				sql += "," + sl+ "," ;

				sql+="'841',";
				sql+="'1',";
				sql+="'0',";
				Date d1=new Date();
				SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
				SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");
				sql+="'"+dateFormat.format(d1)+"',";
				sql+="'"+dateFormat1.format(d1)+"',";
				String str1 = UUID.randomUUID().toString();
				sql+="'"+str1+"')";

				rs.writeLog("空柜插入sql:" + sql);
				rs.executeSql(sql);

				sql="select id from UF_GBJL where modeuuid='"+str1+"'";
				rs.writeLog(sql);
				rs.execute(sql);
				String id="";
				if(rs.next()){
					id=Util.null2String(rs.getString("id"));
				}
				ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
				localModeRightInfo1.setNewRight(true);
				localModeRightInfo1.editModeDataShare(1, 841, Integer.parseInt(id));


				message += "空柜计重插入成功";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;
			}
			//计重有柜情况
			String sql = "select ZXJHH,LCID,TRDH,SFDY,lx from UF_TRDPLDY where 1=1";
			String sfyg = "";//是否有柜
			if (trdh != null) {
				sql += " and TRDH = '" + trdh + "'";
			}
			rs.writeLog(sql);
			rs.executeSql(sql);

			while (rs.next()) {
				String reqid = Util.null2String(rs.getString("lcid"));
				String sfdy = Util.null2String(rs.getString("sfdy"));
				String lx=Util.null2String(rs.getString("lx"));
				String shipping=getShippingByRequestid(reqid,lx);
				if ("0".equals(sfdy)) {
					message += "提入单没有打印";
					jsonObject = addJsonJZ(message);
					out.write(jsonObject.toString());
					return;
				} else if ("1".equals(sfdy)) {
					rs.writeLog("查询提入单已打印");
					String formname="";
					formname=getFormNameByLx(lx);
					String sql1 = "select cp,zxjhh from "+formname+" where requestid='" + reqid
							+ "'";

					rs.writeLog(sql1);
					rs.executeSql(sql1);

					if (rs.next()) {
						String zxjhh = Util.null2String(rs.getString("zxjhh"));
						rs.writeLog("查询到提入单的装卸计划号：" + zxjhh);
						String cp = Util.null2String(rs.getString("cp"));

						String sql0 = "select id from UF_GBJL where zxjhh='" + zxjhh + "' and sfzf='0'";
						rs.writeLog(sql0);
						rs.execute(sql0);

						int count = rs.getCounts();
						Boolean check=false;

						if("unloadingHead".equals(unloadingHead)){
							check=true;
						}
						if ((count == 0||(count==2))) {
						    if (count==2){
						         Boolean check0=checkUnloadingHead(zxjhh);
						         if(!check0){
						             message="该车辆非卸车头！";
									 jsonObject = addJsonJZ(message);
									 out.write(jsonObject.toString());
									 return;
								 }

							}else {

								rs.writeLog("装卸计划尚未计重");

							}
							Boolean check1=checkUnloadingHeadJZ(check,count);
							if (cp == null || "".equals(cp) || !cp.equals(carno)) {
								String sql2 = "UPDATE "+formname+" set cp='" + carno + "' where zxjhh='"
										+ zxjhh+"'";
								rs.writeLog(sql2);
								rs.executeSql(sql2);
								message += "车牌已更新\\n";

							}
							Date date = new Date();
							SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
							String currentDate = sdf.format(date);
							String gbrq = currentDate.substring(0, 10);
							String gbsj = currentDate.substring(11, 16);
							String sql3 = "insert into UF_GBJL (ZXJHH,CP,SHIPPING,GBRQ,GBSJ,RZ,CZ," +
									"FORMMODEID,MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid";
							if(check){
							    sql3+=",unloadingHead";
							}
							sql3+=") values (";
							sql3 += "'" + zxjhh + "',";
							sql3 += "'" + carno + "',";
							sql3 += "'" + shipping + "',";
							sql3 += "'" + gbrq + "',";
							sql3 += "'" + gbsj + "',";
							if (check1){
							    sql3+="null,";
							}else {
								sql3 += "'" + jzzl + "',";
							}
							sql3 += "'" + jzzl + "',";

							sql3+="'841',";
							sql3+="'1',";
							sql3+="'0',";
							Date d1=new Date();
							SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
							SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");
							sql3+="'"+dateFormat.format(d1)+"',";
							sql3+="'"+dateFormat1.format(d1)+"',";
							String str1 = UUID.randomUUID().toString();
							sql3+="'"+str1+"'";
							if(check){
								sql3+=",'1')";
							}else {
							    sql3+=")";
							}

							rs.writeLog(sql3);
							rs.execute(sql3);

							sql="select id from UF_GBJL where modeuuid='"+str1+"'";
							rs.writeLog(sql);
							rs.execute(sql);
							String id="";
							if(rs.next()){
								id=Util.null2String(rs.getString("id"));
							}
							ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
							localModeRightInfo1.setNewRight(true);
							localModeRightInfo1.editModeDataShare(1, 841, Integer.parseInt(id));


							message += "计重插入成功";
							jsonObject = addJsonJZ(message);
							out.write(jsonObject.toString());
							return;
						} else {


							message += "该提入单所属装卸计划已经计重过，无需重复计重！\\n";
							jsonObject = addJsonJZ(message);
							out.write(jsonObject.toString());
							return;
						}

					}

				}
			}
			message += "提入单不存在请确认后再输入！";
			jsonObject = addJsonJZ(message);
			out.write(jsonObject.toString());
			return;

		}

		//过磅操作插入记录
		/**
		 * 过磅逻辑
		 * 1、无柜情况
		 * 		1)业务逻辑
		 * 			过磅时只输入车牌，记录磅值
		 * 		2)代码逻辑
		 * 			a、carno--车牌为条件，在过磅记录表查询 装卸计划不为空，不作废 ，最近 的一条数据--获得 id，及rz-入重
		 * 			b、根据查询到的rz 及磅值--jzzl 计算得出净重--jz（公式为jz=jzzl-rz）
		 * 			c、更新 id号为id值的 过磅记录表 cz（=jzzl） 及jz（=jz）
		 * 2、有柜情况
		 * 		1）业务逻辑
		 * 			a、四次过磅：（这里只考虑只装柜一次情况，多次装柜的，前面四次的过磅为按照四次过磅逻辑，后面按照非四次过磅逻辑）
		 * 				四次过磅是指：
		 * 					#第一次过磅：车辆进入厂后
		 * 					#第二次过磅：因为装货需要比较久的时间等原因，先将车身卸下来留在厂里等待装货，车头出厂
		 * 					#第三次过磅：待装货完成后，车头返厂
		 * 					#第四次过磅：装货完成后出厂
		 * 			b、非四次过磅：
		 * 				第一计算重量，
		 *
		 * 		2）代码逻辑
		 *
		 */
		if ("insertGB".equals(action)) {
		    String formname="";
			rs.writeLog("insertGB");
			String jzzl = "0.00";//过磅重量

			jzzl = Util.null2String(request.getParameter("weight")).trim();//计重重量
			String weighType=Util.null2String(request.getParameter("weighType"));
			String ggh=Util.null2String(request.getParameter("ggh"));
			String trdh = request.getParameter("plate").toUpperCase();//提入单号
			String carno = request.getParameter("carno");//车牌
			rs.writeLog("获得提入单号：" + trdh + ",车牌：" + carno + ",过磅重量" + jzzl+",计重类型"+weighType+",柜罐号："+ggh);
			String rzFlag = "";//入重标识
			String czFlag = "";//出重标识
			String lx="";//类型

			if (!"weighkg".equals(weighType)) {
				char pd = trdh.toCharArray()[4];

				//out --出去
				if ("O".equals(pd + "")) {
					rzFlag = "MIN(RZ)";
					czFlag = "MAX(CZ)";
				}

				//in --进入
				if ("I".equals(pd + "")) {
					rzFlag = "MAX(RZ)";
					czFlag = "MIN(CZ)";
				}

				lx = getLxByTrdh(trdh);

				formname = getFormNameByLx(lx);
			}
			JSONObject jsonObject = new JSONObject();
			String message = "";
			//空柜情况
			if("weighkg".equals(weighType)){

				String sql1="SELECT id,RZ FROM UF_GBJL WHERE CP='"+carno+"' AND ZXJHH IS NULL and sfzf='0' ORDER BY id DESC";
				rs.writeLog(sql1);
				rs.execute(sql1);
				String id="";
				String rz="";
				if (rs.next()){

					id=Util.null2String(rs.getString("id"));

					rz=Util.null2String(rs.getString("RZ"));
				}

				String jz=Double.toString(calculateJZ(rz, jzzl));
				if(!"".equals(id)){
					String sql2="UPDATE UF_GBJL SET CZ='"+jzzl+"',JZ='"+jz+"' WHERE id="+id;
					rs.writeLog(sql2);
					rs.execute(sql2);
					message+="空柜过磅更新成功\\n";

				}else{
					message+="查询id为空!\\n";
				}
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;


			}

			//有柜情况
			int totalBillCounts=0;//该装卸计划总共的提入单数量
			int nowBillCounts=0;//该装卸计划目前的已过磅提入单数量
			String sql0="";
			sql0 = "SELECT DISTINCT b.ZXJHH,a.lcid FROM UF_TRDPLDY a,"+formname+" b where a.LCID=b.REQUESTID";

			if (trdh != null) {
				sql0 += " and a.TRDH = '" + trdh + "'";
			}
			rs.writeLog(sql0);
			rs.executeSql(sql0);
			String zxjhh = "";
			String shipping="";//提入单打印里面需要增加shipping字段
			String lcid="";
			while (rs.next()) {
				zxjhh = rs.getString("zxjhh");
				lcid=Util.null2String(rs.getString("lcid"));

			}
			sql0="SELECT ID FROM UF_TRDPLDY WHERE lcid='"+ lcid + "'";
			rs.writeLog(sql0);
			rs.execute(sql0);
			totalBillCounts=rs.getCounts();
			rs.writeLog("该装卸计划的提入单数量:"+totalBillCounts);
			String sql = "select id from uf_gbjl where zxjhh='" + zxjhh + "' and sfzf='0'";
			rs.writeLog(sql);
			rs.executeSql(sql);
			int count = rs.getCounts();//共计有效的过磅次数（包括过磅和计重）

			if (count == 0) {
				message = "提入单所属装卸计划尚未计重！";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;
			}
			String sql2 = "select id from uf_gbjl where trdh='" + trdh + "' and sfzf='0'";
			rs.writeLog("执行sql2：" + sql2);
			rs.executeSql(sql2);
			int counts=rs.getCounts();//提入单已过磅的数量

			//当之前的数量为
			Boolean check=false;//判断是否为卸车头
			Boolean check1=false;//判断，如果是卸车头，是否需要录入入重和提入单号
			String lastCz="";
			check=checkUnloadingHead(zxjhh);
			check1=checkUnloadingHead1(counts,check);
			Boolean check2=false;//当 为卸车头，并且过磅记录数量小于等于3
			if(check&&(count<3)){
			    check2=true;
			}

			if (counts > 0) {
				rs.writeLog("提入单已过磅");
				message = "该提入单已经过磅过了！不能重复过磅";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;
			}
			if (check&&(count==2)){
				rs.writeLog("卸车头，重新入厂请先计重！");
				message = "卸车头，重新入厂请先计重！";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;


			}

			if (counts==0) {

				if (check && (count == 3)) {
					Double lastCz0 = 0.00;
					String sql4 = "select cz from uf_gbjl where zxjhh='" + zxjhh + "' and sfzf='0' ORDER BY id desc";
					rs.writeLog(sql4);
					rs.execute(sql4);
					int i = 0;
					Double cz0 = 0.00;
					while (rs.next()) {
						cz0 = rs.getDouble("cz");
						if (i == 0 || i == 2) {
							lastCz0 = calculateAdd(lastCz0, cz0);
						}
						if (i == 1) {
							lastCz0 = calculateSub(lastCz0, cz0);
						}
						i++;
					}
					lastCz = lastCz0.toString();

				} else {

					String sql3 = "select cz from uf_gbjl where zxjhh='" + zxjhh + "' and sfzf='0' ORDER BY id desc";
					rs.writeLog(sql3);
					rs.execute(sql3);
					if (rs.next()) {
						lastCz = Util.null2String(rs.getString("cz"));
					}
					rs.writeLog("获得的上一次的出重值为：" + lastCz);
				}
			}
			CalUtil calUtil=new CalUtil();

			String jz=Double.toString(calculateJZ(lastCz, jzzl));


			rs.writeLog("计算出的净重为："+jz);
			//进入 每个提入单的 分摊重量 及 每个订单项次的允差 校验，
			//而 当check=true --为卸载车头情况（需要四次过磅） 同时 已过磅数量小于3次时候 不执行该函数
			if (!(check&&count<3)){
				jsonObject=ftzlAndYcControl(zxjhh,lx,trdh,jz);
				if (jsonObject!=null) {
					out.write(jsonObject.toString());
					return;
				}

			}

			


			Date date = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
			String currentDate = sdf.format(date);
			String gbrq = currentDate.substring(0, 10);
			String gbsj = currentDate.substring(11, 16);
			String sql4 = "insert into UF_GBJL (ZXJHH,CP,SHIPPING,GBRQ,GBSJ,RZ,CZ,JZ,TRDH," +
					"FORMMODEID,MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid) values (";
			sql4 += "'" + zxjhh + "',";
			sql4 += "'" + carno + "',";
			sql4 += "'" + shipping + "',";
			sql4 += "'" + gbrq + "',";
			sql4 += "'" + gbsj + "',";
			if (check2){
			    sql4+="null,";
			}else {
				sql4 += "'" + null2Double(lastCz) + "',";
			}
			sql4 += "'" + null2Double(jzzl) + "',";
			if (check2){
			    sql4+="null,";
			}else {
				sql4 += "'" + jz + "',";
			}
			if (check2){
			    sql4+="null,";
			}else {
				sql4 += "'" + trdh + "',";
			}
			sql4+="'841',";
			sql4+="'1',";
			sql4+="'0',";
			Date d1=new Date();
			SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
			SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");
			sql4+="'"+dateFormat.format(d1)+"',";
			sql4+="'"+dateFormat1.format(d1)+"',";
			String str1 = UUID.randomUUID().toString();
			sql4+="'"+str1+"')";

			rs.writeLog("插入sql4:" + sql4);
			rs.executeSql(sql4);
			message += "过磅插入成功\\n";

			sql="select id from UF_GBJL where modeuuid='"+str1+"'";
			rs.writeLog(sql);
			rs.execute(sql);
			String id="";
			if(rs.next()){
				id=Util.null2String(rs.getString("id"));
			}
			ModeRightInfo localModeRightInfo1 = new ModeRightInfo();
			localModeRightInfo1.setNewRight(true);
			localModeRightInfo1.editModeDataShare(1, 841, Integer.parseInt(id));

			//如果是卸车头，并且不是第四次的话，则不进行已过磅的提入单数量判断
			if (check&&(count==1)){
			    rs.writeLog("check:"+check+",count:"+count);
			    return;
			}
			//最后查询目前的已过磅的提入单数量是否等于总数
			sql0="SELECT ID FROM UF_GBJL WHERE ZXJHH='"+ zxjhh + "' and sfzf='0' and trdh is not null";
			rs.writeLog("最后查询"+zxjhh+"提入单总数量:"+totalBillCounts);
			rs.writeLog("最后查询目前的已过磅的提入单数量sql："+sql0);
			rs.execute(sql0);
			nowBillCounts=rs.getCounts();
			rs.writeLog("nowBillCounts:"+nowBillCounts);
			//如果已过磅的提入单数量是否等于总数,则需要更新装卸计划表重
			String rz="";
			String cz="";
			String gbrq0="";
			String gbsj0="";
			if(totalBillCounts==nowBillCounts){
			    //非卸车头情况
			    if (!check) {
					sql0 = "SELECT " + rzFlag + " RZ," + czFlag + " CZ FROM UF_GBJL WHERE ZXJHH='" + zxjhh + "' and sfzf='0' AND RZ IS NOT NULL" +
							" AND CZ IS NOT NULL";


					rs.writeLog("查询装卸计划在过磅记录中的最大值与最小值sql：" + sql0);
					rs.execute(sql0);
					while (rs.next()) {
						rz = rs.getString("RZ");
						cz = rs.getString("CZ");
					}
				}

				//如果是卸载车头的情况，要重新计算前面三次的入重
				if (check){
				    sql0="select cz from uf_gbjl where zxjhh='"+zxjhh+"' and sfzf='0' order by id asc";
				    rs.writeLog(sql0);
				    rs.execute(sql0);
				    Double rz0=0.00;
				    int i=1;
				    while (rs.next()){
				        Double cz0=rs.getDouble("cz");
				        if (i==1){
				            rz0=cz0;
						}
						if (i==2){
				            rz0=calculateSub(rz0,cz0);
						}
						if (i==3){
				            rz0=calculateAdd(rz0,cz0);
						}
						if (i==4){
				            break;
						}
						i++;
					}
					rz=rz0.toString();
				    sql0="select "+czFlag+" cz from  UF_GBJL where ZXJHH='POZXJH201803150143' and id not in(SELECT id FROM UF_GBJL WHERE ZXJHH='POZXJH201803150143' and sfzf='0' and ROWNUM<4)" +
							" and SFZF='0'";
				    rs.writeLog(sql0);
				    rs.execute(sql0);
				    if (rs.next()){
				        cz=rs.getString("cz");
					}
				}
				rs.writeLog("获得rz："+rz+",cz:"+cz);
				sql0="SELECT GBRQ,GBSJ FROM UF_GBJL WHERE ZXJHH='"+zxjhh+"' and sfzf='0' ORDER BY GBRQ DESC,GBSJ DESC";
				rs.writeLog("查询装卸计划在过磅记录中的最大日期时间："+sql0);
				rs.execute(sql0);
				while(rs.next()){
					gbrq0=rs.getString("GBRQ");
					gbsj0=rs.getString("GBSJ");
				}
				rs.writeLog("获得gbrq："+gbrq0+",gbsj:"+gbsj0);
				message+="更新装卸计划表成功\\n";

				if("".equals(rz) || "".equals(cz) || "".equals(gbrq0) || "".equals(gbsj0)){
					message+="查询数据有误\\n";
				}else{
					Double gbzl=0.00;
					gbzl=calculateJZ(rz, cz);
					//回写装卸计划流程
					String formnameJM=getFormNameByLxJM(lx);
					sql0="UPDATE "+formnameJM+" SET SFGB='1',GBRQ='"+gbrq+"',GBSJ='"+gbsj+"',"	;
					sql0+="CRZ='"+rz+"',CCZ='"+cz+"',GBZL='"+gbzl+"'";
					if (!"2".equals(lx)){
					  sql0+=",sjysrq='"+gbrq+"'";
					}
					sql0+=" WHERE ZXJHH='"+zxjhh+"'";
					rs.writeLog("更新装卸计划sql："+sql0);
					rs.execute(sql0);
					message+="更新装卸计划流程成功\n";
					//更新总净重为 实际过磅净重
					updateZjz(zxjhh,lx);


				}

				request.setAttribute("message", message);
				//request.getRequestDispatcher("/weightJsp/Apportionment _Weight.jsp?zxjhh="+zxjhh+"&lx="+lx)
				request.getRequestDispatcher("/weightJsp/CALC_MAINYF.jsp?zxjhh=" + zxjhh + "&lx=" + lx)
						.forward(request, response);

			};
			jsonObject = addJsonJZ(message);
			out.write(jsonObject.toString());

			return;

		}

		//提入单校验
		if ("checkPlate1".equals(action)) {

			rs.writeLog("进入checkPlate1");
			String plate = request.getParameter("plate").toUpperCase();
			String carno = request.getParameter("carno");
			rs.writeLog("获得的参数:plate--" + plate + ",carno--" + carno);
			String sql1 = "select zxjhh,lcid,sfdy,lx,sfzf from uf_trdpldy where trdh='" + plate + "'";
			rs.writeLog(sql1);
			rs.execute(sql1);
			String message = "";//消息
			String newcp = "";//车牌
			String trdStatus = "0";//提入单状态
			String ptStatus = "0";//是否为四次过磅
			String zxjhh="";//装卸计划号

			JSONObject jsonObject;
			while (rs.next()) {

				String sfzf = Util.null2String(rs.getString("sfzf"));
				if ("1".equals(sfzf)){
					message = "提入单已作废";
					jsonObject = addJson(message, newcp, trdStatus, ptStatus);
					out.write(jsonObject.toString());
					return;
				}
				String lcid = Util.null2String(rs.getString("lcid"));
				String sfdy = Util.null2String(rs.getString("sfdy"));
				String lx = Util.null2String(rs.getString("lx"));
				zxjhh=Util.null2String(rs.getString("zxjhh"));
				String formname=getFormNameByLxJM(lx);

				if ("".equals(lcid)) {
					message = "提入单打印表中流程编号为空";
					jsonObject = addJson(message, newcp, trdStatus, ptStatus);
					out.write(jsonObject.toString());
					return;
				}
				trdStatus = "1";
				if (!"1".equals(sfdy)) {
					message = "提入单尚未打印";
					jsonObject = addJson(message, newcp, trdStatus, ptStatus);
					out.write(jsonObject.toString());
					return;
				}
				ptStatus = checkFourTimesWeigh(plate);//校验是否为四次过磅
				if ("1".equals(ptStatus)){
					message+="提入单物料号包含'R0000125'，首次入场过磅建议选择卸载车头\n";
				}

				String sql2 = "select cp from "+formname+" where zxjhh='" + zxjhh+"'";
				rs.writeLog(sql2);
				rs.execute(sql2);
				while (rs.next()) {
					String cp = rs.getString("cp");
					if ("".equals(cp)) {
						if ("".equals(carno)) {
							message+= "装卸计划表中车牌为空\n";

							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
						if (!"".equals(carno)) {
							String sql3 = "update "+formname+" set cp='" + carno + "' where zxjhh='"
									+ zxjhh + "'";
							rs.writeLog(sql3);
							rs.execute(sql3);
							message += "提入单已打印，更新车牌成功\n";
							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
					}
					if (!"".equals(cp)) {
						if ("".equals(carno)) {
							newcp = cp;
							message+= "提入单可以查到装卸计划的车牌\n";
							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
						if (!"".equals(carno)) {
							if (carno.equals(cp)) {
								message += "输入的车牌与装卸计划表的一致\n";
								jsonObject = addJson(message, newcp, trdStatus, ptStatus);
								bs.writeLog(jsonObject.toString());
								out.write(jsonObject.toString());
								return;
							}
							if (!carno.equals(cp)) {
								String sql4 = "update "+formname+" set cp='" + carno
										+ "' where zxjhh='" + zxjhh + "'";
								rs.writeLog(sql4);
								rs.execute(sql4);
								message += "输入的车牌与装卸计划表的不一致，已更新\n";
								jsonObject = addJson(message, newcp, trdStatus, ptStatus);
								bs.writeLog(jsonObject.toString());
								out.write(jsonObject.toString());
								return;
							}


						}
					}
				}

			}
			message = "提入单不存在";
			jsonObject = addJson(message, newcp, trdStatus, ptStatus);
			out.write(jsonObject.toString());
			return;

		}
		//虚拟删除
		if("deleteweigh".equals(action)){
		    rs.writeLog("进入deleteweigh");
		    String message="";
		    //如果已经称过入重 但是尚未过磅，则可以删除入重记录，否则提示不能删除
			String plate=request.getParameter("plate").toUpperCase();
			String carno=request.getParameter("carno");
			String reason=request.getParameter("reason");

			rs.writeLog("获得提入单号："+plate+",获得删除原因："+reason+",车牌："+carno);
			String sql="";
			String zxjhh="";
			if ((!plate.equals(""))&&!(plate==null)) {
				sql = "select DISTINCT zxjhh from UF_TRDPLDY where trdh='" + plate + "'";
				rs.writeLog(sql);
				rs.execute(sql);
				if (rs.next()) {
					zxjhh = Util.null2String(rs.getString("zxjhh"));
				}

				sql = "SELECT COUNT(*) AS COUNT FROM UF_GBJL WHERE ZXJHH='" + zxjhh + "' and sfzf='0'";
				rs.writeLog(sql);
				rs.execute(sql);
				int count = 0;
				if (rs.next()) {
					count = rs.getInt("count");
				}
				if (count != 1) {
					message = "unable";
				} else {
					sql = "update UF_GBJL set sfzf='1',deleteReason='" + reason + "' where zxjhh='" + zxjhh + "'";
					rs.writeLog(sql);
					rs.execute(sql);
					message = "success";
				}
			}else if((!carno.equals(""))&&!(carno==null)){

				sql="select id,gh FROM UF_GBJL WHERE CP='"+carno+"' ORDER BY ID DESC";
				rs.writeLog(sql);
				rs.execute(sql);
				String id="";
				String gh="";
				if (rs.next()){
					id=Util.null2String(rs.getString("id"));
					gh=Util.null2String(rs.getString("gh"));
				}
				if ("".equals(id)||"".equals(gh)){
				    rs.writeLog("未查询到车牌"+carno+"的过磅记录,或者该车辆已经过磅");
					message = "unable";

				}else {
					sql = "update UF_GBJL set sfzf='1',deleteReason='" + reason + "' where id=" + id + "";
					rs.writeLog(sql);
					rs.execute(sql);
				    message="success";

				}
			}
			JSONObject jsonObject=addJsonJZ(message);

			rs.writeLog(jsonObject.toString());
			out.write(jsonObject.toString());
			return;


		}

		objectresult.put("result", jsonArr);
		//PrintWriter pw = response.getWriter();
		out.write(objectresult.toString());
		//out.write("过磅操作jsp返回的json:");
		//pw.write(objectresult.toString());
		rs.writeLog("返回json：" + objectresult.toString());
		//pw.flush();
		//pw.close();
		return;
	} catch (Exception e) {
		// TODO: handle exception
		//out.write("fail" + e);
		rs.writeLog("fail--" + e);
		e.printStackTrace();


	}
%>

<%!
    private Boolean checkBulk(String trdh, String lx) {
        Boolean isBulk=false;
        String jydh="";
        String xc="";
        RecordSet rs=new RecordSet();
        String VKAUS="";//包装性质 判断是否为散装
        StringBuffer stringBuffer=new StringBuffer()
                .append("	SELECT	 	 	")
                .append("JYDH,")
                .append("DDXC	 	")
                .append("	FROM	 	 	")
                .append("	 	UF_TRDPLDY T1,	 	")
                .append("	 	UF_TRDPLDY_DT1 T2	 	")
                .append("	WHERE	 	 	")
                .append("	 	T1. ID = T2.MAINID	 	")
                .append("	AND T1.TRDH = '").append(trdh).append("'			");
        rs.writeLog(stringBuffer);
        rs.execute(stringBuffer.toString());
        if (rs.next()) {
            jydh = Util.null2String(rs.getString("jydh"));
            xc = Util.null2String(rs.getString("ddxc"));
        }
        StringBuffer stringBuffer0=new StringBuffer();
        if ("0".equals(lx)) {
            stringBuffer0.append("SELECT")
                    .append("  VKAUS ")
                    .append(" FROM")
                    .append(" uf_spghsr")
                    .append(" WHERE")
                    .append(" DELIVERYNO = '").append(jydh).append("'")
                    .append(" AND DELIVERYITEM = '").append(xc).append("'");
        }
        if ("1".equals(lx)) {
            stringBuffer0
                    .append("SELECT  ")
                    .append(" packxz as VKAUS  ")
                    .append("FROM  ")
                    .append(" uf_jmclxq ")
                    .append("WHERE  ")
                    .append(" PONO = '").append(jydh).append("'")
                    .append(" AND POITEM='").append(xc).append("'");
        }
        if ("2".equals(lx)){
            stringBuffer0
                    .append("	SELECT	 	")
                    .append("	 	T2.VKAUS	")
                    .append("	FROM	 	")
                    .append("	 	uf_fsapclxq T1,	")
                    .append("	 	UF_FSAPCLXQ_DT1 T2	")
                    .append("	WHERE	 	")
                    .append("	 	T1. ID = T2.MAINID	")
                    .append("	  AND T1.FLOWNO='").append(jydh).append("'		")
                    .append("	  AND T2.ITEM='").append(xc).append("'		");

        }
        rs.writeLog(stringBuffer0);
        rs.execute(stringBuffer0.toString());

        if ("0".equals(lx)) {
            if ("Z01".equals(VKAUS)) {
                isBulk=true;
                rs.writeLog("交运单号：" + jydh + "项次：" + xc + ",包装为：" + VKAUS + "");
            }
        }
        if ("1".equals(lx)) {
            if ("Z01".equals(VKAUS)) {
                isBulk=true;

                rs.writeLog("采购单号：" + jydh + "项次：" + xc + ",包装为：" + VKAUS + "");
            }
        }
        if ("2".equals(lx)){
            if ("Z01".equals(VKAUS)) {
                isBulk=true;
                rs.writeLog("原始单号：" + jydh + "项次：" + xc + ",包装为：" + VKAUS + "");
            }
        }


        return isBulk;
    }

    public Double calculateJZ(String rz, String cz){
	Util.getDoubleValue("0.00");
	if("".equals(rz) ||rz==null){

		rz="0.00";
	}
	if("".equals(cz) ||rz==null){

		cz="0.00";
	}
	//计算净重的绝对值
	BigDecimal b1=new BigDecimal(rz);
	BigDecimal b2=new BigDecimal(cz);
	Double b3=b1.subtract(b2).setScale(2,BigDecimal.ROUND_HALF_UP).doubleValue();
	return Math.abs(b3);
}%>

<%!public String null2Double(String str){
	String d1="0.00";
	if("".equals(str) ||str==null){
		return d1;
	}
	return str;


}%>

<%!public JSONObject addJsonJZ(String message) {

	return addJson(message, null, null, null);
}%>
<%!public JSONObject addJson(String message, String newcp, String trdStatus, String ptStatus) {
	JSONObject jsonobj = new JSONObject();
	jsonobj.put("message", message);
	jsonobj.put("cp", newcp);
	jsonobj.put("trdStatus", trdStatus);
	jsonobj.put("ptStatus", ptStatus);
	return jsonobj;
}%>

<%!public String getFormNameByLx(String lx){
    String formname="";
	if("0".equals(lx)){
		formname="formtable_main_45";
	}
	if("1".equals(lx)){
		formname="formtable_main_61";
	}
	if("2".equals(lx)){
		formname="formtable_main_88";
		//formname="uf_fsapzxjh";//非SAP装卸计划建模表
	}
	return  formname;
}
	public String getFormNameByLxJM(String lx){
		String formname="";
		if("0".equals(lx)){
			formname="formtable_main_45";
		}
		if("1".equals(lx)){
			formname="formtable_main_61";
		}
		if("2".equals(lx)){
			formname="uf_fsapzxjh";
			//formname="uf_fsapzxjh";//非SAP装卸计划建模表
		}
		return  formname;
	}

%>
<%!public String getZxjhhByRequestid(String requestid,String formname){
	String zxjhh="";
	RecordSet recordSet=new RecordSet();
	String sql="select zxjhh from "+formname+" where requestid="+requestid;
	recordSet.writeLog(sql);
	recordSet.execute(sql);
	if(recordSet.next()){
	    zxjhh=Util.null2String(recordSet.getString("zxjhh"));
	}
	return zxjhh;
}
%>
<%!public String getZxjhhByTrdh(String trdh){
    String zxjhh="";
	RecordSet rs=new RecordSet();
	String sql0 = "SELECT lcid,lx FROM UF_TRDPLDY  where 1=1";
	if (trdh != null) {
		sql0 += " and TRDH = '" + trdh + "'";
	}
	rs.writeLog(sql0);
	rs.executeSql(sql0);
	String requestid="";
	String lx="";
	if (rs.next()) {
		lx = rs.getString("lx");
		requestid=rs.getString("lcid");
	}
	String formname=getFormNameByLx(lx);
	zxjhh=getZxjhhByRequestid(requestid,formname);
    return zxjhh;
}
%>
<%!public String getShippingByRequestid(String requestid,String lx){
    String sql="";
    String shipping="";
    String formname=getFormNameByLx(lx);
  	if("".equals(lx)){
		sql="select YGSHIPNO from "+formname+" where requestid='"+requestid+"'";
		RecordSet recordSet=new RecordSet();
		recordSet.writeLog(sql);
		recordSet.execute(sql);
		if(recordSet.next()){
			shipping=Util.null2String(recordSet.getString("ygshipno"));
		}
	}
	return shipping;
}
%>
<%!public String getLxByTrdh(String trdh){
    String lx="";
    RecordSet recordSet=new RecordSet();
    String sql="select lx from uf_trdpldy where trdh='"+trdh+"'";
    recordSet.writeLog(sql);
    recordSet.execute(sql);
    if(recordSet.next()){
        lx=Util.null2String(recordSet.getString("lx"));
	}
    return lx;
}
%>
<%!public String getFormnameByTrdh(String trdh){
    String formname="";
	String lx="";
	RecordSet recordSet=new RecordSet();
	String sql="SELECT LX FROM UF_TRDPLDY WHERE TRDH='"+trdh+"'";
	recordSet.writeLog(sql);
	recordSet.execute(sql);
	if (recordSet.next()){
	    lx=Util.null2String(recordSet.getString("lx"));
	}
	formname=getFormNameByLx(lx);
    return formname;
}


%>
<%!public  Boolean checkUnloadingHead(String zxjhh){
    Boolean result=false;
    RecordSet recordSet=new RecordSet();
	String unloadingHead="";
	String sql="";
    sql="select unloadingHead from uf_gbjl where zxjhh='"+zxjhh+"' and sfzf='0' order by id asc";
    recordSet.writeLog(sql);
    recordSet.execute(sql);
    if (recordSet.next()){
		unloadingHead=Util.null2String(recordSet.getString("unloadingHead"));

	}
	if ("1".equals(unloadingHead)){
        result=true;
	}
    return result;
}

%>
<%!public Boolean checkUnloadingHeadJZ(Boolean check,int count){
    RecordSet recordSet=new RecordSet();
    recordSet.writeLog("check:"+check+",count:"+count);
    Boolean result=false;
	if (check){
	    if(count==0){
	        result=true;
		}
	}
	return result;

}

%>
<%!public Double calculateAdd(Double jz0,Double cz0){
    Double result=0.00;
	BigDecimal b1=new BigDecimal(jz0);
	BigDecimal b2=new BigDecimal(cz0);
	result=b1.add(b2).doubleValue();
    return result;
}

%>
<%!
	private void updateZjz(String zxjhh, String lx) {
	    String sql="";
	    String updateSql="";
	    String tablename=getFormNameByLxJM(lx);
	    Double zgz=0.00;//总柜重
		Double bzclzzl=0.00;//包装材料总重量
		Double gbzl=0.00;//过磅重量
		Double newZjz=0.00;//重算的总净重
		RecordSet rs=new RecordSet();
	    if("0".equals(lx)){
	        sql="select zgz,bzclzzl,gbzl from "+tablename+" where zxjhh='"+zxjhh+"' and requestid is null";
		}
	    if("1".equals(lx)){
	        sql="select bzclzzl,gbzl from "+tablename+" where zxjhh='"+zxjhh+"'";
		}
	    if("2".equals(lx)){
	        sql="select gbzl from "+tablename+" where zxjhh='"+zxjhh+"'";
		}
		String zjzFlag="zjz";
		if ("1".equals(lx)){
				zjzFlag="zjlhj";
		}
		rs.writeLog(sql);
	    rs.execute(sql);
	    if (rs.next()){

	        bzclzzl=Util.getDoubleValue(rs.getString("bzclzzl"));
	        if (bzclzzl<0){
	            bzclzzl=0.00;
			}
	        zgz=Util.getDoubleValue(rs.getString("zgz"));
	        if (zgz<0){
	            zgz=0.00;
			}
	        gbzl=rs.getDouble("gbzl");
	        if (gbzl<0){
	            gbzl=0.00;
			}
		}
		rs.writeLog(">>>bzclzzl:"+bzclzzl+",zgz:"+zgz+",gbzl:"+gbzl+"<<<");
		newZjz=calculateSub(calculateSub(gbzl,zgz),bzclzzl);
	        updateSql="update "+tablename+" set "+zjzFlag+" ='"+newZjz+"' where zxjhh='"+zxjhh+"'";
	        rs.writeLog(updateSql);
	        rs.execute(updateSql);


	}

	private String checkFourTimesWeigh(String plate) {
	    String result="0";
	    RecordSet rs=new RecordSet();
	    String sql="";
	    sql="SELECT T2.WLHM FROM UF_TRDPLDY T1,UF_TRDPLDY_DT1 T2 WHERE T1.ID=T2.MAINID AND T1.TRDH='"+plate+"'";
	    rs.writeLog(sql);
	    rs.execute(sql);
	    while (rs.next()){
	        String wlhm=rs.getString("wlhm");
	        if ("R0000125".equals(wlhm)){
	            result="1";
	            break;
			}
		}

	    return result;
	}

	private Boolean checkUnloadingHead1(int counts, Boolean check) {
	    Boolean result=false;
	    if (check){
	        if (counts!=3){
	            result=true;
			}
		}
	    return  result;
	}

	public Double calculateSub(Double jz0, Double cz0){
	Double result=0.00;
	BigDecimal b1=new BigDecimal(jz0);
	BigDecimal b2=new BigDecimal(cz0);
	result=b1.subtract(b2).doubleValue();
	return result;
}
//每一笔提入单过完磅都进行实际分摊重量、允差控制、数据表项次的已出货量的更新（只针对散装 SO:VKAUS='Z01' ，PO:）
	private JSONObject ftzlAndYcControl(String zxjhh,String lx,String trdh,String jz) {
		RecordSet rs = new RecordSet();
		BaseBean log = new BaseBean();
		CalUtil calUtil = new CalUtil();
		JSONObject jsonObject = new JSONObject();

		JSONArray jsonArray=new JSONArray();
		JSONArray jsonArray1=new JSONArray();

		String message = "";
		String sql0="";
	    /*
			每一笔提入单号，净重分摊重量,
			获取每一个项次的分摊总重量--xcWeightToatalCur
			 */
		String formtablename = "";
		if ("0".equals(lx)) {
			formtablename = DCCMTableNameConstant.SOZXJH;
		}
		if ("1".equals(lx)) {
			formtablename = DCCMTableNameConstant.POZXJH;
		}
		if ("2".equals(lx)){//当类型为非SAP
		    formtablename="uf_fsapzxjh";
		}
		String sfyg = "0";
		if (!"2".equals(lx)) {
			StringBuffer sqlSfyg = new StringBuffer()
					.append("SELECT ")
					.append(" SFYG FROM ")
					.append(formtablename)
					.append(" WHERE ZXJHH='")
					.append(zxjhh)
					.append("'");
			rs.writeLog(sqlSfyg.toString());
			rs.execute(sqlSfyg.toString());
			if (rs.next()) {
				sfyg = rs.getString("sfyg");
			}
		}
		String poDetailTableName = "";//对应明细表名
		if ("1".equals(lx)) {
			if ("0".equals(sfyg)) {
				poDetailTableName = "formtable_main_61_dt2";
			}
			if ("1".equals(sfyg)) {
				poDetailTableName = "formtable_main_61_dt1";
			}
		}
		StringBuffer stringBuffer4 = new StringBuffer();
		if ("0".equals(lx)) {
			stringBuffer4.append("SELECT")
					.append(" SUM (T2.BCCPJZ) AS SUM,SUM (T2.ZBCZL) AS SUM2")
					.append(" FROM")
					.append(" FORMTABLE_MAIN_45 T1,")
					.append(" FORMTABLE_MAIN_45_DT3 T2")
					.append(" WHERE")
					.append(" T1. ID = T2.MAINID")
					.append(" AND T1.REQUESTID IS NULL")
					.append(" AND T1.SFZF = '0'")
					.append(" AND T2.TRDH='" + trdh + "'");
		}

		if ("1".equals(lx)) {


			stringBuffer4.append("SELECT SUM(t2.BCJZL) AS SUM,SUM(t2.BZZL) AS SUM2 from ")
					.append(formtablename).append(" t1,")
					.append(poDetailTableName).append(" t2")
					.append(" WHERE t2.TRDH='")
					.append(trdh).append("'")
					.append(" and t1.sfzf='0'");
		}
		if ("2".equals(lx)){
		    stringBuffer4.append("SELECT SUM(T2.BCCPJZ) AS SUM FROM ")
			.append(formtablename).append(" t1,")
			.append(formtablename).append("_dt1 t2 ")
			.append("where T1.id=t2.MAINID and t2.trdh='").append(trdh).append("'")
			.append(" and t1.sfzf='0'");
		}
		log.writeLog(stringBuffer4.toString());
		rs.execute(stringBuffer4.toString());
		Double sumJz = 0.00;//该提入单下的明细的总产品理论净重
		Double bcSum = 0.00;//该提入单下的明细的总包装材料重量
		if (rs.next()) {

			sumJz = rs.getDouble("sum");
			bcSum =Util.getDoubleValue(rs.getString("sum2"));

			if (sumJz < 0) {
				sumJz = 0.00;
			}
			if (bcSum < 0) {
				bcSum = 0.00;
			}
		}

		/**
		 * 查询柜重
		 * so需要查询柜重，po和非SAP不需要
		 */
		Double gz = 0.00;//柜重
		if ("1".equals(sfyg)) {

			if ("0".equals(lx)) {
				StringBuffer stringBuffer = new StringBuffer();
				stringBuffer.append("SELECT")
						.append(" T2.GBM")
						.append(" FROM")
						.append(" FORMTABLE_MAIN_45 T1,")
						.append("FORMTABLE_MAIN_45_DT3 T2")
						.append(" WHERE")
						.append(" T1. ID = T2.MAINID")
						.append(" AND T1.REQUESTID IS NULL")
						.append(" AND T1.SFZF = '0'")
						.append(" AND T2.TRDH='" + trdh + "'");
				log.writeLog(stringBuffer.toString());
				rs.execute(stringBuffer.toString());

				String gbm = "";
				if (rs.next()) {
					gbm = Util.null2String(rs.getString("gbm"));
				}
				//查询柜重
				StringBuffer stringBuffer1 = new StringBuffer()
						.append("SELECT  ")
						.append(" GZ ")
						.append("FROM  ")
						.append(" FORMTABLE_MAIN_45_DT1 T1, ")
						.append(" FORMTABLE_MAIN_45 T2 ")
						.append("WHERE  ")
						.append(" T1.MAINID = T2. ID ")
						.append("AND T2.REQUESTID IS NULL ")
						.append(" AND T1.GBH = '").append(gbm).append("'")
						.append(" AND T2.ZXJHH='").append(zxjhh).append("'");

				log.writeLog(stringBuffer1);
				rs.execute(stringBuffer1.toString());
				if (rs.next()) {
					gz = Util.getDoubleValue(rs.getString("gz"));
					if (gz < 0) {
						gz = 0.00;
					}
				}
			}


		}
		Boolean isBulk=false;//是否为散装
		/**
		 * 根据提入单类型查询是否为散装
         *
		 */
		isBulk=checkBulk(trdh,lx);

		/**
		 * 			计算实际净重：
		 公式：  实际净重=过磅净重-该提入单的包材总重量-该提入单的柜重
		 散装不需要减去包材料总重量
		 *
		 */
        Double sjjz=0.00;
        if(isBulk){
            sjjz = calUtil.sub(Double.parseDouble(jz), gz);

        }else {
            sjjz = calUtil.sub(calUtil.sub(Double.parseDouble(jz), bcSum), gz);
        }
		log.writeLog("获得实际净重：" + sjjz);

		StringBuffer stringBuffer3 = new StringBuffer();
		if ("0".equals(lx)) {
			stringBuffer3.append("SELECT")
					.append(" T2.ID,T2.BCCPJZ,T2.JYDH,T2.XC")
					.append(" FROM")
					.append(" FORMTABLE_MAIN_45 T1,")
					.append(" FORMTABLE_MAIN_45_DT3 T2")
					.append(" WHERE")
					.append(" T1. ID = T2.MAINID")
					.append(" AND T1.REQUESTID IS NULL")
					.append(" AND T1.SFZF = '0'")
					.append(" AND T2.TRDH='" + trdh + "'");
		}
		if ("1".equals(lx)) {
			stringBuffer3.append("select")
					.append(" t2.id,t2.jzl as bccpjz,t2.PONO AS jydh,t2.POITEM AS xc")
					.append(" from ")
					.append(formtablename).append(" t1,")
					.append(poDetailTableName).append(" t2")
					.append(" where t1.id=t2.mainid")
					.append(" and t1.sfzf='0'")
					.append(" and t2.trdh='").append(trdh).append("'");
		}
		if ("2".equals(lx)){
		    stringBuffer3.append(" select ")
					.append(" t2.id,t2.bccpjz,t2.ysddh as jydh,t2.ddxc as xc")
					.append(" from ").append(formtablename).append(" t1,")
					.append(formtablename).append("_dt1 t2")
					.append(" where t1.id=t2.mainid")
					.append(" and t1.sfzf='0'")
					.append(" and t2.trdh='").append(trdh).append("'");
		}


		log.writeLog(stringBuffer3.toString());
		rs.execute(stringBuffer3.toString());

		while (rs.next()) {
			JSONObject jsonObject1 = new JSONObject();
			String id = rs.getString("id");
			Double bccpjz = Util.getDoubleValue(rs.getString("bccpjz"));//本次产品净重
			if (bccpjz < 0) {
				bccpjz = 0.00;
			}
			String JYDH = Util.null2String(rs.getString("JYDH"));//交运单号
			String XC = Util.null2String(rs.getString("XC"));//项次
			jsonObject1.put("id", id);
			jsonObject1.put("bccpjz", bccpjz);
			jsonObject1.put("xc", XC);
			jsonObject1.put("jydh", JYDH);
			jsonArray.add(jsonObject1);
		}
		log.writeLog("获得明细本次理论净重明细：" + jsonArray);
		Double sum0 = 0.00;
		for (int i = 0; i < jsonArray.size(); i++) {
			Double sjftjz = 0.00;
			Double bccpjz = 0.00;
			String id = "";
			JSONObject jsonObject1 = jsonArray.getJSONObject(i);
			bccpjz = jsonObject1.getDouble("bccpjz");
			//id=jsonObject1.getString("id");
			//最后一笔重量计算：实际净重 -之前累加重量
			if (i == (jsonArray.size() - 1)) {
				sjftjz = calUtil.sub(sjjz, sum0);

			} else {
				sjftjz = calUtil.mulTwo(sjjz, calUtil.div(bccpjz, sumJz));
				sum0 = calUtil.add(sum0, sjftjz);
			}
			jsonObject1.put("sjftjz", sjftjz);

			//String sqlUpdateSjftjz="update FORMTABLE_MAIN_45_DT3 set sjftjz="+sjftjz+" where id="+id;
			//rs.writeLog(sqlUpdateSjftjz);
			//rs.execute(sqlUpdateSjftjz);

		}
		log.writeLog("获得实际分摊净重明细：" + jsonArray);
		HashMap<String, Double> hp = new HashMap<String, Double>();
		for (int i = 0; i < jsonArray.size(); i++) {
			JSONObject jsonObject1 = jsonArray.getJSONObject(i);
			String jydh = jsonObject1.getString("jydh");
			String xc = jsonObject1.getString("xc");
			Double sjftjz = jsonObject1.getDouble("sjftjz");
			String key = jydh + "-" + xc;
			if (hp.containsKey(key)) {
				Double sjftjzOld = hp.get(key);
				sjftjz = calUtil.add(sjftjz, sjftjzOld);
			}
			hp.put(key, sjftjz);
		}
		calUtil.printMap(hp);




			/*
			SO过磅控制
			散装（固定包装不需要判断已过磅量）
			1.SO 行项目总量
			2.已经过磅总量 > SO 行项目总量*（1+过量允差）。需判断是否有无限过量允差标志，不是无限制的，如果2超过1，则报错，提示“交运单号XXX项次XX超过允差，无法过磅”
			*/


		StringBuffer stringBuffer5 = new StringBuffer();
		if ("0".equals(lx)) {
			stringBuffer5.append("SELECT T2.id,T1.zxjhh,T2.jydh,T2.xc,T2.TRDH,t2.sjftjz FROM FORMTABLE_MAIN_45 T1,FORMTABLE_MAIN_45_DT3 T2")
					.append(" WHERE T1.id=t2.MAINID and T1.REQUESTID IS NULL and t1.sfzf='0' and t2.trdh='").append(trdh).append("'");
		}
		if ("1".equals(lx)) {
			stringBuffer5.append("select t2.id,t2.ftzl as sjftjz,t2.pono as jydh,t2.poitem as xc from ")
					.append(formtablename).append(" t1,").append(poDetailTableName).append(" t2")
					.append(" where t1.id=t2.mainid and t1.sfzf='0' and t2.trdh='").append(trdh).append("'");
		}
		if ("2".equals(lx)){
		    stringBuffer5
					.append("	SELECT	 	")
					.append("	 	t2. ID,	")
					.append("	 	T2.SJFTJZ,	")
					.append("	 	t2.YSDDH AS jydh,	")
					.append("	 	t2.DDXC AS xc	")
					.append("	FROM	 	")
					.append("	 	uf_fsapzxjh T1,	")
					.append("	 	uf_fsapzxjh_DT1 T2	")
					.append("	WHERE	 	")
					.append("	 	T1. ID = T2.MAINID 	")
					.append("	 	and t1.SFZF='0'	")
					.append("	 	and t2.trdh='").append(trdh).append("'	");

		}
		log.writeLog(stringBuffer5.toString());
		rs.execute(stringBuffer5.toString());

		Map<String, Double> hp0 = new HashMap<String, Double>();

		while (rs.next()) {

			String detailId = rs.getString("id");//获取明细id
			String jydh = rs.getString("jydh");//交运单号
			String xc = rs.getString("xc");//项次
			Double sjftjz = 0.00;
			String sjftjz0 = Util.null2String(rs.getString("sjftjz"));//实际分摊净重
			if (!"".equals(sjftjz0)) {
				sjftjz = Double.parseDouble(sjftjz0);

			}else{
			    sjftjz=0.00;
			}
			//Double jhyzl=Util.getDoubleValue(rs.getString("jhyzl"));//计划运载量
			//Double sl=Util.getDoubleValue(rs.getString("sl"));//总数量

			String key = jydh + "-" + xc;//将交运单号-项次的格式 作为key
			Double newValue = 0.00;//相同交运单号项次 的累加实际分摊净重
			if (hp.containsKey(key)) {
				Double oldvalue = hp.get(key);
				newValue = calUtil.add(oldvalue, sjftjz);
			} else {
				newValue = sjftjz;
			}
			hp0.put(key, newValue);

		}
		log.writeLog("打印hp0");
		calUtil.printMap((HashMap) hp0);


		Iterator<Map.Entry<String, Double>> iterator = hp.entrySet().iterator();
		while (iterator.hasNext()) {
			Map.Entry<String, Double> map = iterator.next();
			String[] keys = map.getKey().split("-");
			Double value = map.getValue();
			String jydh = keys[0];
			String xc = keys[1];
			RecordSet recordSet = new RecordSet();
			JSONObject jsonObject1=new JSONObject();
			jsonObject1.put("ddh",jydh);
			jsonObject1.put("xc",xc);


			StringBuffer stringBuffer0 = new StringBuffer();
			if ("0".equals(lx)) {
				stringBuffer0.append("SELECT")
						.append(" UEBTK,VKAUS,LFIMG,UEBTO")
						.append(" FROM")
						.append(" uf_spghsr")
						.append(" WHERE")
						.append(" DELIVERYNO = '").append(jydh).append("'")
						.append(" AND DELIVERYITEM = '").append(xc).append("'");
			}
			if ("1".equals(lx)) {
				stringBuffer0
						.append("SELECT  ")
						.append(" packxz as VKAUS, ")
						.append(" UEBTK, ")
						.append(" UEBTO, ")
						.append(" ZWEIGHT AS LFIMG ")
						.append("FROM  ")
						.append(" uf_jmclxq ")
						.append("WHERE  ")
						.append(" PONO = '").append(jydh).append("'")
						.append(" AND POITEM='").append(xc).append("'");


			}
			if ("2".equals(lx)){
			    stringBuffer0
						.append("	SELECT	 	")
						.append("	 	T2.QUANTITY AS LFIMG,	")
						.append("	 	T2.UEBTK,	")
						.append("	 	T2.VKAUS,	")
						.append("	 	T2.UEBTO	")
						.append("	FROM	 	")
						.append("	 	uf_fsapclxq T1,	")
						.append("	 	UF_FSAPCLXQ_DT1 T2	")
						.append("	WHERE	 	")
						.append("	 	T1. ID = T2.MAINID	")
						.append("	  AND T1.FLOWNO='").append(jydh).append("'		")
						.append("	  AND T2.ITEM='").append(xc).append("'		");

			}
			log.writeLog(stringBuffer0.toString());
			recordSet.execute(stringBuffer0.toString());
			String UEBTK = "";//标识：允许未限制的过量交货 X
			String VKAUS = "";//散装固定包装(包装别) SO -- 散装 Z01  PO--- 散装 X
			Double UEBTO = 0.00;//过量交货限度 单位为百分之
			Double LFIMG = 0.00;//实际已交货量
			jsonObject1.put("VKAUS",VKAUS);
			if (recordSet.next()) {
				UEBTK = recordSet.getString("UEBTK");
				VKAUS = recordSet.getString("VKAUS");
				UEBTO = Util.getDoubleValue(recordSet.getString("UEBTO"));
				LFIMG = Util.getDoubleValue(recordSet.getString("LFIMG"));
				if (UEBTO < 0) {
					UEBTO = 0.00;
				}
				if (LFIMG < 0) {
					LFIMG = 0.00;
				}
			}
			if ("0".equals(lx)) {
				if ("X".equals(UEBTK) || "Z02".equals(VKAUS)) {
					log.writeLog("交运单号：" + jydh + "项次：" + xc + ",标识为：" + UEBTK + "，包装为：" + VKAUS + ",无需重量控制");
					continue;
				}
			}
			if ("1".equals(lx)) {
				if ("X".equals(UEBTK) || "".equals(VKAUS)) {
					log.writeLog("采购单号：" + jydh + "项次：" + xc + ",标识为：" + UEBTK + "，包装为：" + VKAUS + ",无需重量控制");
					continue;
				}
			}
			if ("2".equals(lx)){
			    log.writeLog("非SAP暂不进行允差控制");
			    continue;
			}

			//SO 最大允值= 行项目总量*（1+过量交货限度/100）
			Double ceilWeight = calUtil.mul(LFIMG, calUtil.add(1, calUtil.div(UEBTO, 100)));
			log.writeLog("获得最大允值：" + ceilWeight);


			StringBuffer stringBuffer6 = new StringBuffer();
			jsonObject1.put("ddh",jydh);
			jsonObject1.put("xc",xc);
			if ("0".equals(lx)) {


				stringBuffer6.append("SELECT")
						.append(" SUM (T2.SJFTJZ) as total")
						.append(" FROM")
						.append(" FORMTABLE_MAIN_45 T1,")
						.append("FORMTABLE_MAIN_45_DT3 T2")
						.append(" WHERE")
						.append(" T1. ID = T2.MAINID")
						.append(" AND T2.JYDH = '").append(jydh).append("'")
						.append(" AND T2.XC = '").append(xc).append("'")
						.append(" AND T1.REQUESTID IS NULL")
						.append(" AND T1.SFZF = '0'");

			}
			if ("1".equals(lx)) {
				stringBuffer6.append("SELECT")
						.append(" SUM (T2.ftzl) as total")
						.append(" FROM ")
						.append(formtablename).append(" T1,")
						.append(poDetailTableName).append(" T2")
						.append(" WHERE")
						.append(" T1. ID = T2.MAINID")
						.append(" AND T2.pono = '").append(jydh).append("'")
						.append(" AND T2.poitem = '").append(xc).append("'");
			}
			if ("2".equals(lx)) {
				stringBuffer6.append("SELECT")
						.append(" SUM (T2.SJFTJZ) as total")
						.append(" FROM ")
						.append(formtablename).append(" T1,")
						.append(formtablename).append("_dt1 T2")
						.append(" WHERE")
						.append(" T1. ID = T2.MAINID")
						.append(" AND T2.ysddh = '").append(jydh).append("'")
						.append(" AND T2.ddxc = '").append(xc).append("'");
			}
			log.writeLog(stringBuffer6.toString());

			recordSet.execute(stringBuffer6.toString());
			Double xcTotal = 0.00;//该交运单项次的
			if (recordSet.next()) {

				String total = Util.null2String(recordSet.getString("total"));
				if ("".equals(total) || total == null) {
					xcTotal = 0.00;
				} else {
					xcTotal = Double.parseDouble(total);
				}
			}
			log.writeLog("获得单号：" + jydh + ",项次：" + xc + ",已过磅值：" + xcTotal);
			Double xcTotalTT = calUtil.add(xcTotal, hp0.get(jydh + "-" + xc));
			log.writeLog("获得单号：" + jydh + ",项次：" + xc + ",加上本次的过磅总值：" + xcTotalTT);
			jsonObject1.put("sjchsl",xcTotalTT);
			jsonArray1.add(jsonObject1);
			if (xcTotalTT > 0) {
				if (ceilWeight < xcTotalTT) {
					message += "单号：" + jydh + ",项次：" + xc + "," +
							"\n已过磅量：" + xcTotal + ",本次值:" + hp0.get(jydh + "-" + xc) + "，合计：" + xcTotalTT + ",超过最大允值：" + ceilWeight;
					jsonObject = addJsonJZ(message);

					return jsonObject;

				}

			}
		}
		//允差校验完成后在进行明细表实际分摊重量的更新
		for (int i = 0; i < jsonArray.size(); i++) {
			JSONObject jsonObject1 = jsonArray.getJSONObject(i);
			Double sjftjz = jsonObject1.getDouble("sjftjz");
			String id = jsonObject1.getString("id");
			String sqlUpdateSjftjz = "";
			if ("0".equals(lx)) {
				sqlUpdateSjftjz = "update FORMTABLE_MAIN_45_DT3 set sjftjz=" + sjftjz + " where id=" + id;
			}
			if ("1".equals(lx)) {
				sqlUpdateSjftjz = "update " + poDetailTableName + " set ftzl=" + sjftjz + " where id=" + id;

			}
			if ("2".equals(lx)){
				sqlUpdateSjftjz = "update " +formtablename + "_dt1 set sjftjz=" + sjftjz + " where id=" + id;


			}
			rs.writeLog(sqlUpdateSjftjz);
			rs.execute(sqlUpdateSjftjz);
            if("0".equals(lx)){
                String sql="select sjgbjz from uf_spghsr where where id=" + id;
                rs.writeLog(sql);
                rs.execute(sql);
                Double sjgbjz=0.00;
                if (rs.next()){
                    String sjgbjzStr=Util.null2String(rs.getString("sjgbjz"));
                    if (!"".equals(sjgbjzStr)){
                        sjgbjz=Double.parseDouble(sjgbjzStr);
                    }
                }
                sjgbjz=calUtil.add(sjgbjz,sjftjz);
                if (sjgbjz>0){
                    sql="update uf_spghsr set sjgbjz='"+sjgbjz+"' " +
                            "where id=" + id;

                }
            }
		}

		//查询装卸计划表中有效的实际分摊净重，并更新为同步表中的实际出货数量
		log.writeLog(">>>更新同步表已出货量（散装）>>>");
		log.writeLog(">>>获得遍历jsonarray"+jsonArray1);
		for (int i = 0; i <jsonArray1.size() ; i++) {
			JSONObject jsonObject1=jsonArray1.getJSONObject(i);
			String ddh=jsonObject1.getString("ddh");
			String xc=jsonObject1.getString("xc");
			String sjchsl=jsonObject1.getString("sjchsl");//实际出货数量
			String VKAUS=jsonObject1.getString("VKAUS");//散装固定包装(包装别) SO -- 散装 Z01  PO--- 散装 X
			if ((!"X".equals(VKAUS))&&(!"Z01".equals(VKAUS))){
			log.writeLog(">>>ddh:"+ddh+",xc"+xc+",VKAUS"+VKAUS+",不需要更新出货量");
			continue;
			}
			log.writeLog(">>>ddh:"+ddh+",xc"+xc+",VKAUS"+VKAUS+",需要更新出货量");

			String updateSql="";
			if ("0".equals(lx)){
				updateSql="update uf_spghsr set REALSHIPNUM='"+sjchsl+"' " +
						"where DELIVERYNO='"+ddh+"' and DELIVERYITEM='"+xc+"'";
			}
			if ("1".equals(lx)){
			    updateSql="update uf_jmclxq set REALSHIPNUM='"+sjchsl+"'"+
				"where pono='"+ddh+"' and poitem='"+xc+"'";
			}
			if ("2".equals(lx)){
			    StringBuffer stringBuffer=new StringBuffer()
						.append("	SELECT	 	")
						.append("	 	T2. ID	")
						.append("	FROM	 	")
						.append("	 	UF_FSAPCLXQ t1,	")
						.append("	 	UF_FSAPCLXQ_DT1 t2	")
						.append("	 WHERE	 	")
						.append("	 	t1. ID = t2.MAINID	")
						.append("	  AND T1.FLOWNO = '").append(ddh).append("'		")
						.append("	  AND T2.ITEM = '").append(xc).append("'		");
				rs.writeLog(stringBuffer.toString());
				rs.execute(stringBuffer.toString());
				String id="";
				if (rs.next()){
					id=rs.getString("id");
				}

				updateSql="update UF_FSAPCLXQ_DT1 set hadquan='"+sjchsl+"' "+
				"where id="+id;


			}
			log.writeLog(updateSql);
			rs.execute(updateSql);

		}


		return  null;
	}




%>