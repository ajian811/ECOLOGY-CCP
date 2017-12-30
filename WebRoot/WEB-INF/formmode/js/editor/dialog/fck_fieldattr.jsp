<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >

<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ include file="/systeminfo/init_wev8.jsp" %>
<html>
<head>
<title>Text Area Properties</title>
<meta content="noindex, nofollow" name="robots">
<script src="common/fck_dialog_common_wev8.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript" src="/js/weaver_wev8.js"></script>
<script language=javascript src="/js/jquery/jquery_wev8.js"></script>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script type="text/javascript">

var oEditor = window.parent.InnerDialogLoaded() ;
var iscanuse = true;
// Gets the document DOM
var oDOM = oEditor.FCK.EditorDocument ;

var oActiveEl = oEditor.FCKSelection.GetSelectedElement() ;
var LayoutEditFrameObj = null;
var fieldid = 0;
var fieldGroupid = "";
var isDisabled = false;
var isDetail = 0;
var isZhengshuField = false;
window.onload = function(){
	oEditor.FCKLanguageManager.TranslatePage(document) ;
	//下面这个就是我们要的LayoutEdit.jsp那个document
	LayoutEditFrameObj = window.parent.dialogArguments.FrameWindow.document;
	var inputname = oActiveEl.name;//当前选中的那个input的name
	fieldid = inputname.substring(5, inputname.length);
	try{
		//fieldGroupid = LayoutEditFrameObj.getElementById("fieldattr"+fieldid).nodetype;
		fieldGroupid = $("#fieldattr"+fieldid, LayoutEditFrameObj).attr("nodetype");
	}catch(e){
		fieldGroupid = "-1";
	}
	if(fieldGroupid != "-1"){
		$("#sumoperation").attr("disabled", true);
		isDetail = 1;
	}
	window.parent.SetOkButton( true ) ;

	//var selectOuterHtml = LayoutEditFrameObj.getElementById("labellist"+fieldGroupid).outerHTML;
	var selectOuterHtml = $("#labellist"+fieldGroupid, LayoutEditFrameObj).attr("outerHTML");
	while(selectOuterHtml.indexOf("size=15") > -1){
		selectOuterHtml = selectOuterHtml.replace("size=15", "size=7");
	}
	$("#spanfieldlist").html(selectOuterHtml);
	$("#labellist"+fieldGroupid).show();
	$("#labellist"+fieldGroupid).width("95%");
	try{
		//var fileFieldids = LayoutEditFrameObj.getElementById("fileFieldids").value;
		var fileFieldids = $("#fileFieldids", LayoutEditFrameObj).attr("value");
		//var inputFieldids = LayoutEditFrameObj.getElementById("inputFieldids").value;
		var inputFieldids = $("#inputFieldids", LayoutEditFrameObj).attr("value");
		//var dateFields = LayoutEditFrameObj.getElementById("dateFields").value;
		var dateFields =  $("#dateFields", LayoutEditFrameObj).attr("value");
		//var zhengshuFields = LayoutEditFrameObj.getElementById("zhengshuFields").value;
		var zhengshuFields = $("#zhengshuFields", LayoutEditFrameObj).attr("value");
		var mapFields = $("#mapFields", LayoutEditFrameObj).attr("value");
		if((","+fileFieldids+",").indexOf(","+fieldid+",") > -1){
			doDisplayAll();
			showEscPara(0);
			isDisabled = true;
		}else if((","+inputFieldids+",").indexOf(","+fieldid+",") == -1){
			$("#sumoperation").attr("disabled", true);
		}
	}catch(e){}
	try{
		var dateFields = LayoutEditFrameObj.getElementById("dateFields").value;
		var shuziFieldids = LayoutEditFrameObj.getElementById("shuziFieldids").value;
		if((","+dateFields+",").indexOf(","+fieldid+"_"+isDetail+",")==-1 && (","+shuziFieldids+",").indexOf(","+fieldid+"_"+isDetail+",")==-1){
			$("#dateoperation").attr("disabled", true);
		}
	}catch(e){}
	try{
		var shuziFieldids = LayoutEditFrameObj.getElementById("shuziFieldids").value;
		if((","+shuziFieldids+",").indexOf(","+fieldid+"_"+isDetail+",") != -1){
			if(isDetail != 1){
				$("#fieldtransdiv").show();
			}
			var transtype_t = LayoutEditFrameObj.getElementById("transtype"+fieldid).value;
			jQuery("#transtype"+transtype_t).attr("checked", true);
			isZhengshuField = true;
		}
	}catch(e){}
	try{
		var fieldsql = LayoutEditFrameObj.getElementById("fieldsql"+fieldid).value;
		GetE("fieldattr").value = fieldsql;
		var caltype = LayoutEditFrameObj.getElementById("caltype"+fieldid).value;
		GetE("caltype").value = caltype;
		var othertype = LayoutEditFrameObj.getElementById("othertype"+fieldid).value;
		if(caltype == 1){
			showEscPara(1);
			onchangeSFields(1);
		}else if(caltype == 2){
			onchangeSFields(2);
			showEscPara(2);
		}else if(caltype == 3){
			onchangeSFields(3);
			showEscPara(3);
		}else if(caltype==5){
			onchangeSFields(5);
			showEscPara(5);
		}
		try{
			if(othertype ==1){
				document.getElementById("worddateonly").checked = true;
			}else{
				document.getElementById("worddateonly").checked = false;
			}
		}catch(e){}
	}catch(e){}
	checkSql2($("#fieldattr").get(0));
}
function doDisplayAll(){
	$("#sqloperation").attr("disabled", true);
	$("#sumoperation").attr("disabled", true);
	$("#dateoperation").attr("disabled", true);
	$("#fieldattr").attr("disabled", true);

	$("#currentuser").attr("disabled", true);
	$("#currentdept").attr("disabled", true);
	$("#wfcreater").attr("disabled", true);
	$("#createrdept").attr("disabled", true);
	$("#currentdate").attr("disabled", true);
}
function Ok(){
	var sqlcontent = $("#fieldattr").val();
	var sqlCheck = false;
	sqlCheck = checkSql(sqlcontent);
	var caltype = document.getElementById("caltype").value;
	var othertype = "";
	var worddateonly = false;
	try{
		worddateonly = document.getElementById("worddateonly").checked;
	}catch(e){}
	if(worddateonly == true){
		othertype = "1";
	}else{
		othertype = "0";
	}
	var transtype = "";
	transtype = jQuery("[name='transtype'][checked=true]").val();
	if(transtype == ""){
		transtype = "0";
	}
	if(sqlCheck == true){
		if(iscanuse == true){
			LayoutEditFrameObj.getElementById("fieldsql"+fieldid).value = sqlcontent;
			LayoutEditFrameObj.getElementById("caltype"+fieldid).value = caltype;
			LayoutEditFrameObj.getElementById("othertype"+fieldid).value = othertype;
			LayoutEditFrameObj.getElementById("transtype"+fieldid).value = transtype;
			return true;
		}else{
			if(confirm("<%=SystemEnv.getHtmlLabelName(26896,user.getLanguage())%>")){
				LayoutEditFrameObj.getElementById("fieldsql"+fieldid).value = sqlcontent;
				LayoutEditFrameObj.getElementById("caltype"+fieldid).vlaue = caltype;
				LayoutEditFrameObj.getElementById("othertype"+fieldid).value = othertype;
				LayoutEditFrameObj.getElementById("transtype"+fieldid).value = transtype;
				return true;
			}else{
				return false;
			}
		}
	}
}
function checkSql(sqlcontent){
	var sqlLowerCase = sqlcontent.toLowerCase();
	var pos1 = sqlLowerCase.indexOf("update");
	var pos2 = sqlLowerCase.indexOf("set");
	if(pos1>-1 && pos2>-1 && pos2>pos1){//有update语句
		alert("<%=SystemEnv.getHtmlLabelName(23813,user.getLanguage())+"update"+SystemEnv.getHtmlLabelName(23814,user.getLanguage())%>");
		return false;
	}
	pos1 = sqlLowerCase.indexOf("insert");
	if(pos1 > -1){//有insert语句
		alert("<%=SystemEnv.getHtmlLabelName(23813,user.getLanguage())+"insert"+SystemEnv.getHtmlLabelName(23814,user.getLanguage())%>");
		return false;
	}
	pos1 = sqlLowerCase.indexOf("delete");
	if(pos1 > -1){//有delete语句
		alert("<%=SystemEnv.getHtmlLabelName(23813,user.getLanguage())+"delete"+SystemEnv.getHtmlLabelName(23814,user.getLanguage())%>");
		return false;
	}
	pos1 = sqlLowerCase.indexOf("drop");
	if(pos1 > -1){//有drop语句
		alert("<%=SystemEnv.getHtmlLabelName(23813,user.getLanguage())+"drop"+SystemEnv.getHtmlLabelName(23814,user.getLanguage())%>");
		return false;
	}
	pos1 = sqlLowerCase.indexOf("alter");
	if(pos1 > -1){//有alter语句
		alert("<%=SystemEnv.getHtmlLabelName(23813,user.getLanguage())+"alter"+SystemEnv.getHtmlLabelName(23814,user.getLanguage())%>");
		return false;
	}
	return true;
}
function checkSql2(obj){
	var sqlcontent = obj.value;
    sqlcontent = sqlcontent.replace(/\+/g, "%2B");
    sqlcontent = sqlcontent.replace(/\&/g, "%26");
	if(sqlcontent=="" || sqlcontent.indexOf("doFieldSQL")==-1){
		iscanuse = true;
		$("#noticeDiv").html("");
	}else{
		$.ajax({
			url : "/systeminfo/SqlCheckAjax.jsp",
			type : "post",
			processData : false,
			data : "sql="+sqlcontent,
			dataType : "xml",
			success : function do4Success(msg){
				try{
					var iscanuseStr = msg.getElementsByTagName("iscanuse")[0].childNodes[0].nodeValue;
					if(iscanuseStr == "true"){
						iscanuse = true;
					}else{
						iscanuse = false;
					}
				}catch(e){
					iscanuse = false;
				}
				if(iscanuse==false){
					$("#noticeDiv").html("<%=SystemEnv.getHtmlLabelName(23818,user.getLanguage())%>");
				}else{
					$("#noticeDiv").html("");
				}
			},
			error : function do4Error(request, textStatus, errorThrown){
				$("#noticeDiv").html("<%=SystemEnv.getHtmlLabelName(23818,user.getLanguage())%>");
			}
		});
	}
}
</script>
</head>
<body style='OVERFLOW: hidden' scroll='no'>
	<table height="100%" width="100%">
		<tr>
			<td align="center" valign="top">
			<table class="ViewForm" border="0" cellpadding="0" cellspacing="0" width="90%" height="90%">
			<colgroup>
			<col width="40%">
			<col width="30%">
			<col width="30%">
			</colgroup>
				<tr class="Title" valign="top">
					<TH align="left">
						<%=SystemEnv.getHtmlLabelName(21740,user.getLanguage())%>
					</TH>
					<TH align="left">
						<%=SystemEnv.getHtmlLabelName(23860,user.getLanguage())%>
					</TH>
					<TH align="left">
						<%=SystemEnv.getHtmlLabelName(23861,user.getLanguage())%>
					</TH>
				</tr>
				<tr height="5"><td colspan="3"></td></tr>
				<tr valign="top">
					<td align="left" valign="top">
						<div id="spanfieldlist"></div>
					</td>
					<td align="left" valign="top">
						<input type="hidden" id="caltype" name="caltype" value="0">
						<table cellpadding="0" cellspacing="2" border="0" width="100%">
							<tr valign="top">
								<td width="100%">
									<button id="sqloperation" name="sqloperation" title="<%=SystemEnv.getHtmlLabelName(23748,user.getLanguage())%>" class="btn" onclick="sqlOperation()" ><%=SystemEnv.getHtmlLabelName(23748,user.getLanguage())%></button>
									<span id="sqloperationspan"></span>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="sumoperation" name="sumoperation" title="<%=SystemEnv.getHtmlLabelName(261,user.getLanguage())+SystemEnv.getHtmlLabelName(21845,user.getLanguage())%>" class="btn" onclick="sumOperation()" ><%=SystemEnv.getHtmlLabelName(261,user.getLanguage())+SystemEnv.getHtmlLabelName(21845,user.getLanguage())%></button>
									<span id="sumoperationspan"></span>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="dateoperation" name="dateoperation" title="<%=SystemEnv.getHtmlLabelName(27812,user.getLanguage())%>" class="btn" onclick="dateOperation()" ><%=SystemEnv.getHtmlLabelName(27812,user.getLanguage())%></button>
									<span id="dateoperationspan"></span>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="mapoperation" name="mapoperation" title="<%=SystemEnv.getHtmlLabelName(126784,user.getLanguage()) %>" class="btn" onclick="mapOperation()" ><%=SystemEnv.getHtmlLabelName(126784,user.getLanguage()) %></button>
									<span id="mapoperationspan"></span>
								</td>
							</tr>
						</table>
					</td>
					<td align="left" valign="top">
						<table cellpadding="0" cellspacing="2" border="0" width="100%">
							<tr valign="top">
								<td width="100%">
									<button id="currentuser" name="currentuser" style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(524,user.getLanguage())+SystemEnv.getHtmlLabelName(17482,user.getLanguage())%>" class="btn" onclick="insertMark(' $currentuser$ ')" ><%=SystemEnv.getHtmlLabelName(524,user.getLanguage())+SystemEnv.getHtmlLabelName(17482,user.getLanguage())%></button>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="currentdept" name="currentdept"  style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(17482,user.getLanguage())+SystemEnv.getHtmlLabelName(15393,user.getLanguage())%>" class="btn" onclick="insertMark(' $currentdept$ ')" ><%=SystemEnv.getHtmlLabelName(17482,user.getLanguage())+SystemEnv.getHtmlLabelName(15393,user.getLanguage())%></button>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="wfcreater" name="wfcreater"  style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(28597,user.getLanguage())%>" class="btn" onclick="insertMark(' $wfcreater$ ')" ><%=SystemEnv.getHtmlLabelName(28597,user.getLanguage())%></button>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="createrdept" name="createrdept"  style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(882,user.getLanguage())+SystemEnv.getHtmlLabelName(15393,user.getLanguage())%>" class="btn" onclick="insertMark(' $wfcredept$ ')" ><%=SystemEnv.getHtmlLabelName(882,user.getLanguage())+SystemEnv.getHtmlLabelName(15393,user.getLanguage())%></button>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="currentdate" name="currentdate"  style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(15625,user.getLanguage())%>" class="btn" onclick="insertMark(' $wfcurrdate$ ')" ><%=SystemEnv.getHtmlLabelName(15625,user.getLanguage())%></button>
								</td>
							</tr>
							<tr valign="top">
								<td width="100%">
									<button id="id" name="id"  style="width:120px;" title="<%=SystemEnv.getHtmlLabelName(81287,user.getLanguage())%>" class="btn" onclick="insertMark(' $id$ ')" ><%=SystemEnv.getHtmlLabelName(81287,user.getLanguage())%></button>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="3" align="left" height="0"><div id="noticeDiv" style="height:0px;color:#ff0000;padding-left:25px;"></div>
					</td>
				</tr>
				<tr>
					<td align="left" colspan="3">
						<div id="fieldtransdiv" style="display:none">
						<span><input type="radio" id="transtype1" name="transtype" value="1" /><%=SystemEnv.getHtmlLabelName(18004,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(89,user.getLanguage())%></span>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<span><input type="radio" id="transtype2" name="transtype" value="2" /><%=SystemEnv.getHtmlLabelName(22395,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(89,user.getLanguage())%></span>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<span><input type="radio" id="transtype0" name="transtype" value="0" /><%=SystemEnv.getHtmlLabelName(201,user.getLanguage())%></span>
						&nbsp;&nbsp;&nbsp;&nbsp;
						</div>
						<div id="worddateonlydiv" style="display:none">
						<input type="checkbox" id="worddateonly" name="worddateonly" value="1" /><%=SystemEnv.getHtmlLabelName(27813,user.getLanguage())%>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="#" onclick="insertMark(' $datetime$ ')" ><%=SystemEnv.getHtmlLabelName(27814,user.getLanguage())%></a>
						<br>&nbsp;
							<font color="#ff0000">
						<%if(user.getLanguage() == 7){%>
							暂时只支持日期[合并时间]字段间的减法，以及日期[合并时间]字段与整数的加减法。
						<%}else if(user.getLanguage() == 8){%>
							Supports only for the date [unite time] field subtraction, and the date [unite time] field with integer addition and subtraction.
						<%}else if(user.getLanguage() == 9){%>
							暫時隻支持日期[合并時間]字段間的減法，以及日期[合并時間]字段與整數的加減法。
						<%}%>
							</font>
						</div>
						<textarea id="fieldattr" name="fieldattr" rows="7" style="width:95%" onchange="checkSql2(this)"></textarea>
					</td>
				</tr>
			</table>
			</td>
		</tr>
	</table>
</body>
<script type="text/javascript" language="javascript">
function onchangeformlabel(obj){
	$(".labellist").hide();
	$("#labellist"+obj.value).show();
}
function cool_webcontrollabel(obj){
	var textvalue = "$"+obj.value+"$";
	if(isDisabled == false){
		insertIntoTextarea(textvalue);
	}
}
function sqlOperation(){
	var fieldattr = document.getElementById("fieldattr").value;
	var textvalue = "doFieldSQL(\"  \")";
	if(fieldattr.indexOf("doField")>-1 && fieldattr.indexOf("doFieldSQL")==-1){//有设置过，但曾经的设置不是FieldSQL
		if(confirm("<%=SystemEnv.getHtmlLabelName(23820,user.getLanguage())%>")){
			document.getElementById("fieldattr").value = textvalue;
			showEscPara(1);
			$("#worddateonlydiv").hide();
		}		
	}else if(fieldattr.indexOf("doFieldSQL") == -1){
		insertIntoTextarea(textvalue);
		showEscPara(1);
		$("#worddateonlydiv").hide();
	}
	onchangeSFields(1);
	checkSql2($("#fieldattr").get(0));
}
function sumOperation(){
	var fieldattr = document.getElementById("fieldattr").value;
	var textvalue = "doFieldMath(\"  \")";
	if(fieldattr.indexOf("doField")>-1 && fieldattr.indexOf("doFieldMath")==-1){//有设置过，但曾经的设置不是FieldMath
		if(confirm("<%=SystemEnv.getHtmlLabelName(23820,user.getLanguage())%>")){
			document.getElementById("fieldattr").value = textvalue;
			showEscPara(2);
			onchangeSFields(2);
		}
	}else if(fieldattr.indexOf("doFieldMath") == -1){
		insertIntoTextarea(textvalue);
		showEscPara(2);
		onchangeSFields(2);
	}
	//checkSql2($("#fieldattr").get(0));
}
function dateOperation(){
	var fieldattr = document.getElementById("fieldattr").value;
	var textvalue = "doFieldDate(\"  \")";
	if(fieldattr.indexOf("doField")>-1 && fieldattr.indexOf("doFieldDate")==-1){//有设置过，但曾经的设置不是FieldMath
		if(confirm("<%=SystemEnv.getHtmlLabelName(23820,user.getLanguage())%>")){
			document.getElementById("fieldattr").value = textvalue;
			showEscPara(3);
			onchangeSFields(3);
		}
	}else if(fieldattr.indexOf("doFieldDate") == -1){
		insertIntoTextarea(textvalue);
		showEscPara(3);
		onchangeSFields(3);
	}else{
		$("#worddateonlydiv").show();
	}
}

function mapOperation(){
	var fieldattr = document.getElementById("fieldattr").value;
	var inputname = oActiveEl.name;//当前选中的那个input的name
	var fieldid = inputname.substring(5, inputname.length);
	var textvalue = "doFieldMap(\" $"+fieldid+"$ \")";
	if(fieldattr.indexOf("doField")>-1 && fieldattr.indexOf("doFieldMap")==-1){//有设置过，但曾经的设置不是FieldMath
		if(confirm("<%=SystemEnv.getHtmlLabelName(23820,user.getLanguage())%>")){
			document.getElementById("fieldattr").value = textvalue;
			showEscPara(5);
			onchangeSFields(5);
		}
	}else if(fieldattr.indexOf("doFieldMap") == -1){
		insertIntoTextarea(textvalue);
		showEscPara(5);
		$("#worddateonlydiv").hide();
	}
	onchangeSFields(5);
	//checkSql2($("#fieldattr").get(0));
}
function insertIntoTextarea(textvalue){
	var obj = document.getElementById("fieldattr");
	obj.focus();
	if(document.selection){
		document.selection.createRange().text = textvalue;
	}else{
		obj.value = obj.value.substr(0, obj.selectionStart) + textvalue + obj.value.substr(obj.selectionEnd);
	}
	checkSql2($("#fieldattr").get(0));
}

function insertMark(textvalue){
	insertIntoTextarea(textvalue);
}
//type:1,sql;0,sum;2,date
function showEscPara(type){
	document.getElementById("sqloperationspan").innerHTML = "";
	document.getElementById("sumoperationspan").innerHTML = "";
	document.getElementById("dateoperationspan").innerHTML = "";
	document.getElementById("mapoperationspan").innerHTML = "";
	if(type == 1){//sql
		$("#currentuser").attr("disabled", false);
		$("#currentdept").attr("disabled", false);
		$("#wfcreater").attr("disabled", false);
		$("#createrdept").attr("disabled", false);
		$("#currentdate").attr("disabled", false);
		$("#id").attr("disabled", false);
		document.getElementById("sqloperationspan").innerHTML = "<img src=\"/images/BacoCheck_wev8.gif\" width=\"16\" height=\"16\" border=\"0\">";
	}else if(type == 2){//sum
		$("#currentuser").attr("disabled", true);
		$("#currentdept").attr("disabled", true);
		$("#wfcreater").attr("disabled", true);
		$("#createrdept").attr("disabled", true);
		$("#currentdate").attr("disabled", true);
		$("#id").attr("disabled", true);
		document.getElementById("sumoperationspan").innerHTML = "<img src=\"/images/BacoCheck_wev8.gif\" width=\"16\" height=\"16\" border=\"0\">";
	}else if(type == 3){//date
		$("#currentuser").attr("disabled", true);
		$("#currentdept").attr("disabled", true);
		$("#wfcreater").attr("disabled", true);
		$("#createrdept").attr("disabled", true);
		$("#currentdate").attr("disabled", false);
		$("#id").attr("disabled", true);
		document.getElementById("dateoperationspan").innerHTML = "<img src=\"/images/BacoCheck_wev8.gif\" width=\"16\" height=\"16\" border=\"0\">";
	}else if(type==5){//map
		$("#currentuser").attr("disabled", true);
		$("#currentdept").attr("disabled", true);
		$("#wfcreater").attr("disabled", true);
		$("#createrdept").attr("disabled", true);
		$("#currentdate").attr("disabled", true);
		$("#id").attr("disabled", true);
		document.getElementById("mapoperationspan").innerHTML = "<img src=\"/images/BacoCheck_wev8.gif\" width=\"16\" height=\"16\" border=\"0\">";
	}
	GetE("caltype").value = type;
}
function onchangeSFields(type){
	$("#worddateonlydiv").hide();
	$("#fieldtransdiv").hide();
	var selectOuterHtml = LayoutEditFrameObj.getElementById("labellist"+fieldGroupid).outerHTML;
	while(selectOuterHtml.indexOf("size=15") > -1){
		selectOuterHtml = selectOuterHtml.replace("size=15", "size=7");
	}
	$("#spanfieldlist").html(selectOuterHtml);
	if(type == 1){
		$("#labellist"+fieldGroupid).show();
		$("#worddateonlydiv").hide();
	}else if(type == 2){
		var inputFieldids = LayoutEditFrameObj.getElementById("inputFieldids").value;
		$("#labellist"+fieldGroupid+" option").each(function(){
			if((","+inputFieldids+",").indexOf(","+$(this).val()+",") == -1){
				$(this).remove();
			}
		});
		$("#labellist"+fieldGroupid).show();
		$("#worddateonlydiv").hide();
	}else if(type == 3){
		var zhengshuFields = LayoutEditFrameObj.getElementById("zhengshuFields").value;
		var dateFields = LayoutEditFrameObj.getElementById("dateFields").value;
		var canDateSumFields = zhengshuFields + "," + dateFields;
		$("#labellist"+fieldGroupid+" option").each(function(){
			if((","+canDateSumFields+",").indexOf(","+$(this).val()+"_"+isDetail+",") == -1){
				$(this).remove();
			}
		});
		$("#labellist"+fieldGroupid).show();
		$("#worddateonlydiv").show();
	}else if(type==5){
		var mapFields = LayoutEditFrameObj.getElementById("mapFields").value;
		$("#labellist"+fieldGroupid+" option").each(function(){
			if((","+mapFields+",").indexOf(","+$(this).val()+"_"+isDetail+",") == -1){
				$(this).remove();
			}
		});
		$("#labellist"+fieldGroupid).show();
	}

}
</script>
</html>