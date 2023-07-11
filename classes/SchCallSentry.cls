global with sharing class SchCallSentry implements Schedulable  {
    global void execute(SchedulableContext sc) {
        TelosTouchSF.Batch_CallSentry sentryBatch = new TelosTouchSF.Batch_CallSentry(); 
        Database.executeBatch(sentryBatch);
    } 
}