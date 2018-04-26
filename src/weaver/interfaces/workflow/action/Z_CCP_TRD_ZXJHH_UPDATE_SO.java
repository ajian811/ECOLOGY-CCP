package weaver.interfaces.workflow.action;/*
 *CREATE BY chen
 *AT 2018/3/5 0005 11:06
 *IN ECOLOGY开发
 */

import com.weaver.general.BaseBean;
import org.omg.PortableInterceptor.ACTIVE;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.soa.workflow.request.MainTableInfo;
import weaver.soa.workflow.request.RequestInfo;

public class Z_CCP_TRD_ZXJHH_UPDATE_SO extends BaseBean implements Action {
    private RecordSet recordSet=new RecordSet();
    @Override
    public String execute(RequestInfo request) {
        writeLog("进入Z_CCP_TRD_ZXJHH_UPDATE");
        int requestid = Util.getIntValue(request.getRequestid());
        String result=updateTrdZxjhh(requestid);
        if (Action.FAILURE_AND_CONTINUE.equals(result)){
            request.getRequestManager().setMessagecontent("更新提入单的装卸计划失败，请联系管理员");
        }



        return result;
    }
    public String updateTrdZxjhh(int requestid){
        String result=Action.SUCCESS;
        String zxjhh="";
        String trdh="";
        String sql="";
        String id="";
        try {
            sql = "select id,zxjhh from formtable_main_45 where requestid="+requestid;
            writeLog(sql);
            recordSet.execute(sql);
            if (recordSet.next()){
                zxjhh=Util.null2String(recordSet.getString("zxjhh"));
                id=Util.null2String(recordSet.getString("id"));
            }
            sql="select distinct TRDH from formtable_main_45_dt3 where mainid= "+id;
            writeLog(sql);
            recordSet.execute(sql);
            while (recordSet.next()){
                trdh=Util.null2String(recordSet.getString("trdh"));
                sql="update UF_TRDPLDY set zxjhh='"+zxjhh+"' where trdh='"+trdh+"'";
                writeLog(sql);
                recordSet.execute(sql);
            }


        }catch (Exception e){
            e.printStackTrace();
            result=Action.FAILURE_AND_CONTINUE;
        }

        return result;
    }
}
