/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTUserConversation batch class is used to get the last one-hour user conversation updated records and after that, I have updated insights records.
* @update 27/Jul/2022 - Class was replaced by a direct callout in TTFilterUserController. This class now is OBSOLETE.
*/
global with sharing class TTUserConversation implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    global List<Campaign> campaignGlobalList;
    global List<Campaign> upsertedCampaignList;
    public boolean forFirstTime;
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    @deprecated
    global TTUserConversation(){
        campaignGlobalList = new List<Campaign>();
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param forFirstTime ...
* @param upsertedCampaignList ...
*/
    public TTUserConversation(Boolean forFirstTime, List<Campaign> upsertedCampaignList){
        campaignGlobalList = new List<Campaign>();
        this.upsertedCampaignList = upsertedCampaignList;
        this.forFirstTime = forFirstTime;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ......
* @return Database.QueryLocator soqlQuery ......
*/
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id, Name From Campaign LIMIT 1';
        return Database.getQueryLocator(String.EscapeSingleQuotes(soqlQuery));
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ......
* @param scope ......
*/
    global void execute(Database.BatchableContext bc, List<Campaign> scope){
        Set<Campaign> campaignGlobalSet = new Set<Campaign>();
        List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
        Map<String,TelosTouchSF__Insights__c> conversation_UserMap = new Map<String,TelosTouchSF__Insights__c>();
        Map<String,List<Object>>  answerSobjectMap = new Map<String,List<Object>> ();
        Map<String, String> headersMap = new Map<String, String>();
        Map<String,Campaign> campaignMap = new Map<String,Campaign>();
        Set<Id> campaignIdSet = new Set<Id>();
        List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();

        
        String methodType = 'GET';
        String responseBody,endPointURL ='';
        if(authenticationCredential.TelosTouchSF__Access_Token__c != null && String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c) ){
            headersMap.put('Authorization','Bearer ' +authenticationCredential.TelosTouchSF__Access_Token__c);
        }
        DateTime LAST_HOUR = System.NOW().addMinutes(-62);
        String formatted = LAST_HOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        Integer skip = 0;
        Integer responseSize = 0;

        do {
            responseSize = 0;
            if(adminCredentials.TelosTouchSF__Instance_URL__c != null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                
                if(!Test.isRunningTest() && (forFirstTime == true)){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/touchpoints/recipients/messages?sort=[{%20"id":%20"ASC"%20}]';
                }else{
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/touchpoints/recipients/messages?modified_at={">=":"'+formatted+'"}&sort=[{%20"id":%20"ASC"%20}]';
                }
                endPointURL += '&skip='+skip+'&limit=1000';
                Map<String, String> responseBodyMap = TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
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
                responseBody = responseBodyMap.get('body');
            } 
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if(responseBody != null){
                List<Object> conversationList = (List<Object>)JSON.deserializeUntyped(responseBody);
                responseSize = conversationList.size();
                skip += conversationList.size();
                for(Object conversationObj : conversationList){
                    try {
                        Map<String, Object> conversationMap1 =
                                (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(conversationObj));
                        if (conversationMap1.containsKey('content') && conversationMap1.get('content') != null &&
                                conversationMap1.containsKey('conversation_id') &&
                                        conversationMap1.get('conversation_id') != null) {
                            ObjectWrapper cbjectObj = new ObjectWrapper();
                            cbjectObj.is_robot = Boolean.valueOf(conversationMap1.get('is_robot'));
                            cbjectObj.content = String.valueOf(conversationMap1.get('content'));
                            cbjectObj.conversation_id = String.valueOf(conversationMap1.get('conversation_id'));
                            cbjectObj.type = String.valueOf(conversationMap1.get('type'));
                            cbjectObj.resource_url = String.valueOf(conversationMap1.get('resource_url'));
                            if (answerSobjectMap.containsKey(String.valueOf(conversationMap1.get('conversation_id')))) {
                                answerSobjectMap.get(String.valueOf(conversationMap1.get('conversation_id'))).add(
                                        cbjectObj);
                            } else {
                                answerSobjectMap.put(String.valueOf(conversationMap1.get('conversation_id')),
                                        new List<Object>());
                                answerSobjectMap.get(String.valueOf(conversationMap1.get('conversation_id'))).add(
                                        cbjectObj);
                            }
                        }
                    }catch (Exception ex){
                        System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                    }
                }
                if(!answerSobjectMap.isEmpty()){
                    if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isQueryable() &&
                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isAccessible() &&
                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible() &&
                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isAccessible() &&
                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.IsDeleted.isAccessible() &&
                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isAccessible()){
                            conversation_UserList = [SELECT Id,Name, TelosTouchSF__Conversation_Id__c, TelosTouchSF__Campaign2__c, TelosTouchSF__Answers__c FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__Conversation_Id__c IN: answerSobjectMap.keySet() AND IsDeleted = false LIMIT 20000 ALL ROWS];
                        }
                    for(TelosTouchSF__Insights__c conversationUserObj : conversation_UserList){
                        conversation_UserMap.put(conversationUserObj.TelosTouchSF__Conversation_Id__c,conversationUserObj);
                        if(conversationUserObj.TelosTouchSF__Campaign2__c !=  null){
                            campaignIdSet.add(conversationUserObj.TelosTouchSF__Campaign2__c);
                        }
                    }
                    Map<Id,Campaign> campaignQueryMap = new Map<Id,Campaign>([SELECT Id,Name, TelosTouchSF__TT_Campaign_Id__c, TelosTouchSF__Questions__c FROM Campaign WHERE Id IN: campaignIdSet AND IsDeleted = false LIMIT 20000 ALL ROWS]);
                    for(TelosTouchSF__Insights__c conversationUserObj : conversation_UserList){
                        campaignMap.put(conversationUserObj.TelosTouchSF__Conversation_Id__c, campaignQueryMap.get(conversationUserObj.TelosTouchSF__Campaign2__c));
                    }
                    for(String TTConversation_Id : answerSobjectMap.keySet()){
                        if(conversation_UserMap.containsKey(TTConversation_Id)){
                            conversation_UserMap.get(TTConversation_Id).TelosTouchSF__Answers__c = JSON.serialize(answerSobjectMap.get(TTConversation_Id));
                            campaignGlobalSet.add(campaignMap.get(TTConversation_Id));
                        }
                    }
                    campaignGlobalList.addAll(campaignGlobalSet);
                }
            }
        } while (responseSize == 1000);

        if(!conversation_UserMap.isEmpty()){
            do {
                if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
                    list<TelosTouchSF__Insights__c> lstInsight = new list<TelosTouchSF__Insights__c>();
                    if(conversation_UserMap.values().size() > 10000){
                        Integer i = 0;
                        for(String key : conversation_UserMap.keySet()){
                            lstInsight.add(conversation_UserMap.get(key));
                            conversation_UserMap.remove(key);
                            if(lstInsight.size() == 10000) break;
                        }
                    } else {
                        lstInsight = conversation_UserMap.values();
                        conversation_UserMap = new Map<String,TelosTouchSF__Insights__c>();
                    }
                    UPDATE lstInsight;
                }
            } while (conversation_UserMap.values().size() > 0);
        }

        if(!logList.isEmpty()){
            insert logList;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
*/
    global void finish(Database.BatchableContext bc){
        if(campaignGlobalList.size() > 0 && Test.isRunningTest() == false){
            TTCampaignUserConversation obj = new TTCampaignUserConversation(campaignGlobalList);
            Database.executeBatch(obj);
        }else if(upsertedCampaignList != null && upsertedCampaignList.size() > 0 && Test.isRunningTest() == false){
            TTUserConversationUpdate obj = new TTUserConversationUpdate(upsertedCampaignList);
            Database.executeBatch(obj);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ObjectWrapper is used to get content,is_robot,type,resource_url and conversation_id.
*/ 
    public class ObjectWrapper{
        String  content;
        Boolean  is_robot;
        String  type;
        String  resource_url;
        String  conversation_id;
    }
}