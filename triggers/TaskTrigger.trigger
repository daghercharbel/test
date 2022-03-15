trigger TaskTrigger on Task (before delete) {
    /*if(trigger.isbefore && trigger.isInsert){
        TaskTriggerHandler.assignValueOnInsert(Trigger.new);
    }
    if(trigger.isbefore && trigger.isUpdate && ((!System.isQueueable()) && (!System.isBatch()))){
        TaskTriggerHandler.assignValueOnUpdate(Trigger.new, Trigger.oldMap);
    }*/
    if(trigger.isbefore && trigger.isDelete){
        TelosTouchSF.TaskTriggerHandler.getDeletedTaskRecord(Trigger.old);
    }
}