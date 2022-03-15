/**
* @author Cloud Analogy
* @date 02/08/2021
* @description .....
*/
global with sharing class CampaignDelete_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global List<Campaign> campaignDelteList ;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description constructor ....
* @param campaignlists ....
*/
    global CampaignDelete_Batch(List<Campaign>  campaignlists) { 
        this.campaignDelteList = campaignlists;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description start method ....
* @param bc ....
@return Iterable<sObject>
     */
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return campaignDelteList;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description execute method ....
* @param bc ....
* @param sObjList ....
*/
    global void execute(Database.BatchableContext bc, List<Sobject> sObjList) {
        TelosTouchSF.SFDataSyncWithTelosTouch.deleteCampaign(sObjList);
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description finish method ....
* @param bc ....
*/
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'Finish Method');
    }
    
}