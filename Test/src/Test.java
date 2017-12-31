import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.SimpleTimeZone;

public class Test {
    public static void main(String[] args) {
        Date d1=new Date();
        SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat dateFormat1=new SimpleDateFormat("HH:mm");

        System.out.println(dateFormat.format(d1));
        System.out.print(dateFormat1.format(d1));



    }
}
