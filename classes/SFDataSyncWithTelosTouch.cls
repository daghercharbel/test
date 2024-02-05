/**
* @author Cloud Analogy
* @date 02/08/2021
* @description SFDataSyncWithTelosTouch class is using for syncing contact/lead and task with TelosTouch Used TelosTouch API.
*/
global with sharing class SFDataSyncWithTelosTouch {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public String vfPageURL{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public Boolean isAdmin{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public Boolean showManualSync{get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to create default remote site setting.
*/
    public Boolean viewAllDataEnabled{ get; set; }
	/**
* @author Cloud Analogy
* @date 02/08/2021
* @description createDefualtRemoteSiteSetting ....
*/
	public void createDefualtRemoteSiteSetting() {
        Profile currentProfileViewAll = [SELECT Id, PermissionsViewAllData FROM Profile WHERE Id =: UserInfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1];
        if(currentProfileViewAll != null){
            viewAllDataEnabled = currentProfileViewAll.PermissionsViewAllData;
        }
        vfPageURL = System.URL.getSalesforceBaseURL().toExternalForm();
        TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting(vfPageURL,'Rest_API_Callout');
        PermissionSetForInsightObjMD obj = new  PermissionSetForInsightObjMD();
        obj.createPermissionSet('TTPSetForInsightObjMDRelations','TT PSet For Insight Obj MD Relations');
        String UserId = UserInfo.getUserId();
        List<user> user = new List<user>();
        if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() && Schema.SObjectType.Profile.isAccessible() && Schema.SObjectType.Profile.isQueryable() &&
                Schema.sObjectType.User.fields.profileId.isAccessible()){
            String strSystemAdministrator = 'System Administrator';
            String strAdministrateursysteme = 'Administrateur système';
            user = [SELECT Id FROM User WHERE Id=:UserId AND profileId =:[SELECT Id FROM Profile WHERE (Name =: strSystemAdministrator OR Name =: adminCredentials.TelosTouchSF__ConfigPageVisible__c) OR (Name =: strAdministrateursysteme)]];
            if(user.size() >0){
                isAdmin = true;
            }else{
                isAdmin = false;
            }
        }
        if(!isAdmin){
            List<TelosTouchSF__Manual_Sync_Profiles__c> manualSyncProfilesList = new List<TelosTouchSF__Manual_Sync_Profiles__c>();
            Id currentProfileId = UserInfo.getProfileId();
            Profile currentProfile = [SELECT Name FROM Profile WHERE Id=: currentProfileId WITH SECURITY_ENFORCED];
            manualSyncProfilesList = [SELECT TelosTouchSF__Profile_Name__c FROM TelosTouchSF__Manual_Sync_Profiles__c WHERE TelosTouchSF__Profile_Name__c=: currentProfile.Name WITH SECURITY_ENFORCED];
            if(manualSyncProfilesList.size()>0){
                showManualSync = true;
            }else{
                showManualSync = false;
            }
        }else{
            showManualSync = true;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to sync all tasks from SF to TT.
* @param tasklist gets the list of tasks
* @return taskLogWrapper taskLogObj ....
*/
    Public static taskLogWrapper syncAllTaskstoTTActions(List<Task> tasklist){
        try{
            Map<String,User> userMap = new Map<String,User>();
            List<User> userList = new List<User>();
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            List<Task> newtasklist = new List<Task>();
            User taskOwnerUser = new User();
            taskLogWrapper taskLogObj = new taskLogWrapper();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.isActive.isAccessible() &&
                    Schema.sObjectType.User.fields.isActive.isAccessible() &&
                    Schema.sObjectType.User.fields.Name.isAccessible() && Schema.sObjectType.User.fields.isActive.isAccessible()){
                userList = [SELECT Id, Name, TelosTouchSF__TT_UserName__c,TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Profile.UserLicense.Name != null AND TelosTouchSF__TT_UserId__c  != NULL AND isActive = true];
            }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            List<TelosTouchSF__TT_Salesforce_Mapping__c> TasktelosTouchMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isAccessible()){
                        String strTask = 'Task';
                        TasktelosTouchMappingList = [SELECT Id, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Object_Name__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: strTask AND TelosTouchSF__Is_Deleted__c= false LIMIT 50000];
            }
            if(adminCredentials != null){
                String endPointURL='';
                Map<String, String> headersMap = new Map<String, String>();
                List<String> restrictedRecordList2 = new List <String>();
                Map<Id, List<Task>> ownerIdVsTaskListMap = new Map<Id, List<Task>>();
                if(adminCredentials.TelosTouchSF__NotSyncTaskIfHaving__c != null){
                    String restrictedRecord = adminCredentials.TelosTouchSF__NotSyncTaskIfHaving__c;
                    List<String> restrictedRecordList = restrictedRecord.split(',');
                    for(String restricted : restrictedRecordList){
                        restrictedRecordList2.add(restricted.toLowerCase().trim());
                    }
                }
                if(adminCredentials.TelosTouchSF__Instance_URL__c != null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/actions/mass';
                }
                headersMap.put('Content-Type','application/json');
                headersMap.put('Accept','application/json');
                for(Task taskObj : tasklist){
                    String subjectValue = taskObj.Subject != null ? (taskObj.subject).toLowerCase() : '';
                    if(restrictedRecordList2.size() == 0 ){
                        if(!ownerIdVsTaskListMap.containsKey(taskObj.OwnerId)){
                            ownerIdVsTaskListMap.put(taskObj.OwnerId, new List<Task>{taskObj});
                        }else{
                            ownerIdVsTaskListMap.get(taskObj.OwnerId).add(taskObj);
                        }
                    }else if(!restrictedRecordList2.contains(subjectValue)){
                        if(!ownerIdVsTaskListMap.containsKey(taskObj.OwnerId)){
                            ownerIdVsTaskListMap.put(taskObj.OwnerId, new List<Task>{taskObj});
                        }else{
                            ownerIdVsTaskListMap.get(taskObj.OwnerId).add(taskObj);
                        }
                    }

                }
                for(Id ownerId : ownerIdVsTaskListMap.keySet()){
                    String UserToken, Status = '', isShareWithClient = 'false',bodynew = '', bodyold = '', body1 = '{"actions" :[', body2 = '{"actions" :[';
                    taskOwnerUser = userMap.get(ownerId);
                    if(taskOwnerUser != null && taskOwnerUser.TelosTouchSF__TT_UserName__c != null && taskOwnerUser.TelosTouchSF__Auth_Token__c != null){
                        UserToken = taskOwnerUser.TelosTouchSF__Auth_Token__c;
                        headersMap.put('Authorization', 'Bearer '+UserToken);
                        for(Task taskObj : ownerIdVsTaskListMap.get(ownerId)){
                            if(taskObj.TelosTouchSF__TT_Category__c == null){
                                taskObj.TelosTouchSF__TT_Category__c = 'task';
                            }
                            //For Updating Old Tasks with TT ID not null
                            if(taskObj.TelosTouchSF__Share_with_client_s__c != null){
                                if(taskObj.TelosTouchSF__Share_with_client_s__c == 'Yes'){
                                    isShareWithClient = 'true';
                                }else{
                                    isShareWithClient = 'false';
                                }
                            }else{
                                isShareWithClient = 'false';
                            }
                            if(taskObj.Status !=null && taskObj.Status.length() != 0){
                                if(taskObj.Status == 'Completed'){
                                    Status = 'completed';
                                }else {
                                    Status = 'open';
                                }
                            }else{
                                Status = 'open';
                            }
                            String duedate;
                            if(taskObj.ActivityDate != null){
                                Date d = taskObj.ActivityDate;
                                Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
                                duedate = myDT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                            }else{
                                Date d = Date.today();
                                Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
                                duedate = myDT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                            }
                            Map<String, String> TaskVSTTMap = new Map<String, String>();
                            if(TasktelosTouchMappingList != null && TasktelosTouchMappingList.size() >0){
                                for(TelosTouchSF__TT_Salesforce_Mapping__c mappingObj : TasktelosTouchMappingList){
                                    if((mappingObj.TelosTouchSF__Salesforce_Field__c != 'ActivityDate') && (mappingObj.TelosTouchSF__Salesforce_Field__c != 'TelosTouchSF__Share_with_client_s__c') && (mappingObj.TelosTouchSF__Salesforce_Field__c != 'Status' )){
                                        TaskVSTTMap.put(mappingObj.TelosTouchSF__TT_Field__c,(String)taskObj.get(mappingObj.TelosTouchSF__Salesforce_Field__c) != null ? (String)taskObj.get(mappingObj.TelosTouchSF__Salesforce_Field__c) : '');
                                    }else{
                                        TaskVSTTMap.put('date_due', duedate);
                                        TaskVSTTMap.put('shared', isShareWithClient);
                                        TaskVSTTMap.put('status', Status);
                                    }
                                    if(taskVSTTMap.containskey('type') && (taskVSTTMap.get('type') == '') ){
                                        taskVSTTMap.put('type', 'task');
                                    }
                                    if(taskVSTTMap.containskey('client_id') && (taskVSTTMap.get('client_id') == '') ){
                                        taskVSTTMap.remove('client_id');
                                    }
                                    TaskVSTTMap.put('assigned_user_id',taskOwnerUser.TelosTouchSF__TT_UserId__c);
                                    TaskVSTTMap.put('assigned_user_name',taskOwnerUser.Name);
                                    TaskVSTTMap.put('other_id', taskObj.Id);
                                }
                            }
                            //Below code if The task is Old One And have tttaskId Then it will update it
                            if(taskObj.TelosTouchSF__TT_TaskId__c != null && taskObj.TelosTouchSF__TT_TaskId__c.length() > 0 && UserToken != null){
                                TaskVSTTMap.put('id',taskObj.TelosTouchSF__TT_TaskId__c);
                                bodyold = JSON.serialize(TaskVSTTMap);
                                body1 =  body1 + bodyold + ',';
                            }
                            // *******************Below code if The task is new One *******************
                            else if(UserToken != null){
                                bodynew = JSON.serialize(TaskVSTTMap);
                                body2 =  body2 + bodynew + ',';
                            }
                        }
                        body1 = body1.removeEnd(',') + ']}';
                        body2 = body2.removeEnd(',') + ']}';
                        if(bodyold != ''){
                            Map<String, String> responseString1 = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, headersMap, body1 );
                            if(responseString1.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }else if(responseString1.get('status_code') == '500'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                            }else{
                                if(responseString1.get('status_code').length() > 0){
                                    list<String>StatusCodeList = responseString1.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseString1.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseString1.get('status_code'),1));
                                    }
                                }
                            }
                            if(responseString1.get('body') != null){
                                List<Object> responseList = (List<Object>)JSON.deserializeUntyped(responseString1.get('body'));
                                Set<String> updatedTaskTTIdSet = new Set<String>();
                                for(Object obj : responseList){
                                    Map<String, Object>  mapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                                    if(mapObject.containsKey('id') && mapObject.get('id') != null ){
                                        taskLogObj.taskSuccessCount++;
                                        updatedTaskTTIdSet.add((String)mapObject.get('id'));
                                    }else{
                                        taskLogObj.taskErrorCount++;
                                    }
                                }
                                for(task taskObj1 : tasklist){
                                    if(updatedTaskTTIdSet.contains(taskObj1.TelosTouchSF__TT_TaskId__c)){
                                        if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isCreateable() && Schema.sObjectType.Task.isUpdateable()
                                                && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isCreateable()
                                                && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isUpdateable() ) {
                                            taskObj1.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                            taskObj1.TelosTouchSF__TT_Needs_Sync__c = false;
                                            newtasklist.add(taskObj1);
                                        }
                                    }
                                }
                            }
                        }
                        if(bodynew != ''){
                            Map<String, String> responseString = TelosTouchSF.TelosTouchUtility.getResponse('POST', endPointURL, headersMap, body2 );
                            if(responseString.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }else if(responseString.get('status_code') == '500'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                            }else{
                                if(responseString.get('status_code').length() > 0){
                                    list<String>StatusCodeList = responseString.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseString.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseString.get('status_code'),1));
                                    }
                                }
                            }
                            if(responseString.get('body') != null && responseString.get('body').contains('id')){
                                List<Object> responseList = (List<Object>)JSON.deserializeUntyped(responseString.get('body'));
                                Map<String,String> otherIdVsTTTaskIdMap = new Map<String,String>();
                                for(Object obj : responseList){
                                    Map<String, Object>  mapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                                    if(mapObject.containsKey('id') && mapObject.get('id') != null && mapObject.containsKey('other_id') && mapObject.get('other_id') != null){
                                        otherIdVsTTTaskIdMap.put(String.valueOf(mapObject.get('other_id')),  String.valueOf(mapObject.get('id')));
                                    }
                                }
                                if(otherIdVsTTTaskIdMap != null){
                                    for(task taskObj1 : tasklist){
                                        if(otherIdVsTTTaskIdMap.containsKey(taskObj1.Id)){
                                            if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isCreateable() && Schema.sObjectType.Task.isUpdateable()
                                                    && Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isCreateable()
                                                    && Schema.sObjectType.Task.fields.TelosTouchSF__TT_TaskId__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isAccessible()
                                                    && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isUpdateable() && Schema.sObjectType.Task.fields.TelosTouchSF__TT_LastSyncTime__c.isCreateable()) {
                                                taskObj1.TelosTouchSF__TT_TaskId__c = otherIdVsTTTaskIdMap.get(taskObj1.Id);
                                                taskObj1.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                                taskObj1.TelosTouchSF__TT_Needs_Sync__c = false;
                                                taskLogObj.taskSuccessCount++;
                                                newtasklist.add(taskObj1);
                                            }
                                        }else{
                                            taskLogObj.taskErrorCount++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(newtasklist.size() > 0 && Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isUpdateable() && Schema.sObjectType.Task.isCreateable()){
                    Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
                    Database.UpsertResult[] srList = Database.upsert(newtasklist,false);
                    for (Database.UpsertResult sr : srList) {
                        String errorMessage = 'Failed Task sync records from TelosTouch to Salesforce :';
                        if (sr.isSuccess()) {
                            if(showLogs){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', 'Tasks sync successfully from TelosTouch to Salesforce.',sr.getId()));
                            }
                        }
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            if(showLogs){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, sr.getId()));
                            }
                        }
                    }
                }
                if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                    insert logList;
                }
            }
            return taskLogObj;
        }Catch(Exception ex){
            TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
            List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable()){
                logObj.TelosTouchSF__Result__c = 'Failure';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable()){
                logObj.TelosTouchSF__Total_Records_Count__c = 0;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()){
                logObj.TelosTouchSF__Comments__c = ex.getMessage().abbreviate(254);
                String errorMessage = ex.getMessage() + ex.getStackTraceString() + ' Line number: ' + ex.getLineNumber()  + ' Class: SFDataSyncWithTelosTouch';
                if(showLogs){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, ''));
                }
            }
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
                logObj.TelosTouchSF__LastUpdated__c = local;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable()){
                logObj.TelosTouchSF__Log_Type__c='Main Log';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                insert logObj;
            }
            if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert createListOfLog;
            }
            return null;
        }
    }

    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to sync selected tasks
* @param taskIdsList gets the list of tasks ids
*/
    @AuraEnabled
    Public static void syncSelectedTasks(String taskIdsList){
        try{
            if(taskIdsList != null){
                String s = taskIdsList.deleteWhitespace();
                s = s.remove('[');
                s = s.remove(']');
                List<String> sid = s.split(',');
                Set<Id> newIdSet = new Set<Id>();
                for(String sobj: sid){
                    String temp = sobj.replace('"','');
                    newIdSet.add(Id.valueof(temp));
                }
                if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable() &&
                        Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible()){
                    List<Task> tasklist = [SELECT Id, TelosTouchSF__Share_with_client_s__c FROM Task WHERE Id IN: newIdSet LIMIT 10000];
                    for(Task taskObject : tasklist){
                        if(taskObject.TelosTouchSF__Share_with_client_s__c != 'Yes'){
                            if(Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isCreateable() && Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isUpdateable()
                                    && Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible()){
                                taskObject.TelosTouchSF__Share_with_client_s__c  = 'Yes';
                            }
                        }
                    }
                    if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isUpdateable() && Schema.sObjectType.Task.isCreateable() ){
                        upsert tasklist;
                    }
                }
            }
        } Catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }

    //Get all logs in log tab
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to get All Logs
* @param pageNumber gets the page Number
* @param pageSize gets the page Size
* @return contactDataTableWrapper objDT ....
*/
    @AuraEnabled
    Public static contactDataTableWrapper getAllLogs(Decimal pageNumber, Decimal pageSize){
        try{
            Integer pSize = (Integer)pageSize;
            Integer pNumber = (Integer)pageNumber;
            Integer offset = (pNumber - 1) * pSize;
            Integer totalRecords;
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isQueryable()){
                String strMainLog = 'Main Log';
                totalRecords = [SELECT COUNT() FROM TelosTouchSF__TT_Log__c WHERE TelosTouchSF__Log_Type__c =: strMainLog LIMIT 50000];
            }
            Integer recordEnd = pSize * pNumber;
            contactDataTableWrapper objDT =  new contactDataTableWrapper();
            objDT.pageSize = pSize;
            objDT.pageNumber = pNumber;
            objDT.recordStart = offset + 1;
            objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            objDT.totalRecords = totalRecords;
            if(UserInfo.getLanguage().contains('en')){
                objDT.currentUserLanguage = 'en';
            }else if(UserInfo.getLanguage().contains('fr')){
                objDT.currentUserLanguage = 'fr';
            }else{
                objDT.currentUserLanguage = 'n/a';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isQueryable() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.Name.isAccessible()){
                String strMainLog = 'Main Log';
                objDT.allLogsList = [SELECT id, Name, TelosTouchSF__Result__c, TelosTouchSF__LastUpdated__c, CreatedDate, TelosTouchSF__Total_Records_Count__c, TelosTouchSF__Comments__c, TelosTouchSF__Comments_FR__c FROM TelosTouchSF__TT_Log__c WHERE TelosTouchSF__Log_Type__c =: strMainLog ORDER  BY CreatedDate DESC LIMIT :pSize OFFSET :offset];

            }
            return objDT;
        }
        Catch(Exception ex){
            return null;
        }
    }

    //Get latest log in User Sync tab
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to get latest Logs
* @return contactDataTableWrapper wrapper ....
*/
    @AuraEnabled
    Public static contactDataTableWrapper getLatestLogs(){
        try{
            contactDataTableWrapper  wrapper = new contactDataTableWrapper();
            List<TelosTouchSF__TT_Log__c> logsList = new List<TelosTouchSF__TT_Log__c>();
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isQueryable() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()){
                String strMainLog = 'Main Log';
                logsList = [SELECT id,TelosTouchSF__LastUpdated__c,TelosTouchSF__Comments__c, TelosTouchSF__Comments_FR__c FROM TelosTouchSF__TT_Log__c WHERE TelosTouchSF__Log_Type__c =: strMainLog ORDER  BY TelosTouchSF__LastUpdated__c  DESC LIMIT 1];
            }
            if(logsList.size() >0){
                wrapper.allLogsList = logsList;
            }
            if(adminCredentials != null){
                wrapper.getCustomMetadataSetting = adminCredentials;
            }
            List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
            if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() &&
                    Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
                    Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() ){
                        String strAborted                       = 'Aborted';
                        String strCompleted                     = 'Completed';
                        String strFailed                        = 'Failed';
                        String strGetClientsFromTTQueueable     = 'GetClientsFromTTQueueable';
                        String strGetTaskFromTTQueueable        = 'GetTaskFromTTQueueable';
                        String strGetCampaignsFromTTQueueable   = 'GetCampaignsFromTTQueueable';

                asyncApexJobList = [SELECT Id,ApexClass.Name FROM AsyncApexJob WHERE (Status !=: strAborted AND Status !=: strCompleted AND Status !=: strFailed ) AND (ApexClass.Name =: strGetClientsFromTTQueueable
                OR ApexClass.Name =: strGetTaskFromTTQueueable
                OR ApexClass.Name =: strGetCampaignsFromTTQueueable)
                LIMIT 3];
            }
            if (asyncApexJobList.size() > 0) {
                wrapper.asyncJobstatus = false;
            }else{
                wrapper.asyncJobstatus = true;
            }
            return wrapper;
        }
        Catch(Exception ex){
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to update contacts and leads
* @param createdcontactlist gets the list of contacts
* @param createdleadlist gets the list of lead
* @param action ....
* @param oldContactMap ....
* @param oldLeadMap ....
* @param oldAccountMap ....
@return clientLogWrapper ....
     */
    Public static clientLogWrapper updateContactDetails(List<Contact> createdcontactlist,List<Lead> createdleadlist, String action, Map<Id, Contact> oldContactMap, Map<Id, Lead> oldLeadMap, Map<ID, Account> oldAccountMap){
        try{
            Map<Id,User> userMap = new Map<Id,User>();
            List<User> userList = new List<User>();
            List<Contact> ContactListtoBeUpdated = new List<Contact>();
            List<Lead> LeadListtoBeUpdated = new List<Lead>();
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            List<TelosTouchSF__TT_Salesforce_Mapping__c> leadTelosTouchMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() &&
                    Schema.sObjectType.User.fields.Name.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
                    Schema.sObjectType.User.fields.username.isAccessible() &&
                    Schema.sObjectType.User.fields.isActive.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                userList = [SELECT Id, Name,
                TelosTouchSF__Auth_Token__c, username,
                TelosTouchSF__TT_UserName__c,
                TelosTouchSF__TT_UserId__c
                From User
                WHERE TelosTouchSF__TT_UserId__c  != null
                AND isActive = true  ALL ROWS];
            }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            List<TelosTouchSF__TT_Salesforce_Mapping__c> contactTelosTouchMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable()  &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible()){
                String strContact = 'Contact';
                contactTelosTouchMappingList = [SELECT Id, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Object_Name__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: strContact AND TelosTouchSF__Is_Deleted__c=false LIMIT 500 ];
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Deleted__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible()){
                String strLead = 'Lead';
                leadTelosTouchMappingList = [SELECT Id, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Object_Name__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c =: strLead AND TelosTouchSF__Is_Deleted__c = false LIMIT 500  ];
            }
            clientLogWrapper clientLogObj = new clientLogWrapper();
            if(createdcontactlist != null && createdcontactlist.size()> 0){
                for(Contact conObject : createdcontactlist){
                    if(conObject.TelosTouchSF__Subscribed__c == null){
                        conObject.TelosTouchSF__Subscribed__c = 'Yes';
                    }if(conObject.TelosTouchSF__Source__c == null){
                        conObject.TelosTouchSF__Source__c = 'Salesforce';
                    }if(conObject.TelosTouchSF__Language__c == null){
                        conObject.TelosTouchSF__Language__c = 'English';
                    }
                }
                Map<String, String> ClientIdsGeneratedMap = new Map<String, String>();
                List<Contact> clientlist = new List<Contact>();
                clientlist.addAll(createdcontactlist);
                if(authenticationCredential.TelosTouchSF__Access_Token__c != null){
                    ClientIdsGeneratedMap = makePostCallout(clientlist,null,contactTelosTouchMappingList,leadTelosTouchMappingList,userMap, oldContactMap, oldLeadMap, oldAccountMap);
                }
                if(ClientIdsGeneratedMap != null){
                    for(Integer i=0; i< clientlist.size(); i++){
                        if(!ClientIdsGeneratedMap.containsKey(clientlist[i].id) && ClientIdsGeneratedMap.containsKey(clientlist[i].Email) && ClientIdsGeneratedMap.get(clientlist[i].Email) == 'Duplicate'){
                            if(Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isUpdateable() ){
                                clientlist[i].TelosTouchSF__Error_Message__c = 'Duplicate Email';
                            }
                            ContactListtoBeUpdated.add(clientlist[i]);
                            clientLogObj.contactErrorCount++;
                        }else{
                            if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable()  ){
                                clientlist[i].TelosTouchSF__TT_Client_Id__c = ClientIdsGeneratedMap.get(clientlist[i].Id);
                            }
                            if(Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isUpdateable() ){
                                clientlist[i].TelosTouchSF__Error_Message__c = '';
                            }
                            if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_LastSyncTime__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_LastSyncTime__c.isUpdateable() ){
                                clientlist[i].TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                            }     
                            if((clientlist[i].TelosTouchSF__TT_Client_Id__c != null) && (clientlist[i].TelosTouchSF__TT_Client_Id__c != '') &&
                                Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isUpdateable())
                            {
                                ContactListtoBeUpdated.add(clientlist[i]);
                                clientLogObj.contactSuccessCount++;
                            }
                        }
                    }
                }
            }
            if(createdleadlist != null && createdleadlist.size()> 0){
                List<Lead> newLeadList = new List<Lead>();
                for(Lead leadObject : createdleadlist){
                    if(leadObject.TelosTouchSF__Subscribed__c == null && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Subscribed__c.isUpdateable()){
                        leadObject.TelosTouchSF__Subscribed__c = 'Yes';
                    }if(leadObject.TelosTouchSF__Source__c == null && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Source__c.isUpdateable()){
                        leadObject.TelosTouchSF__Source__c = 'Salesforce';
                    }if(leadObject.TelosTouchSF__Language__c == null && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Language__c.isUpdateable()){
                        leadObject.TelosTouchSF__Language__c = 'English';
                    }
                    if(leadObject.Status != 'Closed - Converted' && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                        newLeadList.add(leadObject);
                    }
                }
                List<Lead> clientleadlist = new List<Lead>();
                Map<String, String> ClientIdsGeneratedMap = new Map<String, String>();
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                    clientleadlist.addAll(newLeadList);
                }
                if(authenticationCredential.TelosTouchSF__Access_Token__c != null){
                    ClientIdsGeneratedMap = makePostCallout(null,clientleadlist,contactTelosTouchMappingList,leadTelosTouchMappingList,userMap, oldContactMap, oldLeadMap, oldAccountMap);
                }
                if(ClientIdsGeneratedMap != null && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                    for(Integer i=0; i< clientleadlist.size(); i++){
                        if(!ClientIdsGeneratedMap.containsKey(clientleadlist[i].id) && ClientIdsGeneratedMap.containsKey(clientleadlist[i].Email) && ClientIdsGeneratedMap.get(clientleadlist[i].Email) == 'Duplicate'){
                            if(Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isUpdateable()){
                                clientleadlist[i].TelosTouchSF__Error_Message__c = 'Duplicate Email';
                            }
                            if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                                LeadListtoBeUpdated.add(clientleadlist[i]);
                            }
                            clientLogObj.leadErrorCount++;
                        }else{
                            if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() ){
                                clientleadlist[i].TelosTouchSF__TT_Client_Id__c = ClientIdsGeneratedMap.get(clientleadlist[i].Id);

                            }
                            if(Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isUpdateable() ){
                                clientleadlist[i].TelosTouchSF__Error_Message__c = '';
                            }
                            if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_LastSyncTime__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_LastSyncTime__c.isUpdateable() ){
                                clientleadlist[i].TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                            }
                            if((clientleadlist[i].TelosTouchSF__TT_Client_Id__c != null) && (clientleadlist[i].TelosTouchSF__TT_Client_Id__c != '')
                                    && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                                clientLogObj.leadSuccessCount++;
                                LeadListtoBeUpdated.add(clientleadlist[i]);
                            }
                        }
                    }
                }
            }

            Map <String, Schema.SObjectType> schemaMapofAllSobject = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> MapofContactObj = schemaMapofAllSobject.get('Contact').getDescribe().fields.getMap();
            List<String> ContactFieldApiNameList = new List<String>();
            for(Schema.SObjectField sObjectfield : MapofContactObj.Values())
                {
                    schema.describefieldresult dfield = sObjectfield.getDescribe();
                    ContactFieldApiNameList.add(dfield.getname());
                }

            Map <String, Schema.SObjectField> MapofLeadtObj = schemaMapofAllSobject.get('Lead').getDescribe().fields.getMap();
            List<String> LeadFieldApiNameList = new List<String>();
            for(Schema.SObjectField sObjectfield : MapofLeadtObj.Values())
            {
                schema.describefieldresult dfield = sObjectfield.getDescribe();
                LeadFieldApiNameList.add(dfield.getname());
            }
            if( Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                if(LeadListtoBeUpdated != null && LeadListtoBeUpdated.size() > 0 && action != 'updateLead' && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                    Database.update(LeadListtoBeUpdated,false);
                }
            }
            if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isUpdateable() ){
                if(ContactListtoBeUpdated != null && ContactListtoBeUpdated.size() > 0 && action != 'updateContact'){
                    Database.update(ContactListtoBeUpdated,false);
                }
            }

            if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert createListOfLog;
            }
            System.debug('clientLogObj:: '+clientLogObj);
            TelosTouchUtility.saveLogSyncronous(JSON.serialize(TelosTouchUtility.lstTTLog));
            return clientLogObj;
        }
        Catch(Exception ex){
            System.debug(' Error is: '+ ex.getMessage() + ' at line '+ ex.getLineNumber());
            TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
            List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable()){
                logObj.TelosTouchSF__Result__c = 'Failure';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable()){
                logObj.TelosTouchSF__Total_Records_Count__c = 0;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()){
                logObj.TelosTouchSF__Comments__c = ex.getMessage().abbreviate(254);
                String errorMessage = ex.getMessage() + ex.getStackTraceString() + ' Line number: ' + ex.getLineNumber() + ' Class: SFDataSyncWithTelosTouch';
                if(showLogs){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, ''));
                }
            }
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
                logObj.TelosTouchSF__LastUpdated__c = local;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable()){
                logObj.TelosTouchSF__Log_Type__c='Main Log';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                insert logObj;
            }
            if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert createListOfLog;
            }
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to make PostCallout
* @param clientlist 
* @param clientleadlist
* @param contactTelosTouchMappingList gets the list of telosTouch Mapping
* @param leadTelosTouchMappingList gets the list of telosTouch Mapping of leads
* @param userMap gets the user token
* @param oldContactMap ....
* @param oldLeadMap ....
* @param oldAccountMap ....
@return Map<String, String> ...
     */
    public static Map<String, String> makePostCallout(List<Contact> clientlist,List<Lead> clientleadlist,List<TelosTouchSF__TT_Salesforce_Mapping__c> contactTelosTouchMappingList, List<TelosTouchSF__TT_Salesforce_Mapping__c> leadTelosTouchMappingList, Map<Id, User> userMap, Map<Id, Contact> oldContactMap, Map<Id, Lead> oldLeadMap, Map<ID, Account> oldAccountMap) {
        try{
            //Integer usagelimit, maxlimit,usagelimit1, maxlimit1;
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            String postBody = '', putBody = '', addCustomFields = '',finalJSONPost = '{"contacts" :[',finalJSONPut = '{"contacts" :[', endpoint;
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            Map<String, String> OtherIdVsClientIdMap = new Map<String, String>();
            Map<String, String> headersMap = new Map<String, String>();
            set<ID> requestIDs = new set<ID>();
            set<ID> responseIDs = new set<ID>();
            List<Contact> contactUpdateList = new List<Contact>();
            List<Lead> leadUpdateList = new List<Lead>();
            List<Account> accountUpdateList = new List<Account>();
            HttpRequest request = new HttpRequest();
            if(adminCredentials != null){
                if(adminCredentials.TelosTouchSF__Instance_URL__c != null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)){
                    endpoint = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/contacts';
                }
                if(String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c)){
                    headersMap.put('Authorization','Bearer '+authenticationCredential.TelosTouchSF__Access_Token__c);
                }
                headersMap.put('Content-Type','application/json');
                headersMap.put('Accept','application/json');

                Map<String, String> ContactVSTTMap = new Map<String, String>();
                Map<String, String> customFieldsMap = new Map<String, String>();
                Map<String, Contact> emailVsContactObjMap = new Map<String, Contact>();
                if(clientlist != null && clientlist.size() > 0){
                    for(Contact conObject : clientlist){
                        if(!emailVsContactObjMap.containsKey(conObject.email)){
                            emailVsContactObjMap.put(conObject.email, conObject);
                        }else{
                            OtherIdVsClientIdMap.put(conObject.email, 'Duplicate');
                        }
                    }
                    for(Contact con : emailVsContactObjMap.values()){
                        for(TelosTouchSF__TT_Salesforce_Mapping__c mappingObj : contactTelosTouchMappingList){
                            if(mappingObj.TelosTouchSF__TT_Field__c != 'Custom Fields'){
                                ContactVSTTMap.put(mappingObj.TelosTouchSF__TT_Field__c,  String.valueOf(con.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) != null ?  String.valueOf(con.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) : '');
                            }else if(mappingObj.TelosTouchSF__TT_Field__c == 'Custom Fields' && String.valueOf(con.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) != null){
                                customFieldsMap.put(mappingObj.TelosTouchSF__Salesforce_Field__c,String.valueOf(con.get(mappingObj.TelosTouchSF__Salesforce_Field__c)));
                            }
                        }
                        if(ContactVSTTMap.get('first_name') == ''){
                            ContactVSTTMap.put('first_name', 'NA');
                        }
                        if(ContactVSTTMap.get('language') == '' || ContactVSTTMap.get('language') == 'English' ){
                            ContactVSTTMap.put('language', 'en_US');
                        }else if(ContactVSTTMap.get('language') == 'French'){
                            ContactVSTTMap.put('language', 'fr_FR');
                        }
                        if(ContactVSTTMap.get('subscribed') == '' ){
                            ContactVSTTMap.put('subscribed', 'Yes');
                        }
                        ContactVSTTMap.put('type', 'client');
                        if(con.TelosTouchSF__TT_Client_Id__c != null){
                            request.setMethod('PUT');
                            ContactVSTTMap.put('id',con.TelosTouchSF__TT_Client_Id__c);
                            ContactVSTTMap.put('other_id', String.valueOf(con.get('Id')));
                            if(userMap.containsKey(ContactVSTTMap.get('created_by'))){
                                ContactVSTTMap.put('created_by',userMap.get(ContactVSTTMap.get('created_by')).TelosTouchSF__TT_UserId__c);
                            }else{
                                ContactVSTTMap.remove('created_by');
                            }
                            putBody = putBody + JSON.serialize(ContactVSTTMap);
                            if(ContactVSTTMap.get('subscribed') == 'Yes'){
                                putBody = putBody.substring(0, putBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": true,"language":"'+contactVSTTMap.get('language')+'"}';
                            }else{
                                putBody = putBody.substring(0, putBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": false,"language":"'+contactVSTTMap.get('language')+'"}';
                            }
                            if(!customFieldsMap.isEmpty()){
                                String customFieldsJSON = JSON.serialize(customFieldsMap);
                                addCustomFields = ',"custom_fields":'+customFieldsJSON;
                                putBody = putBody + addCustomFields;
                            }
                            putBody = putBody + '},';
                        }else{
                            request.setMethod('POST');
                            ContactVSTTMap.put('other_id', String.valueOf(con.get('Id')));
                            if(userMap.containsKey(ContactVSTTMap.get('created_by'))){
                                ContactVSTTMap.put('created_by',userMap.get(ContactVSTTMap.get('created_by')).TelosTouchSF__TT_UserId__c);
                            }else{
                                if(userMap.containsKey(con.OwnerId)){
                                    ContactVSTTMap.put('created_by', String.valueOf(userMap.get(con.OwnerId).TelosTouchSF__TT_UserId__c));
                                } else if(userMap.containsKey(con.CreatedById)){
                                    ContactVSTTMap.put('created_by', String.valueOf(userMap.get(con.CreatedById).TelosTouchSF__TT_UserId__c));
                                } else{
                                    ContactVSTTMap.remove('created_by');
                                }
                            }
                            postBody = postBody + JSON.serialize(ContactVSTTMap);
                            if(ContactVSTTMap.get('subscribed') == 'Yes'){
                                postBody = postBody.substring(0, postBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": true,"language":"'+contactVSTTMap.get('language')+'"}';
                            }else{
                                postBody = postBody.substring(0, postBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": false,"language":"'+contactVSTTMap.get('language')+'"}';
                            }
                            if(!customFieldsMap.isEmpty()){
                                String customFieldsJSON = JSON.serialize(customFieldsMap);
                                addCustomFields = ',"custom_fields":'+customFieldsJSON;
                                postBody = postBody + addCustomFields;
                            }
                            postBody = postBody + '},';
                        }
                    }
                }
                Map<String, Lead> emailVsLeadObjMap = new Map<String, Lead>();
                if(clientleadlist != null && clientleadlist.size() > 0 && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                    for(Lead leadObject : clientleadlist){
                        if(adminCredentials.TelosTouchSF__Use_CreatedById__c == true ? userMap.containsKey(leadObject.CreatedById) : userMap.containsKey(leadObject.OwnerId)){
                            if(!emailVsLeadObjMap.containsKey(leadObject.email)){
                                emailVsLeadObjMap.put(leadObject.email, leadObject);
                            }else{
                                OtherIdVsClientIdMap.put(leadObject.email, 'Duplicate');
                            }
                        }
                    }
                    for(Lead leadObject : emailVsLeadObjMap.values()){
                        for(TelosTouchSF__TT_Salesforce_Mapping__c mappingObj : leadTelosTouchMappingList){
                            if(mappingObj.TelosTouchSF__TT_Field__c != 'Custom Fields'){
                                ContactVSTTMap.put(mappingObj.TelosTouchSF__TT_Field__c,  String.valueOf(leadObject.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) != null ?  String.valueOf(leadObject.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) : '');
                            }else if(mappingObj.TelosTouchSF__TT_Field__c == 'Custom Fields' && String.valueOf(leadObject.get(mappingObj.TelosTouchSF__Salesforce_Field__c)) != null){
                                customFieldsMap.put(mappingObj.TelosTouchSF__Salesforce_Field__c,String.valueOf(leadObject.get(mappingObj.TelosTouchSF__Salesforce_Field__c)));
                            }
                        }
                        if(ContactVSTTMap.get('first_name') == ''){
                            ContactVSTTMap.put('first_name', 'NA');
                        }
                        if(ContactVSTTMap.get('language') == '' || ContactVSTTMap.get('language') == 'English' ){
                            ContactVSTTMap.put('language', 'en_US');
                        }else if(ContactVSTTMap.get('language') == 'French'){
                            ContactVSTTMap.put('language', 'fr_FR');
                        }
                        if(ContactVSTTMap.get('subscribed') == '' ){
                            ContactVSTTMap.put('subscribed', 'Yes');
                        }
                        ContactVSTTMap.put('type', 'lead');
                        if(leadObject.TelosTouchSF__TT_Client_Id__c != null){
                            request.setMethod('PUT');
                            ContactVSTTMap.put('id',leadObject.TelosTouchSF__TT_Client_Id__c);
                            ContactVSTTMap.put('other_id', String.valueOf(leadObject.get('Id')));
                            if(adminCredentials.TelosTouchSF__Use_CreatedById__c == true){
                                ContactVSTTMap.put('created_by', String.valueOf(userMap.get(leadObject.CreatedById).TelosTouchSF__TT_UserId__c));
                            }else{
                                ContactVSTTMap.put('created_by', String.valueOf(userMap.get(leadObject.OwnerId).TelosTouchSF__TT_UserId__c));
                            }
                            putBody = putBody + JSON.serialize(ContactVSTTMap);
                            if(ContactVSTTMap.get('subscribed') == 'Yes'){
                                putBody = putBody.substring(0, putBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": true,"language":"'+contactVSTTMap.get('language')+'"}';
                            }else{
                                putBody = putBody.substring(0, putBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": false,"language":"'+contactVSTTMap.get('language')+'"}';
                            }
                            if(!customFieldsMap.isEmpty()){
                                String customFieldsJSON = JSON.serialize(customFieldsMap);
                                addCustomFields = ',"custom_fields":'+customFieldsJSON;
                                putBody = putBody + addCustomFields;
                            }
                            putBody = putBody + '},';
                        }else{
                            request.setMethod('POST');
                            ContactVSTTMap.put('other_id', String.valueOf(leadObject.get('Id')));
                            if(adminCredentials.TelosTouchSF__Use_CreatedById__c == true){
                                ContactVSTTMap.put('created_by', String.valueOf(userMap.get(leadObject.CreatedById).TelosTouchSF__TT_UserId__c));
                            }else{
                                ContactVSTTMap.put('created_by', String.valueOf(userMap.get(leadObject.OwnerId).TelosTouchSF__TT_UserId__c));
                            }
                            postBody = postBody + JSON.serialize(ContactVSTTMap);
                            if(ContactVSTTMap.get('subscribed') == 'Yes'){
                                postBody = postBody.substring(0, postBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": true,"language":"'+contactVSTTMap.get('language')+'"}';
                            }else{
                                postBody = postBody.substring(0, postBody.length() - 1) + ',"preferences":{"notificationTouchpointSend": false,"language":"'+contactVSTTMap.get('language')+'"}';
                            }
                            if(!customFieldsMap.isEmpty()){
                                String customFieldsJSON = JSON.serialize(customFieldsMap);
                                addCustomFields = ',"custom_fields":'+customFieldsJSON;
                                postBody = postBody + addCustomFields;
                            }
                            postBody = postBody + '},';
                        }
                    }
                }
                String putResponse, postResponse;
                if(String.isNotEmpty(putBody)){
                    putBody = putBody.removeEnd(',');
                    finalJSONPut =  finalJSONPut + putBody + ']}';
                    Map<String, String> putResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endpoint, headersMap, finalJSONPut);
                    if(putResponseMap.get('status_code') == '401'){
                        logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(putResponseMap.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(putResponseMap.get('status_code').length() > 0){
                            list<String>StatusCodeList = putResponseMap.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+putResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+putResponseMap.get('status_code'),1));
                            }
                        }
                    }
                    putResponse = putResponseMap.get('body');
                }
                if(String.isNotEmpty(postBody)){
                    postBody = postBody.removeEnd(',');
                    finalJSONPost =  finalJSONPost + postBody + ']}';
                    Map<String, String> postResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('POST', endpoint, headersMap, finalJSONPost);
                    if(postResponseMap.get('status_code') == '401'){
                        logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(postResponseMap.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(postResponseMap.get('status_code').length() > 0){
                            list<String>StatusCodeList = postResponseMap.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+postResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+postResponseMap.get('status_code'),1));
                            }
                        }
                    }
                    postResponse = postResponseMap.get('body');
                }
                if((clientlist != NULL && clientlist.size() > 0)){
                    for(Contact conObj : clientlist){
                        requestIDs.add(conObj.id);
                    }
                }
                if((clientleadlist != NULL && clientleadlist.size() > 0 && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()) ){
                    for(Lead leadObj : clientleadlist ){
                        if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                            requestIDs.add(leadObj.id);
                        }
                    }
                }
                if(putResponse != null && String.isNotEmpty(putResponse)){
                    List<Object> responseList = (List<Object>) JSON.deserializeUntyped(putResponse);
                    for(Object obj : responseList){
                        Map<String, Object> responseMap = (Map<String, Object>)obj;
                        if(responseMap.containsKey('other_id') && responseMap.containsKey('id') &&
                           responseMap.get('other_id') != null && responseMap.get('id') != null){
                               responseIDs.add(String.valueOf(responseMap.get('other_id')));
                               OtherIdVsClientIdMap.put(String.valueOf(responseMap.get('other_id')), String.valueOf(responseMap.get('id')));
                           }
                    }
                    for(Id requestId : requestIDs){
                        if(!responseIDs.contains(requestId)){
                            if(oldContactMap != NULL && oldContactMap.containsKey(requestId)
                                    && Schema.sObjectType.Contact.fields.Id.isAccessible() && Contact.sObjectType.getDescribe().isUpdateable()
                                    && Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isUpdateable()
                                    && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Conflict__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Conflict__c.isUpdateable()){
                                Contact con = new Contact();
                                con.Id = requestId;
                                con.TelosTouchSF__Error_Message__c = 'OUT OF SYNC DUE TO DUPLICATE EMAIL';
                                con.TelosTouchSF__TT_Conflict__c = true;
                                contactUpdateList.add(con);
                                logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Client update with TT Client Id: '+requestId+' failed due to duplicate email.','Mise à jour du client avec l’ID du client TT : '+requestId+' a échoué en raison de l’e-mail en double.',1));
                            }else if(oldLeadMap != NULL && oldLeadMap.containsKey(requestId)
                                    && Schema.sObjectType.Lead.fields.Id.isAccessible() && Lead.sObjectType.getDescribe().isUpdateable()
                                    && Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isUpdateable()
                                    && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Conflict__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Conflict__c.isUpdateable()){
                                Lead ld = new Lead();
                                ld.Id = requestId;
                                ld.TelosTouchSF__Error_Message__c = 'OUT OF SYNC DUE TO DUPLICATE EMAIL';
                                ld.TelosTouchSF__TT_Conflict__c = true;
                                leadUpdateList.add(ld);
                                logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Client update with TT Client Id: '+requestId+' failed due to duplicate email.','Mise à jour du client avec l’ID du client TT : '+requestId+' a échoué en raison de l’e-mail en double.',1));
                            }else if(oldAccountMap != NULL && oldAccountMap.containsKey(requestId)
                                    && Schema.sObjectType.Account.fields.Id.isAccessible() && Account.sObjectType.getDescribe().isUpdateable()){
                                Account acc = New Account();
                                acc.Id = oldAccountMap.get(requestId).Id;
                                acc.put('TelosTouchSF__Error_Message__pc', 'OUT OF SYNC DUE TO DUPLICATE EMAIL');
                                acc.put('TelosTouchSF__TT_Conflict__pc', true);
                                accountUpdateList.add(acc);
                                logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Client update with TT Client Id: '+requestId+' failed due to duplicate email.','Mise à jour du client avec l’ID du client TT : '+requestId+' a échoué en raison de l’e-mail en double.',1));
                            }
                        }
                    }
                    if(Schema.SObjectType.Contact.isAccessible() && Schema.SObjectType.Contact.isUpdateable() && !contactUpdateList.isEmpty()){
                        update contactUpdateList;
                    }
                    if(Schema.SObjectType.Lead.isAccessible() && Schema.SObjectType.Lead.isUpdateable() && !leadUpdateList.isEmpty()){
                        update leadUpdateList;
                    }
                    if(Account.sObjectType.getDescribe().isAccessible() && Account.sObjectType.getDescribe().isUpdateable() && !accountUpdateList.isEmpty()){
                        update accountUpdateList;
                    }
                    OtherIdVsClientIdMap.put('Updated Count', String.valueOf(responseList.size()));
                }
                if(postResponse != null && String.isNotEmpty(postResponse)){
                    Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(postResponse);
                    List<Object> createdcontactObj = (List<Object>)responseObjMap.get('created');
                    List<Object> duplicatecontactObj = (List<Object>)responseObjMap.get('alreadyExists');
                    for(Integer i=0; i< createdcontactObj.size(); i++){
                        if (postResponse != '[]') {
                            Map<String, Object> createdMap = (Map<String, Object>)createdcontactObj[i];
                            OtherIdVsClientIdMap.put(String.valueOf(createdMap.get('other_id')), String.valueOf(createdMap.get('id')));
                        }
                    }
                    for(Integer i=0; i < duplicatecontactObj.size(); i++){
                        if (postResponse != '[]') {
                            Map<String, Object> duplicateMap = (Map<String, Object>)duplicatecontactObj[i];
                            OtherIdVsClientIdMap.put(String.valueOf(duplicateMap.get('email')), 'Duplicate');
                        }
                    }
                }
            }
            if(!logList.isEmpty()){
                insert logList;
            }
            return OtherIdVsClientIdMap;

        }catch(Exception ex){
            TelosTouchUtility.generateErrorLog(ex, 'SFDataSyncWithTelosTouch', 'makePostCallout', null);
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param ressult ....
* @param message ....
* @param message_fr ....
* @param totalRecords ....
* @return TT_Log__c objDT ....
*/
    Public static TelosTouchSF__TT_Log__c addLogRecord(String ressult, String message, String message_fr, Integer totalRecords){
        TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable()){
            logObj.TelosTouchSF__Result__c = ressult;
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable()){
            logObj.TelosTouchSF__Total_Records_Count__c = totalRecords;
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()
            && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()
            && String.isNotBlank(message))
        {
            logObj.TelosTouchSF__Comments__c = message.abbreviate(254);
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments_FR__c.isAccessible()
            && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments_FR__c.isCreateable()
            && String.isNotBlank(message_fr))
        {
            logObj.TelosTouchSF__Comments_FR__c = message_fr.abbreviate(254);
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments_FR__c.isCreateable()){
            logObj.TelosTouchSF__Log_Type__c='Main Log';
        }
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible()){
            logObj.TelosTouchSF__LastUpdated__c = local;
        }
        return logObj;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description addLogRecordWithRecordId
* @param ressult ....
* @param message ....
* @param recordId ....
@return TT_Log__c
     */
    Public static TT_Log__c addLogRecordWithRecordId(String ressult, String message,String recordId){
        TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable()){
            logObj.TelosTouchSF__Result__c = ressult;
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()){
            logObj.TelosTouchSF__Comments__c = message.abbreviate(254);
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Record_Id__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Record_Id__c.isCreateable()){
            logObj.TelosTouchSF__Record_Id__c = recordId;
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Log_Type__c.isCreateable()){
            logObj.TelosTouchSF__Log_Type__c='Per Record';
        }
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
            logObj.TelosTouchSF__LastUpdated__c = local;
        }
        return logObj;
    }
    /**
* @author Swapnil Sen
* @date 29/11/2022
* @description SyncAllRecords_APEX
* @param syncType Defines if the sync is hard or soft
* @param syncObject Defines which object to sync
*/
    @AuraEnabled
    Public static void SyncAllRecords_APEX(String syncType, String syncObject){
        try{
            if(syncObject == 'All'){
                Database.executeBatch(new BatchForBulkDataInsertOrUpdate(null, null, null, 'Contact', null, syncType, null));
            }else if(syncObject == 'Contact'){
                Database.executeBatch(new BatchForBulkDataInsertOrUpdate(null, null, null, 'Contact', null, syncType, syncObject));
            }else if(syncObject == 'Task'){
                Database.executeBatch(new BatchForBulkDataInsertOrUpdate(null, null, null, 'Task', null, syncType, syncObject));
            }else if(syncObject == 'Campaign'){
                Database.executeBatch(new BatchForBulkDataInsertOrUpdate(null, null, null, 'Campaign', null, syncType, syncObject));
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    //Works when task is deleted 
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to delete task
* @param taskListToDeleted gets the list of task
*/
    Public static void deleteTask(List<task> taskListToDeleted){
        try{
            Map<String,User> userMap = new Map<String,User>();
            User campaignOwnerUser = new User();
            List<User> userList = new List<User>();
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() &&
                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()
                    && Schema.sObjectType.User.fields.isActive.isAccessible()
                    && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible()){
                userList = [SELECT Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c,TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c  != NULL AND isActive = true];
            }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            Integer deleted = 0, undeleted = 0;
            Map<Id, List<String>> ownerIdVsTtTaskIdMap = new Map<Id, List<String>>();
            for(Task taskObject : taskListToDeleted){
                if(!ownerIdVsTtTaskIdMap.containsKey(taskObject.OwnerId)){
                    ownerIdVsTtTaskIdMap.put(taskObject.OwnerId, new List<String>{taskObject.TelosTouchSF__TT_TaskId__c});
                }else{
                    ownerIdVsTtTaskIdMap.get(taskObject.OwnerId).add(taskObject.TelosTouchSF__TT_TaskId__c);
                }
            }
            for(Id ownerId : ownerIdVsTtTaskIdMap.keySet()){
                if(adminCredentials != null){
                    String UserToken,endPointURL='',methodType = 'DELETE';
                    Map<String, String> headersMap = new Map<String, String>();
                    if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                        endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/actions/mass';
                        headersMap.put('Content-Type', 'application/json');
                        headersMap.put('Accept', 'application/json');
                        campaignOwnerUser = userMap.get(ownerId);
                        if(Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                            if(campaignOwnerUser != null && campaignOwnerUser.TelosTouchSF__TT_UserName__c !=null && campaignOwnerUser.TelosTouchSF__Auth_Token__c != null){
                                UserToken = campaignOwnerUser.TelosTouchSF__Auth_Token__c;
                                headersMap.put('Authorization', 'Bearer '+ UserToken);
                            }
                        }
                        Map<Integer, List<String>> TtTaskIdChunkMap = new Map<Integer, List<String>>();
                        Integer count = 1;
                        for(Integer i=0; i<ownerIdVsTtTaskIdMap.get(ownerId).size(); i++){
                            if(!TtTaskIdChunkMap.containsKey(count)){
                                TtTaskIdChunkMap.put(count, new List<String>{ownerIdVsTtTaskIdMap.get(ownerId)[i]});
                            }else{
                                TtTaskIdChunkMap.get(count).add(ownerIdVsTtTaskIdMap.get(ownerId)[i]);
                            }
                            if(i!=0){
                                if(Math.mod((i+1), 20) == 0){
                                    count++;
                                }
                            }
                        }
                        for(Integer chunkNumber : TtTaskIdChunkMap.keySet()){
                            Map<String, List<String>> jsonMap = new  Map<String, List<String>>();
                            jsonMap.put('ids',TtTaskIdChunkMap.get(chunkNumber));
                            String body = JSON.serialize(jsonMap);
                            Map<String, String> responseString = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                            if(responseString.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }else if(responseString.get('status_code') == '500'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                            }else{
                                if(responseString.get('status_code').length() > 0){
                                    list<String>StatusCodeList = responseString.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseString.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseString.get('status_code'),1));
                                    }
                                }
                            }
                            if(responseString.get('body') != null && responseString.get('body').contains('deleted')){
                                List<Object> responseList = (List<Object>)JSON.deserializeUntyped(responseString.get('body'));
                                for(Object responseObj : responseList){
                                    Map<String,Object> data = (Map<String,Object>)responseObj;
                                    if(data.containsKey('deleted') && data.get('deleted') == true){
                                        deleted = deleted+1;
                                    }else{
                                        undeleted = undeleted+1;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(deleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord('success','Task deleted from SF to TelosTouch.','Tâche supprimée de SF à TelosTouch.', deleted);
            }
            if(undeleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.Failed_Text,'Task not deleted from TT or not present on TT','Tâche non supprimée dans TT ou absente de TT', undeleted);
            }
            if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                insert logList;
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }

    // Trigger Method for Campaign Delete
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to delete Campaign
* @param campaignList gets the list of Campaign
*/
    Public static void deleteCampaign(List<Campaign> campaignList){
        try{
            Map<String,User> userMap = new Map<String,User>();
            User campaignOwnerUser = new User();
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            List<User> userList = new List<User>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() &&   Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&  Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&  Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                userList = [Select Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c,TelosTouchSF__TT_UserId__c From User WHERE TelosTouchSF__TT_UserId__c  != NULL LIMIT 50000];
            }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            Integer deleted = 0, undeleted = 0;
            for(Campaign campaignObject : campaignList){
                String  campaignOwnerId = campaignObject.OwnerId;
                campaignOwnerUser = userMap.get(campaignOwnerId);
                String UserToken;
                String endPointURL='';
                if(adminCredentials != null){
                    String methodType = 'DELETE';
                    Map<String, String> headersMap = new Map<String, String>();
                    if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                        if(Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible()){
                            endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/touchpoints/'+campaignObject.TelosTouchSF__TT_Campaign_Id__c ;
                        }
                    }
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    if(Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                        if(campaignOwnerUser != null && campaignOwnerUser.TelosTouchSF__TT_UserName__c !=null && campaignOwnerUser.TelosTouchSF__Auth_Token__c != null){
                            UserToken = campaignOwnerUser.TelosTouchSF__Auth_Token__c;
                            headersMap.put('Authorization', 'Bearer '+ UserToken);
                        }
                    }
                    Map<String, String> responseString = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                    if(responseString.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }else if(responseString.get('status_code') == '500'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                    }else{
                        if(responseString.get('status_code').length() > 0){
                            list<String>StatusCodeList = responseString.get('status_code').split('0');
                            if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseString.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseString.get('status_code'),1));
                            }
                        }
                    }
                    if(responseString.get('body') == 'OK'){
                        deleted = deleted+1;
                    }else{
                        undeleted = undeleted+1;
                    }
                }
            }
            if(deleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord('success','Campaigns deleted from SF to TelosTouch.','Campagnes supprimées de SF à TT.', deleted);
            }
            if(undeleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.Failed_Text,'Campaigns not deleted from TT or not present on TT.','Campagnes non supprimées dans TT ou absentes de TT.', undeleted);
            }
            if(!logList.isEmpty()){
                insert logList;
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
@return TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper ....
     */
    public static TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper registerOrgOnTelosTouch(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setEndpoint(adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/organization/signup');
        req.setHeader('Content-Type', 'application/json');
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('org_uid', UserInfo.getOrganizationId());
        if(UserInfo.getLanguage() == 'fr'){
            requestMap.put('language', 'fr_FR');
        }else if(UserInfo.getLanguage().contains('en')){
            requestMap.put('language', 'en_US');
        }
        requestMap.put('email', UserInfo.getUserEmail());
        req.setBody(JSON.serialize(requestMap));
        res = http.send(req);

	    String respMessage = 'Response Status Code: '+res.getstatusCode()+' | Response Body: '+res.getBody();	
        TelosTouchUtility.generateAndSaveLog(respMessage, 'SFDataSyncWithTelosTouch', 'registerOrgOnTelosTouch', null);
        
        if(res.getStatusCode() == 422){
            //Org is Already Registered
            adminCredentials.TelosTouchSF__Registration_Successful__c = true;
            adminCredentials.TelosTouchSF__Registration_Request_Expiry__c = 0;
            adminCredentials.TelosTouchSF__Registration_DateTime__c = String.valueOf((DateTime.now().getTime())/1000);
            TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential);
            TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredentialWrapper);
            return adminCredentialWrapper;
        }else if(res.getStatusCode() == 425){
            //Previous Request has not Expired
            System.debug(LoggingLevel.WARN,'Previous Request has not Expired');
        }else if(res.getStatusCode() == 200){
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(responseMap.containsKey('id') && String.isNotEmpty((String)responseMap.get('id'))){
                //Store Current Time
                //Store Expiration Time
                //Toggle Registration Sent Flag to True
                adminCredentials.TelosTouchSF__Registration_Successful__c = true;
                adminCredentials.TelosTouchSF__Registration_Request_Expiry__c = (Integer) responseMap.get('expiration');
                adminCredentials.TelosTouchSF__Registration_DateTime__c = String.valueOf((DateTime.now().getTime())/1000);
                adminCredentials.TelosTouchSF__Team_Name__c = (String) responseMap.get('teamName');
                TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential);
                TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredentialWrapper);
                return adminCredentialWrapper;
            }
        }
        return new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(TelosTouchSF.TelosTouchUtility.getCustomMetadata(), TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata());
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to check if the client is a enterprise client or not
@return Boolean ....
     */
    public static Boolean checkIfEnterpriseClient(){
                    System.debug('2');
        try{
            System.debug('2');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/organization/'+UserInfo.getOrganizationId()+'?is_enterprise=true');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            res = http.send(req);
            
            String respMessage = 'Response Status Code: '+res.getstatusCode()+' | Response Body: '+res.getBody();	
            TelosTouchUtility.generateAndSaveLog(respMessage, 'SFDataSyncWithTelosTouch', 'checkIfEnterpriseClient', null);
            if(res.getStatusCode()==404){
                return false;
            }else{
                return true;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception: '+ex.getMessage()+' occurred at Line Number: '+ex.getLineNumber());
            return true;
        }
    }
    @AuraEnabled
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description startRegistrationOnTT
@return String ....
         */
    public static String startRegistrationOnTT(){
        try{
            if(!adminCredentials.TelosTouchSF__Approval__c && !adminCredentials.TelosTouchSF__Registration_Successful__c){
                if(String.isEmpty(adminCredentials.TelosTouchSF__Instance_URL__c)){
                    return 'No Action';
                }
                String[] StringList = adminCredentials.TelosTouchSF__Instance_URL__c.split('//');
                String[] StringList1 = StringList[1].split('\\.');
                String instance_Name = TelosTouchSF.CreateRemoteSiteSetting.getremoteSiteSetting(adminCredentials.TelosTouchSF__Instance_URL__c, StringList1[0]);
                if(instance_Name != 'Already Exists!'){
                    TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1(adminCredentials.TelosTouchSF__Instance_URL__c,instance_Name);
                }
                if (!TelosTouchSF.SFDataSyncWithTelosTouch.checkIfEnterpriseClient()) {
                    TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialWrapper = TelosTouchSF.SFDataSyncWithTelosTouch.registerOrgOnTelosTouch();
                    if(adminCredentialWrapper.Registration_Successful){
                        return 'Registration Successful';
                    }else{
                        return 'Registration Unsuccessful';
                    }
                } else {
                    TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
                    adminCredentials.TelosTouchSF__Instance_URL__c = null;
                    TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential);
                    TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredentialWrapper);
                    return 'Registration Not Required';
                }
            }else{
                return 'No Action';
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'ex: '+e.getMessage()+' at line no: '+e.getLineNumber());
            return 'Package Configuration Failed! Exception: '+e.getMessage();
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description contactDataTableWrapper is used to get pageSize,pageNumber,totalRecords,recordStart,recordEnd and list of logs.
*/
    public class contactDataTableWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Integer pageSize { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public String currentUserLanguage { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Integer pageNumber { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Integer totalRecords { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Integer recordStart { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Integer recordEnd { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public Boolean asyncJobstatus { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public List<TelosTouchSF__TT_Log__c> allLogsList { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public TelosTouchSF__TelosTouch_API_Settings__c getCustomAPISetting { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled
        public TelosTouchSF__TT_Admin_Credentials__mdt getCustomMetadataSetting { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class clientLogWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer contactSuccessCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer contactErrorCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer leadSuccessCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer leadErrorCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        clientLogWrapper(){
            contactSuccessCount = 0;
            contactErrorCount = 0;
            leadSuccessCount = 0;
            leadErrorCount = 0;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class taskLogWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer taskSuccessCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer taskErrorCount {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        taskLogWrapper(){
            taskSuccessCount = 0;
            taskErrorCount = 0;
        }
    }
}