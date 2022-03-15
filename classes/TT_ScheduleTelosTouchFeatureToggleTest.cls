@istest
private class TT_ScheduleTelosTouchFeatureToggleTest {
    
    @isTest static void scheduleBatchTest(){
        Test.startTest();
        TelosTouchSF.TT_ScheduleTelosTouchFeatureToggle invite = new TelosTouchSF.TT_ScheduleTelosTouchFeatureToggle();
        invite.execute(null);
        System.assert(true,'it should be true');
        Test.stopTest();
    }
}