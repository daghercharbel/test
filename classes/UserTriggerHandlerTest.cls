@isTest
private with sharing class UserTriggerHandlerTest {
    
    @isTest
    static void userTriggerHandlermethodTest() {
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0); 
        Profile p2 = [SELECT id, Name FROM Profile where name LIKE '%Marketing%' ].get(0);  
        User userObj = new User(firstname= 'Bhoopesh',lastname='Test',Alias='Test',email = 'Bhoopesh@gmail1.com',
                                username= 'Bhoopesh@gmail1.com', profileId= p.id, emailencodingkey='UTF-8',
                                languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                                TelosTouchSF__TT_UserId__c='test',TelosTouchSF__Token__c='test',TelosTouchSF__TT_UserName__c='test',IsActive= true);
        insert userObj;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: System.Label.TelosTouchSF.TelosTouch_Permission_Set_Name WITH SECURITY_ENFORCED];
        insert new PermissionSetAssignment(AssigneeId = userObj.Id, PermissionSetId = ps.Id);
        System.runAs(userObj) {
            
            list<user> deactivatedUserList = new list<user>();
            
            User userObj2 = new User(firstname= 'Bhoopesh',lastname='Test',Alias='Test',email = 'Bhoopesh@gmail3.com',
                                     username= 'Bhoopesh@gmail3.com', profileId= p2.id, emailencodingkey='UTF-8',
                                     languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                                     TelosTouchSF__TT_UserId__c='test',TelosTouchSF__Token__c='test',TelosTouchSF__TT_UserName__c='test',IsActive= true);
            deactivatedUserList.add(userObj2);	 
            User userObj3 = new User(firstname= 'Bhoopesh',lastname='Test',Alias='Test',email = 'Bhoopesh@gmail4.com',
                                     username= 'Bhoopesh@gmail4.com', profileId= p2.id, emailencodingkey='UTF-8',
                                     languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',
                                     TelosTouchSF__TT_UserId__c='test2',TelosTouchSF__Token__c='test',TelosTouchSF__TT_UserName__c='test',IsActive= true);
            deactivatedUserList.add(userObj3);
            insert deactivatedUserList;
            userObj3.languagelocalekey='en_US';
            userObj2.languagelocalekey='fr';
            userObj2.IsActive=false;
            userObj3.IsActive=false;    
            update userObj2;
            update userObj3;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock1());
            Test.stopTest();
            deactivatedUserList = [select id,languagelocalekey,IsActive from User limit 1];
            system.assertEquals('en_US', deactivatedUserList[0].languagelocalekey, 'deactivatedUserList[0].languagelocalekey should be equal to en_US');
        }
    }
    
}