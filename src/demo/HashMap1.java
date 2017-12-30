package demo;

import java.util.HashMap;
import java.util.Map;

public class HashMap1 {
	public static void main(String[] args) {
		Map<String, String> hm=new HashMap<String, String>();
		hm.put("1", "2");
		hm.get("1");
		hm.hashCode();
		System.out.println(hm.get("1").hashCode());
		
	}
	
	

}
