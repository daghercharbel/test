/**
* @author Cloud Analogy
* @date 02/08/2021
*@description CampaignTriggerHandler.....
*/
public with sharing class CampaignTriggerHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description getDeletedCampaignRecord.....
* @param campaignList ......
*/
    public static void getDeletedCampaignRecord(List<Campaign> campaignList){
        try{
            List<Campaign> updatedCampaignList = new List<Campaign>();
            Set<Id> campaignIdSet = new Set<Id>();
            for(Campaign campaignObject : campaignList){
                campaignIdSet.add(campaignObject.Id);
                if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() && Schema.sObjectType.Campaign.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()){
                    if(campaignObject.TelosTouchSF__TT_Campaign_Id__c != null && campaignObject.TelosTouchSF__isDeletedFromTT__c == false){
                        updatedCampaignList.add(campaignObject);
                    }
                }
            }
            if(updatedCampaignList.size() > 0){
                Database.executeBatch(new TelosTouchSF.CampaignDelete_Batch(updatedCampaignList), 90);
            }
            if(campaignIdSet.size() > 0){
                if(Schema.SObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.SObjectType.TelosTouchSF__Insights__c.isDeletable()){
                    delete [SELECT Id FROM TelosTouchSF__Insights__c Where TelosTouchSF__Campaign2__c IN: campaignIdSet WITH SECURITY_ENFORCED LIMIT 9500 ];
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage()+' Occurred At Line Number: '+ex.getLineNumber());
        }
    }
   /**
* @author Cloud Analogy
* @date 02/08/2021
*@description clearTemplateId.....
* @param lstCamp ......
*/
    public static void clearTemplateId(List<Campaign> lstCamp) {
        for(Campaign camp : lstCamp){
            if(String.isNotBlank(camp.TelosTouchSF__TT_Campaign_Id__c) || !TriggerUtils.wasChanged(camp, 'TelosTouchSF__Type__c')){
                continue;
            }
            camp.TelosTouchSF__TouchPoint_Template_Id__c = null;
        }
    }

    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description createQuestionsAndAnswers.....
* @param campaignList ......
*/
    public static void createQuestionsAndAnswers(List<Campaign> campaignList){
        try{
            if(campaignList != null && campaignList.size()>0){
                List<TelosTouchSF__TT_Client_Answers__c> answersInsertList = new List<TelosTouchSF__TT_Client_Answers__c>();
                Set<String> userIdSet = new Set<String>();
                Set<String> accountIdSet = new Set<String>();
                Set<String> conversationIdSet = new Set<String>();
                Map<String, String> userIdVsAccountIdMap = new Map<String, String>();
                Map<String, Id> userIdvsSfIdMap = new Map<String, Id>();
                Map<String, Id> userIdvsOwnerIdMap = new Map<String, Id>();
                Map<String, Boolean> conversationIdvsFlag = new Map<String, Boolean>();
                for(Campaign each : campaignList){
                    if(String.isNotBlank(each.TelosTouchSF__Answers__c) && String.isNotBlank(each.TelosTouchSF__Questions__c)){
                        List<Object> answersObjList = new List<Object>();
                        answersObjList = (List<Object>)JSON.deserializeUntyped(each.TelosTouchSF__Answers__c.unescapeHtml4());
                        for(Object answerObj : answersObjList){
                            Map<String, Object> answersObjMap = (Map<String, Object>)answerObj;
                            userIdSet.add(String.valueOf(answersObjMap.get('client_id')));
                            conversationIdSet.add(String.valueOf(answersObjMap.get('conversation_id')));
                        }
                    }
                }
                List<TelosTouchSF__TT_Client_Answers__c> answersList = new List<TelosTouchSF__TT_Client_Answers__c>();
                if(Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.isQueryable() &&
                        Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.Id.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__TT_Conversation_Id__c.isAccessible()){
                    answersList = [SELECT Id, TelosTouchSF__TT_Conversation_Id__c FROM TelosTouchSF__TT_Client_Answers__c WHERE TelosTouchSF__TT_Conversation_Id__c IN: conversationIdSet];
                }
                List<Contact> contactList = new List<Contact>();
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable() &&
                        Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                    contactList = [SELECT Id, AccountId, TelosTouchSF__TT_Client_Id__c,TelosTouchSF__TT_UserId__c, OwnerId FROM Contact WHERE TelosTouchSF__TT_Client_Id__c IN: userIdSet];
                }
                List<Lead> leadList = new List<Lead>();
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable() &&
                        Schema.sObjectType.Lead.fields.Id.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                    leadList = [SELECT Id, TelosTouchSF__TT_Client_Id__c, TelosTouchSF__TT_UserId__c, OwnerId FROM Lead WHERE TelosTouchSF__TT_Client_Id__c IN: userIdSet];
                }
                for(Contact each : contactList){
                    userIdvsSfIdMap.put(each.TelosTouchSF__TT_Client_Id__c, each.Id);
                    userIdvsOwnerIdMap.put(each.TelosTouchSF__TT_Client_Id__c, each.OwnerId);
                    if(each.AccountId != null){
                        accountIdSet.add(each.AccountId);
                    }
                }
                for(Lead each : leadList){
                    userIdvsSfIdMap.put(each.TelosTouchSF__TT_Client_Id__c, each.Id);
                    userIdvsOwnerIdMap.put(each.TelosTouchSF__TT_Client_Id__c, each.OwnerId);
                }
                boolean getIsPerson =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
                if(getIsPerson){
                    String queryStr = 'SELECT Id,TelosTouchSF__TT_Client_Id__pc, Name, OwnerId FROM Account WHERE Id IN:accountIdSet AND TelosTouchSF__TT_Client_Id__pc != null';
                    List<sobject> records = Database.query(String.escapeSingleQuotes(queryStr));
                    for(SObject obj : records){
                        userIdVsAccountIdMap.put((String) obj.get('TelosTouchSF__TT_Client_Id__pc'),(String)obj.get('Id'));
                        userIdvsOwnerIdMap.put((String)obj.get('TelosTouchSF__TT_Client_Id__pc'), (Id)obj.get('OwnerId'));
                    }
                }
                for(String conversationid : conversationIdSet){
                    Integer count = 0;
                    for(TelosTouchSF__TT_Client_Answers__c each : answersList){
                        if(conversationid == each.TelosTouchSF__TT_Conversation_Id__c){
                            count++;
                        }
                    }
                    if(count>0){
                        conversationIdvsFlag.put(conversationid, false);
                    }else{
                        conversationIdvsFlag.put(conversationid, true);
                    }
                }
                if(userIdvsSfIdMap.keySet().size() > 0){
                    for(Campaign each : campaignList){
                        if(String.isNotBlank(each.TelosTouchSF__Answers__c) && String.isNotBlank(each.TelosTouchSF__Questions__c)){
                            List<Object> answersObjList = new List<Object>();
                            answersObjList = (List<Object>)JSON.deserializeUntyped(each.TelosTouchSF__Answers__c.unescapeHtml4());
                            for(Object answerObj : answersObjList){
                                Map<String, Object> answersObjMap = (Map<String, Object>)answerObj;
                                if(conversationIdvsFlag.get(String.valueOf(answersObjMap.get('conversation_id')))){
                                    List<Object> questionsandanswersObjList = (List<Object>)answersObjMap.get('questionsandanswers');
                                    for(Object questionAndAnswerObj : questionsandanswersObjList){
                                        Map<String, Object> questionsandanswersObjMap = (Map<String, Object>)questionAndAnswerObj;
                                        if(userIdvsSfIdMap.get(String.valueOf(answersObjMap.get('client_id'))) != null &&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__TT_Conversation_Id__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__TT_Conversation_Id__c.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.Name.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.Name.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Question__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Question__c.isCreateable() &&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Campaign__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Campaign__c.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.OwnerId.isAccessible() &&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.OwnerId.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Contact__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Contact__c.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Lead__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Lead__c.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Answer__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Answer__c.isCreateable()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Client__c.isAccessible()&&
                                                Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Client__c.isCreateable()) {
                                            TelosTouchSF__TT_Client_Answers__c answer = new TelosTouchSF__TT_Client_Answers__c();
                                            answer.Name = String.valueOf(questionsandanswersObjMap.get('question')).abbreviate(80);
                                            answer.TelosTouchSF__Question__c = String.valueOf(questionsandanswersObjMap.get('question')).abbreviate(255);
                                            answer.TelosTouchSF__Campaign__c = each.Id;
                                            answer.TelosTouchSF__Answer__c = (String.valueOf(questionsandanswersObjMap.get('answers')).abbreviate(255)).removeStart('(').removeEnd(')');
                                            answer.TelosTouchSF__TT_Conversation_Id__c = String.valueOf(answersObjMap.get('conversation_id'));
                                            String sObjName = userIdvsSfIdMap.get(String.valueOf(answersObjMap.get('client_id'))).getSObjectType().getDescribe().getName();
                                            if(sObjName == 'Contact'){
                                                answer.TelosTouchSF__Contact__c = userIdvsSfIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                                answer.OwnerId = userIdvsOwnerIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                            }else if(sObjName == 'Lead'){
                                                answer.TelosTouchSF__Lead__c = userIdvsSfIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                                answer.OwnerId = userIdvsOwnerIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                            }
                                            if(userIdVsAccountIdMap.containskey(String.valueOf(answersObjMap.get('client_id'))) && userIdVsAccountIdMap.get(String.valueOf(answersObjMap.get('client_id'))) != null){
                                                answer.TelosTouchSF__Client__c = userIdVsAccountIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                                answer.OwnerId = userIdvsOwnerIdMap.get(String.valueOf(answersObjMap.get('client_id')));
                                            }
                                            answersInsertList.add(answer);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(answersInsertList.size()>0 && Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Client_Answers__c.isCreateable()){
                        insert answersInsertList;
                    }
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.WARN, e.getMessage()+' Occurred At Line Number: '+e.getLineNumber());
        }
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param newList ......
*/
    public static void publishEventOnInsertAndUpdate(List<Campaign> newList){
        try{
            Set<String> campaignIdSet = new Set<String>();
            List<TelosTouchSF__Insight_Creation_Event__e> insightEventList = new List<TelosTouchSF__Insight_Creation_Event__e>();
            for(Campaign camp : newList){
                campaignIdSet.add(camp.Id);
            }
            for(String campId : campaignIdSet){
                insightEventList.add(new TelosTouchSF__Insight_Creation_Event__e(TelosTouchSF__Campaign__c = campId));
            }
            EventBus.publish(insightEventList);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber());
        }
    }
}