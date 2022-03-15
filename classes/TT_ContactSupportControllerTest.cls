@isTest
public class TT_ContactSupportControllerTest {
    @isTest static void createIssueTest(){
        Test.startTest();
       	String res = TelosTouchSF.TT_ContactSupportController.logIssue('Subject', 'Description');
        Test.stopTest();
        System.assertEquals('success', res);
    }
}