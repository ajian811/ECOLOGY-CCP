/**
 * 
 */
package weaver.oatest.webservices;

import org.apache.commons.lang.StringUtils;

import weaver.general.BaseBean;

/**
 * @author Administrator
 *
 */
public class TestServiceImpl extends BaseBean implements TestService  {

	public String TestMethod(String... param) {

		return "接收到的参数为："+StringUtils.join(param,",");
	}

}
