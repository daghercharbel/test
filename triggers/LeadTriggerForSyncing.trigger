trigger LeadTriggerForSyncing on Lead (after insert, before update,after delete, after update) {
    if(trigger.isafter && trigger.isinsert)
    {
        TelosTouchSF.LeadTriggerForSyncingHandler.getInsertRecord(Trigger.new); 
    }
    if(trigger.isafter && trigger.isdelete)
    {
        TelosTouchSF.LeadTriggerForSyncingHandler.getDeleteRecord(Trigger.old); 
    }
    if(trigger.isbefore && trigger.isUpdate && !System.isBatch())
    {
        TelosTouchSF.ContactTriggerForSyncingHandler.updateTaskRecords(Trigger.new, Trigger.oldMap);
        TelosTouchSF.LeadTriggerForSyncingHandler.removeConflict(Trigger.new, Trigger.oldMap);
    }  
    if(trigger.isAfter && trigger.isUpdate){
        TelosTouchSF.LeadTriggerForSyncingHandler.getUpdateRecord(Trigger.new, Trigger.oldMap);
        TelosTouchSF.LeadTriggerForSyncingHandler.leadConvertFieldMapping(Trigger.new);
        TelosTouchSF.LeadTriggerForSyncingHandler.updateClientAnswersAfterLeadConversion(Trigger.new);
    }
}