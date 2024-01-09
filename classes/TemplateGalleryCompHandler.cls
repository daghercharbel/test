/**
* @author Cloud Analogy
* @date 02/08/2021
* @description used for all the template gallery component
*/

public with sharing class TemplateGalleryCompHandler {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();

    public static String getTemplateIdByGraphId(String templatGraphId){

        String result;

        try {

            String userAuthTOKEN = TelosTouchUtility.getCurrentuserTOKEN();

            String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoint/touchpointTemplateByGraph/'+templatGraphId;
            
            map<String, String> mapHeader = new map<String, String>();
            mapHeader.put('Authorization', 'Bearer ' + userAuthTOKEN);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            map<String, String> mapResponse = TelosTouchUtility.getResponse('GET',endpoint,mapHeader,null);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');	
            //TelosTouchUtility.generateLog(respMessage, 'SaveTouchPointTemplate', 'getTemplateIdByGraphId', null);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){
                map<String,Object> mapTemplate = (Map<String,Object>)JSON.deserializeUntyped(mapResponse.get('body'));
                if(mapTemplate.containsKey('id')){ result = String.valueOf(mapTemplate.get('id')); }
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

            return result;
        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TemplateGalleryCompHandler', 'getTemplateIdByGraphId', null);
            return null;
        }

    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetching all the touchpoints
* @param campId ...
* @return String ...
*/
    @AuraEnabled
    public static String getTouchPointTemplatesAdmin(String campId) {

        String conditions = '';

        if(String.isNotBlank(campId)){
            Campaign camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: campId WITH SECURITY_ENFORCED];
            if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
            conditions = '?type='+camp.TelosTouchSF__Type__c;
        }

        String methodType = 'GET';
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        String endPointURL;
        String userAuthTOKEN;
        Map<String, String> headersMap = new Map<String, String>();
        List<Object> templateObjects = new List<Object>();
        headersMap.put('Authorization', 'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
            endPointURL =
                adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/templates'+conditions;
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
                    (Object) ('background-image: url(' +
                              adminCredentials.TelosTouchSF__Instance_URL__c +
                              '/api/v1/attachments/' +
                              templateMap.get('image_id') +
                              ')')
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
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
        } else if (getResponseMap.get('status_code') == '500') {
            createListOfLog.add(
                TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error','Erreur de serveur interne',1));
        } else {
            if (getResponseMap.get('status_code').length() > 0) {
                list<String> StatusCodeList = getResponseMap.get('status_code').split('0');
                if (StatusCodeList[0] == '4' || StatusCodeList[0] == '5') {
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure', 'Something went wrong. Status Code: ' +getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :' +getResponseMap.get('status_code'),1));
                }
            }
        }
        if (createListOfLog.size() > 0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()) {
            insert createListOfLog;
        }
        if (templateObjects.size() > 0) {
            return JSON.serialize(templateObjects);
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetching all the touchpoints
* @param campId ...
* @return String ...
*/
    @AuraEnabled
    public static String getTouchPointTemplates(String campId, String campaignType) {

        String conditions = '';

        Campaign camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: campId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(campId) && String.isBlank(campaignType)){
            if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
            campaignType = camp.TelosTouchSF__Type__c;
        }
        conditions += 'type='+campaignType+'&sort=[{"modified_at":"DESC"},{"id":"DESC"}]';

        String methodType = 'GET';
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        User aUser = [SELECT LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
        String endpointPrivate;
        String endpointShared;
        String endpointPublic;
        String userAuthTOKEN;
        map<String, Map<String, String>> mapResponses = new map<String, Map<String, String>>();
        map<String, List<Object>> mapTemplates = new map<String, List<Object>>();
        userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
        Map<String, String> headersMap = new Map<String, String>();

        headersMap.put('Authorization', 'Bearer ' + userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();

        if(campaignType == 'touchpoint'){

            if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
                string aEndpoint = '/api/v1/touchpoint/templateGraph?language='+aUser.LanguageLocaleKey+'&sort=%7B%22updated_at%22:+%22DESC%22%7D';
                endpointPrivate = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=true&is_shared=false';
                endpointShared = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=true&is_shared=true';
                endpointPublic = adminCredentials.TelosTouchSF__Instance_URL__c+aEndpoint+'&is_private=false&is_shared=false';
            }
            mapResponses.put('private', TelosTouchUtility.getResponse(methodType, endpointPrivate, headersMap, null));
            mapResponses.put('shared', TelosTouchUtility.getResponse(methodType, endpointShared, headersMap, null));
            mapResponses.put('public', TelosTouchUtility.getResponse(methodType, endpointPublic, headersMap, null));

        } else {
            if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
                Boolean tpReady = (camp.TelosTouchSF__Type__c == 'touchpoint');
                String url = adminCredentials.TelosTouchSF__Instance_URL__c
                +'/api/v1/templates?type=email&sort=[{"modified_at":"DESC"},{"id":"DESC"}]&is_tp_ready='+tpReady;
                endpointPrivate = url+'&is_private=true&is_shared=false';
                endpointShared = url+'&is_private=true&is_shared=true';
                endpointPublic = url+'&is_private=false&is_shared=false';
            }
            mapResponses.put('private', TelosTouchUtility.getResponse(methodType, endpointPrivate, headersMap, null));
            mapResponses.put('shared', TelosTouchUtility.getResponse(methodType, endpointShared, headersMap, null));
            mapResponses.put('public', TelosTouchUtility.getResponse(methodType, endpointPublic, headersMap, null));
        }

        for (String key : mapResponses.keySet()) {
            
            map<String, String> getResponseMap = mapResponses.get(key);

            if (getResponseMap.get('status_code') == '200') {
                String resbody = getResponseMap.get('body');
                List<Object> templateList = new List<Object>();
                List<Object> templateObjects = new List<Object>();
                templateList = (List<Object>) JSON.deserializeUntyped(resbody);
                for (Object tempObj : templateList) {

                    Map<String, Object> templateMap = (Map<String, Object>) tempObj;
                    if(String.valueOf(templateMap.get('status')) == 'DRAFTED') { continue; }
                    else if(String.valueOf(templateMap.get('status')) == 'SENT' && key == 'public') { continue; }

                    Object imageId = (campaignType == 'email') ? '{image_id}' : templateMap.get('image_id');

                    templateMap.put(
                        'imageURL',
                        (Object) ('background-image: url(' +
                                  adminCredentials.TelosTouchSF__Instance_URL__c +
                                  '/api/v1/attachments/' +
                                  imageId +
                                  ')')
                    );
                    String dtField;
                    if(templateMap.containsKey('updated_at')){
                        dtField = String.valueOf(templateMap.get('updated_at'));
                    } else if(templateMap.containsKey('modified_at')){
                        dtField = String.valueOf(templateMap.get('modified_at'));
                    }
                    JSONParser parser = JSON.createParser('{"t":"'+dtField+'"}');
                    parser.nextToken();
                    parser.nextValue();
                    DateTime dt = DateTime.newInstance(parser.getDateTimeValue().getTime());
                    templateMap.put(
                        'modified_at',
                        (Object) (String.valueOf(dt.format('MMM dd, yyyy hh:mm a')))
                    );
                    templateMap.put('modifiedAt', (Object) templateMap.get('modified_at'));
                    templateMap.put('Description', (Object) templateMap.get('description'));
                    templateObjects.add((Object) templateMap);
                }
                mapTemplates.put(key, templateObjects);
            } else if (getResponseMap.get('status_code') == '401') {
                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
            } else if (getResponseMap.get('status_code') == '500') {
                createListOfLog.add(
                    TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error','Erreur de serveur interne',1));
            } else {
                if (getResponseMap.get('status_code').length() > 0) {
                    list<String> StatusCodeList = getResponseMap.get('status_code').split('0');
                    if (StatusCodeList[0] == '4' || StatusCodeList[0] == '5') {
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure', 'Something went wrong. Status Code: ' +getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :' +getResponseMap.get('status_code'),1));
                    }
                }
            }
        }

        if (createListOfLog.size() > 0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()) {
            insert createListOfLog;
        }
        if (mapTemplates.size() > 0) {
            return JSON.serialize(mapTemplates);
        }
        return null;
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to generate the Iframe url
* @return Map<String, String> ...
*/
    
    @AuraEnabled
    public static Map<String, String> getIFrameDetails() {
        try {
            Map<String, String> dataMap = new Map<String, String>();
            if (dataMap.isEmpty()) {
                dataMap.put('instanceURL', adminCredentials.TelosTouchSF__Instance_URL__c);
                datamap.put('accessToken',TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
            }
            if (dataMap.size() > 0) {
                return dataMap;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Error is::' + e.getMessage() + ' at line no::' + e.getLineNumber());
            return null;
        }
    }
    
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param campaignRecordId stores the campaign Id
* @param touchPointTemplateId   stores the touchpoint template id
* @return Boolean ....
*/
    
    @AuraEnabled
    public static map<String,String> SaveTouchPointTemplate(Id campId,String templateGraphId, String templateType, String lang){

        map<String, String> mapResult = new map<String, String>();
        
        if(templateType == 'touchpoint'){
            mapResult = sendTouchpointTemplate(campId, templateGraphId);
        } else {
            mapResult = sendEmailTemplate(campId, templateGraphId, lang);
        }

        return mapResult;
        
    }

    public static map<String,String> sendEmailTemplate(Id campId, String templateId, String lang){

        map<String, String> mapResult = new map<String, String>();

        try {

            Campaign camp = [SELECT Id,TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Email_Template_Id__c
                             FROM Campaign WHERE Id =: campId WITH SECURITY_ENFORCED];

            map<String,Object> mapEmailTemplates = new map<String,Object>();
            if(String.isNotBlank(camp.TelosTouchSF__Email_Template_Id__c)){
                mapEmailTemplates = (map<String,Object>)JSON.deserializeUntyped(camp.TelosTouchSF__Email_Template_Id__c);
            }
            
            String methodType = (mapEmailTemplates.containsKey(lang)) ? 'PUT' : 'POST';

            String userAuthTOKEN = TelosTouchUtility.getCurrentuserTOKEN();

            String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c;
            endpoint += (mapEmailTemplates.containsKey(lang)) ? '/api/v2/campaign2/update/touchpoint-email' : '/api/v2/campaign2/link/touchpoint-email';
            
            map<String, String> mapHeader = new map<String, String>();
            mapHeader.put('Authorization', 'Bearer ' + userAuthTOKEN);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            String body = '{"email_id": "'+templateId+'",'
            +'"touchpoint_send_id": "'+camp.TelosTouchSF__TT_Campaign_Id__c+'",'
            +'"language": "'+lang+'"}';

            map<String, String> mapResponse = TelosTouchUtility.getResponse(methodType,endpoint,mapHeader,body);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');	
            TelosTouchUtility.generateLog(respMessage, 'TemplateGalleryCompHandler', 'sendEmailTemplate', camp.Id);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){

                mapEmailTemplates.put(lang, templateId);
                if(Schema.sObjectType.Campaign.fields.TelosTouchSF__Email_Template_Id__c.isUpdateable() &&
                Schema.sObjectType.Campaign.isUpdateable()){
                    camp.TelosTouchSF__Email_Template_Id__c = JSON.serialize(mapEmailTemplates);
                    update camp;
                }
                

            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

            mapResult.put('status', 'success');

            return mapResult;
        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TemplateGalleryCompHandler', 'sendEmailTemplate', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    public static map<String,String> sendTouchpointTemplate(Id campId, String templateGraphId){
        map<String, String> mapResult = new map<String, String>();

        try {

            Campaign camp = [SELECT Id, TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id =: campId WITH SECURITY_ENFORCED];

            String userAuthTOKEN = TelosTouchUtility.getCurrentuserTOKEN();

            String templateId = getTemplateIdByGraphId(templateGraphId);

            String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v2/campaign2/update';
            
            map<String, String> mapHeader = new map<String, String>();
            mapHeader.put('Authorization', 'Bearer ' + userAuthTOKEN);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            String body = '{"id": "'+camp.TelosTouchSF__TT_Campaign_Id__c+'",'
            +'"touchpoint": {'
            +'"id": "'+templateId+'"}}';

            map<String, String> mapResponse = TelosTouchUtility.getResponse('PUT',endpoint,mapHeader,body);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');	
            TelosTouchUtility.generateLog(respMessage, 'TemplateGalleryCompHandler', 'sendTouchpointTemplate', camp.Id);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){

                map<String, Object> mapBody = (map<String, Object>)JSON.deserializeUntyped(mapResponse.get('body'));
                list<Object> lstEmails = (list<Object>)mapBody.get('emails');

                map<String,Object> mapEmailTemplates = new map<String,Object>();
                for(Object obj : lstEmails){
                    map<String, Object> mapFields = (map<String, Object>)obj;
                    mapEmailTemplates.put((String)mapFields.get('language'), mapFields.get('id'));
                }

                if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TouchPoint_Template_Id__c.isUpdateable() &&
                Schema.sObjectType.Campaign.fields.TelosTouchSF__Email_Template_Id__c.isUpdateable() &&
                Schema.sObjectType.Campaign.isUpdateable()){
                    camp.TelosTouchSF__TouchPoint_Template_Id__c = templateGraphId;
                    camp.TelosTouchSF__Email_Template_Id__c = JSON.serialize(mapEmailTemplates);
                    update camp;
                }

            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

            mapResult.put('status', 'success');

            return mapResult;
        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TemplateGalleryCompHandler', 'sendTouchpointTemplate', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
    
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param templateId stores the touchpoint template Id
* @param language   stores the  selected language
* @param campId   stores the  campaign id
* @return String ....
*/
    
    @AuraEnabled
    public static String generatePreviewIFrameUrl(String templateId, String language, String campId) {
        try{
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Campaign camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: campId WITH SECURITY_ENFORCED];
            Map<String,String> urlMap = new Map<String, String>();
            String emailUrl = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId;
            emailUrl += (camp.TelosTouchSF__Type__c == 'email') ? '/preview/public/email' : '/preview/tp/public/email';
            emailUrl += '?lang='+language+'&custom_messages=%5B%5D&access_token='+TelosTouchSF.TelosTouchUtility.getCurrentUserToken();
            urlMap.put('email', emailUrl);
            if(camp.TelosTouchSF__Type__c != 'email'){
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
        }catch(Exception e){
            System.debug('Error is: '+ e.getMessage()+' at line no: '+e.getLineNumber());
            return null;
        }    
    }
}