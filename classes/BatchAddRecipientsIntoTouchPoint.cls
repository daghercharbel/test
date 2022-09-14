/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public class BatchAddRecipientsIntoTouchPoint Implements Database.Batchable <String>, Database.allowsCallouts, Database.Stateful{
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    public AddRecipientsWrapper getwrapper;
    public List<TelosTouchSF__TT_Log__c> createListOfLog;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param finalCamMemList ....
*/
    public BatchAddRecipientsIntoTouchPoint(AddRecipientsWrapper finalCamMemObj){
        getwrapper = new AddRecipientsWrapper();
        getwrapper = finalCamMemObj;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @return AddRecipientsWrapper userList ....
*/
    public Iterable<String> start(Database.BatchableContext bc){
        return getwrapper.clientIds;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @param getwrapper ....
*/
    public void execute(Database.BatchableContext bc, List<String> clientIds){
        String methodType = 'PUT';
        createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
        String endPointURL, getResponseClients, userAuthTOKEN, body;
        Map<String, List<String>> bodyMap = new Map<String, List<String>>();
        Map<String, String> headersMap = new Map<String, String>();
        userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        headersMap.put('Authorization','Bearer '+userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+getwrapper.TTcampId+'/clients';
        }
        bodyMap.put('clients', clientIds);
        body = JSON.serialize(bodyMap);
        Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
        if(getResponseMap.get('status_code') == '401'){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
        }else if(getResponseMap.get('status_code') == '500'){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
        }else{
            if(getResponseMap.get('status_code').length() > 0){
                list<String>StatusCodeList = getResponseMap.get('status_code').split('0');
                if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                }
            }
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
*/
    public void finish(Database.BatchableContext bc){
        String endPointURL, getResponseClients;
        Map<String, String> headersMap = new Map<String, String>();
        String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        headersMap.put('Authorization','Bearer '+userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+getwrapper.TTcampId+'/clients';
        }
        Map<String, String> getResponseClientsMap = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, headersMap, null);
        if(getResponseClientsMap.get('status_code') == '500'){
            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
        }
        else{
            if(getResponseClientsMap.get('status_code').length() > 0){
                list<String>StatusCodeList = getResponseClientsMap.get('status_code').split('0');
                if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseClientsMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseClientsMap.get('status_code'),1));
                }
            }
        }
        getResponseClients = getResponseClientsMap.get('body');
        Database.executeBatch(new BatchCreateInsightsForNewRecipients(getResponseClients, getwrapper), 300);
        if(createListOfLog != null){
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && createListOfLog.size() >0){
                insert createListOfLog;
            }
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class AddRecipientsWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String campId;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String campName;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public List<String> clientIds;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String TTcampId;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Map<String, String> TTClientIdVsLeadId;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Map<String, String> TTClientIdVsContId;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public AddRecipientsWrapper(){
            clientIds = new List<String>();
            TTClientIdVsLeadId = new Map<String, String>();
            TTClientIdVsContId = new Map<String, String>();
        }
    }
}