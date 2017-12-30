
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="weaver.file.*," %>
<%@page import="com.weaver.formmodel.util.StringHelper"%>
<jsp:useBean id="ExcelFile" class="weaver.file.ExcelFile" scope="session"/>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page"/>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="RequestDetailImport" class="weaver.workflow.request.RequestDetailImport" scope="page"/>
<jsp:useBean id="FieldInfo" class="weaver.formmode.data.FieldInfo" scope="page"/>
<HTML>
<HEAD>
    <LINK REL=stylesheet type=text/css HREF=/css/Weaver_wev8.css>
    <link href="/formmode/css/formmode_wev8.css" type="text/css" rel="stylesheet" />
    <SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
    <script>
    var parentWin = null;
	var dialog = null;
	try{
		parentWin = parent.parent.getParentWindow(parent);
		dialog = parent.parent.getDialog(parent);
	}catch(e){}
    </script>
</HEAD>
<body>
<%
    String imagefilename = "/images/hdMaintenance_wev8.gif";
    String titlename = SystemEnv.getHtmlLabelName(26255, user.getLanguage());//明细导入
    String needfav = "";
    String needhelp = "";
    
    int modeId = Util.getIntValue(request.getParameter("modeId"),0);
    int billid = Util.getIntValue(request.getParameter("billid"),0);
    String modename = "";
    int formId = 0;
    if(modeId > 0){
    	rs.executeSql("select * from modeinfo where Id="+modeId);
    	if(rs.next()){
    		formId = rs.getInt("formid");
    		modename = Util.null2String(rs.getString("modename"));
    		
    		ArrayList editfields=new ArrayList();//可编辑字段
    		
    		rs.executeSql("select fieldid from modeformfield where modeid="+modeId+" and type=2 and isedit=1");
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
            
            FieldInfo.setUser(user);
            FieldInfo.GetDetailTableField(formId, 1, user.getLanguage());
            ArrayList detailtablefieldlables=FieldInfo.getDetailTableFieldNames();
            ArrayList detailtablefieldids=FieldInfo.getDetailTableFields();
            for(int i=0;i<detailtablefieldlables.size();i++){
                es = new ExcelSheet() ;   // 初始化一个EXCEL的sheet对象
                ExcelRow er = es.newExcelRow () ;  //准备新增EXCEL中的一行
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
                	
                    if(editfields.indexOf((String)Util.TokenizerString((String)detailfieldids.get(j),"_").get(0))<0) continue;
                    //以下为EXCEL添加多个列
                    es.addColumnwidth(6000);
                    er.addStringValue((String)detailfieldnames.get(j),"Header");
                    hasfield=true;
                }
                if(hasfield){
                    es.addExcelRow(er) ;   //加入一行
                    ExcelFile.addSheet(SystemEnv.getHtmlLabelName(17463, user.getLanguage())+(i+1), es) ; //为EXCEL文件插入一个SHEET
                }
            }
    	}
    }
%>

<%@ include file="/systeminfo/TopTitle_wev8.jsp" %>
<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>
<%
    RCMenu += "{" + SystemEnv.getHtmlLabelName(26255, user.getLanguage()) + ",javascript:onSave(this),_self} ";//明细导入
    RCMenuHeight += RCMenuHeightStep;

    RCMenu += "{" + SystemEnv.getHtmlLabelName(309, user.getLanguage()) + ",javascript:onClose(),_self} ";//关闭
    RCMenuHeight += RCMenuHeightStep;
%>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>

<div id="content">
	<iframe id="ExcelOut" name="ExcelOut" border=0 frameborder=no noresize=NORESIZE height="0px" width="0px"></iframe>
	<form name="detailimportform" method="post" action="ModeDetailImportOperation.jsp" enctype="multipart/form-data">
		<input type=hidden name="modeId" value="<%=modeId%>">
		<input type=hidden name="formId" value="<%=formId%>">
		<input type=hidden name="billid" value="<%=billid%>">
		<input type="hidden" value="save" name="src">
	<TABLE class="e8_tblForm" id="freewfoTable">
		<TBODY>
		<TR>
			<td class="e8_tblForm_label" width="20%">
				1、<%=SystemEnv.getHtmlLabelName(258, user.getLanguage())%><%=SystemEnv.getHtmlLabelName(64, user.getLanguage())%>
			</td>
			<!-- 下载模板(TODO) -->	
			<td class="e8_tblForm_field">
				<a href="/weaver/weaver.file.ExcelOut" style="color:blue;"><%=modename%></a>
			</td>
		</TR>
		<TR>
			<td class="e8_tblForm_label" width="20%">
				2、<%=SystemEnv.getHtmlLabelName(16630, user.getLanguage())%>
			</td>
			<!-- 上传Excel -->	
			<td class="e8_tblForm_field">
				<input type="file" name="excelfile" size="35">
			</td>
		</TR>
		<TR>
			<TD colspan="2" style="">
				<!-- 
					操作步骤
					1)请先下载 进行填写导入明细内容，第一行为表单明细字段的名称。
					2)请在第2步中选择填写好的Excel文件，并点击操作菜单中 明细导入
					使用注意事项：
					1)导入明细数据时会将原有明细内容删除，导入新的模板中内容。
					2)只有可编辑的字段才能进行导入，如果查看的字段有默认值的会自动加上默认值。
					3)模板中第一行为表单明细字段名称，从第二行开始导入明细数据。
					4)明细数据之间不能有空行。
					5)如果有多个明细时模板中会有多个SHEET，一个明细一个SHEET。
					6)数字类型字段不要有特殊格式，例如：科学计数法，千分位，货币符号等。
					7)浏览类型字段直接输入名称，例如：人力资源字段直接输入人员名称。
					8)check类型字段输入“1/0”或“是/否”。
					9)下拉选择框类型字段输入下拉选择框显示名称。(百分比格式的需要改为文本格式)
					10)日期类型字段导入时模板中需改为日期格式。
					11）人力资源字段支持编号导入，excel模板中的格式为：workcode_具体编号。
					12)导入虚拟部门、分部，数据需已virtual_开头，例如：virtual_泛微
				-->
				<br><b><%=SystemEnv.getHtmlLabelName(27577, user.getLanguage())%>：</b><br>
				1）<%=SystemEnv.getHtmlLabelName(27578, user.getLanguage())%><a href="/weaver/weaver.file.ExcelOut" style="color:blue;"><%=modename%></a><%=SystemEnv.getHtmlLabelName(27579, user.getLanguage())%><br>
				2）<%=SystemEnv.getHtmlLabelName(27580, user.getLanguage())%>“<%=SystemEnv.getHtmlLabelName(26255, user.getLanguage())%>”。<br><br>
				<b><%=SystemEnv.getHtmlLabelName(27581, user.getLanguage())%></b><br>
				1）<%=SystemEnv.getHtmlLabelName(27582, user.getLanguage())%><br>
				2）<%=SystemEnv.getHtmlLabelName(27583, user.getLanguage())%><br>
				3）<%=SystemEnv.getHtmlLabelName(27584, user.getLanguage())%><br>
				4）<%=SystemEnv.getHtmlLabelName(27585, user.getLanguage())%><br>
				5）<%=SystemEnv.getHtmlLabelName(27586, user.getLanguage())%><br>
				6）<%=SystemEnv.getHtmlLabelName(27587, user.getLanguage())%><br>
				7）<%=SystemEnv.getHtmlLabelName(82723, user.getLanguage())%><br>
				8）<%=SystemEnv.getHtmlLabelName(27589, user.getLanguage())%><br>
				9）<%=SystemEnv.getHtmlLabelName(27590, user.getLanguage())%><%=SystemEnv.getHtmlLabelName(126300, user.getLanguage())%><br>
				10）<%=SystemEnv.getHtmlLabelName(126320, user.getLanguage())%><br>
				11）<%=SystemEnv.getHtmlLabelName(126429, user.getLanguage())%><br>
				12）<span style="color:red;font-weight:bold;Letter-spacing:1px;"><%=SystemEnv.getHtmlLabelName(126435, user.getLanguage())%></span><br>
			</TD>
		</TR>
		</TBODY>
	</TABLE>
</form>					
</div>

<script language=javascript>
	function onSave(obj) {
        var fileName=$G("excelfile").value;
		if(fileName!=""&&fileName.length>4){
			if(fileName.substring(fileName.length-4).toLowerCase()!=".xls"){
				alert('<%=SystemEnv.getHtmlLabelName(31460,user.getLanguage())%>');//必须上传.xls格式的文件
				return;
			}
			$G("detailimportform").submit();//上传文件
            obj.disabled=true;
		}else{
            alert('<%=SystemEnv.getHtmlLabelName(20890,user.getLanguage())%>');//必须上传Excel格式的文件
        }
    }

    function onClose() {
        window.parent.close();
    }
</script>
</body>
</html>
