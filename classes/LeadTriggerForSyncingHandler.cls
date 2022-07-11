/**
* @author Cloud Analogy
* @date 02/08/2021
* @description LeadTriggerForSyncingHandler..........
*/
public with sharing class LeadTriggerForSyncingHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description getInsertRecord..........
	* @param leadList ......
*/
    public static void getInsertRecord(List<Lead> leadList){
        try{
            List<Id> leadIds = new   List<Id>();
            for(Lead lead : leadList){
                if(Schema.sObjectType.Lead.fields.TelosTouchSF__Source__c.isAccessible() && Schema.sObjectType.Lead.fields.Email.isAccessible()
                   && lead.TelosTouchSF__Source__c == 'Salesforce' && lead.Email != null){
                       leadIds.add(lead.Id);
                   }
            }
            if(leadIds.size() > 0){
                //String jobId = 
                Database.executeBatch(new TelosTouchSF.BatchSFToTTSync(leadIds, null, 'insertLead', NULL, NULL, NULL), 150);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description getUpdateRecord..........
* @param leadList ......
* @param oldMap ......
*/
    public static void getUpdateRecord(List<Lead> leadList, map<Id, Lead> oldMap){
        try{
            List<Id> leadIds = new List<Id>();
            for(Lead lead : leadList){
                if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Lead.fields.Email.isAccessible()
                   && oldMap.get(lead.Id).Email != lead.Email && lead.TelosTouchSF__TT_Client_Id__c != null && !lead.TelosTouchSF__TT_Conflict__c){
                       leadIds.add(lead.Id);
                   }
            }
            if(leadIds.size() > 0){
                //String jobId = 
                Database.executeBatch(new TelosTouchSF.BatchSFToTTSync(leadIds, null, 'updateLead', NULL , oldMap, NULL), 150);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description getDeleteRecord..........
* @param leadList ......
*/
    public static void getDeleteRecord(List<Lead> leadList){
        try{
            List<String> clientIds = new   List<String>();
            List<Lead> filteredLeadList = new List<Lead>();
            for(Lead lead : leadList){
                if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.lead.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()){
                    if(lead.TelosTouchSF__TT_Client_Id__c != null && lead.TelosTouchSF__isDeletedFromTT__c == false){
                        clientIds.add(lead.TelosTouchSF__TT_Client_Id__c);
                        filteredLeadList.add(lead);
                    }
                }
            }
            if(clientIds.size() > 0){
                if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()
                   && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                       List<Task> deleteTaskList = [SELECT Id,TelosTouchSF__TT_TaskId__c,OwnerId,TelosTouchSF__isDeletedFromTT__c FROM Task WHERE TelosTouchSF__TT_Client_Id__c IN:clientIds
                                                    AND TelosTouchSF__TT_TaskId__c != null AND TelosTouchSF__isDeletedFromTT__c = false AND IsDeleted = true ALL ROWS];
                       if(deleteTaskList.size()>0){
                           TelosTouchSF.TaskTriggerHandler.getDeletedTaskRecord(deleteTaskList);
                       }
                   }
                //String jobId = 
                Database.executeBatch(new LeadAndContactDeleteFromTTBatch(null, filteredLeadList, 'deleteLead'), 150);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description updateClientAnswersAfterLeadConversion..........
* @param leadList ......
*/
    public static void updateClientAnswersAfterLeadConversion(List<Lead> leadList){
        try{
            Map<Id, Lead> leadIdvsLeadObjMap = new Map<Id, Lead>();
            List<TelosTouchSF__TT_Client_Answers__c> answersList = new List<TelosTouchSF__TT_Client_Answers__c>();
            List<TelosTouchSF__TT_Client_Answers__c> answersInsertList = new List<TelosTouchSF__TT_Client_Answers__c>();
            if(leadList != null && !leadList.isEmpty()){
                for(Lead leadObj : leadList){
                    if(leadObj.IsConverted){
                        leadIdvsLeadObjMap.put(leadObj.Id, leadObj);
                    }
                }
                if(leadIdvsLeadObjMap != null && !leadIdvsLeadObjMap.isEmpty()){
                    answersList = [SELECT Id, Name, TelosTouchSF__Question__c, TelosTouchSF__Contact__c, TelosTouchSF__Client__c, TelosTouchSF__Campaign__c,
                                   TelosTouchSF__Answer__c, TelosTouchSF__Lead__c, TelosTouchSF__TT_Conversation_Id__c FROM TelosTouchSF__TT_Client_Answers__c
                                   WHERE TelosTouchSF__Lead__c IN: leadIdvsLeadObjMap.keySet() WITH SECURITY_ENFORCED];
                    if(answersList != null && !answersList.isEmpty()){
                        for(TelosTouchSF__TT_Client_Answers__c ansObj : answersList){
                            if(Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.isAccessible() && Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.isCreateable() &&
                               Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Contact__c.isAccessible() && Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Contact__c.isCreateable() &&
                               Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Lead__c.isAccessible() && Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.fields.TelosTouchSF__Lead__c.isCreateable()
                              ){
                                  TelosTouchSF__TT_Client_Answers__c ansInsObj = new TelosTouchSF__TT_Client_Answers__c();
                                  ansInsObj = ansObj.clone(false, true, false, false);
                                  ansInsObj.TelosTouchSF__Contact__c = leadIdvsLeadObjMap.get(ansObj.TelosTouchSF__Lead__c).ConvertedContactId;
                                  ansInsObj.TelosTouchSF__Lead__c = null;
                                  answersInsertList.add(ansInsObj);
                              }
                        }
                        if(Schema.SObjectType.TelosTouchSF__TT_Client_Answers__c.isAccessible() && TelosTouchSF__TT_Client_Answers__c.SObjectType.getDescribe().isDeletable()){
                            Database.delete(answersList, false);
                        }
                        if(answersInsertList != null && !answersInsertList.isEmpty() &&
                           TelosTouchSF__TT_Client_Answers__c.SObjectType.getDescribe().isAccessible() &&
                           TelosTouchSF__TT_Client_Answers__c.SObjectType.getDescribe().isCreateable() ){
                               insert answersInsertList;
                           }
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description leadConvertFieldMapping..........
* @param leadList ......
*/
    public static void leadConvertFieldMapping(List<Lead> leadList){
        try{
            Map<Id, Lead> conIdVsLeadObjMap = new Map<Id, Lead>();
            List<Contact> contactList = new List<Contact>();
            if(!leadList.isEmpty()){
                for(Lead ld : leadList){
                    if(ld.IsConverted && ld.ConvertedContactId != null){
                        conIdVsLeadObjMap.put(ld.ConvertedContactId, ld);
                    }
                }
                contactList = [SELECT Id, TelosTouchSF__TT_Last_Login__c, TelosTouchSF__Error_Message__c, TelosTouchSF__isDeletedFromTT__c, TelosTouchSF__IsTelosTouchSyncAllowed__c,
                               TelosTouchSF__Language__c, TelosTouchSF__Source__c, TelosTouchSF__Subscribed__c, TelosTouchSF__TT_Client_Id__c, TelosTouchSF__TT_UserId__c FROM Contact
                               WHERE Id IN: conIdVsLeadObjMap.keySet() WITH SECURITY_ENFORCED];
                if(!contactList.isEmpty()){
                    for(Contact con: contactList){
                        con.TelosTouchSF__TT_Last_Login__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__TT_Last_Login__c;
                        con.TelosTouchSF__Error_Message__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__Error_Message__c;
                        con.TelosTouchSF__isDeletedFromTT__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__isDeletedFromTT__c;
                        con.TelosTouchSF__IsTelosTouchSyncAllowed__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__IsTelosTouchSyncAllowed__c;
                        con.TelosTouchSF__Language__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__Language__c;
                        con.TelosTouchSF__Source__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__Source__c;
                        con.TelosTouchSF__Subscribed__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__Subscribed__c;
                        con.TelosTouchSF__TT_Client_Id__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__TT_Client_Id__c;
                        con.TelosTouchSF__TT_UserId__c = conIdVsLeadObjMap.get(con.Id).TelosTouchSF__TT_UserId__c;
                    }
                    if(Contact.sObjectType.getDescribe().isAccessible() && Contact.sObjectType.getDescribe().isUpdateable()){
                        update contactList;
                    }
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.WARN, 'Exception: '+e.getMessage()+' at Line Number: '+e.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description removeConflict..........
* @param newList ......
* @param oldMap ......
*/
    public static void removeConflict(List<Lead> newList, Map<Id, Lead> oldMap){
        try{
            if(newList != null && newList.size()>0){
                for(Lead ld : newList){
                    if(ld.TelosTouchSF__TT_Conflict__c && ld.Email != oldMap.get(ld.Id).Email){
                        ld.TelosTouchSF__TT_Conflict__c = false;
                        ld.TelosTouchSF__Error_Message__c = '';
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }

    //Method responsible to update the last modified date field if any of the fields relevant to sync is modified
    public static void checkSyncLastModifiedData(list<Lead> lstLead){

        set<String> setField = new set<String>();
        for(TelosTouchSF__TT_Salesforce_Mapping__c aField : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                WHERE TelosTouchSF__Object_Name__c = 'Lead'])
        {
            setField.add(aField.TelosTouchSF__Salesforce_Field__c);
        }

        for(Lead aLead : lstLead){
            for(String aField : setField){
                if(TriggerUtils.wasChanged(aLead, aField)){
                    aLead.TelosTouchSF__TT_Last_Modified_Date__c = System.now();
                    break;
                }
            }
        }

    }
}