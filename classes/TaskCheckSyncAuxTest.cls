/***
*                  ©2022 TelosTouch
* ==================================================
* 
* Description: Test class for the class TaskCheckSyncAux
* 
* Author: vinicius.duarte@telostouch.com
* 
***/
@isTest
public with sharing class TaskCheckSyncAuxTest {
    @TestSetup
    static void setup(){
        
        
        TelosTouchSF__TT_Salesforce_Mapping__c fieldTest = new TelosTouchSF__TT_Salesforce_Mapping__c(
            TelosTouchSF__Object_Name__c = 'Task',
            TelosTouchSF__Salesforce_Field__c = 'ActivityDate',
            TelosTouchSF__TT_Field__c = 'ActivityDate'
        );
        insert fieldTest;
        
        System.today().addDays(5);
        
        List<Task> lstTaskTest = new list<Task>();
        lstTaskTest.add(new Task(
            Subject = 'TaskCheckSyncAuxTest1',
            TelosTouchSF__Share_with_client_s__c = 'Yes',
            ActivityDate = System.today().addDays(5)
        ));
        lstTaskTest.add(new Task(
            Subject = 'TaskCheckSyncAuxTest2',
            TelosTouchSF__Share_with_client_s__c = 'No',
            ActivityDate = System.today().addDays(5)
        ));
        lstTaskTest.add(new Task(
            Subject = 'TaskCheckSyncAuxTest3',
            TelosTouchSF__Share_with_client_s__c = 'No',
            ActivityDate = System.today().addDays(5)
        ));
        insert lstTaskTest;
        
    }
    
    @IsTest
    static void testUnit() {
        
        list<String> lstSubject = new list<String>{
            'TaskCheckSyncAuxTest1', 
                'TaskCheckSyncAuxTest2', 
                'TaskCheckSyncAuxTest3'
                };
                    list<Task> lstTask = [SELECT Id FROM Task WHERE Subject IN: lstSubject];
        System.assert(!lstTask.isEmpty());
        
        Test.startTest();
        lstTask[0].ActivityDate = System.today().addDays(6);
        lstTask[1].Subject = 'TaskCheckSyncAuxTest2';
        lstTask[2].TelosTouchSF__Share_with_client_s__c = 'Yes';
        lstTask[0].TelosTouchSF__TT_Needs_Sync__c = false;
        lstTask[1].TelosTouchSF__TT_Needs_Sync__c = false;
        lstTask[2].TelosTouchSF__TT_Needs_Sync__c = false;
        update lstTask;
        list<Task> lstTaskUpd = [SELECT Id,TelosTouchSF__TT_Needs_Sync__c FROM Task WHERE Subject IN: lstSubject];
        System.assert(!lstTaskUpd.isEmpty());
        System.assert(lstTaskUpd[0].TelosTouchSF__TT_Needs_Sync__c == true);
        System.assert(lstTaskUpd[2].TelosTouchSF__TT_Needs_Sync__c == true);
        
        Test.stopTest();
        
    }
}