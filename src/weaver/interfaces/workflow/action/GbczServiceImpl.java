package weaver.interfaces.workflow.action;/*
 *CREATE BY chen
 *AT 2018/1/18 0018 11:50
 *IN ECOLOGY开发
 */

public class GbczServiceImpl implements GbczService{
    @Override
    public String deleteWeigh(String plate, String reason) {
        String result=checkDeleteWeigh(plate);
        if ("success".equals(result)){
            updateDeleteWeigh(searchId(plate),reason);
        }
        return null;
    }

    @Override
    public String checkDeleteWeigh(String plate) {
        return null;
    }

    @Override
    public void updateDeleteWeigh(String id, String reason) {

    }

    @Override
    public String searchId(String plate) {
        return null;
    }
}
