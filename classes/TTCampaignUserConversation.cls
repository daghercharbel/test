/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTCampaignUserConversation class is a Batch Class and is used to get all TelosTouch touchpoints using TelosTouch API.
*/
global with sharing class TTCampaignUserConversation implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    global List<Campaign> campaignGlobalList;
    
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param campList ...
*/
    global TTCampaignUserConversation(List<Campaign> campList){
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
        System.debug(LoggingLevel.DEBUG, campaignGlobalList);
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
        if(campaigns != null && campaigns.size() > 0){
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            list<TelosTouchSF__Insights__c> lstInsight = new list<TelosTouchSF__Insights__c>();
            for(Campaign campaignobj : campaigns){
                try {
                    String methodType = 'GET';
                    String endPointURL = '';
                    Map<String, String> headersMap = new Map<String, String>();
                    if (String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c)) {
                        headersMap.put('Authorization', 'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
                    }
                    if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/touchpoints/' +
                                campaignObj.TelosTouchSF__TT_Campaign_Id__c + '/answers';
                    }
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    Map<String, String> responseBodyMap =
                            TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
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
                    if (responseBody != null) {
                        Map<String, Object> responseMap1 =
                                (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        if (Schema.sObjectType.Campaign.fields.TelosTouchSF__Answers__c.isUpdateable()) {
                            String answers = JSON.serialize(responseMap1.get('answers'));
                            if(answers.length() < 131000){ campaignobj.TelosTouchSF__Answers__c = answers; }
                            List<Object> lstAnswer = (List<Object>)responseMap1.get('answers');
                            for(Object answer : lstAnswer){
                                Map<String, Object> mapAnswer = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(answer));
                                TelosTouchSF__Insights__c insight = new TelosTouchSF__Insights__c(
                                    TelosTouchSF__Conversation_Id__c = (String)mapAnswer.get('conversation_id'),
                                    TelosTouchSF__Conversation_Metadata__c = JSON.serialize(answer)
                                );
                                lstInsight.add(insight);
                            }
                        }
                        if (Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isUpdateable()) {
                            System.debug(LoggingLevel.DEBUG,
                                            'responseMap1.get(questions):: ' + responseMap1.get('questions'));
                            campaignobj.TelosTouchSF__Questions__c = JSON.serialize(responseMap1.get('questions'));
                        }
                        campaignobj.TelosTouchSF__TT_Last_Sync_Time__c = System.now();
                    }
                }catch (Exception ex){
                    System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                    TelosTouchUtility.generateAndSaveErrorLog(ex, 'TTCampaignUserConversation', 'execute', null);
                }
            }
            if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable()){
                System.debug(LoggingLevel.DEBUG, 'campaigns:: '+campaigns);
                Database.update(campaigns);
            }
            if(!lstInsight.isEmpty()){
                Database.upsert(lstInsight, TelosTouchSF__Insights__c.TelosTouchSF__Conversation_Id__c);
            }
            if(!logList.isEmpty()){
                insert logList;
            }
        }
    }
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
*/
    global void finish(Database.BatchableContext bc){
        if(campaignGlobalList.size() > 0){
            TTUserConversationUpdate obj = new TTUserConversationUpdate(campaignGlobalList);
            Database.executeBatch(obj);
        }
    }
                /**
* @author Cloud Analogy
* @date 02/08/2021
* @description QuestionResponse is used to get question,key,type and list of answers.
*/
    global class QuestionResponse{
        global String question;
        global String key;
        global String type;
        global List<String> answers;
                    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        global QuestionResponse(){
            answers = new List<String>();
        }
    }
}