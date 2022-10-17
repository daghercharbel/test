trigger AccountTrigger on Account (after insert, before insert, before Update, after update, after delete) {
    if(trigger.isAfter && trigger.isInsert){
        AccountTriggerForPersonAccountHandler.afterInsertHandler(Trigger.new);
    }
    if(trigger.isBefore && trigger.isInsert){
        AccountTriggerForPersonAccountHandler.beforeInsertHandler(Trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        AccountTriggerForPersonAccountHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        AccountTriggerForPersonAccountHandler.checkSyncLastModifiedData(Trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate && !System.isBatch()){
        AccountTriggerForPersonAccountHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isDelete){
        AccountTriggerForPersonAccountHandler.afterDeleteHandler(Trigger.old);
    }
}