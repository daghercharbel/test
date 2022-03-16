/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetDeleteRecordsFromTTQueueable.....
*/
global with sharing class GetDeleteRecordsFromTTQueueable implements Queueable, Database.AllowsCallouts{
    
    //private static final TelosTouchSF__TelosTouch_API_Settings__c GETCREDENTIALS= TelosTouchSF__TelosTouch_API_Settings__c.getOrgDefaults();
    //private static final String INSTANCEURL = GETCREDENTIALS.TelosTouchSF__Instance_url__c;
    //private static final String TOKEN = GETCREDENTIALS.TelosTouchSF__TOKEN__c;
    global integer totalSyncedUser = 0;
    global integer totalSyncedUserForContacts = 0;
    global integer totalSyncedUserForLeads = 0;
    global integer totalSyncedUserForTasks = 0;
    global integer totalSyncedUserForCampaigns = 0;
    global boolean contactFlag = false;
    global boolean taskFlag = false;
    global boolean campaignFlag = false;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ...
*/
    global void execute(QueueableContext context){
        try{
            System.debug(LoggingLevel.DEBUG, 'Execute Method');
            /*Set<String> setTTidForContacts = new Set<String>();
            Set<String> setTTidForTasks = new Set<String>();
            Set<String> setTTidForCampaigns = new Set<String>();
            List<ResponseWrapperForContacts> resdataForContacts = new List<ResponseWrapperForContacts>();
            List<ResponseWrapperForTasks> resdataForTasks = new List<ResponseWrapperForTasks>();
            List<ResponseWrapperForCampaigns> resdataForCampaigns = new List<ResponseWrapperForCampaigns>();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            Map<String, String> headersMap = new Map<String, String>();
            if(String.isNotBlank(TOKEN) ){
                headersMap.put('Authorization','Basic ' +TOKEN);
                headersMap.put('espo-Authorization', TOKEN);
            }
            DateTime lastHour = System.NOW().addMinutes(-180);
            String formatted = lastHour.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            if(String.isNotBlank(INSTANCEURL) ){
                headersMap.put('instance-name', +INSTANCEURL);
            }
            headersMap.put('Content-type', 'application/json');
            String methodType = 'GET',endPointURLForContacts ='',endPointURLForActions ='',endPointURLForCampaigns ='';
            
            if(Test.isRunningTest()){
                endPointURLForContacts = INSTANCEURL+'/api/v1/contacts?where={"deleted":"true"}';
                endPointURLForActions = INSTANCEURL+'/api/v1/actions?where={"deleted":"true"}';
                endPointURLForCampaigns = INSTANCEURL+'/touchpoint/templates/send?where={"deleted":"true"}';
            }
            else{
                endPointURLForContacts = INSTANCEURL+'/api/v1/contacts?where={"deleted":"true","modified_at":{">=":"'+formatted+'"}}';
                endPointURLForActions = INSTANCEURL+'/api/v1/actions?where={"deleted":"true","modified_at":{">=":"'+formatted+'"}}';
                endPointURLForCampaigns = INSTANCEURL+'/touchpoint/templates/send?where={"deleted":"true","modified_at":{">=":"'+formatted+'"}}';
            }
            String responseBodyForContacts = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURLForContacts, headersMap, null);
            String responseBodyForTasks = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURLForActions, headersMap, null);
            String responseBodyForCampaigns = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURLForCampaigns, headersMap, null);
            resdataForContacts = (List<ResponseWrapperForContacts>) System.JSON.deserialize(responseBodyForContacts,List<ResponseWrapperForContacts>.class);
            resdataForTasks = (List<ResponseWrapperForTasks>) System.JSON.deserialize(responseBodyForTasks,List<ResponseWrapperForTasks>.class);
            resdataForCampaigns = (List<ResponseWrapperForCampaigns>) System.JSON.deserialize(responseBodyForCampaigns,List<ResponseWrapperForCampaigns>.class);
            for(Integer i=0; i< resdataForContacts.Size(); i++){
                setTTidForContacts.add(resdataForContacts[i].id);
            }
            for(Integer i=0; i< resdataForTasks.Size(); i++){
                setTTidForTasks.add(resdataForTasks[i].id);
            }
            for(Integer i=0; i< resdataForCampaigns.Size(); i++){
                setTTidForCampaigns.add(resdataForCampaigns[i].id);
            }
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            List<Task> taskList = new List<Task>();
            List<Campaign> campaignList = new List<Campaign>();
            if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable() && 
               Schema.sObjectType.Contact.fields.id.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                   contactList = [SELECT id,TelosTouchSF__TT_Client_Id__c FROM Contact WHERE TelosTouchSF__TT_Client_Id__c IN: setTTidForContacts LIMIT 10000];
               }
            if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable() && 
               Schema.sObjectType.Lead.fields.id.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                   leadList = [SELECT id,TelosTouchSF__TT_Client_Id__c FROM Lead WHERE TelosTouchSF__TT_Client_Id__c IN: setTTidForContacts LIMIT 10000];
               }
            if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable() && Schema.sObjectType.Task.fields.WhoId.isAccessible() &&
               Schema.sObjectType.Task.fields.id.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() && 
               Schema.sObjectType.Task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                   taskList = [SELECT id,TelosTouchSF__TT_TaskId__c,TelosTouchSF__TT_Client_Id__c,WhoId FROM Task WHERE TelosTouchSF__TT_TaskId__c IN: setTTidForTasks LIMIT 10000];
               }
            if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() && 
               Schema.sObjectType.Campaign.fields.id.isAccessible() && Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible()){
                   campaignList = [SELECT id,TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE TelosTouchSF__TT_Campaign_Id__c IN: setTTidForCampaigns LIMIT 10000];
               }
            List<Contact> contactDeletedList = new List<Contact>();
            List<Lead> leadDeletedList = new List<Lead>();
            List<Task> taskDeletedList = new List<Task>();
            List<Campaign> campaignDeletedList = new List<Campaign>();
            Set<Id> clientIdSFSet = new Set<Id>();
            List<Task> taskDelList = new List<Task>();
            if(contactList.Size() > 0){
                for(Contact con : contactList){
                    if(Schema.sObjectType.Contact.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()&& 
                       Schema.sObjectType.Contact.fields.TelosTouchSF__isDeletedFromTT__c.isUpdateable()){
                           con.TelosTouchSF__isDeletedFromTT__c = true;
                       }
                    clientIdSFSet.add(con.Id);
                        contactDeletedList.add(con);
                }
            }
            if(Schema.sObjectType.Contact.isUpdateable() && Schema.sObjectType.Contact.isAccessible()){
                update contactDeletedList; 
            }
            if(leadList.Size() > 0){
                for(Lead lead : leadList){
                    if(Schema.sObjectType.Lead.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()&& 
                       Schema.sObjectType.Lead.fields.TelosTouchSF__isDeletedFromTT__c.isUpdateable()){
                           lead.TelosTouchSF__isDeletedFromTT__c = true;
                       }
                        leadDeletedList.add(lead);
                    clientIdSFSet.add(lead.Id);
                }
            }
            if(Schema.sObjectType.Lead.isUpdateable() && Schema.sObjectType.Lead.isAccessible()){
                update leadDeletedList; 
            }
            if(taskList.Size() > 0){
                for(Task task : taskList){
                    if(Schema.sObjectType.Task.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()&& 
                       Schema.sObjectType.Task.fields.TelosTouchSF__isDeletedFromTT__c.isUpdateable()){
                           task.TelosTouchSF__isDeletedFromTT__c = true;
                       }
                    taskDeletedList.add(task);
                    if((clientIdSFSet.size() > 0 && !clientIdSFSet.contains(task.whoId)) || (task.whoId == null)) {
                        taskDelList.add(task);
                    }
                }
            }
            if(Schema.sObjectType.Task.isUpdateable() && Schema.sObjectType.Task.isAccessible()){
                update taskDeletedList; 
            }
            if(campaignList.Size() > 0){
                for(Campaign camp : campaignList){
                    if(Schema.sObjectType.Campaign.fields.TelosTouchSF__isDeletedFromTT__c.isAccessible()&& 
                       Schema.sObjectType.Campaign.fields.TelosTouchSF__isDeletedFromTT__c.isUpdateable()){
                           camp.TelosTouchSF__isDeletedFromTT__c = true;
                       }
                        campaignDeletedList.add(camp);
                }
            }
            if(Schema.sObjectType.Campaign.isUpdateable() && Schema.sObjectType.Campaign.isAccessible()){
                update campaignDeletedList; 
            }
            if(contactDeletedList.Size() > 0){
                totalSyncedUserForContacts = contactDeletedList.Size();
                if(Contact.sObjectType.getDescribe().isDeletable() && Schema.sObjectType.Contact.isAccessible()){
                    delete contactDeletedList;
                }
                contactFlag = true;
            }
            if(leadDeletedList.Size() > 0){
                totalSyncedUserForLeads = leadDeletedList.Size();
                if(Lead.sObjectType.getDescribe().isDeletable() && Schema.sObjectType.Lead.isAccessible()){
                    delete leadDeletedList;
                }
                contactFlag = true;
            }
            if(taskDelList.Size() > 0){
                totalSyncedUserForTasks = taskDelList.Size();
                taskFlag = true;
                if(Task.sObjectType.getDescribe().isDeletable() && Schema.sObjectType.Task.isAccessible()){
                    delete taskDelList;
                }
            }
            if(campaignDeletedList.Size() > 0){
                totalSyncedUserForCampaigns = campaignDeletedList.Size();
                if(Campaign.sObjectType.getDescribe().isDeletable() && Schema.sObjectType.Campaign.isAccessible()){
                    delete campaignDeletedList;
                }
                campaignFlag = true;
            }
            if(contactFlag == true || taskFlag == true || campaignFlag == true){
                finishMethod();
            }*/
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber()); 
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description finish method......
*/
    public void finishMethod(){
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
        //TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
        /*if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable() 
           && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()){
               if(contactFlag != true && taskFlag != true && campaignFlag != true){
                   logObj.TelosTouchSF__Result__c = 'Success';
                   logObj.TelosTouchSF__Comments__c = 'No records deleted successfully.';
               }    
               else{
                   logObj.TelosTouchSF__Result__c = 'Success';
                   if(contactFlag == true && taskFlag != true && campaignFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Contacts Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForContacts + totalSyncedUserForLeads;
                   }
                   else if(taskFlag == true && contactFlag != true && campaignFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Tasks Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForTasks;
                   }
                   else if(campaignFlag == true && taskFlag != true && contactFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Campaigns Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForCampaigns;
                   }
                   else if(contactFlag == true && taskFlag == true && campaignFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Contacts and Tasks Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForContacts + totalSyncedUserForLeads + totalSyncedUserForTasks;
                   }
                   else if(taskFlag == true && campaignFlag == true && contactFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Campaigns and Tasks Sync deleted successfully.';
                       totalSyncedUser =  totalSyncedUserForTasks + totalSyncedUserForCampaigns;
                   }
                   else if(contactFlag == true && campaignFlag == true && taskFlag != true){
                       logObj.TelosTouchSF__Comments__c = 'Contacts and Campaigns Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForContacts + totalSyncedUserForLeads + totalSyncedUserForCampaigns;
                   }
                   else if(contactFlag == true && taskFlag == true && campaignFlag == true){
                       logObj.TelosTouchSF__Comments__c = 'Contacts, Tasks and Campaigns Sync deleted successfully.';
                       totalSyncedUser = totalSyncedUserForContacts + totalSyncedUserForLeads + totalSyncedUserForTasks + totalSyncedUserForCampaigns;
                   }
               }
           }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()){
            logObj.TelosTouchSF__Total_Records_Count__c = totalSyncedUser;
        }
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
            logObj.TelosTouchSF__LastUpdated__c = local; 
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
            insert logObj;
        }*/
    }
  /*  public class ResponseWrapperForContacts {
        public String id {get;set;} 
    }
    public class ResponseWrapperForTasks {
        public String id {get;set;} 
    }
    public class ResponseWrapperForCampaigns {
        public String id {get;set;} 
    }*/
}