<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="weaver.general.BaseBean"%>
<%@ page import="weaver.interfaces.workflow.action.CCPService.CalFreightService" %>
<%@ page import="weaver.interfaces.workflow.action.CCPServiceImpl.CalFreightServiceImpl" %>



<%!private CalFreightService calFreightService=new CalFreightServiceImpl();

%>


<%
    /**
     * 分摊运费
     * @author jisuqiang
     * @date 2017-12-06
     */
    BaseBean log = new BaseBean();
    log.writeLog("调用CALC_MAINYF.jsp开始");
    Boolean flag;
    try {
        String zxjhh = request.getParameter("zxjhh");//装卸计划号
        String lx = request.getParameter("lx");//类型 0 so 1 po

            flag=calFreightService.calAllocateFrieght(zxjhh,lx);

        if (flag) {
            request.getRequestDispatcher("/weightJsp/SHORT_LIST.jsp?zxjhh=" + zxjhh + "&lx=" + lx)
                    .forward(request, response);
        } else {
            log.writeLog("调用暂估单页面错误！");
            return;
        }

        out.print("end");
    } catch (Exception e) {
        // TODO: handle exception
        out.write("fail" + e);
        e.printStackTrace();

    }
%>




