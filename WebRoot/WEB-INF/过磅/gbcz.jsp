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
			String trdh = request.getParameter("plate");//提入单号
			String carno = request.getParameter("carno1");//车牌
			String weighType=request.getParameter("weighType");//计重类型
			rs.writeLog("取得的数据为 提入单号为:" + trdh + ",车牌号为：" + carno+",计重类型为:"+weighType);
			String sql="";
			if(weighType.equals("weighkg")){
				sql="SELECT * FROM UF_GBJL WHERE CP='"+carno+"' AND TRDH is NULL  ORDER BY GBRQ DESC,GBSJ DESC";
			}else{
				String zxjhh=getZxjhhByTrdh(trdh);
				sql="select * from uf_gbjl where zxjhh='"+zxjhh+"'";
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
			String trdh = request.getParameter("plate");//提入单号
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

			jzzl = Util.null2String(request.getParameter("weight"));//计重重量

			String trdh = Util.null2String(request.getParameter("plate"));//提入单号
			String carno = Util.null2String(request.getParameter("carno"));//车牌
			String weighType=Util.null2String(request.getParameter("weighType"));//计重类型
			String ggh=Util.null2String(request.getParameter("ggh"));//柜罐号
			rs.writeLog("取得的数据为 提入单号为:" + trdh + ",车牌号为：" + carno + ",计重重量为：" + jzzl+",计重类型为："+weighType);

			JSONObject jsonObject = new JSONObject();
			String message = "";
			//计重空柜情况
			if(weighType.equals("weighkg")){
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
				String sql = "INSERT INTO UF_GBJL (CP,GBRQ,GBSJ,RZ,GH,KGSL) VALUES (";

				sql += "'" + carno + "',";
				sql += "'" + gbrq + "',";
				sql += "'" + gbsj + "',";
				sql += "'" + jzzl + "',";
				sql += "'" + ggh+ "'";
				sql += "," + sl+ ")";
				rs.writeLog("空柜插入sql:" + sql);
				rs.executeSql(sql);
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
				if (sfdy.equals("0")) {
					message += "提入单没有打印";
					jsonObject = addJsonJZ(message);
					out.write(jsonObject.toString());
					return;
				} else if (sfdy.equals("1")) {
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

						String sql0 = "select id from UF_GBJL where zxjhh='" + zxjhh + "'";
						rs.writeLog(sql0);
						rs.execute(sql0);

						int count = rs.getCounts();

						if (count == 0) {
							rs.writeLog("装卸计划尚未计重");
							if (cp == null || cp.equals("") || !cp.equals(carno)) {
								String sql2 = "UPDATE "+formname+" set cp='" + carno + "' where REQUESTID="
										+ reqid;
								rs.writeLog(sql2);
								rs.executeSql(sql2);
								message += "车牌已更新<br/>";

							}
							Date date = new Date();
							SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
							String currentDate = sdf.format(date);
							String gbrq = currentDate.substring(0, 10);
							String gbsj = currentDate.substring(11, 16);
							String sql3 = "insert into UF_GBJL (ZXJHH,CP,SHIPPING,GBRQ,GBSJ,RZ,CZ," +
									"FORMMODEID,MODEDATACREATER,modedatacreatertype,modedatacreatedate,modedatacreatetime,modeuuid) values (";
							sql3 += "'" + zxjhh + "',";
							sql3 += "'" + carno + "',";
							sql3 += "'" + shipping + "',";
							sql3 += "'" + gbrq + "',";
							sql3 += "'" + gbsj + "',";
							sql3 += "'" + jzzl + "',";
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
							sql3+="'"+str1+"')";

							rs.writeLog(sql3);
							rs.executeSql(sql3);

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

							message += "该提入单所属装卸计划已经计重过，无需重复计重！";
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
		if ("insertGB".equals(action)) {
		    String formname="";
			rs.writeLog("insertGB");
			String jzzl = "0.00";//过磅重量

			jzzl = Util.null2String(request.getParameter("weight"));//计重重量
			String weighType=Util.null2String(request.getParameter("weighType"));
			String ggh=Util.null2String(request.getParameter("ggh"));
			String trdh = request.getParameter("plate");//提入单号
			String lx=getLxByTrdh(trdh);
			formname=getFormNameByLx(lx);
			String carno = request.getParameter("carno");//车牌
			rs.writeLog("获得提入单号：" + trdh + ",车牌：" + carno + ",过磅重量" + jzzl+",计重类型"+weighType+",柜罐号："+ggh);
			JSONObject jsonObject = new JSONObject();
			String message = "";
			//空柜情况
			if(weighType.equals("weighkg")){

				String sql1="SELECT GBRQ,GBSJ,RZ FROM UF_GBJL WHERE CP='"+carno+"' ORDER BY GBRQ DESC,GBSJ DESC";
				rs.writeLog(sql1);
				rs.execute(sql1);
				String lastgbrq="";
				String lastgbsj="";
				String rz="";
				while(rs.next()){

					lastgbrq=Util.null2String(rs.getString("GBRQ"));
					lastgbsj=Util.null2String(rs.getString("GBSJ"));
					rz=Util.null2String(rs.getString("RZ"));
					break;
				}

				String jz=Double.toString(calculateJZ(rz, jzzl));
				if(!lastgbrq.equals("")&&!lastgbsj.equals("")){
					String sql2="UPDATE UF_GBJL SET CZ='"+jzzl+"',JZ='"+jz+"' WHERE GBRQ='"+lastgbrq+"' AND GBSJ='"+lastgbsj+"'";
					sql2+=" AND CP='"+carno+"'";
					rs.writeLog(sql2);
					rs.execute(sql2);
					message+="空柜过磅更新成功";

					Date date = new Date();
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
					String currentDate = sdf.format(date);
					String gbrq = currentDate.substring(0, 10);
					String gbsj = currentDate.substring(11, 16);
					String sql = "INSERT INTO UF_GBJL (CP,GBRQ,GBSJ,CZ,GH," +
							") VALUES (";

					sql += "'" + carno + "',";
					sql += "'" + gbrq + "',";
					sql += "'" + gbsj + "',";
					sql += "'" + jzzl + "',";
					sql += "'" + ggh+ "')";
					rs.writeLog(sql);
					rs.executeSql(sql);
					message += "空柜计重插入成功";
				}else{
					message+="查询时间和日期为空!";
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
			rs.writeLog("totalBillCounts:"+totalBillCounts);
			String sql = "select id from uf_gbjl where zxjhh='" + zxjhh + "'";
			rs.writeLog(sql);
			rs.executeSql(sql);
			int count = rs.getCounts();

			if (count == 0) {
				message = "提入单所属装卸计划尚未计重！";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;
			}
			String sql2 = "select id from uf_gbjl where trdh='" + trdh + "'";
			rs.writeLog("执行sql2：" + sql2);
			rs.executeSql(sql2);
			if (rs.getCounts() > 0) {
				rs.writeLog("提入单已过磅");
				message = "该提入单已经过磅过了！不能重复过磅";
				jsonObject = addJsonJZ(message);
				out.write(jsonObject.toString());
				return;
			}
			String lastCz="";
			String sql3="select cz from uf_gbjl where zxjhh='"+zxjhh+"' ORDER BY gbrq desc,gbsj desc";
			rs.writeLog(sql3);
			rs.execute(sql3);
			while(rs.next()){
				lastCz=Util.null2String(rs.getString("cz"));
				break;
			}
			rs.writeLog("获得的上一次的出重值为："+lastCz);
			String jz=Double.toString(calculateJZ(lastCz, jzzl));

			rs.writeLog("计算出的净重为："+jz);
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
			sql4 += "'" + null2Double(lastCz) + "',";
			sql4 += "'" + null2Double(jzzl) + "',";
			sql4 += "'" + jz + "',";
			sql4 += "'" + trdh + "',";

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
			message += "过磅插入成功";

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

			//最后查询目前的已过磅的提入单数量是否等于总数
			sql0="SELECT ID FROM UF_GBJL WHERE ZXJHH='"+ zxjhh + "'";
			rs.writeLog("最后查询目前的已过磅的提入单数量sql："+sql0);
			rs.execute(sql0);
			nowBillCounts=rs.getCounts()-1;
			rs.writeLog("nowBillCounts:"+nowBillCounts);
			//如果已过磅的提入单数量是否等于总数,则需要更新装卸计划表重
			String rz="";
			String cz="";
			String gbrq0="";
			String gbsj0="";
			if(totalBillCounts==nowBillCounts){
				sql0="SELECT MIN(CZ) RZ,MAX(CZ) CZ FROM UF_GBJL WHERE ZXJHH='"+zxjhh+"'";
				rs.writeLog("查询装卸计划在过磅记录中的最大值与最小值sql："+sql0);
				rs.execute(sql0);
				while(rs.next()){
					rz=rs.getString("RZ");
					cz=rs.getString("CZ");
				}
				rs.writeLog("获得rz："+rz+",cz:"+cz);
				sql0="SELECT GBRQ,GBSJ FROM UF_GBJL WHERE ZXJHH='"+zxjhh+"' ORDER BY GBRQ DESC,GBSJ DESC";
				rs.writeLog("查询装卸计划在过磅记录中的最大日期时间："+sql0);
				rs.execute(sql0);
				while(rs.next()){
					gbrq0=rs.getString("GBRQ");
					gbsj0=rs.getString("GBSJ");
				}
				rs.writeLog("获得gbrq："+gbrq0+",gbsj:"+gbsj0);
				message+="更新装卸计划表成功";

				if(rz.equals("")||cz.equals("")||gbrq0.equals("")||gbsj0.equals("")){
					message+="查询数据有误";
				}else{
					Double gbzl=0.00;
					gbzl=calculateJZ(rz, cz);
					sql0="UPDATE "+formname+" SET SFGB='1',GBRQ='"+gbrq+"',GBSJ='"+gbsj+"',"	;
					sql0+="CRZ='"+rz+"',CCZ='"+cz+"',GBZL='"+gbzl+"',sjysrq='"+gbrq+"' WHERE ZXJHH='"+zxjhh+"'";
					rs.writeLog("更新装卸计划sql："+sql0);
					rs.execute(sql0);
					message+="--更新装卸计划成功";
				}
				request.setAttribute("message", message);
				request.getRequestDispatcher("/weightJsp/Apportionment _Weight.jsp?zxjhh="+zxjhh+"&lx="+lx)
						.forward(request, response);

			};
			jsonObject = addJsonJZ(message);
			out.write(jsonObject.toString());

			return;

		}

		//提入单校验
		if ("checkPlate1".equals(action)) {

			rs.writeLog("进入checkPlate1");
			String plate = request.getParameter("plate");
			String carno = request.getParameter("carno");
			rs.writeLog("获得的参数:plate--" + plate + ",carno--" + carno);
			String sql1 = "select lcid,sfdy,lx,sfzf from uf_trdpldy where trdh='" + plate + "'";
			rs.writeLog(sql1);
			rs.execute(sql1);
			String message = "";//消息
			String newcp = "";//车牌
			String trdStatus = "0";//提入单状态
			String ptStatus = "0";//提入订单打印状态

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
				String formname=getFormNameByLx(lx);

				if (lcid.equals("")) {
					message = "提入单打印表中流程编号为空";
					jsonObject = addJson(message, newcp, trdStatus, ptStatus);
					out.write(jsonObject.toString());
					return;
				}
				trdStatus = "1";
				if (!sfdy.equals("1")) {
					message = "提入单尚未打印";
					jsonObject = addJson(message, newcp, trdStatus, ptStatus);
					out.write(jsonObject.toString());
					return;
				}
				ptStatus = "1";

				String sql2 = "select cp from "+formname+" where requestid='" + lcid + "'";
				rs.writeLog(sql2);
				rs.execute(sql2);
				while (rs.next()) {
					String cp = rs.getString("cp");
					if (cp.equals("")) {
						if (carno.equals("")) {
							message = "装卸计划表中车牌为空";

							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
						if (!carno.equals("")) {
							String sql3 = "update "+formname+" set cp='" + carno + "' where requestid='"
									+ lcid + "'";
							rs.writeLog(sql3);
							rs.execute(sql3);
							message = "提入单已打印，更新车牌成功";
							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
					}
					if (!cp.equals("")) {
						if (carno.equals("")) {
							newcp = cp;
							message = "提入单可以查到装卸计划的车牌";
							jsonObject = addJson(message, newcp, trdStatus, ptStatus);
							bs.writeLog(jsonObject.toString());
							out.write(jsonObject.toString());
							return;
						}
						if (!carno.equals("")) {
							if (carno.equals(cp)) {
								message = "输入的车牌与装卸计划表的一致";
								jsonObject = addJson(message, newcp, trdStatus, ptStatus);
								bs.writeLog(jsonObject.toString());
								out.write(jsonObject.toString());
								return;
							}
							if (!carno.equals(cp)) {
								String sql4 = "update "+formname+" set cp='" + carno
										+ "' where requestid='" + lcid + "'";
								rs.writeLog(sql4);
								rs.execute(sql4);
								message = "输入的车牌与装卸计划表的不一致，已更新";
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

<%!public Double calculateJZ(String rz,String cz){
	Util.getDoubleValue("0.00");
	if(rz.equals("")||rz==null){

		rz="0.00";
	}
	if(cz.equals("")||rz==null){

		cz="0.00";
	}
	//计算净重的绝对值
	BigDecimal b1=new BigDecimal(rz);
	BigDecimal b2=new BigDecimal(cz);
	Double b3=b1.subtract(b2).doubleValue();
	return Math.abs(b3);
}%>

<%!public String null2Double(String str){
	String d1="0.00";
	if(str.equals("")||str==null){
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
<%!public RecordSet getGBZJ(String planNo) {
	RecordSet rs = new RecordSet();
	String sql = "select * from uf_gbjl where 1=1";
	if (planNo != null) {
		sql += "and zxjhh = " + planNo;
	}
	rs.executeSql(sql);
	return rs;
}%>
<%!public String getFormNameByLx(String lx){
    String formname="";
	if("0".equals(lx)){
		formname="formtable_main_45";
	}
	if("1".equals(lx)){
		formname="formtable_main_61";
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
