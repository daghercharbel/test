/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TelosTouchMapping class is used to create and get fields mapping object records.
*/
public with sharing class TelosTouchMapping {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the all the TT fields.
* @return FieldWrapper fieldlist ....
*/
    @AuraEnabled 
    public static List<FieldWrapper> getTelosTouchFields(){
        try{
            List<TelosTouchSF__TT_Salesforce_Mapping__c> ttMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            ttMappingList = [SELECT Id, TelosTouchSF__TT_Field__c, TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Is_Deleted__c = false AND TelosTouchSF__Object_Name__c = 'Contact' AND TelosTouchSF__TT_Field__c != 'Custom Fields' WITH SECURITY_ENFORCED LIMIT 5000];
            List<FieldWrapper>  fieldlist = new List<FieldWrapper>();
            Map<String, Integer> myMap = new Map<String, Integer>();
            if(ttMappingList != null && ttMappingList.size()>0){
                for(Integer i=0; i<ttMappingList.size(); i++){
                    myMap.put(ttMappingList[i].TelosTouchSF__TT_Field__c, (i+1));
                }
            }
            List<String> orderingList = new List<String>();
            orderingList.addAll(myMap.keyset());
            orderingList.sort();  
            for(String key : orderingList){
                FieldWrapper wp = new FieldWrapper();
                wp.fieldAPINameTT = key;
                String[] r = key.capitalize().split('(?=\\p{Upper})');
                wp.fieldNameTT = string.join(r,' ');
                fieldlist.add(wp);
            }
            return fieldlist;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @return FieldWrapper fieldlist ....
*/
    @AuraEnabled
    public static List<FieldWrapper> getTelosTouchLeadFields(){
        try{
            List<TelosTouchSF__TT_Salesforce_Mapping__c> ttMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            ttMappingList = [SELECT Id, TelosTouchSF__TT_Field__c, TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Is_Deleted__c = false AND TelosTouchSF__Object_Name__c = 'Lead' AND TelosTouchSF__TT_Field__c != 'Custom Fields' WITH SECURITY_ENFORCED LIMIT 5000];
            List<FieldWrapper>  fieldlist = new List<FieldWrapper>();
            Map<String, Integer> myMap = new Map<String, Integer>();
            if(ttMappingList != null && ttMappingList.size()>0){
                for(Integer i=0; i<ttMappingList.size(); i++){
                    myMap.put(ttMappingList[i].TelosTouchSF__TT_Field__c, (i+1));
                }
            }
            List<String> orderingList = new List<String>();
            orderingList.addAll(myMap.keyset());
            orderingList.sort();
            for(String key : orderingList){
                FieldWrapper wp = new FieldWrapper();
                wp.fieldAPINameTT = key;
                String[] r = key.capitalize().split('(?=\\p{Upper})');
                wp.fieldNameTT = string.join(r,' ');
                fieldlist.add(wp);
            }
            return fieldlist;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the all the TT task fields.
* @return FieldWrapper fieldlist ....
*/
    @AuraEnabled 
    public static List<FieldWrapper> getTelosTouchTaskFields(){
        try{
            List<TelosTouchSF__TT_Salesforce_Mapping__c> ttMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            ttMappingList = [SELECT Id, TelosTouchSF__TT_Field__c, TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Is_Deleted__c = false AND TelosTouchSF__Object_Name__c = 'Task' AND TelosTouchSF__TT_Field__c != 'Custom Fields' WITH SECURITY_ENFORCED LIMIT 5000];
            List<FieldWrapper>  fieldlist = new List<FieldWrapper>();
            Map<String, Integer> myMap = new Map<String, Integer>();
            if(ttMappingList != null && ttMappingList.size()>0){
                for(Integer i=0; i<ttMappingList.size(); i++){
                    myMap.put(ttMappingList[i].TelosTouchSF__TT_Field__c, (i+1));
                }
            }
            List<String> orderingList = new List<String>();
            orderingList.addAll(myMap.keyset());
            orderingList.sort();
            for(String key : orderingList){
                FieldWrapper wp = new FieldWrapper();
                wp.fieldAPINameTT = key;
                wp.fieldNameTT = key.replaceAll('[^a-zA-Z0-9\\s+]', ' ').capitalize();
                fieldlist.add(wp);   
            }
            return fieldlist;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets all the fields of objects.
* @param selectedObjectName stores the name of selected object.
* @return FieldWrapper fieldlist ....
*/
    @AuraEnabled
    public static List<FieldWrapper> getObjectAllFields(String selectedObjectName){
        List<FieldWrapper>  fieldlist = new List<FieldWrapper>();
        String sObjectApiName = selectedObjectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
        Map<String, String> returnMap = new Map<String, String>();

        if(adminCredentials.TelosTouchSF__RestrictedTTFieldMapping__c != null){
            String restrictedFields = adminCredentials.TelosTouchSF__RestrictedTTFieldMapping__c;
            List<String> restrictedFieldsList = restrictedFields.split(',');
            List<String> restrictedFieldsList2 = new List <String>();
            for(String restrictedField : restrictedFieldsList){
                restrictedFieldsList2.add(restrictedField.trim());
            }
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(restrictedFieldsList2.size() ==0){
                    returnMap.put(dfield.getLabel(),dfield.getName());
                }else if(!restrictedFieldsList2.contains(dfield.getName())){
                    returnMap.put(dfield.getLabel(),dfield.getName());
                }
            }
        }else{
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                returnMap.put(dfield.getLabel(),dfield.getName());
            }
        }
        
        List<String> orderingList = new List<String>();
        orderingList.addAll(returnMap.keyset());
        orderingList.sort();
        for(String key : orderingList){
            FieldWrapper wObj = new FieldWrapper();
            if(returnMap.get(key) == 'TelosTouchSF__TT_Category__c'){
                wObj.fieldName = 'Category'; 
            }else{
                wObj.fieldName = key;
            }
            wObj.fieldAPIName = returnMap.get(key);
            fieldlist.add(wObj);
        }
        return fieldlist;
    } 
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets all the fields of objects.
* @param selectedObject returns the selected object.
* @return SObject mappingList ....
*/
    @AuraEnabled
    public static List<SObject> getExistingMappingApex(String selectedObject) {
        try{
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable()){
                List<TelosTouchSF__TT_Salesforce_Mapping__c> mappingList = [SELECT Id, Name, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__Object_Name__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: selectedObject AND TelosTouchSF__Is_Deleted__c = false];
                return mappingList;
            }
        } 
        catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method inserts TT object new field list.
* @param mappingList stores the TT salesforce mapping list.
* @param selectedObject gets the selected object.
* @return Boolean true ....
*/
    @AuraEnabled
    public static Boolean saveFieldsMappingApex(List<TelosTouchSF__TT_Salesforce_Mapping__c> mappingList, String selectedObject) {
        try{
            if(mappingList !=null && selectedObject!=null ){
                if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() && TelosTouchSF__TT_Salesforce_Mapping__c.sObjectType.getDescribe().isDeletable()  ){
                    delete [SELECT Id FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Is_Deleted__c=false AND TelosTouchSF__Object_Name__c =: selectedObject];
                }
                List<TelosTouchSF__TT_Salesforce_Mapping__c> ttObjNewList = New List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                for(TelosTouchSF__TT_Salesforce_Mapping__c ttObj : mappingList){
                    TelosTouchSF__TT_Salesforce_Mapping__c ttObjNew = New TelosTouchSF__TT_Salesforce_Mapping__c();
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable()){
                        ttObjNew.TelosTouchSF__Salesforce_Field__c = ttObj.TelosTouchSF__Salesforce_Field__c;
                    }
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable()){
                        ttObjNew.TelosTouchSF__TT_Field__c = ttObj.TelosTouchSF__TT_Field__c;
                    }
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                        ttObjNew.TelosTouchSF__Object_Name__c = selectedObject;
                    }
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Sync_Empty_Field__c.isCreateable()){
                        ttObjNew.TelosTouchSF__Is_Sync_Empty_Field__c = ttObj.TelosTouchSF__Is_Sync_Empty_Field__c;
                    }
                    ttObjNewList.add(ttObjNew);
                }
                if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() ){
                    insert ttObjNewList;
                }
                return true;
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());        }
        return false;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method inserts TT object new field list.
* @param Selectedfieldslist gets the list of selected fields.
* @param objectName gets the name of the object.
* @return Boolean true ....
*/
    @AuraEnabled
    public static Boolean sendCustomFieldsSFToTT(List<String> Selectedfieldslist, String objectName) {
        try{
            if(Selectedfieldslist.size() >0){
                List<String> labellist = new List<String>();
                List<TelosTouchSF__TT_Salesforce_Mapping__c> customMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                for(String selectedField : Selectedfieldslist){
                    labellist.add(selectedField);
                    TelosTouchSF__TT_Salesforce_Mapping__c mappingCustomFields = new TelosTouchSF__TT_Salesforce_Mapping__c();
                    if(Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                        mappingCustomFields.TelosTouchSF__Object_Name__c = objectName;
                    }
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable()){
                        mappingCustomFields.TelosTouchSF__TT_Field__c = 'Custom Fields';
                    }
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable()){
                        mappingCustomFields.TelosTouchSF__Salesforce_Field__c = selectedField;
                    }
                    customMappingList.add(mappingCustomFields);
                } 
                if((labellist.size() > 0) && (labellist != null)){
                    String jsonMap = JSON.serialize(labellist);         
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    if(adminCredentials != null){
                        if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)){
                            request.setEndpoint(adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/settings/touchpoint.custom.fields');
                        }
                        if(String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c)){
                            request.setHeader('Authorization', 'Bearer '+ authenticationCredential.TelosTouchSF__Access_Token__c);
                        }
                        request.setMethod('PUT');
                        request.setHeader('Content-Type', 'application/json'); 
                        request.setHeader('Accept', 'application/json');
                    }
                    request.setBody(jsonMap);
                    request.setTimeout(45000);
                    HttpResponse response = http.send(request);
                    if (response.getStatusCode() == 200) {
                        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible()){
                            insert customMappingList;
                        }                        
                        return true;
                    } 
                    else {  
                        return false;
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());        }
        return false;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method deletes custom fields.
* @param selectedfieldslist gets the list of selected fields.
* @param objectName gets the name of the object.
* @return Boolean true ....
*/
    @AuraEnabled
    public static Boolean deleteCustomFields(List<String> selectedfieldslist, String objectName) {
        try{
            Boolean flag = false;
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable()){
                if(selectedfieldslist.size() > 0){
                    List<TelosTouchSF__TT_Salesforce_Mapping__c> fetchedFields = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                    List<TelosTouchSF__TT_Salesforce_Mapping__c> mappingDeleteList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.Id.isAccessible() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible()){
                           fetchedFields = [SELECT Id, TelosTouchSF__Is_Deleted__c, TelosTouchSF__TT_Field__c,TelosTouchSF__Object_Name__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: objectName AND TelosTouchSF__Is_Deleted__c = false AND ((TelosTouchSF__Salesforce_Field__c =:selectedfieldslist AND TelosTouchSF__TT_Field__c = 'Custom Fields' ) OR TelosTouchSF__TT_Field__c =:selectedfieldslist) LIMIT 5000 ];
                       } 
                    if((fetchedFields.size()>0)&& (fetchedFields != null)){
                        for(TelosTouchSF__TT_Salesforce_Mapping__c each : fetchedFields) {
                            if(each.TelosTouchSF__TT_Field__c == 'Custom Fields'){
                                mappingDeleteList.add(each);
                            }
                            else{
                                each.TelosTouchSF__Is_Deleted__c = true;
                            }
                        }
                        if (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isUpdateable() &&
                            Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() &&
                                TelosTouchSF__TT_Salesforce_Mapping__c.sObjectType.getDescribe().isUpdateable() &&
                            fetchedFields.size()>0) {
                                update fetchedFields;
                                flag = true;
                            }
                        if (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isDeletable() &&
                            Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() &&
                                TelosTouchSF__TT_Salesforce_Mapping__c.sObjectType.getDescribe().isDeletable() &&
                            mappingDeleteList.size()>0) {
                                delete mappingDeleteList;
                                flag = true;
                            }
                        return flag;
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            return false;
        }
        return false;
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @return TT_Salesforce_Mapping__c fetchedFields ....
*/  
    @AuraEnabled
    public static List<TelosTouchSF__TT_Salesforce_Mapping__c> addingStandardFields() {
        try{
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable()){
                List<TelosTouchSF__TT_Salesforce_Mapping__c> fetchedFields = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                   Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible()){
                       fetchedFields = [SELECT TelosTouchSF__TT_Field__c,TelosTouchSF__Is_Deleted__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Is_Deleted__c=false LIMIT 50000 ];
                   }
                return fetchedFields;
            }            
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            return null;
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param objectName ....
* @return DeletedMappingsWrapper mappingsWrapperList ....
*/
    @AuraEnabled
    public static List<DeletedMappingsWrapper> populateDeletedFieldsApex(String objectName){
        try{
            List<DeletedMappingsWrapper> mappingsWrapperList = new List<DeletedMappingsWrapper>();
            List<TelosTouchSF__TT_Salesforce_Mapping__c> mappingList = new List<TT_Salesforce_Mapping__c>();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.Id.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible()){
                   mappingList = [SELECT Id, TelosTouchSF__TT_Field__c,TelosTouchSF__Salesforce_Field__c,TelosTouchSF__Object_Name__c,TelosTouchSF__Is_Deleted__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: objectName AND TelosTouchSF__Is_Deleted__c=true LIMIT 5000];
               }
            if(mappingList.size()>0 && mappingList!=null){
                for(TelosTouchSF__TT_Salesforce_Mapping__c each : mappingList){
                    DeletedMappingsWrapper mappingObj = new DeletedMappingsWrapper();
                    mappingObj.label = each.TelosTouchSF__TT_Field__c;
                    mappingObj.value = each.Id;
                    mappingObj.sfField = each.TelosTouchSF__Salesforce_Field__c;
                    mappingsWrapperList.add(mappingObj);
                }
                return mappingsWrapperList;
            }
            else{
                return null;
            }
        }catch (Exception e){
            System.debug(LoggingLevel.WARN,e.getMessage()+' Occurred at Line Number: '+e.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param mappingIdStr ....
* @return Boolean true ....
*/
    @AuraEnabled
    public static Boolean addDeletedFieldsToMappingApex(String mappingIdStr){
        try{
            System.debug(LoggingLevel.DEBUG, 'mappingIdStr:: '+mappingIdStr);
            String formattedString = mappingIdStr.removeStart('["').removeEnd('"]');
            List<String> mappingIdList = formattedString.contains(',')?formattedString.split(','):new List<String>{formattedString};
                System.debug(LoggingLevel.DEBUG, 'mappingIdList:: '+mappingIdList);
                if(mappingIdList!=null && mappingIdList.size()>0){
                    List<TelosTouchSF__TT_Salesforce_Mapping__c> mappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
                    if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                       Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible()){
                           System.debug(LoggingLevel.DEBUG, 'If Ran!');
                           mappingList = [SELECT Id, TelosTouchSF__Is_Deleted__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE Id IN :mappingIdList WITH SECURITY_ENFORCED LIMIT 5000];
                       }
                    System.debug(LoggingLevel.DEBUG, 'mappingList:: '+mappingList);
                    if(mappingList!=null && mappingList.size()>0){
                        for(TelosTouchSF__TT_Salesforce_Mapping__c each : mappingList){
                            each.TelosTouchSF__Is_Deleted__c = false;
                        }
                        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isUpdateable()){
                            update mappingList;
                        }
                        return true;
                    }
                }
        }
        catch (Exception e){
            System.debug(LoggingLevel.WARN,e.getMessage()+' Occurred at Line Number: '+e.getLineNumber());
            return false;
        }
        return false;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param flag ....
* @return Boolean true ....
*/
    @AuraEnabled
     public static Boolean setUseCreatedByIdFlag(Boolean flag){
         TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
         adminCredentials.TelosTouchSF__Use_CreatedById__c = flag;
         System.enqueueJob(new UpdateCustomMetadataQueueable(adminCredentials, authenticationCredential));
         return true;
     }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @return Boolean ....
*/
     @AuraEnabled
     public static Boolean getUseCreatedByIdFlag(){
         TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
         return adminCredentials.TelosTouchSF__Use_CreatedById__c;
     }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public class DeletedMappingsWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String label { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String value { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String sfField { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description FieldWrapper is used to get fieldName,fieldAPIName,fieldNameTT and fieldAPINameTT.
*/    
    public class FieldWrapper { 
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String fieldName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String fieldAPIName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String fieldNameTT { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String fieldAPINameTT { get; set; }
    }
}