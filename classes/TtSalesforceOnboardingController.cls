public with sharing class TtSalesforceOnboardingController {
  private static final TelosTouchSF__TT_Admin_Credentials__mdt ADMINCREDENTIALS = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
  private static final TelosTouchSF__TT_Authentication_Credential__mdt AUTHENTICATIONCREDENTIALS = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
  @AuraEnabled
  public static Boolean startRegistrationProcess() {
    try {
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
        System.debug(request.getBody());
      response = http.send(request);
      System.debug(response.getStatusCode());
      System.debug(response.getBody());
      if (response.getStatusCode() == 201) {
        return true;
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
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        System.debug(request.getBody());
        return response.getStatusCode() == 201 ? true : false;
      }
      return false;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static String validateTokenAndFetchCredentials(String oneTimeToken) {
    try {
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
      System.debug(response.getStatusCode());
      System.debug(response.getBody());
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
      return JSON.serialize(
        TelosTouchSF.TelosTouchUtility.getAdminAccessToken(
          JSON.serialize(
            new List<TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper>{
              adminCredsWrapper
            }
          ),
          'From Setup'
        )
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        ' at Line: ' +
        e.getLineNumber()
      );
    }
  }
  @AuraEnabled
  public static Boolean checkIfEnterpriseClient() {
    try {
      return !AUTHENTICATIONCREDENTIALS.TelosTouchSF__Is_Trial__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
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
      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}