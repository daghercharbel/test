/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ScheduleSyncingContactsAndLeads class for syncing  the contacts, lead and task.
*/
global with sharing class ScheduleSyncingContactsAndLeads implements schedulable
{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description execute method .
* @param sc ......
*/
    global void execute(SchedulableContext sc)
    {
        TelosTouchSF.Batch_UpdateContactAndLead2 batchobj = new TelosTouchSF.Batch_UpdateContactAndLead2(null, null, 'Contact');
        Database.executeBatch(batchobj,500);
    }
}