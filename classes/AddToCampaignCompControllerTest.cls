@isTest
public with sharing class AddToCampaignCompControllerTest {
    @testSetup static void setupMethod(){
        Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        Campaign campaignObj = new Campaign(
            Name = 'Test bhoopesh',                                                                                                                                                                                                                                                                                                                  // Campaign Name
            RecordTypeId = campaignRecordTypeId                                                                                                                                                                                                                                                                                                                                          // Active
        );
        insert campaignObj;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        acc.Name = 'Test Account 1';
        update acc;
        
        Account acc1 = new Account(name='Test Account');
        insert acc1;     
        
        delete acc1;
        
        Contact conObj = new Contact();
        conObj.LastName = 'bhoopesh test';
        conObj.Email = 'bhoopesh@abc.com';
        conObj.TT_Client_Id__c = '8379ej';
        insert conObj;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'bhoopesh test';
        leadObj.Company = 'Test';
        leadObj.Email = 'bhoopeshtest@abc.com';
        leadObj.TT_Client_Id__c = 'qwkjhei376378';
        insert leadObj;
        
    } 
    @isTest
    static  void addToCampaignCompControllerTestMethod() {
        List<Campaign> campaignList = new List<Campaign>();
        campaignList = [SELECT Id ,Name FROM Campaign];
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id ,Name FROM Account];
        List<Contact> contactList = new List<Contact>();
        contactList = [SELECT Id ,LastName,Email FROM Contact];
        List<Lead> leadList = new List<Lead>();
        leadList = [SELECT Id ,LastName,Company,Email FROM Lead];
        Test.startTest();
        string result = AddToCampaignCompController.getObjectDetails('Campaign',campaignList[0].Id);
        System.assertEquals(result, 'Test bhoopesh', 'result should be equal to Test bhoopesh');
        string resultOfupdateCampaignRecord = AddToCampaignCompController.updateCampaignRecord('Contact',contactList[0].Id,campaignList[0].Id,'Test Campaign');
        System.assertEquals(resultOfupdateCampaignRecord,campaignList[0].Id, 'resultOfupdateCampaignRecord should be equalt to campaignList[0].Id');
        string resultOfupdateCampaignRecord2 = AddToCampaignCompController.updateCampaignRecord('lead',leadList[0].Id,campaignList[0].Id,'Test Campaign');
        System.assertEquals(resultOfupdateCampaignRecord2,campaignList[0].Id, 'resultOfupdateCampaignRecord2 should be equalt to campaignList[0].Id');
        List<RecordType> resultOfcampaignRecordTypeList = AddToCampaignCompController.getCampaignRecordType();
        System.assertEquals(resultOfcampaignRecordTypeList != null, true, 'resultOfcampaignRecordTypeList should not be NULL');
        Campaign resultOfupdateCampaign = AddToCampaignCompController.createNewCampaignApex('Test Campaign','TelosTouch');
        System.assertEquals(resultOfupdateCampaign.Name,'Test Campaign', 'resultOfupdateCampaign.Name should be eqaul to Test Campaign');
        //string result1 = 
        AddToCampaignCompController.getObjectDetails('Account',accountList[0].Id);
        //string resultOfupdateCampaignRecord3 = 
        AddToCampaignCompController.updateCampaignRecord('Account',accountList[0].Id,campaignList[0].Id,'Test Campaign');
        Test.stopTest();
    }
}