package weaver.interfaces.workflow.action.CCPUtil;/*
 *CREATE BY chen
 *AT 2018/3/6 0006 13:40
 *IN ECOLOGY开发
 */

import weaver.general.BaseBean;

import java.util.List;
import java.util.Map;

public class DCCMUtil extends BaseBean{
    public <K,V> void printMapList(List<Map<K,V>> list){
        StringBuffer printStr=new StringBuffer();
        for (int i = 0; i <list.size() ; i++) {
            Map<K,V > map=list.get(i);
            for(Map.Entry<K, V> entry:map.entrySet()){
                printStr.append(entry.getKey()+":"+entry.getValue()+" ");
                //System.out.println(entry.getKey()+":"+entry.getValue());

            }

        }
        writeLog(printStr.toString());
    }
}
