@isTest
public class TouchPointPreviewControllerTest {

    @isTest
    public static void copyTemplateTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String, String> mapResponse = TouchPointPreviewController.copyTemplate('testId', 'testId', 'Email');
        map<String, String> mapResponse2 = TouchPointPreviewController.copyTemplate('testId', 'testId', 'TouchPoint');
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        map<String, String> mapResponse3 = TouchPointPreviewController.copyTemplate('testId', 'testId', 'Email');
        map<String, String> mapResponse4 = TouchPointPreviewController.copyTemplate('testId', 'testId', 'TouchPoint');
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
    }

    @isTest
    public static void createTemplateTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String,String> mapResponse = TouchPointPreviewController.createTemplate('Email', 'en_US', 'Test', 'Test');
        map<String,String> mapResponse2 = TouchPointPreviewController.createTemplate('TouchPoint', 'en_US', 'Test', 'Test');
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        map<String,String> mapResponse3 = TouchPointPreviewController.createTemplate('Email', 'en_US', 'Test', 'Test');
        map<String,String> mapResponse4 = TouchPointPreviewController.createTemplate('TouchPoint', 'en_US', 'Test', 'Test');
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
        System.assert(mapResponse3.get('status') == 'error', 'response must be error');
    }

    @isTest
    public static void deleteTemplateTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String, String> mapResponse = TouchPointPreviewController.deleteTemplate('testId', 'testId', 'Email');
        map<String, String> mapResponse3 = TouchPointPreviewController.deleteTemplate('testId', 'testId', 'TouchPoint');
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        map<String, String> mapResponse2 = TouchPointPreviewController.deleteTemplate('testId', 'testId', 'Email');
        map<String, String> mapResponse4 = TouchPointPreviewController.deleteTemplate('testId', 'testId', 'TouchPoint');
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
    }

    @isTest
    public static void editTemplateTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String, String> mapResponse = TouchPointPreviewController.editTemplate('testId', 'testId', 'Email');
        map<String, String> mapResponse2 = TouchPointPreviewController.editTemplate(null, 'testId', 'Email');
        map<String, String> mapResponse3 = TouchPointPreviewController.editTemplate('testId', 'testId', 'TouchPoint');
        map<String, String> mapResponse4 = TouchPointPreviewController.editTemplate(null, 'testId', 'Touchpoint');        
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
        System.assert(mapResponse2.get('status') == 'error', 'response must be error');
    }

    @isTest
    public static void getIFrameDetailsTest() {
        Test.startTest();
        TouchPointPreviewController.getIFrameDetails();
        Test.stopTest();
    }

    @isTest
    public static void getSharableUsersTest() {
        Test.startTest();
        map<String, String> mapResponse = TouchPointPreviewController.getSharableUsers();
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
    }
    
    @isTest
    public static void getSystemInfoTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(
            Alias = 'standt',
            Email = 'test382798492878294@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test382798492878294@gmail.com',
            TelosTouchSF__Auth_Token__c = '23828962jdkldj'
        );
        Test.startTest();
        System.runAs(u) {
            String returnedValue = TouchPointPreviewController.getSystemInfo();
            System.assert(returnedValue != null);
        }
        Test.stopTest();
    }

    @isTest
    public static void getTemplateDetailsTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        String wp = TouchPointPreviewController.getTemplateDetails('Email');
        String wp2 = TouchPointPreviewController.getTemplateDetails('TouchPoint');
        Test.stopTest();
        System.assert(wp != null, 'wp must not be NULL');
    }

    @isTest
    public static void updateTemplatePermissionTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String, String> mapResponse = TouchPointPreviewController.updateTemplatePermission('testId', 'requestTest', 'testId', 'Email');
        map<String, String> mapResponse3 = TouchPointPreviewController.updateTemplatePermission('testId', 'requestTest', 'testId', 'TouchPoint');
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        map<String, String> mapResponse2 = TouchPointPreviewController.updateTemplatePermission(null, null, 'testId', 'Email');
        map<String, String> mapResponse4 = TouchPointPreviewController.updateTemplatePermission(null, null, 'testId', 'TouchPoint');
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be success');
    }

}