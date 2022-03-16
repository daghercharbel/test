/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetDeleteRecordsFromTTScheduler.....
*/
global with sharing class GetDeleteRecordsFromTTScheduler implements Schedulable  {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description execute method....
* @param sc ...
*/
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new TelosTouchSF.GetDeleteRecordsFromTTQueueable());
    }
}