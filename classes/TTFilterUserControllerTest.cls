@isTest
private with sharing class TTFilterUserControllerTest {
    Public static TTFilterUserController.TTDoinitWrapper wrapperDoinit;
    @testSetup static void setupMethod() {
        Campaign CampaignObj = new Campaign(
                Name = 'Adult is Going Back to School',                                                                                                                                                                                                                                                                                                                  // Campaign Name
                IsActive = false,                                                                                                                                                                                                                                                                                                                                          // Active
                Type = 'Conference',                                                                                                                                                                                                                                                                                                                                       // Type
                Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n',
                Answers__c = '[{"id":"6076eeaa1b30ccf832f45761","conversation_id":"6076c2941b30ccf832f45723","questionsandanswers":[{"question":"What would you like us to help you with?","answers":["Topping up my TFSA"],"type":"multibutton","key":"60358a843e912332339155d8"},{"question":"Have you made any contributions with other institutions?","answers":["No"],"type":"button","key":"60358a843e912332339155da"}],"user_id":"6076c294c42dcdb0d","client_id":null,"modified_by":"System","modified_at":"2021-04-14T13:31:35.054Z","created_by":"System","created_at":"2021-04-14T13:31:22.938Z","touchpoint_template_id":"60358a843e912332339155cf"}]'
        );
        insert CampaignObj;

        Campaign CampaignObj2 = new Campaign(
                Name = 'Reminder Campaign',                                                                                                                                                                                                                                                                                                                  // Campaign Name
                IsActive = false,                                                                                                                                                                                                                                                                                                                                          // Active
                Type = 'Conference',                                                                                                                                                                                                                                                                                                                                       // Type
                TT_Campaign_Id__c = '8329yejwdhgwe',
                Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n',
                Answers__c = '[{"id":"6076eeaa1b30ccf832f45761","conversation_id":"6076c2941b30ccf832f45723","questionsandanswers":[{"question":"What would you like us to help you with?","answers":["Topping up my TFSA"],"type":"multibutton","key":"60358a843e912332339155d8"},{"question":"Have you made any contributions with other institutions?","answers":["No"],"type":"button","key":"60358a843e912332339155da"}],"user_id":"6076c294c42dcdb0d","client_id":null,"modified_by":"System","modified_at":"2021-04-14T13:31:35.054Z","created_by":"System","created_at":"2021-04-14T13:31:22.938Z","touchpoint_template_id":"60358a843e912332339155cf"}]'
        );
        insert CampaignObj2;

        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';      // Email
        con.Phone = '1212212213';                // Phone
        con.IsTelosTouchSyncAllowed__c = false;  // IsTelosTouchSyncAllowed
        con.TT_Client_Id__c = 'abc';
        con.TelosTouchSF__TT_Conflict__c = false;
        insert con;

        Lead lead = new Lead();
        lead.LastName = 'test';
        lead.Status = 'Open';
        lead.Company = 'Test Lead';
        lead.TT_Client_Id__c = 'abc122';
        lead.Email = 'james24@abc.com';      // Email
        lead.Phone = '1212212213';                // Phone
        lead.IsTelosTouchSyncAllowed__c = false;  // IsTelosTouchSyncAllowed
        lead.TelosTouchSF__TT_Conflict__c = false;
        insert lead;

        Insights__c conversationObject = new Insights__c();
        conversationObject.Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.Campaign2__c = CampaignObj.Id;
        conversationObject.Answers__c = '[{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Hi, we wanted to follow up on your tax return for 2018"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"How was it for you?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I received a large refund"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I understand. How would you like us to act on this?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Decrease withholding tax on my RRIF for 2019"},{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Great, someone from our team will reach out to you shortly"},{"type":"uploader","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"In the meantime, can you take a photo of your Notice of Assessment and upload it for us to review?"},{"type":"image/png","resource_url":"https://test2.systelospro.com/crm-v2/?entryPoint=attachment&id=5f4e4f33786aeb472","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"TTLogo.png"}]';
        conversationObject.Contact__c = con.Id;
        Insert conversationObject;
    }
    @isTest
    static  void doinit_ApexTest() {
        List<Campaign> campaignList = new List<Campaign>();
        campaignList = [SELECT Id FROM Campaign];
        Test.startTest();
        wrapperDoinit = TTFilterUserController.doinitApex(campaignList[0].Id);
        System.assertEquals(wrapperDoinit != null, true, 'wrapperDoinit must not be NULL');
        String filterWrapper = '{"questionAnswerList":[{"picklistValueList":[{"label":"Principal Residence","value":"Principal Residence"},{"label":"Investment/Recreational Property","value":"Investment/Recreational Property"}],"question":" Is it a principal residence or investment property?","answer":["Principal Residence"]},{"picklistValueList":[{"label":"Discuss increasing my life insurance","value":"Discuss increasing my life insurance"},{"label":"I would like to have a chat about my mortgage options","value":"I would like to have a chat about my mortgage options"}],"question":"Thanks for letting us know. Would you like to discuss any of the following"},{"picklistValueList":[{"label":"Discuss increasing my life insurance","value":"Discuss increasing my life insurance"},{"label":"I would like to have a chat about my mortgage options","value":"I would like to have a chat about my mortgage options"},{"label":"We need to discuss the future tax implications of the purchase","value":"We need to discuss the future tax implications of the purchase"}],"question":"Thanks for letting us know. Would you like to discuss any of the following"}]}';
        TTFilterUserController.getUserDetails(campaignList[0].Id, filterWrapper,null);
        //System.assertEquals(userObjectList != null, true);
        Test.stopTest();
    }
    @isTest
    static  void doinit_ApexTest2() {
        List<Campaign> campaignList = new List<Campaign>();
        campaignList = [SELECT Id, Name FROM Campaign];
        List<Lead> leadList = new List<Lead>();
        leadList = [SELECT Id,TT_Client_Id__c FROM Lead];
        Insights__c conversationObject = new Insights__c();
        conversationObject.Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.Campaign2__c = campaignList[0].Id;
        conversationObject.Answers__c = '[{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Hi, we wanted to follow up on your tax return for 2018"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"How was it for you?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I received a large refund"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I understand. How would you like us to act on this?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Decrease withholding tax on my RRIF for 2019"},{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Great, someone from our team will reach out to you shortly"},{"type":"uploader","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"In the meantime, can you take a photo of your Notice of Assessment and upload it for us to review?"},{"type":"image/png","resource_url":"https://test2.systelospro.com/crm-v2/?entryPoint=attachment&id=5f4e4f33786aeb472","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"TTLogo.png"}]';
        conversationObject.Lead__c = leadList[0].Id;
        conversationObject.Opened_At__c = System.now();
        conversationObject.Completed_At__c = System.now();
        Insert conversationObject;

        String JsonUser ='[{"ContactCLientId":"5f7af8dd1923f01c68e2ff72","ContactOrLeadSFId":"0032w00000KE3auAAD","Id":"a012w00000Ts3rBAAR","isActive":false,"name":"Bottle Holder 1202","nameURL":"https://telost-dev-ed.my.salesforce.com/lightning/r/Contact/0032w00000KE3auAAD/view","TTCompleted_At":"2020-10-05 12:52:59","TTOpened_At":"2020-10-05 12:52:23"}]';
        Test.startTest();
        String responseRecordType = TTFilterUserController.fetchCampaignRecordType();
        String responseRecordType1 = TTFilterUserController.fetchRecordType();
        wrapperDoinit = TTFilterUserController.doinitApex(campaignList[0].Id);
        System.assertEquals(wrapperDoinit != null, true,'wrapperDoinit must not be NULL');
        String filterWrapper = '{"questionAnswerList":[{"picklistValueList":[{"label":"Principal Residence","value":"Principal Residence"},{"label":"Investment/Recreational Property","value":"Investment/Recreational Property"}],"question":" Is it a principal residence or investment property?","answer":["Principal Residence"]},{"picklistValueList":[{"label":"Discuss increasing my life insurance","value":"Discuss increasing my life insurance"},{"label":"I would like to have a chat about my mortgage options","value":"I would like to have a chat about my mortgage options"}],"question":"Thanks for letting us know. Would you like to discuss any of the following"},{"picklistValueList":[{"label":"Discuss increasing my life insurance","value":"Discuss increasing my life insurance"},{"label":"I would like to have a chat about my mortgage options","value":"I would like to have a chat about my mortgage options"},{"label":"We need to discuss the future tax implications of the purchase","value":"We need to discuss the future tax implications of the purchase"}],"question":"Thanks for letting us know. Would you like to discuss any of the following"}]}';
        TTFilterUserController.getUserDetails(campaignList[0].Id, filterWrapper,null);
        TTFilterUserController.campaignInsertandSendTouchPoint(campaignList[0].Name, JsonUser);
        //System.assertEquals(userObjectList != null, true);
        Test.stopTest();
    }
    @isTest
    static void sendReminderTest(){
        List<Campaign> campaignList = new List<Campaign>();
        campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Reminder Campaign'];
        List<Lead> leadList = new List<Lead>();
        leadList = [SELECT Id,TT_Client_Id__c FROM Lead];
        List<Contact> contactList = new List<Contact>();
        contactList = [SELECT Id,TT_Client_Id__c FROM Contact];
        TTFilterUserController.UserWrapper userWrapperObj1 = new TTFilterUserController.UserWrapper();
        userWrapperObj1.TTCompleted_At = System.label.Pending_Text;
        userWrapperObj1.LeadCLientId = 'abc122';
        TTFilterUserController.UserWrapper userWrapperObj2 = new TTFilterUserController.UserWrapper();
        userWrapperObj2.TTOpened_At = System.label.Pending_Text;
        userWrapperObj2.TTCompleted_At = System.label.Pending_Text;
        userWrapperObj2.ContactCLientId = 'abc';
        List<TTFilterUserController.UserWrapper> userWrapperList = new List<TTFilterUserController.UserWrapper>();
        userWrapperList.add(userWrapperObj1);
        userWrapperList.add(userWrapperObj2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.GetCampaignsFromTTMock());
        TTFilterUserController.sendReminder(campaignList[0].Id, JSON.serialize(userWrapperList));
        System.assert(campaignList[0].Id != null);
        Test.stopTest();
    }
    @isTest
    static void getUserAnswersTest(){
        List<Insights__c> conversationLIST = new List<Insights__c>();
        conversationLIST = [SELECT Id FROM Insights__c];
        Test.startTest();
        List<TTFilterUserController.AnswerWrapperDetails> answerDetailsObject  = TTFilterUserController.getUserAnswers(conversationLIST[0].Id);
        System.assertEquals(answerDetailsObject != null, true, 'answerDetailsObject must not be NULL');
        Test.stopTest();
    }

    @isTest
    static void getTaskDetailsTest(){
        TTFilterUserController.PicklistWrapper PicklistWrapperObj = new TTFilterUserController.PicklistWrapper();
        PicklistWrapperObj.StatusPicklist = new List<TTFilterUserController.listObject>();
        PicklistWrapperObj.ShareWithClientlist = new List<TTFilterUserController.listObject>();
        PicklistWrapperObj.StatusPicklist = TTFilterUserController.getPicklistValues('Task', 'Status');
        PicklistWrapperObj.ShareWithClientlist = TTFilterUserController.getPicklistValues('Task', 'TelosTouchSF__Share_with_client_s__c');
        Test.startTest();
        TTFilterUserController.getTaskDetails();
        Test.stopTest();
        System.assert(PicklistWrapperObj.StatusPicklist != null,'PicklistWrapperObj.StatusPicklist must not be NULL');
        System.assert(PicklistWrapperObj.ShareWithClientlist != null,'PicklistWrapperObj.ShareWithClientlist must not be null');
    }

    @isTest
    static void saveNewTaskTest(){
        List<Task> tasklist = new List<Task>();
        Task task = new Task();
        task.OwnerId = UserInfo.getUserId();
        task.Subject='Donni';
        task.Status='Not Started';
        task.Priority='Normal';
        insert task;
        tasklist.add(task);
        Test.startTest();
        TTFilterUserController.saveNewTask(tasklist);
        Test.stopTest();
        tasklist = [select id from Task];
        System.assert(tasklist.size()>0, tasklist.size());
    }
    @isTest
    public static void fetchLimitedRecordsTest()
    {
        Test.startTest();
        Campaign camp = new Campaign();
        camp.Name='Test Camp';
        Insert camp;
        TTFilterUserController.fetchLimitedRecords();
        System.assert(camp != null);
        Test.stopTest();
    }
    @isTest
    public static void fetchRecordsTest()
    {
        Test.startTest();
        Campaign camp = new Campaign();
        camp.Name='Test Camp';
        Insert camp;
        TTFilterUserController.fetchRecords('Campaign','Name',camp.Name);
        
        Test.stopTest();
    }
    @isTest
    public static void addClientsToCampaignTest()
    {
        Test.startTest();
        Campaign camp = new Campaign();
        camp.Name='Test Camp1';
        Insert camp;
        Campaign camp1 = new Campaign();
        camp1.Name='Test Camp11';
        Insert camp1;
        String userList = '[{"ContactCLientId":"6274ebdad01bdb0e7f00bf3f","ContactOrLeadSFId":"0031y00000KIf3qAAD","Id":"a011y0000033fwVAAQ","isActive":true,"name":"Test Con 1","nameURL":"https://customer-app-586-dev-ed.cs114.my.salesforce.com/lightning/r/Contact/0031y00000KIf3qAAD/view","TTCompleted_At":"Pending","TTOpened_At":"Pending"}]';
        String userList1 = '[{"ContactCLientId":"6274ebdad01bdb0e7f00bf3f","ContactOrLeadSFId":"00QN000000AgDGtMAN","Id":"a011y0000033fwVAAQ","isActive":true,"name":"Test Con 1","nameURL":"https://customer-app-586-dev-ed.cs114.my.salesforce.com/lightning/r/Contact/0031y00000KIf3qAAD/view","TTCompleted_At":"Pending","TTOpened_At":"Pending"}]';
        TTFilterUserController.addClientsToCampaign(camp.Id,userList);
        TTFilterUserController.addClientsToCampaign(camp1.Id,userList1);
        Test.stopTest();
    }
}