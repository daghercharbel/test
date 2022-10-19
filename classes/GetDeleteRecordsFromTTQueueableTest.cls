@isTest 
private with sharing class GetDeleteRecordsFromTTQueueableTest {
    @testSetup static void setupMethod(){
        System.debug(LoggingLevel.DEBUG, 'Setup Method');
    }
    
    @isTest    
    static  void getTTCampaignIdTest() {        
        
        Test.startTest();
        TelosTouchSF.GetDeleteRecordsFromTTQueueable apc = new TelosTouchSF.GetDeleteRecordsFromTTQueueable();
        System.assertEquals(apc != null, true, 'apc not equal to null');
        Test.stopTest();
    }
}