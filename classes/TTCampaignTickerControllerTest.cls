@isTest
public with sharing class TTCampaignTickerControllerTest {

    @testSetup static void setupMethod() {
        
        Contact cttTest = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'TTCampaignTickerControllerTest1@telostouch.com',
            TelosTouchSF__TT_Client_Id__c = 'test1'
        );
        Contact cttTest2 = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'TTCampaignTickerControllerTest2@telostouch.com',
            TelosTouchSF__TT_Client_Id__c = 'getv2campaign2'
        );
        insert new list<Contact>{cttTest,cttTest2};

        Campaign campTest = new Campaign(
            Name='TTCampaignTickerControllerTest',
            TelosTouchSF__TT_Campaign_Id__c = 'TTCampaignTickerControllerTest'
        );
        insert campTest;
        
    }

    @isTest
    static void AddMissingClientTest(){
        
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Contact cttTest = [SELECT Id FROM Contact WHERE Email = 'TTCampaignTickerControllerTest1@telostouch.com'];

        CampaignMember memberTest = new CampaignMember(
            CampaignId = campTest.Id,
            ContactId = cttTest.Id
        );
        insert memberTest;
        
        Test.startTest();
        map<String,String> returnMap = TTCampaignTickerController.AddMissingClient(campTest.Id);
        Test.stopTest();
        System.assert(returnMap != null, 'returnMap should not be null');
    }
    
    @isTest
    static void getCampaignDataTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        map<String,String> returnMap1 = TTCampaignTickerController.getCampaignData(campTest.Id);
        map<String,String> returnMap2 = TTCampaignTickerController.getCampaignData('exception');
        Test.stopTest();
        System.assert(returnMap1 != null, 'returnMap1 should not be null');
        System.assert(returnMap2 != null, 'returnMap2 should not be null');
    }
    
    @isTest
    static void getCustomizeUrlTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        map<String,String> returnMap1 = TTCampaignTickerController.getCustomizeUrl('touchpoint', campTest.Id, 'templateId');
        map<String,String> returnMap2 = TTCampaignTickerController.getCustomizeUrl('email', campTest.Id, 'templateId');
        Test.stopTest();
        System.assert(returnMap1 != null, 'returnMap1 should not be null');
        System.assert(returnMap2 != null, 'returnMap2 should not be null');
    }

    @isTest
    static void getTTClientsTest(){
        
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Contact cttTest = [SELECT Id FROM Contact WHERE Email = 'TTCampaignTickerControllerTest1@telostouch.com'];

        CampaignMember memberTest = new CampaignMember(
            CampaignId = campTest.Id,
            ContactId = cttTest.Id
        );
        insert memberTest;
        
        Test.startTest();
        map<String,String> returnMap = TTCampaignTickerController.getTTClients(campTest.Id);
        Test.stopTest();
        System.assert(returnMap != null, 'returnMap should not be null');
    }
    

    @isTest
    static void removeExtraClientTest(){
        
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        list<Contact> lstCtt = [SELECT Id FROM Contact WHERE Email like: 'TTCampaignTickerControllerTest%' ORDER BY Email ASC];
        
        TelosTouchSF__Insights__c insTest = new TelosTouchSF__Insights__c(
            TelosTouchSF__Campaign2__c = campTest.Id,
            TelosTouchSF__Contact__c = lstCtt[1].Id
        );
        insert insTest;

        CampaignMember memberTest = new CampaignMember(
            CampaignId = campTest.Id,
            ContactId = lstCtt[0].Id
        );
        insert memberTest;
        
        Test.startTest();
        map<String,String> returnMap = TTCampaignTickerController.removeExtraClient(campTest.Id);
        Test.stopTest();
        System.assert(returnMap != null, 'returnMap should not be null');
    }
    
    @isTest
    static void updateSentInsightTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        map<String,String> returnMap = TTCampaignTickerController.updateSentInsight(campTest.Id);
        Test.stopTest();
        System.assert(returnMap != null, 'returnMap should not be null');
    }

}