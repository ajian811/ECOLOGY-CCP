
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="net.sf.json.JSONArray"%>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>
<%@page import="weaver.hrm.User"%>
<%@page import="weaver.hrm.HrmUserVarify"%>
<%@page import="weaver.formmode.service.RemindJobService"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="weaver.formmode.task.RemindDataService"%>
<%@page import="weaver.formmode.task.TaskService"%>
<%@page import="weaver.systeminfo.systemright.CheckSubCompanyRight"%>
<%@page import="weaver.formmode.virtualform.VirtualFormHandler"%>
<%@ page import="weaver.systeminfo.SystemEnv"%>
<%@ page import="org.jdom.Document"%>
<%@ page import="weaver.servicefiles.ResetXMLFileCache"%>

<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="ScheduleXML" class="weaver.servicefiles.ScheduleXML" scope="page" />
<%
out.clear();
User user = HrmUserVarify.getUser (request , response) ;
if(!HrmUserVarify.checkUserRight("FORMMODEAPP:All", user)){
	response.sendRedirect("/notice/noright.jsp");
	return;
}
String operation = Util.null2String(request.getParameter("operation"));

RemindJobService remindJobService = new RemindJobService();
TaskService taskService = new TaskService();
if(operation.equals("saveorupdate")) {
	String conditionssql = Util.null2String(request.getParameter("conditionssql"));
	request.setAttribute("conditionssql",conditionssql);
	String id = remindJobService.saveOrUpdate(request,user);
	request.setAttribute("id",id);
	taskService.doAction(request);
	response.getWriter().println("<script type=\"text/javascript\">parent.parent.refreshRemindJob("+id+");</script>");
} else if(operation.equals("delete")) {
  	int id = Util.getIntValue(request.getParameter("id"));
  	taskService.doAction(request);
  	remindJobService.delete(id);
  	String appid = request.getParameter("appid");
	List<Map<String,Object>> dataList = remindJobService.getRemindJobByModeIds(Util.getIntValue(appid));
	
	String firstId = "";
	if (dataList != null && dataList.size() > 0) 
		firstId = Util.null2String(((Map<String,Object>)dataList.get(0)).get("id"));
	response.getWriter().println("<script type=\"text/javascript\">parent.parent.refreshRemindJob("+firstId+");</script>");
}else if(operation.equals("getRemindJobByModeIdWithJSON")){
	int appId = Util.getIntValue(request.getParameter("appid"));
	int fmdetachable = Util.getIntValue(request.getParameter("fmdetachable"));
	int subCompanyId = Util.getIntValue(request.getParameter("subCompanyId"));
	JSONArray remindJobArr = new JSONArray();
	if(fmdetachable==1){
		remindJobArr = remindJobService.getRemindJobByModeIdWithJSONDetach(appId,user.getLanguage(),subCompanyId);
	}else{
		remindJobArr = remindJobService.getRemindJobByModeIdWithJSON(appId,user.getLanguage());
	}
	out.print(remindJobArr.toString());
	out.flush();
	out.close();
	return;
}else if(operation.equals("getModesByFormId")){
	String fmdetachable = Util.null2String(request.getParameter("fmdetachable"));
	String subCompanyId = Util.null2String(request.getParameter("subCompanyId"));
	String formid = Util.null2String(request.getParameter("formid"));
	String remindtype = Util.null2String(request.getParameter("remindtype"));
	String formtype = Util.null2String(request.getParameter("formtype"));
	String sql = "select id,modename from modeinfo where isdelete=0 and formid="+formid;
	if(fmdetachable.equals("1")){
      	CheckSubCompanyRight mSubRight = new CheckSubCompanyRight();
		int[] mSubCom = mSubRight.getSubComByUserRightId(user.getUID(),"ModeSetting:All",0);
		String subCompanyIds = "";
		for(int i=0;i<mSubCom.length;i++){
			if(i==0){
				subCompanyIds += ""+mSubCom[i];
			}else{
				subCompanyIds += ","+mSubCom[i];
			}
		}
		if(subCompanyIds.equals("")){
			sql+= " and 1=2 ";
		}else{
			sql+= " and subCompanyId in ("+subCompanyIds+") ";
		}
  }
	rs.executeSql(sql);
	String datype = rs.getDBType();
	JSONObject resultObject = new JSONObject();
	JSONArray jsonArray = new JSONArray();
	while(rs.next()){
		JSONObject jsonObject = new JSONObject();
		String id = rs.getString("id");
		String modename = rs.getString("modename");
		jsonObject.put("value",id);
		jsonObject.put("text",modename);
		jsonArray.add(jsonObject);
	}	
	if(datype.equals("sqlserver")){
		sql = "select a.fieldname,b.indexdesc,a.detailtable from workflow_billfield a,htmllabelindex b where  a.billid="+formid+" and  a.fieldhtmltype not in (6,7)  and a.fieldlabel=b.id order by detailtable ";
	}else{
		sql = "select a.fieldname,b.indexdesc,a.detailtable from workflow_billfield a,htmllabelindex b where  a.billid="+formid+" and  a.fieldhtmltype not in (6,7)  and a.fieldlabel=b.id order by detailtable desc";
	}
	
	rs.executeSql(sql);
	JSONArray fieldArray = new JSONArray();
	while(rs.next()){
		JSONObject jsonObject = new JSONObject();
		String id = rs.getString("id");
		String fieldname = rs.getString("fieldname");
		String indexdesc = rs.getString("indexdesc");
		String detailtable = rs.getString("detailtable");
		if(detailtable != null && !detailtable.equals("")){
			String tempdetailtable = detailtable.substring(detailtable.length()-1,detailtable.length());
			if(!formtype.equals(tempdetailtable)){
				continue;
			}
			indexdesc += "("+SystemEnv.getHtmlLabelName(17463,user.getLanguage())+tempdetailtable+")";
			fieldname = detailtable+"."+fieldname;
		}
		jsonObject.put("value",fieldname);
		jsonObject.put("text",indexdesc);
		fieldArray.add(jsonObject);
	}
	resultObject.put("modedata",jsonArray);
	resultObject.put("fielddata",fieldArray);
	out.print(resultObject.toString());
	out.flush();
	out.close();
	return;
}else if(operation.equals("getHrmFieldByFormId")){
	String formid = Util.null2String(request.getParameter("formid"));
	String sql = "select a.id,a.fieldname,b.labelname from workflow_billfield a,HtmlLabelInfo b where a.billid="+formid+" and a.fieldlabel=b.indexid and b.languageid=7 and a.fieldhtmltype=3 and a.type=1 and a.detailtable='' order by a.id";
	rs.executeSql(sql);
	JSONArray jsonArray = new JSONArray();
	while(rs.next()){
		JSONObject jsonObject = new JSONObject();
		String id = rs.getString("id");
		String fieldname = rs.getString("fieldname");
		String labelname = rs.getString("labelname");
		jsonObject.put("id",id);
		jsonObject.put("fieldname",fieldname);
		jsonObject.put("labelname",labelname);
		jsonArray.add(jsonObject);
	}
	out.print(jsonArray.toString());
	out.flush();
	out.close();
	return;
}else if(operation.equals("initRemindData")){
	int id = Util.getIntValue(request.getParameter("id"));
	RemindDataService remindDataService = new RemindDataService();
	remindDataService.setAction("init");
	remindDataService.setRemindid(id);
	Thread remindThread = new Thread(remindDataService);
	remindThread.start();
	out.print(SystemEnv.getHtmlLabelName(82254,user.getLanguage()));//后台正在重构数据......
	out.flush();
	out.close();
	return;
}else if(operation.equals("changeFormType")){
	String formid = Util.null2String(request.getParameter("formid"));
	String sql = "select detailtable from workflow_billfield where billid = "+formid+" group by detailtable";
	rs.executeSql(sql);
	JSONArray jsonArray = new JSONArray();
	while(rs.next()){
		JSONObject jsonObject = new JSONObject();
		String detailtable = rs.getString("detailtable");
		if(detailtable.length() > 0){
			jsonObject.put("detailtable",detailtable.substring(detailtable.length()-1,detailtable.length()));
		}else{
			jsonObject.put("detailtable",detailtable);
		}
		jsonArray.add(jsonObject);
	}
	out.print(jsonArray.toString());
	out.flush();
	out.close();
	return;
}else if(operation.equals("getHrmField")){
	int formid = Util.getIntValue(request.getParameter("formid"), 0);
	String formtype = Util.null2String(request.getParameter("formtype"));
	String sql = "select a.id,a.fieldname,b.labelname,a.detailtable from workflow_billfield a,HtmlLabelInfo b where a.billid="+formid+" and a.fieldlabel=b.indexid and b.languageid=7 and a.fieldhtmltype=3 and a.type=1 order by a.id asc,detailtable asc";
	rs.executeSql(sql);
	JSONArray fieldArray = new JSONArray();
	while(rs.next()){
		JSONObject jsonObject = new JSONObject();
		String fieldid = rs.getString("id");
		String labelname = rs.getString("labelname");
		String detailtable = rs.getString("detailtable");
		if(detailtable != null && !detailtable.equals("")){
			if(detailtable.substring(detailtable.length()-1,detailtable.length()).equals(formtype)){
				labelname += "(明细"+formtype+")";
			}else{
				continue;
			}
		}
		jsonObject.put("value",fieldid);
		jsonObject.put("text",labelname);
		fieldArray.add(jsonObject);
	}
	out.print(fieldArray.toString());
	out.flush();
	out.close();
	return;
}
%>