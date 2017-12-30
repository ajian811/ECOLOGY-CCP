
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.io.File" %>
<%@ page import="weaver.conn.*" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ include file="/formmode/pub_detach.jsp"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<HTML>
<HEAD>
<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
<LINK REL=stylesheet type=text/css HREF=/css/Weaver_wev8.css>
<link href="/formmode/css/formmode_wev8.css" type="text/css" rel="stylesheet" />
</HEAD>
<body>
<%
	if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}

	//============================================删除数据====================================
	String method=Util.null2String(request.getParameter("method"));
	String deletebillid=Util.null2String(request.getParameter("deletebillid"));
	String titlename = SystemEnv.getHtmlLabelName(30091,user.getLanguage());//页面扩展设置
	String layoutname = Util.null2String(request.getParameter("layoutname"));
	String modeid=Util.null2String(request.getParameter("id"));
	int formid = Util.getIntValue(Util.null2String(request.getParameter("formId")));
	
	String sql = "select subCompanyId from modeinfo where id="+modeid;
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
	
	if(method.equals("del")){//删除数据
		String layoutids[] = deletebillid.split(",");
		for(int i=0;i<layoutids.length;i++){
			String id = Util.null2String(layoutids[i]);
			rs.executeSql("delete from modeformfield where layoutid="+id);//删除字段表		
			rs.executeSql("delete from modefieldattr where layoutid="+id);//删除字段属性
			rs.executeSql("select * from modehtmllayout where id="+id);
			String src = "";
			if(rs.next()){
				src = Util.null2String(rs.getString("syspath"));
			}
			try{
				File f = new File(src);
				if (f.exists()) {
					f.delete();
				}
			}catch(Exception e){
			}
			rs.executeSql("delete from modehtmllayout where id="+id);
			rs.executeSql("delete from modeformgroup where id="+id);
		}
	}
	
%>
<BODY>
<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
RCMenu += "{"+SystemEnv.getHtmlLabelName(197,user.getLanguage())+",javaScript:doSearch(),_self} " ;
RCMenuHeight += RCMenuHeightStep ;

if(operatelevel>0){
	//新建布局
	RCMenu += "{"+SystemEnv.getHtmlLabelName(365,user.getLanguage())+SystemEnv.getHtmlLabelName(82134,user.getLanguage())+",javaScript:doAdd(0),_self} " ;//新建显示布局
	RCMenuHeight += RCMenuHeightStep ;
	RCMenu += "{"+SystemEnv.getHtmlLabelName(365,user.getLanguage())+SystemEnv.getHtmlLabelName(82135,user.getLanguage())+",javaScript:doAdd(1),_self} " ;//新建新建布局
	RCMenuHeight += RCMenuHeightStep ;
	RCMenu += "{"+SystemEnv.getHtmlLabelName(365,user.getLanguage())+SystemEnv.getHtmlLabelName(82136,user.getLanguage())+",javaScript:doAdd(2),_self} " ;//新建编辑布局
	RCMenuHeight += RCMenuHeightStep ;
	RCMenu += "{"+SystemEnv.getHtmlLabelName(365,user.getLanguage())+SystemEnv.getHtmlLabelName(82137,user.getLanguage())+",javaScript:doAdd(3),_self} " ;//新建监控布局
	RCMenuHeight += RCMenuHeightStep ;
	RCMenu += "{"+SystemEnv.getHtmlLabelName(365,user.getLanguage())+SystemEnv.getHtmlLabelName(82138,user.getLanguage())+",javaScript:doAdd(4),_self} " ;//新建打印布局
	RCMenuHeight += RCMenuHeightStep ;
}
if(operatelevel>1){
	RCMenu += "{"+SystemEnv.getHtmlLabelName(91,user.getLanguage())+",javaScript:Del(),_self} " ;//删除
	RCMenuHeight += RCMenuHeightStep ;
}
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>

<form name="frmSearch" method="post" action="/formmode/setup/FormModeHtmlList.jsp" onSubmit="return false;">
<input type="hidden" name="id" id="id" value="<%=modeid%>">
<input type="hidden" name="formId" id="formId" value="<%=formid%>">
<table class="e8_tblForm">
<tr>
	<td class="e8_tblForm_label" width="20%">
		<%=SystemEnv.getHtmlLabelName(23731,user.getLanguage())%><!-- 布局名称 -->
	</td>
	<td class="e8_tblForm_field" width="80%">
		<input class="inputstyle" id="layoutname" name="layoutname" type="text" value="<%=layoutname%>" style="width:80%">
	</td>
	
</tr>
</table>
</form>
<br/>

<%
String SqlWhere = " where 1=1";
if(!layoutname.equals("")){
	SqlWhere += " and a.layoutname like '%"+layoutname+"%' ";
}
if(!modeid.equals("")){
	SqlWhere += " and a.modeid = "+modeid+" and a.formid="+formid;
}

String perpage = "10";
String backFields = "a.id,a.modeid,a.formid,a.type,a.layoutname,a.isdefault ";
String sqlFrom = "from modehtmllayout a ";
String orderby = " a.type asc ";

String tableString=""+
	"<table  pagesize=\""+perpage+"\" tabletype=\"checkbox\">"+
		"<sql backfields=\""+backFields+"\" sqlform=\""+sqlFrom+"\" sqlorderby=\""+orderby+"\" sqlprimarykey=\"a.id\" sqlsortway=\"desc\" sqldistinct=\"true\" sqlwhere=\""+Util.toHtmlForSplitPage(SqlWhere)+"\"/>"+
		"<checkboxpopedom showmethod=\"weaver.formmode.interfaces.InterfaceTransmethod.getIscheckbox\" popedompara=\"column:isdefault\"/>"+
			"<head>"+                             //布局名称
				"<col width=\"10%\"  text=\""+SystemEnv.getHtmlLabelName(23731,user.getLanguage())+"\" column=\"layoutname\" orderkey=\"layoutname\" otherpara=\"column:id+column:modeid+column:formid+column:type\" transmethod=\"weaver.formmode.interfaces.InterfaceTransmethod.getLayoutNameUrl\"/>"+
				//布局类型
				"<col width=\"10%\"  text=\""+SystemEnv.getHtmlLabelName(23721,user.getLanguage())+"\" column=\"type\" orderkey=\"type\" otherpara=\""+user.getLanguage()+"\" transmethod=\"weaver.formmode.interfaces.InterfaceTransmethod.getLayoutType\"/>"+
				//是否默认布局
				"<col width=\"10%\"  text=\""+SystemEnv.getHtmlLabelName(82139,user.getLanguage())+"\" column=\"isdefault\" orderkey=\"isdefault\" otherpara=\""+user.getLanguage()+"\" transmethod=\"weaver.formmode.interfaces.InterfaceTransmethod.getIsShow\"/>"+
			"</head>"+
	"</table>";
%>

<wea:SplitPageTag  tableString='<%=tableString%>'  mode="run" isShowTopInfo="true"/>

<script type="text/javascript">
	$(document).ready(function(){//onload事件
		$(".loading", window.parent.document).hide(); //隐藏加载图片
		$("#layoutname").keyup(function(e){
			if(e.keyCode == 13 ){
				doSearch();
			}
		});
	})

    function doSearch(){
        var layoutname = $G("layoutname").value ;
        location.href ="/formmode/setup/FormModeHtmlList.jsp?id=<%=modeid%>&formId=<%=formid%>&layoutname="+layoutname;
        
    }
    function doAdd(type){
        var url = "/formmode/setup/LayoutEdit.jsp?type="+type+"&modeId="+<%=modeid%>+"&formId="+<%=formid%>;
		openFullWindowHaveBar(url);
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
    			$(spanName).html("");
    		}
    	} 
    }
    function Del(){
		var CheckedCheckboxId = _xtable_CheckedCheckboxId();
		if(CheckedCheckboxId!=""){
			window.top.Dialog.confirm("<%=SystemEnv.getHtmlLabelName(33435,user.getLanguage())%>",function(){
				var layoutname = $G("layoutname").value ;
       			location.href ="/formmode/setup/FormModeHtmlList.jsp?id=<%=modeid%>&formId=<%=formid%>&layoutname="+layoutname+"&method=del&deletebillid="+CheckedCheckboxId;
			});
		}else{
			window.top.Dialog.alert("<%=SystemEnv.getHtmlLabelName(20149,user.getLanguage())%>");
			return;
		}
	}
</script>

</BODY>
</HTML>
