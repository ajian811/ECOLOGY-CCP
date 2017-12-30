
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.*" %>
<%@page import="weaver.formmode.service.LogService"%>
<%@page import="weaver.formmode.Module"%>
<%@page import="weaver.formmode.log.LogType"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="RecordSetTrans" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ModeSetUtil" class="weaver.formmode.setup.ModeSetUtil" scope="page" />
<jsp:useBean id="modeLinkageInfo" class="weaver.formmode.setup.ModeLinkageInfo" scope="page" />
<html>
  <head>
  </head>
  <body>
  <%
	if (!HrmUserVarify.checkUserRight("ModeSetting:All", user)) {
		response.sendRedirect("/notice/noright.jsp");
		return;
	}
  %>
  <%
  String operate = Util.null2String(request.getParameter("operate"));
  String modeId = Util.null2String(request.getParameter("modeId"));
  String modeName = Util.null2String(request.getParameter("modeName"));
  String modeDesc = Util.null2String(request.getParameter("modeDesc"));
  String typeId = Util.null2String(request.getParameter("typeId"));
  String formId = Util.null2String(request.getParameter("formId"));
  String maincategory = Util.null2String(request.getParameter("maincategory"));
  String subcategory = Util.null2String(request.getParameter("subcategory"));
  String seccategory = Util.null2String(request.getParameter("seccategory"));
  String isImportDetail = Util.null2String(request.getParameter("isImportDetail"));
  String DefaultShared = Util.null2String(request.getParameter("DefaultShared"));
  String NonDefaultShared = Util.null2String(request.getParameter("NonDefaultShared"));
  double dsporder = Util.getDoubleValue(request.getParameter("dsporder"));
  int subCompanyId = Util.getIntValue(request.getParameter("subCompanyId"),-1);
  int isAllowReply = Util.getIntValue(request.getParameter("isAllowReply"),0);
  String customerValue = Util.null2String(request.getParameter("customerValue"));
  
  int selectcategory = Util.getIntValue(request.getParameter("selectcategory"),0);
  int categorytype = Util.getIntValue(request.getParameter("categorytype"),0);
  if(categorytype==0){
  	selectcategory=0;
  }
  String isloadleft = "0";
  String sql = "";
  
  LogService logService = new LogService();
  logService.setUser(user);
  if(operate.equals("AddMode")){	//新增模板
	  
	  if(subCompanyId==-1||subCompanyId==0){//分权分部的取得。如果页面没有，则首先从分权设置的默认机构取得，如果默认机构没有设置则取所有分部中id最小的那个分部。
	  		RecordSetTrans.executeSql("select fmdftsubcomid,dftsubcomid from SystemSet");
	  		if(RecordSetTrans.next()){
	  			subCompanyId = Util.getIntValue(RecordSetTrans.getString("fmdftsubcomid"),-1);
	  			if(subCompanyId==-1||subCompanyId==0){
		  			subCompanyId = Util.getIntValue(RecordSetTrans.getString("dftsubcomid"),-1);
	  			}
	  		}
	  		if(subCompanyId==-1||subCompanyId==0){
	  			RecordSetTrans.executeSql("select min(id) as id from HrmSubCompany");
	  			if(RecordSetTrans.next()) subCompanyId = RecordSetTrans.getInt("id");
	  		}
	  	}
  
	  ModeSetUtil.setFormId(Util.getIntValue(formId,0));
	  ModeSetUtil.setTypeId(typeId);
	  ModeSetUtil.setModeName(modeName);
	  ModeSetUtil.setModeDesc(modeDesc);
	  ModeSetUtil.setMaincategory(maincategory);
	  ModeSetUtil.setSubcategory(subcategory);
	  ModeSetUtil.setSeccategory(seccategory);
	  ModeSetUtil.setIsImportDetail(isImportDetail);
	  ModeSetUtil.setDefaultShared(DefaultShared);
	  ModeSetUtil.setNonDefaultShared(NonDefaultShared);
	  ModeSetUtil.setDsporder(dsporder);
	  ModeSetUtil.setUser(user);
	  ModeSetUtil.setSubCompanyId(subCompanyId);
	  ModeSetUtil.setCategorytype(categorytype);
	  ModeSetUtil.setSelectcategory(selectcategory);
	  ModeSetUtil.addMode();
	  modeId = String.valueOf(ModeSetUtil.getModeId());
	  isloadleft = "1";
	  response.getWriter().println("<script type=\"text/javascript\">parent.parent.refreshModeOperation("+modeId+");</script>");
	  return;
	  
  }else if(operate.equals("EditMode")){	//编辑模板
	  ModeSetUtil.setFormId(Util.getIntValue(formId,0));
	  ModeSetUtil.setModeName(modeName);
	  ModeSetUtil.setModeDesc(modeDesc);
	  ModeSetUtil.setTypeId(typeId);
	  ModeSetUtil.setModeId(Util.getIntValue(modeId,0));
	  ModeSetUtil.setMaincategory(maincategory);
	  ModeSetUtil.setSubcategory(subcategory);
	  ModeSetUtil.setSeccategory(seccategory);
	  ModeSetUtil.setIsImportDetail(isImportDetail);
	  ModeSetUtil.setDefaultShared(DefaultShared);
	  ModeSetUtil.setNonDefaultShared(NonDefaultShared);
	  ModeSetUtil.setDsporder(dsporder);
	  ModeSetUtil.setIsAllowReply(isAllowReply);
	  ModeSetUtil.setSubCompanyId(subCompanyId);
	  ModeSetUtil.setCategorytype(categorytype);
	  ModeSetUtil.setSelectcategory(selectcategory);
	  ModeSetUtil.editMode();
	  
	  ModeSetUtil.setRequest(request);
	  ModeSetUtil.setUser(user);
	  ModeSetUtil.saveModesHtml();
	  
	  isloadleft = "1";
	  logService.log(modeId, Module.MODEL, LogType.EDIT);
	  response.getWriter().println("<script type=\"text/javascript\">parent.parent.refreshModeOperation("+modeId+");</script>");
	  return;
  }else if(operate.equals("DefaultValue")){
	  String selfieldId[] = Util.null2String(request.getParameter("fieldid")).split("_");
	  int fieldId = 0;
	  if(selfieldId.length>1) fieldId = Util.getIntValue(selfieldId[1],0);
	  
	  ModeSetUtil.setModeId(Util.getIntValue(modeId,0));
	  ModeSetUtil.setFormId(Util.getIntValue(formId,0));
	  ModeSetUtil.setFieldId(fieldId);
	  ModeSetUtil.setCustomerValue(customerValue);
	  ModeSetUtil.saveDefualtValue();
	  response.sendRedirect("/formmode/setup/modelDefaultValue.jsp?ajax=1&modeId="+modeId);
	  return;
  }else if(operate.equals("delDefaultValue")){
	  String selfieldId[] = request.getParameterValues("check_mode");
	  ModeSetUtil.setDefaultValueId(selfieldId);
	  ModeSetUtil.deleteDefualtValue();
	  response.sendRedirect("/formmode/setup/modelDefaultValue.jsp?ajax=1&modeId="+modeId);
	  return;
  }else if(operate.equals("linkageattr")){
	 
	  modeLinkageInfo.setModeId(Util.getIntValue(modeId,0));
	 
	  boolean fly = modeLinkageInfo.LinkageSave(request);
	  
	  response.sendRedirect("/formmode/setup/modelLinkage.jsp?ajax=1&modeId="+modeId);
	  return;
  }
  response.sendRedirect("/formmode/setup/modelAdd.jsp?ajax=1&modeId="+modeId+"&typeId="+typeId+"&isloadleft="+isloadleft);
  %>
  </body>
</html>
