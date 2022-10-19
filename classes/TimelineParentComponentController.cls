/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TimelineParentComponentController class is used to show only those task/campaign on client timeline whose have "show on client timeline" as "yes".
*/
public with sharing class TimelineParentComponentController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method fills and returns TimelineWrapper by querying Task Records from the org.
* @param recordId stores the id of the record.
* @param objectName stores the name of sObject to query.
* @return TimelineWrapper timeLineWrapperObj ....
*/
    @AuraEnabled
    public static TelosTouchSF.TimelineWrapper getTaskData(String recordId, String objectName) {
        try {
            TelosTouchSF.TimelineWrapper timeLineWrapperObj = new TelosTouchSF.TimelineWrapper();
            if(objectName == 'Account'){
                boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
                if(isPersonAccountEnabled == true){
                    string queryStr12 = 'SELECT Id,PersonContactId, Name FROM ' + objectName +' WHERE Id=:recordId';
                    sobject obj = Database.query(String.escapeSingleQuotes(queryStr12));
                    recordId = (String) obj.get('PersonContactId');
                }else{
                    timeLineWrapperObj.isNotPersonAccount = false;
                    return timeLineWrapperObj;
                }
                objectName = 'Contact';
                if(recordId == null){
                    timeLineWrapperObj.isNotPersonAccount = false;
                    return timeLineWrapperObj;
                }
            }
            
            Map<String,Task> taskMap = new Map<String,Task>();
            Map<String,Task> taskMultipleMap = new Map<String,Task>();
            Map<String,CampaignMember> campMemberMap = new Map<String,CampaignMember>();
            String endPointURL, getResponse, userAuthTOKEN;
            List<Task> taskList = new List<Task>();
            List<CampaignMember> campMemberList = new List<CampaignMember>();
            List<TelosTouchSF.TimelineWrapper.PastTimeline> pastTimelineList = new List<TelosTouchSF.TimelineWrapper.PastTimeline>();
            List<TelosTouchSF.TimelineWrapper.FutureTimeline> futureTimelineList = new List<TelosTouchSF.TimelineWrapper.FutureTimeline>();
            List<TelosTouchSF.TimelineWrapper.AttachmentTimeline> attachmentTimelineList = new List<TelosTouchSF.TimelineWrapper.AttachmentTimeline>();
            List<TelosTouchSF.TimelineWrapper.past> pastList = New List<TelosTouchSF.TimelineWrapper.past>();
            List<TelosTouchSF.TimelineWrapper.future> futureList = New List<TelosTouchSF.TimelineWrapper.future>();
            String queryStr = 'SELECT Id, TelosTouchSF__TT_Client_Id__c FROM ' + objectName +' WHERE Id=:recordId';
            sobject recordObj = Database.query(String.escapeSingleQuotes(queryStr));
            String recId ='', clientId = '';
            Boolean taskRelationsExists = false;
            if(recordObj != null){
                recId =  (String) recordObj.get('Id');
                clientId =  (String) recordObj.get('TelosTouchSF__TT_Client_Id__c'); 
            }
            taskRelationsExists = TelosTouchSF.TelosTouchUtility.isObjectExist('TaskRelation');
            if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable() &&
               Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() && 
               Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible() && 
               Schema.sObjectType.Task.fields.subject.isAccessible() && 
               Schema.sObjectType.Task.fields.Description.isAccessible() && 
               Schema.sObjectType.Task.fields.ActivityDate.isAccessible()){
                if(taskRelationsExists){
                    List<sObject> taskRelationList = Database.query(String.escapeSingleQuotes('SELECT TaskId FROM TaskRelation WHERE RelationId =: recId LIMIT 2000'));
                    Set<Id> taskIdSet = new Set<Id>();
                    for(sObject taskRelationObj : taskRelationList){
                        taskIdSet.add((Id)taskRelationObj.get('TaskId'));
                    }
                    taskList = Database.query(String.escapeSingleQuotes('SELECT Id, subject, WhoCount, TelosTouchSF__Share_with_client_s__c, TelosTouchSF__TT_TaskId__c,Description,ActivityDate FROM Task WHERE Id IN: taskIdSet AND Share_with_client_s__c=\'Yes\' AND IsRecurrence = false LIMIT 1000').replace('\\',''));
                }else{
                    String strYes = 'Yes';
                    taskList = [SELECT Id, subject, TelosTouchSF__Share_with_client_s__c, TelosTouchSF__TT_TaskId__c,Description,ActivityDate FROM Task WHERE WhoId =:recId AND Share_with_client_s__c =: strYes AND IsRecurrence = false LIMIT 1000];
                }
               }
            if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isQueryable() &&
               Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible() && 
               Schema.sObjectType.Campaign.fields.Name.isAccessible() && 
               Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() && 
               Schema.sObjectType.Campaign.fields.CreatedDate.isAccessible()){
                   campMemberList = [SELECT Id,CampaignId,Campaign.Name,Campaign.TelosTouchSF__TT_Campaign_Id__c,Campaign.CreatedDate FROM CampaignMember WHERE (ContactId=:recId OR LeadId=:recId) AND Campaign.TT_Campaign_Id__c != null LIMIT 1000];
               }
            List<TelosTouchSF__Insights__c> insightsList = new List<TelosTouchSF__Insights__c>();
            insightsList = [SELECT Id, TelosTouchSF__Answers__c, CreatedDate, TelosTouchSF__Campaign2__c, TelosTouchSF__Campaign2__r.Name FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__Contact__c =: recordId OR TelosTouchSF__Lead__c =: recordId WITH SECURITY_ENFORCED LIMIT 1000];
            for(TelosTouchSF__Insights__c insight : insightsList){
                if(String.isNotEmpty(insight.TelosTouchSF__Answers__c)){
                    List<conversationWrapper> conversationWrapperList = (List<conversationWrapper>) JSON.deserialize(insight.TelosTouchSF__Answers__c.unescapeHtml4(), List<conversationWrapper>.class);
                    for(conversationWrapper conversation : conversationWrapperList){
                        if(String.isNotEmpty(conversation.resource_url)){
                            TelosTouchSF.TimelineWrapper.AttachmentTimeline attachmentTimelineObj = new TelosTouchSF.TimelineWrapper.AttachmentTimeline();
                            attachmentTimelineObj.type = 'attachment';
                            attachmentTimelineObj.attachmentCreatedDate = insight.CreatedDate.date();
                            attachmentTimelineObj.attachmentName = conversation.content;
                            attachmentTimelineObj.attachmentURL = conversation.resource_url;
                            attachmentTimelineObj.campId = insight.TelosTouchSF__Campaign2__c;
                            attachmentTimelineObj.campName = insight.TelosTouchSF__Campaign2__r.Name;
                            attachmentTimelineList.add(attachmentTimelineObj);
                        }
                    }
                }
            }
            for(Task task : taskList){
                if(String.isNotEmpty(clientId) && clientId != null){
                    if(taskRelationsExists && task.get('WhoCount') != null && (Integer) task.get('WhoCount') > 1){
                        taskMultipleMap.put(task.TelosTouchSF__TT_TaskId__c,task);
                        TelosTouchSF.TimelineWrapper.FutureTimeline  futureTimelineObj = new TelosTouchSF.TimelineWrapper.FutureTimeline();
                        futureTimelineObj.taskId = task.Id;
                        futureTimelineObj.taskName = task.subject;
                        futureTimelineObj.description = task.description;
                        futureTimelineObj.sharedWithClient = task.TelosTouchSF__Share_with_client_s__c;
                        futureTimelineObj.type = 'task';
                        futureTimelineObj.taskDueDate = Date.valueOf(task.ActivityDate);
                        futureTimelineList.add(futureTimelineObj);
                    }
                    else if(task.TelosTouchSF__TT_TaskId__c != null){
                        taskMap.put(task.TelosTouchSF__TT_TaskId__c,task);
                    }else{
                        TelosTouchSF.TimelineWrapper.FutureTimeline  futureTimelineObj = new TelosTouchSF.TimelineWrapper.FutureTimeline();
                        futureTimelineObj.taskId = task.Id;
                        futureTimelineObj.taskName = task.subject;
                        futureTimelineObj.description = task.description;   
                        futureTimelineObj.sharedWithClient = task.TelosTouchSF__Share_with_client_s__c;
                        futureTimelineObj.type = 'task';
                        futureTimelineObj.taskDueDate = Date.valueOf(task.ActivityDate);
                        futureTimelineList.add(futureTimelineObj);
                    }
                }else{
                    TelosTouchSF.TimelineWrapper.FutureTimeline  futureTimelineObj = new TelosTouchSF.TimelineWrapper.FutureTimeline();
                    futureTimelineObj.taskId = task.Id;
                    futureTimelineObj.taskName = task.subject;
                    futureTimelineObj.description = task.description;   
                    futureTimelineObj.sharedWithClient = task.TelosTouchSF__Share_with_client_s__c;
                    futureTimelineObj.type = 'task';
                    futureTimelineObj.taskDueDate = Date.valueOf(task.ActivityDate);
                    futureTimelineList.add(futureTimelineObj);
                }
            }
            for(CampaignMember cmpMemeber : campMemberList){
                if(cmpMemeber.Campaign.TelosTouchSF__TT_Campaign_Id__c != null){
                    campMemberMap.put(cmpMemeber.Campaign.TelosTouchSF__TT_Campaign_Id__c,cmpMemeber);
                }
            }
            if(String.isNotEmpty(clientId) && clientId != null){
                String methodType = 'GET';
                Map<String, String> headersMap = new Map<String, String>();
                userAuthTOKEN = TelosTouchUtility.getCurrentUserTOKEN();
                if(userAuthTOKEN != null){
                    headersMap.put('Authorization','Bearer '+userAuthTOKEN);
                }
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Accept', 'application/json');
                Map<String, Object> tempResponseMap = new Map<String, Object>();
                String responseBody = '', pastBody = '"past": [', futureBody  = '"future": [';
                for(Integer i=0;i<=1980;i=i+90){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/contacts/'+clientId+'/timeline?includeChats=true&limit=90&skip='+i+'&period=all&orderBy=DESC';
                    if(getResponse == null && userAuthTOKEN != null){
                        Map<String, String> getResponseMap = TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                        getResponse = getResponseMap.get('body');
                        if(getResponse != null){
                            tempResponseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
                            if(JSON.serialize(tempResponseMap.get('future')).contains('id')){
                                futureBody += JSON.serialize(tempResponseMap.get('future')).removeStart('[').removeEnd(']');
                            }
                            if(JSON.serialize(tempResponseMap.get('past')).contains('id')){
                                pastBody += JSON.serialize(tempResponseMap.get('past')).removeStart('[').removeEnd(']');
                            }
                        }
                    }else{
                        String response;
                        if(userAuthTOKEN != null){
                            Map<String, String> responseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                            response = responseMap.get('body');
                        }
                        if(response != null && response.contains('id')){
                            tempResponseMap = new Map<String, Object>();
                            tempResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                            if(JSON.serialize(tempResponseMap.get('future')).contains('id')){
                                futureBody += ',';
                                futureBody += JSON.serialize(tempResponseMap.get('future')).removeStart('[').removeEnd(']');
                            }
                            if(JSON.serialize(tempResponseMap.get('past')).contains('id')){
                                pastBody += ',';
                                pastBody += JSON.serialize(tempResponseMap.get('past')).removeStart('[').removeEnd(']');
                            }
                        }else{
                            futureBody += ']';
                            pastBody += ']';
                            break; 
                        }
                    }
                    if(getResponse == null){
                        futureBody += ']';
                        pastBody += ']';
                        break; 
                    }
                }
                responseBody = '{'+pastBody+','+futureBody+'}';
                if(responseBody != null){              
                    timeLineWrapperObj = (TelosTouchSF.TimelineWrapper) System.JSON.deserialize(responseBody, TelosTouchSF.TimelineWrapper.class);
                    pastList = timeLineWrapperObj.past;
                    futureList = timeLineWrapperObj.future;
                }
                for(TelosTouchSF.TimelineWrapper.past past:pastList){
                    if(past.type != null && (past.type == 'task' || past.type == 'request' ) && (!taskMultipleMap.containsKey(past.Id)) && (past.shared == 1 || (taskMap.containsKey(past.id) && taskMap.get(past.id).TelosTouchSF__Share_with_client_s__c == 'Yes'))){
                        TelosTouchSF.TimelineWrapper.PastTimeline  pastTimelineObj = new TelosTouchSF.TimelineWrapper.PastTimeline();
                        if(taskMap.containsKey(past.id)){
                            task tsk = taskMap.get(past.id);
                            pastTimelineObj.taskId = tsk.Id;
                            pastTimelineObj.taskName = tsk.subject;
                            pastTimelineObj.description = tsk.description;   
                            pastTimelineObj.sharedWithClient = tsk.TelosTouchSF__Share_with_client_s__c;
                            pastTimelineObj.type = past.type;
                            pastTimelineObj.taskDueDate = Date.valueOf(tsk.ActivityDate);
                        }else{
                            pastTimelineObj.taskName = past.name;
                            pastTimelineObj.type = past.type;
                            pastTimelineObj.description = past.description;
                            pastTimelineObj.sharedWithClient = 'Yes';
                            pastTimelineObj.taskDueDate = Date.valueOf(past.dateStart);
                        }
                        pastTimelineList.add(pastTimelineObj);
                    }else if (past.type != null && past.type == 'touchpoint'){
                        TelosTouchSF.TimelineWrapper.PastTimeline  pastTimelineObj = new TelosTouchSF.TimelineWrapper.PastTimeline();
                        if(campMemberMap.containsKey(past.touchpoint_send_id)){
                            CampaignMember campMemberObj = campMemberMap.get(past.touchpoint_send_id);
                            pastTimelineObj.campId = campMemberObj.CampaignId;
                            pastTimelineObj.campName = campMemberObj.Campaign.Name;
                            pastTimelineObj.type = past.type;
                            pastTimelineObj.sharedWithClient = 'Yes';
                            pastTimelineObj.campCreatedDate = Date.valueOf(campMemberObj.Campaign.CreatedDate);
                        }else{
                            pastTimelineObj.campName = past.name;
                            pastTimelineObj.type = past.type;
                            pastTimelineObj.sharedWithClient = 'Yes';
                            pastTimelineObj.campCreatedDate =  Date.valueOf(past.createdAt);
                        }
                        pastTimelineList.add(pastTimelineObj);
                    }
                }
                for(TelosTouchSF.TimelineWrapper.future future:futureList)
                {
                    if(future.type != null && (future.type == 'task' || future.type == 'request') && (!taskMultipleMap.containsKey(future.Id)) && (future.shared == 1 || (taskMap.containsKey(future.id) && taskMap.get(future.id).TelosTouchSF__Share_with_client_s__c == 'Yes'))){
                        TelosTouchSF.TimelineWrapper.FutureTimeline  futureTimelineObj = new TelosTouchSF.TimelineWrapper.FutureTimeline();
                        if(taskMap.containsKey(future.id)){
                            task tsk = taskMap.get(future.id);
                            futureTimelineObj.taskId = tsk.Id;
                            futureTimelineObj.taskName = tsk.subject;
                            futureTimelineObj.description = tsk.Description;
                            futureTimelineObj.sharedWithClient = tsk.TelosTouchSF__Share_with_client_s__c;
                            futureTimelineObj.type = future.type;
                            futureTimelineObj.taskDueDate = Date.valueOf(tsk.ActivityDate);
                        }else{
                            futureTimelineObj.taskName = future.name;
                            futureTimelineObj.type = future.type;
                            futureTimelineObj.description = future.description;
                            futureTimelineObj.sharedWithClient = 'Yes';
                            futureTimelineObj.campCreatedDate =  Date.valueOf(future.dateStart);
                        }
                        futureTimelineList.add(futureTimelineObj);
                    }else if (future.type != null && future.type == 'touchpoint'){
                        TelosTouchSF.TimelineWrapper.FutureTimeline  futureTimelineObj = new TelosTouchSF.TimelineWrapper.FutureTimeline();
                        if(campMemberMap.containsKey(future.touchpoint_send_id)){
                            CampaignMember campMemberObj = campMemberMap.get(future.touchpoint_send_id);
                            futureTimelineObj.campId = campMemberObj.CampaignId;
                            futureTimelineObj.campName = campMemberObj.Campaign.Name;
                            futureTimelineObj.type = future.type;
                            futureTimelineObj.sharedWithClient = 'Yes';
                            futureTimelineObj.campCreatedDate =   Date.valueOf(future.createdAt);
                        }else{
                            futureTimelineObj.campName = future.name;
                            futureTimelineObj.type = future.type;
                            futureTimelineObj.sharedWithClient = 'Yes';
                            futureTimelineObj.campCreatedDate =   Date.valueOf(future.createdAt);
                        }
                        futureTimelineList.add(futureTimelineObj);
                    }
                    
                }
            }
            timeLineWrapperObj.futureTimelineList = futureTimelineList;
            timeLineWrapperObj.pastTimelineList = pastTimelineList;
            timeLineWrapperObj.isNotPersonAccount = true;
            timeLineWrapperObj.attachmentTimelinelist = attachmentTimelineList;
            return timeLineWrapperObj;
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }     /**
* @author Cloud Analogy
* @date 02/08/2021
* @description wrapper class which have resource_url and content
*/
    public class conversationWrapper{
        public String resource_url;
        public String content;
    }
}