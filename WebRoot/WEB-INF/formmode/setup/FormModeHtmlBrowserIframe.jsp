<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<jsp:useBean id="modeLayoutUtil" class="weaver.formmode.setup.ModeLayoutUtil" scope="page" />
<HTML><HEAD>
<LINK REL=stylesheet type=text/css HREF=/css/Weaver_wev8.css>
<link href="/formmode/css/formmode_wev8.css" type="text/css" rel="stylesheet" />
</HEAD>
<%
int modeId=Util.getIntValue(request.getParameter("modeId"),0);
int formId=Util.getIntValue(request.getParameter("formId"),0);
int type=Util.getIntValue(request.getParameter("type"),-1);
int flag=Util.getIntValue(request.getParameter("flag"),-1);
int languages = user.getLanguage();
if(type!=-1){
	modeLayoutUtil.searchRightModeLayout(modeId,formId,type);
}else{
	if(flag > 0){
	    modeLayoutUtil.setBrowser(true);
	}
	modeLayoutUtil.searchModeLayout(modeId,formId,0);
}

List modeList = modeLayoutUtil.getModeLayoutList();

String sql = "select subCompanyId from modeinfo where id="+modeId;
RecordSet recordSet = new RecordSet();
recordSet.executeSql(sql);
int subCompanyId = -1;
if(recordSet.next()){
	subCompanyId = recordSet.getInt("subCompanyId");
}
String userRightStr = "ModeSetting:All";
Map rightMap = getCheckRightSubCompanyParam(userRightStr,user,fmdetachable, subCompanyId,"",request,response,session);
int operatelevel = Util.getIntValue(Util.null2String(rightMap.get("operatelevel")),-1);
subCompanyId = Util.getIntValue(Util.null2String(rightMap.get("subCompanyId")),-1);
String subCompanyId2 = ""+subCompanyId;

%>

<BODY>

<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(201,languages)+",javascript:window.parent.close(),_self} " ;//取消
RCMenuHeight += RCMenuHeightStep;
if(operatelevel>1){
	RCMenu += "{"+SystemEnv.getHtmlLabelName(311,languages)+",javascript:submitClear(),_self} " ;//清除
	RCMenuHeight += RCMenuHeightStep;
}
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>


<FORM id="SearchForm" name="SearchForm" action="WorkflowModeBrowser.jsp" method="post">
<input type="hidden" id="modeId" name="modeId" value="<%=modeId%>">
<input type="hidden" id="formId" name="formId" value="<%=formId%>">
<table id="topTitle" cellpadding="0" cellspacing="0" style="display:none;">
		<tr>
			<td></td>
			<td class="rightSearchSpan" style="text-align:right; width:500px!important">
				<span title="<%=SystemEnv.getHtmlLabelName(81804, user.getLanguage()) %>" class="cornerMenu"></span>
			</td>
		</tr>
</table>
<table width=100% height=100% border="0" cellspacing="0" cellpadding="0">
<colgroup>
<col width="10">
<col width="">
<col width="10">
<tr>
	<td height="10" colspan="3"></td>
</tr>
<tr>
	<td ></td>
	<td valign="top">
		<TABLE class=Shadow>
		<tr>
		<td valign="top">

<TABLE ID=BrowseTable class="BroswerStyle"  cellspacing="1"  width="100%">
<TR class=DataHeader>
<TH width=40%><%=SystemEnv.getHtmlLabelName(18151,languages)%></TH>
<TH width=30%><%=SystemEnv.getHtmlLabelName(20622,languages)%></TH>
<TH width=30%><%=SystemEnv.getHtmlLabelName(19049,languages)%></TH>
</tr>

<TR class=Line style="height:1px;"><th colspan="5" ></Th></TR>
<%
boolean isLight = false;
Map modeMap ;
for(int i=0;i<modeList.size(); i++){
	modeMap = (Map)modeList.get(i);
	isLight = !isLight ;
	String classNames =  isLight ? "DataLight" : "DataDark";
	int modeType = Util.getIntValue((String)modeMap.get("type"),-1);
%>
<TR class='<%=classNames%>' onmouseover="this.className='Selected'" onmouseout="this.className='<%=classNames%>'">
	<TD style="display:none"><%=modeMap.get("Id")%></TD>
    <TD><%=modeMap.get("layoutName")%></TD>
	<TD><%=modeLayoutUtil.getTypeDesc(modeType,languages)%></TD>
	<TD><%=modeMap.get("modeName")%></TD>
</TR>
<%}%>
</TABLE>

</td>
		</tr>
		</TABLE>
	</td>
	<td></td>
</tr>
<tr>
	<td height="10" colspan="3"></td>
</tr>
</table>

</FORM>
</BODY>
</HTML>

<script type="text/javascript">
var parentWin = parent.parent.parent.getParentWindow(parent.parent);
var dialog = parent.parent.parent.getDialog(parent.parent);


jQuery(document).ready(function(){
	jQuery("#BrowseTable").bind("click",BrowseTable_onclick);
	//jQuery("#BrowseTable").bind("mouseover",BrowseTable_onmouseover);
	//jQuery("#BrowseTable").bind("mouseout",BrowseTable_onmouseout);
})

function BrowseTable_onclick(e){
   var e=e||event;
   var target=e.srcElement||e.target;
   if( target.nodeName =="TD"){
     	//window.parent.returnValue = {modeId:jQuery(jQuery(target).parents("tr")[0].cells[0]).text(),modeName:jQuery(jQuery(target).parents("tr")[0].cells[1]).text()};
	 	//window.parent.close();
	 	var returnjson = {id:jQuery(jQuery(target).parents("tr")[0].cells[0]).text(),name:jQuery(jQuery(target).parents("tr")[0].cells[1]).text()};
		if(dialog){
	    	dialog.callback(returnjson);
		}else{  
	    	window.parent.parent.returnValue  = returnjson;
	    	window.parent.parent.close();
		}
	}
}
function submitClear(){
	var returnjson = {id:"",name:""};
	if(dialog){
	    dialog.callback(returnjson);
	}else{  
	    window.parent.parent.returnValue  = returnjson;
	    window.parent.parent.close();
	}
}

function BrowseTable_onmouseover(e){
 	e=e||event;
    var target=e.srcElement||e.target;
    if("TD"==target.nodeName){
 		jQuery(target).parents("tr")[0].className = "Selected";
    }else if("A"==target.nodeName){
 		jQuery(target).parents("tr")[0].className = "Selected";
    }
}
function BrowseTable_onmouseout(e){
	var e=e||event;
   var target=e.srcElement||e.target;
   var p;
	if(target.nodeName == "TD" || target.nodeName == "A" ){
      p=jQuery(target).parents("tr")[0];
      if( p.rowIndex % 2 ==0){
         p.className = "DataDark"
      }else{
         p.className = "DataLight"
      }
   }
}
</script>

