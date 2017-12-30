<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="weaver.general.GCONST"%>
<%@ page import="com.weaver.formmodel.util.FileHelper"%>
<%@ page import="com.weaver.formmodel.util.DynamicCompiler"%>
<%@ page import="java.io.File"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="weaver.formmode.service.CommonConstant"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="weaver.formmode.customjavacode.JavaCodeManager"%>
<%@ include file="/formmode/pub_init.jsp"%>
<%
response.reset();
out.clear();
String action = Util.null2String(request.getParameter("action"));
if(action.equalsIgnoreCase("saveCode")){
	try{
		
		String code = Util.null2String(request.getParameter("code"));
		code = URLDecoder.decode(code, "UTF-8");
		code = code.trim();
		
		List<String> unsafeCodeKeyList = JavaCodeManager.filterUnsafeCodekeys(code);
		if(!unsafeCodeKeyList.isEmpty()){//代码中包含以下可能不安全而不被允许使用的关键字：xx 请修改代码规避使用以上关键字后再保存。
			throw new RuntimeException(SystemEnv.getHtmlLabelName(82037,user.getLanguage())+"\n\n" + unsafeCodeKeyList.toString() + "\n\n"+SystemEnv.getHtmlLabelName(82038,user.getLanguage()));
		}
		
		String type = Util.null2String(request.getParameter("type"));
		Map<String, String> sourceCodePathMap = CommonConstant.SOURCECODE_PATH_MAP;
		String sourceCodePath = sourceCodePathMap.get(type);
		
		String filename = Util.null2String(request.getParameter("filename"));
		
		String filepath = GCONST.getRootPath() + sourceCodePath + filename;
		
		FileHelper.writeFile(filepath, code, "UTF-8", false);
		
		DynamicCompiler.compile(new File(filepath));
		
		out.print("1");
	}catch(Exception ex){
		String errMsg = Util.null2String(ex.getMessage());
		errMsg = URLEncoder.encode(errMsg, "UTF-8");
		errMsg = errMsg.replaceAll("\\+","%20");
		out.print(errMsg);
	}
}
out.flush();
out.close();
%>