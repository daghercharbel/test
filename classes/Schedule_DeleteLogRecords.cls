/**
* @author Cloud Analogy
* @date 02/08/2021
* @description Schedule_DeleteLogRecords class for deleting the log records.
*/
global with sharing class Schedule_DeleteLogRecords implements Schedulable  {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description execute method.
* @param sc ......
*/
    global void execute(SchedulableContext sc) {
        TelosTouchSF.Batch_DeleteLogRecords deleteLogBatch = new TelosTouchSF.Batch_DeleteLogRecords(); 
        Database.executeBatch(deleteLogBatch);
    } 
}