@istest
public with sharing class SchCallSentryTest {
    
    @testSetup
    static void addSetupMethod(){

        TelosTouchSF__TT_Log__c log = new TelosTouchSF__TT_Log__c(
            TelosTouchSF__Result__c = 'SUCCESS',
            TelosTouchSF__Comments__c = 'Test'
        );
        insert log;

    }   

    @isTest
    public static void executeTest(){
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        Test.startTest();
        System.schedule('TelosTouch Sentry', '0 0 * * * ?', new SchCallSentry());
        Test.stopTest();
    }

}