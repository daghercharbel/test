/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TT_UpgradeToEnterpriseController {
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description sendEmail ..
* @param  description ..
* @return  string ..
*/
    @AuraEnabled
    public static String sendEmail(String description) {
        String toemail = System.Label.Request_for_Enterprise_Email;
        String subject = 'Request for upgrade to Enterprise';
        if (!String.isEmpty(toemail)) {
            List<String> sendTo = new List<String>();
            sendTo.add(toemail);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHtmlBody('Hi there, <br/><br/> A new request has been submitted to upgrade to the Enterprise version by: <br/><br/><b>Email</b> : ' + UserInfo.getUserEmail() + '<br/><br/><b>Org Id</b> : ' + UserInfo.getOrganizationId() + '<br/><br/><b>Company Name</b> : '+ UserInfo.getOrganizationName() + '<br/><br/><b>Description</b> : '+description+'<br/><br/>'+'Thanks!');
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            return 'success';
        }else{
            return 'No Email Found!';
        }
    }
}