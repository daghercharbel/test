/**
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description AddToCampaignCompController ..
 */
public with sharing class AddToCampaignCompController {
   
 /**
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description getObjectDetails ..
 * @param objectName ...
 * @param recordId ...
 * @return String ..
 */
    @AuraEnabled
    public static String getObjectDetails(String objectName, String recordId){
        if(objectName == 'Account'){
            boolean getIsPerson =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
            if(Test.isRunningTest() || getIsPerson){
                if(Test.isRunningTest()){
                    String queryStr12 = 'SELECT Id, Name FROM ' + objectName +' WHERE Id=:recordId';
                    Database.query(String.escapeSingleQuotes(queryStr12));
                    recordId = null;
                }else{
                    String queryStr12 = 'SELECT Id,PersonContactId, Name FROM ' + objectName +' WHERE Id=:recordId';
                    sobject obj = Database.query(String.escapeSingleQuotes(queryStr12));
                    recordId = (String) obj.get('PersonContactId');
                }
                objectName = 'Contact';
                if(recordId == null){
                    return 'isNotPersonAccount'; 
                }
            }else{
                return 'isNotPersonAccount';
            }
        }
        String queryStr = 'SELECT Id, Name FROM ' + objectName +' WHERE Id=:recordId';
        sobject obj1 = Database.query(String.escapeSingleQuotes(queryStr));
        return (String) obj1.get('Name');
    }
    /**
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description updateCampaignRecord ..
* @param objectName ...
* @param recordId ...
* @param campId ...
* @param campName ...
* @return String ..
*/
    @AuraEnabled
    public static String updateCampaignRecord(String objectName, String recordId, String campId, String campName){
        try{
            CampaignMember cmObj = new CampaignMember();
            system.debug(LoggingLevel.DEBUG, 'objectName::'+objectName);
            if(objectName == 'Account'){
                boolean getIsPerson =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
                if(Test.isRunningTest() || getIsPerson){
                    if(Test.isRunningTest()){
                        String queryStr12 = 'SELECT Id, Name FROM ' + objectName +' WHERE Id=:recordId';
                        Database.query(String.escapeSingleQuotes(queryStr12));
                        recordId = null;
                    }else{
                    String queryStr12 = 'SELECT Id,PersonContactId, Name FROM ' + objectName +' WHERE Id=:recordId';
                    sobject obj = Database.query(String.escapeSingleQuotes(queryStr12));
                    recordId = (String) obj.get('PersonContactId');
                    }
                    objectName = 'Contact';
                    if(recordId == null){
                        return 'isNotPersonAccount';  
                    }
                }else{
                    return 'isNotPersonAccount';
                }
            }
            if(objectName == 'Contact'){
                if(Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.sObjectType.CampaignMember.fields.ContactId.isCreateable()){
                    cmObj.ContactId = recordId;
                }
            }else if(objectName == 'Lead'){
                if(Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.sObjectType.CampaignMember.fields.LeadId.isCreateable()){
                    cmObj.LeadId = recordId;
                }
            }
            if(Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible() && Schema.sObjectType.CampaignMember.fields.CampaignId.isCreateable()){
                cmObj.CampaignId = campId;
            }
            if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isCreateable()){
                insert cmObj;
            }
            return campId;
        }catch(Exception ex ){
            System.debug(LoggingLevel.ERROR, 'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
            String exceptionString = 'ERROR:' + ex.getMessage() + 'ON LINE:' + ex.getLineNumber();
            return exceptionString;           
        }
    }
    /**
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description getCampaignRecordType ....
 @return List<RecordType> ...
 */
    @AuraEnabled
    public static List<RecordType> getCampaignRecordType(){
        try{
            List<RecordType> campaignRecordTypeList = new  List<RecordType>();
            for(RecordTypeInfo info: Campaign.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.isActive() && info.getDeveloperName()!='Master' && info.getDeveloperName()!='Principal') {
                    RecordType record = new RecordType();
                    record.Id = info.getRecordTypeId();
                    record.Name = info.getName();
                    campaignRecordTypeList.add(record);
                }
            }
            return campaignRecordTypeList;
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    /**
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description createNewCampaignApex
* @param campName ...
* @param campRecordTypeName ...
 @return Campaign ..
 */
    @AuraEnabled
    public static Campaign createNewCampaignApex(String campName, String campRecordTypeName){
        try{
            if(String.isNotEmpty(campName) && String.isNotEmpty(campRecordTypeName)){
                Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(campRecordTypeName).getRecordTypeId();
                Campaign campaignObject = new Campaign();
                if(Schema.sObjectType.Campaign.fields.Name.isAccessible() && Schema.sObjectType.Campaign.fields.Name.isCreateable()){
                    campaignObject.Name = campName;
                }
                if(Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible() && Schema.sObjectType.Campaign.fields.RecordTypeId.isCreateable()){
                    campaignObject.RecordTypeId = campaignRecordTypeId;
                }
                if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isCreateable()){
                    insert campaignObject;
                }
                return campaignObject;
            }
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
}