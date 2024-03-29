/**
* @author Cloud Analogy
* @date 02/08/2021
* @description SendSFUserBatch class is used to update SF user and hit the TelosTouch API to create a new user on TelosTouch .
*/
global with sharing class SendSFUserBatch implements Database.Batchable<sObject>, Database.AllowsCallouts , Database.Stateful{
    private TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials;
    private TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential;
    private TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialsWrapper;
    global List<User> userList;
    global Map<Id,PermissionSetAssignment> userIdVsPermSetAssignObjMap1;
    global String message;
    global integer totalSyncedUser = 0;
    public List<TelosTouchSF__TT_Log__c> createListOfLog;
       /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param sfUserList ...
*/
    @deprecated
    global SendSFUserBatch(List<User> sfUserList){
        userList = new List<User>();
        userList = sfUserList;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param sfUserList ...
* @param userIdVsPermSetAssignObjMap ......
*/
    global SendSFUserBatch(List<User> sfUserList, Map<Id,PermissionSetAssignment> userIdVsPermSetAssignObjMap){
        userList = new List<User>();
        userList = sfUserList;
        userIdVsPermSetAssignObjMap1 = new Map<Id,PermissionSetAssignment>();
        userIdVsPermSetAssignObjMap1 = userIdVsPermSetAssignObjMap;
        adminCredentials = new TelosTouchSF__TT_Admin_Credentials__mdt();
        authenticationCredential = new TelosTouchSF__TT_Authentication_Credential__mdt();
        if([SELECT count() FROM TelosTouchSF__TT_Admin_Credentials__mdt LIMIT 1] > 0){
            adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
            adminCredentialsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential);
        }
        else{
            adminCredentialsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper();
        }
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @return sObject userList ......
*/
    global Iterable<sObject> start(Database.BatchableContext bc){
        return userList;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @param users ......
*/
    global void execute(Database.BatchableContext bc, List<User> users){
        try{
            String ttTeamName = String.isNotEmpty(adminCredentials.TelosTouchSF__Team_Name__c) ? adminCredentials.TelosTouchSF__Team_Name__c : authenticationCredential.TelosTouchSF__Client_ID__c;
            UserTriggerHandler.run = false;
            createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Boolean userUpdateFlag = false;
            Map<String, String> headersMap = new Map<String, String>();
            Map<String, Object> responseMap1 = new Map<String, Object>();
            Set<String> setOfMoreThanOneEmail = new Set<String>();
            Set<String> userIdSet = new Set<String>();
            if(users != null && users.size() > 0){
                message = 'error';
                List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
                List<PermissionSet> getPermissionSetList = new  List<PermissionSet>();
                if( Schema.sObjectType.PermissionSet.isAccessible() && Schema.sObjectType.PermissionSet.isQueryable()){
                    String strTelosTouch_Custom_Permission = 'TelosTouch_Custom_Permission';
                    String strTTPSetForInsightObjMDRelations = 'TTPSetForInsightObjMDRelations';
                    getPermissionSetList = [SELECT Id FROM PermissionSet WHERE Name =: strTelosTouch_Custom_Permission OR Name =: strTTPSetForInsightObjMDRelations WITH SECURITY_ENFORCED];
                }
                if(String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c) ){
                    headersMap.put('Accept', 'application/json');
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Authorization', 'Bearer '+authenticationCredential.TelosTouchSF__Access_Token__c);
                }
                Map<String, String> teamsResponseBody = TelosTouchSF.TelosTouchUtility.getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/teams?search='+ttTeamName, headersMap, null);
                 if(teamsResponseBody.get('status_code') == '401'){
					createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                }else{
                    if(teamsResponseBody.get('status_code').length() > 0){
                        list<String>StatusCodeList = teamsResponseBody.get('status_code').split('0');
                        if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+teamsResponseBody.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+teamsResponseBody.get('status_code'),1));
                        }
                    }
                }
                List<Object> teamsResponseList = (List<Object>) JSON.deserializeUntyped(teamsResponseBody.get('body'));
                Map<String, String> teamNameVsTeamIdMap = new Map<String, String>();
                for(Object teamsResponseObj : teamsResponseList){
                    Map<String, Object> teamResponseMap = (Map<String, Object>)teamsResponseObj;
                    if(teamResponseMap.containsKey('name') && teamResponseMap.containsKey('id') && teamResponseMap != null){
                        teamNameVsTeamIdMap.put(String.valueOf(teamResponseMap.get('name')), String.valueOf(teamResponseMap.get('id')));
                    }
                }
                for(User userObj: users){
                    userIdSet.add(userObj.Id);
                }
                for(User userObj: users){
                    if((!setOfMoreThanOneEmail.contains(userObj.Email))){
                        String methodType = 'GET',body = '',endPointURL = '', teamId;
                        TelosTouchSF.TelosTouchUtility.TTUserWrapper  ttuserObj = new TelosTouchSF.TelosTouchUtility.TTUserWrapper();
                        if(teamNameVsTeamIdMap.containsKey(ttTeamName)){
                            teamId = teamNameVsTeamIdMap.get(ttTeamName);
                        }else{
                            Map<String, String> teamIdMap = TelosTouchSF.TelosTouchUtility.getResponse('POST', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/teams', headersMap, '{"name":"'+ttTeamName+'","language": "en_US"}');
                            Map<String, Object> createTeamBodyMap = new Map<String, Object>();
                            createTeamBodyMap = (Map<String, Object>) JSON.deserializeUntyped(teamIdMap.get('body'));
                            teamId = String.valueOf(createTeamBodyMap.get('id'));
                        }
                        if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/users?search='+userObj.Email;
                        }
                        Map<String, String> responseBodyMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                        String responseBody = responseBodyMap.get('body');
                        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(responseBody);
                        Map<String, Object> getResponseMap = new Map<String, Object>();
                        if(!responseList.isEmpty()){
                            getResponseMap = (Map<String, Object>)responseList[0];
                        }
                        List<Object> rolesList = new List<Object>();
                        Map<String, Object> roleMap = new Map<String, Object>();
                        if(!getResponseMap.keySet().isEmpty()){
                            Map<String, String> getCurrentTeamBody = TelosTouchSF.TelosTouchUtility.getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users/'+String.valueOf(getResponseMap.get('id')), headersMap, null);
                            Map<String, Object> getCurrentTeamMap = (Map<String, Object>)((Map<String, Object>) JSON.deserializeUntyped(getCurrentTeamBody.get('body'))).get('team');
                            String currentTeamName = String.valueOf(getCurrentTeamMap.get('name'));
                            if(ttTeamName != currentTeamName){
                                Map<String, String> teamChangeReponseBody = TelosTouchSF.TelosTouchUtility.getResponse('PUT', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users/'+String.valueOf(getResponseMap.get('id'))+'/teams/'+teamId, headersMap, null);
                                if(String.valueOf(teamChangeReponseBody.get('body')).contains('id')){
                                    userUpdateFlag = true;
                                }
                            }else if(ttTeamName == currentTeamName){
                                userUpdateFlag = true;
                            }
                            if(userUpdateFlag){
                                if(Schema.sObjectType.User.fields.TelosTouchSF__Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable() &&
                                        Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() && String.valueOf(responseMap1.get('title')) != 'Client' &&
                                        Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable()){
                                    userObj.TelosTouchSF__TT_UserId__c = String.valueOf(getResponseMap.get('id'));
                                    userObj.TelosTouchSF__TT_UserName__c = String.valueOf(getResponseMap.get('username'));
                                    // Extract the role information
                                    rolesList = (List<Object>)getResponseMap.get('roles');
                                    roleMap = (Map<String, Object>)rolesList[0];
                                    // Get the role ID
                                    userObj.TelosTouchSF__TT_Role__c = (String)roleMap.get('id');
                                    ttuserObj = TelosTouchSF.TelosTouchUtility.getTokenForEachUser(String.valueOf(getResponseMap.get('username')), adminCredentialsWrapper);
                                    userObj.TelosTouchSF__Auth_Token__c = ttuserObj.TTToken;
                                }
                            }
                        }else{
                            if(String.isEmpty(userObj.TelosTouchSF__TT_UserId__c) || userObj.TelosTouchSF__TT_UserId__c == null) {
                            methodType = 'POST';
                            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users';
                                body = '{"firstName": "'+userObj.firstName
                                        +'","lastName": "'+userObj.lastName
                                        +'","username": "'+userObj.Username
                                        +'","phone": "'+userObj.Phone
                                        +'","email": "'+userObj.Email
                                        +'","role":"professional","team":"'+teamId+'","otherId":"'
                                        +userObj.Id+'"}';
                                Map<String, String> requestBodyMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                                responseBody = requestBodyMap.get('body');
                            }
                           }
                        }
                        if( responseBody != null && String.isNotBlank(responseBody)){
                            Map<String, Object> responseMap2 =  new Map<String, Object>();
                            if( methodType == 'POST'){
                                responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                                if(responseMap2.containsKey('emailExists') && Boolean.valueOf(responseMap2.get('emailExists'))){
                                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Email Already Exists: '+userObj.Email,'Courriel existe déjà: '+userObj.Email,1));
                                }else if(responseMap2.containsKey('usernameExists') && Boolean.valueOf(responseMap2.get('usernameExists'))){
                                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Username Already Exists: '+userObj.Username,'Code d\'utilisateur existe déjà: '+userObj.Username,1));
                                }else if(responseMap2.containsKey('problems')){
                                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure',String.valueof(responseMap2.get('message')),String.valueof(responseMap2.get('message')),1));
                                }else if(responseMap2.containsKey('id')){
                                    responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                                    if(String.valueof(responseMap1.get('id')) != null){
                                        if(Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable() ){
                                                ttuserObj = TelosTouchSF.TelosTouchUtility.getTokenForEachUser(String.valueOf(responseMap1.get('username')), adminCredentialsWrapper);
                                                userObj.TelosTouchSF__Auth_Token__c = ttuserObj.TTToken;
                                        }
                                        if(Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() ){
                                            userObj.TelosTouchSF__TT_UserId__c = String.valueof(responseMap1.get('id'));
                                        }
                                        if(Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable() ){
                                            userObj.TelosTouchSF__TT_UserName__c = String.valueof(responseMap1.get('username'));
                                        }
                                        // Extract the role information
                                        rolesList = (List<Object>)responseMap1.get('roles');
                                        roleMap = (Map<String, Object>)rolesList[0];
                                        // Get the role ID
                                        if(Schema.sObjectType.User.fields.TelosTouchSF__TT_Role__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_Role__c.isUpdateable() ){
                                            userObj.TelosTouchSF__TT_Role__c = (String)roleMap.get('id');
                                        }
                                    }
                                }
                            }
                            if( (methodType == 'GET' && !getResponseMap.keySet().isEmpty()) || (methodType == 'POST' && responseMap2.containsKey('id')) ){
                                if(!userIdVsPermSetAssignObjMap1.containsKey(userObj.Id)){
                                    PermissionSetAssignment psaObject = new PermissionSetAssignment();
                                    PermissionSetAssignment psaObject1 = new PermissionSetAssignment();
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable() ){
                                        psaObject.PermissionSetId = getPermissionSetList[0].Id;
                                        psaObject1.PermissionSetId = getPermissionSetList[1].Id;
                                    }
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() ){
                                        psaObject.AssigneeId= userObj.Id;
                                        psaObject1.AssigneeId= userObj.Id;
                                    }
                                    permissionSetList.add(psaObject);
                                    permissionSetList.add(psaObject1);
                                }else if(userIdVsPermSetAssignObjMap1.containsKey(userObj.Id) && userIdVsPermSetAssignObjMap1.get(userObj.Id).PermissionSetId != getPermissionSetList[0].Id){
                                    PermissionSetAssignment psaObject = new PermissionSetAssignment();
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable() ){
                                        psaObject.PermissionSetId = getPermissionSetList[0].Id;
                                    }
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() ){
                                        psaObject.AssigneeId= userObj.Id;
                                    }
                                    permissionSetList.add(psaObject);
                                }else if(userIdVsPermSetAssignObjMap1.containsKey(userObj.Id) && userIdVsPermSetAssignObjMap1.get(userObj.Id).PermissionSetId != getPermissionSetList[1].Id){
                                    PermissionSetAssignment psaObject = new PermissionSetAssignment();
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable() ){
                                        psaObject.PermissionSetId = getPermissionSetList[1].Id;
                                    }
                                    if(Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible() && Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() ){
                                        psaObject.AssigneeId= userObj.Id;
                                    }
                                    permissionSetList.add(psaObject);
                                }
                                message = 'success';
                                totalSyncedUser = totalSyncedUser+1;
                            }
                        }
                    }
                       setOfMoreThanOneEmail.add(userObj.Email);
                }
                if(permissionSetList.size() >0){
                    if(Schema.sObjectType.PermissionSetAssignment.isCreateable() && Schema.sObjectType.PermissionSetAssignment.isAccessible()){
                        Database.insert(permissionSetList,false);
                    }
                }
                if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isUpdateable()){
                    Database.update(users,false);
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
*/
    global void finish(Database.BatchableContext bc){
        UserTriggerHandler.run = true;
        if(totalSyncedUser > 0 && message == 'success' ){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('success','Salesforce User Sync Successful with TelosTouch.','Synchronisation des utilisateurs Salesforce réussie avec TelosTouch.',totalSyncedUser));
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && createListOfLog.size() >0){
            insert createListOfLog;
        }
    }
}