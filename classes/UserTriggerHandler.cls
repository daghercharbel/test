/**
* @author Cloud Analogy
* @date 02/08/2021
* @description UserTriggerHandler class is used to update user from Salesforce to TelosTouch.
*/
public with sharing class UserTriggerHandler {
    /*private static final TelosTouch_API_Settings__c getCredentials= TelosTouch_API_Settings__c.getOrgDefaults();
    private static final String instanceUrl = getCredentials.Instance_url__c;
    private static final String token = getCredentials.Token__c;*/
    public static boolean run = true;
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method queries the details of the System Administrator.
* @param deactivatedUserList stores a list of deactivated users in the org.
* @param userMap stores a map of users in the org.
*/
    public static void getUserList(List<User> deactivatedUserList, Map<Id,User> userMap){
        try{
            String UserId = UserInfo.getUserId();
            user user = new user();
            if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible()){
                user = [SELECT Id,TelosTouchSF__TT_UserId__c,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c FROM User WHERE Id=:UserId];
            }
            updateUserInTelosTouch(JSON.serialize(deactivatedUserList),JSON.serialize(user),JSON.serialize(userMap));
        }
        Catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }

    @future(callout=true)
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method updates user details in TelosTouch
* @param userList stores a list of deactivated users in the org in JSON String Format.
* @param userObjJSON stores details of System Administrator in JSON String Format.
* @param userMapJSON stores a map of users in the org in JSON String Format.
*/
    public static void updateUserInTelosTouch(String userList, String userObjJSON, String userMapJSON) {
        try{
            //System.debug('User Future Method Called!');
            List<user> getUserList = (List<user>) JSON.deserialize(userList, List<user>.class);
            Map<Id,User> userMap = (Map<Id,User>) JSON.deserialize(userMapJSON, Map<Id,User>.class);
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            User user = (User) JSON.deserialize(userObjJSON, User.class);
            for(User userObj : getUserList) {
                String  userToken = userObj.TelosTouchSF__Auth_Token__c;
                String  userName = userObj.TelosTouchSF__TT_UserName__c;
                String body = '',UserLanguage ='',endPointURL ='';
                String methodType = 'PUT';
                //Blob blobValue = Blob.valueOf(userName+':'+userToken);
                // String authToken = EncodingUtil.base64Encode(blobValue);
                Map<String, String> headersMap = new Map<String, String>();
                headersMap.put('Authorization','Bearer ' +userToken);
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Accept', 'application/json');
                //System.debug('headers:: '+headersMap);
                if(userMap != null && ((userObj.LanguageLocaleKey != null && userObj.LanguageLocaleKey != userMap.get(userObj.Id).LanguageLocaleKey)|| (userObj.TimeZoneSidKey != null && userObj.TimeZoneSidKey != userMap.get(userObj.Id).TimeZoneSidKey))){
                    methodType = 'GET';
                    if(userObj.LanguageLocaleKey == 'en_US'){
                        UserLanguage = 'en_US';
                    }else if(userObj.LanguageLocaleKey == 'fr'){
                        UserLanguage = 'fr_FR';
                    }else{
                        UserLanguage = 'en_US';
                    }
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/user/settings';
                    Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                    if(getResponseMap.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(getResponseMap.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(getResponseMap.get('status_code').length() > 0){
                            list<String>StatusCodeList = getResponseMap.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                            }
                        }
                    }
                    String getResponse = getResponseMap.get('body');
                    //System.debug('getResponse::'+getResponse);
                    if(getResponse != null && getResponse.contains('language')){
                        methodType = 'PATCH';
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
                        body = '{"language": "'+UserLanguage+'","timezone": "'+userObj.TimeZoneSidKey+'","clientPortal":"'+responseMap.get('clientPortal')+'","notificationTouchpointSend":"'+responseMap.get('notificationTouchpointSend')+'","notificationTouchpointCompleted":"'+responseMap.get('notificationTouchpointCompleted')+'","notificationActionCreate":"'+responseMap.get('notificationActionCreate')+'"}';
                        getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                        getResponse = getResponseMap.get('body');
                        //System.debug('getResponse::'+getResponse);
                        if(getResponse != null && getResponse.contains('language')){
                            Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
                            if((responseMap2.containsKey('language') && String.valueof(responseMap2.get('language')) ==  UserLanguage )
                                    || (responseMap2.containsKey('timezone') && String.valueof(responseMap2.get('timezone')) ==  +userObj.TimeZoneSidKey )){
                                createLogRecord('success','User language/timezone updated successful','Langue ou fuseau horaire de l\'usager mis à jour avec succès',1);
                            }else{
                                createLogRecord(System.Label.Failed_Text,'User language/timezone updated failed','Échec de la mise à jour de la langue ou du fuseau horaire de l\'usager',0) ;
                            }
                        }
                    }
                }
                /*if (userObj.TelosTouchSF__TT_UserId__c != null && userObj.IsActive != true) {
                    userName = user.TelosTouchSF__TT_UserName__c;
                    //blobValue = Blob.valueOf(userName + ':' + userToken);
                    //authToken = EncodingUtil.base64Encode(blobValue);
                    methodType = 'PUT';
                    headersMap.put('Authorization','Bearer ' +adminCredentials.TelosTouchSF__Access_Token__c);
                    body = '{"enabled":false}';
                    endPointURL = adminCredentials.Instance_URL__c+'/api/v1/users/'+userObj.TelosTouchSF__TT_UserId__c;
                    String getResponse = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                    if(getResponse != null && getResponse.contains('isActive')){
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
                        if(responseMap.containsKey('isActive') && String.valueof(responseMap.get('isActive')) ==  'false'){
                            createLogRecord('success','User deactivate successful.',1);
                        }else{
                            createLogRecord('failed','User deactivate failed',0) ; 
                        }
                    }
                }else*/

                if(userObj.TelosTouchSF__TT_UserId__c != null && userMap != null && userObj.IsActive != userMap.get(userObj.Id).IsActive){
                    userName = user.TelosTouchSF__TT_UserName__c;
                    methodType = 'PUT';
                    //blobValue = Blob.valueOf(userName + ':' + userToken);
                    //authToken = EncodingUtil.base64Encode(blobValue);
                    headersMap.put('Authorization','Bearer ' +authenticationCredential.TelosTouchSF__Access_Token__c);
                    body = '{"enabled":'+userObj.IsActive+'}';
                    endPointURL = adminCredentials.Instance_URL__c+'/api/v1/users/'+userObj.TelosTouchSF__TT_UserId__c;
                    Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                    if(getResponseMap.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(getResponseMap.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(getResponseMap.get('status_code').length() > 0){
                            list<String>StatusCodeList = getResponseMap.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                            }
                        }
                    }
                    if(getResponseMap.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }
                    String getResponse = getResponseMap.get('body');
                    if(getResponse != null && getResponse.contains('isActive')){
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
                        if(responseMap.containsKey('isActive') && String.valueof(responseMap.get('isActive')) ==  'true'){
                            createLogRecord('success','User activated successfully from Salesforce to TelosTouch','Usager activé avec succès de Salesforce à TelosTouch', 1);
                        }else if(responseMap.containsKey('isActive') && String.valueof(responseMap.get('isActive')) ==  'false'){
                            createLogRecord('success','User deactivated successfully from Salesforce to TelosTouch','Usager désactivé avec succès de Salesforce à TelosTouch',1);
                        }
                    }else if(userObj.IsActive){
                        createLogRecord(System.Label.Failed_Text,'User activate failed from Salesforce to TelosTouch','Échec d\'activation d\'usager de Salesforce à TelosTouch.', 0) ;
                    }else{
                        createLogRecord(System.Label.Failed_Text,'User deactivate failed from Salesforce to TelosTouch','Échec de la désactivation de l\'usager de Salesforce à TelosTouch.', 0) ;
                    }
                }
            }
            if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert logList;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description  This method inserts logs in TelosTouchSF__TT_Log__c Object.
* @param message stores the result of the log.
* @param comment stores the comment of the log.
* @param comment_fr stores the comment of the log.
* @param count stores the count of the log.
*/
    public static void createLogRecord(String message, String comment, String comment_fr, Integer count){
        TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()
                && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()
                && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()
                && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isAccessible()
                && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments_FR__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments_FR__c.isCreateable()){
            if(message != 'success'){
                logObj.TelosTouchSF__Result__c = 'Failure';
                logObj.TelosTouchSF__Comments__c = comment;
                logObj.TelosTouchSF__Comments_FR__c = comment_fr;
                logObj.TelosTouchSF__Total_Records_Count__c = count;
                logObj.TelosTouchSF__Log_Type__c = 'Main Log';
            }else{
                logObj.TelosTouchSF__Total_Records_Count__c = count;
                logObj.TelosTouchSF__Result__c = 'Success';
                logObj.TelosTouchSF__Comments__c = comment;
                logObj.TelosTouchSF__Comments_FR__c = comment_fr;
                logObj.TelosTouchSF__Log_Type__c = 'Main Log';
            }
        }
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
            logObj.TelosTouchSF__LastUpdated__c = local;
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
            insert logObj;
        }
    }
}