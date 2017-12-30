
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="weaver.file.*," %>
<%@page import="com.weaver.formmodel.util.StringHelper"%>
<jsp:useBean id="ExcelFile" class="weaver.file.ExcelFile" scope="session"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<jsp:useBean id="FieldInfo" class="weaver.formmode.data.FieldInfo" scope="page"/>
<jsp:useBean id="ModeRightInfo" class="weaver.formmode.setup.ModeRightInfo" scope="page" />
<HTML>
<%
	
	String imagefilename = "/images/hdMaintenance_wev8.gif";
	String titlename = SystemEnv.getHtmlLabelName(26601, user.getLanguage());//批量导入
	String needfav = "";
	String needhelp = "";
	
	int modeid = Util.getIntValue(request.getParameter("modeid"),0);
	int pageexpandid = Util.getIntValue(request.getParameter("pageexpandid"),0);
	int sourcetype = Util.getIntValue(request.getParameter("sourcetype"),0);
	String flag = Util.null2String(request.getParameter("flag"));
	String msg = Util.null2String((String)session.getAttribute(flag));
	
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
	
	int type = 4;//批量导入权限
	boolean isRight = false;
	boolean isALLRight = false;
	if(type == 4){//监控权限判断
		ModeRightInfo.setModeId(modeid);
		ModeRightInfo.setType(type);
		ModeRightInfo.setUser(user);
		isRight = ModeRightInfo.checkUserRight(type);
		if(!isRight){
			isALLRight = HrmUserVarify.checkUserRight("ModeSetting:All", user);
			if (!isALLRight) {
				response.sendRedirect("/notice/noright.jsp");
				return;
			}
		}
	}
	
	List<Integer> importTypes = ModeRightInfo.checkUserImportType();
	if(importTypes.size()==0){
		if(isALLRight){
			importTypes.add(0);
		}
	}
%>
<HEAD>
    <LINK REL=stylesheet type=text/css HREF=/css/Weaver_wev8.css>
    <link href="/formmode/css/formmode_wev8.css" type="text/css" rel="stylesheet" />
    <SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
</HEAD>
<body>
<%
    
    String sql = "";
    String modename = "";
    String interfacepath = "";
    String isuse = "";
    String validateid = "";
    int formid = 0;
   	boolean tempflag = false;
    if(modeid > 0){
    	sql = "select * from modeinfo where Id="+modeid;
    	rs.executeSql(sql);
    	if(rs.next()){
    		formid = rs.getInt("formid");
    		modename = Util.null2String(rs.getString("modename"));
    		
    		ArrayList editfields=new ArrayList();//可编辑字段
    		
    		sql = "select * from workflow_billfield where billid="+formid+" order by viewtype asc,detailtable asc";
    		rs.executeSql(sql);
    		while(rs.next()){
    			editfields.add("field"+rs.getString("fieldid"));
    		}
    		ExcelSheet es = null;
    		ExcelFile.init() ;
    		ExcelFile.setFilename(modename) ;
    		ExcelStyle ess = ExcelFile.newExcelStyle("Header") ;
    		ess.setGroundcolor(ExcelStyle.WeaverHeaderGroundcolor) ;
            ess.setFontcolor(ExcelStyle.WeaverHeaderFontcolor) ;
            ess.setFontbold(ExcelStyle.WeaverHeaderFontbold) ;
            ess.setAlign(ExcelStyle.WeaverHeaderAlign) ;
            
            ExcelStyle ess2 = ExcelFile.newExcelStyle("MUST") ;
    		ess2.setGroundcolor(ExcelStyle.WeaverHeaderGroundcolor) ;
            ess2.setFontcolor(ExcelStyle.RED_Color) ;
            ess2.setFontbold(ExcelStyle.WeaverHeaderFontbold) ;
            ess2.setAlign(ExcelStyle.WeaverHeaderAlign) ;
            
            FieldInfo.setUser(user);
            FieldInfo.GetManTableFieldToExcel(formid, 1, user.getLanguage());//获得主字段
            ArrayList ManTableFieldlabel = FieldInfo.getManTableFieldlabel();
            ArrayList ManTableFieldHtmltypes = FieldInfo.getManTableFieldHtmltypes();
            ArrayList ManTableFieldIds = FieldInfo.getManTableFieldIds();
            es = new ExcelSheet() ;   // 初始化一个EXCEL的sheet对象
            ExcelRow er = es.newExcelRow () ;
            es.addColumnwidth(6000);
            er.addStringValue("ID","Header");
            
            String validateids = "";
            sql = "select b.fieldid from mode_excelField a,mode_excelFieldDetail b where a.formid ="+formid+" and a.modeid="+modeid+" and b.mainid=a.id";
            rs.executeSql(sql);
            while(rs.next()){
            	validateids += rs.getString("fieldid")+",";
            }     
            
            for(int i=0;i<ManTableFieldlabel.size();i++){
            	String htmlyype = Util.null2String((String)ManTableFieldHtmltypes.get(i));
            	if(htmlyype.equals("6") || htmlyype.equals("7")) continue;
                String label = Util.null2String((String)ManTableFieldlabel.get(i));
                es.addColumnwidth(6000);
                
                if(validateids.indexOf((String)ManTableFieldIds.get(i)) > -1){
                	er.addStringValue(label,"MUST");
                }else{
                	er.addStringValue(label,"Header");
                }
                
                es.addExcelRow(er);//加入一行
            }
            ExcelFile.addSheet(SystemEnv.getHtmlLabelName(21778, user.getLanguage()), es) ; //为EXCEL文件插入一个SHEET
            
            FieldInfo.GetDetailTableFieldToExcel(formid, 1, user.getLanguage());//获得明细字段
            ArrayList detailtablefieldlables=FieldInfo.getDetailTableFieldNames();
            ArrayList detailtablefieldids=FieldInfo.getDetailTableFields();
            for(int i=0;i<detailtablefieldlables.size();i++){
                es = new ExcelSheet() ;   // 初始化一个EXCEL的sheet对象
                er = es.newExcelRow () ;  //准备新增EXCEL中的一行
                es.addColumnwidth(6000);
                er.addStringValue("MAINID","Header");
                ArrayList detailfieldnames=(ArrayList)detailtablefieldlables.get(i);
                ArrayList detailfieldids=(ArrayList)detailtablefieldids.get(i);
                boolean hasfield=false;
                for(int j=0;j<detailfieldids.size();j++){
                	String f = StringHelper.null2String(detailfieldids.get(j));
                	String[] arr = f.split("_");
                	String dhtmltype = "";
                	if(arr.length==4){
                		dhtmltype = arr[3];
                		if(dhtmltype.equals("6")){
                			continue;
                		}
                	}
                	
                    //以下为EXCEL添加多个列
                    es.addColumnwidth(6000);
                    if(validateids.indexOf(arr[0].replace("field","")) > -1){
                    	er.addStringValue((String)detailfieldnames.get(j),"MUST");
                    }else{
                    	er.addStringValue((String)detailfieldnames.get(j),"Header");
                    }
                    hasfield=true;
                }
                if(hasfield){
                    es.addExcelRow(er) ;   //加入一行
                    ExcelFile.addSheet(SystemEnv.getHtmlLabelName(17463, user.getLanguage())+(i+1), es) ; //为EXCEL文件插入一个SHEET
                }
            }
    	}
    	
    	//获取接口路径等信息
    	sql = "select * from mode_DataBatchImport where modeid="+modeid;
		rs.executeSql(sql);
		if (rs.next()) {
			interfacepath = rs.getString("interfacepath");
			isuse = rs.getString("isuse");
			validateid = Util.null2String(rs.getString("validateid"));
           	if(!validateid.equals("")){
           		sql = "select COUNT(a.id) id from mode_excelFieldDetail a,mode_excelField b where a.mainid=b.id and b.modeid="+modeid;
           		rs.executeSql(sql);
           		if(rs.next()){
           			if(rs.getInt("id") > 0){
           				tempflag = true;
           			}
           		}
           	}
			
		}
    }
    
%>

<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
if (sourcetype == 1 && operatelevel>0) {
    RCMenu += "{" + SystemEnv.getHtmlLabelName(86, user.getLanguage()) + ",javascript:onSubmitData(),_self} "; //保存
    RCMenuHeight += RCMenuHeightStep;
}
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<div id="loading" style="display:none">
	<span><img src="/images/loading2_wev8.gif" align="absmiddle"></span>
	<!-- 数据导入中，请稍等... -->
	<span  id="loading-msg"><%=SystemEnv.getHtmlLabelName(28210,user.getLanguage())%></span>
</div>

<div id="content">

						
						<form name="detailimportform" method="post" action="/formmode/interfaces/ModeDataBatchImportOperation.jsp" enctype="multipart/form-data">
							<input type=hidden id="modeid" name="modeid" value="<%=modeid%>">
							<input type=hidden name="method" value="import"/>
							<input type=hidden id="formid" name="formid" value="<%=formid%>">
							<input type=hidden name="pageexpandid" value="<%=pageexpandid%>">
							<input type=hidden name="sourcetype" value="<%=sourcetype %>"/>
							<TABLE class="e8_tblForm" id="freewfoTable">
								<TBODY>
									<TR>
									    <td class="e8_tblForm_label" width="20%">1、<%=SystemEnv.getHtmlLabelName(258, user.getLanguage())%><%=SystemEnv.getHtmlLabelName(64, user.getLanguage())%></TD>
									    <td class="e8_tblForm_field"><a href="/weaver/weaver.file.ExcelOut" style="color:blue;"><%=modename%></a></TD>
									</TR>
									<TR>
									    <td class="e8_tblForm_label" width="20%">2、<%=SystemEnv.getHtmlLabelName(16630, user.getLanguage())%></TD>
									    <td class="e8_tblForm_field"><input <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %> type="file" name="excelfile" size="35"></TD>
									</TR>
									<tr>
										<td class="e8_tblForm_label" width="20%">
											<!-- 重复验证字段 -->
											3、<%=SystemEnv.getHtmlLabelName(24638, user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
											<select <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %> name="keyField" id="keyField" onchange="javascript:checkKeyField(this);">
												<option value=""></option>
												<option value="dataid"><%=SystemEnv.getHtmlLabelName(81287,user.getLanguage())%></option>
												<%
												sql="select a.fieldname,b.labelname from workflow_billfield a,HtmlLabelInfo b where a.fieldlabel=b.indexid and languageid="+user.getLanguage()+" and (fieldhtmltype<>6 and fieldhtmltype<> 7) and billid="+formid+" and viewtype=0 order by dsporder,id";
												rs.executeSql(sql);
												while(rs.next()){
													String fieldname=rs.getString("fieldname");
													String labelname=rs.getString("labelname");
												%>
												<option value="<%=fieldname%>"><%=labelname%></option>	
												<%
												}
												%>
									        </select>
										</td>
									</tr>
									<tr>
										<td class="e8_tblForm_label" width="20%">
											<!-- 导入类型 -->
											4、<%=SystemEnv.getHtmlLabelName(24863,user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
											<select <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %> id="importtype" name="importtype" onchange="changeImportType(this)">
											    <%
											    //根据后台设置的导入类型 这里做一个限制 
											    if(importTypes.size()==0 || importTypes.contains(1) || importTypes.contains(0)){
											    %>
												<option value="1"><%=SystemEnv.getHtmlLabelName(31259,user.getLanguage())%></option><!-- 追加 -->
												<%}
											    if(importTypes.size()==0 || importTypes.contains(2) || importTypes.contains(0)){
											    %>
												<option value="2"><%=SystemEnv.getHtmlLabelName(31260,user.getLanguage())%></option><!-- 覆盖 -->
												<%}
											    if(importTypes.size()==0 || importTypes.contains(3) || importTypes.contains(0)){
											    %>
												<option value="3"><%=SystemEnv.getHtmlLabelName(17744, user.getLanguage())%></option><!-- 更新 -->
												<%} %>
											</select>
											<span id="RemindMessage" style="color:red;font-weight:bold;Letter-spacing:1px;"></span>
										</td>
									</tr>
									
									<tr>
										<td class="e8_tblForm_label">
											5、<%=SystemEnv.getHtmlLabelName(84673,user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
											<input type="checkbox" name="isImportedWithIgnoringError" id="isImportedWithIgnoringError" value="0" onclick="checkIsImportedWithIgnoringError(this)" >
										</td>
									</tr>
									
									<%if(sourcetype == 1 ){ %>
									<tr>
										<td class="e8_tblForm_label">										
										<!-- 导入必填 -->
											6、<%=SystemEnv.getHtmlLabelNames("32935,18019,22628",user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
										 	<button type="button" class="addbtn2" onclick="onShowModeBrowser('importValidationId','importValidationSpan');" title="<%=SystemEnv.getHtmlLabelNames("18596,15364",user.getLanguage())%>"></button>
										    <span id="importValidationSpan">
										    <%
										       if(!validateid.equals("") && tempflag){
										   %> 	
										       <a id="conditionsetting" href="javascript:onShowModeBrowser('importValidationId','importValidationSpan')"><font color='#018efb'>已设置</font></a>
										    <%   
										       }
										    %>
											</span>
											<input type="hidden" id="importValidationId" name="importValidationId" value="<%=validateid %>">
										</td>
									</tr>
							        <%}else{ 
							             if(!validateid.equals("") && tempflag){
							        %>
							           <tr>
										<td class="e8_tblForm_label">										
										<!-- 导入必填 -->
											6、<%=SystemEnv.getHtmlLabelNames("32935,18019,22628",user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">										 	
										    <span id="importValidationSpan">
										       <a id="conditionsetting" href="javascript:onShowModeBrowser('importValidationId','importValidationSpan')"><font color='#018efb'>已设置</font></a>
											</span>
											<input type="hidden" id="importValidationId" name="importValidationId" value="<%=validateid %>">
										</td>
									</tr>
							        <%}
							           } %>
									<%
									  if (sourcetype == 1) {
									%>
									<tr>
										<td class="e8_tblForm_label" width="20%">
											<!-- 接口路径 -->									
											7、<%=SystemEnv.getHtmlLabelName(82804,user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
											<input type="text" id="interfacePath" name="interfacePath" value="<%=interfacepath %>" <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %> Style="width:400px;" />
											<INPUT class="inputstyle" style="line-light: 10px;" <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %> type="checkbox" id="isUse" name="isUse" value="1" <% if("1".equals(isuse)) {%> checked=checked <%}%>/><span style="color:red;font-weight:bold;Letter-spacing:1px;">(<%=SystemEnv.getHtmlLabelName(18624,user.getLanguage())%>)<!-- 是否启用 --></span>
										</td>
									</tr>
									<% } %>
									<tr>
										<td class="e8_tblForm_label" width="20%">
											<!-- 导入 -->
											<%if (sourcetype == 1) { %>8<% } else { if(tempflag){ %>7<%}else{%>6<%}} %>、<%=SystemEnv.getHtmlLabelName(18596,user.getLanguage())%>
										</td>
										<td class="e8_tblForm_field">
											<button type=BUTTON <%if(operatelevel<1&&!isRight){%>disabled="disabled"<%} %>  class=btnSave onclick="onSave(this);" title="<%=SystemEnv.getHtmlLabelName(25649,user.getLanguage())%>">
												<!-- 开始导入-->
												<%=SystemEnv.getHtmlLabelName(25649,user.getLanguage())%>
											</button>
										</td>
									</tr>
									<%
										if(!flag.equals("") && msg.equals("")){
									%>
										<tr>
											<td class="e8_tblForm_label" width="20%"><%=SystemEnv.getHtmlLabelName(24960,user.getLanguage())%></td><!-- 提示信息 -->
											<td class="e8_tblForm_field"><font color="red"><%=SystemEnv.getHtmlLabelName(28450,user.getLanguage())%></font></td><!-- 导入成功！ -->
										</tr>
										<TR class="Spacing">
										    <TD class="Line" colspan="2"></TD>
										</TR>
									<%
										}else if(!msg.equals("")) {
									%>
											<tr>
												<td class="e8_tblForm_label" width="20%"><%=SystemEnv.getHtmlLabelName(24960,user.getLanguage())%></td><!-- 提示信息 -->
												<td class="e8_tblForm_field"><font color="red"><%=msg.replace("\\n", "<br>") %></font></td>
											</tr>
									<%
										}
									%>
									<TR>
									    <TD colspan="2" style="">
									        <br><b><%=SystemEnv.getHtmlLabelName(27577, user.getLanguage())%>：</b><br><!-- 操作步骤 -->
									        <!-- 
									        1）请先下载<a href="/weaver/weaver.file.ExcelOut" style="color:blue;"><%=modename%></a>模板进行填写导入表单内容，第一行为表单字段的名称。<br>
									        2）请在第2步中选择填写好的Excel文件，并点击开始导入。<br>
									        3）选择导入类型。<br>
									        4）点击"开始导入"。<br><br>
									        <b><%=SystemEnv.getHtmlLabelName(27581, user.getLanguage())%></b><br>
									        1）模板中第一行为表单字段名称，从第二行开始填写需要导入的数据。<br>
									        2）数据之间不能有空行。<br>
									        3）主字段为一个SHEET页，如果有明细时模板中会有多个SHEET，一个明细一个SHEET。<br>
									        4）每条主数据都有一个ID字段，同时每条明细数据里面都有MAINID字段，这两个字段的作用为明细数据和主数据的关联关系，ID的值必须为数字或者字母。<br>
									        5）数字类型字段不要有特殊格式，例如：科学计数法，千分位，货币符号等。<br>
									        6）浏览类型字段直接输入名称，例如：人力资源字段直接输入人员名称。<br>
									        7）check类型字段输入"1/0"或"是/否"。<br>
									        8）下拉选择框类型字段输入下拉选择框显示名称。(百分比格式的需要改为文本格式)<br>
									        9）日期类型字段导入时模板中需改为日期格式。
									        10）人力资源字段支持编号导入，excel模板中的格式为：workcode_具体编号。
									        11）模板中支持创建人，创建日期导入。在模板中创建人支持直接输入名称或者主键ID。
									        12）批量导入支持以数据ID作为重复验证字段去更新已有数据，已有数据的ID可以从查询列表导出。
									        13）导入类型为“追加”，就是把模版中的数据新增到该模块中；导入类型为“覆盖”会把该模块中所有的数据全部删除，然后再导入模版中的数据，请慎用！<br>
									        14）导入虚拟部门、分部，数据需以virtual_开头，例如：virtual_泛微
									        15）接口路径为验证导入数据的接口路径。形如weaver.formmode.setup.**。
									         -->

									        1）<%=SystemEnv.getHtmlLabelName(27578, user.getLanguage())%><a href="/weaver/weaver.file.ExcelOut" style="color:blue;"><%=modename%></a><%=SystemEnv.getHtmlLabelName(30765, user.getLanguage())%><br>
									        2）<%=SystemEnv.getHtmlLabelName(30766, user.getLanguage())%><br>
									        3）<%=SystemEnv.getHtmlLabelName(31261, user.getLanguage())%><br>
									        4）<%=SystemEnv.getHtmlLabelName(30767, user.getLanguage())%><br><br>
									        <b><%=SystemEnv.getHtmlLabelName(27581, user.getLanguage())%></b><br>
									        1）<%=SystemEnv.getHtmlLabelName(30768, user.getLanguage())%><br>
									        2）<%=SystemEnv.getHtmlLabelName(30769, user.getLanguage())%><br>
									        3）<%=SystemEnv.getHtmlLabelName(30770, user.getLanguage())%><br>
									        4）<%=SystemEnv.getHtmlLabelName(30771, user.getLanguage())%><br>
									        5）<%=SystemEnv.getHtmlLabelName(27587, user.getLanguage())%><br>
									        6）<%=SystemEnv.getHtmlLabelName(82723, user.getLanguage())%><br>
									        7）<%=SystemEnv.getHtmlLabelName(30774, user.getLanguage())%><br>
									        8）<%=SystemEnv.getHtmlLabelName(27590, user.getLanguage())%><%=SystemEnv.getHtmlLabelName(126300, user.getLanguage())%><br>
									        9）<%=SystemEnv.getHtmlLabelName(126320, user.getLanguage())%><br>
									        10）<%=SystemEnv.getHtmlLabelName(126429, user.getLanguage())%><br>
									        11）<%=SystemEnv.getHtmlLabelName(126762, user.getLanguage())%><br>
									        12）<%=SystemEnv.getHtmlLabelName(126763, user.getLanguage())%><br>
									        13）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(31262, user.getLanguage())%></span><br>
									        14）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(126435, user.getLanguage())%></span><br>
									        <%
									          if (sourcetype == 1) {
									        	  
									        %>
									        15）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(82825, user.getLanguage())%></span><br>
									        16）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(127102, user.getLanguage())%></span><br>
									        <% }else{ %>
									        15）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(127102, user.getLanguage())%></span><br>
									        <%} %>
									    </TD>
									</TR>
								</TBODY>
							</TABLE>
						</form>
						<iframe id="ExcelOut" name="ExcelOut" border=0 frameborder=no noresize=NORESIZE height="0" width="0"></iframe>
</div>

<script language=javascript>
	$(document).ready(function(){//onload事件
		$(".loading", window.parent.document).hide(); //隐藏加载图片
		if($("#modeid").val()=='0'){
			if(confirm("<%=SystemEnv.getHtmlLabelName(30776,user.getLanguage())%>")){//请先保存基本信息！
				window.parent.document.getElementById('modeBasicTab').click();
			}else{
				$('.href').hide();
			}
		}
	});
	
	function onSubmitData() {
		document.detailimportform.method.value="save";
		document.detailimportform.submit();
	}

    function onSave(obj) {
        var fileName=$G("excelfile").value;
		if(fileName!=""&&fileName.length>4){
		    var keyField_select = $G("keyField").value;
		    var importtype_select = $G("importtype").value;
		    if("dataid" == keyField_select && 3 != importtype_select){
		      alert('<%=SystemEnv.getHtmlLabelName(18214,user.getLanguage())+SystemEnv.getHtmlLabelName(24863,user.getLanguage())+":"+SystemEnv.getHtmlLabelName(17744,user.getLanguage())%>');//
		      return;
		    }
		    
		    if("" == keyField_select && 3 == importtype_select){
		      alert('<%=SystemEnv.getHtmlLabelName(18214,user.getLanguage())+SystemEnv.getHtmlLabelName(24638,user.getLanguage())%>');//
		      return;
		    }
			if(fileName.substring(fileName.length-4).toLowerCase()!=".xls"){
				alert('<%=SystemEnv.getHtmlLabelName(31460,user.getLanguage())%>');//必须上传.xls格式的文件
				return;
			}
			jQuery("#loading").show();
			jQuery("#content").hide();
			$G("detailimportform").submit();//上传文件
            obj.disabled=true;
		}else{
            alert('<%=SystemEnv.getHtmlLabelName(20890,user.getLanguage())%>');//必须上传Excel格式的文件
        }
    }

    function onClose() {
        window.parent.close();
    }
    
    function checkIsImportedWithIgnoringError(obj){
		if($(obj).attr("checked")){
			$(obj).val(1);
		}else{
			$(obj).val(0);
		}
	}

    function changeImportType(obj){
		if(obj.value=="1"){
			jQuery("#RemindMessage").html("");
		}else if(obj.value=="2"){
			jQuery("#RemindMessage").html('<%=SystemEnv.getHtmlLabelName(31263, user.getLanguage())%>');
			alert('<%=SystemEnv.getHtmlLabelName(31263, user.getLanguage())%>');//导入方式选择“覆盖”会把该模块中所有的数据全部删除，然后再导入模版中的数据，请慎用！
		}else if(obj.value == "3") {
		    var htmls = '&nbsp;&nbsp;<input type="checkbox" name="updateadddata" id="updateadddata" value="1" >（<%=SystemEnv.getHtmlLabelName(82483, user.getLanguage())%>）';
			jQuery("#RemindMessage").html(htmls);
		}
	}
	
	function checkKeyField(obj){
	    jQuery("#importtype").selectbox("detach");
	    jQuery("#importtype").empty();
	    if(obj.value=="dataid"){
			jQuery("#importtype").append("<option value='3'><%=SystemEnv.getHtmlLabelName(17744,user.getLanguage())%></option>");
			var htmls = '&nbsp;&nbsp;<input type="checkbox" name="updateadddata" id="updateadddata" value="1" >（<%=SystemEnv.getHtmlLabelName(82483, user.getLanguage())%>）';
			jQuery("#RemindMessage").html(htmls);
	    }else{
	        jQuery("#importtype").append("<option value='1'><%=SystemEnv.getHtmlLabelName(31259,user.getLanguage())%></option>");  
	        jQuery("#importtype").append("<option value='2'><%=SystemEnv.getHtmlLabelName(31260,user.getLanguage())%></option>");  
	        jQuery("#importtype").append("<option value='3'><%=SystemEnv.getHtmlLabelName(17744,user.getLanguage())%></option>");  
	    }
	    jQuery("#importtype").selectbox("attach");
	}
	
	function onShowModeBrowser(ids,spans){
    var modeid = $("#modeid").val();
    var formid = $("#formid").val();
    var importValidationId = $("#importValidationId").val();
	urls = "/formmode/setup/ModeImportCondition.jsp?modeid="+modeid+"&formid="+formid+"&id="+importValidationId+"&sourcetype=<%=sourcetype%>";
	urls = "/systeminfo/BrowserMain.jsp?url="+escape(urls);
	dlg = new window.top.Dialog();
	dlg.currentWindow = window;
	dlg.Model = true;
	dlg.Width = 750;//定义长度
	dlg.Height = 450;
	dlg.URL = urls;
	dlg.Title = "<%=SystemEnv.getHtmlLabelNames("32935,18019,22628",user.getLanguage())%>";//导入必填字段
	dlg.callbackfun = function(callbackfunParam, data){
	   var id = data.id;
	   var flag = data.flag;
	   if(flag){
	      var html = "<a id='conditionsetting' href='javascript:onShowModeBrowser(\""+ids+"\",\""+spans+"\")'><font color='#018efb'>已设置</font></a>";
	      $("#"+spans).html(html);
	      $("#"+ids).val(id);
	   }else{
	      $("#conditionsetting").hide();
       }
	}
	dlg.show();
}
	
    
    <%if(importTypes.contains(3) && importTypes.size()==1){%>
         //更新 + 追加条件
         var htmls = '&nbsp;&nbsp;<input type="checkbox" name="updateadddata" id="updateadddata" value="1" >（<%=SystemEnv.getHtmlLabelName(82483, user.getLanguage())%>）';
	     jQuery("#RemindMessage").html(htmls);
    <%}%>
</script>
</body>
</html>
