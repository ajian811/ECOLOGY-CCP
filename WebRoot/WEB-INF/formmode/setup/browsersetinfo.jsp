
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.formmode.service.BrowserInfoService"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page"/>
<jsp:useBean id="BrowserXML" class="weaver.servicefiles.BrowserXML" scope="page" />
<jsp:useBean id="DataSourceXML" class="weaver.servicefiles.DataSourceXML" scope="page" />
<HTML><HEAD>
<LINK href="/css/Weaver_wev8.css" type=text/css rel=STYLESHEET>
<SCRIPT language="javascript" src="../../js/weaver_wev8.js"></script>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<link rel="stylesheet" href="/wui/theme/ecology8/weaveredittable/css/WeaverEditTable_wev8.css">
<script  src="/wui/theme/ecology8/weaveredittable/js/WeaverEditTable_wev8.js"></script>
<script language=javascript src="/js/ecology8/request/e8.browser_wev8.js"></script>
</head>
<%
if(!HrmUserVarify.checkUserRight("FORMMODEAPP:All",user)) {
	response.sendRedirect("/notice/noright.jsp") ;
	return ;
}

String imagefilename = "/images/hdSystem_wev8.gif";
String titlename = SystemEnv.getHtmlLabelName(23661,user.getLanguage());//配置自定义浏览框
String needfav ="1";
String needhelp ="";
String browserid=Util.null2String(request.getParameter("browserid"));
String customid=Util.null2String(request.getParameter("customid"));
BrowserInfoService browserInfoService=new BrowserInfoService();
Map<String,Object> map=browserInfoService.getBrowserInfoById(Util.getIntValue(customid));
String customname=Util.toScreen(Util.null2String(map.get("customname")),user.getLanguage());
String backto=Util.null2String(request.getParameter("backto"));
ArrayList pointArrayList = BrowserXML.getPointArrayList();
Hashtable dataHST = BrowserXML.getDataHST();
String thisServiceId = "";
String thisSearch = "";
String thisSearchById = "";
String thisSearchByName = "";
String thisNameHeader = "";
String thisDescriptionHeader = "";
String outPageURL = "";
String href = "";
String from = "";
String showtree = "";
String nodename = "";
String parentid = "";
String ismutil = "";
String name = "";
if(!"".equals(browserid))
{
	for(int i=0;i<pointArrayList.size();i++){
	    String pointid = (String)pointArrayList.get(i);
	    if(!pointid.equals("")&&browserid.equals(pointid))
	    {
		    Hashtable thisDetailHST = (Hashtable)dataHST.get(pointid);
		    if(thisDetailHST!=null){
		        thisServiceId = (String)thisDetailHST.get("ds");
		        thisSearch = (String)thisDetailHST.get("search");
		        //out.println("thisSearch : "+thisSearch);
		        thisSearchById = (String)thisDetailHST.get("searchById");
		        thisSearchByName = (String)thisDetailHST.get("searchByName");
		        thisNameHeader = (String)thisDetailHST.get("nameHeader");
		        thisDescriptionHeader = (String)thisDetailHST.get("descriptionHeader");
		        outPageURL = Util.null2String((String)thisDetailHST.get("outPageURL"));
		        href = Util.null2String((String)thisDetailHST.get("href"));
		        from = Util.null2String((String)thisDetailHST.get("from"));
		        showtree = Util.null2String((String)thisDetailHST.get("showtree"));
		        nodename = Util.null2String((String)thisDetailHST.get("nodename"));
		        parentid = Util.null2String((String)thisDetailHST.get("parentid"));
		        ismutil = Util.null2String((String)thisDetailHST.get("ismutil"));
		        name = Util.null2String((String)thisDetailHST.get("name"));
		    }
	    }
	}
}
if(name.equals("")&&!"".equals(browserid))
{
	name = browserid;
}
String pointids = ",";
for(int i=0;i<pointArrayList.size();i++){
    String pointid = (String)pointArrayList.get(i);
    if(pointid.equals(browserid)&&!"".equals(browserid))
		continue;
    pointids += pointid+",";
}
thisServiceId = thisServiceId.replaceAll("datasource.","");
ArrayList dsPointArrayList = DataSourceXML.getPointArrayList();
String dsOptions = "";
for(int i=0;i<dsPointArrayList.size();i++){
    String pointid = (String)dsPointArrayList.get(i);
    //out.println("thisServiceId : "+thisServiceId+" pointid : "+pointid);
    String selected = "";
    if(thisServiceId.equals(pointid)){
    	selected = "selected";
    }
    dsOptions += "<option value='"+pointid+"' "+selected+">"+pointid+"</option>";
}

String subCompanyIdsql = "SELECT b.subcompanyid FROM mode_custombrowser a,modeTreeField b WHERE a.appid=b.id AND a.id="+customid;
RecordSet recordSet = new RecordSet();
recordSet.executeSql(subCompanyIdsql);
int subCompanyId = -1;
if(recordSet.next()){
	subCompanyId = recordSet.getInt("subCompanyId");
}
String userRightStr = "FORMMODEAPP:ALL";
Map rightMap = getCheckRightSubCompanyParam(userRightStr,user,fmdetachable, subCompanyId,"",request,response,session);
int operatelevel = Util.getIntValue(Util.null2String(rightMap.get("operatelevel")),-1);
subCompanyId = Util.getIntValue(Util.null2String(rightMap.get("subCompanyId")),-1);

%>

<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
if(operatelevel>0){
	RCMenu += "{"+SystemEnv.getHtmlLabelName(86,user.getLanguage())+",javascript:onSubmit(),_self} " ;//保存
	RCMenuHeight += RCMenuHeightStep ;
}
if(!"".equals(browserid))
{
	if(operatelevel>1){
		RCMenu += "{" + SystemEnv.getHtmlLabelName(91, user.getLanguage()) + ",javascript:deleteData(),_self} ";//删除
		RCMenuHeight += RCMenuHeightStep;
	}
	if(operatelevel>0){
		RCMenu += "{"+SystemEnv.getHtmlLabelName(20873,user.getLanguage())+",javascript:initData(),_self} ";//初始化
		RCMenuHeight += RCMenuHeightStep ;
	}
	
	RCMenu += "{"+SystemEnv.getHtmlLabelName(201,user.getLanguage())+",/formmode/setup/browserList.jsp?objid="+customid+",_self} " ;//取消
	RCMenuHeight += RCMenuHeightStep ;
}
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
<div id="tabDiv" >
   <span style="font-size:14px;font-weight:bold;"></span> 
</div>
<div class="cornerMenuDiv"></div>
<div class="advancedSearchDiv" id="advancedSearchDiv" style='display:none;'>
</div>
<FORM style="MARGIN-TOP: 0px" name=frmMain method=post action="/formmode/setup/BrowserXMLFileOperation.jsp">
	<input type="hidden" id="operation" name="operation" value="browser">
	<input type="hidden" id="method" name="method" value="add">
	<input type="hidden" id="from" name="from" value="<%=from %>">
	<input type="hidden" id="typename" name="typename" value="<%=backto %>">
	<wea:layout><!-- 基本信息 -->
		<wea:group context='<%=SystemEnv.getHtmlLabelName(1361,user.getLanguage())%>' attributes="{'samePair':'BaseInfo','groupOperDisplay':'none'}">
		  <wea:item><%=SystemEnv.getHtmlLabelName(23675,user.getLanguage())%></wea:item><!-- 自定义浏览框标识 -->
		  <wea:item>
				<input class="inputstyle" type=text  style='width:200px;' id="browserid" name="browserid" value="<%=browserid %>" onChange="checkinput('browserid','browseridspan')" onblur="isExist(this.value)">
				<span id="browseridspan"><%if("".equals(browserid)){ %><img src="/images/BacoError_wev8.gif" align=absmiddle><%} %></span>
				<input class="inputstyle" type=hidden id="oldbrowserid" name="oldbrowserid" value="<%=browserid %>">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(33439,user.getLanguage())%></wea:item><!-- 名称 -->
		  <wea:item>
				<input class="inputstyle" type=text  style='width:200px;' id="name" name="name" value="<%=name %>" onChange="checkinput('name','namespan')">
				<span id="namespan"><%if("".equals(name)){ %><img src="/images/BacoError_wev8.gif" align=absmiddle><%} %></span>
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(82014,user.getLanguage())%></wea:item><!-- 自定义浏览框名称 -->
		  <wea:item>
				<input class="inputstyle" type="hidden"  id="customid" name="customid" value="<%=customid %>" >
				<span id="browsernamespan"><%=customname %></span>
		  </wea:item> 
		  <wea:item><%=SystemEnv.getHtmlLabelName(18076,user.getLanguage())%></wea:item><!-- 数据源 -->
		  <wea:item>
				<select id="ds" name="ds">
				    <option></option>
					<%=dsOptions%>
				</select>
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(23676,user.getLanguage())%></wea:item><!-- 无条件查询 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="search" name="search" value="<%=thisSearch %>" size="80">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(23677,user.getLanguage())%></wea:item><!-- 条件1查询 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="searchById" name="searchById" value="<%=thisSearchById %>" size="80">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(23678,user.getLanguage())%></wea:item><!-- 条件2查询 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="searchByName" name="searchByName" value="<%=thisSearchByName %>" size="80">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(23679,user.getLanguage())%></wea:item><!-- 列1显示名 -->
		  <wea:item>
		  	<input class="inputstyle" type=text   id="nameHeader" name="nameHeader" value="<%=thisNameHeader %>">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(23680,user.getLanguage())%></wea:item><!-- 列2显示名 -->
		  <wea:item>
		  	<input class="inputstyle" type=text   id="descriptionHeader" name="descriptionHeader" value="<%=thisDescriptionHeader %>">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(28144,user.getLanguage())%></wea:item><!-- 外部页面地址 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="outPageURL" name="outPageURL" value="<%=outPageURL %>" size="80">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(16208,user.getLanguage())%></wea:item><!-- 链接地址 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="href" name="href" value="<%=href %>" size="80">
		  </wea:item>
		</wea:group>
		
		<wea:group context="" attributes="{'groupDisplay':'none','itemAreaDisplay':'none'}">
		  <wea:item ><%=SystemEnv.getHtmlLabelName(32350,user.getLanguage())%></wea:item><!-- 树状显示 -->
		  <wea:item >
		  	<input type="checkbox" id="showtree" name="showtree" value="1" <%if("1".equals(showtree)){ %>checked<%} %> onchange="if(this.checked){this.value=1;}else{this.value=0;}">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(32351,user.getLanguage())%></wea:item><!-- 显示标题 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="nodename" style="width:100px;" size="50" name="nodename" value="<%=nodename %>" maxLength="50">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(32352,user.getLanguage())%></wea:item><!-- 上级字段名 -->
		  <wea:item>
		  	<input class="inputstyle" type=text id="parentid" style="width:100px;" name="parentid" value="<%=parentid %>" size="50" maxLength="50">
		  </wea:item>
		  <wea:item><%=SystemEnv.getHtmlLabelName(28627,user.getLanguage())%></wea:item><!-- 多选 -->
		  <wea:item>
		  	<input type="checkbox" id="ismutil" name="ismutil" value="1" <%if("1".equals(ismutil)){ %>checked<%} %> onchange="if(this.checked){this.value=1;}else{this.value=0;}">
		  </wea:item>
		</wea:group>
		
		
	</wea:layout>
	<wea:layout><!-- 说明 -->
		<wea:group context='<%=SystemEnv.getHtmlLabelName(85,user.getLanguage())%>' attributes="{'samePair':'RemarkInfo','groupOperDisplay':'none','itemAreaDisplay':'block'}">
		  <wea:item attributes="{'colspan':'2'}">
			1、<%=SystemEnv.getHtmlLabelName(23953,user.getLanguage())%>；<!-- 浏览按钮字段类型中有自定义单选和自定义多选两种类型字段，所引用的自定义浏览按钮即在此设置，自定义浏览框标识不能重复 -->
			<BR>
			2、<%=SystemEnv.getHtmlLabelName(23954,user.getLanguage())%>；<!-- 数据源选择——从指定数据源中查找并显示数据 -->
			<BR>
			3、<%=SystemEnv.getHtmlLabelName(23955,user.getLanguage())%>；<!-- 自定义浏览页面只能显示一个查询条件和两列内容，即所有查询不能超过三个字段 -->
			<BR>
			4、<%=SystemEnv.getHtmlLabelName(23956,user.getLanguage())%>；<!-- 浏览选择时初始数据按“无条件查询”内容查询数据，条件搜索时按“条件2查询”内容查询数据 -->
			<BR>
			5、<%=SystemEnv.getHtmlLabelName(23957,user.getLanguage())%>；<!-- 选择后流程字段保存的是“无条件查询”的第一列的值，流程中显示值是按“条件1查询”内容查询出的第一列的值，第二列的值作为链接的title -->
			<BR>
			6、<%=SystemEnv.getHtmlLabelName(23958,user.getLanguage())%>；<!-- “列1显示名”和“列2显示名”指定无条件查询的第二列和第三列对应的字段说明 -->
			<BR>
			7、<%=SystemEnv.getHtmlLabelName(23959,user.getLanguage())%>。<!-- 所有查询中的参数变量用？代替 -->
		  </wea:item>
		</wea:group>
	</wea:layout>
  </FORM>
</BODY>

<script language="javascript">
function onSubmit(){
    if(check_form(frmMain,"browserid,name")) frmMain.submit();
}
function isExist(newvalue){
    var pointids = "<%=pointids%>";
    if(pointids.indexOf(","+newvalue+",")>0){
        top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(23992,user.getLanguage())%>");//该自定义浏览框已存在！
        document.getElementById("browserid").value = "";
    }
}
function doBack()
{
	document.location.href="/integration/WsShowEditSetList.jsp?typename=<%=backto%>";
}
function deleteData(){
    top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(15097,user.getLanguage())%>", function (){//确定要删除吗?
		document.getElementById("method").value = "deletesingle";
        document.frmMain.submit();
	}, function () {}, 320, 90);
}

function initData(){
	rightMenu.style.visibility = "hidden";
	frmMain.action = "/formmode/browser/CreateBrowserOperation.jsp?type=1";
	document.getElementById("method").value  = "initData";
	document.getElementById("customid").value  = "<%=customid%>";
	document.getElementById("browserid").value  = "<%=browserid%>";
	frmMain.submit();
}
</script>

</HTML>
