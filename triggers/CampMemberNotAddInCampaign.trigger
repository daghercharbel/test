/**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description This trigger is written on CampaignMember to get new insert record.
 */
trigger CampMemberNotAddInCampaign on CampaignMember (before insert, after insert, after delete) {
    if(trigger.IsInsert && trigger.IsBefore){
        //TelosTouchSF.CampMemberNotAddInCampHandler.checkCampaignSyncOrNot(trigger.new);
    }
    /*if(trigger.IsInsert && trigger.IsAfter && !system.isBatch()){
        //TelosTouchSF.CampMemberNotAddInCampHandler.addRecipientsIntoTouchPoint(trigger.new);
    }*/
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        TelosTouchSF.CampMemberNotAddInCampHandler.publishEventOnInsertAndUpdate(trigger.New);
    }
    if(trigger.isAfter && (trigger.isDelete)){
        TelosTouchSF.CampMemberNotAddInCampHandler.publishEventOnInsertAndUpdate(trigger.Old);
    }
}