/**
* @author Cloud Analogy
* @date 02/08/2021
* @description This class use for Syncing Data Contact and Lead with TelosTouch and calls another class to delete data from TelosTouch.
*/
global with sharing class BatchSFToTTSync implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global List<Id> recordIds ;
    global List<String> clientIds ;
    global String action ;
    global String objectName ;
    public Integer contactSuccessCount = 0;
    public Integer contactErrorCount = 0;
    public Integer leadSuccessCount = 0;
    public Integer leadErrorCount = 0;
    public Map<ID, Contact> oldContactMap;
    public Map<ID, Lead> oldLeadMap;
    public Map<ID, Account> oldAccountMap;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param recordIds ......
* @param clientIds ...
* @param action ......
*/
    @Deprecated
    global BatchSFToTTSync(List<Id>  recordIds, List<String>  clientIds, String action) {
        this.recordIds = recordIds;
        this.action = action;
        this.clientIds = clientIds;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param recordIds ......
* @param clientIds ...
* @param action ......
* @param oldContactMap ......
* @param oldLeadMap ......
* @param oldAccountMap ......
*/
    global BatchSFToTTSync(List<Id>  recordIds, List<String>  clientIds, String action, Map<ID, Contact> oldContactMap, Map<ID, Lead> oldLeadMap, Map<ID, Account> oldAccountMap) {
        this.recordIds = recordIds;
        this.action = action;
        this.clientIds = clientIds;
        this.oldContactMap = oldContactMap;
        this.oldLeadMap = oldLeadMap;
        this.oldAccountMap = oldAccountMap;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ......
* @return Database.QueryLocator query ......
*/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(recordIds != null && recordIds.size() >0){
            String query = '';
            Set<String> setFields = new Set<String>{
                'TelosTouchSF__Language__c',
                'TelosTouchSF__Source__c',
                'TelosTouchSF__Subscribed__c',
                'TelosTouchSF__TT_Client_Id__c'
            };
            Schema.SObjectType entityType = recordIds[0].getSobjectType();
            objectName = String.valueOf(entityType);
            if(objectName == 'Contact'){
                String strContact ='Contact';
                String strAccountId = 'AccountId';
                query = 'SELECT Owner.TelosTouchSF__TT_UserName__c, Owner.TelosTouchSF__TT_UserId__c, Owner.TelosTouchSF__Auth_Token__c, Owner.Id, CreatedBy.Id,';
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable()){
                    for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                            FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                            WHERE TelosTouchSF__Object_Name__c =: strContact 
                                                                            AND TelosTouchSF__Salesforce_Field__c !=: strAccountId])
                    {
                        setFields.add(fieldAPI.TelosTouchSF__Salesforce_Field__c);
                    }
                }
                query += String.join(new List<String>(setFields), ',');
                query = query.removeEnd(',');
                query += ' FROM Contact WHERE ';
            }else{
                String strLead ='Lead';
                String strAccountId = 'AccountId';
                query = 'SELECT Owner.username, Owner.id, Status, ';
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable()){
                    for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                            FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                            WHERE TelosTouchSF__Object_Name__c =: strLead
                                                                            AND TelosTouchSF__Salesforce_Field__c !=: strAccountId])
                    {
                        setFields.add(fieldAPI.TelosTouchSF__Salesforce_Field__c);
                    }
                }
                query += String.join(new List<String>(setFields), ',');
                query = query.removeEnd(',');
                query += ' FROM Lead WHERE IsConverted = false AND';
            }
            query += ' Id IN:recordIds AND Email != null';
            query = query.removeEnd('WHERE');
            query = query.removeEnd('AND');
            return Database.getQueryLocator(String.escapeSingleQuotes(query).replace('\\',''));
        }else{
            String query;
            if(Schema.sObjectType.Organization.isAccessible() && Schema.sObjectType.Organization.isQueryable()){
                query = 'SELECT Id FROM Organization LIMIT 1';
            }
            return Database.getQueryLocator(String.escapeSingleQuotes(query));
        }
    }

    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ......
* @param sObjList ......
*/
    global void execute(Database.BatchableContext bc, List<Sobject> sObjList) {
        if(objectName == 'Contact' && action == 'insertContact' || action == 'updateContact'){
            TelosTouchSF.SFDataSyncWithTelosTouch.clientLogWrapper clientLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(sObjList, null, action, oldContactMap, oldLeadMap, oldAccountMap);
            if(clientLogObj != null){
                contactSuccessCount += clientLogObj.contactSuccessCount;
                contactErrorCount += clientLogObj.contactErrorCount;
            }
        }else if(objectName =='Lead' && action == 'insertLead' || action == 'updateLead'){
            TelosTouchSF.SFDataSyncWithTelosTouch.clientLogWrapper clientLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(null, sObjList, action, oldContactMap, oldLeadMap, oldAccountMap);
            if(clientLogObj != null){
                leadSuccessCount += clientLogObj.leadSuccessCount;
                leadErrorCount += clientLogObj.leadErrorCount;
            }
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ......
*/
    global void finish(Database.BatchableContext bc) {
        List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        List<Contact> conNullEmailList = [SELECT Id FROM Contact WHERE Email = NULL AND ID IN : recordIds WITH SECURITY_ENFORCED];
        List<Lead> leadNullEmailList = [SELECT Id FROM Lead WHERE Email = NULL AND ID IN : recordIds WITH SECURITY_ENFORCED];
        if(contactErrorCount > 0){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Contact sync records from Salesforce to TelosTouch','Échec de la Syncronisation des enregistrements entre Salesforce et TelosTouch',contactErrorCount));
        }
        if(contactSuccessCount > 0){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Contact sync records from Salesforce to TelosTouch','Syncronisation réussie des Contacts de Salesforce à TelosTouch',contactSuccessCount));
        }
        if(leadErrorCount > 0){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Lead sync records from Salesforce to TelosTouch','Échec de la syncronisation des prospects de Salesforce à TelosTouch', leadErrorCount));
        }
        if(leadSuccessCount > 0){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Lead sync records from Salesforce to TelosTouch','Syncronisation réussie des Prospects de Salesforce à TelosTouch',leadSuccessCount));
        }
        if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
            insert createListOfLog;
        }
    }

}