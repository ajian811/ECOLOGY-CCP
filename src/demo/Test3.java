package demo;

import java.math.BigDecimal;
import java.util.*;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;



public class Test3 {
	public static void main(String[] args) {
		String newSl=(calCulate("17000.0000","80.0000")).toString();
		System.out.println(newSl);
	
	}
	
	public static Double calCulate(String str1,String str2){
		if(str1.equals("")||str1==null){
			
			str1="0.00";
		}
		if(str2.equals("")||str2==null){
			
			str2="0.00";
		}
		//计算净重的绝对值
		BigDecimal b1=new BigDecimal(str1);
		BigDecimal b2=new BigDecimal(str2);
		System.out.println(b1);
		System.out.println(b2);
		Double b3=b1.add(b2).doubleValue();
		return b3;
		}
}
