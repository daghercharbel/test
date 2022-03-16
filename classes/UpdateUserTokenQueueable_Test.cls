@isTest
private with sharing class UpdateUserTokenQueueable_Test {
    @isTest
    static void updateUserTokenQueueable() {
        String firstFakeResponseRespString = '{ "id": "5f4e65e9d5d22d1cbed93f3a", "instance_name": "https://test.com", "touchpoint_template_name": "Client is 5 Year Old and No RESP Yet", "touchpoint_template_name_fr": null, "questions": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "questions_fr": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "deleted": false, "created_by_id": "1", "modified_by": "System", "modified_at": "2020-09-01T15:16:57.041Z", "created_by": "Admin Admin", "created_at": "2020-09-01T15:16:57.041Z", "team_id": "5925d8eeaedb9e14c", "other_id": "7012w000000YUQ2AAO", "touchpoint_template_id": "5e947ef0574573795fa7fa21" }';
        SingleRequestMock firstFakeResponseResp = new SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp must not be NULL');

        Map<String, HttpCalloutMock> endpoint2TestResp =
            new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/crm-v2/api/v1/App/user/',firstFakeResponseResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null ,'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'].get(0);  
        User userObj = new User(firstname= 'Bhoopesh2',lastname='Test',Alias='Test',email = 'Bhoopesh@gmail1.com',
                                username= 'Bhoopesh@gmail2.com', profileId= p.id, emailencodingkey='UTF-8',
                                languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                TelosTouchSF__TT_UserId__c='test',Token__c='test',TelosTouchSF__TT_UserName__c='test',IsActive= true);
        System.runAs(userObj) {
        Test.setCreatedDate(userObj.Id, date.today().addDays(-1));
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthenticationMock());    
        String jobId = System.schedule('ScheduleApexClassTest2',  CRON_EXP, new UpdateUserTokenScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'ct.CronExpression must be equal to 0 0 0 15 3 ? *0');
        System.assertEquals(0, ct.TimesTriggered, 'ct.TimesTriggered must be equal to 0');
        Test.stopTest();
        }
    }
}