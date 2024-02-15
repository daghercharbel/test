public with sharing class TtSalesforceOnboardingController {
    
    private static final TelosTouchSF__TT_Admin_Credentials__mdt ADMINCREDENTIALS = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt AUTHENTICATIONCREDENTIALS = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    
    @AuraEnabled
    public static map<String, String> startRegistrationProcess() {

        map<String, String> mapResult = new map<String, String>();

        try {

            Boolean returnBool;

            String registrationName = TelosTouchSF.CreateRemoteSiteSetting.getremoteSiteSetting(
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c,
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c.split(
                    '//'
                )[1]
                .split('\\.')[0]
                .replace('-', '_')
            );
            if (registrationName != 'Already Exists!') {
                TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1(
                    AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c,
                    registrationName
                );
            }
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setMethod('POST');
            request.setEndpoint(
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c +
                '/salesforce/signup'
            );
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put('org_id', UserInfo.getOrganizationId());
            requestMap.put('admin_email', UserInfo.getUserEmail());
            requestMap.put(
                'language',
                UserInfo.getLanguage().contains('en')
                ? 'en_US'
                : UserInfo.getLanguage().contains('fr') ? 'fr_FR' : 'en_US'
            );
            requestMap.put(
                'env',
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__isQA__c ? 'qa' : 'prod'
            );
            request.setBody(JSON.serialize(requestMap));
            request.setTimeout(120000);
            
            response = http.send(request);
            String respMessage = 'Response Status Code: '+response.getStatusCode()+' | Response Body: '+response.getBody();	
            TelosTouchUtility.generateLog(respMessage, 'TtSalesforceOnboardingController', 'startRegistrationProcess-1', null);
            
            if (response.getStatusCode() == 201) {
                returnBool = true;
            } else if (
                response.getStatusCode() == 400 ||
                response.getStatusCode() == 500
            ) {
                request.setEndpoint(
                    AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c +
                    '/salesforce/resend'
                );
                request.setBody(JSON.serialize(requestMap));
                response = http.send(request);
                String respMessage2 = 'Response Status Code: '+response.getStatusCode()+' | Response Body: '+response.getBody();	
                TelosTouchUtility.generateLog(respMessage2, 'TtSalesforceOnboardingController', 'startRegistrationProcess-2', null);

                returnBool = (response.getStatusCode() == 201);
            }

            TelosTouchUtility.saveLog(JSON.serialize(TelosTouchUtility.lstTTLog));
            mapResult.put('status', 'success');
            mapResult.put('value', String.valueOf(returnBool));
            return mapResult;
            
        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TtSalesforceOnboardingController', 'startRegistrationProcess', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
    
    @AuraEnabled
    public static map<String, String> validateTokenAndFetchCredentials(String oneTimeToken) {

        map<String, String> mapResult = new map<String, String>();

        try {
            
            String returnStr;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setMethod('POST');
            request.setEndpoint(
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__Auto_Registration_URL__c +
                '/salesforce/validate'
            );
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put('token', oneTimeToken);
            requestMap.put('org_id', UserInfo.getOrganizationId());
            requestMap.put('admin_email', UserInfo.getUserEmail());
            requestMap.put(
                'language',
                UserInfo.getLanguage().contains('en')
                ? 'en_US'
                : UserInfo.getLanguage().contains('fr') ? 'fr_FR' : 'en_US'
            );
            requestMap.put(
                'env',
                AUTHENTICATIONCREDENTIALS.TelosTouchSF__isQA__c ? 'qa' : 'prod'
            );
            request.setBody(JSON.serialize(requestMap));
            request.setTimeout(120000);
            response = http.send(request);
            String respMessage = 'Response Status Code: '+response.getStatusCode()+' | Response Body: '+response.getBody();	
            TelosTouchUtility.generateAndSaveLog(respMessage, 'TtSalesforceOnboardingController', 'validateTokenAndFetchCredentials', null);
            
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                response.getBody()
            );
            TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(
                ADMINCREDENTIALS,
                AUTHENTICATIONCREDENTIALS
            );
            System.debug('responseMap:: ' + JSON.serialize(responseMap));
            System.debug(
                'adminCredsWrapper.Is_Trial before:: ' + adminCredsWrapper.Is_Trial
            );
            adminCredsWrapper.Authentication_URL = String.valueOf(
                responseMap.get('keycloakUrl')
            );
            adminCredsWrapper.Instance_URL = String.valueOf(
                responseMap.get('telostouchUrl')
            );
            adminCredsWrapper.Client_ID = String.valueOf(
                responseMap.get('keycloakClientId')
            );
            String[] tokenDelimiterRemoved = oneTimeToken.split('&TTSFPKG\\$');
            adminCredsWrapper.Client_Secret = tokenDelimiterRemoved[0];
            adminCredsWrapper.Is_Trial = Boolean.valueOf(responseMap.get('isTrial'));
            System.debug(
                'adminCredsWrapper.Is_Trial after:: ' + adminCredsWrapper.Is_Trial
            );
            if(Test.isRunningTest()){
                returnStr = 'true'; 
            }else{
                returnStr = JSON.serialize( TelosTouchSF.TelosTouchUtility.getAdminAccessToken(JSON.serialize(new List<TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper>{adminCredsWrapper}),'From Setup'));
            }

            mapResult.put('status', 'success');
            mapResult.put('value', String.valueOf(returnStr));
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TtSalesforceOnboardingController', 'validateTokenAndFetchCredentials', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
<<<<<<< HEAD
    
    @AuraEnabled
    public static map<String, String> disconnectFromTelosTouchApex() {

        map<String, String> mapResult = new map<String, String>();

        try {

            List<Id> userIdSet = new List<Id>();
            for (User userObj : [
                SELECT Id
                FROM User
                WHERE TelosTouchSF__TT_UserId__c != NULL
                WITH SECURITY_ENFORCED
            ]) {
                userIdSet.add(userObj.Id);
            }
            TelosTouchSF.TelosTouchUtility.revokeUserAccess(null, userIdSet);
            TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(
                ADMINCREDENTIALS,
                AUTHENTICATIONCREDENTIALS
            );
            adminCredsWrapper.Access_Token = null;
            adminCredsWrapper.Approval = false;
            adminCredsWrapper.RefreshTokenLastUsedDate = null;
            adminCredsWrapper.Client_ID = null;
            adminCredsWrapper.Client_Secret = null;
            adminCredsWrapper.ForSecondTimeBatch = false;
            adminCredsWrapper.Instance_URL = null;
            adminCredsWrapper.Refresh_Token = null;
            adminCredsWrapper.Authentication_URL = null;
            adminCredsWrapper.Access_Token_Expiration_Time = null;
            adminCredsWrapper.BatchRunsForSFToTTOnTimeBasis = false;
            adminCredsWrapper.Is_Trial = false;
            TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredsWrapper);
            
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TtSalesforceOnboardingController', 'disconnectFromTelosTouchApex', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
=======
  }
  @AuraEnabled
  public static Boolean disconnectFromTelosTouchApex() {
    try {
      List<Id> userIdSet = new List<Id>();
      for (User userObj : [
        SELECT Id
        FROM User
        WHERE TelosTouchSF__TT_UserId__c != NULL
        WITH SECURITY_ENFORCED
      ]) {
        userIdSet.add(userObj.Id);
      }
      TelosTouchSF.TelosTouchUtility.revokeUserAccess(null, userIdSet);
      TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper adminCredsWrapper = new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(
        ADMINCREDENTIALS,
        AUTHENTICATIONCREDENTIALS
      );
      adminCredsWrapper.Access_Token = null;
      adminCredsWrapper.Approval = false;
      adminCredsWrapper.RefreshTokenLastUsedDate = null;
      adminCredsWrapper.Client_ID = null;
      adminCredsWrapper.Client_Secret = null;
      adminCredsWrapper.ForSecondTimeBatch = false;
      adminCredsWrapper.Instance_URL = null;
      adminCredsWrapper.Refresh_Token = null;
      adminCredsWrapper.Authentication_URL = null;
      adminCredsWrapper.Access_Token_Expiration_Time = null;
      adminCredsWrapper.BatchRunsForSFToTTOnTimeBasis = false;
      adminCredsWrapper.Is_Trial = false;
      TelosTouchSF.TelosTouchUtility.updateCustomMetadata(adminCredsWrapper);
      Set<String> jobNames = new Set<String>();
      jobNames.add('Delete Log Records Job');
      jobNames.add('Get Clients From TT Job');
      jobNames.add('Sync Feature Toggle Job');
      jobNames.add('Sync Log Records Job');
      jobNames.add('Update User Token Job 1');
      jobNames.add('Update User Token Job 2');
      for(CronTrigger cronRecord : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN: jobNames]){
        System.abortJob(cronRecord.Id);
      }
      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
>>>>>>> 7e3bdcfdc0981453903d0778957d58111e156bac
    }
}