<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.conn.RecordSet" %>
<%@page pageEncoding="UTF-8" language="java" contentType="text/html; UTF-8" %>
<jsp:useBean id="log" class="weaver.general.BaseBean" />
<jsp:useBean id="rs"  class="weaver.conn.RecordSet"/>

<%
    log.writeLog("进入updateCBZX.jsp--更新暂估单明细中成本中心为空的，只针对SO理货申请情况");
    String sql="";
    sql="SELECT id,PONO,ORDERITEM,COSTCENTER FROM UF_ZGFY_DT1 where COSTCENTER is null";
    log.writeLog(sql);
    rs.execute(sql);
    String ID="";
    String PONO="";
    String ORDERITEM="";
    String COSTCENTER="";
    while (rs.next()){


            PONO = Util.null2String(rs.getString("PONO"));
            ORDERITEM = Util.null2String(rs.getString("ORDERITEM"));
            ID = Util.null2String(rs.getString("ID"));
            if ((!"".equals(PONO))&&(!"".equals(ORDERITEM))&&(!"".equals(ID))) {
                updateCBZX(PONO, ORDERITEM, ID);
            }


    }
    out.write("success");

%><%!
    private void updateCBZX(String pono, String orderitem, String id) {
        String sql="";
        String COSTCENTER="";
        sql="select COSTCENTER from uf_spghsr where "
                +"SALEORDER='"+pono+"' and ORDERITEM='"+orderitem+"'";
        RecordSet rs=new RecordSet();
        rs.writeLog(sql);
        rs.execute(sql);
        if (rs.next()){
            COSTCENTER=Util.null2String(rs.getString("COSTCENTER"));
        }
        if (!"".equals(COSTCENTER)){
            sql="update UF_ZGFY_DT1 set COSTCENTER='"+COSTCENTER+"' where id="+id;
            rs.writeLog(sql);
            rs.execute(sql);
        }

    }
%>