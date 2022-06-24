/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTUserConversationUpdate class is used to get one TouchPoint conversation record which is got through TelosTouch API.
*/
global with sharing class TTUserConversationUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    /*private static final TelosTouch_API_Settings__c getCredentials= TelosTouch_API_Settings__c.getOrgDefaults();
    private static final String instanceUrl = getCredentials.Instance_url__c;
    private static final String token = getCredentials.Token__c;*/
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    global List<Campaign> campaignGlobalList;
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This constructor initializes campaign list.
* @param campList stores list of all campaign.
*/
    global TTUserConversationUpdate(List<Campaign> campList){
        campaignGlobalList = new List<Campaign>();
        campaignGlobalList = campList;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @return sObject campaignGlobalList ......
*/
    global Iterable<sObject> start(Database.BatchableContext bc){
        return campaignGlobalList;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @param campaigns ......
*/
    global void execute(Database.BatchableContext bc, List<Campaign> campaigns){
        try{
            if(campaigns != null && campaigns.size() > 0){
                List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
                List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
                for(Campaign campaignObj :campaigns){
                    String methodType = 'GET';
                    String endPointURL = '';
                    Map<String, String> headersMap = new Map<String, String>();
                   // String userAuthTOKEN = TelosTouchUtility.getCurrentUserTOKEN();
                    if(authenticationCredential.TelosTouchSF__Access_Token__c != null && String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c) ){
                        headersMap.put('Authorization','Bearer ' +authenticationCredential.TelosTouchSF__Access_Token__c);
                        //headersMap.put('espo-Authorization', adminCredentials.Access_Token__c);
                    }
                    if(adminCredentials.TelosTouchSF__Instance_URL__c != null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+campaignObj.TelosTouchSF__TT_Campaign_Id__c+'/clients';
                    } 
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    Map<String, String> responseBodyMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                    if(responseBodyMap.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(responseBodyMap.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(responseBodyMap.get('status_code').length() > 0){
                            list<String>StatusCodeList = responseBodyMap.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBodyMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBodyMap.get('status_code'),1));
                            }
                        }
                    }
                    String responseBody = responseBodyMap.get('body');
                    if(responseBody != null){
                        Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(responseMap1.get('conversations')));
                        if(responseList != null && responseList.size() > 0){
                            for(Object responseObj : responseList){
                                try {
                                    Map<String, Object> responseMap2 =
                                            (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseObj));
                                    TelosTouchSF__Insights__c conversation_UserObj = new TelosTouchSF__Insights__c();
                                    if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isCreateable() &&
                                            Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isUpdateable() &&
                                            Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible()) {
                                        conversation_UserObj.TelosTouchSF__Campaign2__c = campaignObj.Id;
                                    }
                                    if (responseMap2.containsKey('conversation_id') &&
                                                    responseMap2.get('conversation_id') != null) {
                                        if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__Conversation_Id__c =
                                                    String.valueOf(responseMap2.get('conversation_id'));
                                        }
                                        if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__TouchPoint_Name__c =
                                                    String.valueOf(responseMap1.get('name'));
                                        }
                                    }
                                    if (responseMap2.containsKey('completed_at') &&
                                                    responseMap2.get('completed_at') != null &&
                                            String.isNotBlank(String.valueOf(responseMap2.get('completed_at')))) {
                                        /*String dates = String.valueOf(responseMap2.get('completed_at'));
                                        dates = dates.replace('T', ' ');
                                        dates = dates.replace('.', '#');
                                        List<String> strList = dates.split('#');*/
                                        JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('completed_at'))+'"}');
                                        parser.nextToken();
                                        parser.nextValue();
                                        if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__Completed_At__c = DateTime.newInstance( parser.getDateTimeValue().getTime() );
                                        }
                                    }
                                    if (responseMap2.containsKey('opened_at') &&
                                                    responseMap2.get('opened_at') != null &&
                                            String.isNotBlank(String.valueOf(responseMap2.get('opened_at')))) {
                                        /*String dates = String.valueOf(responseMap2.get('opened_at'));
                                        dates = dates.replace('T', ' ');
                                        dates = dates.replace('.', '#');
                                        List<String> strList = dates.split('#');*/
                                        JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('opened_at'))+'"}');
                                        parser.nextToken();
                                        parser.nextValue();
                                        if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__Opened_At__c =  DateTime.newInstance( parser.getDateTimeValue().getTime() );
                                        }
                                    }
                                    if (responseMap2.containsKey('user_name') &&
                                                    responseMap2.get('user_name') != null) {
                                        if (Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isAccessible()) {
                                            conversation_UserObj.Name = String.valueOf(responseMap2.get('user_name'));
                                        }
                                    }
                                    if (Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() &&
                                            Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()) {
                                        conversation_UserList.add(conversation_UserObj);
                                    }
                                }catch (Exception ex){
                                    System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                                }
                            }
                        }
                    }
                }
                if(Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
                    if(conversation_UserList.size() > 0){
                        UPSERT  conversation_UserList TelosTouchSF__Conversation_Id__c;
                    }
                }
                if(!logList.isEmpty()){
                    insert logList;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber());
        }
    }
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
*/
    global void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
}