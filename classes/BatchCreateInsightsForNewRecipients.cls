/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public class BatchCreateInsightsForNewRecipients implements Database.Batchable<Object>, Database.Stateful{
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper getwrapper;
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public List<TelosTouchSF__TT_Log__c> createListOfLog;
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public Map<String, Object> responseMap1;
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param getResponseClients ....
* @param getwrapper ....
*/
public BatchCreateInsightsForNewRecipients(String getResponseClients, BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper getwrapper){
	responseMap1 = new Map<String, Object>();
	responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(getResponseClients);
	this.getwrapper = new BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper();
	this.getwrapper = getwrapper;
	createListOfLog = new List<TelosTouchSF__TT_Log__c>();
}
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param bc ....
* @return List<Object> conversationList ....
*/
public Iterable<Object> start(Database.BatchableContext bc){
	List<Object> conversationList = (List<Object>)responseMap1.get('conversations');
	return conversationList;
}
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param bc ....
* @param responseList ....
*/
public void execute(Database.BatchableContext bc, List<Object> responseList){
	List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
	if ((getwrapper.TTClientIdVsLeadId != null && !getwrapper.TTClientIdVsLeadId.isEmpty()) || (getwrapper.TTClientIdVsContId != null && !getwrapper.TTClientIdVsContId.isEmpty())) {
		if(responseMap1 != null && !responseMap1.keySet().isEmpty()){
			if(responseList != null && responseList.size() > 0){
				for(Object responseObj : responseList){
					Map<String, Object> responseMap2 = (Map<String, Object>)responseObj;
					if(getwrapper.TTClientIdVsLeadId.containsKey(String.valueOf(responseMap2.get('contact_id'))) || getwrapper.TTClientIdVsContId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
						TelosTouchSF__Insights__c conversation_UserObj = new TelosTouchSF__Insights__c();
						if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isCreateable()){
							conversation_UserObj.TelosTouchSF__Campaign2__c = getwrapper.campId;
						}
						if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable()){
							conversation_UserObj.TelosTouchSF__TouchPoint_Name__c = String.valueOf(responseMap1.get('name'));
						}
						if(responseMap2.containsKey('contact_id') && responseMap2.get('contact_id') !=  null){
							if(getwrapper.TTClientIdVsContId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isCreateable()){
									conversation_UserObj.TelosTouchSF__Contact__c = getwrapper.TTClientIdVsContId.get(String.valueOf(responseMap2.get('contact_id')));
								}
							}else if(getwrapper.TTClientIdVsLeadId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isCreateable()){
									conversation_UserObj.TelosTouchSF__Lead__c = getwrapper.TTClientIdVsLeadId.get(String.valueOf(responseMap2.get('contact_id')));
								}
							}
							if(responseMap2.containsKey('conversation_id') && responseMap2.get('conversation_id') !=  null){
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isCreateable()){
									conversation_UserObj.TelosTouchSF__Conversation_Id__c = String.valueOf(responseMap2.get('conversation_id'));
								}
							}
							if(responseMap2.containsKey('completed_at') && responseMap2.get('completed_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('completed_at')))){
								JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('completed_at'))+'"}');
								parser.nextToken();
								parser.nextValue();
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isCreateable()){
									conversation_UserObj.TelosTouchSF__Completed_At__c = DateTime.newInstance( parser.getDateTimeValue().getTime() );
								}
							}
							if(responseMap2.containsKey('opened_at') && responseMap2.get('opened_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('opened_at')))){
								JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap2.get('opened_at'))+'"}');
								parser.nextToken();
								parser.nextValue();
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isCreateable()){
									conversation_UserObj.TelosTouchSF__Opened_At__c = DateTime.newInstance( parser.getDateTimeValue().getTime() );
								}
							}
							if(responseMap2.containsKey('user_name') && responseMap2.get('user_name') !=  null){
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isCreateable()){
									conversation_UserObj.Name =  String.valueOf(responseMap2.get('user_name'));
								}
							}
							if(responseMap2.containsKey('send_status') && responseMap2.get('send_status') != null){
								if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isCreateable()){
									conversation_UserObj.TelosTouchSF__Sent_Status__c =  String.valueOf(responseMap2.get('send_status'));
								}
							}
							conversation_UserList.add(conversation_UserObj);
						}
					}
				}
				if(conversation_UserList.size() > 0 && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
					createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('success','Clients Added to Campaign:'+' '+getwrapper.CampName,'Clients ajoutés à la Campagne:'+' '+getwrapper.CampName,1));
				}
			}
		}else{
			createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Clients could Not be Added to Campaign:'+' '+getwrapper.CampName,'Des Clients n\'ont pu être ajoutés à la Campagne:'+' '+getwrapper.CampName,1));
		}
	}
	if(conversation_UserList.size() > 0 && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
		UPSERT  conversation_UserList TelosTouchSF__Conversation_Id__c;
	}
}
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param bc ....
*/
public void finish(Database.BatchableContext bc){
	if(createListOfLog != null){
		if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && createListOfLog.size() >0){
			insert createListOfLog;
		}
	}
}
}