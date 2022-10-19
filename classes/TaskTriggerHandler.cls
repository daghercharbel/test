/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TaskTriggerHandler ...
*/
public with sharing class TaskTriggerHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description assignValueOnInsert ...
* @param  taskList ..
*/
    public static void assignValueOnInsert(List<Task> taskList){
        try{
            Set<Id> contactIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            for(Task taskObj : taskList){
                if(Schema.sObjectType.Task.fields.WhoId.isAccessible() && taskObj.WhoId != null &&
                   Schema.sObjectType.Task.fields.TelosTouchSF__Source__c.isAccessible() && taskObj.Source__c == 'Salesforce' ){
                       Schema.SObjectType entityType = taskObj.WhoId.getSobjectType();
                       String objectName = String.valueOf(entityType);
                       if(objectName == 'Lead'){
                           leadIds.add(taskObj.WhoId);
                       }if(objectName == 'Contact'){
                           contactIds.add(taskObj.WhoId);
                       }
                   }
            }
            if(contactIds.size() >0 || leadIds.size() >0){
                assignValueInTaskFields(taskList, contactIds, leadIds);
            }
        }
        Catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description assignValueOnUpdate ...
* @param  taskList ..
* @param  oldMap ..
*/
    public static void assignValueOnUpdate(List<Task> taskList, map<Id, Task> oldMap){
        try{
            Set<Id> contactIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            if(oldMap != null){
                for(Task taskObj : taskList){
                    if(taskObj.WhoId != null){
                        if(oldMap.get(taskObj.Id).WhoId != taskObj.WhoId){
                            Schema.SObjectType entityType = taskObj.WhoId.getSobjectType();
                            String objectName = String.valueOf(entityType);
                            if(objectName == 'Lead'){
                                leadIds.add(taskObj.WhoId);
                            }else if(objectName == 'Contact'){
                                contactIds.add(taskObj.WhoId);
                            }
                        }
                    }else{
                        if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() &&
                           Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable()){
                               taskObj.TelosTouchSF__TT_Client_Id__c = '';
                               taskObj.TelosTouchSF__TT_Client_Name__c = '';
                           }
                    }
                }
                if(contactIds.size() >0 || leadIds.size() >0){
                    assignValueInTaskFields(taskList, contactIds, leadIds);
                }
            }
        }
        Catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description assignValueInTaskFields ...
* @param  taskList ..
* @param  contactIds ..
* @param  leadIds ..
*/
    public static void assignValueInTaskFields(List<Task> taskList, Set<Id> contactIds, Set<Id> leadIds){
        try{
            List<Contact> contactlist = new List<Contact>();
            List<Lead> leadlist = new List<Lead>();
            map<Id,Contact> mapIdVsContact = new  map<Id,Contact>();
            map<Id,Lead> mapIdVslead = new  map<Id,Lead>();
            
            if(contactIds != null && contactIds.size() >0){
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.User.isQueryable() &&
                   Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                       contactlist = [SELECT Id, Name, TelosTouchSF__TT_Client_Id__c FROM Contact WHERE Id IN: contactIds LIMIT 50000];
                   }
            }
            if(leadIds != null && leadIds.size() >0){
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.User.isQueryable() &&
                   Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Lead.fields.Name.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                       leadlist = [SELECT id, Name, TelosTouchSF__TT_Client_Id__c FROM Lead WHERE Id IN: leadIds LIMIT 50000];
                   }
            }
            if(contactlist.size() >0){
                for (Contact con : contactlist) {
                    mapIdVsContact.put(con.Id, con);
                }
            }
            if(leadlist.size() >0){
                for (Lead leadObj : leadlist) {
                    mapIdVslead.put(leadObj.Id, leadObj);
                }
            }
            for (Task task : taskList) {
                if(mapIdVsContact.containsKey(task.WhoId)){
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Id__c = mapIdVsContact.get(task.WhoId).TelosTouchSF__TT_Client_Id__c;
                    }
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Name__c = mapIdVsContact.get(task.WhoId).Name;
                    }
                }
                else if(mapIdVslead.containsKey(task.WhoId)){
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Id__c = mapIdVslead.get(task.WhoId).TelosTouchSF__TT_Client_Id__c;
                    }
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Name__c = mapIdVslead.get(task.WhoId).Name;
                    }
                }
                else if (task.WhoId == null){
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Id__c = '';
                    }
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() && Schema.sObjectType.Task.fields.TT_Client_Name__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isCreateable()){
                        task.TelosTouchSF__TT_Client_Name__c = '';
                    }
                }
            }
        }Catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description TaskDelete_Batch ...
* @param  taskList ..
*/
    public static void getDeletedTaskRecord(List<Task> taskList){
        try{
            List<Task> updatedTaskList = new List<Task>();
            Set<Id> recurrenceActivityIdSet = new Set<Id>();
            for(Task taskObj : taskList){
                if(Schema.sObjectType.Task.fields.TT_TaskId__c.isAccessible() && Schema.sObjectType.Task.fields.isDeletedFromTT__c.isAccessible()){
                    if(taskObj.TT_TaskId__c != null && taskObj.isDeletedFromTT__c == false && taskObj.IsRecurrence == false){
                        updatedTaskList.add(taskObj);
                    }else if(taskObj.IsRecurrence == true){
                        recurrenceActivityIdSet.add(taskObj.RecurrenceActivityId);
                    }
                }
            }
            List<Task> recurringChildTasks = new List<Task>();
            recurringChildTasks = [SELECT Id, Subject, OwnerId, TelosTouchSF__TT_TaskId__c, WhatId, WhoId, TelosTouchSF__TT_Client_Id__c FROM Task
                                   WHERE RecurrenceActivityId =: recurrenceActivityIdSet AND TelosTouchSF__TT_TaskId__c != NULL WITH SECURITY_ENFORCED ALL ROWS];
            if(!recurringChildTasks.isEmpty()){
                updatedTaskList.addAll(recurringChildTasks);
            }
            if(updatedTaskList.size() > 0){
                Database.executeBatch(new TaskDelete_Batch(updatedTaskList), 150);
            }
        }
        Catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
    }
}