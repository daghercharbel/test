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

    //BEFORE
    if(trigger.isBefore){
        //INSERT
        if(trigger.isInsert){

        }
        //UPDATE
        if(trigger.isUpdate){
            TelosTouchSF.ContactTriggerForSyncingHandler.updateTaskRecords(Trigger.new, Trigger.oldMap);
            TelosTouchSF.ContactTriggerForSyncingHandler.removeConflict(Trigger.new, Trigger.oldMap);
            TelosTouchSF.ContactTriggerForSyncingHandler.checkSyncLastModifiedData(Trigger.new);
        }
        //DELETE
        if(trigger.isDelete){

        }
    }
    
    //AFTER
    if(trigger.isAfter){
        //INSERT
        if(trigger.isInsert){
            TelosTouchSF.ContactTriggerForSyncingHandler.getInsertRecord(Trigger.new);
        }
        //UPDATE
        if(trigger.isUpdate){
            if(!System.isBatch()) TelosTouchSF.ContactTriggerForSyncingHandler.getUpdateRecord(Trigger.new, Trigger.oldMap);
        }
        //DELETE
        if(trigger.isDelete){
            TelosTouchSF.ContactTriggerForSyncingHandler.getDeleteRecord(Trigger.old); 
        }
        //UNDELETE
        if(trigger.isUndelete){

        }
    }

}