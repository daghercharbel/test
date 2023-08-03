@isTest
private with sharing class TTFilterUserControllerTest {

    Public static TTFilterUserController.TTDoinitWrapper wrapperDoinit;

    @testSetup static void setupMethod() {
        Campaign CampaignObj = new Campaign(
                Name = 'Adult is Going Back to School',
                IsActive = false,
                Type = 'Conference',
                Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n',
                Answers__c = '[{"id":"6076eeaa1b30ccf832f45761","conversation_id":"6076c2941b30ccf832f45723","questionsandanswers":[{"question":"What would you like us to help you with?","answers":["Topping up my TFSA"],"type":"multibutton","key":"60358a843e912332339155d8"},{"question":"Have you made any contributions with other institutions?","answers":["No"],"type":"button","key":"60358a843e912332339155da"}],"user_id":"6076c294c42dcdb0d","client_id":null,"modified_by":"System","modified_at":"2021-04-14T13:31:35.054Z","created_by":"System","created_at":"2021-04-14T13:31:22.938Z","touchpoint_template_id":"60358a843e912332339155cf"}]'
        );
        insert CampaignObj;

        Campaign CampaignObj2 = new Campaign(
                Name = 'Reminder Campaign',
                IsActive = false,
                Type = 'Conference',
                TT_Campaign_Id__c = '8329yejwdhgwe',
                Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n',
                Answers__c = '[{"id":"6076eeaa1b30ccf832f45761","conversation_id":"6076c2941b30ccf832f45723","questionsandanswers":[{"question":"What would you like us to help you with?","answers":["Topping up my TFSA"],"type":"multibutton","key":"60358a843e912332339155d8"},{"question":"Have you made any contributions with other institutions?","answers":["No"],"type":"button","key":"60358a843e912332339155da"}],"user_id":"6076c294c42dcdb0d","client_id":null,"modified_by":"System","modified_at":"2021-04-14T13:31:35.054Z","created_by":"System","created_at":"2021-04-14T13:31:22.938Z","touchpoint_template_id":"60358a843e912332339155cf"}]'
        );
        insert CampaignObj2;

        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'james@abc.com';
        con.Phone = '1212212213';
        con.IsTelosTouchSyncAllowed__c = false;
        con.TT_Client_Id__c = 'abc';
        con.TelosTouchSF__TT_Conflict__c = false;
        insert con;

        Lead lead = new Lead();
        lead.LastName = 'test';
        lead.Status = 'Open';
        lead.Company = 'Test Lead';
        lead.TT_Client_Id__c = 'abc122';
        lead.Email = 'james24@abc.com';
        lead.Phone = '1212212213';
        lead.IsTelosTouchSyncAllowed__c = false;
        lead.TelosTouchSF__TT_Conflict__c = false;
        insert lead;

        Insights__c conversationObject = new Insights__c();
        conversationObject.Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.Campaign2__c = CampaignObj.Id;
        conversationObject.Answers__c = '[{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Hi, we wanted to follow up on your tax return for 2018"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"How was it for you?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I received a large refund"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"I understand. How would you like us to act on this?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Decrease withholding tax on my RRIF for 2019"},{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"Great, someone from our team will reach out to you shortly"},{"type":"uploader","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"In the meantime, can you take a photo of your Notice of Assessment and upload it for us to review?"},{"type":"image/png","resource_url":"https://test2.systelospro.com/crm-v2/?entryPoint=attachment&id=5f4e4f33786aeb472","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc87","content":"TTLogo.png"}]';
        conversationObject.Contact__c = con.Id;

        Insights__c conversationObject2 = new Insights__c();
        conversationObject2.Conversation_Id__c = '5f527d53aa941c1bda3b0074';
        conversationObject2.Name = 'Conversation';
        conversationObject2.Campaign2__c = CampaignObj.Id;
        conversationObject2.Answers__c = '[{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"Hi, we wanted to follow up on your tax return for 2018"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"How was it for you?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"I received a large refund"},{"type":"button","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"I understand. How would you like us to act on this?"},{"type":"","resource_url":"","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"Decrease withholding tax on my RRIF for 2019"},{"type":"text","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"Great, someone from our team will reach out to you shortly"},{"type":"uploader","resource_url":"","is_robot":true,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"In the meantime, can you take a photo of your Notice of Assessment and upload it for us to review?"},{"type":"image/png","resource_url":"https://test2.systelospro.com/crm-v2/?entryPoint=attachment&id=5f4e4f33786aeb472","is_robot":false,"conversation_id":"5f4e4eeb6a3bfc1cc544cc88","content":"TTLogo.png"}]';
        conversationObject2.Lead__c = lead.Id;

        Insert new list<Insights__c>{conversationObject, conversationObject2} ;
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
        Test.stopTest();
    }

    @isTest
    static void getCampaignDataTest() {

        list<Campaign> lstCampTest = [SELECT Id FROM Campaign WHERE CreatedDate = TODAY AND Name = 'Adult is Going Back to School'];
        Test.startTest();
        Campaign campSuccess = TTFilterUserController.getCampaignData(lstCampTest[0].Id);
        System.assert(campSuccess.Id == lstCampTest[0].Id, 'Campaign not matching.');
        Exception ex;
        try {
            TTFilterUserController.getCampaignData('error');
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex != null, 'Exception not found.');
        Test.stopTest();

    }

    @isTest
    static void requestSyncTest() {

        list<Campaign> lstCampTest = [SELECT Id FROM Campaign WHERE CreatedDate = TODAY AND Name = 'Adult is Going Back to School'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TTCampaignUserConversationMock());
        TTFilterUserController.requestSync(lstCampTest[0].Id);
        Exception ex;
        try {
            TTFilterUserController.requestSync('error');
        } catch (Exception e) {
            ex = e;
        }
        System.assert(ex != null, 'Exception not found.');
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
    static void addClientsToCampaignTest(){
        
        List<Campaign> lstCamp = [SELECT Id FROM Campaign  WHERE Name = 'Adult is Going Back to School' AND CreatedDate = TODAY];
        List<Contact> lstCtt = [SELECT Id FROM Contact WHERE Email = 'james@abc.com' AND CreatedDate = TODAY];
        List<Lead> lstLead = [SELECT Id FROM Lead WHERE Email = 'james24@abc.com' AND CreatedDate = TODAY];

        String clintStr1 = '[{"ContactOrLeadSFId":"'+lstCtt[0].Id+'"}]';
        String clintStr2 = '[{"ContactOrLeadSFId":"'+lstLead[0].Id+'"}]';
        
        Test.startTest();
        String response1 = TTFilterUserController.addClientsToCampaign(lstCamp[0].Id, clintStr1);
        String response2 = TTFilterUserController.addClientsToCampaign(lstCamp[0].Id, clintStr2);
        String error1 = TTFilterUserController.addClientsToCampaign(lstCamp[0].Id, null);
        String error2 = TTFilterUserController.addClientsToCampaign(lstCamp[0].Id, clintStr1);

        System.assert(response1 == lstCamp[0].Id, 'Error adding contact to the campaign');
        System.assert(response2 == lstCamp[0].Id, 'Error adding lead to the campaign');
        System.assert(error1.contains('error#'), 'error must not be blank');
        System.assert(error2.contains('error#'), 'error must not be blank');

        Test.stopTest();
        
    }

    @isTest
    static void insightCalloutTest(){
        
        List<Insights__c> lstInsight = [SELECT Id FROM Insights__c];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new TTUserConversationTestMock());
        TTFilterUserController.insightCallout(lstInsight[0].Id);

        String error;
        try {
            TTFilterUserController.insightCallout(null);
        } catch (Exception ex) {
            error = ex.getMessage();
        }

        List<Insights__c> lstInsightAfter = [SELECT Id, TelosTouchSF__Answers__c FROM Insights__c];
        System.assertEquals(String.isNotBlank(lstInsightAfter[0].TelosTouchSF__Answers__c), true, 'TelosTouchSF__Answers__c must not be blank');
        System.assertEquals(String.isNotBlank(error), true, 'error must not be blank');

        Test.stopTest();
        
    }

    @isTest
    static void fetchLimitedRecordsTest(){
        
        List<Campaign> lstCamp = [SELECT Id FROM Campaign  WHERE Name = 'Adult is Going Back to School' AND CreatedDate = TODAY];

        Test.startTest();
        
        String response = TTFilterUserController.fetchLimitedRecords(lstCamp[0].Id);
        System.assertEquals(String.isNotBlank(response), true, 'response must not be blank');

        Test.stopTest();
        
    }
    @isTest
    static void isClientTaggingEnabledTest(){   
        TTFilterUserController.PicklistValue userWrapperObj2 = new TTFilterUserController.PicklistValue();
        userWrapperObj2.question = 'test';
        userWrapperObj2.isSelected = true;
        userWrapperObj2.key = 'abc';
        Test.startTest();
        Boolean response = TTFilterUserController.isClientTaggingEnabled();
        System.assert(!response, 'It should be false initially');
        Test.stopTest();
    }
    @isTest
    static void isCampaignSyncEnabledTest(){  
        TTFilterUserController.TTFilterWrapper userWrapperObj2 = new TTFilterUserController.TTFilterWrapper();
        userWrapperObj2.name = 'test';
        userWrapperObj2.pendingOpened_At = 'true';
        userWrapperObj2.pendingCompleted_At = 'abc';
        Test.startTest();
        Map<String, String> response = TTFilterUserController.isCampaignSyncEnabled();
        System.assert(response.keySet() != null, 'It should be not be empty');
        Test.stopTest();
    }
    @isTest
    static void fetchRecordsTest(){  
        Test.startTest();
        String response = TTFilterUserController.fetchRecords('Campaign','','',[SELECT Id FROM Campaign LIMIT 1].Id);
        System.assert(response != null, 'It should not be empty');
        Test.stopTest();
    }

}