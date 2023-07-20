/**
* @author Cloud Analogy
* @date 26/08/2021.
* @description batch post install class ....
*/
global with sharing class BatchPostInstallScript implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private static final TelosTouchSF__TelosTouch_API_Settings__c GETCREDENTIALS = TelosTouchSF__TelosTouch_API_Settings__c.getOrgDefaults();
    global String objectName ;
    /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description constructor...
* @param objName ...
*/
    global BatchPostInstallScript(String objName) {
        this.objectName = objName ;
    }
    /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description start method .....
* @param bc ...
@return Database.QueryLocator ..
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = '';
        if (objectName != NULL && (objectName == 'Contact' || objectName == 'Lead')) {
            queryString = 'SELECT Id, TelosTouchSF__Subscribed__c,TelosTouchSF__Language__c, TelosTouchSF__Source__c, TelosTouchSF__IsTelosTouchSyncAllowed__c,LastModifiedDate FROM ' + objectName+' WHERE TelosTouchSF__IsTelosTouchSyncAllowed__c = false ';
        }else{
             queryString = 'SELECT Id, TelosTouchSF__IsTelosTouchSyncAllowed__c,TelosTouchSF__TT_Category__c,LastModifiedDate FROM ' + objectName+' WHERE TelosTouchSF__IsTelosTouchSyncAllowed__c = false ';
        }
        return Database.getQueryLocator(String.escapeSingleQuotes(queryString));
    }
    /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description execute method ....
* @param bc ...
* @param sobjList ...
*/
    global void execute(Database.BatchableContext bc, List<SObject> sobjList) {
        if (sobjList != NULL && sobjList.size() > 0 && (objectName=='Contact' || objectName=='Lead') && (String.isEmpty(GETCREDENTIALS.TelosTouchSF__Instance_url__c) && GETCREDENTIALS.TelosTouchSF__Approval__c == false) ) {
            for (sobject sobj : sobjList) {
                if(objectName=='Contact'){
                    Contact con = new Contact();
                    con =  (Contact)sobj;
                }else{
                     Lead lead = new Lead();
                    lead =  (Lead)sobj;
                }
                sobj.put('TelosTouchSF__IsTelosTouchSyncAllowed__c', true);
                sobj.put('TelosTouchSF__Subscribed__c', 'Yes');
                sobj.put('TelosTouchSF__Source__c', 'Salesforce');
                sobj.put('TelosTouchSF__Language__c', 'English');
            }
            if(objectName == 'Contact'){
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isUpdateable()){
                    Database.update(sobjList, false);
                }  
            }else{
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable() ){
                    Database.update(sobjList, false);
                }   
            }
        }else if (sobjList != NULL && sobjList.size() > 0 && objectName=='Task' ){
            for (sobject sobj : sobjList) {
                Task task = new Task();
                task =  (Task)sobj;
                sobj.put('TelosTouchSF__IsTelosTouchSyncAllowed__c', true);
                sobj.put('TelosTouchSF__TT_Category__c','task');
            } 
            if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isUpdateable() ){
                Database.update(sobjList, false);
            }
        }
    }
    /**
* @author Cloud Analogy
* @date 26/08/2021
* @description finish method ...
* @param bc ...
*/
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
}