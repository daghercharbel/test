/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetTaskFromTTQueueable is a Queueable class and used to get actions within last 2 hours from TT and insert those tasks in SF.
*/
global with sharing class GetTaskFromTTQueueable implements Queueable, Database.AllowsCallouts{
	/*private static final TelosTouch_API_Settings__c GETCREDENTIALS= TelosTouch_API_Settings__c.getOrgDefaults();
	private static final String INSTANCEURL = GETCREDENTIALS.Instance_url__c;
	private static final String TOKEN = GETCREDENTIALS.TOKEN__c;*/
	private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
	private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
	global String message;
	global integer totalSyncedUser = 0;
	public Integer startPoint;
	public Integer endPoint;
	public Integer numberOfRecords;
	public boolean forFirstTime;
	public String syncObject;
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param startPoint ...
* @param endPoint ......
* @param numberOfRecords ...
* @param forFirstTime ......
* @param syncObject ......
*/
	public GetTaskFromTTQueueable(Integer startPoint, Integer endPoint, Integer numberOfRecords, Boolean forFirstTime, String syncObject){
		this.startPoint = startPoint;
		this.endPoint = endPoint;
		this.numberOfRecords = numberOfRecords;
		this.forFirstTime = forFirstTime;
		this.syncObject = syncObject;
	}
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ......
*/
	global void execute(QueueableContext context){
		try{
			Integer ownerNotFoundCount = 0;
			Map<String,task> taskMap = new Map<String,task>();
			List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
			Map<String,Lead> leadMap = new Map<String,Lead>();
			Map<String,Contact> contactMap = new Map<String,Contact>();
			Map<String, String> headersMap = new Map<String, String>();
			List<ResponseTaskWrapper> resdata1 = new List<ResponseTaskWrapper>();
			Set<String> setTTid = new Set<String>();
			Set<String> setSFId = new Set<String>();
			Set<String> setTTClientId = new Set<String>();
			List<Task> taskUpsertList = new List<Task>();
			String methodType = 'GET', endPointURL = '',responseBody;
			//HttpRequest request = new HttpRequest();
			//HttpResponse response = new HttpResponse();
			//Http http = new Http();
			DateTime lastHour = System.NOW().addMinutes(-62);
			String formatted = lastHour.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			headersMap.put('Content-Type', 'application/json');
			//userAuthTOKEN = TelosTouchUtility.getCurrentUserTOKEN();
			//System.debug('userAuthTOKEN>'+userAuthTOKEN);
			Map<String, Id> userMap = new Map<String, Id>();
			for(User userObj : [SELECT Id, TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c != null AND IsActive = true WITH SECURITY_ENFORCED LIMIT 2000]){
				userMap.put(userObj.TelosTouchSF__TT_UserId__c, userObj.Id);
			}
			if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
				headersMap.put('Accept', 'application/json');
				//Boolean returnValue = TelosTouchUtility.checkAsyncApexJob('GetTaskFromTTQueueable');
				for(Integer i=startPoint;i<endPoint;i=i+200){
					try {
						if (forFirstTime) {
							//endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/actions?skip='+i+'&limit=200&deleted=false';
							endPointURL =
									adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/actions?skip=' + i +
									'&limit=200&deleted=false';
						} else {
							//endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/actions?where={"modified_at":{">=":"'+formatted+'"}}&skip='+i+'&limit=200&deleted=false';
							endPointURL =
									adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/actions?skip=' + i +
									'&limit=200&deleted=false&modified_at={">=":"' + formatted + '"}';
						}
						if (authenticationCredential.TelosTouchSF__Access_Token__c != null) {
							headersMap.put('Authorization', 'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
							Map<String, String> responseBodyMap =
									TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
							if (responseBodyMap.get('status_code') == '401') {
								createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure',
										'User Could Not be Authenticated', 'L\'usager n\'a pu être identifié', 1));
							}else if(responseBodyMap.get('status_code') == '500'){
								createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
							}else{
								if(responseBodyMap.get('status_code').length() > 0){
									list<String>StatusCodeList = responseBodyMap.get('status_code').split('0');
									if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
										createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBodyMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBodyMap.get('status_code'),1));
									}
								}
							}
							responseBody = responseBodyMap.get('body');
						}
						if (responseBody != null && responseBody.contains('id')) {
							resdata1.addAll((List<ResponseTaskWrapper>) System.JSON.deserialize(responseBody,
											List<ResponseTaskWrapper>.class));
						} else {
							break;
						}
					}catch (Exception ex){
						System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
					}
				}
			}
			if(resdata1.size() > 0){
				for(Integer i=0; i< resdata1.size(); i++){
					if(resdata1[i].other_id != null){
						setSFId.add(resdata1[i].other_id);
					}
					setTTid.add(resdata1[i].id);
					if(String.isNotEmpty(String.valueOf(resdata1[i].client_id))){
						setTTClientId.add(resdata1[i].client_id);
					}
				}
				List<TelosTouchSF__TT_Salesforce_Mapping__c> tasktelosTouchMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
				tasktelosTouchMappingList = [SELECT Id, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__Is_Deleted__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Object_Name__c,TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c='Task' AND TelosTouchSF__Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1000 ];
				Map<String, TelosTouchSF__TT_Salesforce_Mapping__c> ttTaskFieldsMap = new Map<String, TelosTouchSF__TT_Salesforce_Mapping__c>();
				for(contact conObj : [SELECT id,TelosTouchSF__TT_Client_Id__c,Name FROM Contact WHERE IsDeleted = false AND TelosTouchSF__TT_Client_Id__c IN:setTTClientId WITH SECURITY_ENFORCED LIMIT 1600 ALL ROWS]){
					contactMap.put(conObj.TelosTouchSF__TT_Client_Id__c, conObj);
				}
				for(lead leadObj : [SELECT id,TelosTouchSF__TT_Client_Id__c,Name FROM Lead WHERE IsDeleted = false AND TelosTouchSF__TT_Client_Id__c IN:setTTClientId WITH SECURITY_ENFORCED LIMIT 1600 All ROWS]){
					leadMap.put(leadObj.TelosTouchSF__TT_Client_Id__c, leadObj);
				}
				List<Task> taskList = new List<Task>();
				taskList = [SELECT id,Subject,WhoId,Status,ActivityDate,TelosTouchSF__Share_with_client_s__c,TelosTouchSF__TT_TaskId__c,TelosTouchSF__TT_Client_Id__c,TelosTouchSF__TT_Client_Name__c,Description,OwnerId,LastModifiedDate,TelosTouchSF__Source__c,TelosTouchSF__TT_Category__c FROM Task WHERE IsDeleted != true AND (TelosTouchSF__TT_TaskId__c IN: setTTid) WITH SECURITY_ENFORCED LIMIT 1400 ALL ROWS];
				taskList.addAll([SELECT id,Subject,WhoId,Status,ActivityDate,TelosTouchSF__Share_with_client_s__c,TelosTouchSF__TT_TaskId__c,TelosTouchSF__TT_Client_Id__c,TelosTouchSF__TT_Client_Name__c,Description,OwnerId,LastModifiedDate,TelosTouchSF__Source__c,TelosTouchSF__TT_Category__c FROM Task WHERE IsDeleted != true AND (ID IN:setSFId) WITH SECURITY_ENFORCED LIMIT 1400 ALL ROWS]);
				for(task taskObj : taskList){
					if(taskObj.TelosTouchSF__TT_TaskId__c == null){
						taskMap.put(taskObj.Id, taskObj);
					}else{
						taskMap.put(taskObj.TelosTouchSF__TT_TaskId__c, taskObj);
					}
				}
				if(tasktelosTouchMappingList != null && tasktelosTouchMappingList.size() >0){
					for(TelosTouchSF__TT_Salesforce_Mapping__c mappingObj : tasktelosTouchMappingList){
						ttTaskFieldsMap.put(mappingObj.TelosTouchSF__TT_Field__c,mappingObj);
					}
				}

				for(ResponseTaskWrapper obj1 : resdata1){
					if(Schema.sObjectType.task.fields.WhoId.isAccessible() &&
							Schema.sObjectType.task.fields.WhoId.isCreateable() &&
							Schema.sObjectType.task.fields.WhoId.isUpdateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Id__c.isCreateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_TaskId__c.isCreateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_TaskId__c.isUpdateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Name__c.isAccessible() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Name__c.isCreateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__TT_Client_Name__c.isUpdateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Source__c.isAccessible() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Source__c.isCreateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Source__c.isUpdateable() &&
							Schema.sObjectType.task.fields.Subject.isAccessible() &&
							Schema.sObjectType.task.fields.Subject.isCreateable() &&
							Schema.sObjectType.task.fields.Subject.isUpdateable() &&
							Schema.sObjectType.task.fields.Status.isAccessible() &&
							Schema.sObjectType.task.fields.Status.isCreateable() &&
							Schema.sObjectType.task.fields.Status.isUpdateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Share_with_client_s__c.isCreateable() &&
							Schema.sObjectType.task.fields.TelosTouchSF__Share_with_client_s__c.isUpdateable() &&
							Schema.sObjectType.task.fields.ActivityDate.isAccessible() &&
							Schema.sObjectType.task.fields.ActivityDate.isCreateable() &&
							Schema.sObjectType.task.fields.ActivityDate.isUpdateable() &&
							Schema.sObjectType.task.fields.Description.isAccessible() &&
							Schema.sObjectType.task.fields.Description.isCreateable() &&
							Schema.sObjectType.task.fields.Description.isUpdateable() ){
						Datetime dt = (DateTime)JSON.deserialize('"' + obj1.modified_at + '"', DateTime.class);
						String clientId = '',ttClientId, shareWithClients,whoId,ttClientName,subject,status,description;
						if (taskMap.containskey(obj1.id) && taskMap.get(obj1.id) != null ){
							if ( taskMap.get(obj1.Id).LastModifiedDate.getTime() < dt.getTime()){
								Task taskObject = new Task();
								taskObject = taskMap.get(obj1.id);
								if(contactMap.containskey(obj1.client_id) && String.isNotEmpty(obj1.client_id)){
									clientId = contactMap.get(obj1.client_id).Id;
								}if(leadMap.containskey(obj1.client_id) && String.isNotEmpty(obj1.client_id)){
									clientId = leadMap.get(obj1.client_id).Id;
								}
								if(obj1.shared == true){
									shareWithClients = 'Yes';
								}else{
									shareWithClients = 'No';
								}
								if(taskObject.WhoId == null){
									whoId = '';
								}else{
									whoId = taskObject.whoId;
								}
								if(taskObject.TelosTouchSF__TT_Client_Id__c == null){
									ttClientId = '';
								}else{
									ttClientId = taskObject.TelosTouchSF__TT_Client_Id__c;
								}
								if(taskObject.TelosTouchSF__TT_Client_Name__c == null){
									ttClientName = '';
								}else{
									ttClientName = taskObject.TelosTouchSF__TT_Client_Name__c;
								}
								if(taskObject.Subject == null){
									subject = '';
								}else{
									subject = taskObject.Subject;
								}
								if(taskObject.Status == null){
									status = '';
								}else{
									status = taskObject.status;
								}
								if(taskObject.description == null){
									description = '';
								}else{
									description = taskObject.description;
								}
								if(ttClientId != obj1.client_id  || whoId != clientId ||
												ttClientName != obj1.client_name || subject != obj1.name ||
												status != obj1.status || shareWithClients != taskObject.TelosTouchSF__Share_with_client_s__c ||
												description != obj1.description || taskObject.ActivityDate != date.valueOf(obj1.date_due) || (userMap.containsKey(obj1.assigned_user_id) &&
														taskObject.OwnerId != userMap.get(obj1.assigned_user_id))){
									if(ttTaskFieldsMap.containskey('client_id')){
										taskObject.put(ttTaskFieldsMap.get('client_id').TelosTouchSF__Salesforce_Field__c, obj1.client_id);
									}
									taskObject.TelosTouchSF__TT_TaskId__c = obj1.id;
									if(ttTaskFieldsMap.containskey('client_name')){
										taskObject.put(ttTaskFieldsMap.get('client_name').TelosTouchSF__Salesforce_Field__c , obj1.client_name);
									}
									if(ttTaskFieldsMap.containskey('name')){
										System.debug(LoggingLevel.DEBUG,' task name');
										//taskObject.put(ttTaskFieldsMap.get('name').TelosTouchSF__Salesforce_Field__c , obj1.name);
									}
									if(ttTaskFieldsMap.containskey('status')){
										System.debug(LoggingLevel.DEBUG,' task status');
										//taskObject.put(ttTaskFieldsMap.get('status').TelosTouchSF__Salesforce_Field__c , obj1.status);
									}
									if(ttTaskFieldsMap.containskey('type')){
										if(obj1.type != ''){
											taskObject.put(ttTaskFieldsMap.get('type').TelosTouchSF__Salesforce_Field__c, obj1.type);
										}else if(obj1.type == '' && ttTaskFieldsMap.get('type').TelosTouchSF__Is_Sync_Empty_Field__c == true){
											taskObject.put(ttTaskFieldsMap.get('type').TelosTouchSF__Salesforce_Field__c, '');
										}
									}
									if(String.isNotBlank(clientId) ){
										taskObject.WhoId = clientId;
									}else{
										taskObject.WhoId = null;
									}
									if(ttTaskFieldsMap.containskey('shared')){
										taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , shareWithClients);
									}
									if(ttTaskFieldsMap.containskey('date_due')){
										System.debug(LoggingLevel.DEBUG,' task date_due');
										//taskObject.put(ttTaskFieldsMap.get('date_due').TelosTouchSF__Salesforce_Field__c , date.valueOf(obj1.date_due));
									}
									if(ttTaskFieldsMap.containskey('description')){
										if(obj1.description != ''){
											System.debug(LoggingLevel.DEBUG,' task description');
											//taskObject.put(ttTaskFieldsMap.get('description').TelosTouchSF__Salesforce_Field__c, obj1.description);
										}else if(obj1.description == '' && ttTaskFieldsMap.get('description').TelosTouchSF__Is_Sync_Empty_Field__c == true){
											System.debug(LoggingLevel.DEBUG,' task description');
											//taskObject.put(ttTaskFieldsMap.get('description').TelosTouchSF__Salesforce_Field__c, '');
										}
									}

									if(userMap.containsKey(obj1.assigned_user_id) && Schema.SObjectType.Task.fields.OwnerId.isAccessible() && Schema.SObjectType.Task.fields.OwnerId.isCreateable()){
										//taskObject.OwnerId = userMap.get(obj1.assigned_user_id);
										taskUpsertList.add(taskObject);
									}else{
										ownerNotFoundCount++;
									}
								}
							}
						}else if(obj1.other_id != null && taskMap.containsKey(obj1.other_id) && taskMap.get(obj1.other_id).TelosTouchSF__TT_TaskId__c == null){
							if(Schema.SObjectType.Task.isAccessible() && Schema.SObjectType.Task.isCreateable() && Schema.SObjectType.Task.isUpdateable() &&
									Schema.SObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() && Schema.SObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isCreateable() && Schema.SObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isUpdateable() &&
									Schema.SObjectType.Task.fields.TelosTouchSF__TT_Category__c.isAccessible() && Schema.SObjectType.Task.fields.TelosTouchSF__TT_Category__c.isCreateable() && Schema.SObjectType.Task.fields.TelosTouchSF__TT_Category__c.isUpdateable() &&
									Schema.SObjectType.Task.fields.WhoId.isAccessible() && Schema.SObjectType.Task.fields.WhoId.isCreateable() && Schema.SObjectType.Task.fields.WhoId.isUpdateable() &&
									Schema.SObjectType.Task.fields.OwnerId.isAccessible() && Schema.SObjectType.Task.fields.OwnerId.isCreateable() && Schema.SObjectType.Task.fields.OwnerId.isUpdateable() ){
								Task taskObject = new Task();
								taskObject = taskMap.get(obj1.other_id);
								taskObject.TelosTouchSF__TT_TaskId__c = obj1.id;
								if(taskObject.TelosTouchSF__TT_Category__c == null){
									taskObject.TelosTouchSF__TT_Category__c = 'task';
								}
								if(ttTaskFieldsMap.containskey('shared')){
									if(obj1.shared == true){
										taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'Yes');
									}else{
										taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'No');
									}
								}
								if(taskMap.get(obj1.other_id).LastModifiedDate != null && taskMap.get(obj1.other_id).LastModifiedDate.getTime() < dt.getTime()) {
									if (ttTaskFieldsMap.containskey('client_id')) {
										taskObject.put(ttTaskFieldsMap.get('client_id').TelosTouchSF__Salesforce_Field__c,
												obj1.client_id);
									}
									if (ttTaskFieldsMap.containskey('client_name')) {
										taskObject.put(ttTaskFieldsMap.get('client_name').TelosTouchSF__Salesforce_Field__c,
												obj1.client_name);
									}
									if (ttTaskFieldsMap.containskey('name')) {
										System.debug(LoggingLevel.DEBUG,' task name');
										//taskObject.put(ttTaskFieldsMap.get('name').TelosTouchSF__Salesforce_Field__c, obj1.name);
									}
									if (ttTaskFieldsMap.containskey('status')) {
										System.debug(LoggingLevel.DEBUG,' task status');
										//taskObject.put(ttTaskFieldsMap.get('status').TelosTouchSF__Salesforce_Field__c, obj1.status);
									}
									if (ttTaskFieldsMap.containskey('type')) {
										if (obj1.type != '') {
											taskObject.put(ttTaskFieldsMap.get('type').TelosTouchSF__Salesforce_Field__c, obj1.type);
										} else if (obj1.type == '' &&
														ttTaskFieldsMap.get('type').TelosTouchSF__Is_Sync_Empty_Field__c == true) {
											taskObject.put(ttTaskFieldsMap.get('type').TelosTouchSF__Salesforce_Field__c, '');
										}
									}
									if (contactMap.containskey(obj1.client_id)) {
										System.debug(LoggingLevel.DEBUG,' contact client_Id');
										//taskObject.WhoId = contactMap.get(obj1.client_id).Id;
									}
									if (leadMap.containskey(obj1.client_id)) {
										System.debug(LoggingLevel.DEBUG,' lead client_Id');
										//taskObject.WhoId = leadMap.get(obj1.client_id).Id;
									}
									if(ttTaskFieldsMap.containskey('shared')){
										if(obj1.shared == true){
											taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'Yes');
										}else{
											taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'No');
										}
									}
									if (ttTaskFieldsMap.containskey('date_due')) {
										System.debug(LoggingLevel.DEBUG,' task date_due');
										//taskObject.put(ttTaskFieldsMap.get('date_due').TelosTouchSF__Salesforce_Field__c,
										//date.valueOf(obj1.date_due));
									}
									if (ttTaskFieldsMap.containskey('description')) {
										if (obj1.description != '') {
											System.debug(LoggingLevel.DEBUG,' task description');
											//taskObject.put(ttTaskFieldsMap.get('description').TelosTouchSF__Salesforce_Field__c,
											//obj1.description);
										} else if (obj1.description == '' &&
														ttTaskFieldsMap.get('description').TelosTouchSF__Is_Sync_Empty_Field__c ==
														true) {
											System.debug(LoggingLevel.DEBUG,' task description in else condition');
											//taskObject.put(ttTaskFieldsMap.get('description').TelosTouchSF__Salesforce_Field__c, '');
										}
									}
								}
								if (userMap.containsKey(obj1.assigned_user_id)) {
									//taskObject.OwnerId = userMap.get(obj1.assigned_user_id);
									taskUpsertList.add(taskObject);
								} else {
									ownerNotFoundCount++;
								}
							}
						}else{
							Task taskObject = new Task();
							if(contactMap.containskey(obj1.client_id)){
								taskObject.WhoId = contactMap.get(obj1.client_id).Id;
							}if(leadMap.containskey(obj1.client_id)){
								taskObject.WhoId = leadMap.get(obj1.client_id).Id;
							}
							if(ttTaskFieldsMap.containskey('client_id')){
								taskObject.put(ttTaskFieldsMap.get('client_id').TelosTouchSF__Salesforce_Field__c, obj1.client_id);
							}
							if(ttTaskFieldsMap.containskey('type')){
								taskObject.put(ttTaskFieldsMap.get('type').TelosTouchSF__Salesforce_Field__c, obj1.type);
							}
							taskObject.TelosTouchSF__TT_TaskId__c = obj1.id;
							if(ttTaskFieldsMap.containskey('client_name')){
								taskObject.put(ttTaskFieldsMap.get('client_name').TelosTouchSF__Salesforce_Field__c , obj1.client_name);
							}
							taskObject.TelosTouchSF__Source__c = 'TelosTouch';
							if(ttTaskFieldsMap.containskey('name')){
								taskObject.put(ttTaskFieldsMap.get('name').TelosTouchSF__Salesforce_Field__c , obj1.name);
							}
							if(ttTaskFieldsMap.containskey('status')){
								taskObject.put(ttTaskFieldsMap.get('status').TelosTouchSF__Salesforce_Field__c , obj1.status);
							}
							if(ttTaskFieldsMap.containskey('shared')){
								if(obj1.shared == true){
									taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'Yes');
								}else{
									taskObject.put(ttTaskFieldsMap.get('shared').TelosTouchSF__Salesforce_Field__c , 'No');
								}
							}
							if(ttTaskFieldsMap.containskey('date_due')){
								taskObject.put(ttTaskFieldsMap.get('date_due').TelosTouchSF__Salesforce_Field__c , date.valueOf(obj1.date_due));
							}
							if(ttTaskFieldsMap.containskey('description')){
								taskObject.put(ttTaskFieldsMap.get('description').TelosTouchSF__Salesforce_Field__c , obj1.description);
							}
							if(userMap.containsKey(obj1.assigned_user_id) && Schema.SObjectType.Task.fields.OwnerId.isCreateable() && Schema.SObjectType.Task.fields.OwnerId.isUpdateable()){
								taskObject.OwnerId = userMap.get(obj1.assigned_user_id);
								taskObject.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
								taskUpsertList.add(taskObject);
							}else{
								ownerNotFoundCount++;
							}
						}
					}
				}
				if(taskUpsertList.size()> 0){
					if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isCreateable()  && Schema.sObjectType.Task.isUpdateable()){
						//  Database.upsert (taskUpsertList ,false);
						Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
						Database.UpsertResult[] srList = Database.upsert(taskUpsertList,false);
						for (Database.UpsertResult sr : srList) {
							String errorMessage = 'Failed Task sync records from TelosTouch to Salesforce :';
							if (sr.isSuccess()) {
								if(showLogs){
									createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', 'Tasks sync successfully from TelosTouch to Salesforce.',sr.getId()));
								}
							}
							else {
								for(Database.Error err : sr.getErrors()) {
									errorMessage += err.getMessage();
								}
								if(showLogs){
									createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, sr.getId()));
								}
							}
						}
					}
					TelosTouchSF.UserTriggerHandler.createLogRecord('success','Tasks sync successfully from TelosTouch to Salesforce.','Syncronisation réussie des Tâches de TelosTouch à Salesforce.', taskUpsertList.size());
				}
			}
			if(OwnerNotFoundCount > 0){
				TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.Failed_Text,'Tasks Sync Failed as Task Owner Not Found in Salesforce','Échec de la Syncronisation des Tâches car propriétaire des Tâches non trouvé sur Salesforce', OwnerNotFoundCount);
			}
			if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
				insert createListOfLog;
			}
			if(endPoint == numberOfRecords){
				if(syncObject == null){
					Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(null, null, null, 'Campaign',null, null, null));
				}else{
					Batch_SyncAllTaskWithTTActions taskBatch = new Batch_SyncAllTaskWithTTActions(syncObject, forFirstTime);
					Database.executeBatch((taskBatch),90);
				}
			}
		}
		catch(Exception ex){
			System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber());
			List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
			Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
			TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
			if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()
					&& Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()){
				logObj.TelosTouchSF__Result__c = 'Failure';
				logObj.TelosTouchSF__Comments__c = ex.getMessage();
				String errorMessage = ex.getMessage() + ex.getStackTraceString() + ' Line number: ' + ex.getLineNumber() + ' Class: GetTaskFromTTQueueable';
				if(showLogs){
					createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, ''));
				}
			}
			if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()){
				logObj.TelosTouchSF__Total_Records_Count__c = 0;
			}
			Datetime now = Datetime.now();
			Integer offset = UserInfo.getTimezone().getOffset(now);
			Datetime local = now.addSeconds(offset/1000);
			if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
				logObj.TelosTouchSF__LastUpdated__c = local;
			}
			if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable()){
				logObj.TelosTouchSF__Log_Type__c='Main Log';
			}
			if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
				insert logObj;
			}
			if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
				insert createListOfLog;
			}
		}
	}
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ResponseTaskWrapper is used to get id,name,status,client_id,client_name,description,shared,date_due and modified_at.
*/
	public class ResponseTaskWrapper {
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String id {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String name {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String status {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String client_id {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String client_name {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String description {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public Boolean shared {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String date_due {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String modified_at {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String type {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String other_id {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String created_by_id {get;set;}
		/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
		public String assigned_user_id {get;set;}
	}
}