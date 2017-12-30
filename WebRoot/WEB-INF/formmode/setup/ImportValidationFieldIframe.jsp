
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.*" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<HTML>
<HEAD>
<LINK REL=stylesheet type=text/css HREF=/css/Weaver_wev8.css />
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<%
String id =  Util.null2String(request.getParameter("id"));
String modeid = Util.null2String(request.getParameter("modeid"));
String formid = Util.null2String(request.getParameter("formid"));
String rownum = Util.null2String(request.getParameter("rownum"));
String selfieldid = Util.null2String(request.getParameter("fieldids"));
String searchfieldname = Util.null2String(request.getParameter("searchfieldname"));
String selectid = Util.null2String(request.getParameter("selectid"));
HashMap hm = new HashMap();
String fieldsql = "";
if(selectid.equals("")){
	fieldsql = "select b.*,c.indexdesc from  htmllabelindex c,workflow_billfield b left join ModeFormFieldExtend a on b.id=a.fieldId where  (needExcel !=0 or needExcel is null) and c.id=b.fieldlabel and b.billid="+formid; 	
}else{
	fieldsql = "select d.detailtable from workflow_billfield d where id="+selectid;
	rs.executeSql(fieldsql);
	String name = "";
	if(rs.next()){
		name = rs.getString("detailtable");
	}
	if(name.equals("")){
		fieldsql = "select b.*,c.indexdesc from htmllabelindex c,workflow_billfield b left join ModeFormFieldExtend a  on b.id=a.fieldId where (b.detailtable='' or b.detailtable is null )  and (needExcel !=0 or needExcel is null) and c.id=b.fieldlabel and b.billid="+formid;
	}else{
		fieldsql = "select b.*,c.indexdesc from htmllabelindex c,workflow_billfield b left join ModeFormFieldExtend a  on b.id=a.fieldId where b.detailtable='"+name+"' and (needExcel !=0 or needExcel is null) and c.id=b.fieldlabel and b.billid="+formid;
	}
    
}
rs.executeSql(fieldsql);
while(rs.next()){
	String indexdesc = Util.null2String(rs.getString("indexdesc"));
	String tempid = Util.null2String(rs.getString("id"));
	String detailtable = Util.null2String(rs.getString("detailtable"));
	if(!detailtable.equals("")){
		indexdesc += "(明细"+detailtable.substring(detailtable.length()-1,detailtable.length())+")";
	}
	hm.put(tempid,indexdesc);
}



String resourceids ="";
String resourcenames = "";

if (!selfieldid.equals("")) {
	String[] tempArray = Util.TokenizerString2(selfieldid, ",");
	for (int i = 0; i < tempArray.length; i++) {
		String tempname = Util.null2String((String)hm.get(tempArray[i]));
		if(!"".equals(tempname)) {
			resourceids += ","+tempArray[i];
			resourcenames += ","+tempname;
		}
	}
}
%>

</HEAD>

<BODY>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(197,user.getLanguage())+",javascript:doSearch(),_top} " ;//搜索
RCMenuHeight += RCMenuHeightStep ;
RCMenu += "{"+SystemEnv.getHtmlLabelName(826,user.getLanguage())+",javascript:btnok_onclick(),_top} " ;//确定
RCMenuHeight += RCMenuHeightStep ;
RCMenu += "{"+SystemEnv.getHtmlLabelName(311,user.getLanguage())+",javascript:btnclear_onclick(),_top} " ;//清除
RCMenuHeight += RCMenuHeightStep ;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>

<FORM id="SearchForm" NAME=SearchForm STYLE="margin-bottom:0" action="MultiFormmodeShareFieldBrowserIframe.jsp" method=post>
<input type="hidden" name="modeid" value='<%=modeid%>'>
<input type="hidden" name="rownum" id="rownum" value='<%=rownum%>'>
<input type="hidden" name="selfieldid" value='<%=selfieldid%>'>
<table id="topTitle" cellpadding="0" cellspacing="0" style="display:none;">
		<tr>
			<td></td>
			<td class="rightSearchSpan" style="text-align:right; width:500px!important">
				<input type="button" value="确认" id="zd_btn_submit" class="e8_btn_top" onclick="btnok_onclick();">
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
		<td valign="top" colspan="2">
<table width=100% class=ViewForm>
  <TR>
	<TD width=15%><%=SystemEnv.getHtmlLabelName(15456,user.getLanguage())%></TD><!-- 字段显示名 -->
	<TD width=35% class=field><input class=InputStyle id=searchfieldname name=searchfieldname value="<%=searchfieldname%>" ></TD>
  </TR><tr style="height: 1px"><td class=Line colspan=2></td></tr>
</table> 
<tr width="100%">
<td width="60%" valign="top">
	<table class=BroswerStyle style="width: 100%;">
	  <tr class=DataHeader>
	    <TH ><%=SystemEnv.getHtmlLabelName(15456,user.getLanguage())%></TH><!-- 字段显示名 -->
	  </tr>
	  <TR class=Line><TH></TH></TR>
	  <TR>
		<td width="100%">
		  <div style="overflow-y:scroll;width:100%;height:400px">
			<table width="100%" id="BrowseTable" >
			<COLGROUP>
			<%
			rs.executeSql(fieldsql);
			int j=0;
			while(rs.next()) {
				String indexdesc = Util.null2String(rs.getString("indexdesc"));
				String tempid = Util.null2String(rs.getString("id"));
				String detailtable = Util.null2String(rs.getString("detailtable"));
				if(!detailtable.equals("")){
					indexdesc += "(明细"+detailtable.substring(detailtable.length()-1,detailtable.length())+")";
				}
				if(indexdesc.toUpperCase().indexOf(searchfieldname.toUpperCase())<0){
					continue;
				}
                if(j==0){
					j=1;
			%> <TR class=DataLight>
			<%  }else{
					j=0;
			%> <TR class=DataDark>
			<%  }%>
				 <TD style="display:none"><A HREF=#><%=tempid%></A></TD>
				 <TD style="word-break:break-all"><%=indexdesc%></TD>
			   </TR>
			<%}%>
		  	</table>
		  </div>
		</td>
	  </TR>
	</table>
</td>
<td width="40%" valign="top">
	<table  cellspacing="1" align="left" width="100%">
		<tr>
			<td align="center" valign="top" width="20%">
				<img src="/images/arrow_u_wev8.gif" style="cursor:pointer" title="<%=SystemEnv.getHtmlLabelName(15084,user.getLanguage())%>" onclick="javascript:upFromList();"><!-- 上移 -->
				<br><br>
					<img src="/images/arrow_left_all_wev8.gif" style="cursor:pointer" title="<%=SystemEnv.getHtmlLabelName(17025,user.getLanguage())%>" onClick="javascript:addAllToList()"><!-- 全部增加 -->
				<br><br>
				<img src="/images/arrow_right_wev8.gif"  style="cursor:pointer" title="<%=SystemEnv.getHtmlLabelName(91,user.getLanguage())%>" onclick="javascript:deleteFromList();"><!-- 删除 -->
				<br><br>
				<img src="/images/arrow_right_all_wev8.gif"  style="cursor:pointer" title="<%=SystemEnv.getHtmlLabelName(16335,user.getLanguage())%>" onclick="javascript:deleteAllFromList();"><!-- 全部删除 -->
				<br><br>
				<img src="/images/arrow_d_wev8.gif"   style="cursor:pointer" title="<%=SystemEnv.getHtmlLabelName(15085,user.getLanguage())%>" onclick="javascript:downFromList();"><!-- 下移 -->
			</td>
			<td align="center" valign="top" width="80%">
				<select size="30" name="srcList" multiple="true" style="width:100%;word-wrap:break-word;height: 100%;border: 0px;border-left: 1px solid #e6e6e6;" >

				</select>
			</td>
		</tr>

	</table>
	 	</td>
	 	</tr>
	   </TABLE>
	 </td>
  </tr>
</table>
<input type="text" name="selectedids" value="" style="display: none;">
</FORM>
<script type="text/javascript">
var resourceids ="<%=resourceids%>"
var resourcenames = "<%=resourcenames%>"
var dialog = null;
try{
	parentWin = parent.parent.parent.getParentWindow(parent.parent);
	dialog = parent.parent.parent.getDialog(parent.parent);
}catch(e){}

function closeWin(returnjson){
         var rownum = $("#rownum").val();
        if(dialog){
            try{
          		dialog.callback(returnjson);
          		
		    }catch(e){}
		    try{
				dialog.callbackfunParam = {rownum:rownum};
				dialog.close(returnjson);
		    }catch(e){}
		}else{
		    window.parent.parent.parent.returnValue=returnjson;
	  	    window.parent.parent.parent.close();
		}
}	
	
function btnclear_onclick(){
    var returnjson = {id:"",name:""};
    closeWin(returnjson);
}


function btnok_onclick(){
	 setResourceStr();
	 if(resourceids != ''){
	 	resourceids = resourceids.substring(1);
	 	resourcenames = resourcenames.substring(1);
	 }
	 var returnjson =  {id:resourceids,name:resourcenames};
	 closeWin(returnjson);
}
jQuery(document).ready(function(){
	jQuery("#BrowseTable").bind("click",BrowseTable_onclick);
	jQuery("#BrowseTable").bind("mouseover",BrowseTable_onmouseover);
	jQuery("#BrowseTable").bind("mouseout",BrowseTable_onmouseout);
})
function BrowseTable_onclick(e){
	var target =  e.srcElement||e.target ;
	try{
		if(target.nodeName == "TD" || target.nodeName == "A"){
			var newEntry = $($(target).parents("tr")[0].cells[0]).text()+"~"+jQuery.trim($($(target).parents("tr")[0].cells[1]).text()) ;
			if(!isExistEntry(newEntry,resourceArray)){
				addObjectToSelect($("select[name=srcList]")[0],newEntry);
				reloadResourceArray();
			}
		}
	}catch (en) {
		alert(en.message);
	}
}
function BrowseTable_onmouseover(e){
	var e=e||event;
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
         p.className = "DataDark";
      }else{
         p.className = "DataLight";
      }
   }
}

//Load
var resourceArray = new Array();
for(var i =1;i<resourceids.split(",").length;i++){
	resourceArray[i-1] = resourceids.split(",")[i]+"~"+resourcenames.split(",")[i];
}

loadToList();
function loadToList(){
	var selectObj = $("select[name=srcList]")[0];
	for(var i=0;i<resourceArray.length;i++){
		addObjectToSelect(selectObj,resourceArray[i]);
	}
	
}/**
加入一个object 到Select List
*/
function addObjectToSelect(obj,str){
	
	if(obj.tagName != "SELECT") return;
	var oOption = document.createElement("OPTION");
	obj.options.add(oOption);
	oOption.value = str.split("~")[0];
	$(oOption).text(str.split("~")[1]);
	
}

function isExistEntry(entry,arrayObj){
	
	for(var i=0;i<arrayObj.length;i++){
		
		if(entry == arrayObj[i].toString()){
			return true;
		}
	}
	return false;
}

function upFromList(){
	var destList  = $("select[name=srcList]")[0];
	var len = destList.options.length;
	for(var i = 0; i <= (len-1); i++) {
		if ((destList.options[i] != null) && (destList.options[i].selected == true)) {
			if(i>0 && destList.options[i-1] != null){
				fromtext = destList.options[i-1].text;
				fromvalue = destList.options[i-1].value;
				totext = destList.options[i].text;
				tovalue = destList.options[i].value;
				destList.options[i-1] = new Option(totext,tovalue);
				destList.options[i-1].selected = true;
				destList.options[i] = new Option(fromtext,fromvalue);		
			}
     }
  }
  reloadResourceArray();
}
function addAllToList(){
	var table =$("#BrowseTable");
	$("#BrowseTable").find("tr").each(function(){
		var str=$($(this)[0].cells[0]).text()+"~"+$.trim($($(this)[0].cells[1]).text());
		if(!isExistEntry(str,resourceArray))
			addObjectToSelect($("select[name=srcList]")[0],str);
	});
	reloadResourceArray();
}

function deleteFromList(){
	var destList  = $("select[name=srcList]")[0];
	var len = destList.options.length;
	for(var i = (len-1); i >= 0; i--) {
	if ((destList.options[i] != null) && (destList.options[i].selected == true)) {
	destList.options[i] = null;
		  }
	}
	reloadResourceArray();
}
function deleteAllFromList(){
	var destList  = $("select[name=srcList]")[0];
	var len = destList.options.length;
	for(var i = (len-1); i >= 0; i--) {
	if (destList.options[i] != null) {
	destList.options[i] = null;
		  }
	}
	reloadResourceArray();
}
function downFromList(){
	var destList  = $("select[name=srcList]")[0];
	var len = destList.options.length;
	for(var i = (len-1); i >= 0; i--) {
		if ((destList.options[i] != null) && (destList.options[i].selected == true)) {
			if(i<(len-1) && destList.options[i+1] != null){
				fromtext = destList.options[i+1].text;
				fromvalue = destList.options[i+1].value;
				totext = destList.options[i].text;
				tovalue = destList.options[i].value;
				destList.options[i+1] = new Option(totext,tovalue);
				destList.options[i+1].selected = true;
				destList.options[i] = new Option(fromtext,fromvalue);		
			}
     }
  }
  reloadResourceArray();
}
//reload resource Array from the List
function reloadResourceArray(){
	resourceArray = new Array();
	var destList =$("select[name=srcList]")[0];
	for(var i=0;i<destList.options.length;i++){
		resourceArray[i] = destList.options[i].value+"~"+jQuery.trim(destList.options[i].text) ;
	}
	//alert(resourceArray.length);
}

function setResourceStr(){
	
	resourceids ="";
	resourcenames = "";
	for(var i=0;i<resourceArray.length;i++){
		resourceids += ","+resourceArray[i].split("~")[0] ;
		resourcenames += ","+resourceArray[i].split("~")[1] ;
	}
	//alert(resourceids+"--"+resourcenames);
	$("input[name=selectedids]").val( resourceids.substring(1));
}

function doSearch()
{
	setResourceStr();
   $("selectedids").val(resourceids.substring(1)) ;
   document.SearchForm.submit();
}
</script>
</BODY>
</HTML>