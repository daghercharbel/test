@isTest
public class TemplateGalleryCompHandlerTest {

    @TestSetup
    static void setup(){

        Campaign CampaignObj = new Campaign(
            Name = 'TemplateGalleryCompHandlerTest',
            IsActive = false,
            TelosTouchSF__Type__c = 'touchpoint',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;

    }
    @isTest static void getTemplatesTest(){
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TemplateGalleryCompHandlerTest'];   
        Test.startTest();
        String res = TemplateGalleryCompHandler.getTouchPointTemplates(campTest.Id, 'touchpoint');
        String res1 = TemplateGalleryCompHandler.getTouchPointTemplatesAdmin(campTest.Id);
        Map<String, String> resp = TemplateGalleryCompHandler.getIFrameDetails();
        System.assert(res != null);
        System.assert(resp != null);
        Test.stopTest();
    }
    @isTest static void saveTemplateTest(){
        String templateId = '2894741';
        Campaign cmpObj = new Campaign();
        cmpObj.Name = 'test';
        insert cmpObj;
        Test.startTest();
        map<String,String> mapResult = TemplateGalleryCompHandler.SaveTouchPointTemplate(cmpObj.Id, templateId, 'touchpoint', null);
        map<String,String> mapResult2 = TemplateGalleryCompHandler.SaveTouchPointTemplate(cmpObj.Id, templateId, 'email', 'en_US');
        System.assert(mapResult != null, 'mapResult should not be null');
        Test.stopTest();
    }
    @isTest static void previewURL(){
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        String templateId = '6843931';
        String language = 'en_US';
        Campaign campTest = [SELECT Id FROM Campaign WHERE Name = 'TemplateGalleryCompHandlerTest'];
        Test.startTest();
        String resp = TemplateGalleryCompHandler.generatePreviewIFrameUrl(templateId, language, campTest.Id);
        System.assert(resp != null);
        Test.stopTest();
    }
}