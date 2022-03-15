/**
* @author Cloud Analogy
* @date 02/08/2021
* @description LayoutRecord ..........
*/
global with sharing class LeadAndContactDeleteFromTTBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

	public List<Contact> deletedContactList ;
	public List<Lead> deletedLeadList ;
	public String action;
	/**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description constructor ..........
	* @param deletedContactList ......
* @param deletedLeadList ......
* @param action ......
*/
	global LeadAndContactDeleteFromTTBatch(List<Contact> deletedContactList, List<Lead> deletedLeadList, String action) {
		this.deletedContactList = deletedContactList;
		this.deletedLeadList = deletedLeadList;
		this.action = action;
	}
	/**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description start method ..........
	* @param bc ......
@return Iterable<sObject> ...
	 */
	global Iterable<sObject> start(Database.BatchableContext bc) {
        if(deletedContactList != null && deletedContactList.size()>0){
			return deletedContactList;
        }
        else if(deletedLeadList != null && deletedLeadList.size()>0){
			return deletedLeadList;
        }
        else{
			return null;
        }
	}
	/**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description execute method ..........
	* @param bc ......
	* @param sObjList ......
*/
	global void execute(Database.BatchableContext bc, List<Sobject> sObjList) {
		if(action == 'deleteContact' ){
			TelosTouchSF.TelosTouchUtility.deleteContactFromTT(sObjList, new List<Lead>());
		}else if( action == 'deleteLead'){
			TelosTouchSF.TelosTouchUtility.deleteContactFromTT(new List<Contact>(), sObjList);
		}
	}
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description finish methiod ..........
* @param bc ......
*/
	global void finish(Database.BatchableContext bc) {
		System.debug(LoggingLevel.DEBUG, 'Finish Method');
	}

}