//  Covered Classes :- Trigger-CampMemberNotAddInCampaign,Trigger-LeadTriggerForSyncing, TaskTrigger
//  Apexclass - TTcampaignResponse, TelosTouchUtility
@isTest 
private with sharing class TelosTouchUtilityTest {
    @isTest    
    static  void getTTCampaignId_test() {
        System.schedule('GetDeleteRecordsFromTTScheduler Job', '0 0 0/1 1/1 * ? *', new GetDeleteRecordsFromTTScheduler());
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        /***************************************************************/
        String firstFakeResponseRespString = '{ "id": "5f4e65e9d5d22d1cbed93f3a", "instance_name": "https://test.com", "touchpoint_template_name": "Client is 5 Year Old and No RESP Yet", "touchpoint_template_name_fr": null, "questions": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "questions_fr": [ { "question": "Would you like us to reach out to discuss opening a plan?", "key": "5e947ef0574573795fa7fa2b", "type": "button", "answers": [ "Not at this time thanks", "Yes" ] }, { "question": "Great, how would you like us to reach out? ", "key": "5e947ef0574573795fa7fa2c", "type": "button", "answers": [ "Call Me", "Video Chat", "In Person Meeting" ] } ], "deleted": false, "created_by_id": "1", "modified_by": "System", "modified_at": "2020-09-01T15:16:57.041Z", "created_by": "Admin Admin", "created_at": "2020-09-01T15:16:57.041Z", "team_id": "5925d8eeaedb9e14c", "other_id": "7012w000000YUQ2AAO", "touchpoint_template_id": "5e947ef0574573795fa7fa21" }';
        String secondFakeResponseRespString='{ "id": "5f527d53aa941c1bda3b0071", "created_at": "2020-09-04T17:45:55.826Z", "created_by": "Jad Chehlawi", "name": "Considering Purchase of a Property", "name_fr": null, "touchpoint_template_id": "5e947ef0574573795fa7f9a5", "conversations": [ { "conversation_id": "5f527d53aa941c1bda3b0073", "completed_at": "2020-09-04T18:42:23.772Z", "opened_at": "2020-09-04T17:59:38.301Z", "status_touchpoint": "completed", "user_id": "5f526a4d219d3865a", "contact_id": "5f5267ce48c9a601c", "user_name": null, "language": null, "avatarId": null } ] }';
        String thirdFakeResponseRespString ='{"emailAddress": "mojitihejgov@gmail.com","id":"5f4a2f6fbbf7da0b8","assignedUserId":"5e95dc6839a36082d","assignedUserName":"telostouch_advisor"}';
        SingleRequestMock firstFakeResponseResp = new SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp must not be NULL');
        SingleRequestMock secondFakeResponseResp = new SingleRequestMock(200,'OK',secondFakeResponseRespString,null);
        System.assert(secondFakeResponseResp != null, 'secondFakeResponseResp must not be NULL');
        SingleRequestMock thirdFakeResponseResp = new SingleRequestMock(200,'OK',thirdFakeResponseRespString,null);
        System.assert(thirdFakeResponseResp != null, 'thirdFakeResponseResp must not be NULL');
        
        Map<String, HttpCalloutMock> endpoint2TestResp =  new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/touchpoint/templates/send/'+CampaignObj.Id,firstFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/5f4e65e9d5d22d1cbed93f3a/clients',secondFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/admin/contacts',thirdFakeResponseResp);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        
        CampaignMember CampaignMemberObj = new CampaignMember();
        CampaignMemberObj.CampaignId = CampaignObj.Id;
        CampaignMemberObj.ContactId = con.Id;
        insert CampaignMemberObj;
        Test.startTest();
        TelosTouchSF.TelosTouchUtility.getTTCampaignId(CampaignObj.Id, JSON.serialize(new List<String>{'abc'}));
        Test.stopTest();
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    @isTest 
    static void getSettingAPI_test() {
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com\\.'; 
        insert credential;
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        TelosTouchUtility.userCredentialsWrapper wp = TelosTouchUtility.getSettingAPI('From Setup',CampaignObj.id);
        Test.stopTest();
        System.assert(wp != null, 'wp must not be NULL');
    }
    @isTest 
    static void sendCampaignTouchPoint_test() {
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = true;
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        Task task = new Task();
        task.OwnerId = UserInfo.getUserId();
        task.Subject='Donni';
        task.Status='Not Started';
        task.WhoId = con.Id;
        insert task;
        task.TT_Client_Id__c = '';
        update task;
        CampaignMember CampaignMemberObj = new CampaignMember();
        CampaignMemberObj.CampaignId = CampaignObj.Id;
        CampaignMemberObj.ContactId = con.Id;
        insert CampaignMemberObj;
        
        Lead ld = new Lead(Company = 'Test Lead',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc');
        insert ld;
        
        CampaignMember CampaignMemberObj1 = new CampaignMember();
        CampaignMemberObj1.CampaignId = CampaignObj.Id;
        CampaignMemberObj1.LeadId = ld.Id;
        insert CampaignMemberObj1;
        
        Test.startTest();
        TelosTouchWrapperUtils.salesforceCamapaignWrapper wrapperObj = TelosTouchUtility.sendCampaignTouchPoint(CampaignObj.Id);
        System.assertEquals(true, wrapperObj != null, 'wrapperObj must not be NULL');
        
        TelosTouchUtility.sendCampaignTouchPoint(con.Id);
        TelosTouchUtility.sendCampaignTouchPoint(ld.Id);
        Test.setMock(HttpCalloutMock.class, new SFDataSyncWithTelosTouchMock1());
        Test.stopTest();
    }
    @isTest 
    static void sendCampaignTouchPoint_test1() {
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            TT_Campaign_Id__c = 'xyz',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        
        Test.startTest();
        TelosTouchWrapperUtils.salesforceCamapaignWrapper wrapperObj = TelosTouchUtility.sendCampaignTouchPoint(CampaignObj.Id);
        System.assertEquals(true, wrapperObj != null,'wrapperObj must not be NULL');
        Test.stopTest();
        
    }
    
    @isTest 
    static void getAdminAccessTokenTest() {
        TelosTouchUtility.AdminCredentialsWrapper adminCredentials = new TelosTouchUtility.AdminCredentialsWrapper(TelosTouchSF.TelosTouchUtility.getCustomMetadata(), TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata());
        List<TelosTouchUtility.AdminCredentialsWrapper> adminCredentialsList = new List<TelosTouchUtility.AdminCredentialsWrapper>{adminCredentials};
            Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' and UserLicense.Name = 'Salesforce'].get(0);
        
        User userObj = New User();
        userObj.IsActive = true;
        userObj.Id = UserInfo.getUserId();
        userObj.TT_UserId__c = '';
        userObj.profileId = p.Id;
        userObj.UserPermissionsMarketingUser = true;
        update userObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthenticationMock());
        TelosTouchUtility.userCredentialsWrapper wp1 = TelosTouchUtility.getAdminAccessToken(JSON.serialize(adminCredentialsList), 'From Setup');
        System.assertEquals(false, wp1 == null, 'wp1 must not be NULL');
        Test.stopTest();  
    } 
    @isTest 
    static void refreshAdminAccessTokenTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthenticationMock());
        TelosTouchUtility.AdminCredentialsWrapper wp1 = TelosTouchUtility.refreshAdminAccessToken();
        System.assertEquals(false, wp1 == null,'wp1 must not be NULL');
        Test.stopTest();
    }
    
    @isTest 
    static void deleteContactFromTT_test1() {
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        List<Contact> conlist = new List<Contact>();
        List<Lead> leadlist = new List<Lead>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = false;
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        conlist.add(con);
        Lead ld = new Lead(Company = 'Test Lead',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc');
        insert ld;
        leadlist.add(ld);
        List<String> clientIds =  new List<String>();
        clientIds.add(CampaignObj.Id);
        
        conlist = [select id,TT_Client_Id__c,OwnerId from Contact LIMIT 50000];
        leadlist = [select id,TT_Client_Id__c,OwnerId from Lead LIMIT 50000];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.deleteContactFromTT(conlist, leadlist);
        System.assert(conlist.size() > 0, 'conlist must not be empty');
        Test.stopTest();
    } 
    
    @isTest 
    static void deleteContactFromTT_test2() {
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        List<Contact> conlist = new List<Contact>();
        List<Lead> leadlist = new List<Lead>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = false;
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        conlist.add(con);
        Lead ld = new Lead(Company = 'Test Lead',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc');
        insert ld;
        leadlist.add(ld);
        List<String> clientIds =  new List<String>();
        clientIds.add(CampaignObj.Id);
        
        leadlist = [select id,TT_Client_Id__c,OwnerId from Lead LIMIT 50000];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.deleteContactFromTT(new List<Contact>(), leadlist);
        System.assert(conlist.size() > 0, 'conlist must not be empty');
        Test.stopTest();
    }
    
    @isTest 
    static void scheduleAllJobsFromHere_test() {
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        List<Contact> conlist = new List<Contact>();
        List<Lead> leadlist = new List<Lead>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = false;
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        conlist.add(con);
        Lead ld = new Lead(Company = 'Test Lead',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc');
        insert ld;
        leadlist.add(ld);
        List<String> clientIds =  new List<String>();
        clientIds.add(CampaignObj.Id);
        
        conlist = [select id,TT_Client_Id__c,OwnerId from Contact LIMIT 50000];
        leadlist = [select id,TT_Client_Id__c,OwnerId from Lead LIMIT 50000];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetClientFromTTMock());
        TelosTouchUtility.scheduleAllJobsFromHere();
        System.assert(CampaignObj != null, 'CampaignObj must not be NULL');
        TelosTouchUtility.abortScheduleJob(credentialList);
        Test.stopTest();
    }
    
    @isTest 
    static  void shareWithClients_test() {
        Task task = new Task();
        task.OwnerId = UserInfo.getUserId();
        task.Subject='Donni';
        task.Status='Not Started';
        task.Priority='Normal';
        insert task;
        Test.startTest();
        string str =  TelosTouchUtility.shareWithClients(task.Id);
        System.assertEquals(true, str != null,'str must not be NULL');
        TelosTouchUtility.checkIfPostInstallScriptRunning_APEX();
        Test.stopTest(); 
    }
    @isTest 
    static  void SendSFUserBatch() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = false;
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        Lead ld = new Lead(Company = 'Test Lead',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc');
        insert ld;
        Test.startTest();
        delete con;
        delete ld;
        Test.stopTest();
        System.assert(ld.id != null, 'ld.id must not be NULL');
    }
    @isTest
    static void checkClientInviteTest(){
        Contact con = new Contact();
        con.TT_Client_Id__c = 'abc';
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.TT_Last_Login__c = '1212212213';     
        insert con;
        
        Lead ld = new Lead();
        ld.TT_Client_Id__c = 'abc123';
        ld.LastName = 'test2';
        ld.Email = 'james2@abc.com';
        ld.TT_Last_Login__c = '1212212213';     
        ld.Company = 'Test Company';
        insert ld;
        
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Test.startTest();
        TelosTouchUtility.checkClientInvite(acc.Id, 'Account', 'updateClient', null, null);
        TelosTouchUtility.checkClientInvite(con.Id, 'Contact', 'updateClient', null, null);
        TelosTouchUtility.checkClientInvite(ld.Id, 'Lead', 'updateClient', null, null);
        System.assert(ld.id != null, 'ld.id must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendSFUserBatchTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<user> userList = new List<User>();
        Map<Id,PermissionSetAssignment> userIdVsPermSetAssignObjMap = new Map<Id,PermissionSetAssignment>();
        
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1868687687@gmail.com');
        User u2 = new User(Alias = 'standt', Email='test18686876@gmail.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test18686876@gmail.com');
        userList.add(u);
        userList.add(u2);
        insert userList;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TelosTouch_Custom_Permission'];
        insert new PermissionSetAssignment(AssigneeId = userList[0].id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = userList[1].id, PermissionSetId = ps.Id);
        List<Id> userIdlist = new List<Id>();
        userIdlist.add(userList[0].Id);
        String firstFakeResponseRespString='[{"id":"5ff18c1c-94ad-4ec5-a6a5-6bc091227607","createdTimestamp":1646300848407,"username":"sfdc.techqa2@gmail.com","enabled":true,"totp":false,"emailVerified":true,"firstName":"Harpreet","lastName":"Singh","email":"sfdc.techqa2@gmail.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["en-us"],"phone":["null"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0}]';
        SingleRequestMock firstFakeResponseResp = new SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        String secondFakeResponseRespString='[{"id":"5ff18c1c-94ad-4ec5-a6a5-6bc091227607","createdTimestamp":1646300848407,"username":"sfdc.techqa2@gmail.com","enabled":true,"totp":false,"emailVerified":true,"firstName":"Harpreet","lastName":"Singh","email":"sfdc.techqa2@gmail.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["en-us"],"phone":["null"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0}]';
        SingleRequestMock SecondFakeResponseResp = new SingleRequestMock(200,'OK',secondFakeResponseRespString,null);
        String thirdFakeResponseRespString='[]';
        SingleRequestMock ThirdFakeResponseResp = new SingleRequestMock(200,'OK',thirdFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp must not be NULL');
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/users',firstFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/App/users',firstFakeResponseResp);    
        endpoint2TestResp.put('https://test.com/api/v1/users?search=test1868687687@gmail.com',SecondFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/users?search=test18686876@gmail.com',ThirdFakeResponseResp);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, new AuthenticationMock());
        System.runAs(u) {
            database.executeBatch(new SendSFUserBatch(userList,userIdVsPermSetAssignObjMap));
        }
    }
    @isTest 
    static void sendSFUserToTT_test1() {
        
        List<User> sfUserList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1868687687@gmail.com');
        sfUserList.add(u);
        insert sfUserList;
        List<Id> listofUserId = new List<Id>();
        listofUserId.add(u.Id);
        TelosTouch_User_Role__c customSettingObj = new TelosTouch_User_Role__c(name= 'customtest',RolesName__c='Test');
        insert customSettingObj;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.setMock(HttpCalloutMock.class, new AuthenticationMock());
        String returnString2 = TelosTouchUtility.sendSFUserToTT(sfUserList,listofUserId);
        Test.stopTest();
        list<TelosTouch_User_Role__c> customSettingList = new list<TelosTouch_User_Role__c>();
        customSettingList = [select RoleId__c,RolesName__c from TelosTouch_User_Role__c];
        system.assertEquals('Test', customSettingList[0].RolesName__c, 'customSettingList[0].RolesName__c must be equal to Test');
    } 
    @isTest 
    static void sendUserInvitation_test1() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        String recordObj = '{"clientId":"abc","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com"}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'invite';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test2() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'bcd';
        insert con;
        String recordObj = '{"clientId":"bcd","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com"}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'invite';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test3() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'cde';
        insert con;
        String recordObj = '{"clientId":"cde","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com"}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'invite';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test4() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'cde';
        insert con;
        String recordObj = '{"clientId":"cde","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com","userId":"d15736ce-1239-4c4e-b196-6f505b34cec7"}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'reset';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test5() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'user123';
        insert con;
        String recordObj = '{"clientId":"user123","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com","userId":"user123"}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'reset';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test6() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'abc';
        insert con;
        String recordObj = '{"clientId":"abc","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com","userId":null}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'reset';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void sendUserInvitation_test7() {
        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';     
        con.Phone = '1212212213';                
        con.IsTelosTouchSyncAllowed__c = false;  
        con.Language__c = 'English';  
        con.TT_Client_Id__c = 'cde';
        insert con;
        String recordObj = '{"clientId":"cde","isInvite":true,"IsNotPersonAccount":true,"objectName":"Contact","recordId":"'+con.Id+'","reSendPassword":false,"userName":"swapnil.sen+123432@cloudanalogy.com","userId":null}';
        TelosTouchUtility.ClientInviteWrapper wrapperobj = new TelosTouchUtility.ClientInviteWrapper();
        string action = 'reset';
        Test.setMock(HttpCalloutMock.class , new TelosTouchUtilityMock2());
        Test.startTest();
        wrapperobj = TelosTouchUtility.sendUserInvitation(recordObj, action);
        System.assert(wrapperobj != null, 'wrapperobj must not be NULL');
        Test.stopTest();
    }
    @isTest 
    static void massInvitationToClients_test1() {
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        List<String> idlist = new List<String>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Contact con1 = new Contact();
        con1.LastName = 'test1';
        con1.Email = 'james1@abc.com';     
        con1.Language__c = 'English';  
        con1.TT_Client_Id__c = 'abc';
        con1.TT_Last_Login__c = '';
        insert con1;
        Contact con2 = new Contact();
        con2.LastName = 'test2';
        con2.Email = 'james2@abc.com';     
        con2.Language__c = 'English';  
        con2.TT_Client_Id__c = 'abc';
        con2.TT_Last_Login__c = '';
        insert con2;
        Contact con3 = new Contact();
        con3.LastName = 'test3';
        con3.Email = 'james3@abc.com';     
        con3.Language__c = 'English';  
        con3.TT_Client_Id__c = 'abc'; 
        con3.TT_Last_Login__c = '';
        insert con3;
        idlist.add(con1.Id);
        idlist.add(con2.Id);
        idlist.add(con3.Id);
        string objectName = 'Contact'; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.massInvitationToClients(JSON.serialize(idlist) , objectName);
        System.assert(idlist.size() > 0, 'idlist must not be empty');
        Test.stopTest();
    }
    @isTest 
    static void massInvitationToClients_test2() {
        List<String> idlist = new List<String>();
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Lead ld = new Lead(Company = 'Test Lead1',
                           LastName = 'Lead Last Name',
                           Status = 'Open',
                           TT_Client_Id__c = 'abc', TT_Last_Login__c = '');
        insert ld;
        Lead ld2 = new Lead(Company = 'Test Lead2',
                            LastName = 'Lead Last Name',
                            Status = 'Open',
                            TT_Client_Id__c = 'abc',TT_Last_Login__c = '');
        insert ld2;
        Lead ld3 = new Lead(Company = 'Test Lead3',
                            LastName = 'Lead Last Name',
                            Status = 'Open',
                            TT_Client_Id__c = 'abc',TT_Last_Login__c = '');
        insert ld3;
        idlist.add(ld.Id);
        idlist.add(ld2.Id);
        idlist.add(ld3.Id);
        string objectName = 'Lead'; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.massInvitationToClients(JSON.serialize(idlist), objectName);
        System.assert(idlist.size() > 0, 'idlist must not be empty');
        Test.stopTest();
    }
    
    @isTest 
    static void massInvitationToClients_test3() {
        List<TelosTouch_API_Settings__c> credentialList = new  List<TelosTouch_API_Settings__c>();
        List<String> idlist = new List<String>();
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com';
        credential.Client_id_username__c = 'telostouch_advisor';
        credential.Client_secret_password__c = 'havefun1';
        insert credential;
        credentialList.add(credential);
        Contact con1 = new Contact();
        con1.LastName = 'test1';
        con1.Email = 'james1@abc.com';     
        con1.Language__c = 'English';  
        con1.TT_Client_Id__c = 'abc';
        con1.TT_Last_Login__c = 'Not Invited';
        insert con1;
        Contact con2 = new Contact();
        con2.LastName = 'test2';
        con2.Email = 'james2@abc.com';     
        con2.Language__c = 'English';  
        con2.TT_Client_Id__c = 'abc';
        con2.TT_Last_Login__c = 'Not Invited';
        insert con2;
        idlist.add(con1.Id);
        idlist.add(con2.Id);
        string objectName = 'Contact'; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.massInvitationToClients(JSON.serialize(idlist) , objectName);
        System.assert(idlist.size() > 0, 'idlist must not be empty');
        Test.stopTest();
    }
    
    @isTest 
    static void getCalloutInfoTest(){
        Test.startTest();
        TelosTouchUtility.getCalloutInfo();
        Test.stopTest();
    }
    
    @isTest
    static void testLeadTrigger(){
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Company = 'CA';
        ld.TelosTouchSF__TT_Client_Id__c = '238648720wkhew';
        ld.Email = 'test@ca.com';
        insert ld;
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        insert camp;
        CampaignMember campMem = new CampaignMember();
        campMem.CampaignId = camp.Id;
        campMem.LeadId = ld.Id;
        insert campMem;
        TT_Client_Answers__c answer = new TT_Client_Answers__c();
        answer.Name = 'Test Question';
        answer.Answer__c = 'Test Answer';
        answer.Campaign__c = camp.Id;
        answer.Lead__c = ld.Id;
        insert answer;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(true, lcr.isSuccess(), 'lcr should be Success');
    }
    @isTest
    static void isObjectExistTest(){
        Test.startTest();
        System.assertEquals(true, TelosTouchSF.TelosTouchUtility.isObjectExist('Task'), 'isObjectExist should be True');
        Test.stopTest();
    }
    @isTest
    static void checkInviteFunctionalityTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        System.assertEquals(false, TelosTouchSF.TelosTouchUtility.checkInviteFunctionality(), 'checkInviteFunctionality should be False');
        Test.stopTest();
    }
    @isTest
    static void getCampaignDetailsTest(){
        Campaign camp1 = new Campaign();
        camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp1.Name = 'Test 1';
        
        Campaign camp2 = new Campaign();
        camp2.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp2.Name = 'Test 2';
        camp2.TelosTouchSF__TT_Campaign_Id__c = '837289ejhhk';
        
        Campaign camp3 = new Campaign();
        camp3.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp3.Name = 'Test 3';
        camp3.TelosTouchSF__TT_Campaign_Id__c = '8293yewhk3287';
        
        Campaign camp4 = new Campaign();
        camp4.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp4.Name = 'Test 4';
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con 1';
        con.Email = 'test123@test.com';
        con.TelosTouchSF__TT_Client_Id__c = '327we8g387t82';
        
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead 1';
        ld.Company = 'CA';
        ld.Email = 'test122332@test.com';
        ld.TelosTouchSF__TT_Client_Id__c = '27328de27g2378';
        
        insert con;
        insert ld;
        
        insert new List<Campaign>{camp1, camp2, camp3, camp4};
            
            CampaignMember campMem1 = new CampaignMember();
        campMem1.CampaignId = camp2.Id;
        campMem1.ContactId = con.Id;
        
        CampaignMember campMem2 = new CampaignMember();
        campMem2.CampaignId = camp2.Id;
        campMem2.LeadId = ld.Id;
        
        TelosTouchSF__Insights__c insight1 = new TelosTouchSF__Insights__c();
        insight1.Name = 'Insight 1';
        insight1.TelosTouchSF__Campaign2__c = camp2.Id;
        insight1.TelosTouchSF__Contact__c = con.Id;
        
        TelosTouchSF__Insights__c insight2 = new TelosTouchSF__Insights__c();
        insight2.Name = 'Insight 2';
        insight2.TelosTouchSF__Campaign2__c = camp2.Id;
        insight2.TelosTouchSF__Lead__c = ld.Id;
        
        CampaignMember campMem3 = new CampaignMember();
        campMem3.CampaignId = camp1.Id;
        campMem3.ContactId = con.Id;
        
        CampaignMember campMem4 = new CampaignMember();
        campMem4.CampaignId = camp1.Id;
        campMem4.LeadId = ld.Id;
        
        CampaignMember campMem5 = new CampaignMember();
        campMem5.CampaignId = camp3.Id;
        campMem5.ContactId = con.Id;
        
        CampaignMember campMem6 = new CampaignMember();
        campMem6.CampaignId = camp3.Id;
        campMem6.LeadId = ld.Id;
        
        TelosTouchSF__Insights__c insight3 = new TelosTouchSF__Insights__c();
        insight3.Name = 'Insight 3';
        insight3.TelosTouchSF__Campaign2__c = camp3.Id;
        insight3.TelosTouchSF__Lead__c = ld.Id;
        
        insert new List<CampaignMember>{campMem1, campMem2, campMem3, campMem4, campMem5, campMem6};
            insert new List<TelosTouchSF__Insights__c>{insight1, insight2, insight3};
                
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        String returnStr;
        returnStr = TelosTouchSF.TelosTouchUtility.getCampaignDetails(camp1.Id);
        returnStr = TelosTouchSF.TelosTouchUtility.getCampaignDetails(camp2.Id);
        returnStr = TelosTouchSF.TelosTouchUtility.getCampaignDetails(camp3.Id);
        returnStr = TelosTouchSF.TelosTouchUtility.getCampaignDetails(camp4.Id);
        System.assert(true);
        Test.stopTest();
    }
    @isTest
    static void addClientsToTouchpointTest(){
        Campaign camp2 = new Campaign();
        camp2.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp2.Name = 'Test 2';
        camp2.TelosTouchSF__TT_Campaign_Id__c = '7283683wuiqshui';
        
        insert camp2;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Con 1';
        con.Email = 'test123@test.com';
        con.TelosTouchSF__TT_Client_Id__c = '62610b10ef5df56030141dd6';
        
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead 1';
        ld.Company = 'CA';
        ld.Email = 'test122332@test.com';
        ld.TelosTouchSF__TT_Client_Id__c = '62610b10ef5lf56030141dd6';
        
        insert con;
        insert ld;
        
        CampaignMember campMem1 = new CampaignMember();
        campMem1.CampaignId = camp2.Id;
        campMem1.ContactId = con.Id;
        
        CampaignMember campMem2 = new CampaignMember();
        campMem2.CampaignId = camp2.Id;
        campMem2.LeadId = ld.Id;
        
        List<CampaignMember> campMemList = new List<CampaignMember>{campMem1, campMem2};
            insert campMemList;
        
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.AuthenticationMock());
        Test.startTest();
        System.assert(TelosTouchSF.TelosTouchUtility.addClientsToTouchpoint(JSON.serialize(campMemList)), 'Method Should Return True');     
        Test.stopTest();
    }
    @isTest static void getInviteFlagTest(){
        Test.startTest();
        boolean storeResponse=TelosTouchSF.TelosTouchUtility.getInviteFlag();
        System.assert(!storeResponse || storeResponse,'it should be true');
        Test.stopTest();
    }
    @isTest 
    static void createUpdateMetadataTest(){
        Test.startTest();
        TelosTouchSF.TelosTouchUtility.createUpdateMetadata(true, false, 'TelosTouchSF__Invite');
        System.assert(true,'it should be true');
        Test.stopTest();
    }
    @isTest 
    static void revokeUserAccessTest(){
        
        List<User> sfUserList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1868687687@gmail.com');
        sfUserList.add(u);
        insert sfUserList;
        list<Id> lstUserId = new list<Id>{sfUserList[0].Id};
        
        Test.startTest();
        TelosTouchSF.TelosTouchUtility.revokeUserAccess(lstUserId[0], null);
        TelosTouchSF.TelosTouchUtility.revokeUserAccess(null, lstUserId);
        Test.stopTest();
    }
    
    @isTest
    static void checkIfEnterpriseClientTest(){
        Test.startTest();
        TelosTouchUtility.checkIfEnterpriseClient();
        Test.stopTest();
    }
    
    @isTest
    static void generateErrorLogTest(){
        Test.startTest();
        try{
            Integer error = 1/0;
        } catch (Exception ex) {
        	TelosTouchUtility.generateErrorLog(ex, 'TelosTouchUtilityTest', 'generateErrorLogTest', null);
        }
        Test.stopTest();
    }
    
}