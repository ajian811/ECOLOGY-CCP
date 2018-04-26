package weaver.interfaces.workflow.action.CCPService;/*
 *CREATE BY chen
 *AT 2018/2/28 0028 11:18
 *IN ECOLOGY开发
 */

import weaver.ofs.dao.OfsTableName;

public interface ZXJHService {
    //根据tablename获取prop配置文件名字
    public String getPropByTableName(String tablename);
    //
    public String sqlAppend(StringBuffer sql, String tablename);
    //计算总运费
    public Double calZyf(Double yf,Double tcyf,Double flx);
    //更新总运费
    public void updateZyf(String tablename,String zxjhh,Double zyf,String zyfflag);
    //计算运费
    public Double calYf(String jfms,Double jgd,Double zjz,Double jhyzlhj);
    //更新运费
    public void updateYf(String tablename,String zxjhh,Double yf,String yfflag);

    //根据装卸计划获取id
    public String getIdByZxjh(String zxjhh,String tablename);

    public String getSfygBy(String id, String tablename);
    //获取价格档
    public String getJgdId(String zxjhh,String tablename);
}
