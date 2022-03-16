/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetClientsFromTTScheduler class is used for updating and insert data in bulk.
*/
global with sharing class GetClientsFromTTScheduler implements Schedulable{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param sc ...
*/
    global void execute(SchedulableContext sc) {
        //System.enqueueJob(new TelosTouchSF.GetClientsFromTTQueueable());
        Database.executeBatch(new BatchForBulkDataInsertOrUpdate(null, null, null, 'Contact', null, null, null));
    }
}