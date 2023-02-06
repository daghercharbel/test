@isTest
public with sharing class ShowTouchPointPreviewControllerTest {
    
    @TestSetup
    static void testSetup(){
        Campaign camp1Test = new Campaign();
        camp1Test.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
        camp1Test.Name = 'ShowTouchPointPreviewControllerTest';
        camp1Test.TelosTouchSF__Type__c = 'touchpoint';

        insert camp1Test;
    }
    
    @isTest
    static void getIFrameUrlsTest(){

        List<Campaign> lstCamp = [SELECT Id FROM Campaign WHERE Name = 'ShowTouchPointPreviewControllerTest'];
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());

        Test.startTest();

        String url = ShowTouchPointPreviewController.getIFrameUrls(lstCamp[0].Id, 'en');

        Test.stopTest();
		
        System.assert(String.isNotBlank(url), 'URL should not be blank');
    }
    
    @isTest
    static void getIFrameUrlsFromTemplateIdTest(){

        List<Campaign> lstCamp = [SELECT Id FROM Campaign WHERE Name LIKE 'ShowTouchPointPreviewControllerTest%'];
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());

        Test.startTest();

        String url = ShowTouchPointPreviewController.getIFrameUrlsFromTemplateId('test', lstCamp[0].Id, 'en');

        Test.stopTest();
		
        System.assert(String.isNotBlank(url), 'URL should not be blank');
    }

}