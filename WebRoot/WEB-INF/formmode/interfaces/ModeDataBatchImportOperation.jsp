
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.Util,java.net.*"%>
<%@ page import="weaver.file.FileUploadToPath" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ModeDataBatchImport" class="weaver.formmode.interfaces.ModeDataBatchImport" scope="page"/>
<jsp:useBean id="ModeRightInfo" class="weaver.formmode.setup.ModeRightInfo" scope="page" />
<%
    FileUploadToPath fu = new FileUploadToPath(request);
	String clientaddress = request.getRemoteAddr();
	int modeid = Util.getIntValue(fu.getParameter("modeid"),0);
	int pageexpandid = Util.getIntValue(fu.getParameter("pageexpandid"));
	String method = Util.null2String(fu.getParameter("method"));
	int sourcetype = Util.getIntValue(fu.getParameter("sourcetype"),0);
	String flag = "";
	if ("import".equals(method)) {
		int type = 4;//批量导入权限
		if(type == 4){//监控权限判断
			ModeRightInfo.setModeId(modeid);
			ModeRightInfo.setType(type);
			ModeRightInfo.setUser(user);
			boolean isRight = false;
			isRight = ModeRightInfo.checkUserRight(type);
			if(!isRight){
				if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
					response.sendRedirect("/notice/noright.jsp");
					return;
				}
			}
		}
		ModeDataBatchImport.setClientaddress(clientaddress);
		ModeDataBatchImport.setUser(user);
		
	    String msg=ModeDataBatchImport.ImportData(fu,user);
	    flag = System.currentTimeMillis() + "_DataBatchImport";
	    session.setAttribute(flag,msg);
	} else if ("save".equals(method)) {
		String interfacePath = Util.null2String(fu.getParameter("interfacePath"));
		String isUse = Util.null2String(fu.getParameter("isUse"));
		String validateid = Util.null2String(fu.getParameter("importValidationId"));
		rs.executeSql("delete mode_DataBatchImport where modeid="+modeid);
		rs.executeSql("insert into mode_DataBatchImport(modeid,interfacepath,isuse,validateid) values("+modeid+",'"+interfacePath+"','"+isUse+"','"+validateid+"')");
	}
	response.sendRedirect("/formmode/interfaces/ModeDataBatchImport.jsp?modeid="+modeid+"&flag="+flag+"&pageexpandid="+pageexpandid+"&sourcetype="+sourcetype);
%>