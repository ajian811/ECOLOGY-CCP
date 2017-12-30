package demo;

import java.math.BigDecimal;

public class Test2 {
	public static void main(String[] args) {
		String double1="3.33";
		String double2="1.11";
		Double double4=0.00;
		
//		Double double3=double1/double2;
//		double4=double1-double2;
		Test2 test2=new Test2();
		double4=test2.calculateJZ(double1, double2);
		System.out.println(double4.toString());
	}
	
	
	public Double calculateJZ(String rz,String cz){
		//Util.getDoubleValue("0.00");
		if(rz.equals("")||rz==null){
			
			rz="0.00";
		}
		if(cz.equals("")||rz==null){
			
			cz="0.00";
		}
		//计算净重的绝对值
		BigDecimal b1=new BigDecimal(rz);
		BigDecimal b2=new BigDecimal(cz);
		Double b3=b1.subtract(b2).doubleValue();
		return Math.abs(b3);
		}
}
