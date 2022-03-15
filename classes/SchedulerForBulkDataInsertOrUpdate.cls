/*
* @author Cloud Analogy
* @date 26/08/2021.
* @description SchedulerForBulkDataInsertOrUpdate ....
*/
public with sharing class SchedulerForBulkDataInsertOrUpdate implements Schedulable{
	public Integer numberOfRecords;
	public Integer startPoint;
	public Integer endPoint;
	public String objectName;
	public Id jobId;
	/*
	* @author Cloud Analogy
	* @date 26/08/2021.
	* @description constructor of the SchedulerForBulkDataInsertOrUpdate class ....
	* @param numberOfRecords ......
* @param startPoint ......
* @param endPoint ......
* @param objectName ......
* @param jobId ......
*/
	public SchedulerForBulkDataInsertOrUpdate(Integer numberOfRecords, Integer startPoint, Integer endPoint, String objectName, Id jobId){
		this.numberOfRecords = numberOfRecords;
		this.startPoint = startPoint;
		this.endPoint = endPoint;
		this.objectName = objectName;
		this.jobId = jobId;
	}
	/*
* @author Cloud Analogy
* @date 26/08/2021.
* @description execute method ....
* @param sc ......
*/
    public void execute(SchedulableContext sc){
        AsyncApexJob jobInfo;
        CronTrigger job;
        if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() && Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible()){
            jobInfo = [SELECT Id,Status FROM AsyncApexJob WHERE Id=:jobId];
        }
        if(jobInfo.Status == 'Completed'){
            if(endPoint != numberOfRecords){
                Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(this.numberOfRecords, this.startPoint, this.endPoint, this.objectName, null, null, null));
            }
            if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() && Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible()){
                job = [SELECT Id FROM CronTrigger WHERE Id = :sc.getTriggerId() WITH SECURITY_ENFORCED LIMIT 1];
            }
            System.abortJob(job.id);
        }else{
            if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() && Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible()){
                job = [SELECT Id FROM CronTrigger WHERE Id = :sc.getTriggerId() WITH SECURITY_ENFORCED LIMIT 1];
            }
            System.abortJob(job.id);

			Datetime dt = Datetime.now().addMinutes(2);
			String hour = String.valueOf(dt.hour());
			String min = String.valueOf(dt.minute());
			String dd = String.valueOf(dt.date().day());
			String mm = String.valueOf(dt.date().month());
			String yy = String.valueOf(dt.date().year());
			String nextFireTime = '0 ' + min + ' ' + hour + ' '+dd+' '+mm+' ? '+yy;

			if(dt > Datetime.now()) {
				System.schedule('Bulk Data Insert Job ' + sc.getTriggerId(), nextFireTime, new SchedulerForBulkDataInsertOrUpdate(this.numberOfRecords, this.startPoint, this.endPoint, this.objectName, this.jobId));
			}else{
				Datetime dt2 = Datetime.now().addMinutes(5);
				String hour2 = String.valueOf(dt2.hour());
				String min2 = String.valueOf(dt2.minute());
				String dd2 = String.valueOf(dt2.date().day());
				String mm2 = String.valueOf(dt2.date().month());
				String yy2 = String.valueOf(dt2.date().year());
				String nextFireTime2 = '0 ' + min2 + ' ' + hour2 + ' '+dd2+' '+mm2+' ? '+yy2;
				System.schedule('Bulk Data Insert Job ' + sc.getTriggerId(), nextFireTime2, new SchedulerForBulkDataInsertOrUpdate(this.numberOfRecords, this.startPoint, this.endPoint, this.objectName, this.jobId));
			}
        }
    }
}