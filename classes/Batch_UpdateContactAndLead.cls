/**
* @author Cloud Analogy
* @date 02/08/2021
*@description Batch_UpdateContactAndLead class is using to get all contact and lead records of the last one hour and calls another class for syncing.After finish, the job of another batch class is calling for task syncing.
*/
global with sharing class Batch_UpdateContactAndLead implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   public Integer contactSuccessCount = 0;
    public Integer contactErrorCount = 0;
    public Integer leadSuccessCount = 0;
    public Integer leadErrorCount = 0;
    public String syncObject;
    public Boolean forFirstTime;
    public List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description constructor......
* @param syncObject ......
* @param forFirstTime ...
*/
    public Batch_UpdateContactAndLead(String syncObject, Boolean forFirstTime){
        this.syncObject = syncObject;
        this.forFirstTime = forFirstTime;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param info ...
* @return SObject totallist ......
*/
    global List<SObject> start(Database.BatchableContext info){ 
        String contactquery = '';
        String leadquery = '';
        //List<lead> leadlist = new List<lead>(); 
        //List<Contact> contactlist = new List<Contact>();
        List<SObject> totallist = new List<SObject>();
        //String objectName = 'Contact';
        String duplicateStr = 'Duplicate Email';
        contactquery = 'SELECT Owner.id, Owner.TelosTouchSF__TT_UserName__c,Owner.TelosTouchSF__TT_UserId__c,Owner.TelosTouchSF__Token__c,  ';
        for(String fieldAPI : Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet()){
            if(fieldAPI != 'AccountId'){
                contactquery += fieldAPI + ',';
            }
        }
        contactquery = contactquery.subString(0, contactquery.length() - 1);
        contactquery += ' FROM Contact WHERE TelosTouchSF__Error_Message__c !=: duplicateStr AND Email != null AND IsDeleted = false AND (Owner.TelosTouchSF__TT_UserId__c != NULL OR CreatedBy.TelosTouchSF__TT_UserId__c != null) AND TelosTouchSF__TT_Conflict__c = false ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST ALL ROWS';
        contactquery = contactquery.removeEnd('WHERE');
        contactquery = contactquery.removeEnd('AND');
        totallist.addAll(Database.query(String.escapeSingleQuotes(contactquery)));
        leadquery = 'SELECT Owner.id,';
        for(String fieldAPI : Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().keySet()){
            if(fieldAPI != 'AccountId' ){
                leadquery += fieldAPI + ','; 
            }
        }
        leadquery = leadquery.subString(0, leadquery.length() - 1);
        leadquery += ' FROM Lead WHERE IsConverted = false AND TelosTouchSF__Error_Message__c !=: duplicateStr AND Email != null AND IsDeleted = false AND TelosTouchSF__TT_Conflict__c = false ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST ALL ROWS';
        leadquery = leadquery.removeEnd('WHERE');
        leadquery = leadquery.removeEnd('AND');
        //System.debug(String.escapeSingleQuotes(leadquery).replace('\\',''));
        totallist.addAll(Database.query(String.escapeSingleQuotes(leadquery).replace('\\','')));
        //System.debug('totallist>>'+totallist);
        /*for(sObject obj : totallist){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Record Id: '+obj.get('Id')+' queried in Client Batch',null,1));
        }*/
        return totallist;
    }
                /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param info ......
* @param records ...
*/
    global void execute(Database.BatchableContext info,  List<Sobject> records){
        List<Contact> contactlist = new List<Contact>();
        List<Lead> leadlist = new List<Lead>();
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        //List<Contact> contactlist2 = new List<Contact>();
        //List<Lead> leadlist2 = new List<Lead>();
        Boolean  returnValue;
        if(this.syncObject != null){
            returnValue = !forFirstTime;
        }else{
            returnValue = adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c;
        }
        if(returnValue){
            for(Integer i=0; i < records.size() ; i++){
                if( !((records[i].get('TelosTouchSF__TT_LastSyncTime__c') == null && records[i].get('TelosTouchSF__TT_Client_Id__c') == null)
                      || ( (Datetime)records[i].get('LastModifiedDate') > (Datetime)records[i].get('TelosTouchSF__TT_LastSyncTime__c'))) ){
                          records.remove(i);
                          --i;
                      }
            }
        }
        System.debug('records:: '+JSON.serialize(records));
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
        System.debug('contactlist:: '+JSON.serialize(contactlist));
        System.debug('leadlist:: '+JSON.serialize(leadlist));
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
    global void finish(Database.BatchableContext info){
        if(this.syncObject == null){
            Batch_SyncAllTaskWithTTActions taskBatch = new Batch_SyncAllTaskWithTTActions(null, null);
            Database.executeBatch((taskBatch),90);
        }
        if(contactErrorCount != 0 || contactSuccessCount != 0){
            //createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','No Contact records synced from Salesforce to TelosTouch','Aucun enregstrement de Contact syncronisé de Salesforce à TelosTouch',0));
      //  }else{
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Contact sync records from Salesforce to TelosTouch','Échec de la Syncronisation des enregistrements entre Salesforce et TelosTouch',contactErrorCount));
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Contact sync records from Salesforce to TelosTouch','Syncronisation réussie des Contacts de Salesforce à TelosTouch',contactSuccessCount));
        }
        if(leadErrorCount != 0 || leadSuccessCount != 0){
           // createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','No Lead records synced from Salesforce to TelosTouch','Aucune donnée de propect syncronisée de Salesforce à TelosTouch', 0));
       // }else{
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Failed Lead sync records from Salesforce to TelosTouch','Échec de la syncronisation des prospects de Salesforce à TelosTouch',leadErrorCount));
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Success','Successful Lead sync records from Salesforce to TelosTouch','Syncronisation réussie des Prospects de Salesforce à TelosTouch', leadSuccessCount));
        }
        if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
            insert createListOfLog;
        }
    }
}