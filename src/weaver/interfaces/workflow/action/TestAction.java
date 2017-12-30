/**
 *
 */
package weaver.interfaces.workflow.action;

import weaver.general.BaseBean;
import weaver.general.StaticObj;
import weaver.interfaces.datasource.DataSource;
import weaver.soa.workflow.request.DetailTableInfo;
import weaver.soa.workflow.request.MainTableInfo;
import weaver.soa.workflow.request.Property;
import weaver.soa.workflow.request.RequestInfo;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * @author weaver
 */
public class TestAction extends BaseBean implements Action {

    public String p1;
    public String p2;

    /* (non-Javadoc)
     * @see weaver.interfaces.workflow.action.Action#execute(weaver.soa.workflow.request.RequestInfo)
     */
    @Override
    public String execute(RequestInfo requestinfo) {
        System.out.println("进入Action requestid=" + requestinfo.getRequestid());
        MainTableInfo mt = requestinfo.getMainTableInfo();
        Property[] p = mt.getProperty();

        DetailTableInfo dti = requestinfo.getDetailTableInfo();

        String requestname = requestinfo.getRequestManager().getRequestname();
        System.out.println("requestname=" + requestname);
        DataSource ds = (DataSource) StaticObj.getServiceByFullname(("datasource.local"), DataSource.class);
        Connection conn = null;

        try {
            conn = ds.getConnection();
            ResultSet rs = conn.createStatement().executeQuery("select top 10 lastname,password from hrmresource");
            while (rs.next()) {
                System.out.println("name-->" + rs.getString("lastname") + " pwd-->" + rs.getString("password"));
            }
            rs.close();

            //requestinfo.getRequestManager().setMessage("xxxxxxxxxxxxxx");
            requestinfo.getRequestManager().setMessagecontent("流程数据异常,请检查!!");
            requestinfo.getRequestManager().setMessageid("11111111111111111");

            //RecordSetDataSource rs = new RecordSetDataSource("local");

        } catch (Exception e) {
            writeLog(e);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {

            }
        }
        System.out.println("Action执行完成 传入参数p1=" + this.getP1() + "  p2=" + this.getP2());

        return "1"; //Sucess = 1
    }

    public String getP1() {
        return p1;
    }

    public void setP1(String p1) {
        this.p1 = p1;
    }

    public String getP2() {
        return p2;
    }

    public void setP2(String p2) {
        this.p2 = p2;
    }


}
