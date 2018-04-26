package weaver.interfaces.workflow.action.CCPServiceImpl;/*
 *CREATE BY chen
 *AT 2018/2/27 0027 15:22
 *IN ECOLOGY开发
 */

import com.weaver.general.BaseBean;
import com.weaver.general.Util;
import weaver.conn.RecordSet;
import weaver.interfaces.workflow.action.CCPConstant.*;
import weaver.interfaces.workflow.action.CCPService.ZXJHService;
import weaver.interfaces.workflow.action.CCPUtil.CalUtil;
import weaver.interfaces.workflow.action.CCPService.CalFreightService;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CalFreightServiceImpl extends BaseBean  implements CalFreightService{
    private CalUtil calUtil=new CalUtil();
    private RecordSet rs=new RecordSet();
    private ZXJHService zs=new ZXJHServiceImpl();

    //各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
/**各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
假设有n行明细：
第1~n-1行：
产品明细的分摊运费 =产品明细的权重比例*总运费, 保留2位小数，四舍五入
第n行：
产品明细的分摊运费 =总运费-∑第1~n-1行产品明细的分摊运费
如果计算出来第n行的分摊运费=0或者小于0， 则第n行的运费强制改为0.01，然后将差的金额调整到上一行；如果调整后上一行金额=0，则还要强制改为0.01，再将差的金额调到上上一行，依次类推。
*/
    @Override
    public List<Map<String, Double>> getYfList(String zxjhh, Double total, String sfyg,String lx) {
        RecordSet dtrs=new RecordSet();
        List<Map<String, Double>> list = new ArrayList<Map<String, Double>>();
        Double dtlc=0.00;
        Double sjftjz=0.00;
        Double zqz=0.00;
        Double dtid=0.00;
        String str0="";
        String dtsql="";
        String tablename="";
        String detailname="";
        String sjftjzFlag="";
        if ("0".equals(lx)){
            tablename="formtable_main_45";
           detailname="formtable_main_45_dt3";
            str0=" AND t1.REQUESTID IS NULL";
            sjftjzFlag="sjftjz";
        }else if ("1".equals(lx)){
            tablename="formtable_main_61";
            if ("0".equals(sfyg)){
                detailname="formtable_main_61_dt2";
            }
            if ("1".equals(sfyg)){
                detailname="formtable_main_61_dt1";
            }
            sjftjzFlag="FTZL";

        }else if ("2".equals(lx)){
            tablename="uf_fsapzxjh";
            detailname="uf_fsapzxjh_dt1";
            sjftjzFlag="sjftjz";


        }


            dtsql = "select t2.* from "+tablename+" t1";
            dtsql += " left join "+detailname+" t2 on t1.id = t2.mainid";
            dtsql += " where t1.zxjhh = '" + zxjhh + "'";
            dtsql+=str0;
            dtsql += " order by t2.id";

        writeLog(dtsql);
        if (dtrs.execute(dtsql)) {
            while (dtrs.next()) {
                Map<String, Double> map = new HashMap<String, Double>();
                dtlc = Util.getDoubleValue(dtrs.getString("lc")) == -1.0 ? 0.00 : dtrs.getDouble("lc");//里程
                sjftjz =Util.getDoubleValue( dtrs.getString(sjftjzFlag) )== -1.0 ? 0.00 : dtrs.getDouble(sjftjzFlag);//实际分摊净重
                zqz =calUtil.add( calUtil.mul(dtlc, sjftjz),zqz);//总权重
                dtid = Double.parseDouble(dtrs.getString("id"));//明细数据Id

                map.put("dtid", dtid);
                map.put("dtlc", dtlc);
                map.put("sjftjz", sjftjz);
                map.put("zqz", zqz);
                map.put("total", total);
                list.add(map);
            }
        } else {
            writeLog("查询明细发生错误");
        }
        return list;

    }

    //各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
/*
*各产品明细的权重比例 =（各产品明细的送达城市点的里程数*实际分摊净重）/总权重计算
假设有n行明细：
第1~n-1行：
产品明细的分摊运费 =产品明细的权重比例*总运费, 保留2位小数，四舍五入
第n行：
产品明细的分摊运费 =总运费-∑第1~n-1行产品明细的分摊运费
如果计算出来第n行的分摊运费=0或者小于0， 则第n行的运费强制改为0.01，然后将差的金额调整到上一行；如果调整后上一行金额=0，则还要强制改为0.01，再将差的金额调到上上一行，依次类推。
*/
    @Override
    public List<Map<String, Double>> getQzList(List<Map<String, Double>> list, Double total) {
        BaseBean log=new BaseBean();

        if (list.size() <= 0) {
            writeLog("数据获取失败，list中没有数据");
            return null;
        }

        double totalFtyf = 0.00;//总分摊运费
        for (int i = 0; i < list.size() - 1; i++) {
            double qzbl =calUtil.div(calUtil.mul(list.get(i).get("dtlc"), list.get(i).get("sjftjz")),
                    list.get(list.size() - 1).get("zqz"));
            double ftyf = calUtil.mulTwo(qzbl, list.get(i).get("total"));
            writeLog("权重比例：" + qzbl + ",ftyf: " + ftyf);
            list.get(i).put("ftyf", ftyf);
            totalFtyf += ftyf;//1~n-1之前的分摊运费的和
        }
        writeLog("1~n-1之前的分摊运费的和,totalFtyf:" + totalFtyf);
        //第N行分摊运费
        double lastFtyf = calUtil.calculateJZ(total, totalFtyf);
        list.get(list.size() - 1).put("ftyf", lastFtyf);

        for (int i = list.size() - 1; i < list.size(); i--) {
            if (i == 0) {
                break;
            }
            lastFtyf = list.get(i).get("ftyf");
            if (lastFtyf <= 0) {
                writeLog("第" + i + "行运费小于O");
                list.get(i).put("ftyf", 0.01);
                double overPrice = calUtil.calculateJZ(lastFtyf, 0.01);
                list.get(i - 1).put("ftyf", calUtil.add(list.get(i - 1).get("ftyf"), overPrice));
            } else {
                break;
            }
        }

        for (int i = list.size() - 1; i < list.size(); i--) {
            if (i == 0) {
                break;
            }
            lastFtyf = list.get(i).get("ftyf");
            if (lastFtyf <= 0) {
                writeLog("第" + i + "行运费小于O");
                list.get(i).put("ftyf", 0.01);
                double overPrice = calUtil.calculateJZ(0.01, lastFtyf);
                list.get(i - 1).put("ftyf", list.get(i - 1).get("ftyf") - overPrice);
            } else {
                break;
            }
        }
        return list;
    }

    @Override
    public void printList(List<Map<String, Double>> list) {
        BaseBean log=new BaseBean();
        //打印log
        int i=1;
        for (Map<String, Double> m : list) {

            writeLog("遍历list：第"+(i++)+"行:");
            StringBuffer stringBuffer=new StringBuffer();
            for (String k : m.keySet()) {

                stringBuffer.append(k + " : " + m.get(k)+" ,");
            }
            writeLog(stringBuffer.toString());
        }

    }

    @Override
    public Boolean updateMx(List<Map<String, Double>> list, String sfyg, String dtname1, String fieldname, String dtname2) {
        RecordSet rs=new RecordSet();
        RecordSet uprs=new RecordSet();

        BaseBean log=new BaseBean();
        Boolean flag=false;
        if ("1".equals(sfyg)||"".equals(sfyg)) {

            //打印log
            for (Map<String, Double> m : list) {
                String updateSql = "update " + dtname1 + " set " + fieldname + " = '" + m.get("ftyf")
                        + "' where id = '" + String.valueOf(m.get("dtid")) + "'";
                writeLog(updateSql);
                flag = uprs.execute(updateSql);
                if (!flag) {
                    writeLog("执行明细表数据id" + String.valueOf(m.get("dtid")) + "错误");
                    break;
                }

            }

        } else if ("0".equals(sfyg)) {
            //打印log
            for (Map<String, Double> m : list) {
                String updateSql = "update " + dtname2 + " set " + fieldname + " = '" + m.get("ftyf")
                        + "' where id = '" + String.valueOf(m.get("dtid")) + "'";
                writeLog(updateSql);
                flag = uprs.executeSql(updateSql);

                if (!flag) {
                    writeLog("执行明细表数据id" + String.valueOf(m.get("dtid")) + "错误");
                    break;
                }
            }
        }
        return flag;
    }

    @Override
    public Boolean calAllocateFrieght(String zxjhh, String lx) {
        String tablename="";

        boolean flag = false;

        BaseBean log = new BaseBean();
        writeLog("进入calAllocateFrieght");



            if ("".equals(zxjhh) || "".equals(lx)) {
                writeLog("装卸计划号为空，或者类型为空");
                return flag;
            }
            writeLog("zxjhh = " + zxjhh + ", lx = " + lx);
            String dtname1 = "";
            String dtname2 = "";
            String fieldname = "";
            if ("0".equals(lx)) {
                //SO
                tablename="formtable_main_45";
                dtname1 = "formtable_main_45_dt3";
                dtname2 = "formtable_main_45_dt3";
                fieldname = "ftfy";
            } else if ("1".equals(lx)) {
                //po
                tablename="formtable_main_61";
                dtname1 = "formtable_main_61_dt1";
                dtname2 = "formtable_main_61_dt2";
                fieldname = "fee";
            } else if ("2".equals(lx)) {
                //po
                tablename="uf_fsapzxjh";
                dtname1 = "uf_fsapzxjh_dt1";
                dtname2 = "uf_fsapzxjh_dt1";
                fieldname = "ftfy";
            } else {
                writeLog("分配错误");
                return flag;
            }
            //费用重算
            calFreight(zxjhh,tablename);


            String jfms = "";//计费模式 0包车 1配载 2计件 3 byweight（kg） 4 byweight（T） 5 bytrip（km）
            double gbzl = 0.00;//过磅重量（总净重）
            double jgd = 0.00;//价格档（单价）
            double lc = 0.00;//里程
            double mainPrice = 0.00;//一般运费
            String sfyg = "";//是否有柜  1 有柜 2无柜
            double cuont = 0.00;//计件数
            double total = 0.00;//总运费
            double flxzj = 0.00;//辅线路运费
            double tczyf = 0.00;//同城费用

            RecordSet rs = new RecordSet();
            RecordSet rs1 = new RecordSet();
            RecordSet dtrs = new RecordSet();
            RecordSet uprs = new RecordSet();
            Double jhyzlhj=0.00;//计划总重量
            //存放流程数据
            List<Map<String, Double>> list = new ArrayList<Map<String, Double>>();
            //存放建模数据
            List<Map<String, Double>> list2 = new ArrayList<Map<String, Double>>();



                /*
                 *类型算主线路运费：
                 *包车： 直接取单价
                 *计件（按个数）： 单价*计件数量
                 *按重量计算（按吨的话）： 单价*过磅重量（KG）/1000
                 *按重量计算（按KG的话）： 单价*过磅重量（KG）
                 *配载（按重量和里程, 每吨每KM多少钱）：主路线的到达城市点的里程数（KM）*(过磅重量（KG）/1000)*单价
                 */

                //DecimalFormat df = new DecimalFormat("#");

                Double zyf=0.00;//总运费

                String sql = "";
                if ("0".equals(lx)) {
                    sql = "select zyf,sfyg from " + tablename + " where zxjhh = '" + zxjhh + "' and REQUESTID IS NULL";
                }else if ("1".equals(lx)) {
                    sql = "select zyf,sfyg from " + tablename + " where zxjhh = '" + zxjhh + "'";
                }else if ("2".equals(lx)) {
                    sql = "select zyf from " + tablename + " where zxjhh = '" + zxjhh + "'";
                }
                writeLog("查询主表Sql:" + sql);
                if (rs.execute(sql)) {
                    if (rs.next()) {

                        zyf=rs.getDouble("zyf");//总运费
                        sfyg = Util.null2String(rs.getString("sfyg"));//是否有柜
                        if ("".equals(sfyg)){
                            sfyg="0";
                        }

                    }
                } else {
                    writeLog("数据库查询错误");
                }

                //总运费计算公式：总运费=一般运费+同城加价单价*同城个数+辅线路的所有运费
                total = zyf;
                writeLog("计算出的总运费:" + total);
                writeLog("sfyg:" + sfyg);
                double zqz = 0.00;//总权重
                double dtlc = 0.00;//明细里程
                double sjftjz = 0.00;//实际分摊净重
                double dtid = 0;//明细表id

                if (total>0){
                    list=getYfList(zxjhh,total,sfyg,lx);
                }else {
                    writeLog("运费小于O或获取不到数据！");
                }



            list=getQzList(list,total);


            //打印log
            printList(list);



            flag=updateMx(list, sfyg, dtname1, fieldname, dtname2);

            return flag;
    }

    @Override
    public String getJgdId(String zxjhh, String tablename) {
        RecordSet rs=new RecordSet();
        String sqlAdd="";
        if ("formtable_main_45".equals(tablename)){
            sqlAdd=" and requestid is null";
        }
        String sql="select yfjgd from "+tablename+" where zxjhh='"+zxjhh+"'"+sqlAdd;
        String jgdid="";
        writeLog(sql);
        rs.execute(sql);
        if (rs.next()){
            jgdid=Util.null2String(rs.getString("yfjgd"));
        }
        return jgdid;
    }

    public void calFreight(String zxjhh, String tablename){
        calFreight(zxjhh, tablename,false,null);
    }
    @Override
    public void calFreight(String zxjhh, String tablename,Boolean zgd,String zgdid) {
        String prop="";//prop配置文件名字
        String jfms="";//计费模式
        Double jgd=0.00;//价格档
        Double flx=0.00;//辅路线价格
        Double tcyf=0.00;//同城总运费
        Double zyf=0.00;//总运费
        Double zjz=0.00;//总净重
        Double jhyzljh = 0.00; //计划运载量合计

        String jfmsFlag ="";//计费模式
        String jgdFlag ="";//价格档
        String flxFlag ="";//辅路线价格
        String tcyfFlag ="";//同城总运费
        String zyfFlag ="";//总运费flag
        String yfFlag ="";//运费flag

        String jhyzljhFlag = ""; //计划运载量合计
        String zjzFlag ="";//总净重


        prop=zs.getPropByTableName(tablename);
        jfmsFlag =getPropValue(prop, PropZxjhKeyConstant.JFMS);
        jgdFlag =getPropValue(prop, PropZxjhKeyConstant.JGD);
        flxFlag =getPropValue(prop, PropZxjhKeyConstant.FLXJG);
        tcyfFlag =getPropValue(prop, PropZxjhKeyConstant.TCZYF);
        zyfFlag =getPropValue(prop, PropZxjhKeyConstant.ZYF);
        yfFlag = getPropValue(prop, PropZxjhKeyConstant.YF);
        
        jhyzljhFlag =getPropValue(prop, PropZxjhKeyConstant.JHYZLHJ);
        zjzFlag =getPropValue(prop, PropZxjhKeyConstant.ZJZ);

        StringBuffer sql=new StringBuffer().append("select ")
                .append(jfmsFlag +","+ jgdFlag +","+ flxFlag +","+ tcyfFlag +","+ zyfFlag +","+ jhyzljhFlag +","+ zjzFlag)
                .append("  from " +tablename+" where zxjhh='"+zxjhh+"'");
        String sql0=zs.sqlAppend(sql,tablename);
        writeLog(sql0);
        rs.execute(sql0);
        if (rs.next()){
            jfms=Util.null2String(rs.getString(jfmsFlag));
            jgd=rs.getDouble(jgdFlag);
            flx=rs.getDouble(flxFlag);
            tcyf=rs.getDouble(tcyfFlag);
            zyf=rs.getDouble(zyfFlag);
            jhyzljh=rs.getDouble(jhyzljhFlag);
            zjz=rs.getDouble(zjzFlag);
        }
        Double yf=zs.calYf(jfms,jgd,zjz,jhyzljh);
        zs.updateYf(tablename,zxjhh,yf, yfFlag);
        zyf=zs.calZyf(yf,tcyf,flx);
        zs.updateZyf(tablename,zxjhh,zyf, zyfFlag);
        if (zgd){
        updateZGDZyf(zgdid,zyf);
        }

    }
    @Override
    public void updateZGDZyf(String zgdid, Double zyf) {
        StringBuffer sql=new StringBuffer().append("UPDATE "+getPropValue(DCCMPropConstant.ZGDPROP,"tablename")+" set ")
                .append(getPropValue(DCCMPropConstant.ZGDPROP,"wsje")+"="+zyf)
                .append(" where id="+zgdid);
        writeLog(sql.toString());
        rs.execute(sql.toString());

    }
}
