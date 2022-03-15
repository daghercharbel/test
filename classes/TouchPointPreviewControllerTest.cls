@isTest
public class TouchPointPreviewControllerTest {
    @isTest
    public static void getIFrameDetailsTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='test382798492878294@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='test382798492878294@gmail.com', TelosTouchSF__Auth_Token__c = '23828962jdkldj');
        System.runAs(u){
            TouchPointPreviewController.getIFrameDetails();
            String returnedValue = TouchPointPreviewController.getListId();
            System.assert(returnedValue!=null);
        }
    }
}