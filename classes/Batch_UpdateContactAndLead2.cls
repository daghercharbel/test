/**
* @author Cloud Analogy
* @date 02/08/2021
*@description Batch_UpdateContactAndLead2 class is using to get all contact and lead records of the last one hour and calls another class for syncing.After finish, the job of another batch class is calling for task syncing.
*/
public with sharing class Batch_UpdateContactAndLead2 implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public Integer contactSuccessCount = 0;
     public Integer contactErrorCount = 0;
     public Integer leadSuccessCount = 0;
     public Integer leadErrorCount = 0;
     public String syncObject;
     public String queryObject;
     public Boolean forFirstTime;
     public List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
     /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description constructor......
 * @param syncObject ......
 * @param forFirstTime ...
 * @param queryObject ...
 */
     public Batch_UpdateContactAndLead2(String syncObject, Boolean forFirstTime, String queryObject){
         this.syncObject = syncObject;
         this.forFirstTime = forFirstTime;
         this.queryObject = queryObject;
     }
         /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ......
 * @param info ...
 * @return SObject totallist ......
 */ 
     public Database.QueryLocator start(Database.BatchableContext info){ 
         String contactquery = '';
         String leadquery = '';
         String duplicateStr = 'Duplicate Email';

         Boolean isSoftSync;
         if(this.syncObject != null) {
            isSoftSync = !forFirstTime; 
         } else{
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            isSoftSync = adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c;
         }

         if(this.queryObject == 'Contact'){
             contactquery = 'SELECT Id, Owner.id, Owner.TelosTouchSF__TT_UserName__c,Owner.TelosTouchSF__TT_UserId__c,Owner.TelosTouchSF__Token__c, ';
             contactquery += 'CreatedBy.id, CreatedBy.TelosTouchSF__TT_UserName__c,CreatedBy.TelosTouchSF__TT_UserId__c,CreatedBy.TelosTouchSF__Token__c, LastModifiedDate, ';
             contactquery += 'TelosTouchSF__Error_Message__c, TelosTouchSF__Source__c, TelosTouchSF__TT_Client_Id__c, TelosTouchSF__TT_Conflict__c, TelosTouchSF__TT_LastSyncTime__c, ';
             String strContact ='Contact';
             String strAccountId = 'AccountId';
             for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                    FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                    WHERE TelosTouchSF__Object_Name__c =: strContact 
                                                                    AND TelosTouchSF__Salesforce_Field__c !=: strAccountId])
             {
                contactquery += fieldAPI.TelosTouchSF__Salesforce_Field__c + ',';
             }
             contactquery = contactquery.subString(0, contactquery.length() - 1);
             contactquery += ' FROM Contact WHERE TelosTouchSF__Error_Message__c !=: duplicateStr AND Email != null';
             contactquery += ' AND IsDeleted = false AND (Owner.TelosTouchSF__TT_UserId__c != NULL OR CreatedBy.TelosTouchSF__TT_UserId__c != null)';
             contactquery += ' AND TelosTouchSF__TT_Conflict__c = false';
             if(isSoftSync){ contactquery += ' AND TelosTouchSF__TT_Needs_Sync__c = true'; }
             contactquery += ' ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST ALL ROWS';
             return Database.getQueryLocator(String.escapeSingleQuotes(contactquery));
         }else{
             leadquery = 'SELECT Owner.id,';
             for(String fieldAPI : Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().keySet()){
                 if(fieldAPI != 'AccountId' ){
                     leadquery += fieldAPI + ','; 
                 }
             }
             leadquery = leadquery.subString(0, leadquery.length() - 1);
             leadquery += ' FROM Lead WHERE IsConverted = false AND TelosTouchSF__Error_Message__c !=: duplicateStr';
             leadquery += ' AND Email != null AND IsDeleted = false AND TelosTouchSF__TT_Conflict__c = false';
             if(isSoftSync){ leadquery += ' AND TelosTouchSF__TT_Needs_Sync__c = true'; }
             leadquery += ' ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST ALL ROWS';
             return Database.getQueryLocator(String.escapeSingleQuotes(leadquery).replace('\\',''));
         }
     }
                 /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ......
 * @param info ......
 * @param records ...
 */
     public void execute(Database.BatchableContext info,  List<Sobject> records){
         List<Contact> contactlist = new List<Contact>();
         List<Lead> leadlist = new List<Lead>();
         for(SObject sObjectIds : records){
             Schema.SObjectType entityType = sObjectIds.Id.getSobjectType();
             String objectName = String.valueOf(entityType);
             if(objectName == 'Contact' ){
                 contactlist.add((Contact)sObjectIds);
             }
             else if(objectName == 'Lead' ){
                 leadlist.add((Lead)sObjectIds);
             }
         }
         if((leadlist.size() > 0 ) || (contactlist.size() > 0)){ 
             SFDataSyncWithTelosTouch.clientLogWrapper clientLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(contactlist,leadlist,null, NULL, NULL, NULL);
             if(clientLogObj != null){
                 contactSuccessCount += clientLogObj.contactSuccessCount;
                 contactErrorCount += clientLogObj.contactErrorCount;
                 leadSuccessCount += clientLogObj.leadSuccessCount;
                 leadErrorCount += clientLogObj.leadErrorCount; 
             }
         }
       
     } 
                     /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ......
 * @param info ......
 */
     public void finish(Database.BatchableContext info){
        if(this.queryObject == 'Contact'){
            Database.executeBatch(new Batch_UpdateContactAndLead2(this.syncObject, this.forFirstTime, 'Lead'));
        }
         if(this.syncObject == null && this.queryObject == 'Lead'){
             Batch_SyncAllTaskWithTTActions taskBatch = new Batch_SyncAllTaskWithTTActions(null, null);
             Database.executeBatch((taskBatch),90);
         }
         if(contactErrorCount > 0){
             createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Contact sync records from Salesforce to TelosTouch','Échec de la Syncronisation des enregistrements entre Salesforce et TelosTouch',contactErrorCount));
         }
         if(contactSuccessCount > 0){
             createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Contact sync records from Salesforce to TelosTouch','Syncronisation réussie des Contacts de Salesforce à TelosTouch',contactSuccessCount));
         }
         if(leadErrorCount > 0){
             createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Lead sync records from Salesforce to TelosTouch','Échec de la syncronisation des prospects de Salesforce à TelosTouch',leadErrorCount));
         }
         if(leadSuccessCount > 0){
             createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Lead sync records from Salesforce to TelosTouch','Syncronisation réussie des Prospects de Salesforce à TelosTouch', leadSuccessCount));
         }
         if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
             insert createListOfLog;
         }
     }
 }