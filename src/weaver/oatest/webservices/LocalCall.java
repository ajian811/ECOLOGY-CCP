/**
 * 
 */
package weaver.oatest.webservices;

import weaver.soa.workflow.request.RequestInfo;
import weaver.soa.workflow.request.RequestService;

public class LocalCall {

	public void DoSubmitRequest(int requestid){
		RequestService rqs = new RequestService();
		RequestInfo request = rqs.getRequest(requestid);

		boolean returnstr = rqs.nextNodeBySubmit(request, requestid, 12, "签字意见");
		if(returnstr){
			System.out.println("流程提交成功");
		}else{
			System.out.println("流程提交失败");
		}
	}
}
