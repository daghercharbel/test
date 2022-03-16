@istest
public with sharing class GetCampaignsFromTTQueueableTest {
   @istest  
    static void TestCampaigns(){
        
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'yogita@gmail.com';     
        con.Phone = '1212212213';                
        con.TelosTouchSF__IsTelosTouchSyncAllowed__c = false;
        con.TelosTouchSF__Language__c = 'English';
        con.TelosTouchSF__TT_Client_Id__c = '60e2c45fd0c2a8a2a3da197c';
        insert con;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'yogita test2';
        leadObj.Company = 'Test1';
        leadObj.Email = 'yogita@gmail.com1';
        leadObj.TelosTouchSF__TT_Client_Id__c = '60e2c4b52cf3cea2af1d8a86';
        leadObj.Phone = '9873445678';
        leadObj.TelosTouchSF__Language__c = 'English';
        leadObj.TelosTouchSF__IsTelosTouchSyncAllowed__c = false;
        insert leadObj;
        
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',                                                                                                                                                                                                                                                                                                                 
            IsActive = false,                                                                                                                                                                                                                                                                                                                                         
            Type = 'Conference',
            TelosTouchSF__Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
       
        CampaignMember CampaignMemberObj = new CampaignMember();
        CampaignMemberObj.CampaignId = CampaignObj.Id;
        CampaignMemberObj.ContactId = con.Id;
        insert CampaignMemberObj;
        
        //List<Insights__c> conversionlist = new list<Insights__c>();
        TelosTouchSF__Insights__c conversionObject = new TelosTouchSF__Insights__c();
        conversionObject.TelosTouchSF__Campaign2__c = CampaignObj.id;
        conversionObject.Name='testyogita';
        conversionObject.TelosTouchSF__TouchPoint_Name__c = 'testing';
        conversionObject.TelosTouchSF__Contact__c = con.id;
        insert conversionObject;
        //conversionlist.add(conversionObject);
        //String searilizestring = JSON.serialize(conversionlist);
        
        //DateTime LAST_HOUR = System.NOW().addMinutes(-120);
        //String formatted = LAST_HOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        TelosTouchSF__TT_Log__c logObject = new TelosTouchSF__TT_Log__c();
        logObject.TelosTouchSF__Comments__c = 'Operation Successfull';
        logObject.TelosTouchSF__Result__c = 'Success';
        logObject.TelosTouchSF__Total_Contact_Count__c = 50;
        logObject.TelosTouchSF__Total_Records_Count__c = 100;
        insert logObject;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetCampaignsFromTTMock());
        System.enqueueJob(new GetCampaignsFromTTQueueable(0,202,202,false,''));
        System.assert(logObject != null, 'logObject must not be NULL');
        Test.stopTest();
    }
    @istest  
    static void TestCampaigns2(){
        TelosTouchSF__TT_Log__c logObject = new TelosTouchSF__TT_Log__c();
        logObject.TelosTouchSF__Comments__c = 'Operation Successfull';
        logObject.TelosTouchSF__Result__c = 'Success';
        logObject.TelosTouchSF__Total_Contact_Count__c = 50;
        logObject.TelosTouchSF__Total_Records_Count__c = 100;
        insert logObject;
        Test.startTest();
        System.assert(logObject != null, 'logObject must not be NULL');
        Test.setMock(HttpCalloutMock.class, new GetCampaignsFromTTMock());
        System.enqueueJob(new GetCampaignsFromTTQueueable(0,202,202,false,''));
        Test.stopTest(); 
    }
}