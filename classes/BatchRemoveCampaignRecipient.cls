public with sharing class BatchRemoveCampaignRecipient Implements Database.Batchable <String>, Database.allowsCallouts, Database.Stateful{
    
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    public map<String, list<String>> mapMembersByCamp;

    public BatchRemoveCampaignRecipient(map<String, list<String>> mapIncome){
        mapMembersByCamp = mapIncome;
    }

    public list<String> start(Database.BatchableContext bc){
        list<String> lstCampId = new list<String>();
        lstCampId.addAll(mapMembersByCamp.keySet());
        return lstCampId;
    }

    public void execute(Database.BatchableContext bc, list<String> lstCampId){

        String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v2/campaign2/client/mass-delete';
        Map<String, String> mapHeader = new Map<String, String>();
        String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
        mapHeader.put('Authorization','Bearer '+userAuthTOKEN);
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Accept', 'application/json');

        set<String> setClientId = new Set<String>();
        list<String> lstCampClientId = new list<String>();

        for(String campId : lstCampId){

            list<String> lstClientId = mapMembersByCamp.get(campId);
            setClientId.addAll(lstClientId);

            String body = '{ "touchpoint_send_id" : "'+campId+'",';
            body += '"all" : false,';
            body += '"recipients" : [';
            for(String clientId : lstClientId){
                body += '"'+clientId+'",';
                lstCampClientId.add(campId+'-'+clientId);
            }
            body = body.removeEnd(',');
            body += ']}';

            Map<String, String> mapResponse = TelosTouchUtility.getResponse('PUT', endpoint, mapHeader, body);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');
            TelosTouchUtility.generateLog(respMessage, 'BatchRemoveCampaignRecipient', 'execute', null);

        }
        
        list<Id> lstInsightId = new list<Id>();
        for(TelosTouchSF__Insights__c insight : [SELECT Id,TelosTouchSF__Campaign2__r.TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Contact__c,
                                                    TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c,TelosTouchSF__Lead__c,
                                                    TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c FROM TelosTouchSF__Insights__c 
                                                    WHERE TelosTouchSF__Campaign2__r.TelosTouchSF__TT_Campaign_Id__c IN: (lstCampId) AND 
                                                    (TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c IN: (setClientId) 
                                                    OR TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c IN: (setClientId))])
        {
            String key = insight.TelosTouchSF__Campaign2__r.TelosTouchSF__TT_Campaign_Id__c+'-';
            if(String.isNotBlank(insight.TelosTouchSF__Contact__c)){
                key += insight.TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c;
            } else if(String.isNotBlank(insight.TelosTouchSF__Lead__c)) {
                key += insight.TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c;
            }
            if(lstCampClientId.contains(key)){ lstInsightId.add(insight.Id); }
        }

        if(!lstInsightId.isEmpty()){ Database.delete(lstInsightId); }

    }

    public void finish(Database.BatchableContext bc){

    }

}