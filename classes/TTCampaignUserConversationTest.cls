@isTest
global with sharing class TTCampaignUserConversationTest {
    @isTest 
    static void ttUserConversationCampaignTest() {
        List<Campaign> campaignList = new List<Campaign>();
        Campaign campaignObj = new Campaign(
            Name = 'Adult is Going Back to School',                                                                                                                                                                                                                                                                                                                   // Campaign Name
            IsActive = false,                                                                                                                                                                                                                                                                                                                                          // Active
            Type = 'Conference',                                                                                                                                                                                                                                                                                                                                       // Type
            TelosTouchSF__Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n',  // Questions
            TelosTouchSF__Answers__c = '[{"touchpoint_template_id":"60ba3c1af14b7123cc22d3d0","created_at":"2021-06-07T17:20:56.442Z","created_by":"System","modified_at":"2021-06-07T17:21:00.939Z","modified_by":"System","client_id":"60be5367b18347ab320d0d90","user_id":"","questionsandanswers":[{"key":"60ba3c1af14b7123cc22d3d6","type":"button","answers":["Investment/Recreational Property"],"question":"Was it a principal residence or investment property?"},{"key":"60ba3c1af14b7123cc22d3da","type":"multibutton","answers":["We need to discuss the tax implications of the sale"],"question":"Understood. Which of the following would you be interested in discussing?"}],"conversation_id":"60be5545ebf8d8ab3260f1a7","id":"60be55781d9b0cab3296cd7e"}]'
        );
        insert campaignObj;
        campaignList.add(campaignObj);
        
        TelosTouchSF__TelosTouch_API_Settings__c credential = new TelosTouchSF__TelosTouch_API_Settings__c();
        credential.TelosTouchSF__Token__c = 'dGVsb3N0b3VjaFOmhhdmVmdW4xMjNA';
        credential.TelosTouchSF__Instance_url__c = 'https://test.com'; 
        insert credential;
        
        TelosTouchSF__Insights__c conversationObject = new TelosTouchSF__Insights__c();
        conversationObject.TelosTouchSF__Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.TelosTouchSF__Campaign2__c = campaignObj.Id;
        insert conversationObject;
        Map<String,Object> newMap = new Map<String,Object>();
        newMap.put('abcbcds',conversationObject);
        String s = JSON.serialize(newMap);
        System.assert(s != null, 's should not be NULL');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TTCampaignUserConversationMock());  
        TelosTouchSF.TTUserConversationUpdate obj = new TelosTouchSF.TTUserConversationUpdate(campaignList);
        Database.executeBatch(obj);
        //Database.executeBatch(new BatchCreateAnswers(campaignList));
        Test.stopTest();
    }
    @isTest
    static  void ttUserConversationCampaignTest2() {
        List<Campaign> campaignList = new List<Campaign>();
        Campaign campaignObj = new Campaign(
            Name = 'Adult is Going Back to School',                                                                                                                                                                                                                                                                                                                   // Campaign Name
            IsActive = false,                                                                                                                                                                                                                                                                                                                                          // Active
            Type = 'Conference',                                                                                                                                                                                                                                                                                                                                       // Type
            TelosTouchSF__Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'  // Questions
        );
        insert campaignObj;
        campaignList.add(campaignObj);
        
        TelosTouchSF__TelosTouch_API_Settings__c credential = new TelosTouchSF__TelosTouch_API_Settings__c();
        credential.TelosTouchSF__Token__c = 'dGVsb3N0b3VjaF9hZHZdmVmdW4xMjNA';
        credential.TelosTouchSF__Instance_url__c = 'https://test.com'; 
        insert credential;
        
        TelosTouchSF__Insights__c conversationObject = new TelosTouchSF__Insights__c();
        conversationObject.TelosTouchSF__Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.TelosTouchSF__Campaign2__c = campaignObj.Id;
        insert conversationObject;
        Map<String,Object> newMap = new Map<String,Object>();
        newMap.put('abcbcds',conversationObject);
        String s = JSON.serialize(newMap);
        System.assert(s != null, 's should not be NULL');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TTCampaignUserConversationMock2());  
        TelosTouchSF.TTCampaignUserConversation obj = new TelosTouchSF.TTCampaignUserConversation(campaignList);
        Database.executeBatch(obj);
        Test.stopTest();
    }
}