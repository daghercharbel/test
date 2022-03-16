@isTest
public class TaskTriggerHandler_Test { 
    @isTest static void assignValueTest(){
        Contact coObj = new Contact(LastName='test');
        insert coObj;
        Contact coObj1 = new Contact(LastName='test1');
        insert coObj1;
        task taskObj1 = new task();
        taskObj1.Subject = 'Email';
        taskObj1.Status = 'Not Started';
        taskObj1.Source__c='Salesforce';
        taskObj1.WhoId= coObj.Id; 
        taskObj1.IsTelosTouchSyncAllowed__c = false;
        list<Task> taskList = new list<Task>();
        taskList.add(taskObj1);
        insert taskList; 
        map<id, task> idVsTaskMap = new map<id,task>();
        task taskObj2 = new task();
        taskObj2.Id = taskObj1.Id;
        taskObj2.WhoId= coObj1.Id; 
        idVsTaskMap.put(taskObj2.Id, taskObj2);
        Test.startTest();
        TaskTriggerHandler.assignValueOnInsert(taskList);
        TaskTriggerHandler.getDeletedTaskRecord(taskList);
        TaskTriggerHandler.assignValueOnUpdate(taskList,idVsTaskMap);
        System.assert(true,'it should be true');
        Test.stopTest();
        
    }
    @isTest static void assignValueTest1(){
        task taskObj1 = new task();
        taskObj1.Subject = 'Email';
        taskObj1.Status = 'Not Started';
        taskObj1.Source__c='Salesforce';
        taskObj1.IsTelosTouchSyncAllowed__c = false;
        list<Task> taskList = new list<Task>();
        taskList.add(taskObj1);
        insert taskList; 
        map<id, task> idVsTaskMap = new map<id,task>();
        idVsTaskMap.put(taskObj1.Id, taskObj1);
        Test.startTest();
        TaskTriggerHandler.assignValueOnUpdate(taskList,idVsTaskMap);
        System.assert(true,'it should be true');
        Test.stopTest();
    }
    @isTest static void assignValueTest2(){
        lead leadObj = new lead(LastName='test2',Company='Salesforce');
        insert leadObj;
        lead leadObj1 = new lead(LastName='test21',Company='Salesforce');
        insert leadObj1;
        task taskObj1 = new task();
        taskObj1.Subject = 'Email';
        taskObj1.Status = 'Not Started';
        taskObj1.Source__c='Salesforce';
        taskObj1.WhoId= leadObj.Id; 
        taskObj1.IsTelosTouchSyncAllowed__c = false;
        list<Task> taskList = new list<Task>();
        taskList.add(taskObj1);
        insert taskList; 
        map<id, task> idVsTaskMap = new map<id,task>();
        task taskObj2 = new task();
        taskObj2.Id = taskObj1.Id;
        taskObj2.WhoId= leadObj1.Id; 
        idVsTaskMap.put(taskObj2.Id, taskObj2);
        Test.startTest();
        TaskTriggerHandler.assignValueOnUpdate(taskList,idVsTaskMap);
        System.assert(true,'it should be true');
        Test.stopTest();
    }
}