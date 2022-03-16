@isTest
private with sharing class OpenAtAndCompleteAtGraphTest {
    @isTest
    static void getConversationRecordsTest(){
        Campaign campaignObj = new Campaign();
        campaignObj.Name = 'CampaignName';
        insert campaignObj;
        
        Campaign campaignObj1 = new Campaign();
        campaignObj1.Name = 'CampaignName1';
        insert campaignObj1;
        
        TelosTouchSF__Insights__c insightsObj = new TelosTouchSF__Insights__c();
        insightsObj.Name = 'insightName';
        insightsObj.TelosTouchSF__Campaign2__c = campaignObj.Id;
        insightsObj.TelosTouchSF__Opened_At__c = DateTime.now();
        insightsObj.TelosTouchSF__Completed_At__c = DateTime.now();
        insert insightsObj;
        
        Test.startTest();
        String result = TelosTouchSF.OpenAtAndCompleteAtGraph_Controller.getConversationRecords(campaignObj.Id);
        System.assertEquals(true, result!=null, 'result should not br NULL');
        String result1 = TelosTouchSF.OpenAtAndCompleteAtGraph_Controller.getConversationRecords(campaignObj1.Id);
        System.assertEquals(true, result1!=null, 'result1 should not be NULL');
        Test.stopTest();
        
    }
}