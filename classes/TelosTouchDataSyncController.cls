/**
* @author Cloud Analogy
* @date 26/08/2021.
* @description TelosTouchDataSyncController ....
*/
public with sharing class TelosTouchDataSyncController {
  private static final TelosTouchSF__TT_Admin_Credentials__mdt ADMINCREDENTIALS = TelosTouchSF.TelosTouchUtility.getCustomMetadata();

  /**
   * @author Swapnil Sen
   * @date 29/11/2022
   * @description getSyncData: Used to get initial sync data when component is initialized
   * @return String ...
   */
  @AuraEnabled
  public static string getSyncData() {
    try {
      Map<String, Object> returnMap = new Map<String, Object>();
      List<TelosTouchSF__TT_Log__c> ttLogObjList = new List<TelosTouchSF__TT_Log__c>();
      String strMainLog = 'Main Log';
      ttLogObjList = [
        SELECT Id, TelosTouchSF__LastUpdated__c
        FROM TelosTouchSF__TT_Log__c
        WHERE TelosTouchSF__Log_Type__c = :strMainLog
        WITH SECURITY_ENFORCED
        ORDER BY TelosTouchSF__LastUpdated__c DESC
        LIMIT 1
      ];
      if(!ttLogObjList.isEmpty()){
        returnMap.put(
          'lastUpdated',
          (Object) ttLogObjList[0].TelosTouchSF__LastUpdated__c != null
            ? ttLogObjList[0].TelosTouchSF__LastUpdated__c.format(
                'dd-MM-yyyy hh:mm:ss a'
              )
            : ''
        );
      }else{
        returnMap.put('lastUpdated', '');
      }
      returnMap.put('approval', ADMINCREDENTIALS.TelosTouchSF__Approval__c);
      List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
      if (
        Schema.sObjectType.AsyncApexJob.isAccessible() &&
        Schema.sObjectType.AsyncApexJob.isQueryable() &&
        Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
        Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible()
      ) {
        String strAborted = 'Aborted';
        String strCompleted = 'Completed';
        String strFailed = 'Failed';
        String strGetClientsFromTTQueueable = 'GetClientsFromTTQueueable';
        String strGetTaskFromTTQueueable = 'GetTaskFromTTQueueable';
        String strGetCampaignsFromTTQueueable = 'GetCampaignsFromTTQueueable';

        asyncApexJobList = [
          SELECT Id, ApexClass.Name
          FROM AsyncApexJob
          WHERE
            Status != :strAborted
            AND Status != :strCompleted
            AND Status != :strFailed
            AND (ApexClass.Name = :strGetClientsFromTTQueueable
            OR ApexClass.Name = :strGetTaskFromTTQueueable
            OR ApexClass.Name = :strGetCampaignsFromTTQueueable)
          LIMIT 3
        ];
      }
      if (asyncApexJobList.size() > 0) {
        returnMap.put('asyncJobstatus', (Object) false);
      } else {
        returnMap.put('asyncJobstatus', (Object) true);
      }
      return JSON.serialize(returnMap);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  /**
   * @author Swapnil Sen
   * @date 29/11/2022
   * @description syncAllRecordsApex: Used to initiate sync with TelosTouch
   * @param syncType Defines if the sync is hard or soft
   * @param syncObject Defines which object to sync
   */
  @AuraEnabled
  public static void syncAllRecordsApex(String syncType, String syncObject) {
    try {
      if (syncObject == 'All') {
        Database.executeBatch(
          new BatchForBulkDataInsertOrUpdate(
            null,
            null,
            null,
            'Contact',
            null,
            syncType,
            null
          )
        );
      } else if (syncObject == 'Contact') {
        Database.executeBatch(
          new BatchForBulkDataInsertOrUpdate(
            null,
            null,
            null,
            'Contact',
            null,
            syncType,
            syncObject
          )
        );
      } else if (syncObject == 'Task') {
        Database.executeBatch(
          new BatchForBulkDataInsertOrUpdate(
            null,
            null,
            null,
            'Task',
            null,
            syncType,
            syncObject
          )
        );
      } else if (syncObject == 'Campaign') {
        Database.executeBatch(
          new BatchForBulkDataInsertOrUpdate(
            null,
            null,
            null,
            'Campaign',
            null,
            syncType,
            syncObject
          )
        );
      }
    } catch (Exception ex) {
      System.debug(
        LoggingLevel.ERROR,
        'Exception::' +
        ex.getMessage() +
        'On Line ::' +
        ex.getLineNumber()
      );
    }
  }
  /**
   * @author Swapnil Sen
   * @date 29/11/2022
   * @description getAllLogs: Used to get TelosTouch logs from Back End
   * @return String ...
   */
  @AuraEnabled
  public static string getAllLogs() {
    try {
      Map<String, Object> returnMap;
      List<Object> returnList = new List<Object>();
      String strMainLog = 'Main Log';
      if (UserInfo.getLanguage().contains('en')) {
        for (TelosTouchSF__TT_Log__c log : [
          SELECT
            Id,
            Name,
            TelosTouchSF__Result__c,
            TelosTouchSF__LastUpdated__c,
            CreatedDate,
            TelosTouchSF__Total_Records_Count__c,
            TelosTouchSF__Comments__c
          FROM TelosTouchSF__TT_Log__c
          WHERE TelosTouchSF__Log_Type__c = :strMainLog
          WITH SECURITY_ENFORCED
          ORDER BY CreatedDate DESC
          LIMIT 50000
        ]) {
          returnMap = new Map<String, Object>();
          returnMap.put('Id', (Object) log.Id);
          returnMap.put('Name', (Object) log.Name);
          returnMap.put(
            'TelosTouchSF__Result__c',
            (Object) log.TelosTouchSF__Result__c
          );
          returnMap.put(
            'TelosTouchSF__LastUpdated__c',
            (Object) log.TelosTouchSF__LastUpdated__c.format(
              'dd-MM-yyyy hh:mm:ss a'
            )
          );
          returnMap.put(
            'CreatedDate',
            (Object) log.CreatedDate.format('dd-MM-yyyy hh:mm:ss a')
          );
          returnMap.put(
            'TelosTouchSF__Total_Records_Count__c',
            (Object) log.TelosTouchSF__Total_Records_Count__c
          );
          returnMap.put(
            'TelosTouchSF__Comments__c',
            (Object) log.TelosTouchSF__Comments__c
          );
          returnList.add((Object) returnMap);
        }
      } else if (UserInfo.getLanguage().contains('fr')) {
        for (TelosTouchSF__TT_Log__c log : [
          SELECT
            Id,
            Name,
            TelosTouchSF__Result__c,
            TelosTouchSF__LastUpdated__c,
            CreatedDate,
            TelosTouchSF__Total_Records_Count__c,
            TelosTouchSF__Comments_FR__c
          FROM TelosTouchSF__TT_Log__c
          WHERE TelosTouchSF__Log_Type__c = :strMainLog
          WITH SECURITY_ENFORCED
          ORDER BY CreatedDate DESC
          LIMIT 50000
        ]) {
          returnMap = new Map<String, Object>();
          returnMap.put('Id', (Object) log.Id);
          returnMap.put('Name', (Object) log.Name);
          returnMap.put(
            'TelosTouchSF__Result__c',
            (Object) log.TelosTouchSF__Result__c
          );
          returnMap.put(
            'TelosTouchSF__LastUpdated__c',
            (Object) log.TelosTouchSF__LastUpdated__c.format(
              'dd-MM-yyyy hh:mm:ss a'
            )
          );
          returnMap.put(
            'CreatedDate',
            (Object) log.CreatedDate.format('dd-MM-yyyy hh:mm:ss a')
          );
          returnMap.put(
            'TelosTouchSF__Total_Records_Count__c',
            (Object) log.TelosTouchSF__Total_Records_Count__c
          );
          returnMap.put(
            'TelosTouchSF__Comments_FR__c',
            (Object) log.TelosTouchSF__Comments_FR__c
          );
          returnList.add((Object) returnMap);
        }
      }
      return JSON.serialize(returnList);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}