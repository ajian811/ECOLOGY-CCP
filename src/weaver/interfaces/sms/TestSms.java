/**
 * 
 */
package weaver.interfaces.sms;

import weaver.general.TimeUtil;
import weaver.sms.SmsService;

/**
 * @author weaver
 *
 */
public class TestSms implements SmsService {

	/* (non-Javadoc)
	 * @see weaver.sms.SmsService#sendSMS(java.lang.String, java.lang.String, java.lang.String)
	 */
	@Override
	public boolean sendSMS(String smsId, String phoneno, String msg) {
		//实现相应的短信接口API进行发送
		System.out.println("调用自定义的短信接口发送给("+phoneno+"):"+msg);
		//TimeUtil.getCurrentDateString();
		return true;
	}

}
