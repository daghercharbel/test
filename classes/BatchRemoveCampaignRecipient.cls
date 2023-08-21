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

        for(String campId : lstCampId){

            list<String> lstClientId = mapMembersByCamp.get(campId);

            String body = '{ "touchpoint_send_id" : "'+campId+'",';
            body += '"all" : false,';
            body += '"recipients" : [';
            for(String clientId : lstClientId){
                body += '"'+clientId+'",';
            }
            body = body.removeEnd(',');
            body += ']}';

            Map<String, String> mapResponse = TelosTouchUtility.getResponse('PUT', endpoint, mapHeader, body);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');
            TelosTouchUtility.generateLog(respMessage, 'BatchRemoveCampaignRecipient', 'execute', null);
            

        }

    }

    public void finish(Database.BatchableContext bc){

    }

}