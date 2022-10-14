/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description AccountTriggerForPersonAccountHandler ...
 */
public with sharing class AccountTriggerForPersonAccountHandler {
	/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description afterInsertHandler ...
* @param newAccountList stores the list of salesforce Accounts List.
 */
	public static void afterInsertHandler(List<Account> newAccountList){
		try {
			List<Id> contactIds = new List<Id>();
			for (Account ac : newAccountList) {
				boolean getIsPerson = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
				if (getIsPerson && ac.get('PersonEmail') != null) {
					contactIds.add(String.valueOf(ac.get('PersonContactId')));
				}
			}
			if (contactIds.size() > 0) {
				Database.executeBatch(
						new TelosTouchSF.BatchSFToTTSync(contactIds, null, 'insertContact', NULL, NULL, NULL), 150);
			}
		}catch (Exception ex){
			System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
		}
	}
	/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description afterUpdateHandler ...
* @param newAccountList stores the list of salesforce Accounts List.
* @param oldMap ....
 */
	public static void afterUpdateHandler(List<Account> newAccountList, Map<Id, Account> oldMap){
		try {
			List<Id> contactIds = new List<Id>();
			Map<Id, Account> PersonContactIdVsAccountMap = new Map<Id, Account>();
			boolean getIsPerson = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
			for (Account ac : newAccountList) {
				if (getIsPerson && ac.get('PersonEmail') != null && !(Boolean)ac.get('TelosTouchSF__TT_Conflict__pc')) {
					if (ac.get('PersonEmail') != oldMap.get(ac.Id).get('PersonEmail')) {
						contactIds.add(String.valueOf(ac.get('PersonContactId')));
					}
				}
			}
			for (Account oldAcc : oldMap.values()) {
				if (getIsPerson){
					PersonContactIdVsAccountMap.put((Id)oldAcc.get('PersonContactId'), oldAcc);
				}
			}
			if (contactIds.size() > 0) {
				Database.executeBatch(new TelosTouchSF.BatchSFToTTSync(contactIds, null, 'insertContact', NULL, NULL,
						PersonContactIdVsAccountMap), 150);
			}
		}catch (Exception ex){
			System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
		}
	}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the new Accounts.
* @param newAccountList stores the list of salesforce Accounts List.
*/
	public static void beforeInsertHandler(List<Account> newAccountList){
		try {
			boolean getIsPerson = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
			if (getIsPerson) {
				TelosTouchSF__Person_Account_Custom_Fields__c languageMapping =
						new TelosTouchSF__Person_Account_Custom_Fields__c();
				if ([SELECT count() FROM TelosTouchSF__Person_Account_Custom_Fields__c] > 0) {
					languageMapping = [SELECT Id, TelosTouchSF__Salesforce_Field__c FROM TelosTouchSF__Person_Account_Custom_Fields__c
					WHERE TelosTouchSF__TT_Field__c = 'language' WITH SECURITY_ENFORCED LIMIT 1];
				}
				if (languageMapping.TelosTouchSF__Salesforce_Field__c != null) {
					for (Account accObj : newAccountList) {
						if (accObj.get(languageMapping.TelosTouchSF__Salesforce_Field__c) == 'EN') {
							accObj.put('TelosTouchSF__Language__pc', 'English');
						} else if (accObj.get(languageMapping.TelosTouchSF__Salesforce_Field__c) == 'FR') {
							accObj.put('TelosTouchSF__Language__pc', 'French');
						}
					}
				}
			}
		}catch (Exception ex){
			System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
		}
	}
	/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description beforeUpdateHandler
* @param newAccountList stores the list of salesforce Accounts List.
* @param oldAccountMap .....
	 */
	public static void beforeUpdateHandler(List<Account> newAccountList, Map<Id, Account> oldAccountMap){
		try {
			boolean getIsPerson = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
			if (getIsPerson) {
				TelosTouchSF__Person_Account_Custom_Fields__c languageMapping =
						new TelosTouchSF__Person_Account_Custom_Fields__c();
				if ([SELECT count() FROM TelosTouchSF__Person_Account_Custom_Fields__c] > 0) {
					languageMapping = [SELECT Id, TelosTouchSF__Salesforce_Field__c FROM TelosTouchSF__Person_Account_Custom_Fields__c
					WHERE TelosTouchSF__TT_Field__c = 'language' WITH SECURITY_ENFORCED LIMIT 1];
				}
				if (languageMapping.TelosTouchSF__Salesforce_Field__c != null) {
					for (Account accObj : newAccountList) {
						if (accObj.get(languageMapping.TelosTouchSF__Salesforce_Field__c) !=
								oldAccountMap.get(accObj.Id).get(languageMapping.TelosTouchSF__Salesforce_Field__c)) {
							if (accObj.get(languageMapping.TelosTouchSF__Salesforce_Field__c) == 'EN') {
								accObj.put('TelosTouchSF__Language__pc', 'English');
							} else if (accObj.get(languageMapping.TelosTouchSF__Salesforce_Field__c) == 'FR') {
								accObj.put('TelosTouchSF__Language__pc', 'French');
							}
						} else if (accObj.get('TelosTouchSF__Language__pc') !=
								oldAccountMap.get(accObj.Id).get('TelosTouchSF__Language__pc')) {
							if (accObj.get('TelosTouchSF__Language__pc') == 'English') {
								accObj.put(languageMapping.TelosTouchSF__Salesforce_Field__c, 'EN');
							} else if (accObj.get('TelosTouchSF__Language__pc') == 'French') {
								accObj.put(languageMapping.TelosTouchSF__Salesforce_Field__c, 'FR');
							}
						}
					}
				}
			}
		}catch (Exception ex){
			System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
		}
	}
	/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description ...
* @param accountOldList ...
 */
	public static void afterDeleteHandler(List<Account> accountOldList){
		try {
			Set<Id> personContactIdSet = new Set<Id>();
			List<Contact> contactList = new List<Contact>();
			boolean getIsPerson = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
			String query;
			if (getIsPerson) {
				for (Account acc : accountOldList) {
					if (acc.get('PersonContactId') != null) {
						personContactIdSet.add((Id)acc.get('PersonContactId'));
					}
				}
				if (personContactIdSet != null && !personContactIdSet.isEmpty()) {
					query = 'SELECT Owner.TelosTouchSF__TT_UserName__c, Owner.TelosTouchSF__TT_UserId__c, Owner.TelosTouchSF__Auth_Token__c,';
					if (Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable()) {
						for (
								String fieldAPI
								:
						Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().keySet()) {
							if (fieldAPI != 'AccountId') {
								query += fieldAPI + ',';
							}
						}
					}
					query = query.subString(0, query.length() - 1);
					query += ' FROM Contact WHERE IsDeleted = true AND Id =: personContactIdSet ALL ROWS';
					contactList = Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
					TelosTouchSF.ContactTriggerForSyncingHandler.getDeleteRecord(contactList);
				}
			}
		}catch (Exception ex){
			System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
		}
	}
    
    //Method responsible to update the last modified date field if any of the fields relevant to sync is modified
    public static void checkSyncLastModifiedData(list<Account> lstAcc){
        
        if(!Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount')) return;
        set<String> setField = new set<String>();
        for(TelosTouchSF__TT_Salesforce_Mapping__c aField : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                             FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                             WHERE TelosTouchSF__Object_Name__c = 'Contact' AND TelosTouchSF__Salesforce_Field__c != null])
        {
            String fieldName = aField.TelosTouchSF__Salesforce_Field__c;
            if(fieldName.endsWith('__c'))fieldName = fieldName.substringBeforeLast('__c')+'__pc';
            setField.add(fieldName);
        }
        //OwnerId is not mapped but is sent in the sync, we are looking a better way to add it dynamically
        setField.add('OwnerId');
        
        for(Account acc : lstAcc){
            if(!(Boolean)acc.get('isPersonAccount')) continue;
            for(String aField : setField){
                if(!Schema.sObjectType.Account.fields.getMap().containsKey(aField)) continue;
                if(TriggerUtils.wasChanged(acc, aField)){
                    acc.put('TelosTouchSF__TT_Last_Modified_Date__pc', System.now());
                    break;
                }
            }
        }
        
    }
    
}