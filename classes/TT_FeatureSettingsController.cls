/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
public with sharing class TT_FeatureSettingsController {
    @AuraEnabled
        /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description ....
	* @return boolean ....
	*/
    public static Boolean getTTFlagValue(){
        TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id,MasterLabel ,TelosTouchSF__TT_Flag__c, TelosTouchSF__SF_Flag__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel='Invite' WITH SECURITY_ENFORCED LIMIT 1];
        return inviteRecord.TelosTouchSF__TT_Flag__c;
    }
    /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ....
 * @return boolean ....
 */
    @AuraEnabled
    public static Boolean getSFFlagValue(){
        TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id,MasterLabel ,TelosTouchSF__TT_Flag__c, TelosTouchSF__SF_Flag__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel='Invite' WITH SECURITY_ENFORCED LIMIT 1];
        return inviteRecord.TelosTouchSF__SF_Flag__c;
    }
    /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ....
 * @return boolean ....
 */
    @AuraEnabled
    public static Boolean IsUserSystemAdmin(){
        Profile UserProfile = [SELECT Id, Name from Profile WHERE Id=:UserInfo.getProfileId()  WITH SECURITY_ENFORCED];
        if(UserProfile.Name == 'System Administrator'){
            return true;
        }
        return false;
    }

      /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ....
 * @return Boolean ....
 */
    @AuraEnabled
    public static Boolean getFinestLogValue(){
        TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id, TelosTouchSF__ShowFinestLogs__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel='Invite' WITH SECURITY_ENFORCED LIMIT 1];
        return inviteRecord.TelosTouchSF__ShowFinestLogs__c;
    }

}