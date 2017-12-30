<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.formmode.virtualform.VirtualFormHandler" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />\
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="recordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="FormModeTransMethod" class="weaver.formmode.search.FormModeTransMethod" scope="page"/>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>


 <%
 String modeid = Util.null2String(request.getParameter("modeId"));
 String formid = Util.null2String(request.getParameter("formId"));
 String customid = Util.null2String(request.getParameter("customId"));
 String billids = Util.null2String(request.getParameter("billId"));

 String info = "";
 rs.executeSql("select * from mode_barcode where modeid="+modeid);
 if (rs.next()) {
 	info = rs.getString("info"); 
 }
 boolean isVirtualForm = VirtualFormHandler.isVirtualForm(formid);
 String vdatasource = "";
 String vprimarykey = "";
 if(isVirtualForm){
 	Map<String,Object> vFormInfo = VirtualFormHandler.getVFormInfo(formid);
 	vdatasource = Util.null2String(vFormInfo.get("vdatasource"));
 	vprimarykey = Util.null2String(vFormInfo.get("vprimarykey"));	//虚拟表单主键列名称
 }
 String tablename = "";
 String sqlStr = "select tablename from workflow_bill where id="+formid;
 RecordSet.executeSql(sqlStr);
 if (RecordSet.next()) {
 	tablename = Util.null2String(RecordSet.getString("tablename"));
 }
 
%>
<html>
  <head>
  </head>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(257,user.getLanguage())+",javascript:doPrint(),_self} " ;//打印
RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
  <body>
	  <div>
		  <table style="width:100%;height:100%"> 
		  
		   <%
		   if(!billids.equals("")){
			   String[] billid =  billids.split(",");
			   
			   info = Util.replaceString2(info, "\\$formid\\$", formid);
			   info = Util.replaceString2(info, "\\$UserId\\$", user.getLastname()+"");
			   info = Util.replaceString2(info, "\\$DepartmentId\\$", user.getUserDepartment()+"");
			   info = Util.replaceString2(info, "\\$SubcompanyId\\$", user.getUserSubCompany1()+"");
			   String allDeptId = user.getUserDepartment()+"";
			   String sql = "select id from HrmDepartment where supdepid="+user.getUserDepartment();
			   recordSet.executeSql(sql);
			   while(recordSet.next()){
					String childDeptid =  Util.null2String(recordSet.getString(1));
					allDeptId += ","+childDeptid;
				}
				info = Util.replaceString2(info, "\\$AllDepartmentId\\$", allDeptId);
				
				String allSubCompanyId = user.getUserSubCompany1()+"";
				sql = "select id from HrmsubCompany where supsubcomid ="+ user.getUserSubCompany1();
				System.out.println(sql);
				recordSet.executeSql(sql);
				while(recordSet.next()){
					String SubCompanyid =  Util.null2String(recordSet.getString(1));
					allSubCompanyId += ","+SubCompanyid;
				}
				info = Util.replaceString2(info, "\\$AllSubcompanyId\\$", allSubCompanyId);
				
			   for(int i=0;i<billid.length;i++){
				   String tempinfo = info;
				   String requestid = "0";
				   String datesql ="select * from "+tablename +" where id='"+billid[i]+"'";
				   RecordSet.executeSql(datesql);
				   while(RecordSet.next()){
					    requestid = RecordSet.getString("requestId");
					    info = Util.replaceString2(info, "\\$requestId\\$", requestid);
						RecordSet RecordSetfield = new RecordSet();
						String fieldsql = "select * from workflow_billfield where billid="+formid;
						RecordSetfield.executeSql(fieldsql);
						while(RecordSetfield.next()){
							int fieldid = RecordSetfield.getInt("id");
							String fieldhtype = RecordSetfield.getString("fieldhtmltype");
							String type = RecordSetfield.getString("type");
							String fielddbtype = RecordSetfield.getString("fielddbtype");
							String fieldname = RecordSetfield.getString("fieldname");
							int viewtype = RecordSetfield.getInt("viewtype");							
							if(("2".equals(fieldhtype)&&"2".equals(type))||"".equals(Util.match(info, "\\$"+fieldname+"\\$", false))){
								continue;
							}
							String fieldvalue = RecordSet.getString(fieldname);
							String paraTwo = (isVirtualForm?vprimarykey:"id") + "+" + fieldid + "+" + fieldhtype + "+" + type + "+" + user.getLanguage() + "+" + "1" + "+" + fielddbtype + "+" + "+" +  modeid + "+" + 
													formid + "+" + viewtype + "+" + "3" + "+" + customid + "+fromsearchlist";
							String showname = FormModeTransMethod.getOthersNoTitle(fieldvalue, paraTwo);
					        tempinfo = Util.replaceString2(tempinfo, "\\$"+fieldname+"\\$", showname);
					        tempinfo = Util.replaceString2(tempinfo, "\\$billid\\$", billid[i]);
					        tempinfo = Util.replaceString2(tempinfo, "\\$modeid\\$", modeid);
						}
					}
				   String imageUrl = "<img alt=''  src='/weaver/weaver.formmode.servelt.BARcodeBuildAction?modeid="+modeid+"&formid="+formid+"&billid="+billid[i]+"&customid="+customid+"'>";
				   tempinfo = tempinfo.replaceAll("#BARCodeImg#",imageUrl);	
				   %>
		      <tr>
		      	 <td valign="middle" align="center">
		      	     <%=tempinfo %>
		      	 </td>
		      	 
		      	 
		      </tr>
		   <%
		   		}
		   }
		   %>
	      </table>
  </body>
</html>
<script type="text/javascript">
function doPrint() {
	hideRightClickMenu();
	window.print();
}
</script>