@isTest
public class TouchPointPreviewControllerTest {
    
    @isTest
    public static void getIFrameDetailsTest() {
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
        System.runAs(u) {
            TouchPointPreviewController.getIFrameDetails();
            String returnedValue = TouchPointPreviewController.getListId();
            System.assert(returnedValue != null);
        }
    }

    @isTest
    public static void getTemplateDetailsTest() {
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        Test.startTest();
        String wp = TouchPointPreviewController.getTemplateDetails();
        Test.stopTest();
        System.assert(wp != null, 'wp must not be NULL');
    }

    @isTest
    public static void getNewTemplateBuilderTest() {
        Test.setMock(HttpCalloutMock.class, new TelosTouchUtilityMock());
        Test.startTest();
        map<String,String> mapResponse = TouchPointPreviewController.getNewTemplateBuilder();
        Test.setMock(HttpCalloutMock.class, new MockResponse_Test());
        map<String,String> mapResponse2 = TouchPointPreviewController.getNewTemplateBuilder();
        Test.stopTest();
        System.assert(mapResponse.get('status') == 'success', 'response must be successful');
        System.assert(mapResponse2.get('status') == 'error', 'response must be error');
    }

}