/**
* @author Cloud Analogy
* @date 02/08/2021
*@description ContactTriggerForSyncingHandler.....
*/
public with sharing class ContactTriggerForSyncingHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description getInsertRecord.....
* @param campaignList ......
*/
    public static void getInsertRecord(List<Contact> contactList){
        try{
            List<Id> contactIds = new   List<Id>();
            for(Contact con : contactList){
                if(Schema.sObjectType.Contact.fields.TelosTouchSF__Source__c.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                   con.TelosTouchSF__Source__c == 'Salesforce' && con.Email != null){
                       contactIds.add(con.Id);
                   }
            }
            if(contactIds.size() > 0){
                Database.executeBatch(new TelosTouchSF.BatchSFToTTSync(contactIds, null, 'insertContact', NULL, NULL, NULL), 150);
            }  
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description getUpdateRecord.....
* @param contactList ......
* @param oldMap ......
*/
    public static void getUpdateRecord(List<Contact> contactList, map<Id, Contact> oldMap){
        try{
            List<Id> contactIds = new   List<Id>();
            for(Contact con : contactList){
                if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                   oldMap.get(con.Id).Email != con.Email && con.TelosTouchSF__TT_Client_Id__c != null && !con.TelosTouchSF__TT_Conflict__c){
                       contactIds.add(con.Id);
                   }
            }if(contactIds.size() > 0){
                Database.executeBatch(new TelosTouchSF.BatchSFToTTSync(contactIds, null, 'updateContact', oldMap, NULL, NULL), 150);
            }  
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }         
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description getDeleteRecord.....
* @param contactList ......
*/
    public static void getDeleteRecord(List<Contact> contactList){
        try{
            List<String> clientIds = new   List<String>();
            List<Contact> filteredContactList = new List<Contact>();
            for(Contact con : contactList){
                if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()){
                    if(con.TelosTouchSF__TT_Client_Id__c != null && con.TelosTouchSF__isDeletedFromTT__c == false){
                        clientIds.add(con.TelosTouchSF__TT_Client_Id__c);
                        filteredContactList.add(con);
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
                Database.executeBatch(new TelosTouchSF.LeadAndContactDeleteFromTTBatch(filteredContactList, null, 'deleteContact'), 150);
            }  
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description updateTaskRecords.....
* @param records ......
* @param oldMap ......
*/
    public static void updateTaskRecords(List<Sobject> records, map<Id, Sobject> oldMap){
        try{
            Set<Id> contactIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            List<Contact> contactlist = new List<Contact>();
            List<Task> tasklist = new List<Task>();
            List<Task> updatetasklist = new List<Task>();
            List<Lead> leadlist = new List<Lead>();
            map<Id,Contact> mapIdVsContact = new  map<Id,Contact>();
            map<Id,Lead> mapIdVslead = new  map<Id,Lead>();
            map<Id,Contact> oldmapIdVsContact = new  map<Id,Contact>();
            map<Id,Lead> oldmapIdVslead = new  map<Id,Lead>();
            String objectName;
            for(SObject sObjectIds : records){
                Schema.SObjectType entityType = sObjectIds.Id.getSobjectType();
                objectName = String.valueOf(entityType);
                if(objectName == 'Contact'){
                    contactlist.add((Contact)sObjectIds);
                }else{
                    leadlist.add((Lead)sObjectIds);
                }
            } 
            for (SObject sobj : oldMap.values()) {
                Schema.SObjectType entityType = sobj.Id.getSobjectType();
                objectName = String.valueOf(entityType);
                if(objectName == 'Contact'){
                    oldmapIdVsContact.put(sobj.Id,(Contact)sobj);
                }else{
                    oldmapIdVslead.put(sobj.Id,(Lead)sobj);
                }
            }
            for(Contact conobj: contactlist){
                if(Schema.sObjectType.Contact.fields.TelosTouchSF__IsTelosTouchSyncAllowed__c.isAccessible() &&
                   Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                   Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&  Schema.sObjectType.Contact.fields.LastName.isAccessible() &&
                   (oldmapIdVsContact != null && oldmapIdVsContact.get(conobj.Id).TelosTouchSF__TT_Client_Id__c != conobj.TelosTouchSF__TT_Client_Id__c)){
                       contactIds.add(conobj.id);
                       mapIdVsContact.put(conobj.id,conobj);
                   }
            }
            for(Lead leadobj: leadlist){
                if(Schema.sObjectType.Lead.fields.TelosTouchSF__IsTelosTouchSyncAllowed__c.isAccessible() &&
                   Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                   Schema.sObjectType.Lead.fields.FirstName.isAccessible() &&  Schema.sObjectType.Lead.fields.LastName.isAccessible() &&
                   (oldmapIdVslead != null && oldmapIdVslead.get(leadobj.Id).TelosTouchSF__TT_Client_Id__c != leadobj.TelosTouchSF__TT_Client_Id__c)){                 
                       leadIds.add(leadobj.id);
                       mapIdVslead.put(leadobj.id,leadobj);
                   }
            }
            if(contactIds.size() >0 || leadIds.size() >0){
                if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable() &&
                   Schema.sObjectType.Task.fields.id.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                   Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() && Schema.sObjectType.Task.fields.WhoId.isAccessible()){
                       tasklist = [SELECT id, TelosTouchSF__TT_Client_Id__c, WhoId,TelosTouchSF__TT_Client_Name__c FROM Task WHERE WhoId IN:contactIds OR WhoId IN:leadIds LIMIT 10000];
                       for (Task task : taskList) {
                           if( mapIdVsContact.containsKey(task.WhoId) && mapIdVsContact.get(task.WhoId) != null){
                               if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable()){
                                   task.TelosTouchSF__TT_Client_Id__c = mapIdVsContact.get(task.WhoId).TelosTouchSF__TT_Client_Id__c;
                               }
                               if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable()){
                                   if(mapIdVsContact.get(task.WhoId).FirstName != null){
                                       task.TelosTouchSF__TT_Client_Name__c =  mapIdVsContact.get(task.WhoId).FirstName+' '+mapIdVsContact.get(task.WhoId).LastName; 
                                   }else{
                                       task.TelosTouchSF__TT_Client_Name__c =  mapIdVsContact.get(task.WhoId).LastName;  
                                   }
                               }                                           
                           }else if( mapIdVslead.containsKey(task.WhoId) && mapIdVslead.get(task.WhoId) != null){ 
                               if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable()){
                                   task.TelosTouchSF__TT_Client_Id__c = mapIdVslead.get(task.WhoId).TelosTouchSF__TT_Client_Id__c;
                               }
                               if(Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable()){
                                   if(mapIdVslead.get(task.WhoId).FirstName != null){
                                       task.TelosTouchSF__TT_Client_Name__c =  mapIdVslead.get(task.WhoId).FirstName+' '+mapIdVslead.get(task.WhoId).LastName; 
                                   }else{
                                       task.TelosTouchSF__TT_Client_Name__c =  mapIdVslead.get(task.WhoId).LastName;  
                                   }
                               }                                
                           }
                           updatetasklist.add(task);  
                       }     
                       if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isUpdateable() && updatetasklist.size ()>0){
                           update updatetasklist;     
                       }
                   }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description removeConflict.....
* @param newList ......
* @param oldMap ......
*/
    public static void removeConflict(List<Contact> newList, Map<Id, Contact> oldMap){
        try{
            String message = 'Duplicate Email';
            if(newList != null && newList.size()>0){
                for(Contact con : newList){
                    if((con.TelosTouchSF__TT_Conflict__c || con.TelosTouchSF__Error_Message__c == message) 
                        && con.Email != oldMap.get(con.Id).Email)
                    {
                        con.TelosTouchSF__TT_Conflict__c = false;
                        con.TelosTouchSF__Error_Message__c = '';
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }

    //Method responsible to update the last modified date field if any of the fields relevant to sync is modified
    public static void checkSyncLastModifiedData(list<Contact> lstContact){

        set<String> setField = new set<String>();
        for(TelosTouchSF__TT_Salesforce_Mapping__c aField : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                WHERE TelosTouchSF__Object_Name__c = 'Contact'])
        {
            setField.add(aField.TelosTouchSF__Salesforce_Field__c);
        }
        //OwnerId is not mapped but is sent in the sync, we are looking a better way to add it dynamically
        setField.add('OwnerId');

        for(Contact ctt : lstContact){
            for(String aField : setField){
                if(TriggerUtils.wasChanged(ctt, aField)){
                    ctt.TelosTouchSF__TT_Last_Modified_Date__c = System.now();
                    break;
                }
            }
        }

    }
}