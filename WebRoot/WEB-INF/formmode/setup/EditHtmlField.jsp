
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="FieldComInfo" class="weaver.workflow.field.FieldComInfo" scope="page" />
<jsp:useBean id="ModeLayoutUtil" class="weaver.formmode.setup.ModeLayoutUtil" scope="page" />
<%
	if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}
%>

<%
int Id = Util.getIntValue(request.getParameter("Id"), 0);
int modeId = Util.getIntValue(request.getParameter("modeId"), 0);
int formId = Util.getIntValue(request.getParameter("formId"), 0);
int type = Util.getIntValue(request.getParameter("type"), 0);
int isdefault = Util.getIntValue(request.getParameter("isdefault"), 0);
String layoutname = Util.null2String(request.getParameter("layoutname"));
int colsperrow = Util.getIntValue(request.getParameter("colsperrow"), 0);
String isdisabled = (type==0 || type==3) ? "disabled":"";

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
subCompanyId = Util.getIntValue(Util.null2String(rightMap.get("subCompanyId")),-1);

HashMap FieldAttrMap = new HashMap();
String sql = "";
sql = "select colsperrow,cssfile from modehtmllayout where modeid = " + modeId + " and type = " + type + " and formid = " + formId;
rs.executeSql(sql);
while(rs.next()){
	colsperrow = Util.getIntValue(rs.getString("colsperrow"),0);
}

String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(28423,user.getLanguage());
String needfav ="";
String needhelp ="";
%>
<HTML>
<HEAD>
<link href="/css/Weaver_wev8.css" type="text/css" rel=STYLESHEET>
<style>
TABLE.liststyle {
	BORDER-RIGHT: 0px; PADDING-RIGHT: 0px; BORDER-TOP: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; BORDER-LEFT: 0px; WIDTH: 100%; PADDING-TOP: 0px; BORDER-BOTTOM: 0px
}
TABLE.liststyle TR {
	
}
TABLE.liststyle TR.Section {
	
}
TABLE.liststyle TR.Section TH {
	TEXT-ALIGN: left
}
TABLE.liststyle TR.Separator {
	HEIGHT: 3px
}
TABLE.liststyle TR.header {
	COLOR: #000000; BACKGROUND-COLOR: #d6d3ce
}
TABLE.liststyle TR.header TD {
	BORDER-RIGHT: #c5c5c5 1pt solid; PADDING-RIGHT: 3pt; BORDER-TOP: #c5c5c5 1pt solid; FONT-WEIGHT: normal; VERTICAL-ALIGN: text-top; BORDER-LEFT: #c5c5c5 1pt solid; PADDING-TOP: 2pt; BORDER-BOTTOM: #c5c5c5 1pt solid; TEXT-ALIGN: left ; 
}
TABLE.liststyle TR.header TH {
	BORDER-RIGHT: #c5c5c5 1pt solid; PADDING-RIGHT: 3pt; BORDER-TOP: #c5c5c5 1pt solid; FONT-WEIGHT: normal; VERTICAL-ALIGN: text-top; BORDER-LEFT: #c5c5c5 1pt solid; PADDING-TOP: 2pt; BORDER-BOTTOM: #c5c5c5 1pt solid; TEXT-ALIGN: left
}
TABLE.liststyle TR.datadark {
	BACKGROUND-COLOR: #e7e7e7
}
TABLE.liststyle TR.datadark td {
	PADDING-RIGHT: 4pt; PADDING-LEFT: 1pt; LINE: 100%
}
TABLE.liststyle TR.datalight {
	BACKGROUND-COLOR: #f5f5f5
}
TABLE.liststyle TR.datalight TD {
	PADDING-RIGHT: 4pt; PADDING-LEFT: 1pt; LINE: 100%
}
TABLE.viewform {
	WIDTH: 100%;
	border:0;margin:0;
	border-collapse:collapse;
}
TABLE.viewform TD.field {
	PADDING-RIGHT: 3px; PADDING-LEFT: 2px; BACKGROUND-COLOR:#F5FAFA;
}
</style>
<script type="text/javascript" language="javascript" src="/js/weaver_wev8.js"></script>
<TITLE></TITLE>
</HEAD>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
if(operatelevel>0){//保存
	RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:submitData(),_self} " ;
	RCMenuHeight += RCMenuHeightStep;
}
//关闭
RCMenu += "{"+SystemEnv.getHtmlLabelName(309,user.getLanguage())+",javascript:window.close(),_self} " ;
RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<%
ModeLayoutUtil.setFormId(formId);
ModeLayoutUtil.setModeId(modeId);
Map fieldsmap = ModeLayoutUtil.getFormfields(user.getLanguage(),type,Id);
List detailGroupList = (List)fieldsmap.get("detailGroup");		//明细
List mainfields = (List)fieldsmap.get("mainfields");				//主表字段
List detlfields = (List)fieldsmap.get("detlfields");				//子表字段
%>
<form id="modefieldhtml" name="modefieldhtml" method="post" action="LayoutOperation.jsp" >
<input type="hidden" id="operation" name="operation" value="batchHtmlField">
<input type="hidden" id="Id" name="Id" value="<%=Id%>">
<input type="hidden" id="modeId" name="modeId" value="<%=modeId%>">
<input type="hidden" id="layoutname" name="layoutname" value="<%=layoutname%>">
<input type="hidden" id="formId" name="formId" value="<%=formId%>">
<input type="hidden" id="type" name="type" value="<%=type%>">
<input type="hidden" id="isdefault" name="isdefault" value="<%=isdefault%>">
<input type="hidden" id="needcreatenew" name="needcreatenew" value="0">
<input type="hidden" id="needprep" name="needprep" value="0">

<table width=100% height=95% border="0" cellspacing="0" cellpadding="0">
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

  <table class=liststyle cellspacing=1 id="tab_dtl_list-1">
	<COLGROUP>
	<COL width="18%">
	<COL width="18%">
	<COL width="18%">
	<COL width="18%">
	<COL width="18%">
	<COL width="10%">
  	<TR height="10">
		<TD colSpan=6></TD>
	</TR>
	<tr>
		<td colspan="6">
		<table class="viewform" cellspacing="1">
			<COLGROUP>
			<COL width="30%">
			<COL width="40%">
			<COL width="30%">
			<tr><!-- 每行显示字段数 -->
				<td class="field"><strong><%=SystemEnv.getHtmlLabelName(21778,user.getLanguage())%><strong></td><!-- 主表 -->
				<td class="field"><%=SystemEnv.getHtmlLabelName(23692,user.getLanguage())%>&nbsp;&nbsp;&nbsp;&nbsp;<!-- 每行显示字段数 -->
					<select id="colsperrow" name="colsperrow" style="width:50px">
						<option value="1" <%if(colsperrow==1){out.print(" selected ");}%>>1</option>
						<option value="2" <%if(colsperrow==2){out.print(" selected ");}%>>2</option>
						<option value="3" <%if(colsperrow==3){out.print(" selected ");}%>>3</option>
						<option value="4" <%if(colsperrow==4){out.print(" selected ");}%>>4</option>
					</select>
				</td>
			</tr>
		</table>
		</td>
	</tr> 
	<TR><TD class="Line1" colSpan=6></TD></TR>
	<tr class=header>
		<td><%=SystemEnv.getHtmlLabelName(685,user.getLanguage())%><!-- 字段名 -->
		</td>
		<td><input type="checkbox" name="title_viewall"  onClick="onChangeViewAll(-1,this.checked)" >
			<%=SystemEnv.getHtmlLabelName(15603,user.getLanguage())%><!-- 是否显示 -->
		</td>
		<td><input type="checkbox" name="title_editall"  onClick="onChangeEditAll(-1,this.checked)" <%if(type==4){%>disabled<%}%>>
			<%=SystemEnv.getHtmlLabelName(15604,user.getLanguage())%><!-- 是否可编辑 -->
		</td>
		<td><input type="checkbox" name="title_manall"  onClick="onChangeManAll(-1,this.checked)" <%if(type==4){%>disabled<%}%>>
			<%=SystemEnv.getHtmlLabelName(15605,user.getLanguage())%><!-- 是否必填 -->
		</td>
		<td><input type="checkbox" name="title_hideall"  onClick="onChangeHideAll(-1,this.checked)" <%if(type==4){%>disabled<%}%>>
			<%=SystemEnv.getHtmlLabelName(83023,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(16636,user.getLanguage())%><!-- 是否隐藏 -->
		</td>
		<td><%=SystemEnv.getHtmlLabelName(23691,user.getLanguage())%><!-- 字段排序 -->
		</td>
	</tr><TR class=Line ><TD colSpan=6></TD></TR>
	<%
	int linecolor=0;
	String view="";
	String edit="";
	String man="";
	String hide_ = "";
	String fieldlabel = "";
	String fieldid = "";
	String fieldhtmltype = "";
	String isview = "";
	String isedit = "";
	String isman = "";
	String ishide = "";
	//double orders = 0;
	for(int i=0; i < mainfields.size(); i++){
		//orders++;
		Map maps = (Map)mainfields.get(i);
		fieldlabel = (String)maps.get("fieldlabel");
		fieldid = (String)maps.get("fieldid");
		fieldhtmltype = (String)maps.get("fieldhtmltype");
		isview = (String)maps.get("isview");
		isedit = (String)maps.get("isedit");
		isman = (String)maps.get("isman");
		ishide = (String)maps.get("ishide");
		if("1".equals(isview)) view = " checked";
		else view = "";
		if("1".equals(isedit)) edit = " checked";
		else edit = "";
		if("1".equals(isman)) man = " checked";
		else man = "";
		if("1".equals(ishide)) hide_ = " checked";
		else hide_ = "";
		String orderid = Util.null2String((String)maps.get("orderid"));
		float order_tmp = Util.getFloatValue(orderid, (float)0.00);
		orderid = order_tmp+"";
		//if(Util.getDoubleValue(orderid,0)==0)
		//	orderid = orders+"";
	%>
	<tr <%if(linecolor==0){%> class=datalight <%} else {%> class=datadark <%}%> >
	  <td><%=fieldlabel %></td>
	  <td><input type="checkbox" name="mode<%=fieldid%>_view_g0" <%=view%> onClick="if(this.checked==false){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g0,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g0,this.checked);}else{changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g0,false);}"></td>
	<%if(!fieldhtmltype.equals("7")){%>		
	  <td><input type="checkbox" name="mode<%=fieldid%>_edit_g0" <%=edit%> <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g0,false);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g0,this.checked);}else{changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g0,this.checked);}" <%if(type==4){%>disabled<%}%>></td>
	  <td><input type="checkbox" name="mode<%=fieldid%>_man_g0"  <%=man%>  <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g0,false);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g0,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g0,this.checked);}" <%if(type==4){%>disabled<%}%>></td>
	   <td><input type="checkbox" name="mode<%=fieldid%>_hide_g0"  <%=hide_%>  <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g0,false);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g0,false);}changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g0,false);" <%if(type==4){%>disabled<%}%>></td>
	<%}else{%>
	  <td><input type="checkbox" name="mode<%=fieldid%>_edit_g0" disabled></td>
	  <td><input type="checkbox" name="mode<%=fieldid%>_man_g0" disabled></td>
	  <td><input type="checkbox" name="mode<%=fieldid%>_hide_g0" disabled></td>
	<%}%>
	  <td><input type="text" class="Inputstyle" name="mode<%=fieldid%>_orderid_g0" maxlength="6" onKeyPress="ItemFloat_KeyPress_ehnf(this)" onChange="checkFloat_ehnf(this)" value="<%=orderid%>" style="width:80%"></td>
	</tr>
	<%	
		if(linecolor==0) linecolor=1;
		else linecolor=0;
	}
	%>
  </table>
  	<%
  	if(detailGroupList!=null && detailGroupList.size()>0){
  		RecordSet detailrs=new RecordSet();
		for(int i=0; i<detailGroupList.size(); i++){
			Map maps = (Map)detailGroupList.get(i);
			String titles = (String)maps.get("titles");
			String detailtable = (String)maps.get("detailtable");
			
			int groupNum = 0;
            detailrs.executeSql("select orderid from Workflow_billdetailtable where tablename='"+detailtable+"' and billid='"+formId+"'");
    		while(detailrs.next()){
    			groupNum = detailrs.getInt("orderid");
			}
			
			String dtladd = (String)maps.get("isadd");
			if(dtladd.equals("1")) dtladd = " checked";
			
			String dtledit = (String)maps.get("isedit");
			if(dtledit.equals("1")) dtledit = " checked";
			
			String dtldelete = (String)maps.get("isdelete");
			
			if(dtldelete.equals("1")) dtldelete = " checked";
			
			String dtlcopy = (String)maps.get("iscopy");
			
			if(dtlcopy.equals("1")) dtlcopy = " checked";
			
			String dtlhide = (String)maps.get("ishidenull");
			if(dtlhide.equals("1")) dtlhide = " checked";
			
			String dtlneed = (String)maps.get("Isneed");
			if(dtlneed.equals("1")) dtlneed = " checked";
			
			String dtldefault = (String)maps.get("isdefault");
			if(dtldefault.equals("1")) dtldefault = " checked";
			
			if(!dtladd.equals(" checked") && !dtledit.equals(" checked"))
				isdisabled = "disabled";
			else
				isdisabled = "";
		%>
		<table class=viewform cellspacing=1 name="tab_dtl_<%=groupNum%>">
			<COLGROUP>
			<COL width="20%">
			<COL width="80%">
			<tr>
				<td class=field colSpan=2><strong><%=titles%><strong></td>
			</tr>
			<TR><TD class="Line1" colSpan=2></TD></TR>
			<tr>
				<td><%=SystemEnv.getHtmlLabelName(19394,user.getLanguage())%></td><!-- 允许新增明细 -->
				<td class=field><input type="checkbox" name="dtl_add_<%=groupNum%>" id="dtl_add_<%=groupNum%>" onClick="checkChange2('<%=String.valueOf(groupNum)%>')" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%><%=dtladd%><% }%>></td>
			</tr>
			<TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
			<tr>
				<td><%=SystemEnv.getHtmlLabelName(19395,user.getLanguage())%></td><!-- 允许修改已有明细 -->
				<td class=field><input type="checkbox" name="dtl_edit_<%=groupNum%>" id="dtl_edit_<%=groupNum%>" onClick="checkChange2('<%=String.valueOf(groupNum)%>')" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%> <%=dtledit%><%}%>></td>
			</tr>
			<TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
			<tr>
				<td><%=SystemEnv.getHtmlLabelName(19396,user.getLanguage())%></td><!-- 允许删除已有明细 -->
				<td class=field><input type="checkbox" name="dtl_del_<%=groupNum%>" id="dtl_del_<%=groupNum%>" onClick="" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%><%=dtldelete%> <%}%>></td>
			</tr>
			<TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
			<tr>
				<td><%=SystemEnv.getHtmlLabelName(82661,user.getLanguage())%></td><!-- 允许复制明细 -->
				<td class=field><input type="checkbox" name="dtl_copy_<%=groupNum%>" id="dtl_copy_<%=groupNum%>" onClick="" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%><%=dtlcopy%> <%}%>></td>
			</tr>
			<TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
			<tr>
                <td><%=SystemEnv.getHtmlLabelName(24801,user.getLanguage())%></td><!-- 必须新增明细 -->
                <td class=field><input type="checkbox" name="dtl_ned_<%=groupNum%>" id="dtl_ned_<%=groupNum%>" onClick="" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%> <%=dtlneed%><%}%> <%=isdisabled %>></td>
            </tr>
            <TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
            <tr>
                <td><%=SystemEnv.getHtmlLabelName(24796,user.getLanguage())%></td><!-- 新增默认空明细 -->
                <td class=field><input type="checkbox" name="dtl_def_<%=groupNum%>" id="dtl_def_<%=groupNum%>" onClick="" <%if(type==0 || type==3 || type==4){%>disabled<%}else{%> <%=dtldefault%><%}%> <%=isdisabled %>></td>
            </tr>
            <TR class="Spacing"><TD class="Line" colSpan=2></TD></TR>
			</table>
			<table class=liststyle cellspacing=1 id="tab_dtl_list<%=groupNum%>" name="tab_dtl_list<%=groupNum%>">
			<COLGROUP>
			<COL width="18%">
			<COL width="18%">
			<COL width="18%">
			<COL width="18%">
			<COL width="18%">
			<COL width="10%">
			<tr class=header>
				<td><%=SystemEnv.getHtmlLabelName(685,user.getLanguage())%></td><!-- 字段名称 -->
				<td>
					<input type="checkbox" name="mode_viewall_g<%=groupNum%>"  onClick="if(this.checked==false){document.modefieldhtml.mode_editall_g<%=groupNum%>.checked=false; document.modefieldhtml.mode_manall_g<%=groupNum%>.checked=false;};onChangeViewAll(<%=groupNum%>,this.checked)">
					<%=SystemEnv.getHtmlLabelName(15603,user.getLanguage())%><!-- 是否显示 -->
				</td>
				<td>
					<input type="checkbox" name="mode_editall_g<%=groupNum%>" <%=isdisabled%>  onClick="if(this.checked==true){document.modefieldhtml.mode_viewall_g<%=groupNum%>.checked=(this.checked==true?true:false);}else{document.modefieldhtml.mode_manall_g<%=groupNum%>.checked=false;};onChangeEditAll(<%=groupNum%>,this.checked)" <%if(type==0 || type==3 || type==4){%>disabled<%}%>>
					<%=SystemEnv.getHtmlLabelName(15604,user.getLanguage())%><!-- 是否可编辑 -->
				</td>
				<td>
					<input type="checkbox" name="mode_manall_g<%=groupNum%>" <%=isdisabled%>  onClick="if(this.checked==true){document.modefieldhtml.mode_viewall_g<%=groupNum%>.checked=(this.checked==true?true:false);document.modefieldhtml.mode_editall_g<%=groupNum%>.checked=(this.checked==true?true:false);};onChangeManAll(<%=groupNum%>,this.checked)" <%if(type==0 || type==3 || type==4){%>disabled<%}%>>
					<%=SystemEnv.getHtmlLabelName(15605,user.getLanguage())%><!-- 是否必须输入 -->
				</td>
				<td>
					<input type="checkbox" name="mode_hideall_g<%=groupNum%>" <%=isdisabled%>  onClick="if(this.checked==true){document.modefieldhtml.mode_viewall_g<%=groupNum%>.checked=(this.checked==true?true:false);}else{document.modefieldhtml.mode_manall_g<%=groupNum%>.checked=false;};onChangeHideAll(<%=groupNum%>,this.checked)" <%if(type==0 || type==3 || type==4){%>disabled<%}%>>
					<%=SystemEnv.getHtmlLabelName(83023,user.getLanguage())%><%=SystemEnv.getHtmlLabelName(16636,user.getLanguage())%><!-- 是否隐藏 -->
				</td>
			<td>
				<%=SystemEnv.getHtmlLabelName(23691,user.getLanguage())%><!-- 字段排序 -->
			</td>
			</tr><TR class=Line ><TD colSpan=6></TD></TR>
			<%
			for(int j=0; j<detlfields.size(); j++){
				Map mapdtl = (Map)detlfields.get(j);
				String detailtable1 = (String)mapdtl.get("detailtable");
				if(detailtable1.equals(detailtable)){
					//orders++;
					fieldlabel = (String)mapdtl.get("fieldlabel");
					fieldid = (String)mapdtl.get("fieldid");
					fieldhtmltype = (String)mapdtl.get("fieldhtmltype");
					isview = (String)mapdtl.get("isview");
					isedit = (String)mapdtl.get("isedit");
					isman = (String)mapdtl.get("isman");
					ishide = (String)mapdtl.get("ishide");
					if("1".equals(isview)) view = " checked";
					else view = "";
					if("1".equals(isedit)) edit = " checked";
					else edit = "";
					if("1".equals(isman)) man = " checked";
					else man = "";
					if("1".equals(ishide)) hide_ = " checked";
					else hide_ = "";
					String orderid = Util.null2String((String)mapdtl.get("orderid"));
					float order_tmp = Util.getFloatValue(orderid, (float)0.00);
					orderid = order_tmp+"";
					//if(Util.getDoubleValue(orderid,0)==0)
					//	orderid = orders+"";
			%>		
					<tr <%if(linecolor==0){%> class=datalight <%} else {%> class=datadark <%}%> >
					  <td><%=fieldlabel %></td>
					  <td><input type="checkbox" name="mode<%=fieldid%>_view_g<%=groupNum%>" <%=view%> onClick="if(this.checked==false){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g<%=groupNum%>,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g<%=groupNum%>,this.checked);}else{changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g<%=groupNum%>,false);}"></td>
					<%if(!"7".equals(fieldhtmltype)){%>		
					  <td><input type="checkbox" name="mode<%=fieldid%>_edit_g<%=groupNum%>" <%=edit%> <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g<%=groupNum%>,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g<%=groupNum%>,false);}else{changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g<%=groupNum%>,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g<%=groupNum%>,false);}" <%if(type==0 || type==3 || type==4){%>disabled<%}%>></td>
					  <td><input type="checkbox" name="mode<%=fieldid%>_man_g<%=groupNum%>"  <%=man%>  <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g<%=groupNum%>,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g<%=groupNum%>,this.checked);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_hide_g<%=groupNum%>,false);}"  <%if(type==0 || type==3 || type==4){%>disabled<%}%>></td>

					  <td><input type="checkbox" name="mode<%=fieldid%>_hide_g<%=groupNum%>"  <%=hide_%>  <%=isdisabled%> onClick="if(this.checked==true){changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_view_g<%=groupNum%>,false);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_edit_g<%=groupNum%>,false);changeCheckboxStatus(document.modefieldhtml.mode<%=fieldid%>_man_g<%=groupNum%>,false);}"  <%if(type==0 || type==3 || type==4){%>disabled<%}%>></td>
					<%}else{%>
					  <td><input type="checkbox" name="mode<%=fieldid%>_edit_g<%=groupNum%>" disabled></td>
					  <td><input type="checkbox" name="mode<%=fieldid%>_man_g<%=groupNum%>" disabled></td>
					   <td><input type="checkbox" name="mode<%=fieldid%>_hide_g<%=groupNum%>" disabled></td>
					<%}%>
					<td><input type="text" class="Inputstyle" name="mode<%=fieldid%>_orderid_g<%=groupNum%>" maxlength="6" onKeyPress="ItemFloat_KeyPress_ehnf(this)" onChange="checkFloat_ehnf(this)" value="<%=orderid%>" style="width:80%"></td>
				   </tr>
					<%	
						if(linecolor==0) linecolor=1;
						else linecolor=0;
				}
			}
			%>
			</table>
			<%
		}
	}
	%>
		</td>
		</tr>
		</TABLE>
	</td>
	<td></td>
</tr>
</table>
</form>
</BODY>
</HTML>

<script language="javascript">
function submitData(){
	window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(23708, user.getLanguage())%>",function(){
		modefieldhtml.needcreatenew.value = "1";
		modefieldhtml.needprep.value = "2";
		enableAllmenu();
		modefieldhtml.submit();
	},function(){
		modefieldhtml.needcreatenew.value = "0";
		modefieldhtml.needprep.value = "2";
		enableAllmenu();
		modefieldhtml.submit();
	});
	
}

function ItemFloat_KeyPress_ehnf(obj){
	if(!((window.event.keyCode>=48 && window.event.keyCode<=57) || window.event.keyCode==46)){
		window.event.keyCode=0;
	}
}

function checkFloat_ehnf(obj){
	var valuenow = obj.value;
	var index = valuenow.indexOf(".");
	var valuechange = valuenow;
	if(index > -1){
		if(index == 0){
			valuechange = "0"+valuenow;
			index = 1;
		}
		valuenow = valuechange.substring(0, index+1);
		valuechange = valuechange.substring(index+1, valuechange.length);
		if(valuechange.length > 2){
			valuechange = valuechange.substring(0, 2);
		}
		index = valuechange.indexOf(".");
		if(index > -1){
			valuechange = valuechange.substring(0, index);
		}
		valuenow = valuenow + valuechange;
		index = valuenow.indexOf(".");
		if(index>-1 && index==valuenow.length-1){
			if(valuenow.length>=6){
				valuenow = valuenow.substring(0, index);
			}else{
				valuenow = valuenow + "0";
			}
		}
		obj.value = valuenow;
	}
}

function checkChange2(id) {
    len = document.modefieldhtml.elements.length;
    var isenable=0;
    if(document.getElementById("dtl_add_"+id).checked || document.getElementById("dtl_edit_"+id).checked){
        isenable=1;
    }
	if(isenable==1) {
		document.getElementById("dtl_copy_"+id).disabled=false;
		document.getElementById("dtl_copy_"+id).nextSibling.className = "jNiceCheckbox";
		document.getElementById("dtl_ned_"+id).disabled=false;
		document.getElementById("dtl_ned_"+id).nextSibling.className = "jNiceCheckbox";
		document.getElementById("dtl_def_"+id).disabled=false;
		document.getElementById("dtl_def_"+id).nextSibling.className = "jNiceCheckbox";
	} else {
		document.getElementById("dtl_copy_"+id).disabled=true;
		document.getElementById("dtl_copy_"+id).nextSibling.className = "jNiceCheckbox_disabled";
		document.getElementById("dtl_ned_"+id).disabled=true;
		document.getElementById("dtl_ned_"+id).nextSibling.className = "jNiceCheckbox_disabled";
		document.getElementById("dtl_def_"+id).disabled=true;
		document.getElementById("dtl_def_"+id).nextSibling.className = "jNiceCheckbox_disabled";
	}
    for( i=0; i<len; i++) {
        var elename=document.modefieldhtml.elements[i].name;
        elename=elename.substr(elename.indexOf('_')+1);
        if (elename=='edit_g'+id || elename=='man_g'+id || elename=='editall_g'+id || elename=='manall_g'+id || elename=='editall'+id || elename=='manall'+id) {
            if(isenable==1){
                document.modefieldhtml.elements[i].disabled=false;
                document.modefieldhtml.elements[i].nextSibling.className = "jNiceCheckbox";
            }else{
				document.modefieldhtml.elements[i].disabled=true;
				document.modefieldhtml.elements[i].nextSibling.className = "jNiceCheckbox_disabled";
            }
        } 
    } 
}

//是否显示全选
function onChangeViewAll(id, opt){
	var tab_id = "tab_dtl_list" + id;
	var tab_name = document.getElementById(tab_id);
	var row = tab_name.rows.length;
	for(var i=1; i<row; i++){
		var tmpTr = tab_name.rows[i];
		if(tmpTr == undefined){
			continue;
		}
		var tmpTd1 = tmpTr.cells[1];
		if(tmpTd1 == undefined){
			continue;
		}
		if(tmpTd1.childNodes[0].childNodes[0].disabled == false){
			changeCheckboxStatus(tmpTd1.childNodes[0].childNodes[0],opt);
		}
		if(opt == false){
			var tmpTd2 = tmpTr.cells[2];
			if(tmpTd2.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd2.childNodes[0].childNodes[0],opt);
			}

			var tmpTd3 = tmpTr.cells[3];
			if(tmpTd3.childNodes[0].childNodes[0].disabled == false){
			    changeCheckboxStatus(tmpTd3.childNodes[0].childNodes[0],opt);
			}
		}if(opt == true){
            var tmpTd4 = tmpTr.cells[4];
			if(tmpTd4.childNodes[0].childNodes[0].disabled == false){
			    changeCheckboxStatus(tmpTd4.childNodes[0].childNodes[0],false);
			}
		}
	}
}


function onChangeEditAll(id, opt){
	var tab_id = "tab_dtl_list" + id;
	var tab_name = document.getElementById(tab_id);
	var row = tab_name.rows.length;
	for(var i=1; i<row; i++){
		var tmpTr = tab_name.rows[i];
		if(tmpTr == undefined){
			continue;
		}
		var tmpTd2 = tmpTr.cells[2];
		if(tmpTd2 == undefined){
			continue;
		}
		if(tmpTd2.childNodes[0].childNodes[0].disabled == false){
			changeCheckboxStatus(tmpTd2.childNodes[0].childNodes[0],opt);
		}
		if(opt == false){
			var tmpTd3 = tmpTr.cells[3];
			if(tmpTd3.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd3.childNodes[0].childNodes[0],opt);
			}
		}else{
			var tmpTd1 = tmpTr.cells[1];
			if(tmpTd1.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd1.childNodes[0].childNodes[0],opt);
			}
			var tmpTd4 = tmpTr.cells[4];
			if(tmpTd4.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd4.childNodes[0].childNodes[0],false);
			}
		}
	}
}


function onChangeManAll(id, opt){
	var tab_id = "tab_dtl_list" + id;
	var tab_name = document.getElementById(tab_id);
	var row = tab_name.rows.length;
	for(var i=1; i<row; i++){
		var tmpTr = tab_name.rows[i];
		if(tmpTr == undefined){
			continue;
		}
		var tmpTd3 = tmpTr.cells[3];
		if(tmpTd3 == undefined){
			continue;
		}
		if(tmpTd3.childNodes[0].childNodes[0].disabled == false){
			changeCheckboxStatus(tmpTd3.childNodes[0].childNodes[0],opt);
		}
		if(opt == true){
			var tmpTd1 = tmpTr.cells[1];
			if(tmpTd1.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd1.childNodes[0].childNodes[0],opt);
			}
			var tmpTd2 = tmpTr.cells[2];
			if(tmpTd2.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd2.childNodes[0].childNodes[0],opt);
			}
			var tmpTd4 = tmpTr.cells[4];
			if(tmpTd4.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd4.childNodes[0].childNodes[0],false);
			}
		}
	}
}
function onChangeHideAll(id, opt){
	var tab_id = "tab_dtl_list" + id;
	var tab_name = document.getElementById(tab_id);
	var row = tab_name.rows.length;
	for(var i=1; i<row; i++){
		var tmpTr = tab_name.rows[i];
		if(tmpTr == undefined){
			continue;
		}
		var tmpTd4 = tmpTr.cells[4];
		if(tmpTd4 == undefined){
			continue;
		}
		if(tmpTd4.childNodes[0].childNodes[0].disabled == false){
			changeCheckboxStatus(tmpTd4.childNodes[0].childNodes[0],opt);
		}
		if(opt == true){
			var tmpTd1 = tmpTr.cells[1];
			if(tmpTd1.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd1.childNodes[0].childNodes[0],false);
			}
			var tmpTd2 = tmpTr.cells[2];
			if(tmpTd2.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd2.childNodes[0].childNodes[0],false);
			}
			var tmpTd3 = tmpTr.cells[3];
			if(tmpTd3.childNodes[0].childNodes[0].disabled == false){
				changeCheckboxStatus(tmpTd3.childNodes[0].childNodes[0],false);
			}
		}
	}
}

function checkBoxOnclick(obj,fieldid){
}
</script>

