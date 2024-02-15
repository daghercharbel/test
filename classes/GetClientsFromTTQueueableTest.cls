@istest
public with sharing class GetClientsFromTTQueueableTest {
    @testSetup
    static void addSetupMethod(){        
        List<TT_Salesforce_Mapping__c> mappingList = new List<TT_Salesforce_Mapping__c>();
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='first_name', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='last_name', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='email', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phone', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Subscribed__c', TT_Field__c='subscribed', Object_Name__c='Lead'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='FirstName', TT_Field__c='first_name', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='LastName', TT_Field__c='last_name', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Email', TT_Field__c='email', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='TelosTouchSF__Language__c', TT_Field__c='language', Object_Name__c='Contact'));
        mappingList.add(new TT_Salesforce_Mapping__c(Salesforce_Field__c='Phone', TT_Field__c='phone', Object_Name__c='Contact'));
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
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Swapnil 1';
        con.Email = 'swapnil.sen+4768736@cloudanalogy.com';
        con.Phone = '923704';
        
        Contact con1 = new Contact();
        con1.LastName = 'Swapnil 2';
        con1.TT_Client_Id__c = '2u90iwj23o923';
        con1.Language__c = 'French';
        
        List<Contact> conList = new List<Contact>{con, con1};
            insert conList;
        List<Lead> leadList = new List<Lead>();
        
        Lead ld = new Lead();
        ld.Company = 'CA 1';
        ld.LastName = 'Swapnil 1';
        ld.Email = 'swapnil.sen+4768736@cloudanalogy.com';
        ld.TT_Client_Id__c = '82u934r897';
        leadList.add(ld);
        
        Lead ld2 = new Lead();
        ld2.Company = 'aviation';
        ld2.LastName = 'Gaurav';
        ld2.Email = 'gaurav.bisht+324345354@avn.com';
        ld2.Language__c = 'French';
        leadList.add(ld2);
        
        Lead ld3 = new Lead();
        ld3.Company = 'aviation';
        ld3.LastName = 'Gaurav';
        ld3.Email = 'gaurav.bisht+8374987893@avn.com';
        ld3.Language__c = 'French';
        leadList.add(ld3);
        
        Lead ld4 = new Lead();
        ld4.Company = 'aviation';
        ld4.LastName = 'Gaurav';
        ld4.Email = 'gaurav.bisht+34344434343@avn.com';
        ld4.Language__c = 'French';
        leadList.add(ld4);
        
        Lead ld5 = new Lead();
        ld5.Company = 'aviation';
        ld5.FirstName = 'Gaurav';
        ld5.LastName = 'Test';
        ld5.Email = 'gaurav.bisht+2398797322873@avn.com';
        ld5.Phone = '378391768';
        ld5.Language__c = 'English';
        ld5.Subscribed__c = 'Yes';
        leadList.add(ld5);
        
        insert leadList;
    }
    @isTest
    public static void testGetClients1(){
        System.debug([SELECT Count() FROM Lead]);
        
        Task taskTest = new Task();
        taskTest.Priority = 'High';
        taskTest.Subject = 'Test';
        taskTest.Status = 'Completed';
        taskTest.Share_with_client_s__c = 'No';
        taskTest.ActivityDate = Date.today();
        taskTest.Description = 'asdf';
        taskTest.TelosTouchSF__TT_TaskId__c = '4298h398r37895379848u9u';
        insert taskTest;
        
        Test.startTest();
        GetClientFromTTMock mockClass = new GetClientFromTTMock();
        mockClass.taskId = taskTest.Id;
        Test.setMock(HttpCalloutMock.class, mockClass);
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new GetClientsFromTTScheduler());
        Datetime last_login_date = (DateTime)JSON.deserialize('"2022-01-05T09:49:35.000Z"', DateTime.class);
        String formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
        System.assert(formattedDate!=null,'it should not be equal to null');
        GetClientsFromTTQueueable.getDateFormate(formattedDate);
        Test.stopTest();
    }
}