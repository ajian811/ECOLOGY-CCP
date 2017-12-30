package demo;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import weaver.general.StaticObj;
import weaver.interfaces.datasource.DataSource;

public class Demo1 {
public static void main(String[] args)  {
	try {
		DataSource ds=(DataSource) StaticObj.getServiceByFullname(("datasource.eweaverTestOA"),
		weaver.interfaces.datasource.DataSource.class);
		  Connection conn=ds.getConnection();
		  Statement st=conn.createStatement();
		  String sql="select * from ";
		  ResultSet rs=st.executeQuery(sql);
		  while(rs.next()){
			  String id= rs.getString("");
			  
		  }
		 
	} catch (Exception e) {
		// TODO: handle exception
		e.printStackTrace();
		
	}
	
	  
	
}
  
  
}
