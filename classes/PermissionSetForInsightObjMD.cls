/**
* @author Cloud Analogy
* @date 02/08/2021
* @description PermissionSetForInsightObjMD class .
*/
public with sharing class PermissionSetForInsightObjMD {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Controller of the MultiObjectLookupController class .
   * @param permissionSetName ......
   * @param permissionSetLabel ......
*/
    public void createPermissionSet(String permissionSetName, String permissionSetLabel){
        try{
            String permSetId = '';
            List<PermissionSet> getPermissionSetList = new  List<PermissionSet>();
            if(Schema.sObjectType.PermissionSet.isAccessible() && Schema.sObjectType.PermissionSet.isQueryable() &&
              Schema.sObjectType.PermissionSet.fields.Id.isAccessible() && Schema.sObjectType.PermissionSet.fields.Name.isAccessible()){
                getPermissionSetList = [SELECT Id,Name FROM PermissionSet WHERE Name = 'TTPSetForInsightObjMDRelations' LIMIT 1];
                if(getPermissionSetList.size() >0){
                    permSetId = getPermissionSetList[0].Id;
                }else{
                    if(Schema.sObjectType.PermissionSet.isAccessible() && Schema.sObjectType.PermissionSet.isCreateable()){
                        PermissionSet pr = new PermissionSet(Name = +permissionSetName,Label = +permissionSetLabel);
                        getPermissionSetList.add(pr);
                        insert getPermissionSetList;
                        permSetId  = getPermissionSetList[0].Id;
                    }  
                }
            }
            List<ObjectPermissions> op = new List<ObjectPermissions>();
            Map<String, String> existOP = new Map<String, String>();
            if( Schema.sObjectType.ObjectPermissions.isAccessible() && Schema.sObjectType.ObjectPermissions.isQueryable() && 
               Schema.sObjectType.ObjectPermissions.fields.SObjectType.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.ID.isAccessible() && 
               Schema.sObjectType.ObjectPermissions.fields.ParentID.isAccessible()){
                op = [SELECT ID, SObjectType, ParentID FROM ObjectPermissions WHERE ParentId = :permSetId];
                for (ObjectPermissions eop : op){
                    String objname = eop.SobjectType;
                    String objid = eop.Id;
                    existOP.put(objname, objid);
                }
            }
            List<ObjectPermissions> objPerms = new List<ObjectPermissions>();
            Map<String, List<Boolean>> objectsAndCRUD = new Map<String, List<Boolean>>();
            List<Map<String, List<Boolean>>> objectsAndCRUDcollection = new List <Map<String, List<Boolean>>>();  
            Map<String, String> existFP = new Map<String, String>();
            List<FieldPermissions> fp = new List<FieldPermissions>();
            if( Schema.sObjectType.FieldPermissions.isAccessible() && Schema.sObjectType.FieldPermissions.isQueryable() && 
               Schema.sObjectType.FieldPermissions.fields.SObjectType.isAccessible() && 
               Schema.sObjectType.FieldPermissions.fields.ID.isAccessible() && 
               Schema.sObjectType.FieldPermissions.fields.ParentID.isAccessible() && 
               Schema.sObjectType.FieldPermissions.fields.Field.isAccessible()){
                   fp = [SELECT ID, SObjectType, Field, ParentID FROM FieldPermissions WHERE ParentId = :permSetId];
                   for (FieldPermissions efp : fp){
                       String fldname = efp.Field;
                       String fldid = efp.Id;
                       existFP.put(fldname, fldid);
                   }
               }
            List<FieldPermissions> fieldPerms = new List<FieldPermissions>();
            Map<String, List<Boolean>> fieldsAndCRUD = new Map<String, List<Boolean>>();
            List<Map<String, List<Boolean>>> fieldsAndFSLcollection = new List <Map<String, List<Boolean>>>();
            objectsAndCRUD.put('Campaign', new List<Boolean>{True, True, True, True});
            objectsAndCRUD.put('Contact', new List<Boolean>{True, True, True, True});
            objectsAndCRUD.put('Lead', new List<Boolean>{True, True, True, True});

            objectsAndCRUDcollection.add(objectsAndCRUD);

            fieldsAndCRUD.put('Lead.TelosTouchSF__TT_Last_Login__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Error_Message__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__isDeletedFromTT__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__IsTelosTouchSyncAllowed__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Language__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Last_Login__c', new List<Boolean>{True, false,false, false});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Source__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Subscribed__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__Synced__c', new List<Boolean>{True, false,false, false});
            fieldsAndCRUD.put('Lead.TelosTouchSF__TT_Client_Id__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.TelosTouchSF__TT_UserId__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.Email', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Lead.Phone', new List<Boolean>{True, True,True, True});
 
            fieldsAndCRUD.put('Contact.TelosTouchSF__TT_Last_Login__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Error_Message__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__isDeletedFromTT__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__IsTelosTouchSyncAllowed__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Language__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Last_Login__c', new List<Boolean>{True, false,false, false});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Source__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Subscribed__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__Synced__c', new List<Boolean>{True, false,false, false});
            fieldsAndCRUD.put('Contact.TelosTouchSF__TT_Client_Id__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.TelosTouchSF__TT_UserId__c', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.Email', new List<Boolean>{True, True,True, True});
            fieldsAndCRUD.put('Contact.Phone', new List<Boolean>{True, True,True, True});
            

            fieldsAndFSLcollection.add(fieldsAndCRUD);
            logicPerms(objectsAndCRUD, getPermissionSetList[0], existOP, objPerms, existFP, fieldsAndCRUD, fieldPerms);    
        }catch (Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Controller of the MultiObjectLookupController class .
* @param objectsAndCRUD ......
* @param pr ......
* @param existOP ......
* @param objPerms ......
* @param existFP ......
* @param fieldsAndCRUD ......
* @param fieldPerms ......
*/
    public void logicPerms(Map<String, List<Boolean>> objectsAndCRUD, PermissionSet pr, 
                           Map<String, String> existOP, List<ObjectPermissions> objPerms,  
                           Map<String, String> existFP, Map<String, List<Boolean>> fieldsAndCRUD, 
                           List<FieldPermissions> fieldPerms)
    {      
        for(String objectName :objectsAndCRUD.keySet()) {
            if(Schema.sObjectType.ObjectPermissions.fields.PermissionsRead.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.PermissionsRead.isCreateable() 
               && Schema.sObjectType.ObjectPermissions.fields.PermissionsRead.isUpdateable() &&
              Schema.sObjectType.ObjectPermissions.fields.PermissionsCreate.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.PermissionsCreate.isCreateable() 
               && Schema.sObjectType.ObjectPermissions.fields.PermissionsCreate.isUpdateable() &&
              Schema.sObjectType.ObjectPermissions.fields.PermissionsEdit.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.PermissionsEdit.isCreateable() 
               && Schema.sObjectType.ObjectPermissions.fields.PermissionsEdit.isUpdateable() &&
              Schema.sObjectType.ObjectPermissions.fields.PermissionsModifyAllRecords.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.PermissionsModifyAllRecords.isCreateable() 
               && Schema.sObjectType.ObjectPermissions.fields.PermissionsModifyAllRecords.isUpdateable() &&
              Schema.sObjectType.ObjectPermissions.fields.PermissionsViewAllRecords.isAccessible() && Schema.sObjectType.ObjectPermissions.fields.PermissionsViewAllRecords.isCreateable() 
               && Schema.sObjectType.ObjectPermissions.fields.PermissionsViewAllRecords.isUpdateable()){
            ObjectPermissions objPermission = new ObjectPermissions();
            objPermission.ParentId = pr.Id;
            objPermission.SobjectType = objectName;
            objPermission.PermissionsRead = False;
            objPermission.PermissionsCreate = False;
            objPermission.PermissionsEdit = False;
            objPermission.PermissionsDelete = False;

            if(objectName == 'Contact' || objectName == 'Lead' || objectName == 'Campaign' ){
                objPermission.PermissionsModifyAllRecords = false;
                objPermission.PermissionsViewAllRecords =  false;
            }else{
                objPermission.PermissionsViewAllRecords =  True;
            }
                
            if (existOP.get(objectName) != null){
                objPermission.Id = existOP.get(objectName);
            }if (objectsAndCRUD.get(objectName)[0] == True) {
                objPermission.PermissionsRead = true;
            }if (objectsAndCRUD.get(objectName)[1] == True) {
                objPermission.PermissionsCreate = true;
            }if (objectsAndCRUD.get(objectName)[2] == True) {
                objPermission.PermissionsEdit = true;
            }if (objectsAndCRUD.get(objectName)[3] == True) {
                objPermission.PermissionsDelete = true;
            }
            objPerms.add(objPermission);	
            }
        }        
        for(String fieldName :fieldsAndCRUD.keySet()) {
            if(Schema.sObjectType.FieldPermissions.fields.PermissionsRead.isAccessible() && Schema.sObjectType.FieldPermissions.fields.PermissionsRead.isCreateable() 
               && Schema.sObjectType.FieldPermissions.fields.PermissionsRead.isUpdateable() &&
               Schema.sObjectType.FieldPermissions.fields.PermissionsEdit.isAccessible() && Schema.sObjectType.FieldPermissions.fields.PermissionsEdit.isCreateable() 
               && Schema.sObjectType.FieldPermissions.fields.PermissionsEdit.isUpdateable() ){
                   FieldPermissions fldPermission = new FieldPermissions();
                   fldPermission.ParentId = pr.Id;
                   fldPermission.SobjectType = fieldName.substringBefore('.');
                   fldPermission.Field = fieldName;
                   fldPermission.PermissionsRead = False;
                   fldPermission.PermissionsEdit = False;
                   if (existFP.get(fieldName) != null){
                       fldPermission.Id = existFP.get(fieldName);
                   }if (fieldsAndCRUD.get(fieldName)[0] == True) {
                       fldPermission.PermissionsRead = true;
                   }if (fieldsAndCRUD.get(fieldName)[1] == True) {
                       fldPermission.PermissionsEdit = true;
                   }
                   fieldPerms.add(fldPermission);	
               }
        }if(Schema.sObjectType.ObjectPermissions.isAccessible() && Schema.sObjectType.ObjectPermissions.isCreateable() && Schema.sObjectType.ObjectPermissions.isUpdateable()){
            if(objPerms.size() >0){
                upsert objPerms;     
            }
        }
        if(Schema.sObjectType.FieldPermissions.isAccessible() && Schema.sObjectType.FieldPermissions.isCreateable() && Schema.sObjectType.FieldPermissions.isUpdateable()){
            if(fieldPerms.size() >0){
                upsert fieldPerms;
            }
        }
    }
    
    
}