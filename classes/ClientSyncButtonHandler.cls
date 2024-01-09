public with sharing class ClientSyncButtonHandler {
    @AuraEnabled
    public static Map<String, String> getFeatureMetadataBasedOnId(Id recordId) {
        Map<String, String> metadataMap = new Map<String, String>();
        try {
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            String recName = (sObjName == 'Contact' ? 'Contact_Syncing' : 'Lead_Syncing');
            metadataMap = TelosTouchSF.TT_FeatureSettingsController.getFeatureMetadata(recName);
            return metadataMap;
        } catch (Exception e) {
            return metadataMap;
        }
   }

   @AuraEnabled
   public static String getRecordInfo(Id recordId){
    try {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT Id, ';
        String duplicateStr = 'Duplicate Email';
        query += 'TelosTouchSF__Error_Message__c, Email, IsDeleted, CreatedBy.TelosTouchSF__TT_UserId__c, TelosTouchSF__TT_Conflict__c'; 
        query +=  sObjName == 'Contact' ? ', Owner.TelosTouchSF__TT_UserId__c FROM' : ' FROM';
        query += sObjName == 'Contact' ? ' Contact' : ' Lead';
        List<sObject> sObjectList = Database.query(query);
        return JSON.serialize(sObjectList);
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }

   @AuraEnabled
   public static Boolean syncRecordBasedOnRecId(Id recordId){
    try {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        List<Contact> contactList = new List<Contact>();
        List<Lead> leadList = new List<Lead>();
        String query = '';
        if(sObjName == 'Contact'){
            query = 'SELECT Id, Owner.id, Owner.TelosTouchSF__TT_UserName__c,Owner.TelosTouchSF__TT_UserId__c,Owner.TelosTouchSF__Token__c, ';
            query += 'CreatedBy.id, CreatedBy.TelosTouchSF__TT_UserName__c,CreatedBy.TelosTouchSF__TT_UserId__c,CreatedBy.TelosTouchSF__Token__c, LastModifiedDate, ';
            query += 'TelosTouchSF__Error_Message__c, TelosTouchSF__Source__c, TelosTouchSF__TT_Client_Id__c, TelosTouchSF__TT_Conflict__c, TelosTouchSF__TT_LastSyncTime__c, ';
            String strContact ='Contact';
            String strAccountId = 'AccountId';
            for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                   FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                   WHERE TelosTouchSF__Object_Name__c =: strContact 
                                                                   AND TelosTouchSF__Salesforce_Field__c !=: strAccountId WITH SECURITY_ENFORCED])
            {
                query += fieldAPI.TelosTouchSF__Salesforce_Field__c + ',';
            }
            query = query.subString(0, query.length() - 1);
            query += ' FROM Contact';
            contactList = Database.query(query);
        }else{
            query = 'SELECT Owner.id,';
            for(String fieldAPI : Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().keySet()){
                if(fieldAPI != 'AccountId' ){
                    query += fieldAPI + ','; 
                }
            }
            query = query.subString(0, query.length() - 1);
            query += ' FROM Lead';
            leadList = Database.query(query);
        }
        TelosTouchSF.SFDataSyncWithTelosTouch.clientLogWrapper clientLogObj;
        if(contactList.size() > 0 || leadList.size() > 0){
            if(sObjName == 'Contact'){
                clientLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(contactList, null, null, NULL, NULL, NULL);
            }else{
                clientLogObj = TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(null, leadList, null, NULL, NULL, NULL);
            }
        }
        return clientLogObj.contactSuccessCount > 0;
    } catch (Exception e) {
        System.debug(' Error is: '+ e.getMessage() + ' at line '+ e.getLineNumber());
        throw new AuraHandledException(e.getMessage() + ' at line '+ e.getLineNumber());
    }
   }
}