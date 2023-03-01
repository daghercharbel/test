public with sharing class SendTestCampaignController {

    private static TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();

    @AuraEnabled
    public static map<String,String> sendTestTemplate(String emails, String campaignId){
        
        map<String, String> mapResult = new map<String, String>();

        try {

            User aUser = [SELECT Id, LanguageLocaleKey, TelosTouchSF__Auth_Token__c 
                          FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            Campaign camp = [SELECT Id, TelosTouchSF__TouchPoint_Template_Id__c 
                             FROM Campaign WHERE Id =: campaignId];

            String body = '{"emails": '+emails+',';
            body += '"template_id": "'+camp.TelosTouchSF__TouchPoint_Template_Id__c+'",';
            body += '"language": "'+aUser.LanguageLocaleKey+'"}';

            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoints/send-test';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            
            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, body);

            if(mapResponse.containsKey('status_code')){
                if(mapResponse.get('status_code') == '200'){
                    mapResult.put('status', 'success');
                } else {
                    mapResult.put('status', 'error');
                    mapResult.put('value', 'Status Code: '+mapResponse.get('status_code'));
                }
                return mapResult;
            } else {
                throw new AuraHandledException('Error');
            }

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'SendTestCampaignController', 'sendTestTemplate', campaignId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

}