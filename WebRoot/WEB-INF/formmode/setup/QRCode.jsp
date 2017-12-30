<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@ page import="com.weaver.formmodel.util.StringHelper"%>
<%@ page import="weaver.formmode.service.ModelInfoService"%>
<%@ page import="weaver.interfaces.workflow.browser.Browser"%>
<%@page import="weaver.formmode.virtualform.VirtualFormHandler"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rst" class="weaver.conn.RecordSetTrans" scope="page" />
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ taglib uri="/browserTag" prefix="brow"%>

<%
	if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}
%>
<html>
<%
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(125513,user.getLanguage());//二维码配置
String needfav ="";
String needhelp ="";

%>
<head>
<link href="/js/checkbox/jquery.tzCheckbox_wev8.css" type=text/css rel=STYLESHEET>
<script language=javascript src="/js/checkbox/jquery.tzCheckbox_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/base/jquery-ui_wev8.js"></script>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<link href="/formmode/css/formmode_wev8.css" type="text/css" rel="stylesheet" />
<style>
.Line {
	background-color: #B5D8EA;
    background-repeat: repeat-x;
    height: 1px;
}
.Serial {
  margin-left:50px;
  margin-right:30px;
}
</style>
</head>
<body>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>

<%
ModelInfoService modelInfoService = new ModelInfoService();
int modeId = Util.getIntValue(request.getParameter("id"),0);
if(modeId<=0){
	modeId = Util.getIntValue(request.getParameter("modeId"),0);
}

int isUse = 0;
String targetType = "";
String targetUrl = "";
int w = 120;
int h = 120;
String baseinfo = "";
rs.executeSql("select * from ModeQRCode where modeid="+modeId);
if (rs.next()) {
	isUse = rs.getInt("isuse");
	targetType = rs.getString("targetType");
	targetUrl = rs.getString("targetUrl");
	w = rs.getInt("width");
	h = rs.getInt("height");
	baseinfo = rs.getString("qrCodeDesc");
}
if ("".equals(targetType)) {
	targetType = "1";
}
if ("".equals(baseinfo)) { //首次给默认模板
	baseinfo = "<table>\r\n" + 
				"<tr>\r\n" + 
				"<td></td>\r\n" + 
				"</tr>\r\n" + 
				"<tr >\r\n" + 
				"<td>#QRCodeImg#</td>\r\n" + 
				"</tr>\r\n" + 
				"</table>";
}
String subCompanyIdsql = "select subCompanyId from modeinfo where id="+modeId;
RecordSet recordSet = new RecordSet();
recordSet.executeSql(subCompanyIdsql);
int subCompanyId = -1;
if(recordSet.next()){
	subCompanyId = recordSet.getInt("subCompanyId");
}
String userRightStr = "ModeSetting:All";
Map rightMap = getCheckRightSubCompanyParam(userRightStr,user,fmdetachable, subCompanyId,"",request,response,session);
int operatelevel = Util.getIntValue(Util.null2String(rightMap.get("operatelevel")),-1);

%>

<%
if(operatelevel>0){
	RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:onSave(this),_self} " ;
	RCMenuHeight += RCMenuHeightStep;
}
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<form id="frmCoder" name="frmCoder" method=post action="qrCodeOperation.jsp" >
<INPUT TYPE="hidden" NAME="method">
<INPUT TYPE="hidden" NAME="postValue">
<INPUT TYPE="hidden" NAME="modeId" value="<%=modeId%>">

<table class="e8_tblForm">
  <colgroup>
  	  	<col width="20%">
  	  	<col width="80%">
  	  </colgroup>
  	  <TBODY>
  <tr>
  	 <TD class="e8_tblForm_label">
        <%=SystemEnv.getHtmlLabelName(18624,user.getLanguage())%>     <!-- 是否启用 -->
    </TD>
    <TD class="e8_tblForm_field">
        <input class="inputStyle" type="checkbox" name="txtUserUse" tzCheckbox="true" value="1" <%if (isUse==1) out.println("checked");%>>
    </TD>    
  </tr>
  <TR>
    <TD class="e8_tblForm_label">
        <%=SystemEnv.getHtmlLabelName(125569,user.getLanguage()) %>     <!-- 目标类型 -->
    </TD>
    <TD class="e8_tblForm_field">
        <input type=radio name=targetType <%if("1".equals(targetType)){ %>checked<%} %> value="1"/> <%=SystemEnv.getHtmlLabelName(89,user.getLanguage()) %><!-- 显示 -->
        <input type=radio name=targetType <%if("2".equals(targetType)){ %>checked<%} %> value="2"/> <%=SystemEnv.getHtmlLabelName(93,user.getLanguage()) %><!-- 编辑 -->
        <input type=radio name=targetType <%if("3".equals(targetType)){ %>checked<%} %> value="3"/> <%=SystemEnv.getHtmlLabelName(811,user.getLanguage()) %><!-- 其它 -->
    </TD>                   
  </TR>  
  <tr id="space1" style="height:1px!important;display:none;" class="Spacing"><td class="paddingLeft18" colspan="2"><div class="intervalDivClass"></div></td></tr>
  <TR id="targetUrlTR" style="<%if(!"3".equals(targetType)){ %>display:none;<%}%>">
    <TD class="e8_tblForm_label">
        <%=SystemEnv.getHtmlLabelName(16208,user.getLanguage()) %>        <!-- 链接地址 -->
    </TD>
    <TD class="e8_tblForm_field" valign="top">
        <textarea id="targetUrl" name="targetUrl" class="inputstyle" rows="3" style="width:80%;" onblur="checkinput2('targetUrl','targetUrlspan',1)"><%=targetUrl %></textarea>
        <SPAN id="targetUrlspan">
			<%if ("".equals(targetUrl)) { %>
               <img align="absMiddle" src="/images/BacoError_wev8.gif"/>
            <% } %>
		</SPAN>
		<!-- 
			提示：可输入动态参数为
			1.输入“$UserId$”表示当前操作者
			2.输入“$DepartmentId$”表示当前操作者部门
			3.输入“$AllDepartmentId$”表示当前操作者部门（包含下级部门）
			4.输入“$SubcompanyId$”表示当前操作者分部
			5.输入“$AllSubcompanyId$”表示当前操作者分部（包含下级分部）
			6.输入“$date$”表示当前日期
			7.输入“$当前字段名称$”表示当前字段
			8.输入“$modeid$”、“$formid$”、“$billid$”表示当前模块id、表单id、单据id
		 -->
			<span title='<%=SystemEnv.getHtmlLabelName(82350,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82351,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82352,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82462,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82463,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82464,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82465,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(125568,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(125598,user.getLanguage())%>&#10;' id="remind">
				<img align="absMiddle" src="/images/remind_wev8.png">
			</span><BR>
		<%--<font color="red"><%=SystemEnv.getHtmlLabelName(125629,user.getLanguage())%><!-- 链接地址长度不能超过216个字节长度 --></font>--%>
    </TD>                   
  </TR>  
  <tr style="height:1px!important;display:;" class="Spacing"><td class="paddingLeft18" colspan="2"><div class="intervalDivClass"></div></td></tr>
  <TR>
    <TD class="e8_tblForm_label">
        <%=SystemEnv.getHtmlLabelName(26901,user.getLanguage()) %>        <!-- 宽 -->
    </TD>
    <TD class="e8_tblForm_field">
        <input type="text" id="w" name="w" value="<%=w %>" style="width:100px" onKeyPress="ItemCount_KeyPress()"  onKeyUp='NotWriteZero(this)'/>
        <font color="red"><%=SystemEnv.getHtmlLabelName(125570,user.getLanguage()) %><!-- (宽必须大于119) --></font>
    </TD>                   
  </TR>  
  <tr style="height:1px!important;display:;" class="Spacing"><td class="paddingLeft18" colspan="2"><div class="intervalDivClass"></div></td></tr>
  <TR>
    <TD class="e8_tblForm_label">
        <%=SystemEnv.getHtmlLabelName(27734,user.getLanguage()) %>     <!-- 高 -->
    </TD>
    <TD class="e8_tblForm_field">
        <input type="text" id="h" name="h" value="<%=h %>" style="width:100px" onKeyPress="ItemCount_KeyPress()"  onKeyUp='NotWriteZero(this)'/>
        <font color="red"><%=SystemEnv.getHtmlLabelName(125571,user.getLanguage()) %><!-- (高必须大于119) --></font>
    </TD>                   
  </TR>  
  <tr style="height:1px!important;display:;" class="Spacing"><td class="paddingLeft18" colspan="2"><div class="intervalDivClass"></div></td></tr>
  <TR>
    <TD class="e8_tblForm_label">
      	<%=SystemEnv.getHtmlLabelName(1361,user.getLanguage()) %><!-- 基本信息 -->
    </TD>
    <TD class="e8_tblForm_field" valign="top">
        <textarea name="baseinfo" class="inputstyle" rows="10" style="width:80%"><%=baseinfo %></textarea>
        <!-- 
			提示：可输入动态参数为
			1.输入“$UserId$”表示当前操作者
			2.输入“$DepartmentId$”表示当前操作者部门
			3.输入“$AllDepartmentId$”表示当前操作者部门（包含下级部门）
			4.输入“$SubcompanyId$”表示当前操作者分部
			5.输入“$AllSubcompanyId$”表示当前操作者分部（包含下级分部）
			6.输入“$date$”表示当前日期
			7.输入“$当前字段名称$”表示当前字段
			8.输入“$modeid$”、“$formid$”、“$billid$”表示当前模块id、表单id、单据id
		 -->
			<span title='<%=SystemEnv.getHtmlLabelName(82350,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82351,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82352,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82462,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82463,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82464,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(82465,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(125568,user.getLanguage())%>&#10;<%=SystemEnv.getHtmlLabelName(125598,user.getLanguage())%>&#10;' id="remind">
				<img align="absMiddle" src="/images/remind_wev8.png">
			</span>
        <br>
        <font color="red"><%=SystemEnv.getHtmlLabelName(125572,user.getLanguage())%><!-- 可根据实际情况设计二维码HTML显示样式 --></font>
    </TD>                   
  </TR>  
  <tr style="height:1px!important;display:;" class="Spacing"><td class="paddingLeft18" colspan="2"><div class="intervalDivClass"></div></td></tr>
  <tr>
  	<TD colspan="2" style="">
		<b><%=SystemEnv.getHtmlLabelName(27581, user.getLanguage())%></b><br> <!-- 使用注意事项: -->
		<!-- 1）目标类型：二维码扫描后打开目标为显示则为当前模块显示布局；编辑为当前模块编辑布局；其它可在链接地址中定义目标地址或显示字符。<br>
		2）链接地址：自定义链接路径或字符。<br>
		3）宽：二维码图片显示宽度。<br>
		4）高：二维码图片显示高度。<br>
		5）基本信息：可以自定义HTML模板描述二维码的一些基本信息。<font color="red">使用#QRCodeImg#定义二维码图片</font>。<br>
		6）<font color="red">特别说明：#QRCodeImg#也可以用在表单建模布局中</font>。 -->
		
		<%=SystemEnv.getHtmlLabelName(125573, user.getLanguage())%>。<br>
		<%=SystemEnv.getHtmlLabelName(125574, user.getLanguage())%><br>
		<%=SystemEnv.getHtmlLabelName(125575, user.getLanguage())%><br>
		<%=SystemEnv.getHtmlLabelName(125576, user.getLanguage())%><br>
		<%=SystemEnv.getHtmlLabelName(125577, user.getLanguage())%><font color="red"><%=SystemEnv.getHtmlLabelName(125578, user.getLanguage())%></font>。<br>
		<font color="red"><%=SystemEnv.getHtmlLabelName(125579, user.getLanguage())%></font>
	</TD>
  </tr>
  </TBODY>
</table>
    
</form>
</body>

<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDialog_wev8.js"></script>
<script language="javascript" src="/wui/theme/ecology8/jquery/js/zDrag_wev8.js"></script>
<script type="text/javascript">

$(document).ready(function(){
$(".loading", window.parent.document).hide(); //隐藏加载图片
$("input[name='targetType']").click(
function() {
   if (this.value==1||this.value==2) {
   		document.getElementById("space1").style.display="none";
   		document.getElementById("targetUrlTR").style.display="none";
   } else {
   		document.getElementById("space1").style.display="";
   		document.getElementById("targetUrlTR").style.display="";
   }
}
)
});

function onSave() {
   var targetUrlval = document.getElementById("targetUrl").value;
   //if (getByteLen(targetUrlval) > 215) {
        //alert("<%=SystemEnv.getHtmlLabelName(125629,user.getLanguage())%>");//链接地址长度不能超过216个字节长度
   		//return;
   //}
   var w = document.getElementById("w").value;
   var h = document.getElementById("h").value;
   if (w < 120 || h < 120) {
   		alert("<%=SystemEnv.getHtmlLabelName(125580,user.getLanguage())%>");//宽或者高不符合规则
   		return;
   } 
   if($("input[name='targetType']:checked").val() != "3" || ($("input[name='targetType']:checked").val() == "3" && checkFieldValue("targetUrl"))) {
      enableAllmenu();
   	  document.frmCoder.submit();
   }
}

// 判断input框中是否输入的是数字,不包括小数点
function ItemCount_KeyPress()
{
	var evt = getEvent();
	var keyCode = evt.which ? evt.which : evt.keyCode;
 if(!(((keyCode>=48) && (keyCode<=57))))
  {
     if (evt.keyCode) {
     	evt.keyCode = 0;evt.returnValue=false;     
     } else {
     	evt.which = 0;evt.preventDefault();
     } 
  }
}

//不能输入0
function NotWriteZero(obj){
	if (parseInt(obj.value) == 0) obj.value = "";
}

function checkFieldValue(ids){
	var idsArr = ids.split(",");
	for(var i=0;i<idsArr.length;i++){
		var obj = document.getElementById(idsArr[i]);
		if(obj&&obj.value==""){
			Dialog.alert("<%=SystemEnv.getHtmlLabelName(15859,user.getLanguage())%>",function(){displayAllmenu();});//必要信息不完整！
			return false;
		}
	}
	return true;
}

function getByteLen(val) { 
    var len = 0; 
    for (var i = 0; i < val.length; i++) { 
        if (val[i].match(/[^x00-xff]/ig) != null) //全角 
            len += 2; 
        else
             len += 1; 
    }; 
    return len; 
}

</script>
</html>
