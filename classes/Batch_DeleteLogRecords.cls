/*
* @author Cloud Analogy
* @date 26/08/2021.
* @description batch delete log records class ....
*/
global with sharing class Batch_DeleteLogRecords Implements Database.batchable<sobject>{
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description start method ...
* @param bc ...
@return Database.QueryLocator ....*/
    global Database.QueryLocator start(Database.BatchableContext bc){
        Datetime dateValue = Datetime.now().addDays(-2);
        return Database.getQueryLocator(String.escapeSingleQuotes(
            'SELECT Id FROM TelosTouchSF__TT_Log__c WHERE CreatedDate <=: dateValue AND IsDeleted = false ALL ROWS'));   
    }
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description execute method...
* @param bc ...
* @param scope ...
*/
    global  void execute(Database.BatchableContext bc,List<TelosTouchSF__TT_Log__c> scope){
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && TelosTouchSF__TT_Log__c.sObjectType.getDescribe().isDeletable()){
            DataBase.delete(scope,false);
        }
    }
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description finish method ...
* @param bc ...
*/
    global void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
}