/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TT_AddToCampaignMobile....
*/
public with sharing class TT_AddToCampaignMobile {
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description fetchData ....
	* @param objectName ...
* @param dataIdSet ....
* @param searchKey ....
@return List<dataWrapper> ...
         */
    public static List<dataWrapper> fetchData(String objectName, String dataIdSet, String searchKey) {
        try {
            if (objectName != null) {
                List<Id> dataIDs = new List<Id>();
                String query;
                dataIDs = (List<Id>)JSON.deserialize(dataIdSet, List<Id>.class);
                List<sObject> queryResult = new List<sObject>();
                List<List<sObject>> searchQueryResults = new List<List<sObject>>();
                if (dataIDs.size() == 0 && String.isEmpty(searchKey)) {
                    query = 'SELECT ID,Name,Phone,Email,Synced__c FROM ' + objectName + ' WHERE Email != NULL ORDER BY Id ASC LIMIT 100';
                } else if (dataIDs.size() != 0 && String.isEmpty(searchKey)) {
                    query = 'SELECT ID,Name,Phone,Email,Synced__c FROM ' + objectName+
                        ' WHERE Id NOT IN: dataIDs AND Email != NULL ORDER BY ID ASC LIMIT 100';
                } else if (dataIDs.size() == 0 && String.isNotEmpty(searchKey)) {
                    /*query = 'SELECT ID,Name,Phone,Email,Synced__c FROM ' + objectName + ' WHERE (Email LIKE ' + '\'' +
                        searchKey.trim() + '%\'' + 'OR Name LIKE ' + '\'' + searchKey.trim() + '%\'' +
                        ' ) ORDER BY Id ASC LIMIT 100';*/
                    query = 'FIND \''+searchKey+'*\' IN ALL FIELDS RETURNING '+objectName+'(ID,Name,Phone,Email,Synced__c WHERE Email != null) LIMIT 100';
                } else if (dataIDs.size() != 0 && String.isNotEmpty(searchKey)) {
                    query = 'SELECT ID,Name,Phone,Email,Synced__c FROM ' + objectName + ' WHERE (Email LIKE ' + '\'' +
                        searchKey.trim() + '%\'' + 'OR Name LIKE ' + '\'' + searchKey.trim() + '%\'' +
                        ' ) AND Id NOT IN: dataIDs ORDER BY Id ASC LIMIT 100';
                }
                if (dataIDs.size() == 0 && String.isNotEmpty(searchKey)){
                    query = String.escapeSingleQuotes(query).replace('\\','');
                    searchQueryResults = Search.query(query);
                }else{
                    queryResult = Database.query(String.escapeSingleQuotes(query).replace('\\',''));
                }
                //System.debug('searchQueryResults:: '+searchQueryResults);
                List<dataWrapper> dataList = new List<dataWrapper>();
                if (queryResult != null && queryResult.size() > 0) {
                    for (sObject qObj : queryResult) {
                        dataWrapper wrapperObj = new dataWrapper();
                        wrapperObj.Id = (String)qObj.get('Id');
                        wrapperObj.Name = (String)qObj.get('Name');
                        wrapperObj.Phone = (String)qObj.get('Phone');
                        wrapperObj.Email = (String)qObj.get('Email');
                        String synced = (String)qObj.get('Synced__c');
                        if (synced.contains('Right')){
                            wrapperObj.isSynced = System.Label.Yes_Text;
                        }
                        else{
                            wrapperObj.isSynced = System.Label.No_Text;
                        }
                        dataList.add(wrapperObj);
                    }
                    return dataList;
                }else if(searchQueryResults != null && searchQueryResults.size() > 0){
                    for (sObject qObj : searchQueryResults[0]) {
                        dataWrapper wrapperObj = new dataWrapper();
                        wrapperObj.Id = (String)qObj.get('Id');
                        wrapperObj.Name = (String)qObj.get('Name');
                        wrapperObj.Phone = (String)qObj.get('Phone');
                        wrapperObj.Email = (String)qObj.get('Email');
                        String synced = (String)qObj.get('Synced__c');
                        if (synced.contains('Right')){
                            wrapperObj.isSynced = System.Label.Yes_Text;
                        }
                        else{
                            wrapperObj.isSynced = System.Label.No_Text;
                        }
                        dataList.add(wrapperObj);
                    }
                    return dataList;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception:: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description fetchRecordCounts ....
* @param campaignId ....
@return detailsWarpper ...
     */
    @AuraEnabled
    public static detailsWarpper fetchRecordCounts(Id campaignId) {
        try {
            Integer totalLeads = [Select Count() FROM Lead WITH SECURITY_ENFORCED];
            Integer totalContacts = [Select Count() FROM Contact WITH SECURITY_ENFORCED];
            List<CampaignMember> allCampMembers = new List<CampaignMember>();
            List<String> memberIds = new List<String>();
            detailsWarpper wrapper = new detailsWarpper();
            if (campaignId != null){
                allCampMembers = [SELECT Id, LeadId, ContactId FROM CampaignMember WHERE CampaignId =: campaignId WITH SECURITY_ENFORCED LIMIT 50000];
            }
            if (allCampMembers != null && allCampMembers.size() > 0) {
                for (CampaignMember camObj : allCampMembers) {
                    if (camObj.ContactId != null){
                        memberIds.add(camObj.ContactId);
                    }
                    if (camObj.LeadId != null){
                        memberIds.add(camObj.LeadId);
                    }
                }
            }
            String result = String.valueOf(totalLeads + '&&' + String.valueOf(totalContacts));
            wrapper.counts = result;
            wrapper.memberIds = memberIds;
            return wrapper;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Error is ::: ' + e.getMessage() + ' at line no. ::: ' + e.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description createCampaignMembers ....
* @param dataList ....
* @param campaignId ....
* @param objectName ....
@return Boolean ..
     */
    @AuraEnabled
    public static Boolean createCampaignMembers(String dataList, Id campaignId, String objectName) {
        try {
            if (dataList != null) {
                List<dataWrapper> data = (List<dataWrapper>)JSON.deSerialize(dataList, List<dataWrapper>.class);
                List<CampaignMember> campMembList = new List<CampaignMember>();
                for (dataWrapper dataObj : data) {
                    CampaignMember campMembObj = new CampaignMember();
                    campMembObj.CampaignId = campaignId;
                    if (objectName == 'Lead' && Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() && Schema.sObjectType.CampaignMember.fields.LeadId.isCreateable() ){
                        campMembObj.LeadId = dataObj.Id;
                    }
                    else{
                        if(Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.sObjectType.CampaignMember.fields.ContactId.isCreateable()) {
                            campMembObj.ContactId = dataObj.Id;
                        }
                    }
                    campMembList.add(campMembObj);
                }
                //System.debug('campMembList:: '+campMembList);
                if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isCreateable() && CampaignMember.getSObjectType().getDescribe().isAccessible() && CampaignMember.getSObjectType().getDescribe().isCreateable()) {
                    insert campMembList;
                }
                return true;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' At Line: '+ e.getLineNumber());
        }
        return false;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description wrapper class which stores Id, Name, Phone, Email and isSynced.
*/
    public class dataWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String Id {
            get;set;
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String Name {
            get;set;
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String Phone {
            get;set;
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String Email {
            get;set;
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String isSynced {
            get;set;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description detailsWrapper stores counts, memberIds
*/
    public class detailsWarpper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public String counts {
            get;set;
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
        @AuraEnabled public List<String> memberIds {
            get;set;
        }
    }
}