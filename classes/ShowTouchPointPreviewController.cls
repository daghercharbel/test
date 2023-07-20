/**
* @author Cloud Analogy
* @date 26/08/2021.
* @description ShowTouchPointPreviewController ....
*/
public with sharing class ShowTouchPointPreviewController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt ADMINCREDENTIALS = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt AUTHENTICATIONCREDENTIALS = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param recordId stores the campaign Id
* @param language   stores the selected language
* @return String ...
*/
    @AuraEnabled
    public static string getIFrameUrls(Id recordId, String language){
        try {

            Campaign campObjUpd;
            String userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
            Campaign campObj = [SELECT Id,TelosTouchSF__TouchPoint_Template_Id__c,TelosTouchSF__Type__c 
                                FROM Campaign WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
            if(campObj.TelosTouchSF__Type__c == null){ campObj.TelosTouchSF__Type__c = 'touchpoint'; }

            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            if(String.isEmpty(campObj.TelosTouchSF__TouchPoint_Template_Id__c)){
                String methodType = 'GET';
                String endPointURL ='';
                Map<String, String> headersMap = new Map<String, String>();
                if(userToken != null && String.isNotBlank(userToken) ){
                    headersMap.put('Authorization','Bearer ' +userToken);
                    headersMap.put('Accept', 'application/json');
                    headersMap.put('Content-Type', 'application/json');
                }
                if(adminCredentials.TelosTouchSF__Instance_URL__c!= null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoint/templates/send/'+campObj.Id;
                } 
                Map<String, String> responseBody = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                if(responseBody != null && responseBody.containsKey('status_code') && responseBody.containsKey('body')){
                    if(responseBody.get('status_code') == '401'){
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(responseBody.get('status_code') == '500'){
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(responseBody.get('status_code').length() > 0){
                            list<String> statusCodeList = responseBody.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBody.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBody.get('status_code'),1));
                            }
                        }
                    }
                    if(responseBody.get('body') != null && responseBody.get('status_code') == '200'){
                        Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
                        if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TouchPoint_Template_Id__c.isUpdateable()){
                            campObj.TelosTouchSF__TouchPoint_Template_Id__c =  String.valueof(responseMap1.get('touchpoint_template_id'));
                        }
                    }
                    campObjUpd = campObj;
                }
            }
            Map<String,String> urlMap = new Map<String, String>();
            String emailUrl = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+campObj.TelosTouchSF__TouchPoint_Template_Id__c;
            emailUrl += (campObj.TelosTouchSF__Type__c != 'touchpoint') ? '/preview/public/email' : '/preview/tp/public/email';
            emailUrl += '?lang='+language+'&custom_messages=%5B%5D&access_token='+userToken;
            urlMap.put('email', emailUrl);
            if(String.isBlank(recordId) || !campObj.TelosTouchSF__Type__c.equalsIgnoreCase('email')){
                Map<String, String> headersMap = new Map<String, String>();
                String endPointURL = '';
                headersMap.put('Authorization','Bearer '+userToken);
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Accept', 'application/json');
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+campObj.TelosTouchSF__TouchPoint_Template_Id__c+'/preview/tp/portalurl?language='+language;
                }
                Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, headersMap, null);
                if(getResponseMap.get('status_code') == '401'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                }else if(getResponseMap.get('status_code') == '500'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                }else{
                    if(getResponseMap.get('status_code').length() > 0){
                        list<String> statusCodeList = getResponseMap.get('status_code').split('0');
                        if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                        }
                    }
                }
                urlMap.put('touchpoint', getResponseMap.get('body'));
            }
            if(campObjUpd != null){
                update campObjUpd;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() ){
                insert createListOfLog;
            }
            return JSON.serialize(urlMap);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage() + ' occurred at line: '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


         /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to generate the iframe url for the preview touchpoint the touchpoint .
* @param templateId stores the campaign Id
* @param campId   stores the selected language
* @param language   stores the selected language
* @return String ...
*/

    @AuraEnabled
    public static string getIFrameUrlsFromTemplateId(String templateId, String campId, String language){
        try {

            Campaign camp = new Campaign();
            if(String.isNotBlank(campId)){ 
                camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: campId LIMIT 1];
                if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
            }

            Map<String,String> urlMap = new Map<String, String>();
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            String emailUrl = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId;
            emailUrl += (camp.TelosTouchSF__Type__c != 'touchpoint') ? '/preview/public/email' : '/preview/tp/public/email';
            emailUrl += '?lang='+language+'&custom_messages=%5B%5D&access_token='+TelosTouchSF.TelosTouchUtility.getCurrentUserToken();
            urlMap.put('email', emailUrl);
            if(String.isBlank(campId) || !camp.TelosTouchSF__Type__c.equalsIgnoreCase('email')){
                Map<String, String> headersMap = new Map<String, String>();
                String endPointURL = '';
                String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
                headersMap.put('Authorization','Bearer '+userAuthTOKEN);
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Accept', 'application/json');
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId+'/preview/tp/portalurl?language='+language;
                }
                Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, headersMap, null);
                if(getResponseMap.get('status_code') == '401'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                }else if(getResponseMap.get('status_code') == '500'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                }else{
                    if(getResponseMap.get('status_code').length() > 0){
                        list<String> statusCodeList = getResponseMap.get('status_code').split('0');
                        if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                        }
                    }
                }
                urlMap.put('touchpoint', getResponseMap.get('body'));
            }
            System.debug(LoggingLevel.DEBUG, urlMap);
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() ){
                insert createListOfLog;
            }
            return JSON.serialize(urlMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}