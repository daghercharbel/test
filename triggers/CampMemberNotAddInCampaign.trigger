/**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description This trigger is written on CampaignMember to get new insert record.
 */
trigger CampMemberNotAddInCampaign on CampaignMember (before insert, before delete, after insert, after delete) {
    if(trigger.isBefore){
        if(trigger.IsInsert){
            CampMemberNotAddInCampHandler.checkCampaignSyncOrNot(trigger.new);
        }
        if(trigger.isDelete){
            CampMemberNotAddInCampHandler.blockDelete(trigger.old);
        }
    } else if(trigger.isAfter) {
        if(trigger.isInsert){
            TelosTouchSF.CampMemberNotAddInCampHandler.publishEventOnInsertAndUpdate(trigger.New);
            CampMemberNotAddInCampHandler.updateTTCampaignMember(trigger.New);
        } else if(trigger.isUpdate){
            TelosTouchSF.CampMemberNotAddInCampHandler.publishEventOnInsertAndUpdate(trigger.New);
        } else if(trigger.isDelete){
            TelosTouchSF.CampMemberNotAddInCampHandler.publishEventOnInsertAndUpdate(trigger.Old);
            CampMemberNotAddInCampHandler.removeTTCampaignMember(trigger.Old);
        }
    }
}