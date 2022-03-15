/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description ContactTriggerForSyncing ...
 * @param after insert ...
* @param before update ...
* @param after delete ...
* @param after update ...
 */
trigger ContactTriggerForSyncing on Contact (after insert,before update, after delete, after update) {
    if(trigger.isafter && trigger.isinsert)
    {
        TelosTouchSF.ContactTriggerForSyncingHandler.getInsertRecord(Trigger.new);
    }
    if(trigger.isdelete && trigger.isafter) {
        TelosTouchSF.ContactTriggerForSyncingHandler.getDeleteRecord(Trigger.old); 
    }
    if(trigger.isbefore && trigger.isUpdate)
    {
        TelosTouchSF.ContactTriggerForSyncingHandler.updateTaskRecords(Trigger.new, Trigger.oldMap);
        TelosTouchSF.ContactTriggerForSyncingHandler.removeConflict(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate && !System.isBatch()){
        TelosTouchSF.ContactTriggerForSyncingHandler.getUpdateRecord(Trigger.new, Trigger.oldMap);
    }
}