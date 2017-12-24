package weaver.interfaces.schedule;

import weaver.general.TimeUtil;

public class TestSchedule extends BaseCronJob {

	@Override
	public void execute() {
		System.out.println("计划任务执行-->"+TimeUtil.getCurrentTimeString());
	}

}
