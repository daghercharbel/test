/***
 *                  ©2022 TelosTouch
 * ==================================================
 * 
 * Description: Auxiliar class to the flow taskCheckSync 
 * 
 * Author: vinicius.duarte@telostouch.com
 * Test Class: taskCheckSyncAuxTest
***/
global class TaskCheckSyncAux {

    //Method responsible to for checking if any of the fields utilized in the sync was modified
    @InvocableMethod
    public static list<Task> checkTaskModification(list<Task> oldLstTask) {

        set<String> setField = new set<String>();
        set<Id> setTaskId = new set<Id>();
        map<String, Task> oldMapTask = new map<String, Task>();

        for(TelosTouchSF__TT_Salesforce_Mapping__c aField : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                WHERE TelosTouchSF__Object_Name__c = 'Task'])
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
            for(String aField : setField){
                if(aTask.get(aField) != oldTask.get(aField)){
                    aTask.TelosTouchSF__TT_Needs_Sync__c = true;
                    break;
                }
            }
        }

        return lstTask;

    }
}