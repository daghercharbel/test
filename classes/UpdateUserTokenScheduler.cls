/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
global with sharing class UpdateUserTokenScheduler  implements Schedulable{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param ctx ....
*/
    global void execute(SchedulableContext ctx)
    {
        TelosTouchSF.UpdateUserTokenQueueable obj = new TelosTouchSF.UpdateUserTokenQueueable();
        System.enqueueJob(obj);
    }
}