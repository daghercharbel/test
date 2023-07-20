/**
*                  ©2022 TelosTouch
* ==================================================
* 
* Description: Auxiliar class to the flow taskCheckSync 
* 
* Author: vinicius.duarte@telostouch.com
* Test Class: taskCheckSyncAuxTest
* @description Auxiliar class to the flow taskCheckSync  ....
*/
global with sharing class TaskCheckSyncAux {
    
    //Method responsible to for checking if any of the fields utilized in the sync was modified
         /**
* @author Cloud Analogy
* @date 02/08/2021
* @description checkTaskModification ....
* @param oldLstTask ....
* @return List<TaskCheckSyncAux2Result> ...
*/
    @InvocableMethod
    public static List<TaskCheckSyncAux2Result> checkTaskModification(list<Task> oldLstTask) {
        
        try{
            
            set<String> setField = new set<String>();
            set<Id> setTaskId = new set<Id>();
            map<String, Task> oldMapTask = new map<String, Task>();
            List<TaskCheckSyncAux2Result> results = new List<TaskCheckSyncAux2Result>();
            
            for(TelosTouchSF__TT_Salesforce_Mapping__c aField : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                 FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                 WHERE TelosTouchSF__Object_Name__c = 'Task' WITH SECURITY_ENFORCED])
            {
                setField.add(aField.TelosTouchSF__Salesforce_Field__c);
            }
            
            //OwnerId and WhoId is not mapped but is sent in the sync, we are looking a better way to add it dynamically
            setField.add('OwnerId');
            setField.add('WhoId');
            setField.add('TelosTouchSF__Share_with_client_s__c');
            
            for(Task aTask : oldLstTask){
                oldMapTask.put(aTask.Id, aTask);
                setTaskId.add(aTask.Id);
            }
            
            String query = 'SELECT Id, TelosTouchSF__TT_Needs_Sync__c';
            for(String aField : setField){
                query += ','+String.escapeSingleQuotes(aField).replace('\\','');
            }
            
            query += ' FROM Task WHERE Id IN: setTaskId';
            
            list<Task> lstTask = Database.query(query);
            
            for(Task aTask : lstTask){
                Task oldTask = oldMapTask.get(aTask.Id);
                TaskCheckSyncAux2Result result = new TaskCheckSyncAux2Result();
                Boolean needsSync = false;
                for(String aField : setField){
                    if(aTask.get(aField) != oldTask.get(aField)){
                        needsSync = true;
                        break;
                    }
                }
                result.taskResult = new Task( Id = aTask.Id, TelosTouchSF__TT_Needs_Sync__c = needsSync);
                results.add(result);
            }
            return results;
            
        } catch (Exception ex) {
            
            System.debug('Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
            return null;
            
        }
    }
       /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description TaskCheckSyncAux2Result ....
*/
    global class TaskCheckSyncAux2Result {
                /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description taskResult ....
*/
        @InvocableVariable
        global Task taskResult;
    }
}