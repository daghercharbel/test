@isTest
public with sharing class TTUserConversationTest {
	@isTest
    static void userConversationCampaignTest() {
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VZpc29yOmhhdmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com'; 
        insert credential;
        
        Insights__c conversationObject = new Insights__c();
        conversationObject.Conversation_Id__c = '5f527d53aa941c1bda3b0073';
        conversationObject.Name = 'Conversation';
        conversationObject.Campaign2__c = CampaignObj.Id;
        conversationObject.Answers__c = 'Answers';
        Insert conversationObject;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TTUserConversationTestMock());
        TTUserConversationScheduler schObj = new TTUserConversationScheduler();
        string sch = '0 0 * * * ?';
        system.schedule('test',sch,schObj);
        
        TTUserConversation obj = new TTUserConversation();
        Database.executeBatch(obj);
        
        Insights__c [] conversationList = [SELECT Id,Name, Answers__c FROM Insights__c];
        System.assertEquals(conversationList[0].Answers__c != null , true, 'conversationList[0].Answers__c must not be NULL');
        Test.stopTest(); 
    }
    @isTest
    static void TTCampaignUserConversationTest() {
        List<Campaign> campaignObjectList = new List<Campaign>();
        Campaign CampaignObj = new Campaign(
            Name = 'Adult is Going Back to School',
            IsActive = false,
            Type = 'Conference',
            TT_Campaign_Id__c = '5f4e65e9d5d22d1cbed9',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        campaignObjectList.add(CampaignObj);
        Insert campaignObjectList;
        
        /***************************************************************/
        String firstFakeResponseRespString = '{"id":"60ddc58ba30c31a2afae2d50","created_at":"2021-07-01T13:39:23.971Z","created_by":"Mohd Rais","name":"Image Touchpoint","name_fr":"nouveau modèle","touchpoint_template_id":"60dadf2d0cb607a3ced073d6","conversations":[{"conversation_id":"60ddc58ba30c31a2afae2d52","completed_at":"2021-07-01T13:42:29.051Z","opened_at":"2021-07-01T13:42:23.439Z","status_touchpoint":"completed","user_id":"782ea8a2-081a-4adb-b493-47613cd8fdd4","user_name":"HR SF Lead T11 1-7","contact_id":"60ddb798d0c2a8a2a3da1967","avatarId":null,"language":"fr_FR"},{"conversation_id":"60ddc58ba30c31a2afae2d53","completed_at":"2021-07-01T13:44:30.605Z","opened_at":"2021-07-01T13:44:25.867Z","status_touchpoint":"completed","user_id":"73a61a8a-49ff-4be4-980c-c2ebe281bc2d","user_name":"HR SF Contact  T11 1-7","contact_id":"60ddb7c4d0c2a8a2a3da1969","avatarId":null,"language":"fr_FR"}]}';
        String secondFakeResponseRespString='{ "answers": [ { "id": "5f5a3cdebad093641a5b412f", "conversation_id": "5f5a3ca7bad093641a5b4129", "questionsandanswers": [ { "question": "Thanks for watching or reading, would you like to learn more regarding any of the below:", "answers": [ "Portfolio management & trades " ], "type": "button", "key": "5f08c8770e7a9d038008d811" }, { "question": "Protecting your assets is our primary responsibility. If you would like to discuss trade decisions further, please let us know.", "answers": [ "Im fine, thank you" ], "type": "button", "key": "5f08c8770e7a9d038008d816" } ], "user_id": "5f3154b14fcfcde2c", "modified_by": "System", "modified_at": "2020-09-10T14:49:17.049Z", "created_by": "System", "created_at": "2020-09-10T14:49:02.273Z", "touchpoint_template_id": "5f08c8770e7a9d038008d5f5" } ], "questions": [ { "question": "Thanks for watching or reading, would you like to learn more regarding any of the below:", "key": "5f08c8770e7a9d038008d811", "type": "button", "answers": [ "Portfolio management & trades ", "COVID-19 relief government initiatives ", "Im fine, thank you" ], "question_fr": "Merci den avoir pris connaissance. Aimeriez-vous en savoir plus sur lun des sujets suivants?", "answers_fr": [ "Gestion de portefeuille et transactions", "COVID-19 mesures de support gouvernementales", "Non, merci" ] }, { "question": "Protecting your assets is our primary responsibility. If you would like to discuss trade decisions further, please let us know.", "key": "5f08c8770e7a9d038008d816", "type": "button", "answers": [ "Yes I would like to learn more", "Im fine, thank you" ], "question_fr": "La protection de vos actifs est notre première responsabilité. Laissez-nous savoir si vous souhaitez discuter plus en détails de la gestion de portefeuille", "answers_fr": [ "Oui, jaimerais en savoir plus", "Non, merci" ] }, { "question": "COVID-19 has been a difficult time. If you would like to discuss for any of these programs further, please let us know.", "key": "5f08c8770e7a9d038008d81b", "type": "button", "answers": [ "Yes I would like to learn more", "Im fine, thank you " ], "question_fr": "La COVID-19 a amené son lot de difficultés. Laissez-nous savoir si vous souhaitez discuter plus en détails de ces mesures gouvernementales", "answers_fr": [ "Oui, jaimerais en savoir plus", "Non, merci" ] } ] }}}';
        
        SingleRequestMock firstFakeResponseResp = new SingleRequestMock(200,'OK',firstFakeResponseRespString,null);
        System.assert(firstFakeResponseResp != null, 'firstFakeResponseResp must not be NULL');
        SingleRequestMock secondFakeResponseResp = new SingleRequestMock(200,'OK',secondFakeResponseRespString,null);
        System.assert(secondFakeResponseResp != null, 'secondFakeResponseResp must not be NULL');
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/'+CampaignObj.TT_Campaign_Id__c+'/clients',firstFakeResponseResp);
        endpoint2TestResp.put('https://test.com/api/v1/touchpoints/'+CampaignObj.TT_Campaign_Id__c+'/answers',secondFakeResponseResp); 
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null,'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        TTCampaignUserConversation obj = new TTCampaignUserConversation(campaignObjectList);
        Database.executeBatch(obj);
        Test.stopTest();
        Campaign [] campaignList = [SELECT Id, Name, TT_Campaign_Id__c FROM Campaign];
        System.assertEquals(CampaignObj.TT_Campaign_Id__c , campaignList[0].TT_Campaign_Id__c, 'CampaignObj.TT_Campaign_Id__c must be equal to campaignList[0].TT_Campaign_Id__c');
    } 
}