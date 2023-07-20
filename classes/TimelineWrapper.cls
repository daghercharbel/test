/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TimelineWrapper{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public List<past> past {get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public list<future> future{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    @AuraEnabled
    public List<PastTimeline>  pastTimelineList{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    @AuraEnabled
    public list<FutureTimeline> futureTimelineList{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    @AuraEnabled
    public list<AnswerTimeline> answerTimelinelist{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    @AuraEnabled
    public list<AttachmentTimeline> attachmentTimelinelist{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    @AuraEnabled
    public Boolean isNotPersonAccount { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class FutureTimeline {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String taskId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String taskName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String description { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String sharedWithClient { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String type { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date campCreatedDate { get; set; }
//CD
/**
* @author Charbel Dagher
* @date 04/010/2022
* @description ...
*/  
@AuraEnabled
public  date campOpenDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
@AuraEnabled
public  date campCompletedDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date taskDueDate { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class AnswerTimeline {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String type { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String answerId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String question { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date answerCreatedDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String answer { get; set; }
    }   /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class AttachmentTimeline {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String type { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date attachmentCreatedDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String attachmentName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String attachmentURL { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campName { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class PastTimeline {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String taskId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String taskName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String description { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String sharedWithClient { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String campName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  String type { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date campCreatedDate { get; set; }
//CD
/**
* @author Charbel Dagher
* @date 04/010/2022
* @description ...
*/  
@AuraEnabled
public  date campOpenDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
@AuraEnabled
public  date campCompletedDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public  date taskDueDate { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class past {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String type {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name_fr {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String description {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Integer shared {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String dateStart {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String completedAt {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdAt {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String openedAt {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserId {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserName {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdById {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdByName {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_send_id {get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String image_id {get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class future{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdAt{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String completedAt{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String dateStart{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String openedAt{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Integer shared{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserId{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserName{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String description{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdById{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name_fr{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdByName{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_send_id{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String image_id{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String type{get;set;}
    }
}