/***
 *                  ©2022 TelosTouch
 * ==================================================
 * 
 * Description: Test class for the class LeadTriggerForSyncingHandler
 * 
 * Author: vinicius.duarte@telostouch.com
 * 
***/
@isTest
public with sharing class LeadTriggerForSyncingHandlerTest {

    @TestSetup
    static void setup(){

        TelosTouchSF__TT_Salesforce_Mapping__c fieldTest = new TelosTouchSF__TT_Salesforce_Mapping__c(
            TelosTouchSF__Object_Name__c = 'Lead',
            TelosTouchSF__Salesforce_Field__c = 'FirstName',
            TelosTouchSF__TT_Field__c = 'first_name'
        );
        insert fieldTest;

        List<Lead> lstLeadTest = new list<Lead>();
        lstLeadTest.add(new Lead(
            FirstName = 'Name',
            LastName = 'Test',
            Company = 'Test',
            Email = 'LeadTriggerForSyncingHandler@test.com'
        ));
        lstLeadTest.add(new Lead(
            FirstName = 'Name',
            LastName = 'Test2',
            Company = 'Test',
            Email = 'LeadTriggerForSyncingHandler@test2.com'
        ));
        lstLeadTest.add(new Lead(
            FirstName = 'Name',
            LastName = 'Test3',
            Company = 'Test',
            Email = 'LeadTriggerForSyncingHandler@test3.com'
        ));
        insert lstLeadTest;

    }

    @IsTest
    static void testUnit() {
        
        list<Lead> lstLead = [SELECT Id FROM Lead WHERE email LIKE 'LeadTriggerForSyncingHandler%'];
        System.assert(!lstLead.isEmpty());
        
        Test.startTest();
            lstLead[0].FirstName = 'Namee';
            lstLead[1].City = 'Test';
            lstLead[2].FirstName = 'Nameeee';
            update lstLead;

            list<Lead> lstLeadUpt = [SELECT Id,TelosTouchSF__TT_Last_Modified_Date__c FROM Lead WHERE email LIKE 'LeadTriggerForSyncingHandler%'];
            System.assert(!lstLeadUpt.isEmpty());
            System.assert(lstLeadUpt[0].TelosTouchSF__TT_Last_Modified_Date__c != null);
            System.assert(lstLeadUpt[1].TelosTouchSF__TT_Last_Modified_Date__c == null);
            System.assert(lstLeadUpt[2].TelosTouchSF__TT_Last_Modified_Date__c != null);

        Test.stopTest();
        
    }
    
}
