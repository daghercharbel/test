@isTest
public class TemplateGalleryCompHandlerTest {
    @isTest static void getTemplatesTest(){
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.TelosTouchUtilityMock());        
        Test.startTest();
        String res = TemplateGalleryCompHandler.getTouchPointTemplates();
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