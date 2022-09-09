/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TelosTouchUtility class is used for multiple task for example Sync third party credentials and get token and Update  custom setting and used TelosTouch API for verify the Admin credentials.
*/
public with sharing class TelosTouchUtility implements Metadata.DeployCallback{
    
    //Interface method 
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Callback Function for Custom Metadata
* @param result ....
* @param context ....
*/

    public class CustomException extends Exception {}

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            //Success
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = getCustomMetadata();
            System.debug(LoggingLevel.DEBUG, 'Success Result-' + result);
            System.debug(LoggingLevel.DEBUG, 'Success Context-' + context);
            List<CronJobDetail> jobList = [SELECT Id FROM CronJobDetail Where Name LIKE 'Delete Log Records%' OR
                                           Name LIKE 'Update User Token Job%' OR
                                           Name LIKE 'Get Clients From TT Job%' OR
                                           Name LIKE 'Sync Feature Toggle Job%' WITH SECURITY_ENFORCED];
            System.debug(LoggingLevel.DEBUG, 'JobList Size: '+jobList.size());
            if(jobList.size()<5 && String.isNotEmpty(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c)){
                System.debug(LoggingLevel.DEBUG, 'Jobs Scheduled!');
                if(adminCredentials.TelosTouchSF__Auto_Schedule_Jobs__c){
                    scheduleAllJobsFromHere();
                }
            }
        } else {
            //Failed
            System.debug(LoggingLevel.DEBUG,'Failed Result-' + result);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the TT id of campaigns.
* @param campId stores id of campaign.
* @param remainingClientIds stores...
*/
    @AuraEnabled
    public static String getTTCampaignId(String campId, String remainingClientIds){
        try{
            List<String> remainingClientIdsList = new List<String>();
            remainingClientIdsList = (List<String>) JSON.deserialize(remainingClientIds, List<String>.class);
            String ttCampId = TTcampaignResponse.getCampaignResponse(campId, remainingClientIdsList);
            return ttCampId;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return TelosTouchSF__TT_Admin_Credentials__mdt TelosTouchSF__TT_Admin_Credentials__mdt ....
*/
    public static TelosTouchSF__TT_Admin_Credentials__mdt getCustomMetadata(){
        try{
            String profileName = [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId()].Profile.Name;
            if(profileName == System.Label.TelosTouchSF.ShowTTConfigPage &&
               [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name] == 0){
                   PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: System.Label.TelosTouchSF.TelosTouch_Permission_Set_Name WITH SECURITY_ENFORCED];
                   if(Schema.SObjectType.PermissionSetAssignment.isAccessible() && Schema.SObjectType.PermissionSetAssignment.isCreateable() &&
                      Schema.SObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible() && Schema.SObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
                      Schema.SObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() && Schema.SObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable() ){
                          insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
                      }
               }
            if(Test.isRunningTest() && [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name] > 0 &&
               [SELECT Count() FROM TelosTouchSF__TT_Admin_Credentials__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label LIMIT 1] > 0 ){
                   return [SELECT TelosTouchSF__Client_ID__c,TelosTouchSF__Auto_Schedule_Jobs__c,TelosTouchSF__Refresh_Token_Last_Used_Date__c, TelosTouchSF__Client_Secret__c, TelosTouchSF__Access_Token__c, TelosTouchSF__Approval__c, TelosTouchSF__ConfigPageVisible__c, TelosTouchSF__Authentication_URL__c,
                           TelosTouchSF__ForSecondTimeBatch__c, TelosTouchSF__Instance_URL__c, TelosTouchSF__Refresh_Token__c, TelosTouchSF__Access_Token_Expiration_Time__c, TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c,
                           TelosTouchSF__NotSyncTaskIfHaving__c, TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c, TelosTouchSF__RestrictedTTFieldMapping__c, TelosTouchSF__Use_CreatedById__c,
                           TelosTouchSF__Registration_DateTime__c, TelosTouchSF__Registration_Successful__c, TelosTouchSF__Registration_Request_Expiry__c, TelosTouchSF__Team_Name__c
                           FROM TelosTouchSF__TT_Admin_Credentials__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label WITH SECURITY_ENFORCED LIMIT 1];
               }else if([SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name] > 0 &&
                        [SELECT Count() FROM TelosTouchSF__TT_Admin_Credentials__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label LIMIT 1] > 0 ){
                            return [SELECT TelosTouchSF__Client_ID__c,TelosTouchSF__Auto_Schedule_Jobs__c,TelosTouchSF__Refresh_Token_Last_Used_Date__c, TelosTouchSF__Client_Secret__c, TelosTouchSF__Access_Token__c, TelosTouchSF__Approval__c, TelosTouchSF__ConfigPageVisible__c, TelosTouchSF__Authentication_URL__c,
                                    TelosTouchSF__ForSecondTimeBatch__c, TelosTouchSF__Instance_URL__c, TelosTouchSF__Refresh_Token__c, TelosTouchSF__Access_Token_Expiration_Time__c, TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c,
                                    TelosTouchSF__NotSyncTaskIfHaving__c, TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c, TelosTouchSF__RestrictedTTFieldMapping__c, TelosTouchSF__Use_CreatedById__c,
                                    TelosTouchSF__Registration_DateTime__c, TelosTouchSF__Registration_Successful__c, TelosTouchSF__Registration_Request_Expiry__c, TelosTouchSF__Team_Name__c
                                    FROM TelosTouchSF__TT_Admin_Credentials__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label WITH SECURITY_ENFORCED LIMIT 1];
                        }else{
                            return new TelosTouchSF__TT_Admin_Credentials__mdt();
                        }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error is::'+e.getMessage() +'at line no::'+e.getLineNumber());
            return new TelosTouchSF__TT_Admin_Credentials__mdt();
        }
        
    }
    public static TelosTouchSF__TT_Authentication_Credential__mdt getAuthenticationCustomMetadata(){
        try{
            if(Test.isRunningTest() && [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name] >0 &&
               [SELECT Count() FROM TelosTouchSF__TT_Authentication_Credential__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label LIMIT 1] > 0 ){
                   return [SELECT TelosTouchSF__Client_ID__c, TelosTouchSF__Client_Secret__c, TelosTouchSF__Access_Token__c, TelosTouchSF__Refresh_Token__c
                           FROM TelosTouchSF__TT_Authentication_Credential__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label WITH SECURITY_ENFORCED LIMIT 1];
               }else if([SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name] > 0 &&
                        [SELECT Count() FROM TelosTouchSF__TT_Authentication_Credential__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label LIMIT 1] > 0 ){
                            return [SELECT TelosTouchSF__Client_ID__c, TelosTouchSF__Client_Secret__c, TelosTouchSF__Access_Token__c, TelosTouchSF__Refresh_Token__c
                                    FROM TelosTouchSF__TT_Authentication_Credential__mdt WHERE MasterLabel =: System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label WITH SECURITY_ENFORCED LIMIT 1];
                        }else{
                            return new TelosTouchSF__TT_Authentication_Credential__mdt();
                        }   
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error is::'+e.getMessage()+' at line no:'+e.getLineNumber());
            return new TelosTouchSF__TT_Authentication_Credential__mdt();
        }
        
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the TT API settings.
* @param isCallingFrom stores the value of isCallingFrom.
* @param campId stores id of campaign.
* @return userCredentialsWrapper getActiveUserWrapper ....
*/
    @AuraEnabled
    public static userCredentialsWrapper getSettingAPI(String isCallingFrom, String campId){
        AdminCredentialsWrapper apiSetting;
        Integer recordCount1 = [SELECT count() FROM TelosTouchSF__TT_Admin_Credentials__mdt WITH SECURITY_ENFORCED];
        Integer recordCount2 = [SELECT count() FROM TelosTouchSF__TT_Authentication_Credential__mdt WITH SECURITY_ENFORCED];
        if(recordCount1 > 0 && recordCount2 > 0){
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = new TelosTouchSF__TT_Admin_Credentials__mdt();
            adminCredentials = getCustomMetadata();
            TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredentials = new TelosTouchSF__TT_Authentication_Credential__mdt();
            authenticationCredentials = getAuthenticationCustomMetadata();
            apiSetting = new AdminCredentialsWrapper(adminCredentials, authenticationCredentials);
        }else{
            apiSetting = new AdminCredentialsWrapper();
        }
        
        if(((campId != null && String.isNotBlank(campId)) || isCallingFrom == 'ManageTouchPoint' || isCallingFrom == 'TTDeshboard') && apiSetting.Access_Token != null ){
            UserCredentialsWrapper getActiveUserWrapper= new UserCredentialsWrapper();
            getActiveUserWrapper.authToken = getCurrentuserTOKEN();
            getActiveUserWrapper.adminCredentials = apiSetting;
            if(getActiveUserWrapper.authToken != null){
                return getActiveUserWrapper;
            }else{
                getActiveUserWrapper.errorMessage = 'This Owner not contain TT userId';
                return getActiveUserWrapper;
            }
        }else{
            return getUserAccessToken(apiSetting, isCallingFrom);
        }
    }
    /*public static UserCredentialsWrapper getUserauthTOKEN(AdminCredentialsWrapper apiSettingList){
try {
UserCredentialsWrapper getActiveUserWrapper= new UserCredentialsWrapper();
TTUserWrapper  ttuserObj = new TTUserWrapper();
if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() &&
Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() &&
Schema.sObjectType.User.fields.TT_UserId__c.isAccessible()){
User user = new User();
user = [SELECT Id, Auth_Token__c,TT_UserName__c,TT_UserId__c FROM User WHERE Id =: UserInfo.getUserId()];
if(String.isNotBlank(user.TT_UserId__c)){
String returnTOKEN = '';
ttuserObj = getTOKENForEachUser(user.TT_UserId__c, INSTANCEURL, TOKEN);
returnTOKEN = ttuserObj.TTToken;
if(user != null && returnTOKEN != null && user.TT_UserName__c!= null){
if(Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isUpdateable() &&
Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserName__c.isUpdateable() ){
user.Auth_Token__c = returnTOKEN;
user.TT_UserName__c = ttuserObj.ttUserName;
Blob blobValue = Blob.valueOf(user.TT_UserName__c +':' +returnTOKEN);
String authTOKEN = EncodingUtil.base64Encode(blobValue);

}
}
getActiveUserWrapper.settingApi = apiSettingList[0];
if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isUpdateable()){
update user;
}
}
}else{
getActiveUserWrapper.errorMessage = 'This Owner not contain TT userId';
}
return getActiveUserWrapper;
} catch (Exception ex) {
System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
}
return null;
}*/
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the user auth token.
* @param recordId stores id of record.
* @return TelosTouchWrapperUtils.salesforceCamapaignWrapper wrapper ....
*/
    @AuraEnabled
    public static TelosTouchWrapperUtils.salesforceCamapaignWrapper sendCampaignTouchPoint(Id recordId) {
        try{
            TelosTouchWrapperUtils.salesforceCamapaignWrapper wrapper = new TelosTouchWrapperUtils.salesforceCamapaignWrapper();
            wrapper.clientIds = new List<String>();
            Schema.SObjectType entityType = recordId.getSobjectType();
            String objectName = String.valueOf(entityType);
            if(objectName != 'Campaign'){
                String strQuery = 'SELECT Id, Name,TelosTouchSF__TT_Client_Id__c FROM '+objectName +' WHERE id =:recordId LIMIT 1' ;
                List<sObject> recordObj  = Database.query(String.EscapeSingleQuotes(strQuery));
                Contact  conObject= new Contact();
                Lead  leadObject= new Lead();
                if(objectName == 'Lead'){
                    leadObject = (Lead)recordObj[0];
                    if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isCreateable() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()  && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable()){
                        wrapper.clientIds.add(leadObject.TelosTouchSF__TT_Client_Id__c);
                    }
                    if(leadObject.TelosTouchSF__TT_Client_Id__c != null){
                        wrapper.returnMessage ='synced lead';
                    }else{
                        wrapper.returnMessage ='not synced lead';
                    }
                }else if (objectName == 'Contact'){
                    conObject = (Contact)recordObj[0];
                    if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isCreateable() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()  && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable()){
                        wrapper.clientIds.add(conObject.TelosTouchSF__TT_Client_Id__c);
                    }
                    if(conObject.TelosTouchSF__TT_Client_Id__c != null){
                        wrapper.returnMessage ='synced contact';
                    }else{
                        wrapper.returnMessage ='not synced contact';
                    }
                }
            }else{
                List<Campaign> campaigns = new List<Campaign>();
                if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() &&
                   Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                   Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() ){
                       campaigns =[SELECT Name,TelosTouchSF__TT_Campaign_Id__c,RecordType.Name FROM Campaign WHERE Id=:recordId];
                   }
                List<CampaignMember> campaignMembers = new List<CampaignMember>();
                if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isQueryable() &&
                   Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                   Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible()){
                       campaignMembers=  [SELECT ContactId, Contact.TelosTouchSF__TT_Client_Id__c,
                                          LeadId, Lead.TelosTouchSF__TT_Client_Id__c,
                                          Lead.Phone FROM CampaignMember WHERE CampaignId=:recordId];
                   }
                wrapper.CampId = recordId;
                if(campaigns.size() >0 && campaigns[0].RecordType.Name != null && campaigns[0].RecordType.Name != 'TelosTouch'){
                    wrapper.returnMessage ='Campaign is not having the TelosTouch record type.';
                    return wrapper;
                }
                if(campaigns.size() >0 && campaigns[0].TelosTouchSF__TT_Campaign_Id__c != null && String.isNotEmpty(campaigns[0].TelosTouchSF__TT_Campaign_Id__c)){
                    wrapper.returnMessage ='You have already sent a touchpoint for this campaign.';
                    return wrapper;
                }
                if(campaignMembers.size() >0){
                    for(CampaignMember memObj: campaignMembers){
                        if(memObj.ContactId != null && memObj.Contact.TelosTouchSF__TT_Client_Id__c != null ){
                            wrapper.clientIds.add(memObj.Contact.TelosTouchSF__TT_Client_Id__c);
                        }
                        else if(memObj.LeadId != null && memObj.Lead.TelosTouchSF__TT_Client_Id__c != null){
                            wrapper.clientIds.add(memObj.Lead.TelosTouchSF__TT_Client_Id__c);
                        }
                        else if(memObj.Lead.TelosTouchSF__TT_Client_Id__c == null || memObj.Contact.TelosTouchSF__TT_Client_Id__c == null){
                            wrapper.returnMessage ='Please check all Campaign members synced or not.';
                        }
                    }
                    return  wrapper;
                }else{
                    wrapper.returnMessage ='Please add Campaign members';
                }
            }
            return wrapper;
        }catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
        }
        return null;
    }
    
    /*@AuraEnabled
public static userCredentialsWrapper saveSettings_Apex(List<TelosTouch_API_Settings__c> apiSettingList, String isCallingFrom) {
try {
if(isCallingFrom == 'From Setup'){
String[] StringList = apiSettingList[0].TelosTouchSF__Instance_URL__c.split('//');
String[] StringList1 = StringList[1].split('\\.');
if(apiSettingList[0].TelosTouchSF__Instance_URL__c.trim() != null && StringList1[0] != null){
CreateRemoteSiteSetting.remoteSiteSetting1(apiSettingList[0].TelosTouchSF__Instance_URL__c,StringList1[0]);  
}  
}
if(apiSettingList.size() >0 && apiSettingList[0].TelosTouchSF__Instance_URL__c != null &&
apiSettingList[0].Client_id_username__c != null && apiSettingList[0].Client_secret_password__c != null){
return thirdPartySignIn(apiSettingList, isCallingFrom);
}else{
if(Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Instance_URL__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Instance_URL__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Auth_Token__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_id_username__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_id_username__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isUpdateable() ){
apiSettingList[0].TelosTouchSF__Approval__c = false; 
apiSettingList[0].TelosTouchSF__Instance_URL__c = ''; 
apiSettingList[0].Auth_Token__c = ''; 
apiSettingList[0].Client_id_username__c = ''; 
apiSettingList[0].Client_secret_password__c = ''; 
if(Schema.sObjectType.TelosTouch_API_Settings__c.isCreateable() && Schema.sObjectType.TelosTouch_API_Settings__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.isUpdateable()){
upsert apiSettingList[0]; 
}
}
return null; 
}
} catch (Exception ex) {
System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
}
return null;
}
public static userCredentialsWrapper thirdPartySignIn(List<TelosTouch_API_Settings__c> apiSettingList, String isCallingFrom) {
try {
userCredentialsWrapper getActiveUserWrapper= new userCredentialsWrapper();
String methodType = 'GET';
String endPointURL = apiSettingList[0].TelosTouchSF__Instance_URL__c.trim() + '/crm-v2/api/v1/App/user';
Map<String, String> headersMap = new Map<String, String>();
headersMap.put('instance-name', +apiSettingList[0].TelosTouchSF__Instance_URL__c.trim());
String username = apiSettingList[0].Client_id_username__c.trim();
String password = apiSettingList[0].Client_secret_password__c.trim();
Blob headerValue = Blob.valueOf(username + ':' + password);
String authorizationHeader = EncodingUtil.base64Encode(headerValue);
headersMap.put('espo-Authorization', authorizationHeader);
headersMap.put('Authorization','Basic ' +authorizationHeader);
headersMap.put('Content-Type', 'application/json');
String getResponse = getResponse(methodType, endPointURL, headersMap, null);
TelosTouch_API_Settings__c updateSettings = TelosTouch_API_Settings__c.getOrgDefaults();
if (getResponse != null ) {
TelosTouchWrapperUtils.userSignInWrapper thirdPartySignInWrapper = generateSessionIdWrapper(getResponse);
if (thirdPartySignInWrapper.user.token != null && thirdPartySignInWrapper.user.isAdmin == true && thirdPartySignInWrapper.user.isActive == true) {
Blob blobValue = Blob.valueOf(username + ':' + thirdPartySignInWrapper.user.token);
String authToken = EncodingUtil.base64Encode(blobValue);
apiSettingList[0].Auth_Token__c = authorizationHeader;
apiSettingList[0].TelosTouchSF__Approval__c = true;
if(updateSettings.Id != null){
apiSettingList[0].Id = updateSettings.Id;    
}
String UserId = UserInfo.getUserId();
String ProfileId = UserInfo.getProfileId();
string cstmLabel = System.Label.TelosTouchSF.ShowTTConfigPage;
string cstmLabel1 = System.Label.TelosTouchSF.ShowTTConfigPageFrench;
user user = new user();
TTUserWrapper  ttuserObj = new TTUserWrapper();
if(isCallingFrom != 'DoinitFromSetup'){
if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
Schema.sObjectType.User.fields.Id.isAccessible() &&
Schema.sObjectType.User.fields.ProfileId.isAccessible() &&
Schema.sObjectType.User.fields.firstName.isAccessible() &&
Schema.sObjectType.User.fields.lastName.isAccessible() &&
Schema.sObjectType.User.fields.Email.isAccessible() &&
Schema.sObjectType.User.fields.TT_UserId__c.isAccessible() &&
Schema.sObjectType.User.fields.IsActive.isAccessible() &&
Schema.sObjectType.User.fields.phone.isAccessible() &&
Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() &&
Schema.sObjectType.User.fields.Auth_Token__c.isAccessible()){
user = [SELECT Id, userName, ProfileId, firstName,phone, lastName, Email,TT_UserId__c, TT_UserName__c, IsActive,Auth_Token__c FROM User 
WHERE IsActive = true AND UserPermissionsMarketingUser = true AND Profile.UserLicense.Name = 'Salesforce' AND 
Id=:UserId AND profileId =:[SELECT id FROM Profile WHERE (Name = 'System Administrator' OR Name =: cstmLabel) OR (Name = 'Administrateur système' OR Name =: cstmLabel1) ] LIMIT 1];
}

if(user != null && (user.TT_UserId__c == null )){
String endpoint = apiSettingList[0].TelosTouchSF__Instance_URL__c.trim()+'/crm-v2/api/v1/User?where[0][type]=equals&where[0][attribute]=emailAddress&where[0][value]='+user.Email;
String getResponseBody = getResponse('GET', endpoint, headersMap, null);
Map<String, Object> getResponseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponseBody);
if(Integer.valueOf(getResponseMap.get('total')) > 0){
List<Object> listResponse = (List<Object>)JSON.deserializeUntyped(JSON.serialize(getResponseMap.get('list')));
Map<String, Object> responseMap1 = new Map<String, Object>();
if(listResponse != null && listResponse.size() > 0){
responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(listResponse[0]));
}
if(Schema.sObjectType.User.fields.TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserId__c.isUpdateable() &&
Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserName__c.isUpdateable() &&
Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isUpdateable() && String.valueOf(responseMap1.get('title')) != 'Client'){
user.TT_UserId__c = String.valueOf(responseMap1.get('id'));
user.TT_UserName__c = String.valueOf(responseMap1.get('userName'));
ttuserObj = getTokenForEachUser(String.valueOf(responseMap1.get('id')),apiSettingList[0].TelosTouchSF__Instance_URL__c.trim(), authorizationHeader);
user.Auth_Token__c =   ttuserObj.TTToken;
}
}else{
String  body = '{"firstName": "'+user.firstName+'","lastName": "'+user.lastName+'","emailAddress": "'+user.Email+'","phoneNumber": "'+user.Phone+'","title": "Advisor","otherId": "'+user.Id+'","isActive": "'+user.IsActive+'", "userName": "'+user.userName+'","rolesIds":["58b7218cca6d3c8a3"],"rolesNames":{"58b7218cca6d3c8a3":"advisor"} }';
System.debug('Request Sent');
String responseBody = getResponse('POST', apiSettingList[0].TelosTouchSF__Instance_URL__c.trim()+'/crm-v2/api/v1/User', headersMap, body);
if(responseBody != null){
Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
if(String.valueof(responseMap2.get('type')) == 'error' && String.valueof(responseMap2.get('message')).contains('username already exists')){

UserTriggerHandler.createLogRecord('failed',String.valueof(responseMap2.get('message')), 1) ; 
return null;
}else if(String.valueof(responseMap2.get('type')) != 'error'){
if(Schema.sObjectType.User.fields.TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserId__c.isUpdateable() &&
Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isUpdateable() &&
Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserName__c.isUpdateable()){
user.TT_UserId__c = String.valueof(responseMap2.get('id'));
user.TT_UserName__c = String.valueof(responseMap2.get('userName'));
ttuserObj =  getTokenForEachUser(String.valueof(responseMap2.get('id')), apiSettingList[0].TelosTouchSF__Instance_URL__c.trim(), authorizationHeader);
user.Auth_Token__c =   ttuserObj.TTToken;
}
}
}else{
getActiveUserWrapper.errorMessage = 'This user is not validate with TT.'; 
return null;
}
}
if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isUpdateable()){
update user;
}
}
}
if(Schema.sObjectType.TelosTouch_API_Settings__c.isCreateable() && Schema.sObjectType.TelosTouch_API_Settings__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.isUpdateable()){
upsert apiSettingList[0]; 
}
}else {
getActiveUserWrapper.errorMessage = 'Not Admin'; 
if(updateSettings.Id != null){
apiSettingList[0].Id = updateSettings.Id;    
}
if(Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isUpdateable()) {
apiSettingList[0].TelosTouchSF__Approval__c = false;  
}
if(Schema.sObjectType.TelosTouch_API_Settings__c.isCreateable() && Schema.sObjectType.TelosTouch_API_Settings__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.isUpdateable()){
upsert apiSettingList[0]; 
}
getActiveUserWrapper.settingApi = apiSettingList[0]; 
return getActiveUserWrapper;
}
if(isCallingFrom == 'From Setup'){
getActiveUserWrapper = getUserList();
}
getActiveUserWrapper.settingApi = apiSettingList[0]; 
return getActiveUserWrapper;
} else{
if(updateSettings.Id != null){
apiSettingList[0].Id = updateSettings.Id;    
}
if(Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Instance_URL__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.TelosTouchSF__Instance_URL__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Auth_Token__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_id_username__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_id_username__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isUpdateable() &&
Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.fields.Client_secret_password__c.isUpdateable() ){
apiSettingList[0].TelosTouchSF__Approval__c = false; 
apiSettingList[0].TelosTouchSF__Instance_URL__c = ''; 
apiSettingList[0].Auth_Token__c = ''; 
apiSettingList[0].Client_id_username__c = ''; 
apiSettingList[0].Client_secret_password__c = ''; 
if(Schema.sObjectType.TelosTouch_API_Settings__c.isCreateable() && Schema.sObjectType.TelosTouch_API_Settings__c.isAccessible() && Schema.sObjectType.TelosTouch_API_Settings__c.isUpdateable()){
upsert apiSettingList[0]; 
}
}
return null;
}
} catch (Exception ex) {
System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
}
return null;
}*/
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param apiSetting ....
* @param isCallingFrom ....
* @return userCredentialsWrapper OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static userCredentialsWrapper getAdminAccessToken(String apiSetting, String isCallingFrom){
        //System.debug(apiSetting);
        List<AdminCredentialsWrapper> apiSettingList = (List<AdminCredentialsWrapper>)JSON.deserialize(apiSetting, List<AdminCredentialsWrapper>.class);
        //System.debug(apiSettingList);
        AdminCredentialsWrapper adminCredentials = new AdminCredentialsWrapper();
        if((isCallingFrom != null && isCallingFrom == 'From Setup') && (apiSettingList != null)){
            String[] StringList = apiSettingList[0].Instance_URL.split('//');
            String[] StringList1 = StringList[1].split('\\.');
            String[] StringList2 = apiSettingList[0].Authentication_URL.split('//');
            String[] StringList3 = StringList2[1].split('\\.');
            if(apiSettingList[0].Instance_URL.trim() != null && StringList1[0] != null){
                String instance_Name = TelosTouchSF.CreateRemoteSiteSetting.getremoteSiteSetting(apiSettingList[0].Instance_URL, StringList1[0]);
                String authentication_Name = TelosTouchSF.CreateRemoteSiteSetting.getremoteSiteSetting(apiSettingList[0].Authentication_URL, StringList3[0]);
                if(instance_Name != 'Already Exists!'){
                    TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1(apiSettingList[0].Instance_URL,instance_Name);
                }
                if(authentication_Name != 'Already Exists!'){
                    TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1(apiSettingList[0].Authentication_URL,authentication_Name);
                }
            }
            String instanceUrl = apiSettingList[0].Instance_URL.trim();
            String scope = 'offline_access';
            String body = 'scope='+EncodingUtil.urlEncode(scope,'UTF-8')
                +'&client_id='+EncodingUtil.urlEncode(apiSettingList[0].Client_ID,'UTF-8')
                +'&client_secret='+EncodingUtil.urlEncode(apiSettingList[0].Client_Secret,'UTF-8')
                +'&grant_type=client_credentials';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiSettingList[0].Authentication_URL+'/auth/realms/'+StringList1[0]+'/protocol/openid-connect/token');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(body);
            HttpResponse response = http.send(request);
	        String respMessage = 'Response Status Code: '+response.getstatusCode()+'| Response Body: '+response.getBody();	
            TelosTouchUtility.generateLog(respMessage, 'TelosTouchUtility', 'getAdminAccessToken', null);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                //System.debug('responseMap:: '+responseMap.get('access_token'));
                if(responseMap.containsKey('access_token') && responseMap.get('access_token')!=null){
                    adminCredentials.Client_ID = apiSettingList[0].Client_ID;
                    adminCredentials.Client_Secret = apiSettingList[0].Client_Secret;
                    adminCredentials.Access_Token = String.valueOf(responseMap.get('access_token'));
                    adminCredentials.Registration_Successful = false;
                    adminCredentials.Instance_URL = instanceUrl;
                    adminCredentials.Refresh_Token = String.valueOf(responseMap.get('refresh_token'));
                    adminCredentials.Authentication_URL = apiSettingList[0].Authentication_URL;
                    adminCredentials.RefreshTokenLastUsedDate = System.now();
                    adminCredentials.Access_Token_Expiration_Time = String.valueOf(responseMap.get('expires_in'));
                    return getUserAccessToken(adminCredentials, isCallingFrom);
                }else{
                    return null;
                }
            }
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return AdminCredentialsWrapper OpenAtAndCompletedWrapperObj ....
*/
    public static AdminCredentialsWrapper refreshAdminAccessToken(){
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = getCustomMetadata();
        TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = getAuthenticationCustomMetadata();
        Integer noOfDays = 0, expirationDays = 0;
        if(adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c != null){
            noOfDays = adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c.date().daysBetween( Date.today() );
        }
        if(adminCredentials.TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c != null){
            expirationDays = Integer.valueOf(adminCredentials.TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c) - 1;
        }
        //System.debug('noOfDays>'+noOfDays);
        String[] StringList = adminCredentials.TelosTouchSF__Instance_URL__c.split('//');
        String[] StringList1 = StringList[1].split('\\.');
        String scope = 'profile';
        String body = 'scope='+EncodingUtil.urlEncode(scope,'UTF-8')
            +'&client_id='+EncodingUtil.urlEncode(authenticationCredential.TelosTouchSF__Client_ID__c.trim(),'UTF-8')
            +'&client_secret='+EncodingUtil.urlEncode(authenticationCredential.TelosTouchSF__Client_Secret__c.trim(),'UTF-8')
            +'&refresh_token='+EncodingUtil.urlEncode(authenticationCredential.TelosTouchSF__Refresh_Token__c.trim(),'UTF-8')
            +'&grant_type=refresh_token';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(adminCredentials.TelosTouchSF__Authentication_URL__c+'/auth/realms/'+StringList1[0]+'/protocol/openid-connect/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        HttpResponse response = http.send(request);
        //System.debug('response Body:: '+response.getBody());
	    String respMessage = 'Response Status Code: '+response.getstatusCode()+'| Response Body: '+response.getBody();	
        TelosTouchUtility.generateLog(respMessage, 'TelosTouchUtility', 'refreshAdminAccessToken', null);
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            //System.debug('responseMap:: ' + responseMap.get('access_token'));
            authenticationCredential.TelosTouchSF__Access_Token__c = String.valueOf(responseMap.get('access_token'));
            if(noOfDays >= expirationDays) {
                authenticationCredential.TelosTouchSF__Refresh_Token__c = String.valueOf(responseMap.get('refresh_token'));
            }
            adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c = System.now();
            return new AdminCredentialsWrapper(adminCredentials, authenticationCredential);
        }else{
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param adminCredentials ....
*/
    public static void updateCustomMetadata(AdminCredentialsWrapper adminCredentials){
        //System.debug('adminCredentials>>'+adminCredentials.);
        Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
        cMetadata.fullName = 'TelosTouchSF__TT_Admin_Credentials.TelosTouchSF__AdminDetails';
        cMetadata.label = 'AdminDetails';
        
        Metadata.CustomMetadata authMetadata = new Metadata.CustomMetadata();
        authMetadata.fullName = 'TelosTouchSF__TT_Authentication_Credential__mdt.TelosTouchSF__AdminDetails';
        authMetadata.label = 'AdminDetails';
        
        Metadata.CustomMetadataValue clientIdValue = new Metadata.CustomMetadataValue();
        clientIdValue.Field = 'TelosTouchSF__Client_ID__c';
        clientIdValue.Value = adminCredentials.Client_ID;
        authMetadata.values.add(clientIdValue);
        
        Metadata.CustomMetadataValue clientSecretValue = new Metadata.CustomMetadataValue();
        clientSecretValue.Field = 'TelosTouchSF__Client_Secret__c';
        clientSecretValue.Value = adminCredentials.Client_Secret;
        authMetadata.values.add(clientSecretValue);
        
        Metadata.CustomMetadataValue accessTokenValue = new Metadata.CustomMetadataValue();
        accessTokenValue.Field = 'TelosTouchSF__Access_Token__c';
        accessTokenValue.Value = adminCredentials.Access_Token;
        authMetadata.values.add(accessTokenValue);
        
        Metadata.CustomMetadataValue instanceUrlValue = new Metadata.CustomMetadataValue();
        instanceUrlValue.Field = 'TelosTouchSF__Instance_URL__c';
        instanceUrlValue.Value = adminCredentials.Instance_URL;
        cMetadata.values.add(instanceUrlValue);
        
        Metadata.CustomMetadataValue RefreshTokenValue = new Metadata.CustomMetadataValue();
        RefreshTokenValue.Field = 'TelosTouchSF__Refresh_Token__c';
        RefreshTokenValue.Value = adminCredentials.Refresh_Token;
        authMetadata.values.add(RefreshTokenValue);
        
        Metadata.CustomMetadataValue ApprovalValue = new Metadata.CustomMetadataValue();
        ApprovalValue.Field = 'TelosTouchSF__Approval__c';
        ApprovalValue.Value = adminCredentials.Approval;
        cMetadata.values.add(ApprovalValue);
        
        Metadata.CustomMetadataValue ForSecondTimeBatchValue = new Metadata.CustomMetadataValue();
        ForSecondTimeBatchValue.Field = 'TelosTouchSF__ForSecondTimeBatch__c';
        ForSecondTimeBatchValue.Value = adminCredentials.ForSecondTimeBatch;
        cMetadata.values.add(ForSecondTimeBatchValue);
        
        Metadata.CustomMetadataValue BatchRunsForSFToTTOnTimeBasisValue = new Metadata.CustomMetadataValue();
        BatchRunsForSFToTTOnTimeBasisValue.Field = 'TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c';
        BatchRunsForSFToTTOnTimeBasisValue.Value = adminCredentials.BatchRunsForSFToTTOnTimeBasis;
        cMetadata.values.add(BatchRunsForSFToTTOnTimeBasisValue);
        
        Metadata.CustomMetadataValue Authentication_URLValue = new Metadata.CustomMetadataValue();
        Authentication_URLValue.Field = 'TelosTouchSF__Authentication_URL__c';
        Authentication_URLValue.Value = adminCredentials.Authentication_URL;
        cMetadata.values.add(Authentication_URLValue);
        
        Metadata.CustomMetadataValue AdminRefreshTokenLastUsedDate = new Metadata.CustomMetadataValue();
        AdminRefreshTokenLastUsedDate.Field = 'TelosTouchSF__Refresh_Token_Last_Used_Date__c';
        AdminRefreshTokenLastUsedDate.Value = adminCredentials.RefreshTokenLastUsedDate;
        cMetadata.values.add(AdminRefreshTokenLastUsedDate);
        
        Metadata.CustomMetadataValue AdminTokenExpirationTimeValue = new Metadata.CustomMetadataValue();
        AdminTokenExpirationTimeValue.Field = 'TelosTouchSF__Access_Token_Expiration_Time__c';
        AdminTokenExpirationTimeValue.Value = adminCredentials.Access_Token_Expiration_Time;
        cMetadata.values.add(AdminTokenExpirationTimeValue);
        
        Metadata.CustomMetadataValue Use_CreatedByIdValue = new Metadata.CustomMetadataValue();
        Use_CreatedByIdValue.Field = 'TelosTouchSF__Use_CreatedById__c';
        Use_CreatedByIdValue.Value = adminCredentials.Use_CreatedById;
        cMetadata.values.add(Use_CreatedByIdValue);
        
        Metadata.CustomMetadataValue Registration_Request_ExpiryValue = new Metadata.CustomMetadataValue();
        Registration_Request_ExpiryValue.Field = 'TelosTouchSF__Registration_Request_Expiry__c';
        Registration_Request_ExpiryValue.Value = adminCredentials.Registration_Request_Expiry;
        cMetadata.values.add(Registration_Request_ExpiryValue);
        
        Metadata.CustomMetadataValue Registration_SuccessfulValue = new Metadata.CustomMetadataValue();
        Registration_SuccessfulValue.Field = 'TelosTouchSF__Registration_Successful__c';
        Registration_SuccessfulValue.Value = adminCredentials.Registration_Successful;
        cMetadata.values.add(Registration_SuccessfulValue);
        
        Metadata.CustomMetadataValue Registration_DateTimeValue = new Metadata.CustomMetadataValue();
        Registration_DateTimeValue.Field = 'TelosTouchSF__Registration_DateTime__c';
        Registration_DateTimeValue.Value = adminCredentials.Registration_DateTime;
        cMetadata.values.add(Registration_DateTimeValue);
        
        Metadata.CustomMetadataValue Team_NameValue = new Metadata.CustomMetadataValue();
        Team_NameValue.Field = 'TelosTouchSF__Team_Name__c';
        Team_NameValue.Value = adminCredentials.Team_Name;
        cMetadata.values.add(Team_NameValue);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(cMetadata);
        mdContainer.addMetadata(authMetadata);
        TelosTouchUtility callback = new TelosTouchUtility();
        if(!Test.isRunningTest()){
            Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param adminCredentials ....
* @param isCallingFrom ....
* @return userCredentialsWrapper OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static userCredentialsWrapper getUserAccessToken(AdminCredentialsWrapper adminCredentials, String isCallingFrom){
        try {
            System.debug('adminCredentials.Team_Name:: '+adminCredentials.Team_Name);
            String ttTeamName = String.isNotEmpty(adminCredentials.Team_Name) ? adminCredentials.Team_Name : adminCredentials.Client_ID;
            System.debug('ttTeamName:: '+ttTeamName);
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            userCredentialsWrapper getActiveUserWrapper= new userCredentialsWrapper();
            Boolean userUpdateFlag = false;
            if (adminCredentials.Access_Token != null) {
                adminCredentials.Approval = true;
                String UserId = UserInfo.getUserId();
                string cstmLabel = System.Label.TelosTouchSF.ShowTTConfigPage;
                string cstmLabel1 = System.Label.TelosTouchSF.ShowTTConfigPageFrench;
                user user = new user();
                TTUserWrapper  ttuserObj = new TTUserWrapper();
                if(isCallingFrom != 'DoinitFromSetup'){
                    if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
                       Schema.sObjectType.User.fields.Id.isAccessible() &&
                       Schema.sObjectType.User.fields.ProfileId.isAccessible() &&
                       Schema.sObjectType.User.fields.firstName.isAccessible() &&
                       Schema.sObjectType.User.fields.lastName.isAccessible() &&
                       Schema.sObjectType.User.fields.Email.isAccessible() &&
                       Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() &&
                       Schema.sObjectType.User.fields.IsActive.isAccessible() &&
                       Schema.sObjectType.User.fields.phone.isAccessible() &&
                       Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&
                       Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible()){
                           user = [SELECT Id, userName, ProfileId, Profile.Name, firstName,phone, lastName, Email,TelosTouchSF__TT_UserId__c, TelosTouchSF__TT_UserName__c, IsActive,TelosTouchSF__Auth_Token__c FROM User
                                   WHERE IsActive = true AND UserPermissionsMarketingUser = true AND Profile.UserLicense.Name = 'Salesforce' AND
                                   Id=:UserId AND profileId =:[SELECT id FROM Profile WHERE (Name = 'System Administrator' OR Name =: cstmLabel) OR (Name = 'Administrateur système' OR Name =: cstmLabel1) ] WITH SECURITY_ENFORCED LIMIT 1];
                       }
                    if(user != null && (user.TelosTouchSF__TT_UserId__c == null )){
                        String teamId='';
                        Map<String, String> headersMap = new Map<String, String>();
                        headersMap.put('Accept', 'application/json');
                        headersMap.put('Content-Type', 'application/json');
                        headersMap.put('Authorization', 'Bearer '+adminCredentials.Access_Token);
                        Map<String, String> teamsResponseBody = TelosTouchSF.TelosTouchUtility.getResponse('GET', adminCredentials.Instance_URL+'/api/v1/teams?search='+ttTeamName, headersMap, null);
                        if(teamsResponseBody.get('status_code') == '401'){
                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                        }
                        List<Object> teamsResponseList = (List<Object>) JSON.deserializeUntyped(teamsResponseBody.get('body'));
                        Map<String, String> teamNameVsTeamIdMap = new Map<String, String>();
                        for(Object teamsResponseObj : teamsResponseList){
                            Map<String, Object> teamResponseMap = (Map<String, Object>)teamsResponseObj;
                            if(teamResponseMap.containsKey('name') && teamResponseMap.containsKey('id') && teamResponseMap != null){
                                teamNameVsTeamIdMap.put(String.valueOf(teamResponseMap.get('name')), String.valueOf(teamResponseMap.get('id')));
                            }
                        }
                        System.debug('teamNameVsTeamIdMap:: '+JSON.serialize(teamNameVsTeamIdMap));
                        if(teamNameVsTeamIdMap.containsKey(ttTeamName)){
                            teamId = teamNameVsTeamIdMap.get(ttTeamName);
                        }else{
                            Map<String, String> teamIdResponse = TelosTouchUtility.getResponse('POST', adminCredentials.Instance_URL+'/api/v1/teams', headersMap, '{"name":"'+ttTeamName+'"}');
	                        String respMessage = 'Response Status Code: '+teamIdResponse.get('status_code')+'| Response Body: '+teamIdResponse.get('body');	
                            TelosTouchUtility.generateLog(respMessage, 'TelosTouchUtility', 'getUserAccessToken', null);
                            teamId = teamIdResponse.get('body');
                        }
                        String endpoint = adminCredentials.Instance_URL.trim()+'/api/v1/users?search='+user.Email;
                        Map<String, String> getResponseBody = getResponse('GET', endpoint, headersMap, null);
                        //System.debug('getResponseBody:: '+getResponseBody);
                        if(getResponseBody.get('status_code') == '401'){
                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                        }else if(getResponseBody.get('status_code') == '500'){
                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error','Erreur de serveur interne',1));
                        }
                        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(getResponseBody.get('body'));
                        Map<String, Object> getResponseMap = new Map<String, Object>();
                        if(!responseList.isEmpty()){
                            getResponseMap = (Map<String, Object>)responseList[0];
                        }
                        //System.debug('getResponseMap:: '+getResponseMap);
                        if(!getResponseMap.keySet().isEmpty()){
                            //System.debug('If');
                            Map<String, String> getCurrentTeamBody = TelosTouchUtility.getResponse('GET', adminCredentials.Instance_URL+'/api/v1/users/'+String.valueOf(getResponseMap.get('id'))+'/teams', headersMap, null);
                            if(getCurrentTeamBody.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }
                            List<Object> getCurrentTeamList = (List<Object>) JSON.deserializeUntyped(getCurrentTeamBody.get('body'));
                            Map<String, Object> getCurrentTeamMap = (Map<String, Object>)getCurrentTeamList[0];
                            String currentTeamName = String.valueOf(getCurrentTeamMap.get('path')).split('/')[1].trim();
                            //System.debug('current Team Name:: '+currentTeamName);
                            //System.debug('current Profile Name:: '+user.Profile.Name);
                            if(ttTeamName != currentTeamName){
                                Map<String,String> teamChangeReponseBody = TelosTouchSF.TelosTouchUtility.getResponse('PUT', adminCredentials.Instance_URL+'/api/v1/users/'+String.valueOf(getResponseMap.get('id'))+'/teams/'+teamId, headersMap, null);
                                if(teamChangeReponseBody.get('status_code') == '401'){
                                    logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                                }
                                Map<String, Object> teamChangeResponseMap = (Map<String, Object>) JSON.deserializeUntyped(teamChangeReponseBody.get('body')!=null ? teamChangeReponseBody.get('body') : '{}');
                                if(teamChangeResponseMap.containsKey('id')){
                                    userUpdateFlag = true;
                                    //System.debug('Team Updated');
                                }
                            }else if(ttTeamName == currentTeamName){
                                userUpdateFlag = true;
                                //System.debug('Team Not Updated');
                            }
                            if(userUpdateFlag){
                                if (Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable()) {
                                        user.TelosTouchSF__TT_UserId__c = String.valueOf(getResponseMap.get('id'));
                                        user.TelosTouchSF__TT_UserName__c = String.valueOf(getResponseMap.get('username'));
                                        ttuserObj = getTokenForEachUser(String.valueOf(getResponseMap.get('username')),adminCredentials);
                                        user.TelosTouchSF__Auth_Token__c = ttuserObj.TTToken;
                                    }
                            }
                        }else{
                            //System.debug('Else');
                            //String  body = '{"firstName": "'+user.firstName+'","lastName": "'+user.lastName+'","emailAddress": "'+user.Email+'","phoneNumber": "'+user.Phone+'","title": "Advisor","otherId": "'+user.Id+'","isActive": "'+user.IsActive+'", "userName": "'+user.userName+'","rolesIds":["58b7218cca6d3c8a3"],"rolesNames":{"58b7218cca6d3c8a3":"advisor"} }';
                            String body = '{"firstName": "'+user.firstName
                                +'","lastName": "'+user.lastName
                                +'","username": "'+user.Username
                                +'","phone": "'+user.Phone
                                +'","email": "'+user.Email
                                +'","role":"professional","team":"'+teamId+'","otherId":"'
                                +user.Id+'"}';
                            //System.debug('Request Sent');
                            Map<String, String> responseBody = getResponse('POST', adminCredentials.Instance_url.trim()+'/api/v1/users', headersMap, body);
                            if(responseBody.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }
                            if(responseBody.get('body') != null){
                                Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
                                //System.debug('responseMap2:: '+responseMap2);
                                if(responseMap2.containsKey('emailExists') && Boolean.valueOf(responseMap2.get('emailExists'))){
                                    TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.TelosTouchSF.Failed_Text,'Email Already Exists: '+user.Email,'Courriel existe déjà: '+user.Email, 1) ;
                                    return null;
                                }else if(responseMap2.containsKey('usernameExists') && Boolean.valueOf(responseMap2.get('usernameExists'))){
                                    TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.TelosTouchSF.Failed_Text,'Username Already Exists:' +' '+user.Username,'Code d\'utilisateur existe déjà:' +' '+user.Username, 1) ;
                                    return null;
                                }else if(responseMap2.containsKey('problems')){
                                    TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.TelosTouchSF.Failed_Text,String.valueOf(responseMap2.get('message')),String.valueOf(responseMap2.get('message')), 1) ;
                                    return null;
                                }else if(responseMap2.containsKey('id')){
                                    if(Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() &&
                                       Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable() &&
                                       Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable()){
                                           user.TelosTouchSF__TT_UserId__c = String.valueof(responseMap2.get('id'));
                                           user.TelosTouchSF__TT_UserName__c = String.valueof(responseMap2.get('username'));
                                           //System.debug('Username:: '+String.valueOf(responseMap2.get('username')));
                                           ttuserObj = getTokenForEachUser(String.valueOf(responseMap2.get('username')), adminCredentials);
                                           user.TelosTouchSF__Auth_Token__c =   ttuserObj.TTToken;
                                       }
                                }
                            }else{
                                getActiveUserWrapper.errorMessage = 'This user is not validate with TT.';
                                return null;
                            }
                        }
                        if(user.TelosTouchSF__TT_UserId__c != null && user.TelosTouchSF__TT_UserName__c != null && user.TelosTouchSF__Auth_Token__c != null
                           && [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'TelosTouch_Custom_Permission' AND AssigneeId =: UserInfo.getUserId()] == 0){
                               PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TelosTouch_Custom_Permission'];
                               if(ps != null && ps.Id != null){
                                   insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
                               }
                           }
                        if(Schema.sObjectType.User.isUpdateable() && Schema.sObjectType.User.isCreateable() && User.getSObjectType().getDescribe().isAccessible() && User.getSObjectType().getDescribe().isUpdateable()){
                            update user;
                        }
                        if(!logList.isEmpty() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                            insert logList;
                        }
                    }
                }
            }else {
                getActiveUserWrapper.errorMessage = 'Not Admin';
                adminCredentials.Approval = false;
                updateCustomMetadata(adminCredentials);
                getActiveUserWrapper.adminCredentials = adminCredentials;
                return getActiveUserWrapper;
            }
            if(isCallingFrom == 'From Setup'){
                getActiveUserWrapper = getUserList();
            }
            updateCustomMetadata(adminCredentials);
            getActiveUserWrapper.adminCredentials = adminCredentials;
            return getActiveUserWrapper;
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the user auth token.
* @param sfUserList stores the list of salesforce User List.
* @param listofUserId stores the list of user id.
* @return String OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static String sendSFUserToTT(List<User> sfUserList, List<Id> listofUserId) {
        try{
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<TelosTouchSF__TelosTouch_User_Role__c> customSettingList = new List<TelosTouchSF__TelosTouch_User_Role__c>();
            if( Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.isQueryable() &&
               Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RoleId__c.isAccessible() &&
               Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RolesName__c.isAccessible()){
                   customSettingList = [SELECT TelosTouchSF__RoleId__c, TelosTouchSF__RolesName__c FROM TelosTouchSF__TelosTouch_User_Role__c WHERE TelosTouchSF__RoleId__c != null AND TelosTouchSF__RolesName__c != null LIMIT 1];
                   if(customSettingList.size() == 0 ){
                       TelosTouchSF__TelosTouch_User_Role__c customObjRecord = new TelosTouchSF__TelosTouch_User_Role__c();
                       if(Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.SetupOwnerId.isAccessible()
                          && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.SetupOwnerId.isUpdateable()
                          && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.SetupOwnerId.isCreateable()){
                              customObjRecord.SetupOwnerId = UserInfo.getProfileId();
                          }
                       if(Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RoleId__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RoleId__c.isCreateable()
                          && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RoleId__c.isUpdateable()){
                              customObjRecord.TelosTouchSF__RoleId__c = '58b7218cca6d3c8a3';
                          }
                       if(Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RolesName__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RolesName__c.isCreateable()
                          && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.fields.TelosTouchSF__RolesName__c.isUpdateable()){
                              customObjRecord.TelosTouchSF__RolesName__c = 'Advisor';
                          }
                       if(Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.isCreateable()
                          &&  Schema.sObjectType.TelosTouchSF__TelosTouch_User_Role__c.isUpdateable()){
                              customSettingList.add(customObjRecord);
                              upsert customSettingList;
                          }
                   }
               }
            
            if(sfUserList != null && sfUserList.size() >0){
                if(Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.PermissionSetAssignment.isQueryable() &&
                   Schema.sObjectType.PermissionSetAssignment.fields.Id.isAccessible() &&
                   Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() &&
                   Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible()){
                       permissionSetList = [SELECT Id, PermissionSetId,AssigneeId
                                            FROM PermissionSetAssignment
                                            WHERE (PermissionSet.Name = 'TelosTouch_Custom_Permission' OR  PermissionSet.Name = 'TTPSetForInsightObjMDRelations')
                                            AND AssigneeId IN: listofUserId LIMIT 2];
                       Map<Id,PermissionSetAssignment> userIdVsPermSetAssignObjMap = new Map<Id,PermissionSetAssignment>();
                       if(permissionSetList.size()> 0 && permissionSetList.size() == 1){
                           for(PermissionSetAssignment psaObj : permissionSetList){
                               userIdVsPermSetAssignObjMap.put(psaObj.AssigneeId,psaObj);
                           }
                       }
                       if(sfUserList.size()>0){
                           Database.executeBatch(new TelosTouchSF.SendSFUserBatch(sfUserList,userIdVsPermSetAssignObjMap), 20);
                       }
                   }
                return 'success' +'+'+sfUserList.size();
            }else{
                return null;
            }
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    /*public static TTUserWrapper getTokenForEachUser(String TTuserId, String instanceName, String authToken) {
try{
TTUserWrapper  ttuserObj = new TTUserWrapper();
String methodType = 'GET',endPointURL;
Map<String, String> headersMap = new Map<String, String>();
if(String.isNotBlank(authToken) && String.isNotBlank(instanceName) ){
endPointURL = instanceName+'/crm-v2/api/v1/App/user';
headersMap.put('instance-name', +instanceName);
headersMap.put('Authorization','Basic ' +authToken);
headersMap.put('espo-Authorization', authToken);
if(TTuserId != null){
headersMap.put('espoid', TTuserId);
}
}
headersMap.put('Content-Type', 'application/json');
String getResponse = getResponse(methodType, endPointURL, headersMap, null);
if(getResponse!= null){
Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(getResponse);
if(String.valueof(responseMap.get('token')) != null){
ttuserObj.TTToken = String.valueof(responseMap.get('token'));
}
Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('user')));
if(String.valueof(responseMap2.get('userName')) != null){
ttuserObj.TTUserName = String.valueof(responseMap2.get('userName'));
}
return ttuserObj;
}
}catch (Exception ex) {
System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
}
return null;
}*/
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param TTusername ....
* @param adminCredentials ....
* @return TTUserWrapper OpenAtAndCompletedWrapperObj ....
*/
    public static TTUserWrapper getTokenForEachUser(String TTusername, AdminCredentialsWrapper adminCredentials) {
        try{
            //System.debug('TTusername:: '+TTusername);
            String[] StringList = adminCredentials.Instance_URL.split('//');
            String[] StringList1 = StringList[1].split('\\.');
            String body;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            TTUserWrapper  ttuserObj = new TTUserWrapper();
            if(String.isNotBlank(adminCredentials.Access_Token.trim()) && String.isNotBlank(adminCredentials.Authentication_URL) ){
                body = 'client_id='+EncodingUtil.urlEncode(adminCredentials.Client_ID.trim(),'UTF-8')
                    +'&client_secret='+EncodingUtil.urlEncode(adminCredentials.Client_Secret.trim(),'UTF-8')
                    +'&subject_token='+EncodingUtil.urlEncode(adminCredentials.Access_Token.trim(),'UTF-8')
                    +'&requested_subject='+EncodingUtil.urlEncode(TTusername.trim(),'UTF-8')
                    +'&requested_token_type=urn:ietf:params:oauth:token-type:access_token'
                    +'&grant_type=urn:ietf:params:oauth:grant-type:token-exchange';
                request.setEndpoint(adminCredentials.Authentication_URL+'/auth/realms/'+StringList1[0]+'/protocol/openid-connect/token');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setBody(body);
            }
            //System.debug('Request Body:: '+body);
            HttpResponse response = http.send(request);
            //System.debug('Response Body:: '+response.getBody());
	        String respMessage = 'Response Status Code: '+response.getstatusCode()+'| Response Body: '+response.getBody();	
            TelosTouchUtility.generateLog(respMessage, 'TelosTouchUtility', 'getTokenForEachUser', null);
            if(response.getBody() != null){
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                //System.debug('responseMap:: '+responseMap);
                if(String.valueof(responseMap.get('access_token')) != null){
                    ttuserObj.TTToken = String.valueof(responseMap.get('access_token'));
                }
                if(TTusername != null){
                    ttuserObj.TTUserName = TTusername;
                }
                return ttuserObj;
            }
        }catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the user list.
* @return userCredentialsWrapper OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static userCredentialsWrapper getUserList(){
        
        Set<Id> setProfileIds = new  Set<Id>();
        Set<String> setOfMoreThanOneEmail = new Set<String>();
        map<Id,String> mapIdVsName = new  map<Id,String>();
        List<userWrapper> userwp = new List<userWrapper>();
        List<User> userList = new List<User>();
        if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
           Schema.sObjectType.User.fields.Id.isAccessible() &&
           Schema.sObjectType.User.fields.ProfileId.isAccessible() &&
           Schema.sObjectType.User.fields.firstName.isAccessible() &&
           Schema.sObjectType.User.fields.lastName.isAccessible() &&
           Schema.sObjectType.User.fields.Email.isAccessible() &&
           Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() &&
           Schema.sObjectType.User.fields.IsActive.isAccessible() &&
           Schema.sObjectType.User.fields.phone.isAccessible()){
               userList = [SELECT Id, userName, ProfileId, firstName,phone, lastName, Email,TelosTouchSF__TT_UserId__c,IsActive FROM User WHERE IsActive = true AND UserPermissionsMarketingUser = true AND Profile.UserLicense.Name = 'Salesforce' AND TelosTouchSF__TT_UserId__c != '1' LIMIT 5000 ];
           }
        userCredentialsWrapper getActiveUserWrapper= new userCredentialsWrapper();
        for(User user: userList){
            setProfileIds.add(user.ProfileId);
        }
        List<Profile > profileList = new List<Profile >();
        if(Schema.SObjectType.Profile.isAccessible() && Schema.SObjectType.Profile.isQueryable() &&
           Schema.sObjectType.Profile.fields.Id.isAccessible() &&
           Schema.sObjectType.Profile.fields.Name.isAccessible()){
               profileList = [SELECT Id,Name FROM Profile WHERE Id IN:setProfileIds];
           }
        for(Profile profile: profileList){
            mapIdVsName.put(profile.Id, profile.Name);
        }
        for(User user: userList){
            if(mapIdVsName.containsKey(user.ProfileId) && (!setOfMoreThanOneEmail.contains(user.Email)) && user.TelosTouchSF__TT_UserId__c != null){
                userWrapper obj = new userWrapper();
                obj.userObject = user;
                obj.userProfile = mapIdVsName.get(user.ProfileId);
                obj.TTUser = System.Label.TelosTouchSF.Yes_Text;
                userwp.add(obj);
                setOfMoreThanOneEmail.add(user.Email);
            }
        }
        for(User user: userList){
            if(mapIdVsName.containsKey(user.ProfileId) && (!setOfMoreThanOneEmail.contains(user.Email)) && user.TelosTouchSF__TT_UserId__c == null){
                userWrapper obj = new userWrapper();
                obj.userObject = user;
                obj.userProfile = mapIdVsName.get(user.ProfileId);
                obj.TTUser = System.Label.TelosTouchSF.No_Text;
                userwp.add(obj);
                setOfMoreThanOneEmail.add(user.Email);
            }
        }
        getActiveUserWrapper.activeUserWrapper = userwp;
        if(getActiveUserWrapper != null){
            return getActiveUserWrapper;
        }else{
            return null;
        }
    }
    /**
* @author Charbel Dagher
* @date 19/07/2022
* @description This method calls the job to refresh the token
* @return response
*/
@AuraEnabled
public static string refreshTokenController(){
    try {
        system.debug('!!!entrer refreshTokenController');
        System.enqueueJob(new UpdateUserTokenQueueable());
        system.debug('!!!DONE');
        return 'success';
    }catch (Exception ex) {
        System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        return null;
    }

}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method schedules all the jobs.
* @return string OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static string scheduleAllJobsFromHere(){
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        try {
            List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
            if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() &&
               Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
               Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() ){
                   asyncApexJobList = [SELECT Id FROM AsyncApexJob WHERE Status = 'Completed' AND (ApexClass.Name ='BatchForBulkDataInsertOrUpdate'
                                                                                                   OR ApexClass.Name ='GetTaskFromTTQueueable'
                                                                                                   OR ApexClass.Name ='GetCampaignsFromTTQueueable')
                                       LIMIT 3];
               }
            if (asyncApexJobList.size() < 3) {
                //GetClientsFromTTQueueable getClientObj = new GetClientsFromTTQueueable();
                //System.enqueueJob(getClientObj);
                Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(null, null, null, 'Contact', null, null, null));
            }
            List<CronJobDetail> jobList = new List<CronJobDetail>();
            List<CronJobDetail> jobList3 = new List<CronJobDetail>();
            ///List<CronJobDetail> jobList4 = new List<CronJobDetail>();
            List<CronJobDetail> jobList5 = new List<CronJobDetail>();
            List<CronJobDetail> jobList6 = new List<CronJobDetail>();
            jobList = [SELECT Id FROM CronJobDetail Where Name LIKE 'Delete Log Records%' WITH SECURITY_ENFORCED];
            jobList3 = [SELECT Id FROM CronJobDetail Where Name LIKE 'Update User Token Job%' WITH SECURITY_ENFORCED];
            //jobList4 = [SELECT Id FROM CronJobDetail Where Name LIKE 'Get Delete Records From TT Job%'];
            jobList5 = [SELECT Id FROM CronJobDetail Where Name LIKE 'Get Clients From TT Job%' WITH SECURITY_ENFORCED];
            jobList6 = [SELECT Id FROM CronJobDetail Where Name LIKE 'Sync Feature Toggle Job%' WITH SECURITY_ENFORCED];
            if(jobList5.size() == 0){
                System.schedule('Get Clients From TT Job', '0 0 0/1 1/1 * ? *', new TelosTouchSF.GetClientsFromTTScheduler());
            }if(jobList3.size() == 0){
                if((Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600) > 0){
                    System.schedule('Update User Token Job 1', '0 0 0/'+String.valueOf(Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600)+' 1/1 * ? *', new TelosTouchSF.UpdateUserTokenScheduler());
                    System.schedule('Update User Token Job 2', '0 30 0/'+String.valueOf(Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600)+' 1/1 * ? *', new TelosTouchSF.UpdateUserTokenScheduler());
                }
                // System.schedule('Update User Token Job 2', '0 40 * * * ?', new UpdateUserTokenScheduler());
                // System.schedule('Update User Token Job 3', '0 0 * * * ?', new UpdateUserTokenScheduler());
            }if(jobList.size() == 0){
                System.schedule('Delete Log Records Job', '0 5 0 1/1 * ? *', new TelosTouchSF.Schedule_DeleteLogRecords());
            }
            if(jobList6.size() == 0){
                String chronJobId = '0 0 1 * * ? *';
                System.schedule('Sync Feature Toggle Job', chronJobId,  new TelosTouchSF.TT_ScheduleTelosTouchFeatureToggle());
                TelosTouchSF.TT_FeatureToggle inviteBatch= new TelosTouchSF.TT_FeatureToggle();
                Database.executeBatch(inviteBatch, 200);
            }
            /*if(jobList4.size() == 0){
System.schedule('Get Delete Records From TT Job', '0 0 0/1 1/1 * ? *', new GetDeleteRecordsFromTTScheduler());
}*/
            return 'success';
        }catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method aborts the scheduled jobs.
* @param apiSettingList stores the list of TT API settings.
*/
    @AuraEnabled
    public static void abortScheduleJob(List<TelosTouchSF__TelosTouch_API_Settings__c> apiSettingList){
        System.debug(LoggingLevel.DEBUG, 'Deprecated');
        /*List<CronTrigger> JOBIDLIST = new List<CronTrigger>();
if(Schema.sObjectType.CronTrigger.isAccessible() && Schema.sObjectType.CronTrigger.isQueryable() &&
Schema.sObjectType.CronTrigger.fields.id.isAccessible()){
JOBIDLIST = [SELECT id, CronJobDetail.Name FROM CronTrigger LIMIT 100];
}
for(CronTrigger job:JOBIDLIST )
{
if(job.CronJobDetail.Name.contains('User Conversation')){
System.abortJob(job.id);
}
if(job.CronJobDetail.Name.contains('Update User Token Job')){
System.abortJob(job.id);
}
if(job.CronJobDetail.Name.contains('Get Clients From TT Job')){
System.abortJob(job.id);
}
*//* if(job.CronJobDetail.Name.contains('Get Delete Records From TT Job')){
System.abortJob(job.id);
}*//*
}
TelosTouchSF__TelosTouch_API_Settings__c updateSettings = new TelosTouchSF__TelosTouch_API_Settings__c();
if(Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.isQueryable()){
updateSettings = TelosTouchSF__TelosTouch_API_Settings__c.getOrgDefaults();
}
if(updateSettings.Id != null){
if(Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.fields.Id.isAccessible() && Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.fields.Id.isUpdateable() && Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.fields.Id.isCreateable()){
apiSettingList[0].Id = updateSettings.Id;
}
}
if(Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isUpdateable() && Schema.sObjectType.TelosTouchSF__TelosTouch_API_Settings__c.fields.TelosTouchSF__Approval__c.isCreateable()){
apiSettingList[0].TelosTouchSF__Approval__c = false;
}
if(TelosTouchSF__TelosTouch_API_Settings__c.sObjectType.getDescribe().isAccessible() && TelosTouchSF__TelosTouch_API_Settings__c.sObjectType.getDescribe().isCreateable() && TelosTouchSF__TelosTouch_API_Settings__c.sObjectType.getDescribe().isUpdateable()){
upsert apiSettingList;
}*/
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method generated the session id wrapper.
* @param responseString stores the response.
* @return TelosTouchWrapperUtils.userSignInWrapper OpenAtAndCompletedWrapperObj ....
*/
    private static TelosTouchWrapperUtils.userSignInWrapper generateSessionIdWrapper(String responseString) {
        TelosTouchWrapperUtils.userSignInWrapper thirdPartySignInWrapper =
            (TelosTouchWrapperUtils.userSignInWrapper) JSON.deserialize(responseString, TelosTouchWrapperUtils.userSignInWrapper.class);
        return thirdPartySignInWrapper;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method deletes the contact from Telostouch.
* @param createdcontactlist ....
* @param createdleadlist ....
*/
    public static void deleteContactFromTT(List<Contact> createdcontactlist, List<Lead> createdleadlist){
        try {
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            Map<String,User> userMap = new Map<String,User>();
            List<String> ttClientIdList = new List<String>();
            //User clientOwnerUser = new User();
            List<User> userList = new List<User>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()
               && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible()){
                   userList = [SELECT Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c,TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c  != NULL AND isActive = true];
               }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            Integer deleted = 0, undeleted = 0;
            String /*UserToken,*/endPointURL='',methodType = 'DELETE';
            Map<String, String> headersMap = new Map<String, String>();
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if(createdcontactlist != null && createdcontactlist.size() >0){
                //Map<Id, List<String>> ownerIdVsTtClientIdMap = new Map<Id, List<String>>();
                for(Contact contact : createdcontactlist){
                    /*if(!ownerIdVsTtClientIdMap.containsKey(contact.OwnerId)){
ownerIdVsTtClientIdMap.put(contact.OwnerId, new List<String>{contact.TT_Client_Id__c});
}else{
ownerIdVsTtClientIdMap.get(contact.OwnerId).add(contact.TT_Client_Id__c);
}*/
                    /*if(String.isNotBlank(instanceUrl) ){
if(Schema.sObjectType.Contact.fields.TT_Client_Id__c.isAccessible()){
endPointURL =   instanceUrl + '/api/v1/contacts/'+contact.TT_Client_Id__c;
}
headersMap.put('instance-name', instanceUrl);
}
if(Schema.sObjectType.Contact.fields.OwnerId.isAccessible()){
String  contactOwnerId = contact.OwnerId;
clientOwnerUser = userMap.get(contactOwnerId);
}
if(Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserId__c.isAccessible()){
if(clientOwnerUser != null && clientOwnerUser.TT_UserName__c !=null && clientOwnerUser.Auth_Token__c != null){
Blob blobValue = Blob.valueOf(clientOwnerUser.TT_UserName__c + ':' + clientOwnerUser.Auth_Token__c);
UserToken = EncodingUtil.base64Encode(blobValue);
headersMap.put('Authorization', 'Basic '+ UserToken);
headersMap.put('espo-authorization', UserToken);
}
}
String responseString = getResponse(methodType, endPointURL, headersMap, null);
if(responseString != null && responseString.contains('deleted')){
Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseString);
if(responseMap.containsKey('deleted') && responseMap.get('deleted') == true){
deleted = deleted+1;
}else{
undeleted = undeleted+1;
}
}*/
                    if(String.isNotEmpty(contact.TelosTouchSF__TT_Client_Id__c)){
                        ttClientIdList.add(contact.TelosTouchSF__TT_Client_Id__c);
                    }
                }
                //for(Id ownerId : ownerIdVsTtClientIdMap.keySet()){
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/contacts';
                    /*clientOwnerUser = userMap.get(ownerId);
if(Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserId__c.isAccessible()){
if(clientOwnerUser != null && clientOwnerUser.TT_UserName__c !=null && clientOwnerUser.Auth_Token__c != null){
//Blob blobValue = Blob.valueOf(clientOwnerUser.TT_UserName__c + ':' + clientOwnerUser.Auth_Token__c);
UserToken = clientOwnerUser.Auth_Token__c;
}
}*/
                    headersMap.put('Authorization', 'Bearer '+ authenticationCredential.TelosTouchSF__Access_Token__c);
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    /*Map<Integer, List<String>> TtClientIdChunkMap = new Map<Integer, List<String>>();
Integer count = 1;
for(Integer i=0; i<ownerIdVsTtClientIdMap.get(ownerId).size(); i++){
if(!TtClientIdChunkMap.containsKey(count)){
TtClientIdChunkMap.put(count, new List<String>{ownerIdVsTtClientIdMap.get(ownerId)[i]});
}else{
TtClientIdChunkMap.get(count).add(ownerIdVsTtClientIdMap.get(ownerId)[i]);
}
if(i!=0){
if(Math.mod((i+1), 20) == 0){
count++;
}
}
}*/
                    //for(Integer chunkNumber : TtClientIdChunkMap.keySet()){
                    if(!ttClientIdList.isEmpty()) {
                        Map<String, List<String>> jsonMap = new Map<String, List<String>>();
                        jsonMap.put('ids', ttClientIdList);
                        String body = JSON.serialize(jsonMap);
                        //System.debug('body:: ' + body);
                        Map<String, String> responseString =
                            TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                        if (responseString.get('status_code') == '401') {
                            logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                        }
                        if (responseString.get('body') != null && responseString.get('body').contains('deleted')) {
                            List<Object> responseList =
                                (List<Object>)JSON.deserializeUntyped(responseString.get('body'));
                            for (Object responseObj : responseList) {
                                Map<String, Object> data = (Map<String, Object>)responseObj;
                                if (data.containsKey('deleted') && data.get('deleted') == true) {
                                    deleted = deleted + 1;
                                } else {
                                    undeleted = undeleted + 1;
                                }
                            }
                        }
                    }
                    //}
                }
                //}
            }
            else if(createdleadlist !=null && createdleadlist.size() >0){
                //Map<Id, List<String>> ownerIdVsTtClientIdMap = new Map<Id, List<String>>();
                for(Lead lead : createdleadlist){
                    /*if(!ownerIdVsTtClientIdMap.containsKey(lead.OwnerId)){
ownerIdVsTtClientIdMap.put(lead.OwnerId, new List<String>{lead.TT_Client_Id__c});
}else{
ownerIdVsTtClientIdMap.get(lead.OwnerId).add(lead.TT_Client_Id__c);
}*/
                    if(String.isNotEmpty(lead.TelosTouchSF__TT_Client_Id__c)){
                        ttClientIdList.add(lead.TelosTouchSF__TT_Client_Id__c);
                    }
                }
                //for(Id ownerId : ownerIdVsTtClientIdMap.keySet()){
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                        endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/contacts';
                    }
                    /*if(Schema.sObjectType.Contact.fields.OwnerId.isAccessible()){
clientOwnerUser = userMap.get(ownerId);
}
if(Schema.sObjectType.User.fields.TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TT_UserId__c.isAccessible()){
if(clientOwnerUser != null && clientOwnerUser.TT_UserName__c !=null && clientOwnerUser.Auth_Token__c != null){
headersMap.put('Authorization', 'Bearer '+ clientOwnerUser.Auth_Token__c);
}
}*/
                    headersMap.put('Authorization', 'Bearer '+ authenticationCredential.TelosTouchSF__Access_Token__c);
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    /*Map<Integer, List<String>> TtClientIdChunkMap = new Map<Integer, List<String>>();
Integer count = 1;
for(Integer i=0; i<ownerIdVsTtClientIdMap.get(ownerId).size(); i++){
if(!TtClientIdChunkMap.containsKey(count)){
TtClientIdChunkMap.put(count, new List<String>{ownerIdVsTtClientIdMap.get(ownerId)[i]});
}else{
TtClientIdChunkMap.get(count).add(ownerIdVsTtClientIdMap.get(ownerId)[i]);
}
if(i !=0){
if(Math.mod((i+1), 20) == 0){
count++;
}
}
}*/
                    //for(Integer chunkNumber : TtClientIdChunkMap.keySet()){
                    if(!ttClientIdList.isEmpty()){
                        Map<String, List<String>> jsonMap = new  Map<String, List<String>>();
                        jsonMap.put('ids',ttClientIdList);
                        String body = JSON.serialize(jsonMap);
                        Map<String, String> responseString = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, body);
                        if(responseString.get('body') != null && responseString.get('body').contains('deleted')){
                            List<Object> responseList = (List<Object>)JSON.deserializeUntyped(responseString.get('body'));
                            for(Object responseObj : responseList){
                                Map<String,Object> data = (Map<String,Object>)responseObj;
                                if(data.containsKey('deleted') && data.get('deleted') == true){
                                    deleted = deleted+1;
                                }else{
                                    undeleted = undeleted+1;
                                }
                            }
                        }
                    }
                    //}
                }
                //}
            }
            if(deleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord('success','Clients deleted from SF to TelosTouch.','Clients supprimés de SF à TelosTouch.', deleted);
            }
            if(undeleted >0 ){
                TelosTouchSF.UserTriggerHandler.createLogRecord(System.Label.TelosTouchSF.Failed_Text,'Clients not deleted from TT or not present on TT.','Clients non supprimés dans TT ou absents de TT.',undeleted);
            }
            if(!logList.isEmpty()){
                insert logList;
            }
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN,'exception::'+ex.getMessage() +'At line ::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This Utility method gets the response.
* @param methodType stores the method type.
* @param endPointURL stores endPointURL.
* @param headersMap stores the headersMap.
* @param requestBody stores the body.
* @return Map OpenAtAndCompletedWrapperObj ....
*/
    //Utility Method to get Response
    public static Map<String, String> getResponse(String methodType, String endPointURL, Map<String, String> headersMap, String requestBody) {
        try {
            //Integer usagelimit, maxlimit;
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            request.setMethod(methodType);
            request.setEndpoint(endPointURL);
            request.setTimeout(20000);
            Map<String, String> responseMap = new Map<String, String>();
            if (headersMap.size() > 0) {
                for (String str : headersMap.keySet()) {
                    request.setHeader(str, headersMap.get(str));
                }
            }
            if (requestBody != null) {
                request.setBody(requestBody);
            }
            system.debug(LoggingLevel.DEBUG, 'requestBody TU::'+requestBody);
            system.debug(LoggingLevel.DEBUG, 'request endpoint TU:: '+request.getEndpoint());
            system.debug(LoggingLevel.DEBUG, 'request Method TU:: '+request.getMethod());
            system.debug(LoggingLevel.DEBUG, 'request Headers TU:: '+headersMap);
            
            /* List<System.OrgLimit> limits = OrgLimits.getAll();
for (System.OrgLimit aLimit: limits){
if(aLimit.getName() == 'DailyApiRequests'){
usagelimit = aLimit.getValue();
maxlimit = aLimit.getLimit();
}
}*/
            // if(usagelimit < maxlimit){
            //System.debug(Datetime.now());
            response = http.send(request);
            //System.debug(Datetime.now());
            /* }
else{
UserTriggerHandler.createLogRecord('Error','Org daily API requests limit has been exceeded!', 0);
return null;
}*/
            system.debug(LoggingLevel.DEBUG, 'response body TU::'+response.getBody());
            system.debug(LoggingLevel.DEBUG, 'response Status Code TU::'+response.getStatusCode());
            if(response.getstatusCode() == 200 && response.getbody() != null){
                if(response.getstatus() =='panding'){
                    responseMap.put('body', response.getStatus());
                    return responseMap;
                }
                responseMap.put('status_code', String.valueOf(response.getStatusCode()));
                responseMap.put('body', response.getBody());
                return responseMap;
            }else if(response.getstatusCode() == 202 && response.getstatus() == 'Accepted'){
                if(response.getBody() == '[]'){
                    responseMap.put('body', response.getStatus());
                    return responseMap;
                }else{
                    responseMap.put('status_code', String.valueOf(response.getStatusCode()));
                    responseMap.put('body', response.getBody());
                    return responseMap;
                }
            }else if((response.getStatusCode() == 422) || (response.getStatusCode() == 401) || (response.getStatusCode() == 500) || (response.getStatusCode() == 400 && response.getBody().contains('problems'))){
                responseMap.put('status_code', String.valueOf(response.getStatusCode()));
                responseMap.put('body', response.getBody());
                return responseMap;
            }
        } catch (Exception ex) {
            String exceptionString = 'ERROR:' + ex.getMessage() + 'ON LINE:' + ex.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'exceptionString:' + exceptionString);
            //System.debug(Datetime.now());
            Map<String, String> responseMap = new Map<String, String>();
            responseMap.put('error', exceptionString);
            return responseMap;
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the response.
* @param recordId stores the id of record.
* @return String success ....
*/
    @AuraEnabled
    public static  String shareWithClients(string recordId){
        if(String.isNotBlank(recordId)){
            Task task = new Task();
            if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isQueryable() &&
               Schema.sObjectType.Task.fields.Id.isAccessible() &&
               Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible()){
                   task = [SELECT Id,TelosTouchSF__Share_with_client_s__c FROM Task WHERE Id =: recordId ];
               }
            if(task != null){
                if(Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isAccessible() && Schema.sObjectType.Task.fields.TelosTouchSF__Share_with_client_s__c.isUpdateable()){
                    task.TelosTouchSF__Share_with_client_s__c  = 'Yes';
                }
                if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isUpdateable()){
                    update task;
                }
                return 'success';
            }
        }
        return 'error';
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method checks that PostInstallScript batch running or not.
* @return Boolean true ....
*/
    @AuraEnabled
    public static Boolean checkIfPostInstallScriptRunning_APEX() {
        List<AsyncApexJob> postInstallBatchList = new List<AsyncApexJob>();
        if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() &&
           Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
           Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() ){
               postInstallBatchList = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'BatchPostInstallScript' AND Status != 'Completed' limit 3];
           }
        if (postInstallBatchList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param apexJob ....
* @return Boolean true ....
*/
    public static Boolean checkAsyncApexJob(String apexJob) {
        List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
        if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() &&
           Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
           Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() ){
               asyncApexJobList = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name =:apexJob AND Status = 'Completed' LIMIT 1];
           }
        if (asyncApexJobList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param recordId ....
* @param objectName ....
* @param action ....
* @param userId ....
* @param lastLoginDate ....
* @return ClientInviteWrapper inviteWrapper ....
*/
    @AuraEnabled
    public static ClientInviteWrapper checkClientInvite(String recordId, String objectName, String action, String userId, String lastLoginDate){
        string contactrecordId;
        ClientInviteWrapper  inviteWrapper =  new ClientInviteWrapper();
        if(objectName == 'Account'){
            boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
            if(isPersonAccountEnabled == true){
                string queryStr12 = 'SELECT Id,PersonContactId, Name FROM ' + objectName +' WHERE Id=:recordId';
                sobject obj = Database.query(String.escapeSingleQuotes(queryStr12));
                contactrecordId = (String) obj.get('PersonContactId');
            }else{
                inviteWrapper.isNotPersonAccount = false;
                return inviteWrapper;
            }
            objectName = 'Contact';
            if(contactrecordId != null){
                recordId = contactrecordId;
            }else{
                recordId = null;
                inviteWrapper.isNotPersonAccount = false;
                return inviteWrapper;
            }
        }
        inviteWrapper.clientId = '';
        if(String.isNotEmpty(recordId) && String.isNotEmpty(objectName)){
            inviteWrapper.recordId = recordId;
            inviteWrapper.objectName = objectName;
            String strQuery = 'SELECT Id,TelosTouchSF__TT_Client_Id__c,TelosTouchSF__TT_Last_Login__c,Email,TelosTouchSF__TT_UserId__c FROM '+objectName +' WHERE id =:recordId AND TelosTouchSF__TT_Client_Id__c != null LIMIT 1' ;
            List<sObject> recordObj  = Database.query(String.EscapeSingleQuotes(strQuery));
            Contact  conObject= new Contact();
            Lead  leadObject= new Lead();
            if(objectName == 'Lead' && recordObj.size() >0){
                leadObject = (Lead)recordObj[0];
                inviteWrapper.userName = leadObject.Email;
                inviteWrapper.clientId = leadObject.TelosTouchSF__TT_Client_Id__c;
                inviteWrapper.userId = leadObject.TelosTouchSF__TT_UserId__c;
                if(leadObject != null && leadObject.TelosTouchSF__TT_Last_Login__c != null && leadObject.TelosTouchSF__TT_UserId__c != null){
                    inviteWrapper.reSendPassword = true;
                    inviteWrapper.isInvite =  false;
                }else{
                    inviteWrapper.reSendPassword = false;
                    inviteWrapper.isInvite =  true;
                }
                if(leadObject != null && action != null && action == 'updateClient'){
                    if(Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Last_Login__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Last_Login__c.isUpdateable()
                       && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isUpdateable()){
                           //leadObject.TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                           leadObject.TelosTouchSF__TT_UserId__c = userId;
                           leadObject.TelosTouchSF__TT_Last_Login__c = lastLoginDate!=null?lastLoginDate:System.Label.TelosTouchSF.After_TT_invite;
                           update leadObject;
                       }
                }
                inviteWrapper.lastLogin = leadObject.TelosTouchSF__TT_Last_Login__c;
            }else if(objectName == 'Contact' && recordObj.size() >0){
                conObject = (Contact)recordObj[0];
                inviteWrapper.clientId = conObject.TelosTouchSF__TT_Client_Id__c;
                inviteWrapper.userName = conObject.Email;
                inviteWrapper.userId = conObject.TelosTouchSF__TT_UserId__c;
                if(conObject != null && conObject.TelosTouchSF__TT_Last_Login__c != null && conObject.TelosTouchSF__TT_UserId__c != null){
                    inviteWrapper.reSendPassword = true;
                    inviteWrapper.isInvite =  false;
                }else{
                    inviteWrapper.reSendPassword = false;
                    inviteWrapper.isInvite =  true;
                }
                if(conObject != null && action != null && action == 'updateClient'){
                    if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Last_Login__c.isAccessible() && Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Last_Login__c.isUpdateable()
                       && Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isUpdateable()){
                           //conObject.TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                           conObject.TelosTouchSF__TT_UserId__c = userId;
                           conObject.TelosTouchSF__TT_Last_Login__c = lastLoginDate!=null?lastLoginDate:System.Label.TelosTouchSF.After_TT_invite;
                           update conObject;
                       }
                }
                inviteWrapper.lastLogin = conObject.TelosTouchSF__TT_Last_Login__c;
            }
            inviteWrapper.isNotPersonAccount = true;
        }
        return inviteWrapper;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param recordObject ....
* @param action ....
* @return ClientInviteWrapper inviteWrapper ....
*/
    @AuraEnabled
    public static ClientInviteWrapper sendUserInvitation(String recordObject, String action){
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        ClientInviteWrapper obj = (ClientInviteWrapper)JSON.deserialize(recordObject, ClientInviteWrapper.class);
        String endPointURL,body,userAuthTOKEN;
        Map<String, String> getResponse = new Map<String, String>();
        Map<String, String> getResponse2 = new Map<String, String>();
        Map<String, String> headersMap = new Map<String, String>();
        List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
        if(String.isNotBlank(authenticationCredential.TelosTouchSF__Access_Token__c) ){
            userAuthTOKEN = getCurrentuserTOKEN();
            if(userAuthTOKEN != null){
                headersMap.put('Authorization','Bearer '+userAuthTOKEN);
            }
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/contacts/'+obj.clientId;
            getResponse2 = getResponse('GET', endPointURL, headersMap, null);
            Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(getResponse2.get('body'));
            if(action == 'invite'){
                if(getResponse2.get('status_code') == '401'){
                    logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                }
                if(getResponse2.get('status_code') == '200'){
                    if(responseMap2.containsKey('userId') && responseMap2.get('userId') == null){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/contacts/invite';
                        body = '{"ids":["'+obj.clientId+'"]}';
                        getResponse('POST', endPointURL, headersMap, body);
                        obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', null, null);
                        obj.reSendPassword = false;
                        obj.isInvite =  true;
                    }else{
                        DateTime lastLoginDate;
                        if(responseMap2.containsKey('lastLoginDate') && responseMap2.get('lastLoginDate') != null){
                            lastLoginDate = (DateTime)JSON.deserialize('"' + responseMap2.get('lastLoginDate') + '"', DateTime.class);
                            obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', String.valueOf(responseMap2.get('userId')), lastLoginDate.formatGMT('MMM d yyyy HH:mm:a'));
                            obj.reSendPassword = true;
                            obj.isInvite =  false;
                        }else{
                            obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', String.valueOf(responseMap2.get('userId')), null);
                            obj.reSendPassword = true;
                            obj.isInvite =  false;
                        }
                    }
                }
            }else {
                if(obj.userId != null){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users/'+obj.userId+'/reset-password';
                    getResponse('POST', endPointURL, headersMap, body);
                    Datetime lastLoginDate;
                    if(responseMap2.containsKey('lastLoginDate') && responseMap2.get('lastLoginDate') != null) {
                        lastLoginDate = (DateTime)JSON.deserialize('"' + responseMap2.get('lastLoginDate') + '"', DateTime.class);
                        obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', obj.userId, lastLoginDate.formatGMT('MMM d yyyy HH:mm:a'));
                    }else{
                        obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', obj.userId, null);
                    }
                    obj.reSendPassword = true;
                    obj.isInvite =  false;
                    //body = '{"id":"'+obj.userId+'"}';
                }else{
                    Map<String, String> getResp = getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/contacts/'+obj.clientId, headersMap, Null);
                    if(getResp.get('status_code') == '401'){
                        logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                    }
                    if(getResp.get('body') != null && getResp.get('body').contains('userId')){
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(getResp.get('body'));
                        body = '{"id":"'+responseMap.get('userId')+'"}';
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/users/'+responseMap.get('userId')+'/reset-password';
                        getResponse('POST', endPointURL, headersMap, body);
                        DateTime lastLoginDate;
                        if(responseMap.containsKey('lastLoginDate') && responseMap.get('lastLoginDate') != null){
                            lastLoginDate = (DateTime)JSON.deserialize('"' + responseMap.get('lastLoginDate') + '"', DateTime.class);
                            obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', String.valueOf(responseMap.get('userId')), lastLoginDate.formatGMT('MMM d yyyy HH:mm:a'));
                            obj.reSendPassword = true;
                            obj.isInvite =  false;
                        }else{
                            obj = checkClientInvite(obj.recordId, obj.objectName, 'updateClient', String.valueOf(responseMap.get('userId')), null);
                            obj.reSendPassword = true;
                            obj.isInvite =  false;
                        }
                    }
                }
            }
        }
        if(!logList.isEmpty()){
            insert logList;
        }
        return obj;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param recordIdsList ....
* @param objectName ....
* @return String inviteWrapper ....
*/
    @AuraEnabled
    public static String massInvitationToClients(String recordIdsList, String objectName){
        try{
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            String endPointURL,body,str='',str2='',returnString,userAuthTOKEN, responseBodyStr;
            Map<String, String> responseBody;
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            List<String> clientIdList = new List<String>();
            Map<String, String> headersMap = new Map<String, String>();
            Map<String,Contact> contactMap = new Map<String,Contact>();
            Map<String,Lead> leadMap = new Map<String,Lead>();
            String stringList = recordIdsList.deleteWhitespace();
            stringList = stringList.remove('[');
            stringList = stringList.remove(']');
            List<String> sid = (List<String>) JSON.deserialize(recordIdsList, List<String>.class);
            Set<Id> newIdSet = new Set<Id>();
            Set<Id> personAccIdSet = new Set<Id>();
            if(objectName == 'Account'){
                boolean isPersonAccountEnabled = Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount');
                if(isPersonAccountEnabled == true){
                    for(String sobj: sid){
                        personAccIdSet.add(Id.valueof(sobj));
                    }
                    string queryStr12 = 'SELECT Id,PersonContactId, Name FROM ' + objectName +' WHERE Id=:personAccIdSet AND TT_Client_Id__pc != null';
                    List<sObject> sObjList = Database.query(String.escapeSingleQuotes(queryStr12));
                    for(sObject obj : sObjList){
                        newIdSet.add(String.valueof(obj.get('PersonContactId')));
                    }
                    if(newIdSet.size() == 0){
                        return 'Please select valid records for invite.';
                    }
                }else{
                    return 'Person Account Not Enabled';
                }
                objectName = 'Contact';
            }else{
                for(String sobj: sid){
                    newIdSet.add(Id.valueof(sobj));
                }
            }
            String queryStr = 'SELECT Id, TelosTouchSF__TT_Client_Id__c,TelosTouchSF__TT_Last_Login__c,TelosTouchSF__TT_UserId__c FROM ' + objectName +' WHERE Id IN:newIdSet AND TelosTouchSF__TT_Client_Id__c != Null AND TelosTouchSF__TT_Last_Login__c = null LIMIT 1000';
            queryStr = String.escapeSingleQuotes(queryStr).replace('\\','');
            List<sObject> recordList = Database.query(String.escapeSingleQuotes(queryStr));
            for(SObject obj : recordList){
                if(objectName == 'Contact'){
                    contactList.add((Contact)obj);
                }else{
                    leadList.add((Lead)obj);
                }
            }
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if( String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/contacts/invite';
                userAuthTOKEN = getCurrentuserTOKEN();
                if(userAuthTOKEN != null){
                    headersMap.put('Authorization','Bearer '+userAuthTOKEN);
                }
            }
            if(contactList.size() >0){
                for(Contact con : contactList){
                    contactMap.put(con.TelosTouchSF__TT_Client_Id__c, con);
                    con.TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                    clientIdList.add(con.TelosTouchSF__TT_Client_Id__c);
                }
            }else if(leadList.size() >0 ){
                for(Lead lead : leadList){
                    leadMap.put(lead.TelosTouchSF__TT_Client_Id__c, lead);
                    lead.TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                    clientIdList.add(lead.TelosTouchSF__TT_Client_Id__c);
                }
            }else{
                returnString = 'Please select valid records for invite.';
            }
            if(clientIdList != null && !clientIdList.isEmpty()){
                Map<String, List<String>> requestMap = new Map<String, List<String>>();
                requestMap.put('ids', clientIdList);
                body = JSON.serialize(requestMap);
                responseBody  = getResponse('POST', endPointURL, headersMap, body);
                responseBodyStr = responseBody.get('body');
            }
            if(responseBody.get('status_code') == '401'){
                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
            }
            if(responseBodyStr != null && responseBodyStr.contains('id')){
                List<Object>  responseList= (List<Object>)JSON.deserializeUntyped(responseBodyStr);
                for(Object obj : responseList) {
                    Map<String, Object> stringVsObjMap = (Map<String, Object>)obj;
                    if(contactMap.containskey(String.valueOf(stringVsObjMap.get('id'))) && contactMap.get(String.valueOf(stringVsObjMap.get('id'))) != null){
                        contactMap.get(String.valueOf(stringVsObjMap.get('id'))).TelosTouchSF__TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                        if(stringVsObjMap.containskey('userId') && String.valueOf(stringVsObjMap.get('userId')) != null ){
                            contactMap.get(String.valueOf(stringVsObjMap.get('id'))).TelosTouchSF__TT_UserId__c = String.valueOf(stringVsObjMap.get('userId'));
                        }
                    }else if(leadMap.containskey(String.valueOf(stringVsObjMap.get('id'))) && leadMap.get(String.valueOf(stringVsObjMap.get('id'))) != null){
                        leadMap.get(String.valueOf(stringVsObjMap.get('id'))).TelosTouchSF__TT_Last_Login__c = System.Label.TelosTouchSF.After_TT_invite;
                        if(stringVsObjMap.containskey('userId') && String.valueOf(stringVsObjMap.get('userId')) != null ){
                            leadMap.get(String.valueOf(stringVsObjMap.get('id'))).TelosTouchSF__TT_UserId__c = String.valueOf(stringVsObjMap.get('userId'));
                        }
                    }
                }
                if(contactMap.values() != null){
                    update contactMap.values();
                }else if(leadMap.values() != null){
                    update leadMap.values();
                }
                returnString = 'sent';
            }else if(responseBody.get('body') == 'Accepted' && contactList.size()>0){
                update contactList;
                returnString = 'sent';
            }else if(responseBody.get('body') == 'Accepted' && leadList.size()>0){
                update leadList;
                returnString = 'sent';
            }
            if(!logList.isEmpty()){
                insert logList;
            }
            return returnString;
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN,'exception::'+ex.getMessage() +'At line ::'+ex.getLineNumber());
        }
        return 'not sent';
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return String userAuthTOKEN ....
*/
    public static String getCurrentuserTOKEN(){
        String userAuthTOKEN;
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
           Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
           Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
               List<User> user = [SELECT Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c FROM User WHERE Id=:UserInfo.getUserId() AND TelosTouchSF__TT_UserId__c != Null ];
               if( user != null && user.size() > 0  && authenticationCredential.TelosTouchSF__Access_Token__c != null){
                   if(user.size()>0 && user[0].TelosTouchSF__Auth_Token__c != null ){
                       userAuthTOKEN = user[0].TelosTouchSF__Auth_Token__c;
                   }
               }
           }
        return userAuthTOKEN;
    }
    public static boolean isObjectExist(String ObjectNameParam){
        for (Schema.SObjectType sObjectTypeObj : Schema.getGlobalDescribe().values() ) {
            String sobjName = String.valueOf(sObjectTypeObj);
            if (sobjName.contains(ObjectNameParam) ) {
                return true;
            }
        }
        return false;
    }
    @AuraEnabled
    public static Boolean checkInviteFunctionality(){
        TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
        TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
        List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
        Map<String, String> headersMap = new Map<String, String>();
        if(adminCredentials != null && String.isNotEmpty(authenticationCredential.TelosTouchSF__Access_Token__c)){
            headersMap.put('Authorization','Bearer '+authenticationCredential.TelosTouchSF__Access_Token__c);
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            Map<String, String> getResponseMap = getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/preferences', headersMap, null);
            if(getResponseMap.containsKey('adminToken')){
                authenticationCredential.TelosTouchSF__Access_Token__c = getResponseMap.get('adminToken');
                System.enqueueJob(new TelosTouchSF.UpdateCustomMetadataQueueable(adminCredentials, authenticationCredential));
            }
            if(getResponseMap.containsKey('userToken')){
                if(SObjectType.User.getSObjectType().getDescribe().isAccessible() && SObjectType.User.getSObjectType().getDescribe().isUpdateable() &&
                   Schema.SObjectType.User.fields.Id.isAccessible() &&
                   Schema.SObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.SObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable()){
                       User userObj = new User();
                       userObj.Id = getResponseMap.get('userId');
                       userObj.TelosTouchSF__Auth_Token__c = getResponseMap.get('userToken');
                       update userObj;
                   }
            }
            if(getResponseMap.get('status_code') == '401'){
                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                return false;
            }
            Map<String, Object> responseJsonMap = new Map<String, Object>();
            responseJsonMap = (Map<String, Object>)JSON.deserializeUntyped(getResponseMap.get('body'));
            if(!responseJsonMap.keySet().isEmpty() && responseJsonMap.containsKey('clientPortal')){
                return (Boolean)responseJsonMap.get('clientPortal');
            }
        }
        return false;
    }
    @AuraEnabled
    public static String getCampaignDetails(Id campSfId){
        try{
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
            Set<Id> insightsIdSet = new Set<Id>();
            Map<String, Object> returnMap = new Map<String, Object>();
            if(String.isNotEmpty(authenticationCredential.TelosTouchSF__Access_Token__c)){
                returnMap.put('accessTokenPresent', (Object)true);
            }else{
                returnMap.put('accessTokenPresent', (Object)false);
            }
            Campaign campObj = [SELECT Id, TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id =: campSfId LIMIT 1];
            if(campObj != null && String.isNotEmpty(campObj.TelosTouchSF__TT_Campaign_Id__c)){
                returnMap.put('synced', (Object)true);
                List<CampaignMember> campMemList = new List<CampaignMember>();
                List<CampaignMember> campMemReturnList = new List<CampaignMember>();
                Integer campMemCount = [SELECT count() FROM CampaignMember WHERE campaignId =: campObj.Id];
                if(campMemCount == 0){
                    returnMap.put('campMemberPresent', (Object)false);
                }else{
                    returnMap.put('campMemberPresent', (Object)true);
                }
                campMemList = [SELECT Id, campaignId, contactId, leadId FROM CampaignMember WHERE campaignId =: campObj.Id];
                List<TelosTouchSF__Insights__c> insightsList = new List<TelosTouchSF__Insights__c>();
                insightsList = [SELECT Id, TelosTouchSF__contact__c, TelosTouchSF__lead__c FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__campaign2__c =: campObj.Id WITH SECURITY_ENFORCED];
                for(TelosTouchSF__Insights__c insight : insightsList){
                    if(insight.TelosTouchSF__Contact__c != null && insight.TelosTouchSF__Lead__c == null){
                        insightsIdSet.add(insight.TelosTouchSF__Contact__c);
                    }else if(insight.TelosTouchSF__Contact__c == null && insight.TelosTouchSF__Lead__c != null){
                        insightsIdSet.add(insight.TelosTouchSF__Lead__c);
                    }
                }
                for(CampaignMember campMemObj : campMemList){
                    if(campMemObj.ContactId != null && campMemObj.LeadId == null){
                        if(!insightsIdSet.contains(campMemObj.ContactId)){
                            returnMap.put('actionRequired', (Object)true);
                            break;
                        }
                    }else if(campMemObj.ContactId == null && campMemObj.LeadId != null){
                        if(!insightsIdSet.contains(campMemObj.LeadId)){
                            returnMap.put('actionRequired', (Object)true);
                            break;
                        }
                    }
                }
                if(returnMap.containsKey('actionRequired') && (Boolean)returnMap.get('actionRequired')){
                    for(CampaignMember campMemObj : campMemList){
                        if(campMemObj.ContactId != null && campMemObj.LeadId == null){
                            if(!insightsIdSet.contains(campMemObj.ContactId)){
                                campMemReturnList.add(campMemObj);
                            }
                        }else if(campMemObj.ContactId == null && campMemObj.LeadId != null){
                            if(!insightsIdSet.contains(campMemObj.LeadId)){
                                campMemReturnList.add(campMemObj);
                            }
                        }
                    }
                    returnMap.put('campMemList', (Object)campMemReturnList);
                }
                if(!returnMap.containsKey('actionRequired')){
                    returnMap.put('actionRequired', (Object)false);
                }
            }else if(campObj != null){
                Integer campMemCount = [SELECT count() FROM CampaignMember WHERE campaignId =: campObj.Id];
                if(campMemCount == 0){
                    returnMap.put('campMemberPresent', (Object)false);
                }else{
                    returnMap.put('campMemberPresent', (Object)true);
                }
                returnMap.put('synced', (Object)false);
                returnMap.put('actionRequired', (Object)false);
            }
            if(returnMap.containsKey('actionRequired')){
                returnMap.put('openTouchPointModal', returnMap.get('actionRequired'));
            }
            if(returnMap.containsKey('openTouchPointModal') && [SELECT count() FROM AsyncApexJob WHERE (ApexClass.Name = 'BatchCreateInsightsForNewRecipients' OR ApexClass.Name = 'BatchAddRecipientsIntoTouchPoint')
                AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing')] > 0){
                    returnMap.put('openTouchPointModal', (Object)false);
                }
            //System.debug(JSON.serialize(returnMap));
            return JSON.serialize(returnMap);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'exception::'+ex.getMessage() +'At line ::'+ex.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static Boolean addClientsToTouchpoint(String campMemListStr){
        try{
            List<CampaignMember> campMemList = new List<CampaignMember>();
            campMemList = (List<CampaignMember>) JSON.deserialize(campMemListStr, List<CampaignMember>.class);
            CampMemberNotAddInCampHandler.addRecipientsIntoTouchPoint(campMemList);
            return true;
        }catch (Exception ex){
            return false;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param isTTActive ....
* @param isSFActive ....
* @param MasterLabel ....
*/
    @AuraEnabled
    public static void createUpdateMetadata(Boolean isTTActive, Boolean isSFActive, String MasterLabel){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'TelosTouchSF__TT_Feature_Flag' + '.' + 'TelosTouchSF__'+MasterLabel;
        customMetadata.label = MasterLabel;
        
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        fieldWithValuesMap.put('TelosTouchSF__TT_Flag__c',isTTActive);
        fieldWithValuesMap.put('TelosTouchSF__SF_Flag__c',isSFActive);
        
        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        TelosTouchSF.TelosTouchUtility callback = new TelosTouchSF.TelosTouchUtility();
        if(!(Test.isRunningTest())){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param enableFinestLogs ....
* @param MasterLabel ....
*/
    @AuraEnabled
    public static void updateFinestLogging(Boolean enableFinestLogs, String MasterLabel){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'TelosTouchSF__TT_Feature_Flag' + '.' + 'TelosTouchSF__' +MasterLabel;
        customMetadata.label = MasterLabel;
        
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        fieldWithValuesMap.put('TelosTouchSF__ShowFinestLogs__c',enableFinestLogs);
        
        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        TelosTouchSF.TelosTouchUtility callback = new TelosTouchSF.TelosTouchUtility();
        if(!(Test.isRunningTest())){
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return boolean  ....
*/
    @AuraEnabled
    public static Boolean getInviteFlag(){
        try {
            TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id,MasterLabel ,TelosTouchSF__TT_Flag__c, TelosTouchSF__SF_Flag__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel='Invite' WITH SECURITY_ENFORCED LIMIT 1];
            if(inviteRecord.TelosTouchSF__TT_Flag__c && inviteRecord.TelosTouchSF__SF_Flag__c){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static AdminCredentialsWrapper sendRegistrationRequest(){
        try{
            AdminCredentialsWrapper adminWrapper = TelosTouchSF.SFDataSyncWithTelosTouch.registerOrgOnTelosTouch();
            return adminWrapper;
        }catch (Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception: '+e.getMessage()+' caused at Line Number: '+e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static Boolean checkIfEnterpriseClient(){
        try{
            
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
            if(String.isEmpty(adminCredentials.TelosTouchSF__Instance_URL__c)){
                return true;
            }
            String[] StringList = adminCredentials.TelosTouchSF__Instance_URL__c.split('//');
            String[] StringList1 = StringList[1].split('\\.');
            String instance_Name = TelosTouchSF.CreateRemoteSiteSetting.getremoteSiteSetting(adminCredentials.TelosTouchSF__Instance_URL__c, StringList1[0]);
            if(instance_Name != 'Already Exists!'){
                TelosTouchSF.CreateRemoteSiteSetting.remoteSiteSetting1(adminCredentials.TelosTouchSF__Instance_URL__c,instance_Name);
            }
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/organization/'+UserInfo.getOrganizationId()+'?is_enterprise=true');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            res = http.send(req);
            String respMessage = 'Response Status Code: '+res.getstatusCode()+'| Response Body: '+res.getBody();	
            TelosTouchUtility.generateLog(respMessage, 'TelosTouchUtility', 'checkIfEnterpriseClient', null); 
            if(res.getStatusCode()==404){
                return false;
            }else{
                return true;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception: '+ex.getMessage()+' occurred at Line Number: '+ex.getLineNumber());
            return true;
        }
    }

    public static void generateErrorLog(Exception ex, String className, String classMethod, String recordId){
        String aError = ex.getTypeName()+': '+ex.getMessage()+' '+className+'.'+classMethod+': line '+ex.getLineNumber();
        System.debug(logginglevel.ERROR, aError);
        if(TT_FeatureSettingsController.getFinestLogValue()){
	    aError = aError.abbreviate(255);
            Database.insert(SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', aError, recordId));
        }
    }

    public static void generateLog(String message, String className, String classMethod, String recordId){
        String aMessage = className+'.'+classMethod+': '+message;
        System.debug(aMessage);
        if(TT_FeatureSettingsController.getFinestLogValue()){
            aMessage = aMessage.abbreviate(255);
            Database.insert(SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Log', aMessage, recordId));
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description userCredentialsWrapper is used to get list of activeUserWrapper,settingApi,errorMessage and authToken.
*/
    public class userCredentialsWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public List<userWrapper> activeUserWrapper{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public TelosTouchSF__TelosTouch_API_Settings__c settingApi{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public AdminCredentialsWrapper adminCredentials{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String errorMessage{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String authToken{get;set;}
        
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public class userWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public User userObject { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String userProfile{get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String TTUser{get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public class TTUserWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String TTToken { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public String TTUserName { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public class ClientInviteWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean IsNotPersonAccount { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean isInvite { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String message { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String clientId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String objectName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String userName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String recordId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String userId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String lastLogin { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean reSendPassword { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public class AdminCredentialsWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Access_Token { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean Approval { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public DateTime RefreshTokenLastUsedDate { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Client_ID { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Client_Secret { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String ConfigPageVisible  { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean ForSecondTimeBatch { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Instance_URL { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Refresh_Token { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Authentication_URL { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean BatchRunsForSFToTTOnTimeBasis { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Access_Token_Expiration_Time { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean Use_CreatedById { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Boolean Registration_Successful { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public Integer Registration_Request_Expiry { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Registration_DateTime { get; set; }
        @AuraEnabled
        public String Team_Name {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description  constructor for initializing the values.
*/
        public AdminCredentialsWrapper(){
            TT_Admin_Credentials__mdt adminCredentials = getCustomMetadata();
            if(adminCredentials.TelosTouchSF__Approval__c != null &&
               adminCredentials.TelosTouchSF__ForSecondTimeBatch__c != null &&
               adminCredentials.TelosTouchSF__Use_CreatedById__c != null &&
               adminCredentials.TelosTouchSF__Registration_Successful__c != null){
                   Approval = adminCredentials.TelosTouchSF__Approval__c;
                   ForSecondTimeBatch = adminCredentials.TelosTouchSF__ForSecondTimeBatch__c;
                   Use_CreatedById = adminCredentials.TelosTouchSF__Use_CreatedById__c;
                   Registration_Successful = adminCredentials.TelosTouchSF__Registration_Successful__c;
               }else{
                   Approval = false;
                   ForSecondTimeBatch = false;
                   Use_CreatedById = false;
                   Registration_Successful = false;
               }
        }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param adminCredentials ....
* @param authenticationCredentials ....
*/
        public AdminCredentialsWrapper(TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials, TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredentials){
            Access_Token = authenticationCredentials.TelosTouchSF__Access_Token__c;
            Approval = adminCredentials.TelosTouchSF__Approval__c; 
            Client_ID = authenticationCredentials.TelosTouchSF__Client_ID__c;
            Client_Secret = authenticationCredentials.TelosTouchSF__Client_Secret__c;
            ConfigPageVisible = adminCredentials.TelosTouchSF__ConfigPageVisible__c;
            ForSecondTimeBatch = adminCredentials.TelosTouchSF__ForSecondTimeBatch__c;
            Instance_URL = adminCredentials.TelosTouchSF__Instance_URL__c;
            Refresh_Token = authenticationCredentials.TelosTouchSF__Refresh_Token__c;
            BatchRunsForSFToTTOnTimeBasis = adminCredentials.TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c;
            Authentication_URL = adminCredentials.TelosTouchSF__Authentication_URL__c;
            RefreshTokenLastUsedDate = adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c;
            Access_Token_Expiration_Time = adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c;
            Use_CreatedById = adminCredentials.TelosTouchSF__Use_CreatedById__c;
            Registration_Successful = adminCredentials.TelosTouchSF__Registration_Successful__c;
            Registration_Request_Expiry = (Integer) adminCredentials.TelosTouchSF__Registration_Request_Expiry__c;
            Registration_DateTime = adminCredentials.TelosTouchSF__Registration_DateTime__c;
            Team_Name = adminCredentials.TelosTouchSF__Team_Name__c;
        }
    }
}