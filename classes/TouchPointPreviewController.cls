/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TouchPointPreviewController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();

    @AuraEnabled
    public static map<String, String> copyTemplate(String templateId){
        
        map<String, String> mapResult = new map<String, String>();

        try {
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/'+templateId+'/copy';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, null);

            if(mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                return mapResult;
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }
        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'updateTemplatePermission', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;

        }
    }

    @AuraEnabled
    public static map<String, String> createTemplate() {

        map<String, String> mapResult = new map<String, String>();
        Id userId;
        try {
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            userId = aUser.Id;
            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('POST', endPointURL, mapHeader, null);

            if(mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                String responseBody = mapResponse.get('body');
                map<String,Object> mapResponseBody = (map<String,Object>)JSON.deserializeUntyped(responseBody);
                String templateId = (String)mapResponseBody.get('id');
                String iframeUrl = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/app/v1/#/experience-panel-sf/touchpoint/'+templateId+'?fullscreen=true&access_token='+aUser.TelosTouchSF__Auth_Token__c+'&lang=en_US';
                mapResult.put('value', iframeUrl);
                return mapResult;
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'createNewTemplate', userId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String, String> deleteTemplate(String templateId){
        
        map<String, String> mapResult = new map<String, String>();

        try {
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/'+templateId;

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('DELETE', endPointURL, mapHeader, null);

            if(mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                return mapResult;
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }
        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'updateTemplatePermission', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;

        }
    }

    @AuraEnabled
    public static map<String, String> editTemplate(String templateId){

        map<String, String> mapResult = new map<String, String>();
        try {
            
            if(String.isBlank(templateId)){ throw new AuraHandledException('TemplateId Empty'); }

            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            String iframeUrl = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/app/v1/#/experience-panel-sf/touchpoint/'+templateId+'?fullscreen=true&access_token='+aUser.TelosTouchSF__Auth_Token__c+'&lang=en_US';

            mapResult.put('status', 'success');
            mapResult.put('value', iframeUrl);

            return mapResult;

        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'editTemplate', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String, String> getIFrameDetails() {
        try {
            Map<String, String> dataMap = new Map<String, String>();
            if (dataMap.isEmpty()) {
                dataMap.put('instanceURL', adminCredentials.TelosTouchSF__Instance_URL__c
                );
                datamap.put('accessToken',TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
            }
            if (dataMap.size() > 0) {
                return dataMap;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error is::'+e.getMessage()+' at line no::'+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static map<String,String> getSharableUsers(){
        map<String, String> mapResult = new map<String, String>();
        try {

            list<User> lstUser = [SELECT Id, Name, TelosTouchSF__TT_UserId__c
                                  FROM User WHERE TelosTouchSF__TT_UserId__c != null AND Id !=: UserInfo.getUserId()];
            mapResult.put('status', 'success');
            mapResult.put('value', JSON.serialize(lstUser));
            return mapResult; 

        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'getSharableUsers', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;

        }
    }
    
    @AuraEnabled
    public static String getSystemInfo() {
        try {
            Map<String, Object> returnMap = new Map<String, Object>();
            String strCampaign = 'Campaign';
            String strTTCampaigns = 'TT Campaigns';
            //System.Label.System_Administrator
            ListView lvObj = [SELECT Id, Name FROM ListView WHERE SobjectType =: strCampaign AND Name =: strTTCampaigns
                              WITH SECURITY_ENFORCED LIMIT 1];
            User aUser = [SELECT Id, Profile.name FROM User WHERE id =: UserInfo.getUserId()];
            returnMap.put('isAdmin', aUser.Profile.Name == System.Label.System_Administrator);
            returnMap.put('listViewId', lvObj.Id);
            return JSON.serialize(returnMap);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception: '+ex.getMessage()+' Occurred at Line No.: '+ex.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static String getTemplateDetails() {
        String methodType = 'GET';
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        User aUser = [SELECT LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
        String endpointPrivate;
        String endpointShared;
        String endpointPublic;
        String userAuthTOKEN;
        Map<String, String> headersMap = new Map<String, String>();
        map<String, List<Object>> mapTemplates = new map<String, List<Object>>();
        userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        headersMap.put('Authorization', 'Bearer ' + userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');

        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
            string aEndpoint = '/api/v1/touchpoint/templateGraph?language='+aUser.LanguageLocaleKey+'&sort=%7B%22updated_at%22:+%22DESC%22%7D';
            endpointPrivate = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=true&is_shared=false';
            endpointShared = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=true&is_shared=true';
            endpointPublic = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=false&is_shared=false';
        }
        
        map<String, Map<String, String>> mapResponses = new map<String, Map<String, String>>();
        mapResponses.put('private', TelosTouchUtility.getResponse(methodType, endpointPrivate, headersMap, null));
        mapResponses.put('shared', TelosTouchUtility.getResponse(methodType, endpointShared, headersMap, null));
        mapResponses.put('public', TelosTouchUtility.getResponse(methodType, endpointPublic, headersMap, null));


        for (String key : mapResponses.keySet()) {
            
            map<String, String> getResponseMap = mapResponses.get(key);

            if (getResponseMap.get('status_code') == '200') {
                String resbody = getResponseMap.get('body');
                List<Object> templateList = new List<Object>();
                List<Object> templateObjects = new List<Object>();
                templateList = (List<Object>) JSON.deserializeUntyped(resbody);
                for (Object tempObj : templateList) {
                    Map<String, Object> templateMap = (Map<String, Object>) tempObj;
                    templateMap.put(
                        'imageURL',
                        (Object) (adminCredentials.TelosTouchSF__Instance_URL__c +
                                  '/api/v1/attachments/' +
                                  templateMap.get('image_id'))
                    );
                    JSONParser parser = JSON.createParser(
                        '{"t":"' +
                        String.valueOf(templateMap.get('updated_at')) +
                        '"}'
                    );
                    parser.nextToken();
                    parser.nextValue();
                    DateTime dt = DateTime.newInstance(parser.getDateTimeValue().getTime());
                    templateMap.put(
                        'modified_at',
                        (Object) (String.valueOf(dt.format('MMM dd, yyyy hh:mm a')))
                    );
                    templateObjects.add((Object) templateMap);
                }
                mapTemplates.put(key, templateObjects);
            } else if (getResponseMap.get('status_code') == '401') {
                createListOfLog.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
            } else if (getResponseMap.get('status_code') == '500') {
                createListOfLog.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error','Erreur de serveur interne',1));
            } else {
                if (getResponseMap.get('status_code').length() > 0) {
                    list<String> StatusCodeList = getResponseMap.get('status_code').split('0');
                    if (StatusCodeList[0] == '4' || StatusCodeList[0] == '5') {
                        createListOfLog.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                    }
                }
            }
        }
        if (
            createListOfLog.size() > 0 &&
            Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() &&
            Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()
        ) {
            insert createListOfLog;
        }
        if (mapTemplates.size() > 0) {
            
            return JSON.serialize(mapTemplates);
        }
        return null;
    }

    @AuraEnabled
    public static map<String,String> updateTemplatePermission(String templateId, String requestBody){

        map<String, String> mapResult = new map<String, String>();

        try {
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/'+templateId+'/permissions';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, requestBody);

            if(mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                return mapResult;
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }
        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TouchPointPreviewController', 'updateTemplatePermission', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;

        }
    }

    @AuraEnabled
    public static Boolean checkIfUserHaveCreationAcess(){
        try {
            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/users?search='+[SELECT Email FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1].Email;
            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('GET',endPointURL,mapHeader,null);
            List<Object> ttUserList = (List<Object>) JSON.deserializeUntyped(getResponseMap.get('body'));
            Map<String, Object> ttUserObj = (Map<String, Object>) ttUserList[0];
            if(ttUserObj.containsKey('role') && ((ttUserObj.get('role') == 'administrator') || (ttUserObj.get('role') == 'builder'))){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}