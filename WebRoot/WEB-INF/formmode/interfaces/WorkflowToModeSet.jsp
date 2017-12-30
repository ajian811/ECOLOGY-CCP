
<%@page import="weaver.general.StaticObj"%>
<%@page import="weaver.interfaces.workflow.action.Action"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.conn.*" %>
<%@ include file="/formmode/pub.jsp"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<jsp:useBean id="WorkflowComInfo" class="weaver.workflow.workflow.WorkflowComInfo" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs1" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="xssUtil" class="weaver.filter.XssUtil"/>
<HTML>
<HEAD>
<link type='text/css' rel='stylesheet'  href='/wui/theme/ecology8/skins/default/wui_wev8.css'/>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<script type="text/javascript" src="/wui/theme/ecology8/page/perfect-scrollbar/perfect-scrollbar_wev8.js"></script>
<script type="text/javascript" src="/js/ecology8/browserCommon_wev8.js"></script>
<script type='text/javascript' src='/js/jquery-autocomplete/browser_wev8.js'></script>
<link rel="stylesheet" type="text/css" href="/js/jquery-autocomplete/jquery.autocomplete_wev8.css" />
<link rel="stylesheet" type="text/css" href="/js/jquery-autocomplete/browser_wev8.css" />
<link href="/js/ecology8/selectbox/css/jquery.selectbox_wev8.css" type=text/css rel=stylesheet>
<script language=javascript src="/js/ecology8/selectbox/js/jquery.selectbox-0.2_wev8.js"></script>
<style>
*, textarea, select{font: 12px Microsoft YaHei;}
.e8_tblForm{
	width: 100%;
	margin: 0 0;
	border-collapse: collapse;
}
.e8_tblForm .e8_tblForm_label{
	vertical-align: top;
	border-bottom: 1px solid #e6e6e6;
	padding: 5px 0;
}
.e8_tblForm .e8_tblForm_field{
	border-bottom: 1px solid #e6e6e6;
	padding: 5px 7px;
	background-color: #f8f8f8;
}
.e8_label_desc{
	color: #aaa;
}
.e8_label_desc1{
	color: red;
}
.e8_tbl_detail{
	width: 100%;
	border-collpase: collapse;
	border-spacing: 0px;
	background-color: #e6e6e6;
	border: 0px solid #e6e6e6;
	border-bottom: 0;
}
.e8_tbl_detail tr th{
	background-color: #e6e6e6;
	border-bottom: 1px solid #e6e6e6;
	text-align: left;
	padding: 1px 4px;
	font-weight: bold;
}
.e8_tbl_detail tr td{
	background-color: #f8f8f8;
	border-bottom: 1px solid #e6e6e6;
	padding: 1px 4px;
	color: #333;
}
div#divPage{
	display: inline;
}
</style> 
</head>
<%
if(!HrmUserVarify.checkUserRight("ModeSetting:All", user)){
	response.sendRedirect("/notice/noright.jsp");
	return;
}
boolean existWorkflowToMode = false;
try{
Action workflowToModeAction = (Action)StaticObj.getServiceByFullname("action.WorkflowToMode", Action.class);
if(workflowToModeAction!=null)
	existWorkflowToMode = true;
}catch(org.apache.hivemind.ApplicationRuntimeException e){
}
String imagefilename = "/images/hdMaintenance_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(30055,user.getLanguage()) + ":" + SystemEnv.getHtmlLabelName(82,user.getLanguage());//流程转数据:新建
String needfav ="1";
String needhelp ="";

int id = Util.getIntValue(Util.null2String(request.getParameter("id")),0);
int isadd = Util.getIntValue(Util.null2String(request.getParameter("isadd")),0);
int modeid = Util.getIntValue(Util.null2String(request.getParameter("modeid")),0);
int formid = Util.getIntValue(Util.null2String(request.getParameter("formid")),0);
int workflowid = Util.getIntValue(Util.null2String(request.getParameter("workflowid")),0);



int initmodeid = Util.getIntValue(Util.null2String(request.getParameter("initmodeid")),0);
int initworkflowid = Util.getIntValue(Util.null2String(request.getParameter("initworkflowid")),0);
if(isadd==1){
	modeid = initmodeid;
	//workflowid = initworkflowid;
}


String modename = "";
String sql = "";
int modeformid = 0;
int wfformid = 0;
int modecreater = 0;
int modecreaterfieldid = 0;
int triggerNodeId = 0;
int triggerType = 0;
int isenable = 0;
int actionid = -1;
String formtype = "";
boolean isdetailform = false;
String maintableopttype="1";
String maintableupdatecondition = "";
sql = "select * from mode_workflowtomodeset where id = " + id;
rs.executeSql(sql);
while(rs.next()){
	modeid = rs.getInt("modeid");
	workflowid = rs.getInt("workflowid");
	formid = rs.getInt("formid");
	id = rs.getInt("id");
	modecreater = rs.getInt("modecreater");
	modecreaterfieldid = rs.getInt("modecreaterfieldid");
	rs1.executeSql("select formid from workflow_base where id="+workflowid);
	if(rs1.next()){
		wfformid = Util.getIntValue(rs1.getString("formid"));
	}
	//wfformid = Util.getIntValue(WorkflowComInfo.getFormId(String.valueOf(workflowid)));
	triggerNodeId = rs.getInt("triggerNodeId");
	triggerType = rs.getInt("triggerType");
	isenable = rs.getInt("isenable");
	formtype = Util.null2String(rs.getString("formtype"));
	if(formtype.indexOf("detail")>-1){
		isdetailform = true;
	}
	actionid = rs.getInt("actionid");
	if(actionid<0){
		actionid = -1;
	}
	maintableopttype = Util.null2String(rs.getString("maintableopttype"));
	if("".equals(maintableopttype)){
		maintableopttype = "1";
	}
	maintableupdatecondition = Util.null2String(rs.getString("maintableupdatecondition"));
	maintableupdatecondition = Util.toScreenToEdit(maintableupdatecondition,user.getLanguage());
}

//=============字段对应设置信息=====================

HashMap existsMap = new HashMap();
sql = "select * from mode_workflowtomodesetdetail where mainid = " + id;
rs.executeSql(sql);
while(rs.next()){
	String modefieldid = rs.getString("modefieldid");
	String wffieldid = rs.getString("wffieldid");
	String key = modefieldid+"_"+wffieldid;
	existsMap.put(key,key);
	existsMap.put(modefieldid,wffieldid);
}

//=============子表操作设置信息=====================

Map<String,Object> detailtableoptMap = new HashMap<String,Object>();
sql ="select * from mode_workflowtomodesetopt where mainid = " + id;
rs.executeSql(sql);
while(rs.next()){
	String detailtablename = Util.null2String(rs.getString("detailtablename"));
	String opttype = Util.null2String(rs.getString("opttype"));
	String updatecondition = Util.null2String(rs.getString("updatecondition"));
	updatecondition = Util.toScreenToEdit(updatecondition,user.getLanguage());
	Map<String,Object> optMap = new HashMap<String,Object>();
	optMap.put("opttype", opttype);
	optMap.put("updatecondition",updatecondition);
	detailtableoptMap.put(detailtablename,optMap);
}

if(modeid>0){
	sql = "select modename,formid from modeinfo where id = " + modeid;
	rs.executeSql(sql);
	while(rs.next()){
		modename = Util.null2String(rs.getString("modename"));
		modeformid = rs.getInt("formid");
	}
}

String subCompanyIdsql = "select subCompanyId from modeinfo where id="+modeid;
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

if(modename.equals("")){
	modename = "<img src=\"/images/BacoError_wev8.gif\" align=\"absmiddle\">";
}
String workflowname = WorkflowComInfo.getWorkflowname(String.valueOf(workflowid));
if(workflowname.equals("")){
	workflowname = "<img src=\"/images/BacoError_wev8.gif\" align=\"absmiddle\">";
}

//显示基础设置
String displaystr = "";
if(workflowid<=0){
	displaystr = "style=\"display:none\"";
}

if(modeid>0&&workflowid>0){
	titlename = SystemEnv.getHtmlLabelName(30055,user.getLanguage()) + ":" + SystemEnv.getHtmlLabelName(19342,user.getLanguage());//流程转数据:详细设置
}

%>
<BODY>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
if(operatelevel>0){
	RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javaScript:doSave(),_self} " ;
	RCMenuHeight += RCMenuHeightStep;
}

if(operatelevel>1){
	if(isadd!=1){
		RCMenu += "{"+SystemEnv.getHtmlLabelName(91,user.getLanguage())+",javaScript:doDel(),_self} " ;
		RCMenuHeight += RCMenuHeightStep;
	}
}
RCMenu += "{"+SystemEnv.getHtmlLabelName(1290,user.getLanguage())+",javaScript:doBack(),_self} " ;
RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>

<form name="frmSearch" method="post" action="/formmode/interfaces/WorkflowToModeSetOperation.jsp">
	<input name="operation" value="save" type="hidden">
	<input name="id" value="<%=id%>" type="hidden">
	<input name="actionid" value="<%=actionid%>" type="hidden">
	
	<input name="initmodeid" value="<%=initmodeid%>" type="hidden">
	<input name="initworkflowid" value="<%=initworkflowid%>" type="hidden">
	
	<table class="e8_tblForm">
		<tr <%=displaystr%>>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(18624,user.getLanguage())%><!-- 是否启用 -->
				<div class="e8_label_desc"><%=SystemEnv.getHtmlLabelName(81954,user.getLanguage())%></div><!-- 勾选此项功能生效。 -->
			</td>
			<td class="e8_tblForm_field">
				<input class="inputstyle" id="isenable" name="isenable" <%=existWorkflowToMode?"":"disabled" %>  type="checkbox" value="1" <%if(isenable==1)out.println("checked");%>>
				<span  style="color:red; display:<%=existWorkflowToMode?"none":"" %>"><%=SystemEnv.getHtmlLabelName(82726,user.getLanguage())%><!-- 未在接口库中注册WorkflowToMode(流程转数据接口 ) --></span>
				<span style="margin-left: 10px; cursor: pointer;display:<%=existWorkflowToMode?"none":"" %>;" onclick="window.open('/integration/icontent.jsp?showtype=10')"><%=SystemEnv.getHtmlLabelName(82725,user.getLanguage())%><!-- 注册接口 --></span>
			</td>
		</tr>
		
		<tr>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(16579,user.getLanguage())%><!-- 流程类型 -->
			</td>
			<td class="e8_tblForm_field">
				<brow:browser viewType="0" name="workflowid" browserValue='<%=workflowid==0?"":(String.valueOf(workflowid))%>' 
				 	browserUrl='<%="/systeminfo/BrowserMain.jsp?url=/workflow/workflow/WorkflowBrowser.jsp?sqlwhere="+xssUtil.put("where isbill=1 and formid<0") %>'
					hasInput="false" isSingle="true" hasBrowser = "true" isMustInput="2"
					completeUrl="/data.jsp" linkUrl=""  width="228px"
					browserDialogWidth="510px" onpropertychange="getFormidByChange()"
					browserSpanValue='<%=workflowname%>'>
				</brow:browser>
			</td>

		</tr>
		<tr>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(81955,user.getLanguage())%><!-- 触发表单 -->
			</td>
			<td class="e8_tblForm_field">
		  		 <div id="formIdDiv">
		  		 </div>
			</td>
		</tr>
		<tr>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(19049,user.getLanguage())%><!-- 模块 -->
			</td>
			<td class="e8_tblForm_field">
		  		 
		  		 <brow:browser viewType="0" id="modeid" name="modeid" browserValue='<%=modeid==0?"":""+modeid%>' 
  		 				browserUrl="/systeminfo/BrowserMain.jsp?url=/formmode/browser/ModeBrowser.jsp"
						hasInput="false" isSingle="true" hasBrowser = "true" isMustInput="2"
						completeUrl="/data.jsp" linkUrl=""  width="228px"
						browserDialogWidth="510px"
						browserSpanValue='<%=modename %>'
						></brow:browser>
			</td>
		</tr>

		<TR>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(19346,user.getLanguage())%><!-- 触发节点 -->
			</TD>                                            
			<td class="e8_tblForm_field">
			    <div id="nodesDiv">
				<SELECT class=InputStyle name="triggerNodeId" id="triggerNodeId" >    
					<%
						if (rs.getDBType().equals("oracle")||rs.getDBType().equals("db2")) {
							rs.executeSql(" select b.id as triggerNodeId,a.nodeType as triggerNodeType,b.nodeName as triggerNodeName from workflow_flownode a,workflow_nodebase b where (b.IsFreeNode is null or b.IsFreeNode!='1') and a.nodeId=b.id and a.workFlowId is not null and a.workFlowId= "+workflowid+"  order by a.nodeType,a.nodeId  ");
						}else{
							rs.executeSql(" select b.id as triggerNodeId,a.nodeType as triggerNodeType,b.nodeName as triggerNodeName from workflow_flownode a,workflow_nodebase b where (b.IsFreeNode is null or b.IsFreeNode!='1') and a.nodeId=b.id and a.workFlowId !='' and a.workFlowId= "+workflowid+"  order by a.nodeType,a.nodeId  ");
						}
						while(rs.next()) {
							int temptriggerNodeId = rs.getInt("triggerNodeId");
							String triggerNodeName = Util.null2String(rs.getString("triggerNodeName"));
							boolean selected = (temptriggerNodeId==triggerNodeId);
							String selectedstr = "";
							if(selected){
								selectedstr = "selected";
							}
					%>
							<option value="<%=temptriggerNodeId%>" <%=selectedstr%>><%=triggerNodeName%></option>
					<%
						}
					%>
				</SELECT>    
				</div>                                    
			</TD>		
		</TR>
		<TR>
			<td class="e8_tblForm_label" width="20%">
				<%=SystemEnv.getHtmlLabelName(19347,user.getLanguage())%><!-- 触发时间 -->
			</TD>                                            
			<td class="e8_tblForm_field">                                          
				<SELECT class=InputStyle  name="triggerType" >   
					<option value="1" <%if(triggerType==1)out.println("selected");%>><%=SystemEnv.getHtmlLabelName(19348,user.getLanguage())%></option><!-- 到达节点 -->
					<option value="0" <%if(triggerType==0)out.println("selected");%>><%=SystemEnv.getHtmlLabelName(19349,user.getLanguage())%></option><!-- 离开节点 -->
				</SELECT>                                        
			</TD>		
		</TR>

		<TR>
			<td class="e8_tblForm_label" width="20%"><%=SystemEnv.getHtmlLabelName(28597,user.getLanguage())%></TD><!-- 模块创建人 -->
			<td class="e8_tblForm_field">
				<input type=radio name=modecreater id=modecreater value="1" <%if(modecreater<=0||modecreater==1){%>	checked<%}%>>
				<%=SystemEnv.getHtmlLabelName(28607,user.getLanguage())%><!-- 流程当前操作人 -->
				<br/>
				<input type=radio name=modecreater id=modecreater value="2" <%if(modecreater==2){%> checked<%}%>>
				<%=SystemEnv.getHtmlLabelName(28595,user.getLanguage())%><!-- 流程创建人 -->
				<br/>
				<input type=radio name=modecreater id=modecreater value="3" <%if(modecreater==3){%> checked<%}%>>
				<%=SystemEnv.getHtmlLabelName(28608 ,user.getLanguage())%><!-- 流程人力资源相关字段 -->
				<select class=inputstyle  name="modecreaterfieldid" id="modecreaterfieldid" > 	
				<%
					int fieldId= 0;
					//sql = "select id as id , fieldlabel as name from workflow_billfield where (viewtype is null or viewtype<>1) and billid="+ wfformid+ " and fieldhtmltype = '3' and (type=1 or type=17 or type=141 or type=142 or type=166) " ;
					sql = "select id as id , fieldlabel as name from workflow_billfield where (viewtype is null or viewtype<>1) and billid="+ wfformid+ " and fieldhtmltype = '3' and (type=1 or type=17 or type=166) " ;
					rs.executeSql(sql);
					while(rs.next()){
						fieldId=rs.getInt("id");
				%>
						<option value=<%=fieldId%> <%if(fieldId==modecreaterfieldid){%> selected<%}%>>
						<%=SystemEnv.getHtmlLabelName(rs.getInt("name"),user.getLanguage())%>
						</option>
				<%
					}
				%>
				</select>
			</TD>
		</TR>

	<%
		int modedetailno = 0;
		HashMap optionMap = new HashMap();
		
		HashMap modeFieldIdMap = new HashMap();
		HashMap modeLabelNameMap = new HashMap();
		
		ArrayList modeFieldIdList = new ArrayList();
		ArrayList modeLabelNameList = new ArrayList();
		
		ArrayList modeDetailFieldIdList = new ArrayList();
		ArrayList modeDetailLabelNameList = new ArrayList();		
		
		if(modeid>0&&workflowid>0){
			modeFieldIdList.add("-1");
			modeLabelNameList.add(SystemEnv.getHtmlLabelName(1334,user.getLanguage()));//请求标题
			
			modeFieldIdList.add("-2");
			modeLabelNameList.add(SystemEnv.getHtmlLabelName(28610,user.getLanguage()));//请求Id
			//主表名称
			sql = "select tablename from workflow_bill where id="+wfformid;
			rs.executeSql(sql);
			rs.next();
			String maintablename = Util.null2String(rs.getString("tablename"));
			//流程表单字段信息
			String tempdetailtable = "";
			sql = "select id,fieldname,fieldlabel,fielddbtype,fieldhtmltype,type,viewtype,detailtable from workflow_billfield where billid = " + wfformid + " order by viewtype asc,detailtable asc,id asc";
			rs.executeSql(sql);
			while(rs.next()){
				String fieldid = Util.null2String(rs.getString("id"));
				String fieldname = Util.null2String(rs.getString("fieldname"));
				String fieldlabel = Util.null2String(rs.getString("fieldlabel"));
				String fielddbtype = Util.null2String(rs.getString("fielddbtype"));
				String fieldhtmltype = Util.null2String(rs.getString("fieldhtmltype"));
				String type = Util.null2String(rs.getString("type"));
				String viewtype = Util.null2String(rs.getString("viewtype"));
				String detailtable = Util.null2String(rs.getString("detailtable"));
				String labelname = SystemEnv.getHtmlLabelName(Util.getIntValue(fieldlabel),user.getLanguage());
				labelname += "("+fieldname+")";
				String optionstr = "<option value=\""+fieldid+"\">"+labelname+"</option>";
				if(viewtype.equals("1")&&!tempdetailtable.equals(detailtable)){
					//modedetailno++;
					modedetailno = Util.getIntValue(detailtable.replace(maintablename+"_dt", ""));
					tempdetailtable = detailtable;
					//modeFieldIdList = new ArrayList();
					//modeLabelNameList = new ArrayList();
					modeDetailFieldIdList.add("");
					modeDetailLabelNameList.add("------"+SystemEnv.getHtmlLabelName(17463,user.getLanguage())+modedetailno+"("+detailtable+")"+"------");//明细
				}
				if(modedetailno==0){
					modeFieldIdList.add(fieldid);
					modeLabelNameList.add(labelname);
				}else{
					modeDetailFieldIdList.add(fieldid);
					modeDetailLabelNameList.add(labelname);					
				}
				String key = String.valueOf(modedetailno);
				if(optionMap.containsKey(key)){
					optionstr = Util.null2String((String)optionMap.get(key)) + optionstr;
				}
				optionMap.put(key,optionstr);
				//modeFieldIdMap.put(key,modeFieldIdList);
				//modeLabelNameMap.put(key,modeLabelNameList);
			}
			
			//modeFieldIdList = (ArrayList)modeFieldIdMap.get("0");
			//modeLabelNameList = (ArrayList)modeLabelNameMap.get("0");
	%>
								<tr>
								    <td class="e8_tblForm_label" width="20%">
								    <table style="width:100%;">
								    	<tr>
									    	<td>
										    	<%=SystemEnv.getHtmlLabelName(21778,user.getLanguage())%><!-- 主表 -->
										    	<div class="e8_label_desc"><%=SystemEnv.getHtmlLabelName(81956,user.getLanguage())%><!-- 模块主表字段映射。 --></div>
									    	</td>
									    </tr>
								    	<tr>
								    	<td>
								    		<select id="maintableopttype" name="maintableopttype" onchange="changeMaintableopttype(this)" style="width:80px;">
								    		<option value="1" <%if("1".equals(maintableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(30615,user.getLanguage())%></option><!--插入 -->
								    		<option value="2" <%if("2".equals(maintableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(17744,user.getLanguage())%></option><!--更新 -->
								    		</select>
								    	</td>
								    	</tr>
								    	<tr id="mtucTR" <%if("1".equals(maintableopttype)){%>style="display:none;"<%}%>>
								    		<td>
								    		<textarea id="maintableupdatecondition" name="maintableupdatecondition" style="width:80%;height:40px;" onChange="checkinput('maintableupdatecondition','maintableupdateconditionspan')"><%=maintableupdatecondition%></textarea>
								    		<span id="maintableupdateconditionspan"><%if(maintableupdatecondition.equals("")){%><IMG src="/images/BacoError_wev8.gif" align=absMiddle><%}%></span>
								    		<div class="e8_label_desc" style="margin-top:4px;"><%=SystemEnv.getHtmlLabelName(126244,user.getLanguage())%></div>
								    		</td>
								    	</tr>
								    </table>
								    </td>
								    <td class="e8_tblForm_field">
								    <table class="e8_tbl_detail">
								    <tr>
									    <th width="40%"><%=SystemEnv.getHtmlLabelName(28605,user.getLanguage())%><!-- 模块字段 --></th>
									    <th width="30%"><%=SystemEnv.getHtmlLabelName(685,user.getLanguage())%><!-- 字段名称 --></th>
									    <th style="width:16px;"></th>
									    <th><%=SystemEnv.getHtmlLabelName(19372,user.getLanguage())%><!-- 流程字段 --></th>
								    </tr>
		              			<%
		              				//被触发表单字段信息
		              				int detailno = 0;
		              				tempdetailtable = "";
		              				String dataclass = "datalight";
		              				sql = "select id,fieldname,fieldlabel,fielddbtype,fieldhtmltype,type,viewtype,detailtable from workflow_billfield where billid = " + modeformid + " order by viewtype asc,detailtable asc";
			              			rs.executeSql(sql);
			              			while(rs.next()){
			              				String fieldid = Util.null2String(rs.getString("id"));
			              				String fieldname = Util.null2String(rs.getString("fieldname"));
			              				String fieldlabel = Util.null2String(rs.getString("fieldlabel"));
			              				String fielddbtype = Util.null2String(rs.getString("fielddbtype"));
			              				String fieldhtmltype = Util.null2String(rs.getString("fieldhtmltype"));
			              				String type = Util.null2String(rs.getString("type"));
			              				String viewtype = Util.null2String(rs.getString("viewtype"));
			              				String detailtable = Util.null2String(rs.getString("detailtable"));
			              				String labelname = SystemEnv.getHtmlLabelName(Util.getIntValue(fieldlabel),user.getLanguage());
			              				labelname += "("+fieldname+")";
			              				if(viewtype.equals("1")&&!tempdetailtable.equals(detailtable)){
			              					detailno++;
			              					tempdetailtable = detailtable;
			              					dataclass = "datalight";
			              					
			              					String detailtableopttype = "1";
			              					String detailtableupdatecondition = "";
			              					if(detailtableoptMap.containsKey(detailtable)){
			              						Map<String,Object> optMap = (Map<String,Object>)detailtableoptMap.get(detailtable);
			              						detailtableopttype = Util.null2String(optMap.get("opttype"));
			              						detailtableupdatecondition = Util.null2String(optMap.get("updatecondition"));
			              					}
			              					
											%>
											</td></tr></table>
											<tr>
											<td class="e8_tblForm_label" width="20%">
												<table style="width:100%;">
													<tr>
														<td>
														<%=SystemEnv.getHtmlLabelName(17463,user.getLanguage())%><%=detailno%>(<%=detailtable %>)
														<input type="hidden" id="detailtablename<%=detailno%>" name="detailtablename<%=detailno%>" value="<%=detailtable %>" />
														<input type="hidden" name="detailnoflag" value="<%=detailno %>" />
														<div class="e8_label_desc"><%=SystemEnv.getHtmlLabelName(81957,user.getLanguage())%><!-- 模块明细表字段映射。 --></div>
														<div class="e8_label_desc1"><%=SystemEnv.getHtmlLabelName(81958,user.getLanguage())%><!-- (模块明细只能映射单个流程明细表) --></div>
														</td>
													</tr>
													<tr id="dtotTR<%=detailno%>" <%if(isdetailform || "1".equals(maintableopttype)){%>style="display:none;"<%}%>>
														<td>
														<select id="detailtableopttype<%=detailno%>" name="detailtableopttype<%=detailno%>" onchange="changeDetailtableopttype(this,<%=detailno%>)" style="width:80px;">
											    		<option value="1" <%if("1".equals(detailtableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(149,user.getLanguage())%></option><!-- 默认 -->
											    		<option value="2" <%if("2".equals(detailtableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(31259,user.getLanguage())%></option><!-- 追加 -->
											    		<option value="3" <%if("3".equals(detailtableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(17744,user.getLanguage())%></option><!-- 更新 -->
											    		<option value="4" <%if("4".equals(detailtableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(126237,user.getLanguage())%></option><!-- 更新(追加) -->
											    		<option value="5" <%if("5".equals(detailtableopttype)){%>selected<%}%>><%=SystemEnv.getHtmlLabelName(31260,user.getLanguage())%></option><!-- 覆盖 -->
											    		</select>
														</td>
													</tr>
													<tr id="dtucTR<%=detailno%>" <%if(isdetailform || (!"3".equals(detailtableopttype)&&!"4".equals(detailtableopttype))){%>style="display:none;"<%}%>>
											    		<td>
											    		<textarea id="detailtableupdatecondition<%=detailno%>" name="detailtableupdatecondition<%=detailno%>" style="width:80%;height:40px;" onChange="checkinput('detailtableupdatecondition<%=detailno%>','detailtableupdateconditionspan<%=detailno%>')"><%=detailtableupdatecondition%></textarea>
											    		<span id="detailtableupdateconditionspan<%=detailno%>"><%if(detailtableupdatecondition.equals("")){%><IMG src="/images/BacoError_wev8.gif" align=absMiddle><%}%></span>
											    		<div class="e8_label_desc" style="margin-top:4px;"><%=SystemEnv.getHtmlLabelName(126245,user.getLanguage())%></div>
											    		</td>
											    	</tr>
												</table>
											</td>
										    <td class="e8_tblForm_field">
											<table class="e8_tbl_detail">
												<th width="40%"><%=SystemEnv.getHtmlLabelName(28605,user.getLanguage())%><!-- 模块字段 --></th>
												<th width="30%"><%=SystemEnv.getHtmlLabelName(685,user.getLanguage())%><!-- 字段名称 --></th>
												<th style="width:16px;"></th>
												<th><%=SystemEnv.getHtmlLabelName(19372,user.getLanguage())%><!-- 流程字段 --></th>
										<%}%>
			              				<tr>
			              					<td>
			              						<%=labelname%> <span style="font-size:11px;color:#aaa;"></span>
			              						<input type="hidden" name="modefieldid<%=detailno%>" id="modefieldid<%=detailno%>" value="<%=fieldid%>">
		              						</td>
		              						<td style="font-size:11px;"><%=fieldname%></td>
		              						<td><img src="/formmode/images/arrow_left_wev8.png"/></td>
			              					<td>
			              						<select name="wffieldid<%=detailno%>" id="wffieldid<%=detailno%>"  style="width:100%">
			              							<option value="0">&nbsp;&nbsp;&nbsp;&nbsp;</option>
			              							<%
			              								if(detailno==0){
			              									for(int i=0;i<modeFieldIdList.size();i++){
			              										String tempfieldid = (String)modeFieldIdList.get(i);
			              										String tempfieldlabelname = (String)modeLabelNameList.get(i);
				              									String key = fieldid+"_"+tempfieldid;
				              									boolean selected = existsMap.containsKey(key);
				              									String selectedstr = "";
				              									if(selected){
				              										selectedstr = "selected";
				              									}
		           									%>
		           												<option value="<%=tempfieldid%>" <%=selectedstr%>><%=tempfieldlabelname%></option>
		           									<%
			              									}
			              									if(formtype.indexOf("detail")>-1){
			              										int index = Util.getIntValue(formtype.replace("detail",""));
			              										String tableStr = SystemEnv.getHtmlLabelName(17463,user.getLanguage())+index;//明细
			              										boolean isnext = false;
			              										for(int i=0;i<modeDetailFieldIdList.size();i++){
				              										String tempfieldid = (String)modeDetailFieldIdList.get(i);
				              										String tempfieldlabelname = (String)modeDetailLabelNameList.get(i);
																	if(tempfieldlabelname.indexOf("------")>-1&&isnext){
																		isnext = false;
				              										}
				              										if(tempfieldlabelname.indexOf(tableStr)>-1){
				              											isnext = true;;
				              										}
				              										if(isnext){
				              											String key = fieldid+"_"+tempfieldid;
						              									boolean selected = existsMap.containsKey(key);
						              									String selectedstr = "";
						              									if(selected){
						              										selectedstr = "selected";
						              									}
				           									%>
				           												<option value="<%=tempfieldid%>" <%=selectedstr%>><%=tempfieldlabelname%></option>
				           									<%
				              										}
				              									}
			              									}
			              								}else if("maintable".equals(formtype)){
			              									for(int i=0;i<modeDetailFieldIdList.size();i++){
			              										String tempfieldid = (String)modeDetailFieldIdList.get(i);
			              										String tempfieldlabelname = (String)modeDetailLabelNameList.get(i);
				              									String key = fieldid+"_"+tempfieldid;
				              									boolean selected = existsMap.containsKey(key);
				              									String selectedstr = "";
				              									if(selected){
				              										selectedstr = "selected";
				              									}
		           									%>
		           												<option value="<%=tempfieldid%>" <%=selectedstr%>><%=tempfieldlabelname%></option>
		           									<%
			              									}			              									
			              								}
			              							%>
			              						</select>
			              					</td>
			              		<%
			              			}
		              			%>
		              			</table>
		              			</td>
		              			</tr>
		                	</table>
		                	<br/>
		                	<input type="hidden" name="detailno" value="<%=detailno%>">
	<%
		} 
	%>
</form>
<script type="text/javascript">
	var initworkflowid = document.getElementById("workflowid").value;
	var formtype = '<%=formtype%>';
	var isdetailform = <%=isdetailform%>;
	$(document).ready(function(){//onload事件
		$(".loading", window.parent.document).hide(); //隐藏加载图片
		initFormTypeSelect();
		init_width_for_empty_selector("triggerNodeId");
		init_width_for_empty_selector("modecreaterfieldid");
	})

	<%
		for(int i=0;i<modedetailno;i++){
			String key = String.valueOf(i);
			String optionstr = Util.null2String((String)optionMap.get(key));
			out.println(" var option" + key + "  = '" + optionstr + "';");
		}
	%>
	
	function init_width_for_empty_selector(targetId) {
		var targetObj = document.getElementById(targetId);
		if(targetObj && targetObj.options.length == 0) {
			targetObj.style.width = '80px';
			$("#" +targetId).selectbox("detach");
			beautySelect(targetObj);
		} 
	}

    function doSave(){
        rightMenu.style.visibility = "hidden";
        if($("#workflowid").val()=='0'){
        	$("#workflowid").val("");
		}
        if($("#modeid").val()=='0'){
        	$("#modeid").val("");
		}
		var checkFields = "workflowid,modeid";
		var maintableopttype = $("#maintableopttype").val();
		if(maintableopttype=="2"){
			checkFields += ",maintableupdatecondition";
			if(!isdetailform){
				jQuery("[name='detailnoflag']").each(function(){
					var detailno = jQuery(this).val();
					var detailtableopttype = jQuery("#detailtableopttype"+detailno).val();
					if((detailtableopttype=="3"||detailtableopttype=="4")){
						checkFields +=",detailtableupdatecondition"+detailno;
					}
				});
			}
		}
		if(checkFieldValue(checkFields)){
			enableAllmenu();
	        document.frmSearch.submit();
		}
    }
    function doBack(){
    	enableAllmenu();
    	location.href = "/formmode/interfaces/WorkflowToModeList.jsp?modeid=<%=initmodeid%>&workflowid=<%=initworkflowid%>";
	}
	
	function doDel(){
    	window.top.Dialog.confirm("<%=SystemEnv.getHtmlNoteName(7,user.getLanguage())%>",function(){
			enableAllmenu();
    		document.frmSearch.operation.value="del";
    		document.frmSearch.submit();
		});
	}
    function onShowModeSelect(inputName, spanName){
    	var datas = window.showModalDialog("/systeminfo/BrowserMain.jsp?url=/formmode/browser/ModeBrowser.jsp");
    	if (datas){
    	    if(datas.id!=""){
    		    $(inputName).val(datas.id);
    			if ($(inputName).val()==datas.id){
    		    	$(spanName).html(datas.name);
    			}
    	    }else{
    		    $(inputName).val("");
    			$(spanName).html("<img src=\"/images/BacoError_wev8.gif\" align=\"absmiddle\">");
    		}
    	} 
    }
    
    function openURL(){
      var url = "/systeminfo/BrowserMain.jsp?url=/workflow/workflow/WorkflowBrowser.jsp?sqlwhere=where isbill=1 and formid<0";
      var result = showModalDialog(url);
      if(result){
	      if(result.name!="" && result.id!=""){
	         $("#workflowspan").html(result.name);
	         $("#workflowid").val(result.id);
	      }else{
	     	 $("#workflowspan").html("<img src=\"/images/BacoError_wev8.gif\" align=\"absmiddle\">");
	         $("#workflowid").val("");
	      }
      }
    }
    function initFormTypeSelect(){
    	var ranindex = Math.ceil(Math.random()*1000);
    	var workflowid = document.getElementById("workflowid").value;
    	$.ajax({
	    		url: "/formmode/interfaces/tableByWorkflowid.jsp?index="+ranindex,
	    		data: {workflowid:workflowid},
	    		dataType: "json",
	    		success: function(data){
	    			var selectHtml = "";
	    			if(data&&data.length>0){
	    				selectHtml = selectHtml + "<select class=InputStyle id='formtype' name='formtype'>";
	    				for(var i = 0;i<data.length;i++){
	    					var name = data[i].name;
	    					var value = data[i].value;
	    					if(formtype==value){
	    						selectHtml += "<option selected value='"+value+"'>"+name+"</option>";
	    					}else{
	    						selectHtml += "<option value='"+value+"'>"+name+"</option>";
	    					}
	    				}
	    				selectHtml +=" </select>";
	    			}
	    			$("#formIdDiv").html(selectHtml);
	    			 var targetObj = document.getElementById("formtype");
	     			 beautySelect(targetObj);
	       		}
	       });
    }
    $(document).ready(function(){
    	if($("#workflowid").val()!=''){
    		var title = $("#workflowidspan").find("a").text();
			$("#workflowidspan").html("<span class=\"e8_showNameClass\">"+title+"</span>");
    	}
    });
    function getFormidByChange(){
    	var ranindex = Math.ceil(Math.random()*1000);
    	var workflowid = document.getElementById("workflowid").value;
    	if(""!=workflowid){
	    	$.ajax({
	    		url: "/formmode/interfaces/tableByWorkflowid.jsp?index"+ranindex,
	    		data: {workflowid:workflowid},
	    		dataType: "json",
	    		success: function(data){
	    			var selectHtml = "";
	    			if(data&&data.length>0){
	    				selectHtml = selectHtml + "<select class=InputStyle id='formtype' name='formtype'>";
	    				for(var i = 0;i<data.length;i++){
	    					var name = data[i].name;
	    					var value = data[i].value;
	    					selectHtml += "<option value='"+value+"'>"+name+"</option>";
	    				}
	    				selectHtml +=" </select>";
	    			}else{
	    				var selectHtml =  "<select class=InputStyle id='formtype' name='formtype'></select>";
	    			}
	    			$("#formIdDiv").html(selectHtml);
	    			 var targetObj = document.getElementById("formtype");
	     			 beautySelect(targetObj);
    			}
	       });
	       
	       $.ajax({
	    		url: "/formmode/interfaces/NodesByWorkflowid.jsp?index"+ranindex,
	    		data: {workflowid:workflowid},
	    		dataType: "json",
	    		success: function(data){
	    			var selectHtml = "";
	    			if(data&&data.length>0){
	    				selectHtml = selectHtml + "<select class=InputStyle id='triggerNodeId' name='triggerNodeId'>";
	    				for(var i = 0;i<data.length;i++){
	    					var name = data[i].name;
	    					var value = data[i].value;
	    					selectHtml += "<option value='"+value+"'>"+name+"</option>";
	    				}
	    				selectHtml +=" </select>";
	    			}else{
	    				var selectHtml =  "<select class=InputStyle id='triggerNodeId' name='triggerNodeId'></select>";
	    			}
	    			$("#nodesDiv").html(selectHtml);
    				var targetObj = document.getElementById("triggerNodeId");
	     			beautySelect(targetObj);
    			}
	       });
    	}
    	if(event.propertyName=='value'){
			var title = $("#workflowidspan").find("a").text();
			$("#workflowidspan").html("<span class=\"e8_showNameClass\">"+title+"</span>");
		}
		//getWorkflowVersion();
    }
    
    function getWorkflowVersion(workflowid){
    	var ranindex = Math.ceil(Math.random()*1000);
    	$.ajax({
    		url: "/formmode/interfaces/getWorkflowVersion.jsp?index"+ranindex,
    		data: {workflowid:workflowid},
    		cache: false,
    		success: function(data){
    			data = jQuery.trim(data);
    			if(data&&data.length>0){
    				jQuery("#workflowversion").html("V"+data);
    			}
   			}
       });
    }
    
    
    function changeMaintableopttype(obj){
		if(obj.value=="1"){
			jQuery("#mtucTR").hide();
			if(!isdetailform){
				jQuery("[name='detailnoflag']").each(function(){
					var detailno = jQuery(this).val();
					jQuery("#dtotTR"+detailno).hide();
					jQuery("#dtucTR"+detailno).hide();
				});
			}
		}else{
			jQuery("#mtucTR").show();
			if(!isdetailform){
				jQuery("[name='detailnoflag']").each(function(){
					var detailno = jQuery(this).val();
					jQuery("#dtotTR"+detailno).show();
					var detailtableopttypeObj = jQuery("#detailtableopttype"+detailno);
					var detailtableopttype = detailtableopttypeObj.val();
					if(detailtableopttype=="3"||detailtableopttype=="4"){
						jQuery("#dtucTR"+detailno).show();
					}
				});
			}
		}
	}
	
	function changeDetailtableopttype(obj,detailno){
		var dtucTR = jQuery("#dtucTR"+detailno);
		if(obj.value=="3"||obj.value=="4"){
			dtucTR.show();
		}else{
			dtucTR.hide();
		}
	}
</script>

</BODY></HTML>
