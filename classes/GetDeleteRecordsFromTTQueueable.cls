/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetDeleteRecordsFromTTQueueable.....
*/
global with sharing class GetDeleteRecordsFromTTQueueable implements Queueable, Database.AllowsCallouts{
    
    global integer totalSyncedUser = 0;
    global integer totalSyncedUserForContacts = 0;
    global integer totalSyncedUserForLeads = 0;
    global integer totalSyncedUserForTasks = 0;
    global integer totalSyncedUserForCampaigns = 0;
    global boolean contactFlag = false;
    global boolean taskFlag = false;
    global boolean campaignFlag = false;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ...
*/
    global void execute(QueueableContext context){
        try{
            System.debug(LoggingLevel.DEBUG, 'Execute Method');
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber()); 
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description finish method......
*/
    public void finishMethod(){
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
}