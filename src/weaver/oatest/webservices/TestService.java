/**
 * 自定义的WebService接口
 */
package weaver.oatest.webservices;

public interface TestService {

	/**
	 * 输出接收的参数
	 * @param param
	 * @return
	 */
	public String TestMethod(String... param);
}
