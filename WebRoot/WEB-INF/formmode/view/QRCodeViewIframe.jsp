<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.formmode.virtualform.VirtualFormHandler" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="FormModeTransMethod" class="weaver.formmode.search.FormModeTransMethod" scope="page"/>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<html>
<%
//获取modeid
String modeid = request.getParameter("modeId");
String formid = request.getParameter("formId");
String customid = request.getParameter("customid");
String billids = request.getParameter("billid");
String qrCodeDesc = "";
String width = "";
String height = "";

rs.executeSql("select * from ModeQRCode where modeid="+modeid);
if (rs.next()) {
	qrCodeDesc = rs.getString("qrCodeDesc"); 
	width = rs.getInt("width") + "px";
	height = rs.getInt("height") + "px";
}
boolean isVirtualForm = VirtualFormHandler.isVirtualForm(formid);
String vdatasource = "";
String vprimarykey = "";
if(isVirtualForm){
	Map<String,Object> vFormInfo = VirtualFormHandler.getVFormInfo(formid);
	vdatasource = Util.null2String(vFormInfo.get("vdatasource"));
	vprimarykey = Util.null2String(vFormInfo.get("vprimarykey"));	//虚拟表单主键列名称
}

qrCodeDesc = Util.toScreenToEdit(qrCodeDesc,user.getLanguage()).trim();
qrCodeDesc = FormModeTransMethod.getDefaultSqlToName(user,qrCodeDesc);
String qrCodeDescT = qrCodeDesc;

String tablename = "";
String sqlStr = "select tablename from workflow_bill where id="+formid;
RecordSet.executeSql(sqlStr);
if (RecordSet.next()) {
	tablename = Util.null2String(RecordSet.getString("tablename"));
}
if(isVirtualForm){
	tablename = VirtualFormHandler.getRealFromName(tablename);
}

 %>
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
    for (int i = 0 ; i < billids.split(",").length ; i++) {
        String billid = billids.split(",")[i];
        if ("".equals(billid)) continue;
		String requestid = "0";
		String datesql ="select * from "+tablename +" where id='"+billid+"'";
		
		if(isVirtualForm){
			RecordSet.executeSql(datesql,vdatasource);
		}else{
			RecordSet.executeSql(datesql);
		}
		if(RecordSet.next()){ 
			requestid = RecordSet.getString("requestId");
			qrCodeDesc = Util.replaceString2(qrCodeDesc, "\\$requestId\\$", requestid);
			RecordSet RecordSetfield = new RecordSet();
			String fieldsql = "select * from workflow_billfield where billid="+formid+" and (detailtable ='' or detailtable is null)";
			RecordSetfield.executeSql(fieldsql);
			while(RecordSetfield.next()){
				int fieldid = RecordSetfield.getInt("id");
				String fieldhtype = RecordSetfield.getString("fieldhtmltype");
				String type = RecordSetfield.getString("type");
				String fielddbtype = RecordSetfield.getString("fielddbtype");
				String fieldname = RecordSetfield.getString("fieldname");
				int viewtype = RecordSetfield.getInt("viewtype");
				if(("2".equals(fieldhtype)&&"2".equals(type))||"".equals(Util.match(qrCodeDesc, "\\$"+fieldname+"\\$", false))){
					continue;
				}
				String fieldvalue = RecordSet.getString(fieldname);
				String paraTwo = (isVirtualForm?vprimarykey:"id") + "+" + fieldid + "+" + fieldhtype + "+" + type + "+" + user.getLanguage() + "+" + "1" + "+" + fielddbtype + "+" + "+" +  modeid + "+" + 
										formid + "+" + viewtype + "+" + "3" + "+" + customid + "+fromsearchlist";
				String showname = FormModeTransMethod.getOthersNoTitle(fieldvalue, paraTwo);
				qrCodeDesc = Util.replaceString2(qrCodeDesc, "\\$"+fieldname+"\\$", showname);
				qrCodeDesc = Util.replaceString2(qrCodeDesc, "\\$billid\\$", billid);
				qrCodeDesc = Util.replaceString2(qrCodeDesc, "\\$modeid\\$", modeid);
				qrCodeDesc = Util.replaceString2(qrCodeDesc, "\\$formid\\$", formid);
			}
		}
		qrCodeDesc = qrCodeDesc.replaceAll("#QRCodeImg#","<img alt='' width="+width+" height="+height+" src='/weaver/weaver.formmode.servelt.QRcodeBuildAction?modeid="+modeid+"&formid="+formid+"&billid="+billid+"&customid="+customid+"'>");
        
 %>
	<tr>
		<td valign="middle" align="center">
			<%=qrCodeDesc %>
		</td>
	</tr>
<% 
	qrCodeDesc = qrCodeDescT;
} 
%>
</table>
</div>
</body>
<script type="text/javascript">
function doPrint() {
	hideRightClickMenu();
	window.print();
}
</script>
</html>