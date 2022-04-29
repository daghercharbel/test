/**
* @author Cloud Analogy
* @date 02/08/2021
* @description This trigger is written on the campaign object to delete and update campaigns.
*/
trigger CampaignTrigger on Campaign (before delete, before update, after update) {
    if(trigger.isbefore && trigger.isdelete && !System.isBatch()){
        CampaignTriggerHandler.getDeletedCampaignRecord(Trigger.old); 
    }
    if(trigger.isbefore && trigger.isUpdate){
        CampaignTriggerHandler.notChangeTouchPointRecordType(Trigger.new); 
    }
    if(trigger.isAfter && trigger.isUpdate){
        CampaignTriggerHandler.createQuestionsAndAnswers(Trigger.new);
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        TelosTouchSF.CampaignTriggerHandler.publishEventOnInsertAndUpdate(trigger.New);
    }
}