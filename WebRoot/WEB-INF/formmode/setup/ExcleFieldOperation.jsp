
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="weaver.general.*" %>
<%@page import="net.sf.json.*"%>

<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
  <%
  String id = Util.null2String(request.getParameter("id"));
  String modeid = Util.null2String(request.getParameter("modeid"));
  String formid = Util.null2String(request.getParameter("formid"));
  int field_rownum =  Util.getIntValue(request.getParameter("field_rownum"),0);
  String action = Util.null2String(request.getParameter("action"));
  String selectid = Util.null2String(request.getParameter("selectid"));
  
  String note = Util.null2String(request.getParameter("note"));
  String sql = "";
 
  if(action.equals("getFieldIds")){
	  JSONObject object = new JSONObject();
	  boolean flag = false; 
	  if(id.equals("")){
		  sql = "insert into mode_excelField (modeid,formid,note) values ("+modeid+","+formid+",'"+note+"')"; 
		  rs.executeSql(sql);
		  sql = "select MAX(id) as id from mode_excelField";
		  rs.executeSql(sql);
		  if(rs.next()){
			  id = rs.getString("id");
			  for(int i=0;i<field_rownum;i++){
				  String fieldids = Util.null2String(request.getParameter("fieldids_"+i));
				  String tempselectid = Util.null2String(request.getParameter("selectid_"+i));
				  String selectvalue = Util.null2String(request.getParameter("selectvalue_"+i));
				  if(fieldids.equals("")){
					  continue;
				  }
				  sql = "insert into mode_excelFieldDetail(mainid,fieldid,selectids,selectvalue) values ("+id+",'"+fieldids+"','"+tempselectid+"',"+selectvalue+")"; 
				  rs.executeSql(sql);
				  flag = true;
			  }
			  object.accumulate("id",id);
			  object.accumulate("flag",flag);
		  }
	  }else{
		  sql = "update mode_excelField set note ='"+note+"' where id="+id;
		  rs.executeSql(sql);
		  sql = "delete mode_excelFieldDetail where mainid="+id;
		  rs.executeSql(sql);
		  for(int i=0;i<field_rownum;i++){
			  String fieldids = Util.null2String(request.getParameter("fieldids_"+i));
			  String tempselectid = Util.null2String(request.getParameter("selectid_"+i));
			  String selectvalue = Util.null2String(request.getParameter("selectvalue_"+i));
			  if(fieldids.equals("")){
				  continue;
			  }
			  sql = "insert into mode_excelFieldDetail(mainid,fieldid,selectids,selectvalue) values ("+id+",'"+fieldids+"','"+tempselectid+"',"+selectvalue+")";
			  rs.executeSql(sql);
			  flag = true;
		  }
		  object.accumulate("id",id);
		  object.accumulate("flag",flag);
	  }
	  
	  sql = "select * from mode_DataBatchImport where modeid="+modeid; 
	  rs.executeSql(sql);
	  if(rs.next()){
		    String tempid = rs.getString("id");
		  	sql = "update mode_DataBatchImport set validateid="+id+" where id="+tempid;
		  	rs.executeSql(sql);
	  }else{
			sql = "insert into mode_DataBatchImport (validateid,modeid) values('"+id+"','"+modeid+"')";
			rs.executeSql(sql);
	  } 
	  response.getWriter().write(object.toString());
  } else if(action.equals("getSelectInfo")){
	  JSONObject object = new JSONObject();
	  JSONArray array = new JSONArray();
	  sql = "select * from workflow_SelectItem where fieldid="+selectid;
	  rs.executeSql(sql);
	  while(rs.next()){
		  JSONObject temp = new JSONObject();
		  String label = rs.getString("selectname");
		  String value = rs.getString("selectvalue");
		  temp.accumulate("label",label);
		  temp.accumulate("value",value);
		  array.add(temp);
	  }
	  object.accumulate("info",array);
	  response.getWriter().write(object.toString());
  }else if(action.equals("getSelectId")){
	  formid = request.getParameter("formid");
	  sql = "select a.id,a.detailtable,b.* from workflow_billfield a, htmllabelindex b where a.billid="+formid+" and fieldhtmltype=5 and b.id=a.fieldlabel";	  
	  JSONObject object = new JSONObject();
	  JSONArray array = new JSONArray();
	  rs.executeSql(sql);
	  while(rs.next()){
		  JSONObject temp = new JSONObject();
	      String tempfieldid = rs.getString("id");
	      String templabel = rs.getString("indexdesc");
	      String detailtable = rs.getString("detailtable");
	      if(detailtable != null && !detailtable.equals("")){
	     	templabel = templabel + "(明细"+detailtable.substring(detailtable.length()-1,detailtable.length())+")";
	      }
	      temp.accumulate("tempfieldid",tempfieldid);
		  temp.accumulate("templabel",templabel);
		  array.add(temp);
	   }
	  object.accumulate("info",array);
	  response.getWriter().write(object.toString());
  }else if(action.equals("clearAll")){
	  modeid = request.getParameter("modeid");
	  sql = "select * from mode_excelField where modeid="+modeid;	
	  String mainid = "";
	  rs.executeSql(sql);
	  if(rs.next()){
		  mainid = rs.getString("id");
	  }
	  sql = "update mode_excelField set note='' where modeid="+modeid;
	  rs.executeSql(sql);
	  sql = "delete mode_excelFieldDetail where mainid="+mainid;	
	  rs.executeSql(sql);
	  
  }
  
  %>

