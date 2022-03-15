@isTest 
private with sharing class CreateRemoteSiteSettingTest {
    @isTest 
    static void remoteSiteSettingTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.CreateRemoteSiteSettingMock());
        TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting('https://www.google.co.in', 'google');
        HttpResponse res = 	TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1('https://www.google.co.in', 'google');
        Test.stopTest();
        System.assertEquals(200, res.getStatusCode(), 'res.getStatusCode() should be equal to 200');
    }
}