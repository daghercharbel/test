@isTest
public class SendSFUserBatchTest {
    
    @isTest 
    static void executeTest() {
        
        Profile profTest = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User userTest = new User(
            Alias = 'standt', Email='test1868687687@gmail.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = profTest.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test1868687687@gmail.com'
        );
        insert userTest;
        
        TelosTouch_User_Role__c customSettingObj = new TelosTouch_User_Role__c(name= 'customtest',RolesName__c='Test');
        insert customSettingObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        TelosTouchUtility.sendSFUserToTT(new list<User>{userTest},new list<Id>{userTest.Id});
        Test.stopTest();
        
        list<TelosTouch_User_Role__c> customSettingList = new list<TelosTouch_User_Role__c>();
        customSettingList = [select RoleId__c,RolesName__c from TelosTouch_User_Role__c];
        system.assertEquals('Test', customSettingList[0].RolesName__c, 'customSettingList[0].RolesName__c must be equal to Test');
    } 

}