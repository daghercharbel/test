/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public class BatchAddRecipientsIntoTouchPoint Implements Database.Batchable <AddRecipientsWrapper>, Database.allowsCallouts, Database.Stateful{
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    public List<AddRecipientsWrapper> getwrapper;
    public List<TelosTouchSF__TT_Log__c> createListOfLog;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param finalCamMemList ....
*/
    public BatchAddRecipientsIntoTouchPoint(List<AddRecipientsWrapper> finalCamMemList){
        getwrapper = new List<AddRecipientsWrapper>();
        getwrapper = finalCamMemList;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @return AddRecipientsWrapper userList ....
*/
    public Iterable<AddRecipientsWrapper> start(Database.BatchableContext bc){
        return getwrapper;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @param getwrapper ....
*/
    public void execute(Database.BatchableContext bc, List<AddRecipientsWrapper> getwrapper){
        //System.debug('WRAPPER : '+getwrapper);
        //System.debug('WRAPPER SIZE: '+getwrapper.size());
        String methodType = 'PUT';
        createListOfLog = new List<TelosTouchSF__TT_Log__c>();
        List<TelosTouchSF__Insights__c> conversation_UserList = new List<TelosTouchSF__Insights__c>();
        String endPointURL, getResponse, getResponseClients, userAuthTOKEN, body;
        Map<String, List<String>> bodyMap = new Map<String, List<String>>();
        Map<String, String> headersMap = new Map<String, String>();
        userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        headersMap.put('Authorization','Bearer '+userAuthTOKEN);
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Accept', 'application/json');
        for(AddRecipientsWrapper obj : getwrapper){
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+obj.TTcampId+'/clients';
            }
            bodyMap.put('clients', obj.clientIds);
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
            getResponse = getResponseMap.get('body');
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+obj.TTcampId+'/clients';
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
            if ((obj.TTClientIdVsLeadId != null && !obj.TTClientIdVsLeadId.isEmpty()) || (obj.TTClientIdVsContId != null && !obj.TTClientIdVsContId.isEmpty())) {
                if(getResponseClients != null){
                    Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(getResponseClients);
                    List<Object> responseList = (List<Object>)responseMap1.get('conversations');
                    if(responseList != null && responseList.size() > 0){
                        for(Object responseObj : responseList){
                            Map<String, Object> responseMap2 = (Map<String, Object>)responseObj;
                            if(obj.TTClientIdVsLeadId.containsKey(String.valueOf(responseMap2.get('contact_id'))) || obj.TTClientIdVsContId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
                                TelosTouchSF__Insights__c conversation_UserObj = new TelosTouchSF__Insights__c();
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isCreateable()){
                                    conversation_UserObj.TelosTouchSF__Campaign2__c = obj.campId;
                                }
                                if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isCreateable()){
                                    conversation_UserObj.TelosTouchSF__TouchPoint_Name__c = String.valueOf(responseMap1.get('name'));
                                }
                                if(responseMap2.containsKey('contact_id') && responseMap2.get('contact_id') !=  null){
                                    if(obj.TTClientIdVsContId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Contact__c = obj.TTClientIdVsContId.get(String.valueOf(responseMap2.get('contact_id')));
                                        }
                                    }else if(obj.TTClientIdVsLeadId.containsKey(String.valueOf(responseMap2.get('contact_id')))){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Lead__c = obj.TTClientIdVsLeadId.get(String.valueOf(responseMap2.get('contact_id')));
                                        }
                                    } 
                                    if(responseMap2.containsKey('conversation_id') && responseMap2.get('conversation_id') !=  null){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Conversation_Id__c = String.valueOf(responseMap2.get('conversation_id'));
                                        }
                                    }
                                    if(responseMap2.containsKey('completed_at') && responseMap2.get('completed_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('completed_at')))){
                                        String dates = String.valueOf(responseMap2.get('completed_at'));
                                        dates = dates.replace('T', ' ');
                                        dates = dates.replace('.', '#');
                                        List<String> strList = dates.split('#');
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Completed_At__c = Datetime.valueOf(strList[0]);
                                        }
                                    }
                                    if(responseMap2.containsKey('opened_at') && responseMap2.get('opened_at') !=  null && String.isNotBlank(String.valueOf(responseMap2.get('opened_at')))){
                                        String dates = String.valueOf(responseMap2.get('opened_at'));
                                        dates = dates.replace('T', ' ');
                                        dates = dates.replace('.', '#');
                                        List<String> strList = dates.split('#');
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isCreateable()){
                                            conversation_UserObj.TelosTouchSF__Opened_At__c = Datetime.valueOf(strList[0]);
                                        }
                                    }
                                    if(responseMap2.containsKey('user_name') && responseMap2.get('user_name') !=  null){
                                        if(Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isUpdateable() && Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isCreateable()){
                                            conversation_UserObj.Name =  String.valueOf(responseMap2.get('user_name'));
                                        }
                                    }
                                    conversation_UserList.add(conversation_UserObj);
                                }
                            } 
                        }  
                        if(conversation_UserList.size() > 0 && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('success','Clients Added to Campaign:'+' '+obj.CampName,'Clients ajoutés à la Campagne:'+' '+obj.CampName,1));
                        }
                    }
                }else{
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Clients could Not be Added to Campaign:'+' '+obj.CampName,'Des Clients n\'ont pu être ajoutés à la Campagne:'+' '+obj.CampName,1));
                }
            }
        }
        if(conversation_UserList.size() > 0 && Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isCreateable() && Schema.sObjectType.TelosTouchSF__Insights__c.isUpdateable()){
            UPSERT  conversation_UserList TelosTouchSF__Conversation_Id__c;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
*/
    public void finish(Database.BatchableContext bc){
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