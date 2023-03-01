@isTest
public with sharing class SendTestCampaignControllerTest {

    @testSetup static void setupMethod(){

        Campaign camp = new Campaign(
            name = 'SendTestCampaignControllerTest',
            TelosTouchSF__TouchPoint_Template_Id__c = 'SendTestCampaignControllerTest'
        );
        insert camp;

    }

    @isTest
    static void sendTestTemplateTest() {
      Test.setMock(
        HttpCalloutMock.class,
        new TelosTouchSF.TelosTouchUtilityMock()
      );

      Campaign camp = [SELECT Id FROM Campaign WHERE TelosTouchSF__TouchPoint_Template_Id__c = 'SendTestCampaignControllerTest' ];
      String emails = '["test@test.com"]';

      Test.startTest();
      SendTestCampaignController.sendTestTemplate(emails, camp.Id);
      SendTestCampaignController.sendTestTemplate(emails, 'null');
      Test.stopTest();
    }

}