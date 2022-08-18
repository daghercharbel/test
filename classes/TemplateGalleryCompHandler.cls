/**
* @author Cloud Analogy
* @date 02/08/2021
* @description used for all the template gallery component
*/

public with sharing class TemplateGalleryCompHandler {
  private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
  
      /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetching all the touchpoints
*/
  @AuraEnabled
  public static String getTouchPointTemplates() {
    String methodType = 'GET';
    List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
    String endPointURL;
    String userAuthTOKEN;
    Map<String, String> headersMap = new Map<String, String>();
    List<Object> templateObjects = new List<Object>();
    userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
    headersMap.put('Authorization', 'Bearer ' + userAuthTOKEN);
    headersMap.put('Content-Type', 'application/json');
    headersMap.put('Accept', 'application/json');
    TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    if (String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c)) {
      endPointURL =
        adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/templates';
    }
    Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(
      methodType,
      endPointURL,
      headersMap,
      null
    );
    if (getResponseMap.get('status_code') == '200') {
      String resbody = getResponseMap.get('body');
      List<Object> templateList = new List<Object>();
      templateList = (List<Object>) JSON.deserializeUntyped(resbody);
      for (Object tempObj : templateList) {
        Map<String, Object> templateMap = (Map<String, Object>) tempObj;
        templateMap.put(
          'imageURL',
          (Object) ('background-image: url(' +
          adminCredentials.TelosTouchSF__Instance_URL__c +
          '/api/v1/attachments/' +
          templateMap.get('image_id') +
          ')')
        );
        JSONParser parser = JSON.createParser(
          '{"t":"' +
          String.valueOf(templateMap.get('modified_at')) +
          '"}'
        );
        parser.nextToken();
        parser.nextValue();
        DateTime dt = DateTime.newInstance(parser.getDateTimeValue().getTime());
        templateMap.put(
          'modified_at',
          (Object) (String.valueOf(dt.format('MMM dd, yyyy hh:mm a')))
        );
        templateObjects.add((Object) templateMap);
      }
    } else if (getResponseMap.get('status_code') == '401') {
        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
    } else if (getResponseMap.get('status_code') == '500') {
      createListOfLog.add(
        TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error','Erreur de serveur interne',1));
    } else {
      if (getResponseMap.get('status_code').length() > 0) {
        list<String> StatusCodeList = getResponseMap.get('status_code').split('0');
        if (StatusCodeList[0] == '4' || StatusCodeList[0] == '5') {
          createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure', 'Something went wrong. Status Code: ' +getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :' +getResponseMap.get('status_code'),1));
        }
      }
    }
    if (createListOfLog.size() > 0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()) {
      insert createListOfLog;
    }
    if (templateObjects.size() > 0) {
      return JSON.serialize(templateObjects);
    }
    return null;
  }

        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to generate the Iframe url
*/

  @AuraEnabled
  public static Map<String, String> getIFrameDetails() {
    try {
      Map<String, String> dataMap = new Map<String, String>();
      if (dataMap.isEmpty()) {
        dataMap.put(
          'instanceURL',
          adminCredentials.TelosTouchSF__Instance_URL__c
        );
        datamap.put(
          'accessToken',
          TelosTouchSF.TelosTouchUtility.getCurrentUserToken()
        );
      }
      if (dataMap.size() > 0) {
        return dataMap;
      } else {
        return null;
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error is::' +
        e.getMessage() +
        ' at line no::' +
        e.getLineNumber()
      );
      return null;
    }
  }


        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param campaignRecordId stores the campaign Id
* @param touchPointTemplateId   stores the touchpoint template id
*/

  @AuraEnabled
  public static Boolean SaveTouchPointTemplate(
    Id campaignRecordId,
    String touchPointTemplateId
  ) {
    try {
      Campaign campObj = [
        SELECT Id, TelosTouchSF__TouchPoint_Template_Id__c
        FROM Campaign
        WHERE Id = :campaignRecordId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      campObj.TelosTouchSF__TouchPoint_Template_Id__c = touchPointTemplateId;
      if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable() ){
        update campObj;
        return true;
      }
      return false;
    } catch (Exception e) {
      System.debug('Error is: '+ e.getMessage()+ ' at line no: '+ e.getLineNumber());
      return false;
    }
  }


          /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param templateId stores the touchpoint template Id
* @param language   stores the  selected language
*/

  @AuraEnabled
  public static String generatePreviewIFrameUrl(String templateId, String language) {
    try{
      List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
      Map<String,String> urlMap = new Map<String, String>();
      urlMap.put('email', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId+'/preview/public/email?lang='+language+'&custom_messages=%5B%5D&access_token='+TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
      Map<String, String> headersMap = new Map<String, String>();
      String endPointURL = '';
      String userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
      headersMap.put('Authorization','Bearer '+userAuthTOKEN);
      headersMap.put('Content-Type', 'application/json');
      headersMap.put('Accept', 'application/json');
      if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
          endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+templateId+'/preview/portalurl?language='+language;
      }
      Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, headersMap, null);
      if(getResponseMap.get('status_code') == '401'){
          createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
      }else if(getResponseMap.get('status_code') == '500'){
          createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
      }else{
          if(getResponseMap.get('status_code').length() > 0){
              list<String> statusCodeList = getResponseMap.get('status_code').split('0');
              if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                  createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
              }
          }
      }
      urlMap.put('touchpoint', getResponseMap.get('body'));
      System.debug(LoggingLevel.DEBUG, urlMap);
      if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() ){
          insert createListOfLog;
      }
      return JSON.serialize(urlMap);
    }catch(Exception e){
      System.debug('Error is: '+ e.getMessage()+' at line no: '+e.getLineNumber());
      return null;
    }    
  }
}