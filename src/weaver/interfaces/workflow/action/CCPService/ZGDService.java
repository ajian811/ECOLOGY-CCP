package weaver.interfaces.workflow.action.CCPService;/*
 *CREATE BY chen
 *AT 2018/2/28 0028 14:31
 *IN ECOLOGY开发
 */

public interface ZGDService {

    //暂估单重算总运费
    public void calZGDFreight(String zxplanno,String tablename,String zgdid);

    //暂估单分摊运费重算
    public void calZGDAllocateFrieght(String zxplanno,String djlx);

    //更新暂估单总运费
    public void updateZGDZyf(String zgdid,Double zyf);

    //更新暂估单分摊运费重算
    public void updateZGDAllocateFrieght(String zgdid,String zxplanno,String tablename);

    //装卸计划价格档
    public String getJgdId(String zxjhh, String tablename);

}
