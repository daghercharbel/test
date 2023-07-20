/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTcampaignResponse class is used to get new created TouchPoint record from SF to TelosTouch which is got through TelosTouch API.
*/
public with sharing class TTcampaignResponse {
    
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();

        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the response of campaigns.
* @param campId stores id of campaign.
* @param remainingClientIdsList stores id of campaign.
* @return String...
*/
    public static String getCampaignResponse(String campId, List<String> remainingClientIdsList ){
        try{
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            if(campId != null && String.isNotBlank(campId)){
                List<Campaign> campaignList = new List<Campaign>();
                       campaignList = [SELECT Id, Name, TelosTouchSF__TT_Campaign_Id__c, TelosTouchSF__Questions__c FROM Campaign WHERE Id =: campId AND TelosTouchSF__TT_Campaign_Id__c = null WITH SECURITY_ENFORCED LIMIT 1];
                if(campaignList.size() > 0){
                    String methodType = 'GET';
                    String endPointURL ='', userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
                    Map<String, String> headersMap = new Map<String, String>();
                    if(userToken != null && String.isNotBlank(userToken) ){
                        headersMap.put('Authorization','Bearer ' +userToken);
                         headersMap.put('Accept', 'application/json');
                         headersMap.put('Content-Type', 'application/json');
                    }
                    if(adminCredentials.TelosTouchSF__Instance_URL__c!= null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoint/templates/send/'+campId;
                    } 
                    Map<String, String> responseBody = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                    if(responseBody.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(responseBody.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(responseBody.get('status_code').length() > 0){
                            list<String>StatusCodeList = responseBody.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBody.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBody.get('status_code'),1));
                            }
                        }
                    }
                    if(responseBody.get('body') != null){
                        Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
                        if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isUpdateable()){
                            campaignList[0].TelosTouchSF__TT_Campaign_Id__c = String.valueof(responseMap1.get('id'));
                        }
                        if(Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isUpdateable()){
                            campaignList[0].TelosTouchSF__Questions__c =  JSON.serialize(responseMap1.get('questions'));
                        }
                        if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable()){
                            UPDATE campaignList;
                        }
                        if(remainingClientIdsList != null && !remainingClientIdsList.isEmpty()){
                            List<CampaignMember> campaignMembers = [ SELECT ContactId, Contact.TelosTouchSF__TT_Client_Id__c, LeadId, Lead.TelosTouchSF__TT_Client_Id__c, CampaignId,
                                                                     Lead.Phone FROM CampaignMember WHERE (CampaignId=:campId) AND
                                                                     ((Contact.TelosTouchSF__TT_Client_Id__c IN: remainingClientIdsList) OR (Lead.TelosTouchSF__TT_Client_Id__c IN: remainingClientIdsList)) WITH SECURITY_ENFORCED ];
                        }
                        if(Test.isRunningTest()){
                            getTTCampaignConversationResponse(campId, String.valueOf(responseMap1.get('id')));
                        }
                        if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                            insert logList;
                        }
                        if(!Test.isRunningTest()){
                            System.enqueueJob(new TelosTouchSF.GetClientsFromTTQueueable(0, 9000, Null,false, null));
                        }                        
                    }
                    return campaignList[0].TelosTouchSF__TT_Campaign_Id__c;
                }
            }
            return null;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            return null;
        }
    }
    @future (callout= true)
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the response of TT campaigns conversations.
* @param campId stores id of campaign.
* @param TTcampId stores Telostouch id of campaign.
*/
    public static void getTTCampaignConversationResponse(String campId,String TTcampId){
        try{
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            if(campId != null && TTcampId != null){
                List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
                List<Contact> contactList = new List<Contact>();
                List<Lead> leadList = new List<Lead>();
                Set<Id> contactIdSet = new Set<Id>();
                Set<Id> leadIdSet = new Set<Id>();
                Map<String,Contact> contactMap = new Map<String,Contact>();
                Map<String,Lead> leadMap = new Map<String,Lead>();
                
                List<CampaignMember> campaignMembers = new List<CampaignMember>();
                if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isQueryable() &&
                   Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() &&
                   Schema.sObjectType.CampaignMember.fields.Name.isAccessible() && Schema.sObjectType.CampaignMember.fields.Id.isAccessible() && 
                   Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible()){
                       campaignMembers= [SELECT Id,
                                         Name,
                                         ContactId,
                                         LeadId
                                         FROM CampaignMember WHERE CampaignId=: campId];
                   }
                for(CampaignMember campaignMemberObj : campaignMembers){
                    if(campaignMemberObj.ContactId != null){
                        contactIdSet.add(campaignMemberObj.ContactId);
                    }else if(campaignMemberObj.LeadId != null){
                        leadIdSet.add(campaignMemberObj.LeadId);
                    }
                }
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable() &&
                   Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                       contactList = [SELECT Id,TelosTouchSF__TT_Client_Id__c FROM Contact WHERE Id IN: contactIdSet AND TelosTouchSF__TT_Client_Id__c != null LIMIT 9000];
                   }
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable() &&
                   Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                       leadList = [SELECT Id,TelosTouchSF__TT_Client_Id__c FROM Lead WHERE Id IN: leadIdSet  AND TelosTouchSF__TT_Client_Id__c != null LIMIT 9000];
                   }
                for(Contact conObj :contactList){
                    contactMap.put(conObj.TelosTouchSF__TT_Client_Id__c,conObj);
                }
                for(Lead leadObj :leadList){
                    leadMap.put(leadObj.TelosTouchSF__TT_Client_Id__c,leadObj);
                }
                if ((leadMap != null && !leadMap.isEmpty()) || (contactMap != null && !contactMap.isEmpty())) {
                    
                    String methodType = 'GET';
                    String endPointURL ='', userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
                    Map<String, String> headersMap = new Map<String, String>();
                    if(String.isNotBlank(userToken) ){
                        headersMap.put('Authorization','Bearer ' +userToken);
                    }
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+TTcampId+'/clients';
                    } 
                    Map<String, String> responseBody = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                    if(responseBody.get('status_code') == '401' && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable()){
                        logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(responseBody.get('status_code') == '500' && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable()){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(responseBody.get('status_code').length() > 0){
                            list<String>StatusCodeList = responseBody.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5' &&(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable())){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBody.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBody.get('status_code'),1));
                            }
                        }
                    }
                    if(responseBody.get('body') != null){
                        Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
                        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(responseMap1.get('conversations')));
                        if(responseList != null && responseList.size() > 0){
                            for(Object responseObj : responseList){
                                Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseObj));
                                TelosTouchSF__Insights__c conversation_UserObj = new TelosTouchSF__Insights__c();
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isCreateable()){
                                    conversation_UserObj.TelosTouchSF__Campaign2__c = campId;
                                }
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable()){
                                    conversation_UserObj.TelosTouchSF__TouchPoint_Name__c = String.valueOf(responseMap1.get('name'));
                                }
                                if(responseMap2.containsKey('contact_id') && responseMap2.get('contact_id') !=  null){
                                    if(contactMap.containsKey(String.valueOf(responseMap2.get('contact_id')))){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Contact__c = contactMap.get(String.valueOf(responseMap2.get('contact_id'))).Id;
                                        }
                                    }else if(leadMap.containsKey(String.valueOf(responseMap2.get('contact_id')))){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Lead__c = leadMap.get(String.valueOf(responseMap2.get('contact_id'))).Id;
                                        }
                                    } 
                                }
                                if(responseMap2.containsKey('conversation_id') && responseMap2.get('conversation_id') !=  null){
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isCreateable()){
                                        conversation_UserObj.TelosTouchSF__Conversation_Id__c = String.valueOf(responseMap2.get('conversation_id'));
                                    }
                                }
                                if(responseMap2.containsKey('completed_at') && responseMap2.get('completed_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('completed_at')))){
                                    JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('completed_at'))+'"}');
                                    parser.nextToken();
                                    parser.nextValue();
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isCreateable()){
                                        conversation_UserObj.TelosTouchSF__Completed_At__c = DateTime.newInstance( parser.getDateTimeValue().getTime() );
                                    }
                                }
                                if(responseMap2.containsKey('opened_at') && responseMap2.get('opened_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('opened_at')))){
                                    JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('opened_at'))+'"}');
                                    parser.nextToken();
                                    parser.nextValue();
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isCreateable()){
                                        conversation_UserObj.TelosTouchSF__Opened_At__c = DateTime.newInstance( parser.getDateTimeValue().getTime() );
                                    }
                                }
                                if(responseMap2.containsKey('user_name') && responseMap2.get('user_name') !=  null){
                                    if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isCreateable()){
                                        conversation_UserObj.Name =  String.valueOf(responseMap2.get('user_name'));
                                    }
                                }
                                conversation_UserList.add(conversation_UserObj);
                            }
                            if(conversation_UserList.size() > 0){
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
                                    UPSERT  conversation_UserList TelosTouchSF__Conversation_Id__c;
                                }
                            }
                            if(!logList.isEmpty()){
                                insert logList;
                            }
                        }
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
}