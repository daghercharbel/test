/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TaskDelete_Batch ...
*/
global with sharing class TaskDelete_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global List<Task> deletedtasklist ;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description constructor ...
* @param  tasklists ..
*/
    global TaskDelete_Batch(List<Task>  tasklists) { 
        this.deletedtasklist = tasklists;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param  bc ..
@return Iterable<sObject> ...
     */
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return deletedtasklist;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param  bc ..
* @param  sObjList ..
*/
    global void execute(Database.BatchableContext bc, List<Sobject> sObjList) {
        TelosTouchSF.SFDataSyncWithTelosTouch.deleteTask(sObjList);
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param  bc ..
*/
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
    
}