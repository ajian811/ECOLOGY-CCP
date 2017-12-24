package weaver.oatest;



import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.hrm.User;

/**
 * Created by Administrator on 2016/10/11.
 */
public class DemoUtil {

    /**
     * 获取复选框能否被选中
     * @param id
     * @return
     */
    public String getCanCheck(String id){
        if(Util.getIntValue(id)%2==0) {
            return "true";
        }else{
            return "false";
        }
    }

    /**
     * 获取能不能进行操作，进行权限判断
     * @param id
     * @param userid
     * @return
     */
    public ArrayList getCanOperation(String id,String userid){
        ArrayList resultlist = new ArrayList();
        resultlist.add("true");
        resultlist.add("true");
        return resultlist;
    }

    /**
     * 封装分页控件需要显示的数据
     * @param user  当前操作人
     * @param otherparams   传入参数
     * @param request
     * @param response
     * @return
     */
    public List<Map<String, String>> getDemoData(User user,
                                                Map<String, String> otherparams, HttpServletRequest request,
                                                HttpServletResponse response){
        List<Map<String, String>> data = new ArrayList<Map<String, String>>();
        String userid = otherparams.get("userid");

        RecordSet rs = new RecordSet();//模拟外部数据查询
        rs.executeSql("select * from demotable");
       
        while(rs.next()){
            Map<String, String> d = new HashMap<String, String>();
            d.put("id", rs.getString("id"));
            d.put("name", Util.null2String(rs.getString("name")));
            d.put("userid", Util.null2String(rs.getString("userid")));
            d.put("scount", Util.null2String(rs.getString("scount")));
            d.put("sprice", Util.null2String(rs.getString("sprice")));
            
            data.add(d);
        }

        rs.writeLog("getDemoData 传入参数：："+userid);

        return data;
    }

}
