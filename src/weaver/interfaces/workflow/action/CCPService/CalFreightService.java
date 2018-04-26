package weaver.interfaces.workflow.action.CCPService;/*
 *CREATE BY chen
 *AT 2018/2/27 0027 15:17
 *IN ECOLOGY开发
 */

import java.util.List;
import java.util.Map;

public interface CalFreightService {
    //获取运费列表
    public List<Map<String, Double>> getYfList(String zxjhh,Double total,String sfyg,String lx);
    //获得权重比信息map数组
    public List<Map<String,Double>> getQzList(List<Map<String,Double>> list, Double total);
    //打印map数组
    public void printList(List<Map<String,Double>> list);
    //更新明细表的分摊运费
    public Boolean updateMx(List<Map<String,Double>> list,String sfyg,String dtname1,String fieldname,String dtname2);
    //分摊运费
    public Boolean calAllocateFrieght(String zxjhh,String lx);
    //根据装卸计划id获取运费价格档id
    public String getJgdId(String zxjhh, String tablename);
    //重算运费
    public void calFreight(String zxjhh,String tablename ,Boolean zgd,String zgdid);

    //更新暂估单总运费
    public void updateZGDZyf(String zgdid,Double zyf);
}
