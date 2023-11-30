global with sharing class BatchUpdateTTUser implements Database.Batchable<sObject>, Database.AllowsCallouts , Database.Stateful{

    private TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials;
    private TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential;
    global List<User> lstGlobalUser;
    global String ttTeamId;

    global BatchUpdateTTUser(List<User> lstUser){
        adminCredentials = TelosTouchUtility.getCustomMetadata();
        authenticationCredential = TelosTouchUtility.getAuthenticationCustomMetadata();
        lstGlobalUser = lstUser;
        
    }

    global Iterable<sObject> start(Database.BatchableContext bc){
        return lstGlobalUser;
    }

    global void execute(Database.BatchableContext bc, List<User> lstUser){

        String aMethod = 'PUT';
        String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users';
        map<String, String> mapHeader = new map<String,String>();
        mapHeader.put('Accept', 'application/json');
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Authorization', 'Bearer '+authenticationCredential.TelosTouchSF__Access_Token__c);
        list<User> lstUserUpd = new list<User>();

        if(String.isEmpty(ttTeamId)){

            String ttTeamName = String.isNotEmpty(adminCredentials.TelosTouchSF__Team_Name__c) ? adminCredentials.TelosTouchSF__Team_Name__c : authenticationCredential.TelosTouchSF__Client_ID__c;
            Map<String, String> mapTeamResponse = TelosTouchUtility.getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/teams?search='+ttTeamName, mapHeader, null);

            List<Object> lstObject = (List<Object>)JSON.deserializeUntyped(mapTeamResponse.get('body'));
            for(Object aObj : lstObject){
                Map<String, Object> mapObject = (Map<String, Object>)aObj;
                ttTeamId = String.valueOf(mapObject.get('id'));
            }

        }

        for(User aUser : lstUser){
            
            if(String.isBlank(aUser.TelosTouchSF__TT_UserId__c)){ continue; }

            String body = '{'+
            '"role": "'+aUser.TelosTouchSF__TT_Role__c+'",'+
            '"email": "'+aUser.Email+'",'+
            '"firstName": "'+aUser.FirstName+'",'+
            '"lastName": "'+aUser.LastName+'",'+
            '"team": "'+ttTeamId+'"'+
            '}';
            String userEndpoint = endpoint+'/'+aUser.TelosTouchSF__TT_UserId__c;

            Map<String, String> mapResponse = TelosTouchUtility.getResponse(aMethod, userEndpoint, mapHeader, body);

            if(mapResponse.get('status_code') == '200'){
                lstUserUpd.add(aUser);
            }

        }

        if(!lstUserUpd.isEmpty()){ Database.update(lstUserUpd); }

    }

    global void finish(Database.BatchableContext bc){

    }

}