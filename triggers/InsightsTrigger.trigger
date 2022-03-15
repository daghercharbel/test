trigger InsightsTrigger on TelosTouchSF__Insights__c (After insert, After Update) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        TelosTouchSF.InsightsTriggerHandler.publishEventOnInsertAndUpdate(trigger.New);
    }
}