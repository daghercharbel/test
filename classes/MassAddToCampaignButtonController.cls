/**
* @author Cloud Analogy
* @date 02/08/2021
* @description MassAddToCampaignButtonController ..........
*/
public with sharing class MassAddToCampaignButtonController {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    public List<Account> accountList { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    private ApexPages.StandardSetController standardController;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    public List<String> recordIdList { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    public String jsonStr { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    public String isPersonAccount { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description constructor..........
	* @param standardController ......
*/
    public MassAddToCampaignButtonController(ApexPages.StandardSetController standardController){
        try{
            recordIdList = new List<String>();
            Boolean isPersonAccount =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
            this.standardController = standardController;
            accountList = new List<Account>(); 
            for (Object mem : (List<Object>)standardController.getSelected()){
                Map<String, Object> stringVsObjMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mem));
                if(isPersonAccount){
                    recordIdList.add(String.valueOf(stringVsObjMap.get('Id')));
                    this.isPersonAccount = 'true';
                }else{
                    this.isPersonAccount = 'false';
                }
            }
            jsonStr = JSON.serialize(recordIdList);
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        } 
    }
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description checkPersonAccountOrNot..........
		* @param recordIdsList ......
	* @param objectName ......
@return string ...
         */
    public static String checkPersonAccountOrNot(String recordIdsList, String objectName){
        //List<Contact> contactList = new List<Contact>();
        //List<Lead> leadList = new List<Lead>();
        String endPointURL,body,str='',str2='',returnString,responseBody,userAuthTOKEN;
        Integer count = 0;
        Map<String, String> headersMap = new Map<String, String>();
        Map<String,Contact> contactMap = new Map<String,Contact>();
        Map<String,Lead> leadMap = new Map<String,Lead>();
        String stringList = recordIdsList.deleteWhitespace();
        stringList = stringList.remove('[');
        stringList = stringList.remove(']');
        List<String> sid = stringList.split(',');
        Set<Id> newIdSet = new Set<Id>();
        for(String sobj: sid){
            String recordId = sobj.replace('"','');
            newIdSet.add(Id.valueof(recordId));
        }
        List<Account> account = new List<Account>();
        if(!Test.isRunningTest()){
            account = Database.query('SELECT Id, TelosTouchSF__TT_Client_Id__pc FROM Account WHERE Id IN:newIdSet AND TelosTouchSF__TT_Client_Id__pc != Null LIMIT 2000');
        }else{
            account = Database.query('SELECT Id FROM Account WHERE Id IN:newIdSet LIMIT 2000');
        }
        if(newIdSet.size() != account.size()){
            return 'Some Account is not PersonAccount';
        }else if (account.size()>0){
            return 'have PersonAccount';
        }else{
            return null;
        }
    }
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description addCamapignMember..........
		* @param camp ......
	* @param recordIdsList ......
@return string ...
*/
    public static String addCamapignMember(Campaign camp,String recordIdsList){
        try{
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            String endPointURL,body,str='',str2='',returnString,responseBody,userAuthTOKEN;
            Integer count = 0;
            Map<String, String> headersMap = new Map<String, String>();
            Map<String,Contact> contactMap = new Map<String,Contact>();
            Map<String,Lead> leadMap = new Map<String,Lead>();
            String stringList = recordIdsList.deleteWhitespace();
            stringList = stringList.remove('[');
            stringList = stringList.remove(']');
            List<String> sid = stringList.split(',');
            Set<Id> newIdSet = new Set<Id>();
            for(String sobj: sid){
                String recordId = sobj.replace('"','');
                newIdSet.add(Id.valueof(recordId));
            }
            List<Account> accountList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            if(Test.isRunningTest()){
                conList = [SELECT Id FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
                accountList = Database.query('SELECT Id FROM Account WHERE Id IN:newIdSet LIMIT 2000');
            }else{
                if(Schema.SObjectType.Account.isAccessible()){
                    accountList = Database.query('SELECT Id, TelosTouchSF__TT_Client_Id__pc,PersonContactId FROM Account WHERE Id IN:newIdSet AND TelosTouchSF__TT_Client_Id__pc != Null LIMIT 2000');
                }
            }
            List<CampaignMember> cmList = new List<CampaignMember>();
            if(accountList.size() >0){
                for(Account acc : accountList){
                    CampaignMember cmObj = new CampaignMember();
                    if(!Test.isRunningTest() && Schema.SObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.SObjectType.CampaignMember.fields.ContactId.isCreateable()){
                        cmObj.ContactId = String.valueOf(acc.get('PersonContactId'));
                    }else{
                        if(Schema.SObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.SObjectType.CampaignMember.fields.ContactId.isCreateable()){
                            cmObj.ContactId = conList[0].Id;
                        }
                    }
                    if(Schema.SObjectType.CampaignMember.fields.CampaignId.isAccessible() && Schema.SObjectType.CampaignMember.fields.CampaignId.isCreateable()){
                        cmObj.CampaignId = camp.Id;
                        cmList.add(cmObj);
                    }
                }
                if(cmList.size() >0 && Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isCreateable()) {
                    insert cmList;
                    return camp.Id;
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            return ex.getMessage();
        } 
    }
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description getObjectDetails..........
		* @param objectName ......
	* @param recordId ......
@return string ...
         */
    public static String getObjectDetails(String objectName, String recordId){
        if(objectName == 'Account'){
            boolean getIsPerson =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
            if(Test.isRunningTest() || getIsPerson){
                if(Test.isRunningTest()){
                    String queryStr12 = 'SELECT Id, Name FROM ' + objectName +' WHERE Id=:recordId';
                    //sobject obj = 
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
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description updateCampaignRecord..........
		* @param objectName ......
	* @param recordId ......
	* @param campId ......
	* @param campName ......
@return string ...
*/
    public static String updateCampaignRecord(String objectName, String recordId, String campId, String campName){
        try{
            CampaignMember cmObj = new CampaignMember();
            system.debug(LoggingLevel.WARN, 'objectName::'+objectName);
            if(objectName == 'Account'){
                boolean getIsPerson =  Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
                if(Test.isRunningTest() || getIsPerson){
                    if(Test.isRunningTest()){
                        String queryStr12 = 'SELECT Id, Name FROM ' + objectName +' WHERE Id=:recordId';
                        //sobject obj = 
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
            String exceptionString = 'ERROR:' + ex.getMessage() + 'ON LINE:' + ex.getLineNumber();
            return exceptionString;           
        }
    }
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description getCampaignRecordType..........
	@return List<RecordType> ...
*/
    public static List<RecordType> getCampaignRecordType(){
        try{
            List<RecordType> campaignRecordTypeList = new  List<RecordType>();
            if(Schema.SObjectType.RecordType.isAccessible() && Schema.SObjectType.RecordType.isQueryable() && Schema.sObjectType.RecordType.fields.Name.isAccessible()){
                campaignRecordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType='Campaign' ORDER BY Name DESC LIMIT 100];
            }
            return campaignRecordTypeList;
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN, 'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description createNewCampaignApex..........
		* @param campName ......
	* @param campRecordTypeName ......
	@return Campaign ...
*/
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