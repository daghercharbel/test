/**
* @author Cloud Analogy
* @date 02/08/2021
*@description ClientTaggingController.....
*/
public with sharing class ClientTaggingController {
   /**
* @author Cloud Analogy
* @date 02/08/2021
*@description deleteAssignments.....
* @param lstTopic ......
* @param lstRecordId ......
* @return ...
*/
    @AuraEnabled
    public static map<String, String> deleteAssignments(list<String> lstTopic, list<String> lstRecordId){

        map<String, String> mapResult = new map<String, String>();

        try {
            
            List<TopicAssignment> lstAssign = [SELECT Id FROM TopicAssignment WHERE EntityId IN: lstRecordId AND TopicId IN: lstTopic WITH SECURITY_ENFORCED];
            if (Schema.sObjectType.TopicAssignment.isAccessible() && Schema.sObjectType.TopicAssignment.isDeletable()) {
                Database.delete(lstAssign);
            }
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'ClientTaggingController', 'deleteAssignments', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
 /**
* @author Cloud Analogy
* @date 02/08/2021
*@description getTopics.....
* @param lstRecordId ......
* @return ...
*/
    @AuraEnabled
    public static map<String, String> getTopics(list<String> lstRecordId){

        map<String, String> mapResult = new map<String, String>();

        try {

            list<Topic> lstTopic = [SELECT Id, Name FROM Topic WHERE Id IN (SELECT TopicId FROM TopicAssignment WHERE EntityId IN: lstRecordId) WITH SECURITY_ENFORCED];

            mapResult.put('status', 'success');
            mapResult.put('value', JSON.serialize(lstTopic));

            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'ClientTaggingController', 'getTopics', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description upsertTopics.....
* @param topicName ......
* @param lstRecordId ......
* @return ...
*/
    @AuraEnabled
    public static map<String, String> upsertTopics(String topicName, list<String> lstRecordId){

        map<String, String> mapResult = new map<String, String>();
        String topicId;

        try {
            
            topicName = topicName.normalizeSpace();
            list<Topic> lstTopic = [SELECT Id FROM Topic WHERE Name =: topicName WITH SECURITY_ENFORCED];

            if(lstTopic.isEmpty()){
                Topic aTopic = new Topic(
                    name = topicName
                );
            if (Schema.sObjectType.Topic.isCreateable() && Schema.sObjectType.Topic.isAccessible()) {
                database.insert(aTopic);
            }
            topicId = aTopic.Id;
            } else {
                topicId = lstTopic[0].Id;
            }

            List<TopicAssignment> lstAssign = new List<TopicAssignment>();
            for(String recordId : lstRecordId){
                TopicAssignment assign = new TopicAssignment(
                    EntityId = recordId,
                    TopicId = topicId
                );
                lstAssign.add(assign);
            }
            if (Schema.sObjectType.TopicAssignment.isCreateable() && Schema.sObjectType.TopicAssignment.isAccessible()) {
                Database.insert(lstAssign);
            }
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'ClientTaggingController', 'upsertTopics', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

}