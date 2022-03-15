@isTest
public with sharing class MassAddToCampaignButtonControllerTest {
    @testSetup static void setup() {
        Campaign campaignObject = new Campaign();
        campaignObject.Name = 'campName';
        insert campaignObject;
        
        Lead leadObj = new Lead();
        leadObj.Company = 'adidas';
        leadObj.LastName = 'leadLastName';
        leadObj.Status = 'Open - Not Contacted';
        insert leadObj;
        
        Contact conObj = new Contact();
        conObj.LastName = 'LastName';
        insert conObj;
        
        Account accObj = new Account();
        accObj.Name = 'testname';
        insert accObj;
    }
    @isTest
    public static void constructorTest() {
        Account accObj = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1]; 
        Account accObj2 = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1];
        
        List<Account> accList = new List<Account>{accObj, accObj2};
        ApexPages.StandardSetController sc = new ApexPages.standardSetController(accList); 
        sc.setSelected(accList);
        MassAddToCampaignButtonController controller = new MassAddToCampaignButtonController(sc);
        System.assertEquals(accList.size() > 0, true, 'accList size should be greater than 0');
    }
    @isTest
    public static void checkPersonAccountOrNotTest(){
        //Contact conObj = [SELECT Id, LastName FROM Contact WHERE LastName = 'LastName' LIMIT 1];
        
        //Lead leadObj = [SELECT Id, Company, LastName, Status FROM Lead WHERE Company = 'adidas' LIMIT 1];
        
        Account accObj = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1]; 
        Account accObj2 = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1];
        
        Set<Id> newIdSet = new Set<Id>();
        newIdSet.add(accObj.Id);
        newIdSet.add(accObj2.Id);
        
        Test.StartTest(); 
        String recordIdsList= JSON.serialize(newIdSet);
        String objectName='Account';
        String result = MassAddToCampaignButtonController.checkPersonAccountOrNot(recordIdsList, objectName);
        System.assertEquals('have PersonAccount', result, 'result should be equal to have PersonAccount');
        Test.StopTest();
    }
    @isTest
    public static void addCamapignMemberTest(){
        Campaign campaignObject = [SELECT Id, Name FROM Campaign WHERE Name = 'campName' LIMIT 1];
        
        Account accObj = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1];
        
        Set<Id> newIdSet = new Set<Id>();
        newIdSet.add(accObj.Id);
        
        String recordIdsList =JSON.serialize(newIdSet);
        
        //Contact conObj = [SELECT Id, LastName FROM Contact WHERE LastName = 'LastName' LIMIT 1];
        
        Test.StartTest(); 
        String result = MassAddToCampaignButtonController.addCamapignMember(campaignObject, recordIdsList);
        System.assertEquals(result != NULL, true, 'result should not be NULL');
        Test.StopTest();
    }
    @isTest
    public static void getObjectDetailsTest(){
        Test.StartTest(); 
        Account accObj = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1];
        String objectName = 'Account';
        String recordId = accObj.Id;
        MassAddToCampaignButtonController.getObjectDetails(objectName, recordId);
        
        Contact conObj = [SELECT Id, LastName FROM Contact WHERE LastName = 'LastName' LIMIT 1];        
        objectName = 'Contact';
        recordId = conObj.Id;
        String result = MassAddToCampaignButtonController.getObjectDetails(objectName, recordId);
        System.assertEquals('LastName', result, 'result should be equal to result');
        Test.StopTest();
    }
    @isTest
    public static void updateCampaignRecordTest(){
        Test.StartTest(); 
        Account accObj = [SELECT Id, Name FROM Account WHERE Name = 'testName' LIMIT 1];
        
        Campaign campaignObject = [SELECT Id, Name FROM Campaign WHERE Name = 'campName' LIMIT 1];
        
        Contact conObj = [SELECT Id, LastName FROM Contact WHERE LastName = 'LastName' LIMIT 1];
        
        Lead leadObj = [SELECT Id, Company, LastName, Status FROM Lead WHERE Company = 'adidas' LIMIT 1];
        
        String objectName = 'Contact';
        String recordId = conObj.Id;
        String campId = campaignObject.id;
        String campName = campaignObject.Name;        
        MassAddToCampaignButtonController.updateCampaignRecord(objectName, recordId, campId, campName);
        
        objectName = 'Lead';
        recordId = leadObj.Id;
        campId = campaignObject.id;
        campName = campaignObject.Name;  
        MassAddToCampaignButtonController.updateCampaignRecord(objectName, recordId, campId, campName);
        
        objectName = 'Account';
        recordId = accObj.Id;
        campId = campaignObject.id;
        campName = campaignObject.Name;  
        String result = MassAddToCampaignButtonController.updateCampaignRecord(objectName, recordId, campId, campName);
        System.assertEquals('isNotPersonAccount', result, 'result should be equal to isNotPersonAccount');
        
        Test.StopTest();
    }
    @isTest
    public static void getCampaignRecordTypeTest(){
        Test.StartTest(); 
        List<RecordType> campaignRecordTypeList = MassAddToCampaignButtonController.getCampaignRecordType();
        System.assertEquals(campaignRecordTypeList != NULL, true, 'campaignRecordTypeList should not be NULL');
        Test.StopTest();
    }
    @isTest
    public static void createNewCampaignApexTest(){        
        Campaign campaignObject = [SELECT Id, Name FROM Campaign WHERE Name = 'campName' LIMIT 1];
        
        Test.StartTest(); 
        String campName = campaignObject.Name; 
        String campRecordTypeName ='TelosTouch';
        Campaign obj = MassAddToCampaignButtonController.createNewCampaignApex(campName, campRecordTypeName);
        System.assertEquals( obj != NULL, true, 'obj should not be NULL');
        Test.StopTest();
    }
}