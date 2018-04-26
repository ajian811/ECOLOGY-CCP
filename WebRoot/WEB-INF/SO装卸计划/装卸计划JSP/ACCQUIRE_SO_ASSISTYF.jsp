<%@page import="weaver.general.Util"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Map"%>
<%@page import="weaver.conn.RecordSet"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="net.sf.json.JSONArray"%>
<%
	RecordSet rs = new RecordSet();
	try {
		String list = request.getParameter("list");
		String[] comm = request.getParameterValues("comm[]");
		String startCity = request.getParameter("startCity");
		String endCity = request.getParameter("endCity");
		JSONArray jsonArr = new JSONArray();
		rs.writeLog("list："+list);
		rs.writeLog("comm:"+comm.toString());
		rs.writeLog("startCity:"+startCity);
		rs.writeLog("endCity:"+endCity);


		RecordSet jgdrs = new RecordSet();
		rs.writeLog("ACCQUIRE_SO_ASSISTYF.jsp");

		JSONArray json = JSONArray.fromObject(list);
		List<Map<String, String>> newList = new ArrayList<Map<String, String>>();
		//获取辅路线并放入map
		for (int i = 0; i < json.size(); i++) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("startCity", startCity);
			map.put("midCity", (String) json.getJSONObject(i).get("midCity"));
			map.put("sendName", (String) json.getJSONObject(i).get("sendName"));
			map.put("sendAddress", (String) json.getJSONObject(i).get("sendAddress"));
			map.put("cysjm", comm[0]);
			map.put("cx", comm[1]);
			map.put("dw", comm[2]);
			map.put("ysrq", comm[3]);
			map.put("jflx", comm[4]);
			map.put("yslx", comm[5]);
			map.put("xllx", comm[6]);
			map.put("index", "0");
			map.put("cqb", comm[7]);

			newList.add(map);
			if (i == json.size() - 1) {
				//放入终点路线
				Map<String, String> firstmap = new HashMap<String, String>();
				firstmap.put("startCity", startCity);
				firstmap.put("midCity", endCity);
				firstmap.put("sendName", (String) json.getJSONObject(i).get("sendName"));
				firstmap.put("sendAddress", (String) json.getJSONObject(i).get("sendAddress"));
				firstmap.put("cysjm", comm[0]);
				firstmap.put("cx", comm[1]);
				firstmap.put("dw", comm[2]);
				firstmap.put("ysrq", comm[3]);
				firstmap.put("jflx", comm[4]);
				firstmap.put("yslx", comm[5]);
				firstmap.put("xllx", comm[6]);
				firstmap.put("index", "0");
				firstmap.put("cqb", comm[7]);
				newList.add(firstmap);
			}
		}

		for (int i = 0; i < newList.size(); i++) {
			Map m1 = newList.get(i);

			for (int j = i + 1; j < newList.size(); j++) {
				Map m2 = newList.get(j);
				if (m1.get("midCity").equals(m2.get("midCity"))
						&& m1.get("sendAddress").equals(m2.get("sendAddress"))) {
					newList.remove(j);
					continue;
				}

			}
		}

		//查询同城个数，并调整
		List<Map<String, String>> countList = new ArrayList<Map<String, String>>();
		for (int i = 0; i < newList.size(); i++) {
			String city = newList.get(i).get("midCity");
			String sendName = newList.get(i).get("sendName");
			String sendAddress = newList.get(i).get("sendAddress");
			String firstCity = newList.get(i).get("startCity");
			int flag = 0;
			int index = 0;
			for (int j = 0; j < countList.size(); j++) {
				String city1 = countList.get(j).get("midCity");
				String sendName1 = countList.get(j).get("sendName");
				String sendAddress1 = countList.get(j).get("sendAddress");
				String firstCity1 = countList.get(j).get("startCity");
				if (city.equals(city1) && !sendAddress.equals(sendAddress1)) {
					int sum = Integer.parseInt(newList.get(i).get("index"))
							+ Integer.parseInt(countList.get(j).get("index")) + 1;
					countList.get(j).put("index", "" + sum);//同城个数
					flag = 1;
				} else if (firstCity.equals(firstCity1) && city.equals(city1)
						&& sendAddress.equals(sendAddress1)) {
					flag = 1;
				}
			}
			if (flag == 0) {
				countList.add(newList.get(i));
			}
		}

		//查询里程
		for (Map<String, String> m : countList) {
			StringBuffer sb = new StringBuffer();
			sb.append("select * from uf_citymanagement where ");
			//sb.append("startcity = '").append(m.get("startCity")).append("' and ");
			sb.append("id = '").append(m.get("midCity")).append("' and ");
			//sb.append("id = '").append(m.get("cqb")).append("' and ");
			sb.append("state = '").append("1").append("' ");
			jgdrs.writeLog(sb.toString());
			jgdrs.executeSql(sb.toString());
			if (jgdrs.next()) {
				m.put("lc", jgdrs.getString("distance"));//距离
				m.put("tcdj", jgdrs.getString("cityprice"));//同城单价
			} else {
				//没有赋值O
				m.put("lc", "0");
				m.put("tcdj", "0");
			}

		}

		//对里程数进行排序
		Collections.sort(countList, new Comparator<Map<String, String>>() {
			public int compare(Map<String, String> o1, Map<String, String> o2) {
				//o1，o2是list中的Map，可以在其内取得值，按其排序，此例为升序，s1和s2是排序字段值  
				double s1 = Double.parseDouble(o1.get("lc"));
				double s2 = Double.parseDouble(o2.get("lc"));
				if (s1 > s2) {
					return 1;
				} else {
					return -1;
				}
			}
		});

		//设置顺序，并放入中转城市
		for (int i = 0; i < countList.size(); i++) {
			countList.get(i).put("sort", "" + (i + 1));
			if (i > 0) {
				countList.get(i).put("changeCity", countList.get(i - 1).get("midCity"));
			}

		}

		//获取同城单价
		int index = 0;
		for (Map<String, String> m : countList) {
			StringBuffer sb = new StringBuffer();
			sb.append("select * from uf_yfjgwhd where ");
			sb.append("cysjm = '").append(m.get("cysjm")).append("' and ");
			sb.append("cx = '").append(m.get("cx")).append("' and ");
			sb.append("jflx = '").append(m.get("jflx")).append("' and ");
			sb.append("xllx = '").append("1").append("' and ");
			sb.append("yslx = '").append(m.get("yslx")).append("' and ");
			sb.append("'").append(m.get("ysrq")).append("' >= date1").append(" and ");
			sb.append("'").append(m.get("ysrq")).append("' <= date2").append(" and ");
			if (index > 0) {
				sb.append("cfcs = '").append(m.get("changeCity")).append("' and ");
			} else {
				sb.append("cfcs = '").append(m.get("startCity")).append("' and ");
			}
			sb.append("destination = '").append(m.get("midCity")).append("' ");
			sb.append("order by price desc");
			index++;
			jgdrs.writeLog(sb.toString());
			jgdrs.executeSql(sb.toString());
			if (jgdrs.next()) {
				m.put("price", jgdrs.getString("price"));//获取路线价格
			} else {
				m.put("price", "0");
			}
			jsonArr.add(m);
		}
		for (Map<String, String> m : countList) {
			for (String k : m.keySet()) {
				rs.writeLog(k + " : " + m.get(k));
			}

		}
		PrintWriter pw = response.getWriter();
		pw.write(jsonArr.toString());
		pw.flush();
		pw.close();
	} catch (Exception e) {
		// TODO: handle exception
		out.write("fail" + e);
		e.printStackTrace();
	}
%>