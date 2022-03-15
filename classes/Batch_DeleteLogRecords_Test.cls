@isTest
private with sharing class Batch_DeleteLogRecords_Test {
    @isTest
    static void test() {
        TelosTouchSF__TT_Log__c c1 = new TelosTouchSF__TT_Log__c();
        c1.TelosTouchSF__Comments__c = 'New';
        insert c1; 
        
        Datetime yesterday = Datetime.now().addDays(-35);
        Test.setCreatedDate(c1.Id, yesterday); 
        
        Test.startTest();
        String cronExp = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  cronExp, new TelosTouchSF.Schedule_DeleteLogRecords());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'cronExp should be equal to 0 0 0 15 3 ? *');
        System.assertEquals(0, ct.TimesTriggered, 'ct.TimesTriggered should be equal to 0');
        TelosTouchSF.Batch_DeleteLogRecords batchObj = new TelosTouchSF.Batch_DeleteLogRecords();
        Database.executeBatch(batchObj);
        Test.stopTest();
    }
}