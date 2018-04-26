package weaver.interfaces.workflow.action.CCPUtil;/*
 *CREATE BY chen
 *AT 2018/2/27 0027 15:26
 *IN ECOLOGY开发
 */

import org.apache.xpath.operations.Div;
import weaver.general.BaseBean;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class CalUtil<K,V> extends BaseBean{
    public Double add(double v1, double v2) {
        //计算净重的绝对值
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
        return b1.add(b2).setScale(6, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
public Double calculateJZ(double v1, double v2) {
        //计算净重的绝对值
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
        return b1.subtract(b2).setScale(6, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
public Double mul(double v1, double v2) {
        //计算乘法
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

        return b1.multiply(b2).setScale(6, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
public Double div(double v1, double v2) {
        //计算除法
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

        return b1.divide(b2, 6, BigDecimal.ROUND_HALF_UP).doubleValue();
    }

    public double mulTwo(double v1, Double v2) {
        //计算乘法 保留两位有效位
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));

        return b1.multiply(b2).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
    public double sub(double v1,double v2){
        BigDecimal b1 = new BigDecimal(Double.valueOf(v1));
        BigDecimal b2 = new BigDecimal(Double.valueOf(v2));
        return Math.abs(b1.subtract(b2).doubleValue());
    }
    public void printMap(HashMap<K,V> hp){
        writeLog("开始打印map：");
        Iterator itreator=hp.entrySet().iterator();
        while (itreator.hasNext()){
            Map.Entry entry=(Map.Entry) itreator.next();
            Object key=entry.getKey();
            Object value=entry.getValue();
            writeLog(key+":"+value);

        }
    }
}
