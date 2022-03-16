/**
* @author Cloud Analogy
* @date 02/08/2021
* @description Batch_SyncAllTaskWithTTActions class is using to get all task of today and yesterday and calls another class for syncing.
*/
global with sharing class Batch_SyncAllTaskWithTTActions implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public Integer taskSuccessCount = 0;
    public Integer taskErrorCount = 0;
    public String syncObject;
    public Boolean forFirstTime;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description constructor......
* @param syncObject ......
* @param forFirstTime ...
*/
    public Batch_SyncAllTaskWithTTActions(String syncObject, Boolean forFirstTime){
        this.syncObject = syncObject;
        this.forFirstTime = forFirstTime;
    }
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param BC ...
* @return Database.QueryLocator taskquery ......
*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime myDT = System.now();
        myDT = myDT.addMinutes(-62);
        Boolean returnValue;
        if(syncObject != null){
            returnValue = !forFirstTime;
        }else{
            returnValue = adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c;
        }
        //Boolean returnValue = TelosTouchUtility.checkAsyncApexJob('Batch_SyncAllTaskWithTTActions'); 
        String taskquery = 'SELECT Who.Name, Owner.id, ';
        if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable()){
            for(String fieldAPI : Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().keySet()){
                if((fieldAPI != 'whatid') && (fieldAPI != 'type')){
                    taskquery += fieldAPI + ',';
                }
            }
        }       
        taskquery = taskquery.subString(0, taskquery.length() - 1);
        if(returnValue){
            taskquery += ' FROM Task WHERE (lastmodifieddate >=:myDT OR TelosTouchSF__TT_TaskId__c = NULL) AND IsDeleted = false AND IsRecurrence = false ALL ROWS';
        }else{
            taskquery += ' FROM Task WHERE IsDeleted = false AND IsRecurrence = false ALL ROWS';
        }
        return Database.getQueryLocator(String.escapeSingleQuotes(taskquery));
    }
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param BC ......
* @param tasklist ...
*/
    global void execute(Database.BatchableContext BC, List<Task> tasklist) {
        if((tasklist != null) && (tasklist.size() > 0)){
           TelosTouchSF.SFDataSyncWithTelosTouch.taskLogWrapper taskLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.syncAllTaskstoTTActions(tasklist);
            if(taskLogObj != null && taskLogObj.taskSuccessCount != null){
                taskSuccessCount += taskLogObj.taskSuccessCount;
            }
            if(taskLogObj != null && taskLogObj.taskErrorCount != null){
                taskErrorCount += taskLogObj.taskErrorCount;
            }
        }
    }  
               /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param BC ......
*/
    global void finish(Database.BatchableContext BC) { 
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        if(taskErrorCount != 0 || taskSuccessCount != 0){
           // createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','No Task records synced from Salesforce to TelosTouch', 'Aucun enregistrement de Tâche syncronisé de Salesforce à TelosTouch', 0));
       // }else{
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure', 'Failed Task sync records from Salesforce to TelosTouch', 'Échec de la syncronisation des Tâches de Salesforce à TelosTouch', taskErrorCount));
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success', 'Successful Task sync records from Salesforce to TelosTouch', 'Syncronisation réussie des Tâches de Salesforce à TelosTouch' ,taskSuccessCount));
        }
        if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
            insert createListOfLog; 
        }
        if(adminCredentials != null && adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c == false){
            adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c = true;
            System.enqueueJob(new UpdateCustomMetadataQueueable(adminCredentials, authenticationCredential));
        }
    }
}