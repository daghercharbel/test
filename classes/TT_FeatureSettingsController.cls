/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
public with sharing class TT_FeatureSettingsController {
 /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
* @return map<String,String>  ....
*/
    @AuraEnabled
    public static map<String,String> getFeatureMetadata(){

        map<String, String> mapResult = new map<String, String>();

        try {

            String strInvite = 'Invite';
            list<TelosTouchSF__TT_Feature_Flag__mdt> lstMetadata =[SELECT TelosTouchSF__SF_Flag__c,TelosTouchSF__ShowClientTagging__c,
                                                                    TelosTouchSF__ShowFinestLogs__c,TelosTouchSF__TT_Flag__c 
                                                                    FROM TelosTouchSF__TT_Feature_Flag__mdt 
                                                                    WHERE MasterLabel =: strInvite WITH SECURITY_ENFORCED LIMIT 1];
            
            if(!lstMetadata.isEmpty()){
                mapResult.put('status', 'success');
                mapResult.put('value', JSON.serialize(lstMetadata[0]));
            } else {
                mapResult.put('status', 'error');
                mapResult.put('value', 'Metadata not found.');
            }
            return mapResult;

        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TT_FeatureSettingsController', 'getFeatureMetadata', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
* @return Boolean ....
*/
    @AuraEnabled
    public static Boolean getFinestLogValue(){
        String strInvite = 'Invite';
        TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id, TelosTouchSF__ShowFinestLogs__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel= :strInvite WITH SECURITY_ENFORCED LIMIT 1];
        return inviteRecord.TelosTouchSF__ShowFinestLogs__c;
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
* @return boolean ....
*/
    @AuraEnabled
    public static Boolean IsUserSystemAdmin(){
        Profile UserProfile = [SELECT Id, Name from Profile WHERE Id=:UserInfo.getProfileId() WITH SECURITY_ENFORCED];
        if(UserProfile.Name == 'System Administrator'){
            return true;
        }
        return false;
    }
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
* @param stringMdt ...
* @return map<String,String>  ....
*/
    @AuraEnabled
    public static map<String,String> setFeatureMetadata(String stringMdt){

        map<String, String> mapResult = new map<String, String>();
        list<String> lstMdtFields = new list<String>{
            'TelosTouchSF__SF_Flag__c',
            'TelosTouchSF__ShowClientTagging__c',
            'TelosTouchSF__ShowFinestLogs__c',
            'TelosTouchSF__TT_Flag__c'
        };

        try {

            TelosTouchSF__TT_Feature_Flag__mdt featureMdt = (TelosTouchSF__TT_Feature_Flag__mdt)JSON.deserialize(stringMdt,TelosTouchSF__TT_Feature_Flag__mdt.class);

            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'TelosTouchSF__TT_Feature_Flag.TelosTouchSF__Invite';
            customMetadata.label = 'Invite';
        
            for(String field : lstMdtFields){
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = field;
                customField.value = featureMdt.get(field);
                customMetadata.values.add(customField);
            }

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            TelosTouchSF.TelosTouchUtility callback = new TelosTouchSF.TelosTouchUtility();
            if(!(Test.isRunningTest())){
                Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            }
            
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {

            TelosTouchUtility.generateAndSaveErrorLog(ex, 'TT_FeatureSettingsController', 'getFeatureMetadata', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }
    
}