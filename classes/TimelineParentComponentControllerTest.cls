@isTest
private with sharing class TimelineParentComponentControllerTest {
    
    @testSetup static void setupMethod(){
        Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        Campaign CampaignObj = new Campaign(
            Name = 'Test bhoopesh',
            RecordTypeId = campaignRecordTypeId
        );
        insert CampaignObj;
        Campaign CampaignObj1 = new Campaign(
            Name = 'Test bhoopesh',
            RecordTypeId = campaignRecordTypeId
        );
        insert CampaignObj1;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        CampaignObj1.TT_Campaign_Id__c='123';
        update CampaignObj1;
        
        CampaignObj.TT_Campaign_Id__c='test';
        update CampaignObj;
        
    } 
    
    @isTest
    static  void gettaskObjData_Method2_Test() {
        
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com'; 
        insert credential;
        
        Contact conObj2 = new Contact();
        conObj2.LastName = 'bhoopesh test1';
        conObj2.Email = 'bhoopesh@abc.com1';
        conObj2.TT_Client_Id__c = 'abc68791';
        insert conObj2;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'bhoopesh test1';
        leadObj.Company = 'Test1';
        leadObj.Email = 'bhoopeshtest@abc.com1';
        leadObj.TelosTouchSF__TT_Client_Id__c = 'abcff1233';
        insert leadObj;
        
        task taskObj5 = new task();
        taskObj5.Subject='Donni';
        taskObj5.Status='Not Started';
        taskObj5.Priority='Normal';
        taskObj5.Share_with_client_s__c='Yes';
        taskObj5.WhoId=conObj2.Id;
        taskObj5.Description='Test Task';
        insert taskObj5;
        
        task taskObj = new task();
        taskObj.Subject = 'Donni11';
        taskObj.Status = 'Not Started';
        taskObj.Priority = 'Normal';
        taskObj.Share_with_client_s__c = 'Yes';
        taskObj.WhoId = leadObj.Id;
        taskObj.Description = 'Test Task1';
        insert taskObj;
        
        task taskObj1 = new task();
        taskObj1.Subject = 'Donni';
        taskObj1.Status = 'Not Started';
        taskObj1.Priority = 'Normal';
        taskObj1.Share_with_client_s__c = 'Yes';
        taskObj1.TT_TaskId__c = '5fbea7ce9505ef1d9affb150';
        taskObj1.WhoId = leadObj.Id;
        taskObj1.Description = 'Test Task';
        insert taskObj1;
        
        task taskObj4 = new task();
        taskObj4.Subject = 'Donni';
        taskObj4.Status = 'Not Started';
        taskObj4.Priority = 'Normal';
        taskObj4.Share_with_client_s__c='Yes';
        taskObj4.TT_TaskId__c='5fc0dc425669d846a1670e29';
        taskObj4.WhoId=LeadObj.Id;
        taskObj4.Description='Test Task';
        insert taskObj4;
        
        List<Campaign> CampaignObj = new List<Campaign>();
        CampaignObj = [SELECT Id ,Name,TT_Campaign_Id__c FROM Campaign];
        
        CampaignMember CampaignMemberObj = new CampaignMember();
        CampaignMemberObj.CampaignId = CampaignObj[0].Id;
        CampaignMemberObj.ContactId = conObj2.Id;
        insert CampaignMemberObj;
        
        CampaignMember CampaignMemberObj1 = new CampaignMember();
        CampaignMemberObj1.CampaignId = CampaignObj[1].Id;
        CampaignMemberObj1.ContactId = conObj2.Id;
        insert CampaignMemberObj1;
        
        List<Lead> LeadObj2 = new List<Lead>();
        LeadObj2 = [SELECT Id ,LastName,TT_Client_Id__c,Email FROM Lead];
        List<Contact> conObj = new List<Contact>();
        conObj = [SELECT Id ,LastName,TT_Client_Id__c,Email FROM Contact];
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id ,Name FROM Account];
        
        String firstFakeResponseRespString = '{ "id": "5f4e65e9d5d22d1cbed93f3a", "instance_name": "https://test.com", "touchpoint_template_name": "Client is 5 Year Old and No RESP Yet", "touchpoint_template_name_fr": null, "questions": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "questions_fr": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "deleted": false, "created_by_id": "1", "modified_by": "System", "modified_at": "2020-09-01T15:16:57.041Z", "created_by": "Admin Admin", "created_at": "2020-09-01T15:16:57.041Z", "team_id": "5925d8eeaedb9e14c", "other_id": "7012w000000YUQ2AAO", "touchpoint_template_id": "5e947ef0574573795fa7fa21" }';
        String secondFakeResponseRespString='{ "id": "5f527d53aa941c1bda3b0071", "created_at": "2020-09-04T17:45:55.826Z", "created_by": "Jad Chehlawi", "name": "Considering Purchase of a Property", "name_fr": null, "touchpoint_template_id": "5e947ef0574573795fa7f9a5", "conversations": [ { "conversation_id": "5f527d53aa941c1bda3b0073", "completed_at": "2020-09-04T18:42:23.772Z", "opened_at": "2020-09-04T17:59:38.301Z", "status_touchpoint": "completed", "user_id": "5f526a4d219d3865a", "contact_id": "5f5267ce48c9a601c", "user_name": null, "language": null, "avatarId": null } ] }';
        String thirdFakeResponseRespString ='{"emailAddress": "mojitihejgov@gmail.com","id":"5f4a2f6fbbf7da0b8","assignedUserId":"5e95dc6839a36082d","assignedUserName":"telostouch_advisor"}';
        String fourthFakeResponseRespString = '{"past": [{"type": "task","id": "5fc0dc425669d846a1670e29","name": "Send Letter","name_fr": "","description": "","status": "open","shared": 1,"dateStart": "2020-11-27 00:00:00","completedAt": null,"createdAt": "2020-11-27 00:00:00","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "","image_id": ""},{"type": "touchpoint","id": "5fc0dc425669d846a1670e59","name": "Send Letter","name_fr": "","description": "","status": "open","shared": 0,"dateStart": "2020-11-27 00:00:00","completedAt": null,"createdAt": "2020-11-27 00:00:00","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "123","image_id": ""},{"type": "task","id": "5fc0dc425669d846a1670e19","name": "Send Letter","name_fr": "","description": "","status": "open","shared": 1,"dateStart": "2020-11-27 00:00:00","completedAt": null,"createdAt": "2020-11-27 00:00:00","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "","image_id": ""},{"type": "touchpoint","id": "5fbea5e78217721d9a8e1815","name": "Tax Season","name_fr": null,"description": null,"status": "none","shared": 1,"dateStart": "2020-11-25T18:43:51.443Z","completedAt": "","createdAt": "2020-11-25T18:43:51.443Z","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "5fbea5e78217721d9a8e1811","image_id": null}],"future": [{"type": "task","id": "5fbea7ce9505ef1d9affb150","name": "1230","name_fr": "","description": "","status": "open","shared": 1,"dateStart": "2020-12-03T00:00:00.000Z","completedAt": null,"createdAt": "2020-11-25T00:00:00.000Z","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "","image_id": ""},{"type": "touchpoint","id": "5fbea7ce9505ef1d9affb151","name": "1230","name_fr": "","description": "","status": "open","shared": 0,"dateStart": "2020-12-03T00:00:00.000Z","completedAt": null,"createdAt": "2020-11-25T00:00:00.000Z","openedAt": "","assignedUserId": "1","assignedUserName": "Admin Admin","createdById": "1","createdByName": "Admin Admin","touchpoint_send_id": "","image_id": ""}],"pastTotal": 2,"futureTotal": 2}';
        String fifthFakeResponseRespString = '{"past": [],"future": [],"pastTotal": 2,"futureTotal": 2}';
        String sixthFakeRepomseRespString ='[{"deviceToken":null,"id":"60e435f0d0c2a8a2a3da19bd","first_name":"Swapnil","last_name":"PUT Sen Keycloak 4","email":"demo@gmail.com","user_id":null,"phone":"","language":"en_US","created_by":"6240d32f-a652-472c-85bf-42cb27dd2420","invited_at":null,"modified_at":"2021-07-06T10:55:06.000Z","created_at":"2021-07-06T10:52:32.000Z","last_login_date":null,"avatar_id":null,"deleted":false,"custom_fields":null,"preferences":{"notificationTouchpointSend":true,"language":"en_US"},"accepts_calls":true,"type":"client","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420","other_id":null},{"deviceToken":null,"id":"60e435f0d0c2a8a2a3da19be","first_name":"Swapnil","last_name":"PUT Sen Keycloak 5","email":"random@gmail.com","user_id":null,"phone":"","language":"en_US","created_by":"6240d32f-a652-472c-85bf-42cb27dd2420","invited_at":null,"modified_at":"2021-07-06T10:55:06.000Z","created_at":"2021-07-06T10:52:32.000Z","last_login_date":null,"avatar_id":null,"deleted":false,"custom_fields":null,"preferences":{"notificationTouchpointSend":true,"language":"en_US"},"accepts_calls":true,"type":"client","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420","other_id":null}]';
        String batch1String = '';
        String batch2String = '{ "id": "5f527d53aa941c1bda3b0071", "created_at": "2020-09-04T17:45:55.826Z", "created_by": "Jad Chehlawi", "name": "Considering Purchase of a Property", "name_fr": null, "touchpoint_template_id": "5e947ef0574573795fa7f9a5", "conversations": [ { "conversation_id": "5f527d53aa941c1bda3b0073", "completed_at": "2020-09-04T18:42:23.772Z", "opened_at": "2020-09-04T17:59:38.301Z", "status_touchpoint": "completed", "user_id": "5f526a4d219d3865a", "contact_id": "5f5267ce48c9a601c", "user_name": null, "language": null, "avatarId": null } ] }';
        SingleRequestMock firstFakeResponseResp = new SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp must not be NULL');
        SingleRequestMock secondFakeResponseResp = new SingleRequestMock(200,'OK',secondFakeResponseRespString,null);
        System.assert(secondFakeResponseResp != null, 'secondFakeResponseResp must not be NULL');
        SingleRequestMock thirdFakeResponseResp = new SingleRequestMock(200,'OK',thirdFakeResponseRespString,null);
        System.assert(thirdFakeResponseResp != null, 'thirdFakeResponseResp must not be NULL');
        SingleRequestMock fourthFakeResponseResp = new SingleRequestMock(200,'OK',fourthFakeResponseRespString,null);
        System.assert(fourthFakeResponseResp != null, 'fourthFakeResponseResp must not be NULL');
        SingleRequestMock fifthFakeResponseResp = new SingleRequestMock(200,'OK',fifthFakeResponseRespString,null);
        System.assert(fifthFakeResponseResp != null, 'fifthFakeResponseResp must not be NULL');
        SingleRequestMock sixthFakeResponseResp = new SingleRequestMock(200,'OK',sixthFakeRepomseRespString,null);
        System.assert(sixthFakeResponseResp != null, 'sixthFakeResponseResp must not be NULL');
        SingleRequestMock batch1 = new SingleRequestMock(200,'OK',batch1String,null);
        System.assert(batch1 != null, 'batch1 must not be NULL');
        SingleRequestMock batch2 = new SingleRequestMock(200,'OK',batch2String,null);
        System.assert(batch2 != null, 'batch2 must not be NULL');
        

        Map<String, HttpCalloutMock> endpoint2TestResp =
        new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/touchpoint/templates/send/'+CampaignObj[0].Id,firstFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/test/clients',secondFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/123/clients',secondFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/contacts/'+conObj[0].TT_Client_Id__c,thirdFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/contacts/'+conObj[0].TT_Client_Id__c+'/timeline?includeChats=true&limit=90&skip=0&period=all&orderBy=DESC',fourthFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/contacts/'+conObj[0].TT_Client_Id__c+'/timeline?includeChats=true&limit=90&skip=90&period=all&orderBy=DESC',fifthFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/contacts/'+leadObj.TT_Client_Id__c+'/timeline?includeChats=true&limit=90&skip=0&period=all&orderBy=DESC',fourthFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/contacts/'+leadObj.TT_Client_Id__c+'/timeline?includeChats=true&limit=90&skip=90&period=all&orderBy=DESC',fifthFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v2/campaign2/clients',batch1);
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/'+CampaignObj[0].TT_Campaign_Id__c+'/clients',batch2);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        TimelineWrapper TimelineWrapperObj1 = TimelineParentComponentController.getTaskData(LeadObj2[0].Id,'Lead');
        System.assertEquals(TimelineWrapperObj1 != null, true, 'TimelineWrapperObj1 must not be NULL');
        TimelineWrapper TimelineWrapperObj2 = TimelineParentComponentController.getTaskData(conObj[0].Id,'Contact');
        System.assertEquals(TimelineWrapperObj2 != null, true, 'TimelineWrapperObj2 must not be NULL');
        TimelineWrapper TimelineWrapperObj3 = TimelineParentComponentController.getTaskData(accountList[0].Id,'Account');
        System.assertEquals(TimelineWrapperObj3 != null, true, 'TimelineWrapperObj3 must not be NULL');
        Test.stopTest();
    }
}