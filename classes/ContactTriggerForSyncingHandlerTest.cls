/***
 *                  ©2022 TelosTouch
 * ==================================================
 * 
 * Description: Test class for the class ContactTriggerForSyncingHandler
 * 
 * Author: vinicius.duarte@telostouch.com
 * 
***/
@isTest
public with sharing class ContactTriggerForSyncingHandlerTest {

    @TestSetup
    static void setup(){

        TelosTouchSF__TT_Salesforce_Mapping__c fieldTest = new TelosTouchSF__TT_Salesforce_Mapping__c(
            TelosTouchSF__Object_Name__c = 'Contact',
            TelosTouchSF__Salesforce_Field__c = 'FirstName',
            TelosTouchSF__TT_Field__c = 'first_name'
        );
        insert fieldTest;

        List<Contact> lstCttTest = new list<Contact>();
        lstCttTest.add(new Contact(
            FirstName = 'Name',
            LastName = 'Test',
            Email = 'ContactTriggerForSyncingHandler@test.com'
        ));
        lstCttTest.add(new Contact(
            FirstName = 'Name',
            LastName = 'Test2',
            Email = 'ContactTriggerForSyncingHandler@test2.com'
        ));
        lstCttTest.add(new Contact(
            FirstName = 'Name',
            LastName = 'Test3',
            Email = 'ContactTriggerForSyncingHandler@test3.com'
        ));
        insert lstCttTest;

    }

    @IsTest
    static void testUnit() {
        
        list<Contact> lstCtt = [SELECT Id FROM Contact WHERE email LIKE 'ContactTriggerForSyncingHandler%'];
        System.assert(!lstCtt.isEmpty());
        
        Test.startTest();
            lstCtt[0].FirstName = 'Namee';
            lstCtt[1].MailingCity = 'Test';
            lstCtt[2].FirstName = 'Nameeee';
            update lstCtt;

            list<Contact> lstCttUpt = [SELECT Id,TelosTouchSF__TT_Last_Modified_Date__c FROM Contact WHERE email LIKE 'ContactTriggerForSyncingHandler%'];
            System.assert(!lstCtt.isEmpty());
            System.assert(lstCttUpt[0].TelosTouchSF__TT_Last_Modified_Date__c != null);
            System.assert(lstCttUpt[1].TelosTouchSF__TT_Last_Modified_Date__c == null);
            System.assert(lstCttUpt[2].TelosTouchSF__TT_Last_Modified_Date__c != null);

        Test.stopTest();
        
    }
    
}