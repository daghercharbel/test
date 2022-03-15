/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TouchPointPreviewController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @return  Map<String, String> ....
*/
    @AuraEnabled
    public static Map<String, String> getIFrameDetails() {
        try {
            Map<String, String> dataMap = new map<String, String>();
            if (dataMap.isEmpty()) {
                dataMap.put('instanceURL', adminCredentials.TelosTouchSF__Instance_URL__c);
                datamap.put('accessToken', TelosTouchSF.TelosTouchUtility.getCurrentUserToken());
            }
            if (dataMap.size() > 0) {
                return dataMap;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Error is::' + e.getMessage() + ' at line no::' + e.getLineNumber());
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @return String ....
*/
    @AuraEnabled
    public static String getListId(){
        try{
            Map<String, String> returnMap = new Map<String, String>();
            returnMap.put('url', URL.getSalesforceBaseUrl().toExternalForm());
            ListView lvObj = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Campaign' AND Name = 'TT Campaigns' WITH SECURITY_ENFORCED LIMIT 1];
            returnMap.put('listId', lvObj.Id);
            return JSON.serialize(returnMap);
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception: '+ex.getMessage()+' Occurred at Line No.: '+ex.getLineNumber());
            return null;
        }
    }
}