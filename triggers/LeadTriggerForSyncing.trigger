trigger LeadTriggerForSyncing on Lead (after insert, before update,after delete, after update) {

    //BEFORE
    if(trigger.isBefore){
        //INSERT
        if(trigger.isInsert){

        }
        //UPDATE
        if(trigger.isUpdate){
            if(!System.isBatch()) TelosTouchSF.ContactTriggerForSyncingHandler.updateTaskRecords(Trigger.new, Trigger.oldMap);
            if(!System.isBatch()) TelosTouchSF.LeadTriggerForSyncingHandler.removeConflict(Trigger.new, Trigger.oldMap);
            TelosTouchSF.LeadTriggerForSyncingHandler.checkSyncLastModifiedData(Trigger.new);
        }
        //DELETE
        if(trigger.isDelete){

        }
    }
    
    //AFTER
    if(trigger.isAfter){
        //INSERT
        if(trigger.isInsert){
            TelosTouchSF.LeadTriggerForSyncingHandler.getInsertRecord(Trigger.new);
        }
        //UPDATE
        if(trigger.isUpdate){
            TelosTouchSF.LeadTriggerForSyncingHandler.getUpdateRecord(Trigger.new, Trigger.oldMap);
            TelosTouchSF.LeadTriggerForSyncingHandler.leadConvertFieldMapping(Trigger.new);
            TelosTouchSF.LeadTriggerForSyncingHandler.updateClientAnswersAfterLeadConversion(Trigger.new);
        }
        //DELETE
        if(trigger.isDelete){
            TelosTouchSF.LeadTriggerForSyncingHandler.getDeleteRecord(Trigger.old);
        }
        //UNDELETE
        if(trigger.isUndelete){

        }
    }
}