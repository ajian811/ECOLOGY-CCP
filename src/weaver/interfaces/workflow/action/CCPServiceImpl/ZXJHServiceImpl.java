package weaver.interfaces.workflow.action.CCPServiceImpl;/*
 *CREATE BY chen
 *AT 2018/2/28 0028 11:19
 *IN ECOLOGY开发
 */

import org.apache.poi.hssf.record.Record;
import weaver.conn.RecordSet;
import weaver.general.BaseBean;
import weaver.general.Util;
import weaver.interfaces.workflow.action.CCPConstant.DCCMPropConstant;
import weaver.interfaces.workflow.action.CCPConstant.DCCMTableNameConstant;
import weaver.interfaces.workflow.action.CCPConstant.JFMSConstant;
import weaver.interfaces.workflow.action.CCPService.ZXJHService;
import weaver.interfaces.workflow.action.CCPUtil.CalUtil;

public class ZXJHServiceImpl extends BaseBean implements ZXJHService {
    private CalUtil calUtil=new CalUtil();
    private RecordSet rs=new RecordSet();

    @Override
    public String getPropByTableName(String tablename) {
        String prop=getPropValue(DCCMPropConstant.DCCMTABLENAMEPROP,tablename);
        return prop;
    }

    @Override
    public String sqlAppend(StringBuffer sql, String tablename) {

        if (DCCMTableNameConstant.SOZXJH.equals(tablename)){
            sql.append(" and requestid is null");
        }
        return sql.toString();
    }

    @Override
    public Double calZyf(Double yf, Double tcyf, Double flx) {
        Double zyf=0.00;//总运费

        /**
         * 总运费计算逻辑
         * 包车：总运费=价格档+同城费用+辅路线费用
         * 计重：总运费=价格档*总净重/1000+辅路线费用+同城费用
         * 计件：总运费=价格档*计划运载量计划+辅路线费用+同城费用
         */
        writeLog("开始计算总运费：");
        writeLog("获取参数yf:"+yf+"tcyf:"+tcyf+",flx:"+flx);

        zyf=calUtil.add(yf,calUtil.add(flx,tcyf));

        writeLog("求得总运费："+zyf);

        return zyf;
    }

    @Override
    public Double calYf(String jfms,Double jgd,  Double zjz, Double jhyzlhj) {
        Double yf=0.00;//运费

        /**
         * 总运费计算逻辑
         * 包车：总运费=价格档+同城费用+辅路线费用
         * 计重：总运费=价格档*总净重/1000+辅路线费用+同城费用
         * 计件：总运费=价格档*计划运载量计划+辅路线费用+同城费用
         */
        writeLog("开始计算运费：");
        writeLog("获取参数jfms:"+jfms+",jgdZ:"+jgd+",zjz:"+zjz+",jhyzlhj:"+jhyzlhj);
        if ((JFMSConstant.BYCAR).equals(jfms)){
            yf=jgd;
        }
        if ((JFMSConstant.BYWEIGHT).equals(jfms)){
            yf=calUtil.div(calUtil.mul(jgd,zjz),1000);
        }
        if ((JFMSConstant.BYPIECE).equals(jfms)){
            yf=calUtil.mul(jgd,jhyzlhj);
        }
        writeLog("求得运费："+yf);

        return yf;
    }

    @Override
    public void updateYf(String tablename, String zxjhh, Double yf, String yfflag) {
        StringBuffer sql=new StringBuffer().append("update "+tablename)
                .append(" set "+yfflag+"="+yf+" where zxjhh='"+zxjhh+"'");
        String sql0=sqlAppend(sql,tablename);
        writeLog(sql0);
        rs.execute(sql0);

    }

    @Override
    public void updateZyf(String tablename,String zxjhh, Double zyf, String zyfflag) {
        StringBuffer sql=new StringBuffer().append("update "+tablename)
                .append(" set "+zyfflag+"="+zyf+" where zxjhh='"+zxjhh+"'");
        String sql0=sqlAppend(sql,tablename);
        writeLog(sql0);
        rs.execute(sql0);
    }

    @Override
    public String getIdByZxjh(String zxjhh,String tablename) {
        StringBuffer sql=new StringBuffer().append("select id from ").append(tablename)
                .append(" where zxjhh='"+zxjhh+"'");
        String sql0=sqlAppend(sql,tablename);
        writeLog(sql0);
        rs.execute(sql0);
        String id="";
        if (rs.next()){
            id= Util.null2String(rs.getString("id"));
        }
        return id;

    }

    @Override
    public String getSfygBy(String id, String tablename) {
        String sfyg="";
        StringBuffer sql=new StringBuffer().append("select sfyg from "+tablename)
                .append(" where id="+id);
        writeLog(sql.toString());
        rs.execute(sql.toString());
        if (rs.next()){
            sfyg=rs.getString("sfyg");
        }
        return sfyg;
    }

    @Override
    public String getJgdId(String zxjhh, String tablename) {
        StringBuffer sql=new StringBuffer().append("select yfjgd from ").append(tablename)
                .append(" where zxjhh='"+zxjhh+"'");
        String sql0=sqlAppend(sql,tablename);
        writeLog(sql0);
        rs.execute(sql0);
        String id="";
        if (rs.next()){
            id= Util.null2String(rs.getString("yfjgd"));
        }
        return id;
    }
}
