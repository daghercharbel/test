/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
public with sharing class BatchForBulkDataInsertOrUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public Integer numberOfRecords;
    public Integer startPoint;
    public Integer endPoint;
    public boolean forFirstTime;
    public String objectName;
    public Id JobId;
    public String syncType;
    public String syncObject;
    /*private static final TelosTouch_API_Settings__c getCredentials= TelosTouch_API_Settings__c.getOrgDefaults();
    private static final String instanceUrl = getCredentials.Instance_url__c;
    private static final String token = getCredentials.Token__c;
    private static final Boolean secondTime = getCredentials.ForSecondTimeBatch__c;*/
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param numberOfRecords ....
* @param startPoint ....
* @param endPoint ....
* @param objectName ....
* @param JobId ....
* @param syncType ....
* @param syncObject ....
*/
    public BatchForBulkDataInsertOrUpdate(Integer numberOfRecords, Integer startPoint, Integer endPoint, String objectName, Id JobId, String syncType, String syncObject){
        this.numberOfRecords = numberOfRecords;
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.objectName = objectName;
        this.JobId = JobId;
        this.syncType = syncType;
        this.syncObject = syncObject;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @return sObject [SELECT ID FROM Organization LIMIT 1] ....
*/
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query;
            if(Schema.sObjectType.Organization.isAccessible() && Schema.sObjectType.Organization.isQueryable()){
                query = 'SELECT Id FROM Organization LIMIT 1';
            }
            return Database.getQueryLocator(String.escapeSingleQuotes(query));
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc .... 
* @param nullList ....
*/
    public void execute(Database.BatchableContext bc, List<sObject> nullList){
        try{
            if(this.syncType != null){
                if(this.syncType == 'Hard'){
                    forFirstTime = true;
                }else if(this.syncType == 'Soft'){
                    forFirstTime = false;
                }
            }else{
                if(adminCredentials.TelosTouchSF__ForSecondTimeBatch__c == false){
                    forFirstTime = true;
                }else{
                    forFirstTime = false;
                }
            }
            if(numberOfRecords == null){
                numberOfRecords = 0;
                Map<String, String> headersMap = new Map<String, String>();
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) && String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c)){
                    headersMap.put('Accept', 'application/json');
                    headersMap.put('Authorization','Bearer ' +authenticationCredential.TelosTouchSF__Access_Token__c);
                    headersMap.put('Content-Type', 'application/json');
                }
                DateTime taskLASTHOUR = System.NOW().addMinutes(-62);
                String formatted = taskLASTHOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                String endPointURL;

                if(objectName == 'Task'){
                    if(!forFirstTime){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/actions?deleted=false&modified_at={">=":"'+formatted+'"}';
                    }else{
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/actions?deleted=false';
                    }
                }else if(objectName == 'Campaign'){
                    if(!forFirstTime){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/touchpoints?modified_at={">=":"'+formatted+'"}';
                        //System.debug(endPointURL);
                    }else{
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/touchpoints';
                    }
                }else if(objectName == 'Contact'){
                    if(!forFirstTime){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/contacts?deleted=false&modified_at={">=":"'+formatted+'"}';
                    }else{
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/admin/contacts?deleted=false';
                    }
                }
                //System.debug('endPointURL>>'+endPointURL);
                HttpRequest request = new HttpRequest();
                Http http = new Http();
                HttpResponse response = new HttpResponse();
                request.setMethod('HEAD');
                request.setEndpoint(endPointURL);
                if (headersMap.size() > 0) {
                    for (String str : headersMap.keySet()) {
                        request.setHeader(str, headersMap.get(str));
                    }
                }
                response = http.send(request);
                if(response.getstatusCode() == 200){
                    if(objectName == 'Contact'){
                        numberOfRecords = Integer.valueOf(response.getHeader('X-Total-Count'));
                        //system.debug('numberOfRecords>>'+numberOfRecords);
                    }else if(objectName == 'Task'){
                        numberOfRecords = Integer.valueOf(response.getHeader('X-Total-Count'));
                    }else if(objectName == 'Campaign'){
                        numberOfRecords = Integer.valueOf(response.getHeader('X-Total-Count'));
                    }
                }
            }
            if(startPoint == null){
                startPoint = 0;
                if(numberOfRecords > startPoint+1400){
                    endPoint = startPoint+1400;
                }else{
                    endPoint = numberOfRecords;
                }
            }else{
                startPoint = endPoint;
                if(numberOfRecords > startPoint+1400){
                    endPoint = startPoint+1400;
                }else{
                    endPoint = numberOfRecords;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
    }
            /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
*/
    public void finish(Database.BatchableContext bc){
        if(JobId == null){
            if(ObjectName == 'Task'){
                JobId = System.enqueueJob(new TelosTouchSF.GetTaskFromTTQueueable(this.startPoint, this.endPoint, this.NumberOfRecords, forFirstTime, syncObject ));
            }else if(ObjectName == 'Campaign'){
                JobId = System.enqueueJob(new TelosTouchSF.GetCampaignsFromTTQueueable(this.startPoint, this.endPoint, this.NumberOfRecords, forFirstTime, syncObject ));
            }else if(ObjectName == 'Contact'){
                //System.debug('Contact');
               	JobId = System.enqueueJob(new TelosTouchSF.GetClientsFromTTQueueable(this.startPoint, this.endPoint, this.NumberOfRecords, forFirstTime, syncObject ));
            }
        }
        if(JobId != null){
            AsyncApexJob jobInfo = new AsyncApexJob();
            if(AsyncApexJob.SObjectType.getDescribe().isAccessible() && AsyncApexJob.sObjectType.getDescribe().isQueryable() &&
               Schema.SObjectType.AsyncApexJob.fields.Status.isAccessible() ){
                   jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id=:JobId];
               }
            if(jobInfo.Status == 'Completed'){
                if(endPoint != NumberOfRecords){
                    Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(this.NumberOfRecords, this.startPoint, this.endPoint, this.ObjectName, this.JobId, null, null));
                }
            }else{
                Datetime dt = Datetime.now().addMinutes(2);
                String hour = String.valueOf(dt.hour());
                String min = String.valueOf(dt.minute());
                String dd = String.valueOf(dt.date().day());
                String mm = String.valueOf(dt.date().month());
                String yy = String.valueOf(dt.date().year());
                String nextFireTime = '0 ' + min + ' ' + hour + ' '+dd+' '+mm+' ? '+yy;
                if(dt > Datetime.now()){
                    System.schedule('Bulk Data Insert Job Batch '+JobId, nextFireTime, new TelosTouchSF.SchedulerForBulkDataInsertOrUpdate(this.NumberOfRecords, this.startPoint, this.endPoint, this.ObjectName, this.JobId));
                }else{
                    Datetime dt2 = Datetime.now().addMinutes(5);
                    String hour2 = String.valueOf(dt2.hour());
                    String min2 = String.valueOf(dt2.minute());
                    String dd2 = String.valueOf(dt2.date().day());
                    String mm2 = String.valueOf(dt2.date().month());
                    String yy2 = String.valueOf(dt2.date().year());
                    String nextFireTime2 = '0 ' + min2 + ' ' + hour2 + ' '+dd2+' '+mm2+' ? '+yy2;
                    System.schedule('Bulk Data Insert Job Batch '+JobId, nextFireTime2, new TelosTouchSF.SchedulerForBulkDataInsertOrUpdate(this.NumberOfRecords, this.startPoint, this.endPoint, this.ObjectName, this.JobId));
                }
            }
        }
    }
}