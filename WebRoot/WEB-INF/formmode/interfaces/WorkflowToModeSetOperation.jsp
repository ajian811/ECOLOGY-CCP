<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@page import="weaver.workflow.action.WorkflowActionManager"%>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="java.util.*" %>

<jsp:useBean id="RecordSet" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="rs" class="weaver.conn.RecordSet" scope="page" />
<jsp:useBean id="WorkflowComInfo" class="weaver.workflow.workflow.WorkflowComInfo" scope="page" />
<%
if(!HrmUserVarify.checkUserRight("ModeSetting:All", user)){
	response.sendRedirect("/notice/noright.jsp");
	return;
}

String operation = Util.null2String(request.getParameter("operation"));
char separator = Util.getSeparator() ;
String sql = "";

int workflowid = Util.getIntValue(request.getParameter("workflowid"),0);
int modeid = Util.getIntValue(request.getParameter("modeid"),0);
int id = Util.getIntValue(request.getParameter("id"),0);
int modecreater = Util.getIntValue(request.getParameter("modecreater"),0);
int modecreaterfieldid = Util.getIntValue(request.getParameter("modecreaterfieldid"),0);
int detailno = Util.getIntValue(request.getParameter("detailno"),0);
int triggerNodeId = Util.getIntValue(request.getParameter("triggerNodeId"),0);
int triggerType = Util.getIntValue(request.getParameter("triggerType"),0);
int isenable = Util.getIntValue(request.getParameter("isenable"),0);
String formtype =  Util.null2String(request.getParameter("formtype"),"maintable");
int tempid = id;
String isnode = "1";
String type = "2";

int initworkflowid = Util.getIntValue(request.getParameter("initworkflowid"),0);
int initmodeid = Util.getIntValue(request.getParameter("initmodeid"),0);
int actionid = Util.getIntValue(request.getParameter("actionid"),0);

String maintableopttype = Util.null2String(request.getParameter("maintableopttype"),"1");
String maintableupdatecondition = Util.null2String(request.getParameter("maintableupdatecondition")).trim();
if("1".equals(maintableopttype)){//如果是插入，则清空更新条件
	maintableupdatecondition = "";
}else{
	maintableupdatecondition = Util.fromScreen(maintableupdatecondition,user.getLanguage());
}

//先删除数据再重新保存
if (operation.equals("save")) {
	String customervalue = "action.WorkflowToMode";//通过action，使流程的数据转为卡片数据
	if(modecreater!=3){
		modecreaterfieldid = 0;
	}
	
	if(id>0){//编辑
		
		//删除老的action
		int oldworkflowid = 0;
		int oldtriggerNodeId = 0;
		int oldtriggerType = 0;
		int oldisenable = 0;
		
		sql = "select * from mode_workflowtomodeset where id = " + id;
		rs.executeSql(sql);
		while(rs.next()){
			oldworkflowid = rs.getInt("workflowid");
			oldtriggerNodeId  = rs.getInt("triggerNodeId");
			oldtriggerType  = rs.getInt("triggerType");
			oldisenable  = rs.getInt("isenable");
		}
		
		/*在workflowActionManager对应的方法中处理----所以此处注释掉 
		if(oldisenable==1){//是否被启用
			sql = "select id,wftomodesetid from workflow_addinoperate where objid = "+oldtriggerNodeId+" and ispreadd = '"+oldtriggerType+"' and isnode = "+isnode+" and workflowid = "+oldworkflowid+" and type = "+type;
			rs.executeSql(sql);
			//new weaver.general.BaseBean().writeLog(sql);
			while(rs.next()){
				int _id = rs.getInt("id");//
				String _wftomodesetid = Util.null2String(rs.getString("wftomodesetid"));//
				_wftomodesetid = ","+_wftomodesetid+",";
				_wftomodesetid = _wftomodesetid.replace(","+id+",","");
				if(_wftomodesetid.replace(",","").equals("")){
					sql = "delete from workflow_addinoperate where id = " + _id;
				}else{
					if(_wftomodesetid.startsWith(",")){
						_wftomodesetid = _wftomodesetid.substring(1);
					}
					if(_wftomodesetid.endsWith(",")){
						_wftomodesetid = _wftomodesetid.substring(0,_wftomodesetid.length()-1);
					}
					sql = "update workflow_addinoperate set wftomodesetid = '"+_wftomodesetid+"' where id = " + _id;
				}
				RecordSet.executeSql(sql);
			}
		}
		*/
				
		//修改数据
		sql = "update mode_workflowtomodeset set isenable = "+isenable+",modeid = "+modeid+",workflowid = "+workflowid+",modecreater = "+modecreater
				+",modecreaterfieldid = "+modecreaterfieldid+",triggerNodeId = "+triggerNodeId+",triggerType = "+triggerType+",formtype='"
				+formtype+"',maintableopttype='"+maintableopttype+"',maintableupdatecondition='"+maintableupdatecondition+"' where id = " + id;
		rs.executeSql(sql);
		
		//删除已经设置好的明细数据
		sql = "delete from mode_workflowtomodesetdetail where mainid = " + id;
		rs.executeSql(sql);
		
        for(int i=0;i<=detailno;i++){
        	String wffieldidvalues[] = request.getParameterValues("wffieldid"+i);
        	String modefieldidvalues[] = request.getParameterValues("modefieldid"+i);
        	
        	if(wffieldidvalues!=null && modefieldidvalues!=null){
        		for(int j=0;j<wffieldidvalues.length;j++){
        			int wffieldidvalue = Util.getIntValue((String)wffieldidvalues[j],0);
        			int modefieldidvalue = Util.getIntValue((String)modefieldidvalues[j],0);
        			
        			sql = "insert into mode_workflowtomodesetdetail (mainid,modefieldid,wffieldid) values ("+id+","+modefieldidvalue+","+wffieldidvalue+")";
        			rs.executeSql(sql);
        		}
        	}
        }
        
        //删除已经设置好的明细表操作方式
        sql ="delete from mode_workflowtomodesetopt where mainid = " + id;
        rs.executeSql(sql);
        
        if(formtype.indexOf("detail")==-1){
        	for(int i=1;i<=detailno;i++){
	        	String detailtablename = Util.null2String(request.getParameter("detailtablename"+i));
	        	String detailtableopttype =Util.null2String(request.getParameter("detailtableopttype"+i));
	        	String detailtableupdatecondition = Util.null2String(request.getParameter("detailtableupdatecondition"+i));
	        	detailtableupdatecondition = Util.fromScreen(detailtableupdatecondition,user.getLanguage());
	        	if("1".equals(maintableopttype)){//如果主表是插入操作，则子表操作条件清空
	        		detailtableopttype = "";
	        		detailtableupdatecondition = "";
	        	}
	        	if(!"3".equals(detailtableopttype)&&!"4".equals(detailtableopttype)){//如果不是更新操作则更新条件清空
	        		detailtableupdatecondition = "";
	        	}
	        	
	        	sql = "insert into mode_workflowtomodesetopt (mainid,detailtablename,opttype,updatecondition) values "
	        			+"("+id+",'"+detailtablename+"','"+detailtableopttype+"','"+detailtableupdatecondition+"')";
	        	rs.executeSql(sql);
	        }
        }
        
        /* 在workflowActionManager对应的方法中处理----所以此处注释掉 
        //如果启用，插入新的数据
		if(isenable==1){//是否被启用
			sql = "select id,wftomodesetid from workflow_addinoperate where objid = "+triggerNodeId+" and ispreadd = '"+triggerType+"' and isnode = "+isnode+" and workflowid = "+workflowid+" and type = "+type;
			rs.executeSql(sql);
			if(rs.getCounts()>0){
				while(rs.next()){
					int _id = rs.getInt("id");//
					String _wftomodesetid = Util.null2String(rs.getString("wftomodesetid"));//
					_wftomodesetid = _wftomodesetid+","+id;
					sql = "update workflow_addinoperate set wftomodesetid = '"+_wftomodesetid+"' where id = " + _id;
					RecordSet.executeSql(sql);
				}
			}else{
				sql = "insert into workflow_addinoperate (objid,isnode,workflowid,customervalue,type,ispreadd,wftomodesetid) values ("+triggerNodeId+","+isnode+","+workflowid+",'"+customervalue+"',"+type+","+triggerType+","+id+")";
				RecordSet.executeSql(sql);
			}
		}
        */
        
        if(actionid>0){
	        int order = 0;
	        sql = "select nodeid,ispreoperator,actionorder from workflowactionset where id="+actionid;
	        RecordSet.executeSql(sql);
	        if(RecordSet.next()){
	        	int nodeid_ = Util.getIntValue(RecordSet.getString("nodeid"),-1);
	        	int ispreoperator_ = Util.getIntValue(RecordSet.getString("ispreoperator"),0);
	        	order = Util.getIntValue(RecordSet.getString("actionorder"),0);
	        	/**workflowActionManager.setActionid(actionid);
	        	workflowActionManager.setWorkflowid(workflowid_);
	        	workflowActionManager.setNodeid(nodeid_);
	        	workflowActionManager.setNodelinkid(nodelinkid_);
	        	workflowActionManager.setIspreoperator(ispreoperator_);
	        	workflowActionManager.doDeleteWsAction();**/
	        	//如果存在，则先将workflow_addinoperate表里面的数据删除掉，这里不通过WorkflowActionManager类删除，因为该类要先删workflowactionset这个表，删了不能做更新
	        	String sql_ = "delete workflow_addinoperate where objid="+nodeid_+" and isnode=1 and type=3 and ispreadd="+ispreoperator_+" and isnewsap=0";
	        	RecordSet.executeSql(sql_);
	        	String actionname = "WorkflowToMode";
	        	WorkflowActionManager workflowActionManager = new WorkflowActionManager();
		        workflowActionManager.setActionid(actionid);//保存
				workflowActionManager.setWorkflowid(workflowid);
				workflowActionManager.setNodeid(triggerNodeId);
				workflowActionManager.setActionorder(order);
				workflowActionManager.setNodelinkid(0);
				workflowActionManager.setIspreoperator(triggerType);
				workflowActionManager.setActionname(actionname);
				workflowActionManager.setInterfaceid(actionname);
				workflowActionManager.setInterfacetype(3);
				workflowActionManager.setIsused(isenable);//是否启用
				
				actionid = workflowActionManager.doSaveWsAction();
	        } else {
	        	String actionname = "WorkflowToMode";
		    	WorkflowActionManager workflowActionManager = new WorkflowActionManager();
		    	workflowActionManager.setActionid(0);//新建
				workflowActionManager.setWorkflowid(workflowid);
				workflowActionManager.setNodeid(triggerNodeId);
				workflowActionManager.setActionorder(0);
				workflowActionManager.setNodelinkid(0);
				workflowActionManager.setIspreoperator(triggerType);
				workflowActionManager.setActionname(actionname);
				workflowActionManager.setInterfaceid(actionname);
				workflowActionManager.setInterfacetype(3);
				workflowActionManager.setIsused(isenable);//是否启用
				
				actionid = workflowActionManager.doSaveWsAction();
	        }
        } else if (actionid == -1) {
        	String actionname = "WorkflowToMode";
		    WorkflowActionManager workflowActionManager = new WorkflowActionManager();
		    workflowActionManager.setActionid(0);//新建
			workflowActionManager.setWorkflowid(workflowid);
			workflowActionManager.setNodeid(triggerNodeId);
			workflowActionManager.setActionorder(0);
			workflowActionManager.setNodelinkid(0);
			workflowActionManager.setIspreoperator(triggerType);
			workflowActionManager.setActionname(actionname);
			workflowActionManager.setInterfaceid(actionname);
			workflowActionManager.setInterfacetype(3);
			workflowActionManager.setIsused(isenable);//是否启用
				
			actionid = workflowActionManager.doSaveWsAction();
        }
        //修改主表action字段
		sql = "update mode_workflowtomodeset set actionid = " + actionid + " where id = " + id;
        rs.executeSql(sql);
	} else {//新建
    	String actionname = "WorkflowToMode";
        WorkflowActionManager workflowActionManager = new WorkflowActionManager();
        workflowActionManager.setActionid(0);//新建
		workflowActionManager.setWorkflowid(workflowid);
		workflowActionManager.setNodeid(triggerNodeId);
		workflowActionManager.setActionorder(0);
		workflowActionManager.setNodelinkid(0);
		workflowActionManager.setIspreoperator(triggerType);
		workflowActionManager.setActionname(actionname);
		workflowActionManager.setInterfaceid(actionname);
		workflowActionManager.setInterfacetype(3);
		workflowActionManager.setIsused(0);//新建未启用
		
		actionid = workflowActionManager.doSaveWsAction();
		
		//插入主表数据
        sql = "insert into mode_workflowtomodeset(modeid,workflowid,modecreater,modecreaterfieldid,triggerNodeId,triggerType,isenable,formtype,actionid) values ("+modeid+","+workflowid+","+modecreater+","+modecreaterfieldid+","+triggerNodeId+","+triggerType+","+isenable+",'"+formtype+"',"+actionid+")";
        rs.executeSql(sql);
        
        //查询id
        sql = "select max(id) id from mode_workflowtomodeset where modeid = " + modeid + " and workflowid = " + workflowid + " and modecreater = " + modecreater + " and modecreaterfieldid = " +modecreaterfieldid;
        rs.executeSql(sql);
        while(rs.next()){
        	id = rs.getInt("id");
        }
        
		//新建的时候，如果明细和主表用的为同一个表单，则初始化字段的对应关系
       	int modeformid = 0;
       	int wfformid = 0;
       	wfformid = Util.getIntValue(WorkflowComInfo.getFormId(String.valueOf(workflowid)));
   		sql = "select modename,formid from modeinfo where id = " + modeid;
   		rs.executeSql(sql);
   		while(rs.next()){
   			modeformid = rs.getInt("formid");
   		}
   		if(wfformid==modeformid&&wfformid!=0){
         	sql = "insert into mode_workflowtomodesetdetail (mainid,modefieldid,wffieldid) select " + id + ",id,id from workflow_billfield where billid = " + wfformid;
			rs.executeSql(sql);
   		}
    }
	response.sendRedirect("/formmode/interfaces/WorkflowToModeSet.jsp?initworkflowid="+initworkflowid+"&initmodeid="+initmodeid+"&id="+id);
}else if (operation.equals("del")) {
	//删除已经设置的action
	int oldworkflowid = 0;
	int oldtriggerNodeId = 0;
	int oldtriggerType = 0;
	int oldisenable = 0;
	
	sql = "select * from mode_workflowtomodeset where id = " + id;
	rs.executeSql(sql);
	while(rs.next()){
		oldworkflowid = rs.getInt("workflowid");
		oldtriggerNodeId  = rs.getInt("triggerNodeId");
		oldtriggerType  = rs.getInt("triggerType");
		oldisenable  = rs.getInt("isenable");
	}
	
	/* 在workflowActionManager对应的方法中处理 ----所以此处注释掉 
	if(oldisenable==1){//是否被启用
		sql = "select id,wftomodesetid from workflow_addinoperate where objid = "+oldtriggerNodeId+" and ispreadd = '"+oldtriggerType+"' and isnode = "+isnode+" and workflowid = "+oldworkflowid+" and type = "+type;
		rs.executeSql(sql);
		while(rs.next()){
			int _id = rs.getInt("id");//
			String _wftomodesetid = Util.null2String(rs.getString("wftomodesetid"));//
			_wftomodesetid = ","+_wftomodesetid+",";
			_wftomodesetid = _wftomodesetid.replace(","+id+",","");
			if(_wftomodesetid.replace(",","").equals("")){
				sql = "delete from workflow_addinoperate where id = " + _id;
			}else{
				if(_wftomodesetid.startsWith(",")){
					_wftomodesetid = _wftomodesetid.substring(1);
				}
				if(_wftomodesetid.endsWith(",")){
					_wftomodesetid = _wftomodesetid.substring(0,_wftomodesetid.length()-1);
				}
				sql = "update workflow_addinoperate set wftomodesetid = '"+_wftomodesetid+"' where id = " + _id;
			}
			RecordSet.executeSql(sql);
		}
	}
	*/
	
    //删除主表数据
	sql = "delete from mode_workflowtomodeset where id = " + id;
	rs.executeSql(sql);
	
	//删除明细表更新条件
	sql = "delete from mode_workflowtomodesetopt where mainid = " + id;
	rs.executeSql(sql);

	//删除明细表数据
	sql = "delete from mode_workflowtomodesetdetail where mainid = " + id;
	rs.executeSql(sql);
	if(actionid>0){
		WorkflowActionManager workflowActionManager = new WorkflowActionManager();
		workflowActionManager.doDeleteWsAction(actionid);
	}
	
	response.sendRedirect("/formmode/interfaces/WorkflowToModeList.jsp?workflowid="+initworkflowid+"&modeid="+initmodeid);
}

%>