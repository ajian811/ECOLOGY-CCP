package weaver.interfaces.workflow.action.CCPServiceImpl;/*
 *CREATE BY chen
 *AT 2018/2/28 0028 14:39
 *IN ECOLOGY开发
 */

import weaver.general.Util;
import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.interfaces.workflow.action.CCPConstant.DCCMPropConstant;
import weaver.interfaces.workflow.action.CCPConstant.DCCMTableNameConstant;
import weaver.interfaces.workflow.action.CCPConstant.ZxjhConstant;
import weaver.interfaces.workflow.action.CCPService.CalFreightService;
import weaver.interfaces.workflow.action.CCPService.ZGDService;
import weaver.interfaces.workflow.action.CCPService.ZXJHService;
import java.util.*;


public class ZGDServiceImpl extends BaseBean implements ZGDService {
    private CalFreightService cf=new CalFreightServiceImpl();
    private RecordSet recordSet=new RecordSet();
    private ZXJHService zxjhService=new ZXJHServiceImpl();
    @Override
    public void calZGDFreight(String zxplanno, String tablename,String zgdid) {
            cf.calFreight(zxplanno,tablename,true,zgdid);
    }

    @Override
    public void calZGDAllocateFrieght(String zxplanno, String djlx) {
        cf.calAllocateFrieght(zxplanno,djlx);

    }

    @Override
    public void updateZGDZyf(String zgdid, Double zyf) {
        StringBuffer sql=new StringBuffer().append("UPDATE "+getPropValue(DCCMPropConstant.ZGDPROP,"tablename")+" set ")
                .append(getPropValue(DCCMPropConstant.ZGDPROP,"wsje")+"="+zyf)
                .append(" where id="+zgdid);
        writeLog(sql.toString());
        recordSet.execute(sql.toString());

    }

    @Override
    public void updateZGDAllocateFrieght(String zgdid, String zxplanno,String tablename) {
        String id=zxjhService.getIdByZxjh(zxplanno,tablename);
        String zxjhDetailName="";
        String propname="";
        String tablename0="";
        String zyfFlag="";

        if (DCCMTableNameConstant.POZXJH.equals(tablename)){
            String sfyg=zxjhService.getSfygBy(id,tablename);
            if(ZxjhConstant.WG.equals(sfyg)){
                zxjhDetailName=DCCMTableNameConstant.POZXJHDETAILNAMEWG;
            }
            if (ZxjhConstant.YG.equals(sfyg)){
                zxjhDetailName=DCCMTableNameConstant.POZXJHDETAILNAMEYG;
            }
            propname=DCCMPropConstant.POZXJHPROP;
        }
        if (DCCMTableNameConstant.SOZXJH.equals(tablename)){
                zxjhDetailName=DCCMTableNameConstant.SOZXJHHDETAILNAMEWG;
                propname=DCCMPropConstant.SOZXJHPROP;
        }
        StringBuffer stringBuffer0=new StringBuffer().append("SELECT ZYF FROM "+tablename)
                .append(" where id="+id);
        writeLog(stringBuffer0.toString());
        recordSet.execute(stringBuffer0.toString());
        String zyf="";
        if (recordSet.next()){
            zyf=Util.null2String(recordSet.getString("zyf"));
        }

        String detailftfy0=getPropValue(propname,"detailftfy");
        StringBuffer stringBuffer=new StringBuffer().append("select "+detailftfy0)
                .append(" from "+zxjhDetailName+" where mainid="+id+" order by id asc");
        writeLog(stringBuffer.toString());
        recordSet.execute(stringBuffer.toString());
        List<String> list=new ArrayList<String>();
        while (recordSet.next()){
            String detailftfy= Util.null2String(recordSet.getString(detailftfy0));
            list.add(detailftfy);

        }
        StringBuffer stringBuffer2=new StringBuffer().append("select id from uf_zgfy_dt1")
                .append(" where mainid="+zgdid+" order by id asc");
        writeLog(stringBuffer2.toString());
        recordSet.execute(stringBuffer2.toString());
        List<String> list2=new ArrayList<String>();
        while (recordSet.next()){
            String id0= Util.null2String(recordSet.getString("id"));
            list2.add(id0);

        }
        if (list.size()==(list2.size()-1)) {

            for (int i = 0; i < list.size(); i++) {
            StringBuffer stringBuffer1=new StringBuffer().append("UPDATE "+DCCMTableNameConstant.ZGDDETAIL)
                    .append(" SET notaxamt="+list.get(i)+" where id="+list2.get(i));
            writeLog(stringBuffer1.toString());
            recordSet.execute(stringBuffer1.toString());

            }
            StringBuffer stringBuffer1=new StringBuffer().append("UPDATE "+DCCMTableNameConstant.ZGDDETAIL)
                    .append(" SET notaxamt="+zyf+" where id="+list2.get(list2.size()-1));
            writeLog(stringBuffer1.toString());
            recordSet.execute(stringBuffer1.toString());

        }
    }

    @Override
    public String getJgdId(String zxjhh, String tablename) {
        return zxjhService.getJgdId(zxjhh, tablename);
    }
}
