package weaver.interfaces.workflow.action;/*
 *CREATE BY chen
 *AT 2018/1/18 0018 11:44
 *IN ECOLOGY开发
 */

import weaver.conn.RecordSet;

public interface GbczService {
    public String deleteWeigh(String plate,String reason);

    public String checkDeleteWeigh(String plate);

    public void updateDeleteWeigh(String id,String reason);

    public String searchId(String plate);


}
