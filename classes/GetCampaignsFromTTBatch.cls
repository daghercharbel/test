/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetCampaignsFromTTBatch class is used to get campaigns within last 2 hours from TT and insert in SF.
*/
global with sharing class GetCampaignsFromTTBatch implements Database.batchable<ResponseWrapper>, Database.AllowsCallouts, Database.Stateful{

    /*private static final TelosTouch_API_Settings__c getCredentials= TelosTouch_API_Settings__c.getOrgDefaults();
private static final String instanceUrl = getCredentials.Instance_url__c;
private static final String token = getCredentials.Token__c;*/
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    global List<Campaign> updateCampaignslList = new List<Campaign>();
    public List<Campaign> upsertedCampaignList = new List<Campaign>();
    global String message;
    global Integer totalRecordsSync = 0;
    global String touchPointdata;
    public boolean forFirstTime;
    @Deprecated
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param responseBody ...
*/
    global GetCampaignsFromTTBatch(String responseBody){
        touchPointdata = responseBody;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param responseBody ...
* @param forFirstTime ......
*/
    //Added new constructor
    public GetCampaignsFromTTBatch(String responseBody,Boolean forFirstTime){
        touchPointdata = responseBody;
        this.forFirstTime = forFirstTime;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @return ResponseWrapper newCampaignsFromTT ......
*/
    global Iterable<ResponseWrapper> start(Database.BatchableContext bc){
        List<ResponseWrapper>  newCampaignsFromTT = new List<ResponseWrapper>();
        for(Object respObj : (List<Object>) System.JSON.deserializeUntyped(touchPointdata)){
            Map<String, Object> respMap = (Map<String, Object>) respObj;
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.id = (String) respMap.get('id');
            respWrapper.other_id = (String) respMap.get('other_id');
            respWrapper.touchpoint_template_name = (String) respMap.get('touchpoint_template_name');
            respWrapper.questions = (List<Object>) respMap.get('questions');
            respWrapper.created_by_id  = (String) respMap.get('created_by_id');
            newCampaignsFromTT.add(respWrapper);
        }
        return newCampaignsFromTT;
    }

    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ...
* @param newCampaignsFromTT ...
*/
    global void execute(Database.BatchableContext bc, List<ResponseWrapper> newCampaignsFromTT){
        try{
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            Integer ownerNotFoundCount = 0;
            Set<String> setOfId = new Set<String>();
            Set<String> setOfSFId = new Set<String>();
            Map<String, Set<String>> setOfCampMemTTId = new Map<String, Set<String>>();
            Map<String,List<String>> TTCampIdVsClientsMap = new Map<String,List<String>>();
            Map<String, Object> responseMap1 = new Map<String, Object>();
            Map<String, String> mapOfSFCampIdVsTTCampIds = new  Map<String, String>();
            Map<String, String> mapOfSFCampIdVsTTCampIdsForUser = new  Map<String, String>();
            Map<String, String> mapSfIdVsTTIdForClients = new Map<String, String>();
            Map<String, String> headersMap = new Map<String, String>();
            Map<String, String> clientIdsVsSfClientIds = new Map<String, String>();
            List<Campaign> campaignInsertList = new  List<Campaign>();
            List<Campaign> needToDeleteCampaignList = new  List<Campaign>();
            Map<Id, Campaign> getSFCampaignsMap;
            List<Campaign> updateCampaignsList = new  List<Campaign>();
            List<CampaignMember> campaignMemberInsertList = new  List<CampaignMember>();
            List<String> listOfClientsId = new  List<String>();
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            List<Object> responseList = new List<Object>();
            List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
            List<TelosTouchSF__Insights__c> insertConversationUserList = new List<TelosTouchSF__Insights__c>();
            List<User> userList = new List<User>();

            Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
            String methodType = 'GET',endPointURL = '';
            //userAuthToken = TelosTouchUtility.getCurrentUserToken();
            if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                userList = [SELECT Id, TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c!=null AND IsActive=true];
            }
            Map<String, Id> userMap = new Map<String, Id>();
            for(User userObj : userList){
                userMap.put(userObj.TelosTouchSF__TT_UserId__c, userObj.Id);
            }
            if(newCampaignsFromTT.size() >0){
                for(Integer i=0; i< newCampaignsFromTT.size(); i++){
                    if(newCampaignsFromTT[i].other_id == null){
                        setOfId.add(newCampaignsFromTT[i].id);
                    }
                    else{
                        setOfId.add(newCampaignsFromTT[i].id);
                        setOfSFId.add(newCampaignsFromTT[i].other_id);
                    }
                }
                
                if(setOfId.size() > 0){
                    for(CampaignMember campMemObj : [SELECT Id, Contact.TelosTouchSF__TT_Client_Id__c, Lead.TelosTouchSF__TT_Client_Id__c, Campaign.TelosTouchSF__TT_Campaign_Id__c FROM CampaignMember WHERE Campaign.TelosTouchSF__TT_Campaign_Id__c IN: setOfId LIMIT 20000]){
                        if(campMemObj.Contact.TelosTouchSF__TT_Client_Id__c != null){
                            if(setOfCampMemTTId.containsKey(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c)){
                                setOfCampMemTTId.get(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c).add(campMemObj.Contact.TelosTouchSF__TT_Client_Id__c);
                            }else{
                                setOfCampMemTTId.put(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c, new Set<String>{campMemObj.Contact.TelosTouchSF__TT_Client_Id__c});
                            }
                        }else if(campMemObj.Lead.TelosTouchSF__TT_Client_Id__c != null){
                            if(setOfCampMemTTId.containsKey(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c)){
                                setOfCampMemTTId.get(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c).add(campMemObj.Lead.TelosTouchSF__TT_Client_Id__c);
                            }else{
                                setOfCampMemTTId.put(campMemObj.Campaign.TelosTouchSF__TT_Campaign_Id__c, new Set<String>{campMemObj.Lead.TelosTouchSF__TT_Client_Id__c});
                            }
                        }
                    }
                }
                if(setOfId.size() > 0){
                    for(String ttCampId : setOfId){
                        try {
                            if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
                                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/touchpoints/' +
                                        ttCampId + '/clients';
                                headersMap.put('Content-Type', 'application/json');
                                headersMap.put('Accept', 'application/json');
                            }
                            if (authenticationCredential.TelosTouchSF__Access_Token__c != null) {
                                headersMap.put('Authorization',
                                                'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
                                Map<String, String> cmResponseMap =
                                        TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                                if(cmResponseMap.get('status_code') == '401'){
                                    logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                                }else if(cmResponseMap.get('status_code') == '500'){
                                    logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                                }else{
                                    if(cmResponseMap.get('status_code').length() > 0){
                                        list<String>StatusCodeList = cmResponseMap.get('status_code').split('0');
                                        if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+cmResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+cmResponseMap.get('status_code'),1));
                                        }
                                    }
                                }
                                String cmResponseBody = cmResponseMap.get('body');
                                responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(cmResponseBody);
                                responseList = (List<Object>)JSON.deserializeUntyped(
                                        JSON.serialize(responseMap1.get('conversations')));
                            }
                            if (responseList != null && responseList.size() > 0) {
                                for (Object responseObj : responseList) {
                                    Map<String, Object> responseMap2 =
                                            (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseObj));
                                    if (!setOfCampMemTTId.containsKey(String.valueOf(responseMap1.get('id'))) ||
                                            !setOfCampMemTTId.get(String.valueOf(responseMap1.get('id'))).contains(
                                                    String.valueOf(responseMap2.get('contact_id')))) {
                                        TelosTouchSF__Insights__c conversation_UserObj =
                                                new TelosTouchSF__Insights__c();
                                        if (responseMap2.containsKey('conversation_id') &&
                                                        responseMap2.get('conversation_id') != null) {
                                            if (
                                                    Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isCreateable() &&
                                                    Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isUpdateable() &&
                                                    Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isAccessible()) {
                                                conversation_UserObj.TelosTouchSF__Conversation_Id__c =
                                                        String.valueOf(responseMap2.get('conversation_id'));
                                            }
                                        }
                                        if (
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__TouchPoint_Name__c =
                                                    String.valueOf(responseMap2.get('contact_id'));
                                        }
                                        if (
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isUpdateable() &&
                                                Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isAccessible()) {
                                            conversation_UserObj.TelosTouchSF__Answers__c =
                                                    String.valueOf(responseMap1.get('id'));
                                        }
                                        conversation_UserList.add(conversation_UserObj);
                                        if (TTCampIdVsClientsMap.containsKey(ttCampId)) {
                                            List<String> clientsId = TTCampIdVsClientsMap.get(ttCampId);
                                            clientsId.add(String.valueOf(responseMap2.get('contact_id')));
                                            TTCampIdVsClientsMap.put(ttCampId, clientsId);
                                        } else {
                                            TTCampIdVsClientsMap.put(ttCampId, new List<String> { String.valueOf(
                                                    responseMap2.get('contact_id')) });
                                        }
                                    }
                                }
                            }
                        }catch (Exception ex){
                            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                        }
                    }
                    if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() &&
                            Schema.sObjectType.Campaign.isCreateable() && Schema.sObjectType.Campaign.isUpdateable() &&
                            Schema.sObjectType.Campaign.isDeletable() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isCreateable() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isUpdateable() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isAccessible() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isUpdateable() &&
                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isCreateable()){
                        getSFCampaignsMap = new Map<Id, Campaign>([SELECT Id, Name, TelosTouchSF__TT_Campaign_Id__c,
                                                                    TelosTouchSF__TempTTCampId__c, TelosTouchSF__Questions__c
                                                                    FROM Campaign WHERE IsDeleted = false AND 
                                                                    TelosTouchSF__TT_Campaign_Id__c IN: setOfId 
                                                                    WITH SECURITY_ENFORCED LIMIT 10000 ALL ROWS]);
                        if(getSFCampaignsMap.values().size()>0){
                            upsertedCampaignList.addAll(getSFCampaignsMap.values());
                        }
                        for(Campaign campObj : getSFCampaignsMap.values()){
                            mapOfSFCampIdVsTTCampIds.put(campObj.TelosTouchSF__TT_Campaign_Id__c, campObj.Id);
                        }
                    }
                    for(ResponseWrapper respObj : newCampaignsFromTT){
                        if(respObj.other_id == null && !mapOfSFCampIdVsTTCampIds.containskey(respObj.id)){
                            if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isAccessible() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isCreateable() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isUpdateable() &&
                                    Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible() &&
                                    Schema.sObjectType.Campaign.fields.RecordTypeId.isCreateable() &&
                                    Schema.sObjectType.Campaign.fields.RecordTypeId.isUpdateable() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Source__c.isAccessible() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Source__c.isCreateable() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Source__c.isUpdateable() &&
                                    Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                                    Schema.sObjectType.Campaign.fields.Name.isCreateable() &&
                                    Schema.sObjectType.Campaign.fields.Name.isUpdateable() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isUpdateable() &&
                                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isCreateable() &&
                                    Schema.sObjectType.Campaign.isDeletable()){
                                Campaign campaignObject = new Campaign();
                                campaignObject.TelosTouchSF__TempTTCampId__c = respObj.id;
                                campaignObject.RecordTypeId = campaignRecordTypeId;
                                campaignObject.TelosTouchSF__Source__c = 'TelosTouch';
                                campaignObject.Name = respObj.touchpoint_template_name;
                                campaignObject.TelosTouchSF__Questions__c = JSON.serialize(respObj.questions);
                                if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable() && Schema.sObjectType.Campaign.isCreateable() &&
                                        Schema.sObjectType.Campaign.fields.OwnerId.isAccessible() && Schema.sObjectType.Campaign.fields.OwnerId.isUpdateable() && Schema.sObjectType.Campaign.fields.OwnerId.isCreateable() ){
                                    if(userMap.containsKey(respObj.created_by_id)){
                                        campaignObject.OwnerId = userMap.get(respObj.created_by_id);
                                        campaignInsertList.add(campaignObject);
                                    }else{
                                        OwnerNotFoundCount++;
                                    }
                                }
                            }
                        }else if(/*respObj.other_id != null &&*/ mapOfSFCampIdVsTTCampIds.containsKey(respObj.Id)){
                            campaignInsertList.add(getSFCampaignsMap.get(mapOfSFCampIdVsTTCampIds.get(respObj.Id)));
                        }
                    }
                    if(campaignInsertList.size() >0){
                        for(List<String> outerList  :TTCampIdVsClientsMap.values()){
                            for(String st : outerList ){
                                listOfClientsId.add(st);
                            }
                        }
                        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                            contactList = [SELECT Id, TelosTouchSF__TT_Client_Id__c FROM Contact WHERE IsDeleted = false AND TelosTouchSF__TT_Client_Id__c IN: listOfClientsId LIMIT 20000 ALL ROWS];
                        }
                        if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                            leadList = [SELECT Id, TelosTouchSF__TT_Client_Id__c FROM Lead WHERE IsDeleted = false AND TelosTouchSF__TT_Client_Id__c IN: listOfClientsId LIMIT 20000 ALL ROWS];
                        }
                        if(contactList.size() == 0 && leadList.size() == 0){
                            return;
                        }
                        for(Contact obj : contactList){
                            mapSfIdVsTTIdForClients.put(obj.TelosTouchSF__TT_Client_Id__c, obj.Id);
                        }
                        for(Lead obj : leadList){
                            mapSfIdVsTTIdForClients.put(obj.TelosTouchSF__TT_Client_Id__c, obj.Id);
                        }
                        if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isCreateable() && Schema.sObjectType.Campaign.isUpdateable()){
                            upsert campaignInsertList;
                        }
                        for(Campaign insertCampObj : campaignInsertList){
                            if(TTCampIdVsClientsMap.containskey(String.isNotEmpty(insertCampObj.TelosTouchSF__TT_Campaign_Id__c) ? insertCampObj.TelosTouchSF__TT_Campaign_Id__c : insertCampObj.TelosTouchSF__TempTTCampId__c)
                                    && TTCampIdVsClientsMap.get(String.isNotEmpty(insertCampObj.TelosTouchSF__TT_Campaign_Id__c) ? insertCampObj.TelosTouchSF__TT_Campaign_Id__c : insertCampObj.TelosTouchSF__TempTTCampId__c) !=  null){
                                boolean removeCampaign = false;
                                for(String st  :TTCampIdVsClientsMap.get(String.isNotEmpty(insertCampObj.TelosTouchSF__TT_Campaign_Id__c) ? insertCampObj.TelosTouchSF__TT_Campaign_Id__c : insertCampObj.TelosTouchSF__TempTTCampId__c)){
                                    if(!setOfCampMemTTId.containsKey(insertCampObj.TelosTouchSF__TT_Campaign_Id__c) || !setOfCampMemTTId.get(insertCampObj.TelosTouchSF__TT_Campaign_Id__c).contains(st)){
                                        if( mapSfIdVsTTIdForClients.containsKey(st) && mapSfIdVsTTIdForClients.get(st) != null ){
                                            CampaignMember CampaignMemberObj = new CampaignMember();
                                            if(Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible() &&
                                                    Schema.sObjectType.CampaignMember.fields.CampaignId.isCreateable()){
                                                CampaignMemberObj.CampaignId = insertCampObj.Id;
                                            }
                                            Schema.SObjectType entityType = Id.valueOf(mapSfIdVsTTIdForClients.get(st)).getSobjectType();
                                            String objectName = String.valueOf(entityType);
                                            if(objectName == 'Contact'){
                                                if(Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                                                        Schema.sObjectType.CampaignMember.fields.ContactId.isCreateable()){
                                                    CampaignMemberObj.ContactId = mapSfIdVsTTIdForClients.get(st);
                                                    clientIdsVsSfClientIds.put(st, mapSfIdVsTTIdForClients.get(st)+' Contact');
                                                }
                                            }else if(objectName == 'Lead'){
                                                if(Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() &&
                                                        Schema.sObjectType.CampaignMember.fields.LeadId.isCreateable() ){
                                                    CampaignMemberObj.LeadId = mapSfIdVsTTIdForClients.get(st);
                                                    clientIdsVsSfClientIds.put(st, mapSfIdVsTTIdForClients.get(st));
                                                }
                                            }
                                            campaignMemberInsertList.add(CampaignMemberObj);
                                        }else{
                                            removeCampaign = true;
                                        }
                                    }
                                }
                                if(removeCampaign == false){
                                    if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isAccessible() &&
                                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TempTTCampId__c.isUpdateable() &&
                                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() &&
                                            Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isUpdateable() &&
                                            String.isNotEmpty(insertCampObj.TelosTouchSF__TempTTCampId__c)){
                                        insertCampObj.TelosTouchSF__TT_Campaign_Id__c = insertCampObj.TelosTouchSF__TempTTCampId__c;
                                        insertCampObj.TelosTouchSF__TempTTCampId__c = '';
                                    }
                                    mapOfSFCampIdVsTTCampIdsForUser.put(insertCampObj.TelosTouchSF__TT_Campaign_Id__c, insertCampObj.Id);
                                    updateCampaignsList.add(insertCampObj);
                                }else{
										needToDeleteCampaignList.add(insertCampObj);
                                }
                            }
                        }
                        if(campaignMemberInsertList.size() >0 ){
                            if(Schema.sObjectType.CampaignMember.isCreateable() && Schema.sObjectType.CampaignMember.isAccessible()){
                                insert campaignMemberInsertList;
                            }
                            message = 'Campaigns Sync Successfully';
                        }else{
                            if(Campaign.SObjectType.getDescribe().isDeletable() && needToDeleteCampaignList.size() >0){
                                delete needToDeleteCampaignList;
                            }
                            message = System.Label.Failed_Text;
                            return;
                        }
                        if( Campaign.SObjectType.getDescribe().isDeletable() && needToDeleteCampaignList.size() >0){
                            delete needToDeleteCampaignList;
                        }
                        if(updateCampaignsList.size() >0){
                            if(Schema.sObjectType.Campaign.isUpdateable() && Schema.sObjectType.Campaign.isAccessible()){
                                update updateCampaignsList;
                            }
                            updateCampaignslList = updateCampaignsList;
                            message = 'Success';
                        }else{
                            message = System.Label.Failed_Text;
                            return;
                        }
                        for(TelosTouchSF__Insights__c answerObj : conversation_UserList){
                            String st = answerObj.TelosTouchSF__Answers__c;
                            if(mapOfSFCampIdVsTTCampIdsForUser.containsKey(st) && mapOfSFCampIdVsTTCampIdsForUser.get(answerObj.TelosTouchSF__Answers__c) != null
                                    && clientIdsVsSfClientIds.containskey(answerObj.TelosTouchSF__TouchPoint_Name__c) && clientIdsVsSfClientIds.get(answerObj.TelosTouchSF__TouchPoint_Name__c) != null){
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible() &&
                                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isCreateable() ){
                                    answerObj.TelosTouchSF__Campaign2__c = mapOfSFCampIdVsTTCampIdsForUser.get(answerObj.TelosTouchSF__Answers__c);
                                }
                                if(clientIdsVsSfClientIds.get(answerObj.TelosTouchSF__TouchPoint_Name__c).contains('Contact')){
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isAccessible() &&
                                            Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isCreateable() ){
                                        answerObj.TelosTouchSF__Contact__c = clientIdsVsSfClientIds.get(answerObj.TelosTouchSF__TouchPoint_Name__c).remove('Contact').trim();
                                    }
                                }else{
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isAccessible() &&
                                            Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isCreateable() ){
                                        answerObj.TelosTouchSF__Lead__c = clientIdsVsSfClientIds.get(answerObj.TelosTouchSF__TouchPoint_Name__c);
                                    }
                                }
                                /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param answerObj ...
*/
                                insertConversationUserList.add(answerObj);
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isAccessible() &&
                                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isCreateable() &&
                                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isAccessible() &&
                                        Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable()){
                                    answerObj.TelosTouchSF__Answers__c = '';
                                    answerObj.TelosTouchSF__TouchPoint_Name__c = '';
                                }
                            }
                        }
                        if(insertConversationUserList.size() >0){
                            message ='Campaigns and Clients Sync Successfully';
                            if(Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible()){
                                insert insertConversationUserList;
                            }
                            totalRecordsSync = insertConversationUserList.size();
                        }else{
                            message = System.Label.Failed_Text;
                            return;
                        }
                    }
                }
            }
            if(OwnerNotFoundCount > 0){
                TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.Failed_Text,'Campaigns Sync Failed as Campaign Owner Not Found in Salesforce','Syncronisaiton de la Campagne a échoué car le propriétaire de la Campagne n\'existe pas dans Salesforce', OwnerNotFoundCount);
            }
            if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert logList;
            }
        }catch(exception ex ){
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
        if(message != null && String.isNotEmpty(message)){
            if(message == 'Campaigns Sync Successfully'){
                TelosTouchSF.UserTriggerHandler.createLogRecord('success','Campaigns sync successfully from TelosTouch to Salesforce.','Campagnes syncronisées avec succès de TelosTouch à Salesforce.', updateCampaignslList.size());
            }if (message == 'Campaigns and Clients Sync Successfully'){
                TelosTouchSF.UserTriggerHandler.createLogRecord('success','Campaigns sync successfully from TelosTouch to Salesforce with clients user.','Campagnes syncronisées avec succès de TelosTouch vers Salesforce avec utilisateurs clients', updateCampaignslList.size());
            }
        }
        //Call TTUserConversation batch for conversation
        //Added new constructor 
        if(Test.isRunningTest() == false){
            TTUserConversation obj = new TTUserConversation(forFirstTime, upsertedCampaignList);
            Database.executeBatch(obj);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ResponseWrapper is used to get id,other_id,touchpoint_template_name and list of questions.
*/
    global class ResponseWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String id {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String other_id {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String touchpoint_template_name{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public List<Object> questions {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String created_by_id {get;set;}
    }
    @Deprecated
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Questions......
*/
    global class Questions {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String question {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String key {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String type {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public List<String> answers;
    }
}