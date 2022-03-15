@isTest
private with sharing class Batch_UpdateContactAndLead_Test { 
    @testSetup
    static void addSetupMethod(){
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHZpc2dmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com'; 
        insert credential;
        
        List<TT_Salesforce_Mapping__c> mappingList = new List<TT_Salesforce_Mapping__c>();
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='firstName', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='lastName', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='emailAddress', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phoneNumber', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Subscribed__c', TT_Field__c='subscribed', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='firstName', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='lastName', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='emailAddress', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phoneNumber', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Subscribed__c', TT_Field__c='subscribed', Object_Name__c='Contact'));
		mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='ActivityDate', TT_Field__c='date_due', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Subject', TT_Field__c='name', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Status', TT_Field__c='status', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Client_Id__c', TT_Field__c='client_id', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Client_Name__c', TT_Field__c='client_name', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Description', TT_Field__c='description', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Share_with_client_s__c', TT_Field__c='shared', Object_Name__c='Task'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__TT_Category__c', TT_Field__c='type', Object_Name__c='Task'));
        
        insert mappingList;
    }
    @isTest
    static void test() {
        String cronExp = '0 0 0 15 3 ? *';
        Contact con = new Contact();
        con.LastName ='Test';
        con.Email = 'test@ca.com';
        con.TelosTouchSF__IsTelosTouchSyncAllowed__c = true;
        insert con;
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.Email = 'test2@ca.com';
        leadObj.Company = 'CA';
        insert leadObj;
        Task taskObj = new Task();
        taskObj.Subject = 'Test Task';
        taskObj.ActivityDate = Date.today();
        taskObj.WhoId = con.Id;
        insert taskObj;
        Datetime timeDate = Datetime.now().addMinutes(-30);
        Test.setCreatedDate(con.Id, timeDate); 
        String jobId = System.schedule('ScheduleApexClassTest',  cronExp, new TelosTouchSF.ScheduleSyncingContactsAndLeads());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression ,'ct.CronExpression should be equal to 0 0 0 15 3 ? *');
        System.assertEquals(0, ct.TimesTriggered, 'ct.TimesTriggered should be equal to 0');
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.SFDataSyncWithTelosTouchMock2());
        Test.startTest();
        TelosTouchSF.Batch_UpdateContactAndLead batchObj = new TelosTouchSF.Batch_UpdateContactAndLead(null, null);
        Database.executeBatch(batchObj);
        Test.stopTest();
    } 
}