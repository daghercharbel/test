/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TouchPointPreviewController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @return  Map<String, String> ....
*/
    @AuraEnabled
    public static Map<String, String> getIFrameDetails() {
        try {
            Map<String, String> dataMap = new Map<String, String>();
            if (dataMap.isEmpty()) {
                dataMap.put(
                    'instanceURL',
                    adminCredentials.TelosTouchSF__Instance_URL__c
                );
                datamap.put(
                    'accessToken',
                    TelosTouchSF.TelosTouchUtility.getCurrentUserToken()
                );
            }
            if (dataMap.size() > 0) {
                return dataMap;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'Error is::' +
                e.getMessage() +
                ' at line no::' +
                e.getLineNumber()
            );
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @return String ....
*/
    @AuraEnabled
    public static String getListId() {
        try {
            Map<String, String> returnMap = new Map<String, String>();
            String strCampaign = 'Campaign';
            String strTTCampaigns = 'TT Campaigns';
            returnMap.put('url', URL.getSalesforceBaseUrl().toExternalForm());
            ListView lvObj = [
                SELECT Id, Name
                FROM ListView
                WHERE SobjectType = :strCampaign AND Name = :strTTCampaigns
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            returnMap.put('listId', lvObj.Id);
            return JSON.serialize(returnMap);
        } catch (Exception ex) {
            System.debug(
                LoggingLevel.ERROR,
                'Exception: ' +
                ex.getMessage() +
                ' Occurred at Line No.: ' +
                ex.getLineNumber()
            );
            return null;
        }
    }
    
    @AuraEnabled
    public static String getTemplateDetails() {
        String methodType = 'GET';
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        String endPointURL;
        String userAuthTOKEN;
        Map<String, String> headersMap = new Map<String, String>();
        List<Object> templateObjects = new List<Object>();
        userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        headersMap.put('Authorization', 'Bearer ' + userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
            endPointURL =
                adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/templates';
        }
        Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(
            methodType,
            endPointURL,
            headersMap,
            null
        );
        if (getResponseMap.get('status_code') == '200') {
            String resbody = getResponseMap.get('body');
            List<Object> templateList = new List<Object>();
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
                    String.valueOf(templateMap.get('modified_at')) +
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
        } else if (getResponseMap.get('status_code') == '401') {
            createListOfLog.add(
                TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord(
                    'Failure',
                    'User Could Not be Authenticated',
                    'L\'usager n\'a pu être identifié',
                    1
                )
            );
        } else if (getResponseMap.get('status_code') == '500') {
            createListOfLog.add(
                TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord(
                    'Failure',
                    'Internal Server Error',
                    'Erreur de serveur interne',
                    1
                )
            );
        } else {
            if (getResponseMap.get('status_code').length() > 0) {
                list<String> StatusCodeList = getResponseMap.get('status_code')
                    .split('0');
                if (StatusCodeList[0] == '4' || StatusCodeList[0] == '5') {
                    createListOfLog.add(
                        TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord(
                            'Failure',
                            'Something went wrong. Status Code: ' +
                            getResponseMap.get('status_code'),
                            'Quelque chose s\'est mal passé  Code d\'état :' +
                            getResponseMap.get('status_code'),
                            1
                        )
                    );
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
        if (templateObjects.size() > 0) {
            return JSON.serialize(templateObjects);
        }
        return null;
    }

    @AuraEnabled
    public static map<String, String> getNewTemplateBuilder() {

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

            String requestBody = '{ "content":{ "name":"new template", "name_fr":"nouveau modèle", "description":"description", "description_fr":null, "image_id":null, "introduction":"Please take a moment to complete \'new template\'", "introduction_fr":"Veuillez prendre un moment pour compléter \'nouveau modèle\'", "nodes":[ { "id":"start-node", "type":"essentials", "position":{ "x":100, "y":100 }, "data":{ "type":"start" } }, { "id":"end-node", "type":"end", "position":{ "x":100, "y":400 }, "data":{ "type":"end" } } ], "edges":[ ] } }';

            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('POST', endPointURL, mapHeader, null);

            if(mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                String responseBody = mapResponse.get('body');
                String templateId = responseBody.substringBetween('"id": "', '",');
                String iframeUrl = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/app/v1/#/touchpoint/'+templateId+'/customize?fullscreen=true&access_token='+aUser.TelosTouchSF__Auth_Token__c+'&lang=en_US';
                mapResult.put('value', iframeUrl);
                return mapResult;
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

        } catch (Exception ex) {

            TelosTouchUtility.generateErrorLog(ex, 'TouchPointPreviewController', 'createNewTemplate', userId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }

    }
    
}