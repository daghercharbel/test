public with sharing class ShowTouchPointPreviewController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt ADMINCREDENTIALS = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt AUTHENTICATIONCREDENTIALS = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();

    @AuraEnabled
    public static string getIFrameUrls(Id recordId, String language){
        try {
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Campaign campObj = [SELECT Id, TelosTouchSF__TouchPoint_Template_Id__c FROM Campaign WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
            if(String.isEmpty(campObj.TelosTouchSF__TouchPoint_Template_Id__c)){
                String methodType = 'GET';
                String endPointURL ='', userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
                Map<String, String> headersMap = new Map<String, String>();
                if(userToken != null && String.isNotBlank(userToken) ){
                    headersMap.put('Authorization','Bearer ' +userToken);
                    //headersMap.put('espo-Authorization', adminCredentials.Access_Token__c);
                        headersMap.put('Accept', 'application/json');
                        headersMap.put('Content-Type', 'application/json');
                }
                if(adminCredentials.TelosTouchSF__Instance_URL__c!= null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoint/templates/send/'+campObj.Id;
                } 
                Map<String, String> responseBody = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
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
                if(responseBody.get('body') != null){
                    Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
                    if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TouchPoint_Template_Id__c.isUpdateable()){
                        campObj.TelosTouchSF__TouchPoint_Template_Id__c =  String.valueof(responseMap1.get('touchpoint_template_id'));
                    }
                }
            }
            Map<String,String> urlMap = new Map<String, String>();
            urlMap.put('email', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+campObj.TelosTouchSF__TouchPoint_Template_Id__c+'/preview/public/email?lang='+language+'&custom_messages=%5B%5D&access_token='+TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
            Map<String, String> headersMap = new Map<String, String>();
            String endPointURL = '';
            String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
            headersMap.put('Authorization','Bearer '+userAuthTOKEN);
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+campObj.TelosTouchSF__TouchPoint_Template_Id__c+'/preview/portalurl?language='+language;
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
            System.debug(LoggingLevel.DEBUG, urlMap);
            if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable()){
                UPDATE campObj;
            }
            return JSON.serialize(urlMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getIFrameUrlsFromTemplateId(String templateId, String language){
        try {
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Map<String,String> urlMap = new Map<String, String>();
            urlMap.put('email', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId+'/preview/public/email?lang='+language+'&custom_messages=%5B%5D&access_token='+TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
            Map<String, String> headersMap = new Map<String, String>();
            String endPointURL = '';
            String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
            headersMap.put('Authorization','Bearer '+userAuthTOKEN);
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId+'/preview/portalurl?language='+language;
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