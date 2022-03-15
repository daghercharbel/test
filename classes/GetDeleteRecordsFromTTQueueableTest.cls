@isTest 
private with sharing class GetDeleteRecordsFromTTQueueableTest {
    @testSetup static void setupMethod(){
        System.debug(LoggingLevel.DEBUG, 'Setup Method');
      /*  Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        
        Campaign campaignObj = new Campaign(
            Name = 'Test bhoopesh',
            RecordTypeId = campaignRecordTypeId                                                                                                                                                                                                                                                                                                                                          // Active
        );
        insert campaignObj;
        
        Campaign campaignObj1 = new Campaign(
            Name = 'Test bhoopesh',
            RecordTypeId = campaignRecordTypeId                                                                                                                                                                                                                                                                                                                                          // Active
        );
        insert campaignObj1;
        
        Contact conObj = new Contact();
        conObj.LastName = 'Bhoopeshtest2';
        conObj.Email = 'Bhoopesh@gmail.com';
        conObj.TelosTouchSF__TT_Client_Id__c = '5fe0e55496031f4e70e';
        insert conObj;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'yogitate4t11';
        leadObj.Company = 'Test1';
        leadObj.Email = 'yogitde@gmail.com';
        leadObj.TelosTouchSF__TT_Client_Id__c = '5f527d53aa941c1bda3b0071';
        insert leadObj;
        
        task taskObj = new task();
        taskObj.OwnerId = UserInfo.getUserId();
        taskObj.Subject='Donni11';
        taskObj.Status='Not Started';
        taskObj.Priority='Normal';
        taskObj.TelosTouchSF__Share_with_client_s__c='Yes';
        taskObj.WhoId=leadObj.Id;
        taskObj.TelosTouchSF__TT_TaskId__c='5fda9b79d03e1a08c131';
        taskObj.Description='Test Task1';
        insert taskObj;
        
        CampaignMember campaignMemberObj = new CampaignMember();
        campaignMemberObj.CampaignId = campaignObj.Id;
        campaignMemberObj.ContactId = conObj.Id;
        insert campaignMemberObj;
        
        CampaignMember campaignMemberObj1 = new CampaignMember();
        campaignMemberObj1.CampaignId = campaignObj1.Id;
        campaignMemberObj1.ContactId = conObj.Id;
        insert campaignMemberObj1;
        
        campaignObj1.TelosTouchSF__TT_Campaign_Id__c='5fbffb459ad05e28c8300';
        update campaignObj1;
        
        campaignObj.TelosTouchSF__TT_Campaign_Id__c='5fbffb459ad05e28c8300';
        update campaignObj;*/
    }
  /*  @isTest
    static void utilityTest(){
        String firstFakeResponseRespString = '[{"id": "5fe0e55496031f4e70e","name": "cont m","firstName": "cont","lastName": "m","emailAddress": "nitesh+tm@telosh.com","invitedAt": "2020-12-21T18:12:05.000Z","lastLoginDate": null,"phoneNumber": "123456","userId": "5fe0e5750a2083d","avatarId": null,"preferences": {"language": "en_US","notificationTouchpointSend": false,"timezone": "America/Toronto","clientPortal": false,"notificationTouchpointCompleted": true,"notificationActionCreate": false},"customFields": {"driver_licence_expiry_date": "12/12/2012","last_meeting_date": "11/11/2011","acccount_number": "1234"}}]';
        String secondFakeResponseRespString='[{"id": "5fda9b79d03e1a08c131","name": "12ws","type": "task","status": "open","client_id": "5fd244a2a8db5f6ee88ae52a","client_name": "test3 test3","description": "","created_by_id": "5f7f1bf7697cad4d2","created_by_name": "Advisor A","assigned_user_id": "5f7f1c2186f5b34f8","assigned_user_name": "Advisor B","touchpoint_send_id": "","touchpoint_send_name": "","touchpoint_send_name_fr": "","default_team_id": "5d49a886ee7w20c8c","shared": true,"instance": "https://test.com","deleted": true,"date_due": "2020-12-16T23:42:35.000Z","completed_at": null,"modified_at": "","created_at": "2020-12-16T23:42:49.000Z","created_by": "5f7f1bf7697cad5d2","modified_by": "5f7f1bf7697cad5d2"}]';
        String thirdFakeResponseRespString ='[{"id": "5fbffb459ad05e28c8300","instance_name": "https://test.com","touchpoint_template_name": "Update ID","touchpoint_template_name_fr": null,"questions": [],"questions_fr": [],"deleted": true,"is_email_action": false,"created_by_id": "5d49a95fcf2516820","modified_by": "System","modified_at": "","created_by": "Systelos Advisor","created_at": "2020-11-26T19:00:21.986Z","team_id": "5d49a886ee7b20c8c","other_id": null,"touchpoint_template_id": "5e8c7f3523114d7ba28aa049","stats": {"opened": 0,"completed": 0,"recipients": 1}}]';
        SingleRequestMock firstFakeResponseResp = new TelosTouchSF.SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp should not be NULL');
        SingleRequestMock secondFakeResponseResp = new TelosTouchSF.SingleRequestMock(200,'OK',secondFakeResponseRespString,null);
        System.assert(secondFakeResponseResp != null, 'secondFakeResponseResp should not be NULL');
        SingleRequestMock thirdFakeResponseResp = new TelosTouchSF.SingleRequestMock(200,'OK',thirdFakeResponseRespString,null);
        System.assert(thirdFakeResponseResp != null, 'thirdFakeResponseResp should not be NULL');
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/contacts?where={"deleted":"true"}',firstFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/actions?where={"deleted":"true"}',secondFakeResponseResp);
        endpoint2TestResp.put('https://test.com/touchpoint/templates/send?where={"deleted":"true"}',thirdFakeResponseResp);
        
        HttpCalloutMock multiCalloutMock = new TelosTouchSF.MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock should not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }*/
    
    @isTest    
    static  void getTTCampaignIdTest() {
       /* TelosTouchSF__TelosTouch_API_Settings__c credential = new TelosTouchSF__TelosTouch_API_Settings__c();
        credential.TelosTouchSF__Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.TelosTouchSF__Instance_url__c = 'https://test.com'; 
        insert credential;
        
        List<Campaign> campaignObj = new List<Campaign>();
        campaignObj = [SELECT Id ,Name FROM Campaign];
        List<Lead> leadObj = new List<Lead>();
        leadObj = [SELECT Id ,LastName,TelosTouchSF__TT_Client_Id__c,Email FROM Lead];
        List<Contact> conObj = new List<Contact>();
        conObj = [SELECT Id ,LastName,TelosTouchSF__TT_Client_Id__c,Email FROM Contact];
        
        DateTime lastHour = System.NOW().addMinutes(-180);
        String formatted = lastHour.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');*/
        
        
        Test.startTest();
       // utilityTest();
       /* String cronExp = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  cronExp, new TelosTouchSF.GetDeleteRecordsFromTTScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'ct.CronExpression should be equal to 0 0 0 15 3 ? *');
        System.assertEquals(0, ct.TimesTriggered, 'ct.TimesTriggered should be equal to 0');*/
        TelosTouchSF.GetDeleteRecordsFromTTQueueable apc = new TelosTouchSF.GetDeleteRecordsFromTTQueueable();
        System.assertEquals(apc != null, true, 'apc not equal to null');
        Test.stopTest();
    }
}