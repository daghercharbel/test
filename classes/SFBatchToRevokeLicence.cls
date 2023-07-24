/**
* @author Cloud Analogy
* @date 26/08/2021.
* @description SFBatchToRevokeLicence....
*/
public with sharing class SFBatchToRevokeLicence implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    public List<Id> userList;
    private TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential;
    private TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials;
    
    /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description SFBatchToRevokeLicence ....
* @param userIdList ......
*/
public SFBatchToRevokeLicence(List<Id> userIdList){
        this.userList=userIdList;
        adminCredentials = new TelosTouchSF__TT_Admin_Credentials__mdt();
        authenticationCredential = new TelosTouchSF__TT_Authentication_Credential__mdt();
        if([SELECT count() FROM TelosTouchSF__TT_Admin_Credentials__mdt LIMIT 1] > 0){
            adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        }
    }
        /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description start ....
* @param BC ......
* @return Database.QueryLocator ...
*/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String q = 'SELECT TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c, TelosTouchSF__TT_UserName__c FROM User where Id IN :userList WITH SECURITY_ENFORCED';
       return Database.getQueryLocator(q);
    }
         /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description execute ....
* @param BC ......
* @param returnedUserList ......
*/
    public void execute(Database.BatchableContext BC,List<user> returnedUserList){

        try {

            String endPointURL;
            Map<String, String> headersMap = new Map<String, String>();
            map<Id, User> mapUser = new map<Id, User>();

            //Remove access in the app
            if(String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c) ){
                headersMap.put('Accept', 'application/json');
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Authorization', 'Bearer '+authenticationCredential.TelosTouchSF__Access_Token__c);
            }
            for(User aUser : returnedUserList){
                String calloutStatus = 'SUCCESS';
                if(String.isNotBlank(aUser.TelosTouchSF__TT_UserId__c)){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users/'+aUser.TelosTouchSF__TT_UserId__c;
                    Map<String, String> requestBodyMap = TelosTouchSF.TelosTouchUtility.getResponse('DELETE', endPointURL, headersMap, null);
                    if(requestBodyMap.get('status_code') != '200'){ calloutStatus = 'FAIL'; }
                }
                if(calloutStatus != 'SUCCESS'){ continue; }

                aUser.TelosTouchSF__Auth_Token__c ='';
                aUser.TelosTouchSF__TT_UserId__c ='';
                aUser.TelosTouchSF__TT_UserName__c ='';
                mapUser.put(aUser.Id, aUser);
            }
            
            //Remove access in the User Object
            if(!mapUser.isEmpty()){ Database.update(mapUser.values()); }

            //Remove access in the Permission Set Assigment 
            List<PermissionSetAssignment> lstPSA = [SELECT Id,PermissionSet.Name 
                                                    FROM PermissionSetAssignment 
                                                    WHERE (PermissionSet.Name = 'TTPSetForInsightObjMDRelations' OR PermissionSet.Name = 'TelosTouch_Custom_Permission') 
                                                    AND AssigneeId IN: mapUser.keySet() WITH SECURITY_ENFORCED] ; 
            if(!lstPSA.isEmpty()){ Database.delete(lstPSA); }
            
        } catch (Exception ex) {
            TelosTouchSF.TelosTouchUtility.generateAndSaveErrorLog(ex, 'SFBatchToRevokeLicence', 'execute', null);
        }
    }
     /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description finish ....
* @param BC ......
*/
    public void finish(Database.BatchableContext BC){

    } 
}