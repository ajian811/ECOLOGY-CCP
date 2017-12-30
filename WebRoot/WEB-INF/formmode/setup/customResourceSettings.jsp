<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="weaver.formmode.service.AppInfoService"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="weaver.systeminfo.SystemEnv"%>
<%@page import="weaver.formmode.service.CustomResourceService"%>
<%@ include file="/formmode/pub.jsp"%>
<%
	if (!HrmUserVarify.checkUserRight("FORMMODEAPP:ALL", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}
%>
<%
int appId = Util.getIntValue(request.getParameter("modelId"), 0);
AppInfoService appInfoService = new AppInfoService();
CustomResourceService customResourceService = new CustomResourceService();
Map<String, Object> appInfo = appInfoService.getAppInfoById(appId);
String treeFieldName = Util.null2String(appInfo.get("treefieldname"));

int subCompanyId = Util.getIntValue(Util.null2String(appInfo.get("subcompanyid")),-1);
String userRightStr = "FORMMODEAPP:ALL";
Map rightMap = getCheckRightSubCompanyParam(userRightStr,user,fmdetachable, subCompanyId,"",request,response,session);
int operatelevel = Util.getIntValue(Util.null2String(rightMap.get("operatelevel")),-1);
subCompanyId = Util.getIntValue(Util.null2String(rightMap.get("subCompanyId")),-1);
String subCompanyId3 = ""+subCompanyId;
int currentSubCompanyId = Util.getIntValue(Util.null2String(rightMap.get("currentSubCompanyId")),-1);

JSONArray resourceCustomtreeArr = new JSONArray();
if(fmdetachable.equals("1")){
	resourceCustomtreeArr = customResourceService.getCustomResourceByModeIdWithJSONDetach(appId,currentSubCompanyId);
}else{
	resourceCustomtreeArr = customResourceService.getCustomResourceByModeIdWithJSONDetach(appId);
}

String titlename=SystemEnv.getHtmlLabelName(124947,user.getLanguage());//自定义页面设置
%>
<html>
<head>
	<title></title>
	<link rel="stylesheet" type="text/css" href="/formmode/js/ext-3.4.1/resources/css/ext-all_wev8.css" />
	<script type="text/javascript" src="/formmode/js/ext-3.4.1/adapter/ext/ext-base_wev8.js"></script>
	<script type="text/javascript" src="/formmode/js/ext-3.4.1/ext-all_wev8.js"></script>
	<script type="text/javascript" src="/formmode/js/ext-3.4.1/ux/miframe_wev8.js"></script>
	
	<script type="text/javascript" src="/formmode/js/jquery/pagination/jquery.pagination_wev8.js"></script>
	<script type="text/javascript" src="/formmode/js/jquery/hoverIntent/jquery.hoverIntent.minified_wev8.js"></script>
	
	<link rel="stylesheet" href="/formmode/js/jquery/zTree3.5.15/css/zTreeStyle/zTreeStyle_wev8.css" type="text/css">
	<script type="text/javascript" src="/formmode/js/jquery/zTree3.5.15/js/jquery.ztree.all-3.5.min_wev8.js"></script>
	
	<link rel="stylesheet" type="text/css" href="/formmode/css/leftPartTemplate_wev8.css" />
	<script type="text/javascript" src="/formmode/js/leftPartTemplate_wev8.js"></script>
	
	<script type="text/javascript">
	
		var datas = <%=resourceCustomtreeArr.toString() %>;
		var currentDatas;
		
		var customResourceId = null;
		
		$(document).ready(function () {
			
			customResourceId = FormmodeUtil.getLastId(FormModeConstant._CURRENT_RESOURCE, datas, "id");
			currPageIndex = FormmodeUtil.getLastIdPageIndex(customResourceId,datas,"id",pageSize);
			
			//去掉左菜单边框
			try{
				top.document.getElementById("leftmenuTD").style.borderRight = "#e6e6e6 1px solid";
			}catch(e){}
			
			var leftPanel = new Ext.Panel({
				contentEl: "leftPart",
				header: false,
				region: "west",
				width:250,
				border: false,
            	split:true,
            	collapsible: true,
           		collapsed : false
			});
			
			var url = "";
			//if(customPageId != null){
				url = "/formmode/setup/customResourceInfo.jsp?id="+customResourceId+"&appid=<%=appId%>";	
			//}
			
			var viewport = new Ext.Viewport({
				layout: 'border',
				items: [leftPanel,
                {
					region:'center',
					xtype     :'iframepanel',
 					frameConfig: {
                    	id:'rightFrame', 
                    	name:'rightFrame', 
                    	frameborder:0 ,
                    	eventsFollowFrameLinks : false,
                    	height:"100%",
                    	width:"100%",
                    	onload:"rightFrameLoad()",
                    	src: url
					},
                	autoScroll:true,
                	border: false
 				}]
			});
			
			initSearchText(onSearchTextChange);
			
			currentDatas = datas;
			doSearchTextChange();
		});
		
		function doSearchTextChange(){
			var st = $(".e8_searchText").val();
			onSearchTextChange(st);
		}
		
		var srarchData;
		function onSearchTextChange(text){
			text = text.toLowerCase();
			if(text == ""){
				srarchData = currentDatas;
			}else{
				srarchData = [];
				for(var i = 0; i < currentDatas.length; i++){
					if(currentDatas[i].resourcename.toLowerCase().indexOf(text) != -1 || currentDatas[i].description.toLowerCase().indexOf(text) != -1){
						srarchData.push(currentDatas[i]);
					}
				}
			}
			doPagination(srarchData, pagedDataRender);
			
			$(".e8_left_center .e8_title span").html("<%=treeFieldName%>(" + srarchData.length +")");
		}
		
		function changeRightFrameUrl(id, AElement){
			var $li = $(AElement).parent();
			$li.siblings().removeClass("selected");
			$li.addClass("selected");
			
			customResourceId = id;
			FormmodeUtil.writeCookie(FormModeConstant._CURRENT_RESOURCE, id);
			
			$("#rightFrame").attr("src", "/formmode/setup/customResourceInfo.jsp?id="+id+"&appid=<%=appId%>");
		}
		
		function onPagedCallback(){
			if(customResourceId != null){
				var $currForm = $("#A_" + customResourceId);
				if($currForm.length > 0){
					$currForm.parent().addClass("selected");
				}
			}
		}
		
		function pagedDataRender(data){
			//var subtablecount = data["subtablecount"]=="0" ? "" : "<div class=\"e8_data_subtablecount\">"+data["subtablecount"]+"</div>";
			
			return "<a id=\"A_"+data["id"]+"\" href=\"javascript:void(0);\" onclick=\"javascript:changeRightFrameUrl("+data["id"]+",this);\">" +
						"<div class=\"e8_data_label\">"+data["resourcename"]+"</div>" +
						"<div class=\"e8_data_label2\">"+data["description"]+"</div>" +
						//subtablecount +
					"</a>";
		}
		
		
		function refreshData(){
			var url = "/formmode/setup/customResourceSettingsAction.jsp?operation=getCustomResourceByModeIdWithJSONDetach&appid=<%=appId%>&fmdetachable=<%=fmdetachable%>&subCompanyId=<%=currentSubCompanyId%>";
			FormmodeUtil.doAjaxDataLoad(url, function(formDatas){
				currentDatas = formDatas;
				doSearchTextChange();
			});
		}
		
		function refreshCustomResource(id) {
			changeRightFrameUrl(id);
			refreshData();
		}
		
		function onCreate() {
		    rightMenu.style.visibility = "hidden";
			$("#rightFrame").attr("src","/formmode/setup/customResourceInfo.jsp?appid=<%=appId%>");
		}
		
		function rightFrameLoad(){
			try{
				rightFrame.forPageResize();
			}catch(e){}
		}
	</script>
</head>
<body>
	<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
	<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
	<%
		if(operatelevel>0){
			RCMenu += "{"+SystemEnv.getHtmlLabelName(124939,user.getLanguage())+",javascript:onCreate(),_top} " ;//新建资源面板
			RCMenuHeight += RCMenuHeightStep ;
		}
	%>
	<%@ include file="/formmode/setup/leftPartTemplate.jsp" %>
	
	<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
</body>
<script type="text/javascript">
window.onload = function (){
	changePageMenuDiaplay(1);
}

var menuCount = 0;

var menuTitleArr = ["<%=SystemEnv.getHtmlLabelName(18363, user.getLanguage())%>",//首页
					"<%=SystemEnv.getHtmlLabelName(1258, user.getLanguage())%>",//上一页
					"<%=SystemEnv.getHtmlLabelName(1259, user.getLanguage())%>",//下一页
					"<%=SystemEnv.getHtmlLabelName(18362, user.getLanguage())%>"];//尾页
var pageMenuIndex = [];
function changePageMenuDiaplay(type){
	var rightMenuIframe = document.getElementById("rightMenuIframe");
	var rightMenuWin = rightMenuIframe.contentWindow;
	var menuTable = $(rightMenuWin.document.getElementById("menuTable"));
	if(rightMenuWin.location.href=="about:blank"){
		if(type==1){
			setTimeout(function(){
				changePageMenuDiaplay(1);
			},500);
		}
	}
	if(type==1){
		var index = 0;
		menuTable.children().each(function () {
			if (!jQuery(this).css("display") || jQuery(this).css("display").toLowerCase() != "none") {
				menuCount++;
				var obj = jQuery(this);
				var title = obj.find("button").attr("title");
				if(title){
					for(var i=0;i<menuTitleArr.length;i++){
						if(menuTitleArr[i]==title){
							pageMenuIndex.push(index);
							break;
						}
					}
				}
			}
			index++;
		});
	}
	var st = $(".e8_searchText").val();
	var isshow = true;
	var len = srarchData.length;
	if(st=="") len = currentDatas.length;
	if(len<=10) isshow = false;
	if(isshow){//显示右键菜单  首页    上一页    下一页    尾页
		for(var i=0;i<pageMenuIndex.length;i++){
			showRCMenuItem(pageMenuIndex[i]);
		}
	}else{
		for(var i=0;i<pageMenuIndex.length;i++){
			hiddenRCMenuItem(pageMenuIndex[i]);
		}
	}
}
</script>
</html>
