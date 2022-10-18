/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetCampaignsFromTTQueueable class is used to get campaigns within last 2 hours from TT and insert those reocords in SF.
*/
global with sharing class GetCampaignsFromTTQueueable implements Queueable, Database.AllowsCallouts{
    
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    public Integer startPoint;
    public Integer endPoint;
    public Integer NumberOfRecords;
    public boolean forFirstTime;
    public String syncObject;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param startPoint ...
* @param endPoint ......
* @param NumberOfRecords ...
* @param forFirstTime ......
* @param syncObject ......
*/
    public GetCampaignsFromTTQueueable(Integer startPoint, Integer endPoint, Integer NumberOfRecords,Boolean forFirstTime, String syncObject){
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.NumberOfRecords = NumberOfRecords;
        this.forFirstTime = forFirstTime;
        this.syncObject = syncObject;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ...
*/
    global void execute(QueueableContext context){
        try{
            Map<String, String> headersMap = new Map<String, String>();
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            String methodType = 'GET',endPointURL = '',responseBody;
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');

            DateTime LAST_HOUR = System.NOW().addMinutes(-62);
            String formatted = LAST_HOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                headersMap.put('Authorization','Bearer ' +authenticationCredential.TelosTouchSF__Access_Token__c);
                for(Integer i=startPoint;i<endPoint;i=i+200){
                    try {
                        if (Test.isRunningTest() || (forFirstTime == true)) {
                            endPointURL =
                                    adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/touchpoints?skip=' +
                                    i + '&limit=200';
                        } else {
                            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c +
                                    '/api/v1/admin/touchpoints?modified_at={">=":"' + formatted + '"}&skip=' + i +
                                    '&limit=200';
                        }
                        if (responseBody == null && authenticationCredential.TelosTouchSF__Access_Token__c != null) {
                            Map<String, String> responseBodyMap =
                                    TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap,
                                            null);
                            if (responseBodyMap.get('status_code') == '401') {
                                logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure',
                                        'User Could Not be Authenticated', 'L\'usager n\'a pu être identifié', 1));
                            }else if(responseBodyMap.get('status_code') == '500'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                            }else{
                                if(responseBodyMap.get('status_code').length() > 0){
                                    list<String>StatusCodeList = responseBodyMap.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBodyMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBodyMap.get('status_code'),1));
                                    }
                                }
                            }
                            responseBody = responseBodyMap.get('body');
                        } else {
                            String response;
                            if (authenticationCredential.TelosTouchSF__Access_Token__c != null) {
                                Map<String, String> responseMap =
                                        TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap,
                                                null);
                                if (responseMap.get('status_code') == '401' && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable()) {
                                    logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure',
                                            'User Could Not be Authenticated', 'L\'usager n\'a pu être identifié', 1));
                                }else if(responseMap.get('status_code') == '500' && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable()){
                                    logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                                }else{
                                    if(responseMap.get('status_code').length() > 0){
                                        list<String>StatusCodeList = responseMap.get('status_code').split('0');
                                        if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5' && (Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable())){
                                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseMap.get('status_code'),1));
                                        }
                                    }
                                }
                                response = responseMap.get('body');
                            }
                            if (response != null && response.contains('id')) {
                                responseBody = responseBody.removeEnd(']');
                                response = response.removeStart('[');
                                response = response.removeEnd(']');
                                responseBody += (',' + response + ']');
                            } else {
                                break;
                            }
                        }
                        if (!responseBody.contains('id')) {
                            break;
                        }
                    }catch (Exception ex){
                        System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                    }
                }
            }
            if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                insert logList;
            }
            if(responseBody != null /*&& responseBody.contains('id')*/){
                Database.executeBatch(new TelosTouchSF.GetCampaignsFromTTBatch(responseBody, forFirstTime),50);
            } 
            
            if(endPoint == NumberOfRecords){
                if(!Test.isRunningTest() && forFirstTime == false && syncObject == null){
                    Batch_UpdateContactAndLead2 batchObj = new Batch_UpdateContactAndLead2(null, null, 'Contact');
                    Database.executeBatch(batchObj,500);
                }
                TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredentialsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential);
                adminCredentialsWrapper.ForSecondTimeBatch = true;
                TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredentialsWrapper);
            }
        }catch(exception ex ){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
    }                    
}