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
        TTCampaignTickerController.AddMissingClient(campTest.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCampaignDataTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        TTCampaignTickerController.getCampaignData(campTest.Id);
        TTCampaignTickerController.getCampaignData('exception');
        Test.stopTest();
    }
    
    @isTest
    static void getCustomizeUrlTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        TTCampaignTickerController.getCustomizeUrl('touchpoint', campTest.Id, 'templateId');
        TTCampaignTickerController.getCustomizeUrl('email', campTest.Id, 'templateId');
        Test.stopTest();
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
        TTCampaignTickerController.getTTClients(campTest.Id);
        Test.stopTest();
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
        TTCampaignTickerController.removeExtraClient(campTest.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateSentInsightTest(){
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TTCampaignTickerControllerTest'];
        Test.startTest();
        TTCampaignTickerController.updateSentInsight(campTest.Id);
        Test.stopTest();
    }

}