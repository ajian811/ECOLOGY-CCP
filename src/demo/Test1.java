package demo;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.*;

import org.bouncycastle.crypto.macs.HMac;

import com.inet.pool.i;
import com.inet.tds.h;

import net.sf.json.JSONArray;
import weaver.general.StaticObj;
import weaver.interfaces.workflow.browser.Browser;

public class Test1 {
	public static void main(String[] args) {
		String list="[{'midCity':'1','sendName':'2','sendAddress':'3'},";
			list+="{'midCity':'1','sendName':'4','sendAddress':'5'},";
			list+="{'midCity':'1','sendName':'9','sendAddress':'9'},";
			list+="{'midCity':'1','sendName':'4','sendAddress':'5'},";
			list+="{'midCity':'2','sendName':'4','sendAddress':'5'},";
			list+="{'midCity':'2','sendName':'4','sendAddress':'5'},";
			list+="{'midCity':'2','sendName':'6','sendAddress':'5'},";
			list+="{'midCity':'2','sendName':'2','sendAddress':'1'}]";
		HashMap<String,String> hp=new HashMap<String,String>();
		JSONArray json = JSONArray.fromObject(list);
		for (int i = 0; i < json.size(); i++) {
			String city=json.getJSONObject(i).getString("midCity");
			String sendName=json.getJSONObject(i).getString("sendName");
			String sendAddress=json.getJSONObject(i).getString("sendAddress");
			hp.put(city+sendName+sendAddress, city+sendAddress);
		}
		Iterator iterator=hp.keySet().iterator();
		HashMap<String,Integer> hp2=new HashMap<String,Integer>();
		 while (iterator.hasNext()) {
			 Object keyObject=iterator.next();
			
			System.out.println("城市點条件："+keyObject.toString()+",城市点为："+hp.get(keyObject));
			if(hp2.containsKey(hp.get(keyObject))){
				int count=hp2.get(hp.get(keyObject));
				hp2.put(hp.get(keyObject), ++count);
				
			}else{
				hp2.put(hp.get(keyObject), 1);
				
			}
			
		}
//		hp2.put("32",1 );
		 Iterator iterator1=hp2.keySet().iterator();
			 while (iterator1.hasNext()) {
				 Object keyObject=iterator1.next();
				System.out.println("城市點："+keyObject.toString()+",个数为："+hp2.get(keyObject));
				
			}
		 
		 
		
		
	//	System.out.println(json.toString());
	//	System.out.println(json.size());
//		for (int i = 0; i < json.size(); i++) {
//			String city1=json.getJSONObject(i).getString("midCity");
//			String sendName1=json.getJSONObject(i).getString("sendName");
//			String sendAddress1=json.getJSONObject(i).getString("sendAddress");
//			for (int j = i+1; j < json.size(); j++) {
//				String city2=json.getJSONObject(j).getString("midCity");
//				String sendName2=json.getJSONObject(j).getString("sendName");
//				String sendAddress2=json.getJSONObject(j).getString("sendAddress");
//				if(city1.equals(city2) && !sendName1.equals(sendName2) && !sendAddress1.equals(sendAddress2)){
//					   System.out.println("i:"+i+"j:"+j+"---city:"+city1+",sendname:"+sendName1+",sendaddresss:"+sendAddress1);
//					   if(hp.containsKey(city1)){
//						   int tcgs=hp.get(city1);
//						   hp.put(city1, ++tcgs);
//						   
//					   }else{
//						   hp.put(city1, 1);
//					   }
//					   
//				}
//			}
//		}
//		 int index = 0;
//		 for (int i = 0; i < json.size(); i++) {
//		  for (int j = i+1; j < json.size(); j++) {
//		   String city1 = (String)json.getJSONObject(i).get("midCity");
//		   String city2 = (String)json.getJSONObject(j).get("midCity");
//		   String sendName1 = (String)json.getJSONObject(i).get("sendName");
//		   String sendName2 = (String)json.getJSONObject(j).get("sendName");
//		   String sendAddress1 = (String)json.getJSONObject(i).get("sendAddress");
//		   String sendAddress2 = (String)json.getJSONObject(j).get("sendAddress");
//		   if(city1.equals(city2) && !sendName1.equals(sendName2) && !sendAddress1.equals(sendAddress2)){
//			   System.out.println("i:"+i+"j:"+j+"---city:"+city1+",sendname:"+sendName1+",sendaddresss:"+sendAddress1);
//			   if(hp.containsKey(city1)){
//				   int tcgs=hp.get(city1);
//				   hp.put(city1, ++tcgs);
//				   
//			   }else{
//				   hp.put(city1, 1);
//			   }
//			   		
//			   
//		    
//		   }
//		  }
//		 }
		 
		 
		 
	}
}
