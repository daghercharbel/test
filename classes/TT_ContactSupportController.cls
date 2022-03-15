/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
public with sharing class TT_ContactSupportController {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param subject ..
* @param description ..
* @return String ......
*/
    @AuraEnabled
    public static String logIssue(String subject, String description) {
            String toemail = System.Label.Request_for_Enterprise_Email;
            if (toemail.length() > 4) {
                List<String> sendTo = new List<String>();
                sendTo.add(toemail);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setSaveAsActivity(false);
                email.setSubject(subject);
                email.setHtmlBody('Org Id : ' + UserInfo.getOrganizationId() + '\n<br/>Company Name : '+ UserInfo.getOrganizationName() + ' \n<br/>Issue Description : ' + description);
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                }
                return 'success';
            }else{
                return 'No Email Found!';
            }
    }
}