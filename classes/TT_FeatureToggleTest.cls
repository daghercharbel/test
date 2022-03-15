@isTest
private with sharing class TT_FeatureToggleTest {
    
    @isTest static void checkInviteFunctionality() {
        Test.startTest();
        TelosTouchSF.TT_FeatureToggle invite = new TelosTouchSF.TT_FeatureToggle();
        Id batchId = Database.executeBatch(invite);
        System.assert(batchId!=null,'it should not be null');
        Test.stopTest();
    }
}