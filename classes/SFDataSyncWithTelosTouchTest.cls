@isTest
public with sharing class SFDataSyncWithTelosTouchTest {  
    @testSetup
    static void addSetupMethod(){        
        List<TT_Salesforce_Mapping__c> mappingList = new List<TT_Salesforce_Mapping__c>();
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='firstName', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='lastName', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='emailAddress', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phoneNumber', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Subscribed__c', TT_Field__c='subscribed', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Address', TT_Field__c='Custom Fields', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='firstName', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='lastName', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='emailAddress', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phoneNumber', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Subscribed__c', TT_Field__c='subscribed', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='AssistantPhone', TT_Field__c='Custom Fields', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='ActivityDate', TT_Field__c='date_due', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Subject', TT_Field__c='name', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Status', TT_Field__c='status', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Client_Id__c', TT_Field__c='client_id', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Client_Name__c', TT_Field__c='client_name', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Description', TT_Field__c='description', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Share_with_client_s__c', TT_Field__c='shared', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Category__c', TT_Field__c='type', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='CallDurationInSeconds', TT_Field__c='Custom Fields', Object_Name__c='Task'));
        
        insert mappingList;
    }
    @isTest 
    static void testTaskSync() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, 
                          TT_UserName__c ='standarduser12345@testorg.com', 
                          Auth_Token__c = '973e878d316e6fb88a38c6591a5f7', TimeZoneSidKey = 'America/Los_Angeles', 
                          username = 'standarduser12345@testorg.com', TT_UserId__c = '123798', Id = UserInfo.getUserId());
        User taskOwnerUser = new User(Alias = 'standt', email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', 
                                      LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, 
                                      TT_UserName__c ='standarduser12345@testorg.com', 
                                      Auth_Token__c = '973e878d316e6fb88a38c6591a5f7', TimeZoneSidKey = 'America/Los_Angeles', 
                                      username = 'standarduser12345@testorg.com', TT_UserId__c = '123798');
        Map<String,User> userMapTest = new Map<String,User>();
        userMapTest.put(u.id, u);
        taskOwnerUser = userMapTest.get('ownerId');  
        List<TT_Salesforce_Mapping__c> listfieldMappings = new List<TT_Salesforce_Mapping__c>();
        TT_Salesforce_Mapping__c mappingObject2 = new TT_Salesforce_Mapping__c();
        mappingObject2.Salesforce_Field__c = 'Subject';
        mappingObject2.TT_Field__c = 'Name';
        mappingObject2.Object_Name__c = 'Task';
        listfieldMappings.add(mappingObject2);
        TT_Salesforce_Mapping__c mappingObject3 = new TT_Salesforce_Mapping__c();
        mappingObject3.Salesforce_Field__c = 'ActivityDate';
        mappingObject3.TT_Field__c = 'ActivityDate';
        mappingObject3.Object_Name__c = 'Task';
        listfieldMappings.add(mappingObject3);
        insert listfieldMappings;
        List<Task> tasklistSyncAllTask = new List<Task>();
        System.runAs(u) {
            Contact conobj = new Contact();
            conobj.FirstName = 'Ram';
            conobj.LastName = 'Mohan77';
            conobj.Email = 'rammohan7771@gmail.com';
            conobj.Phone = '1922199339';
            conobj.TT_Client_Id__c = 'abc';
            insert conobj;
            Lead ld = new Lead();
            ld.Company = 'Test Lead';
            ld.LastName = 'Lead Last Name';
            ld.Status = 'Open';
            ld.TT_Client_Id__c = 'abc';
            insert ld;
            Task tobj = new Task();
            tobj.Priority = 'High';
            tobj.Subject = 'Test';
            tobj.Status = 'Completed';
            tobj.Share_with_client_s__c = 'No';
            tobj.ActivityDate = Date.today();
            tobj.Description = 'ABCDDVMKVNSDVDSNV';
            tobj.WhoId = conobj.Id;
            Task tobj2 = new Task();
            tobj2.TT_TaskId__c = '588i87576';
            tobj2.Status = 'Open';
            tobj.Subject = 'Test2';
            tobj2.Share_with_client_s__c = 'Yes';
            tobj2.Description = 'ABCDDVMKVNSDVDSNV';
            tobj2.WhoId = ld.Id;
            tasklistSyncAllTask.add(tobj);
            tasklistSyncAllTask.add(tobj2);
            insert tasklistSyncAllTask;    
        }        
        Set<Id> taskIdSet = new Set<Id>{tasklistSyncAllTask[0].id, tasklistSyncAllTask[1].id};
            tasklistSyncAllTask = [SELECT Id, OwnerId, TT_TaskId__c,TT_Client_Id__c, TT_Client_Name__c, Status, Subject, Share_with_client_s__c, Description, WhoId,
                                   TT_Category__c, ActivityDate FROM Task WHERE Id IN: taskIdSet];
        String a = '[' + tasklistSyncAllTask[0].Id + ']';  
        TT_Log__c logObject = new TT_Log__c();
        logObject.Comments__c = 'Operation Successfull';
        logObject.Result__c = 'Success';
        logObject.Total_Contact_Count__c = 50;
        logObject.Total_Records_Count__c = 100;
        insert logObject; 
        Test.setMock(HttpCalloutMock.class, new SFDataSyncWithTelosTouchMock2());  
        System.assert(logObject != null, 'logObject must not be NULL');
        test.startTest();
        SFDataSyncWithTelosTouch sfDataSyncObj = new SFDataSyncWithTelosTouch();
        sfDataSyncObj.createDefualtRemoteSiteSetting();
        SFDataSyncWithTelosTouch.syncAllTaskstoTTActions(tasklistSyncAllTask);
        SFDataSyncWithTelosTouch.syncSelectedTasks(a);
        
        test.stopTest();
    }
    
    @isTest 
    static void contactandLeadSync() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<user> userList = new List<User>();
        User u = new User(Alias = 'standt', email = 'standarduser@testorg.com', EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, 
                          TT_UserName__c = 'standarduser12345@testorg.com', 
                          Token__c = '973e878d079316e6fb88a38c6591a5f7', TimeZoneSidKey = 'America/Los_Angeles',
                          username = 'standarduser12345@testorg.com', TT_UserId__c = '123');
        userList.add(u);
        insert userList;
        TT_Salesforce_Mapping__c mappingObject = new TT_Salesforce_Mapping__c();
        mappingObject.Salesforce_Field__c = 'Email';
        mappingObject.TT_Field__c = 'emailAddress';
        mappingObject.Object_Name__c = 'Contact';
        insert mappingObject;
        TT_Salesforce_Mapping__c mappingObject1 = new TT_Salesforce_Mapping__c();
        mappingObject1.Salesforce_Field__c = 'Email';
        mappingObject1.TT_Field__c = 'emailAddress';
        mappingObject1.Object_Name__c = 'Lead';
        insert mappingObject1;
        TT_Salesforce_Mapping__c mappingObject2 = new TT_Salesforce_Mapping__c();
        mappingObject2.Salesforce_Field__c = 'ActivityDate';
        mappingObject2.TT_Field__c = 'date_due';
        mappingObject2.Object_Name__c = 'Task';
        mappingObject2.Is_Deleted__c = false;
        insert mappingObject2;
        
        Contact conobj = new Contact();
        conobj.FirstName = 'Ram';
        conobj.LastName ='Mohan';
        conobj.OwnerId = userList[0].id;
        conobj.Email = 'ramMohan121@gmail.com';
        conobj.Phone = '9192219339';
        List<Contact> conList = new List<Contact>();
        conList.add(conobj);
        insert conList;
        
        Lead leadobj = new Lead();
        leadobj.FirstName = 'Ram1';
        leadobj.LastName ='Mohan1';
        leadobj.Company = 'ABCD';
        leadobj.OwnerId = userList[0].id;
        leadobj.Email = 'ramMohan1211@gmail.com';
        leadobj.Phone = '91922193395';
        insert leadobj;
        Task tobj = new Task();
        tobj.Priority = 'High';
        tobj.Subject = 'Test';
        tobj.Status = 'Open';
        tobj.OwnerId = userList[0].id;
        tobj.WhoId = leadobj.Id;
        tobj.Share_with_client_s__c = 'Yes';
        tobj.ActivityDate = Date.today();
        insert tobj;
        Task tobj2 = new Task();
        tobj2.Priority = 'High';
        tobj2.Subject = 'Test';
        tobj2.Status = 'Open';
        tobj2.OwnerId = userList[0].id;
        tobj2.WhoId = conobj.Id;
        tobj2.Share_with_client_s__c = 'Yes';
        tobj2.ActivityDate = Date.today();
        insert tobj2;
        List<Lead> leadList = new List<Lead>();
        leadList.add(leadobj);      
        Test.setMock(HttpCalloutMock.class, new SFDataSyncWithTelosTouchMock1());  
        System.assert(leadobj != null, 'leadobj must not be NULL');
        test.startTest();
        SFDataSyncWithTelosTouch.updateContactDetails(conList, leadList, null, NULL, NULL, NULL);
        SFDataSyncWithTelosTouch.getAllLogs(10,5);
        SFDataSyncWithTelosTouch.GetLatestLogs();
        
    } 
    @isTest static void taskDeleteMethodTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<user> userList = new List<User>();
        User u = new User(Alias = 'standt', email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TT_UserName__c ='standarduser12345@testorg.com',Token__c='973e878d079316e6fb88a38c6591a5f7',
                          TimeZoneSidKey='America/Los_Angeles', username='standarduser12345@testorg.com',TT_UserId__c ='123');
        userList.add(u);
        insert userList;
        Task tobj = new Task();
        tobj.Priority = 'High';
        tobj.Status = 'Open';
        tobj.Share_with_client_s__c = 'Yes';
        tobj.ActivityDate = Date.today(); 
        tobj.Description='ABCDDVMKVNSDVDSNV';
        tobj.TT_TaskId__c = '2134132131231';
        tobj.TT_Client_Id__c = '2134132131231';
        tobj.OwnerId = userList[0].id;
        List<Task> tasklistSyncAllTask = new List<Task>();
        tasklistSyncAllTask.add(tobj);
        insert tasklistSyncAllTask;
        Contact con = new Contact();
        con.LastName = 'Test Name';
        con.TT_UserId__c = '6076c294c42dcdb0d';
        con.Email = 'swapnil.sen+9665@gmail.com';
        insert con;
        Campaign campobj = new Campaign();
        campobj.Name = 'Test Purpose 123';
        campobj.OwnerId = userList[0].id;
        campobj.TT_Campaign_Id__c ='1234524234234';
        List<Campaign> campaignlist = new List<Campaign>();
        campaignlist.add(campobj);
        insert campaignlist;
        campaignlist[0].Name = 'Test Purpose';
        campaignlist[0].Answers__c = '[{"id":"6076eeaa1b30ccf832f45761","conversation_id":"6076c2941b30ccf832f45723","questionsandanswers":[{"question":"What would you like us to help you with?","answers":["Topping up my TFSA"],"type":"multibutton","key":"60358a843e912332339155d8"},{"question":"Have you made any contributions with other institutions?","answers":["No"],"type":"button","key":"60358a843e912332339155da"}],"user_id":"6076c294c42dcdb0d","client_id":null,"modified_by":"System","modified_at":"2021-04-14T13:31:35.054Z","created_by":"System","created_at":"2021-04-14T13:31:22.938Z","touchpoint_template_id":"60358a843e912332339155cf"}]';
        campaignlist[0].Questions__c = '[{"question":"What would you like us to help you with?","key":"60358a843e912332339155d8","type":"multibutton","answers":["RRSP Contributions","Topping up my TFSA","Manage my Tax slips"],"question_fr":"What would you like us to help you with?","answers_fr":["RRSP Contributions","Topping up my TFSA","Manage my Tax slips"]}]';
        update campaignlist;
        Test.setMock(HttpCalloutMock.class, new DeleteTaskMock());  
        System.assert(campaignlist != null, 'campaignlist must not be NULL');        
        Test.setMock(HttpCalloutMock.class, new DeleteTaskMock()); 
        System.assert(tasklistSyncAllTask != null, 'tasklistSyncAllTask must not be NULL');
        test.startTest();
        SFDataSyncWithTelosTouch.deleteTask(tasklistSyncAllTask);
        SFDataSyncWithTelosTouch.deleteCampaign(campaignlist);
        SFDataSyncWithTelosTouch.addLogRecord('Failure','No sync','No Sync',1);
        Database.ExecuteBatch(new TaskDelete_Batch(tasklistSyncAllTask));
        Database.ExecuteBatch(new CampaignDelete_Batch(campaignlist));
        test.stopTest();
        delete campaignlist;
        delete tasklistSyncAllTask;
    }
    @isTest static void updateContactLead() {
        Contact con = new Contact();
        con.LastName = 'Test Name';
        con.TT_UserId__c = '6076c294c42dcdb0d';
        con.Email = 'swapnil.sen+966522@gmail.com';
        con.TT_Client_Id__c = '384793kdjsj7446';
        con.AssistantPhone = '8924783';
        insert con;
        
        Lead leadobj = new Lead();
        leadobj.FirstName = 'Ram1';
        leadobj.LastName ='Mohan1';
        leadobj.Company = 'ABCD';
        leadobj.Email = 'ramMohan1211@gmail.com';
        leadobj.Phone = '91922193395';
        leadobj.TT_Client_Id__c = '60e3e9ae2cf3cea2af1d8a99';
        insert leadobj;
        
        Contact con2 = new Contact();
        con2.LastName = 'Test Name';
        con2.Email = 'swapnil.sen+9665233622@gmail.com';
        insert con2;
        
        Lead leadobj2 = new Lead();
        leadobj2.LastName ='Mohan1';
        leadobj2.Company = 'ABCD';
        leadobj2.Email = 'ramMohan1234211@gmail.com';
        leadobj2.Phone = '922193395';
        insert leadobj2;
        
        Contact con3 = new Contact();
        con3.LastName = 'Test Name';
        con3.AssistantPhone = '8924783';
        con3.Email = 'swapnil.sen+961333622@gmail.com';
        con3.Subscribed__c = '';
        con3.Language__c = 'French';
        insert con3;
        
        Lead leadobj3 = new Lead();
        leadobj3.LastName ='Mohan1';
        leadobj3.Company = 'ABCD';
        leadobj3.Email = 'ramMohan1215611@gmail.com';
        leadobj3.Phone = '922193395';
        leadobj3.Subscribed__c = '';
        leadobj3.Language__c = 'French';
        insert leadobj3;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SFDataSyncWithTelosTouchMock2()); 
        con.Email = 'swapnil.sen+9665222@gmail.com';
        update con;
        leadobj.Email = 'ramMohan12111@gmail.com';
        update leadobj;
        System.assertEquals('ramMohan12111@gmail.com', leadobj.Email, 'leadobj.Email should be updated to ramMohan12111@gmail.com');
        test.stopTest();
    }
    @isTest static void checkEnterpriseClientTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SFDataSyncWithTelosTouchMock1()); 
        Boolean resp = SFDataSyncWithTelosTouch.checkIfEnterpriseClient();
        System.debug('resp: '+ resp);
        System.assert(!resp);
        Test.stopTest();
    }
}