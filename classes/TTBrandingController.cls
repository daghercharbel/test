public with sharing class TTBrandingController {

    private static TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();

    @AuraEnabled
    public static map<String,String> createAttachment(String body){

        map<String, String> mapResult = new map<String, String>();
        Id userId;
        try {

            if(String.isBlank(body)) { throw new AuraHandledException('Empty request body'); }
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            userId = aUser.Id;
            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/attachments?isBase64=true';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            
            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('POST', endPointURL, mapHeader, body);

            if(mapResponse.containsKey('status_code')){
                if(mapResponse.get('status_code') == '200'){
                    mapResult.put('status', 'success');
                    mapResult.put('value', mapResponse.get('body'));
                } else {
                    mapResult.put('status', 'error');
                    mapResult.put('value', 'Status Code: '+mapResponse.get('status_code'));
                }
                return mapResult;
            } else {
                throw new AuraHandledException('Error');
            }

        } catch (Exception ex) {

            TelosTouchUtility.generateErrorLog(ex, 'TTBrandingController', 'createAttachment', userId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }

    }

    @AuraEnabled
    public static map<String,String> getSignature(){

        map<String, String> mapResult = new map<String, String>();
        Id userId;
        try {
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            userId = aUser.Id;
            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/user/signature';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            
            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, mapHeader, null);

            if(mapResponse.containsKey('body')){
                mapResult.put('status', 'success');
                mapResult.put('value', mapResponse.get('body'));
                return mapResult;
            } else {
                throw new AuraHandledException('User not Found');
            }

        } catch (Exception ex) {

            TelosTouchUtility.generateErrorLog(ex, 'TTBrandingController', 'getSignature', userId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }

    }

    @AuraEnabled
    public static map<String,String> putSignature(String body){

        map<String, String> mapResult = new map<String, String>();
        Id userId;
        try {

            if(String.isBlank(body)) { throw new AuraHandledException('Empty request body'); }
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

            userId = aUser.Id;
            String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/user/signature';

            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            
            Map<String, String> mapResponse = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, body);

            if(mapResponse.containsKey('status_code')){
                if(mapResponse.get('status_code') == '200'){
                    mapResult.put('status', 'success');
                    mapResult.put('value', mapResponse.get('body'));
                } else {
                    mapResult.put('status', 'error');
                    mapResult.put('value', 'Status Code: '+mapResponse.get('status_code'));
                }
                return mapResult;
            } else {
                throw new AuraHandledException('Error');
            }

        } catch (Exception ex) {

            TelosTouchUtility.generateErrorLog(ex, 'TTBrandingController', 'putSignature', userId);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }

    }
}
