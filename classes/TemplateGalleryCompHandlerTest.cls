@isTest
public class TemplateGalleryCompHandlerTest {
    @isTest static void getTemplatesTest(){

        Campaign CampaignObj = new Campaign(
            Name = 'TemplateGalleryCompHandlerTest',
            IsActive = false,
            TelosTouchSF__Type__c = 'touchpoint',
            Questions__c = '[{"answers":["Yes","Not at this time thanks"],"type":"button","key":"5e947ef1574573795fa7fa6d","question":"Would you like us to reach out to you to discuss?"},{"answers":["Call Me","Video Chat","In Person Meeting"],"type":"button","key":"5e947ef1574573795fa7fa6e","question":"How would you like us to reach out to discuss?"}]\n'
        );
        insert CampaignObj;
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());        
        Test.startTest();
        String res = TemplateGalleryCompHandler.getTouchPointTemplates(CampaignObj.Id);
        String res1 = TemplateGalleryCompHandler.getTouchPointTemplatesAdmin(CampaignObj.Id);
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
        Boolean response = TemplateGalleryCompHandler.SaveTouchPointTemplate(cmpObj.Id, templateId);
        System.assert(response);
        Test.stopTest();
    }
    @isTest static void previewURL(){
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());
        String templateId = '6843931';
        String language = 'en_US';        
        Test.startTest();
        String resp = TemplateGalleryCompHandler.generatePreviewIFrameUrl(templateId, language);
        System.assert(resp != null);
        Test.stopTest();
    }
}