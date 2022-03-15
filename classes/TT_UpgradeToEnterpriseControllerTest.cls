@istest
public class TT_UpgradeToEnterpriseControllerTest {
    @istest static void sendEmailTest(){
        String response = TelosTouchSF.TT_UpgradeToEnterpriseController.sendEmail(' A new request has been submitted to upgrade to the Enterprise version');
        System.assertEquals('success', response);
    }
}