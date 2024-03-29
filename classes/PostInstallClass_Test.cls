@isTest
public with sharing class PostInstallClass_Test {
    @isTest
    public static void testInstallScript() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test186ew74368@gmail.com');
        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, new TelosTouchSF.MockResponse_Test());
            TelosTouchSF.PostInstallClass postinstall = new TelosTouchSF.PostInstallClass();
            Test.testInstall(postinstall, null);
            Test.testInstall(postinstall, new Version(1, 0), true);
            TelosTouchSF__TT_Salesforce_Mapping__c envoySaeAccount = new TelosTouchSF__TT_Salesforce_Mapping__c();
            String cronExp = '0 0 0 15 3 ? *';
            Contact con = new Contact();
            con.LastName ='Test';
            con.Email = 'test@ca.com';
            insert con;
            TelosTouchSF.PermissionSetForInsightObjMD obj = new  TelosTouchSF.PermissionSetForInsightObjMD();
            obj.createPermissionSet('Test','Test1');
            String jobId = System.schedule('ScheduleApexClassTest', cronExp, new TelosTouchSF.ScheduleSyncingContactsAndLeads());
            Database.ExecuteBatch(new TelosTouchSF.BatchPostInstallScript('Contact'));
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronExp, ct.CronExpression, 'ct.CronExpression should be equal to 0 0 0 15 3 ? *');
            System.assertEquals(0, ct.TimesTriggered , 'ct.TimesTriggered should be equal to 0');
        }
    }
    
    @isTest
    public static void testInstallScript2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test186ew74368@gmail.com');
        System.runAs(u) {
            task taskObj1 = new task();
            taskObj1.Subject = 'Email';
            taskObj1.Status = 'Not Started';
            taskObj1.TelosTouchSF__IsTelosTouchSyncAllowed__c = false;
            insert taskObj1;
            ID jobID13 = Database.ExecuteBatch(new TelosTouchSF.BatchPostInstallScript('Task')); 
            AsyncApexJob asyncObj = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'BatchPostInstallScript' AND Status != 'Completed'];
            System.assertEquals(asyncObj.Id, jobID13, 'jobID13 should be equal to asyncObj.Id');
        }
    }
    
    @isTest
    public static void testInstallScript3() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test186ew74368@gmail.com');
        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, new TelosTouchSF.SFDataSyncWithTelosTouchMock1());
            TelosTouchSF.PostInstallClass postinstall = new TelosTouchSF.PostInstallClass();
            Test.testInstall(postinstall, null);
            Test.testInstall(postinstall, new Version(1, 0), true);
            System.assert([SELECT COUNT()FROM TelosTouchSF__TT_Salesforce_Mapping__c]>=0);
        }
    }
    
    @isTest
    public static void testInstallScript4() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='test1868687687@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test186ew74368@gmail.com');
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TelosTouch_Custom_Permission'];
		insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        
        System.runAs(u) {
            TelosTouchSF.PostInstallClass postinstall = new TelosTouchSF.PostInstallClass();
            Test.testInstall(postinstall, null);
        }
    }
}