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
    public static TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials;
    public static TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredentials;
 /**
* @author Cloud Analogy
* @date 02/08/2021
* @description handleResult ....
* @param result ....
* @param context ....
*/
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            //Success
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            System.debug(LoggingLevel.DEBUG, 'Success Result-' + result);
            System.debug(LoggingLevel.DEBUG, 'Success Context-' + context);
            String strDeleteLogRecords      = 'Delete Log Records%';
            String strUpdateUserTokenJob    = 'Update User Token Job%';
            String strGetClientsFromTTJob   = 'Get Clients From TT Job%';
            String strSyncFeatureToggleJob  = 'Sync Feature Toggle Job%';
            List<CronJobDetail> jobList = [SELECT Id FROM CronJobDetail Where Name LIKE :strDeleteLogRecords OR
                                           Name LIKE :strUpdateUserTokenJob OR
                                           Name LIKE :strGetClientsFromTTJob OR
                                           Name LIKE :strSyncFeatureToggleJob WITH SECURITY_ENFORCED];
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
* @return String ...
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
            map<String, TelosTouchSF__TT_Admin_Credentials__mdt> mapMDT = new map<String, TelosTouchSF__TT_Admin_Credentials__mdt>();
            list<PermissionSetAssignment> lstPsa = new list<PermissionSetAssignment>();

            for(TelosTouchSF__TT_Admin_Credentials__mdt mdt : [SELECT MasterLabel, TelosTouchSF__Client_ID__c,TelosTouchSF__Auto_Schedule_Jobs__c,
                TelosTouchSF__Refresh_Token_Last_Used_Date__c, TelosTouchSF__Client_Secret__c, TelosTouchSF__Access_Token__c, TelosTouchSF__Approval__c, 
                TelosTouchSF__ConfigPageVisible__c, TelosTouchSF__Authentication_URL__c, TelosTouchSF__ForSecondTimeBatch__c, TelosTouchSF__Instance_URL__c,
                TelosTouchSF__Refresh_Token__c, TelosTouchSF__Access_Token_Expiration_Time__c, TelosTouchSF__BatchRunsForSFToTTOnTimeBasis__c,
                TelosTouchSF__NotSyncTaskIfHaving__c, TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c, TelosTouchSF__RestrictedTTFieldMapping__c, 
                TelosTouchSF__Use_CreatedById__c, TelosTouchSF__Registration_DateTime__c, TelosTouchSF__Registration_Successful__c, 
                TelosTouchSF__Registration_Request_Expiry__c, TelosTouchSF__Team_Name__c FROM TelosTouchSF__TT_Admin_Credentials__mdt WITH SECURITY_ENFORCED])
            {
                mapMDT.put(mdt.MasterLabel, mdt);
            }

            PermissionSet ps = [SELECT Id, (SELECT Id FROM Assignments WHERE AssigneeId =: Userinfo.getuserid()) 
                                FROM PermissionSet WHERE Name =: System.Label.TelosTouch_Permission_Set_Name WITH SECURITY_ENFORCED LIMIT 1];
            
            if(ps.Assignments.size() > 0){
                lstPsa = ps.Assignments;
            } else if(profileName == System.Label.TelosTouchSF.ShowTTConfigPage){
                lstPsa.add(new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id));
                if (Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.PermissionSetAssignment.isCreateable()){
                    insert lstPsa;
                }
            }
            
            if(Test.isRunningTest() && lstPsa[0].Id != null && mapMDT.containsKey(System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label))
            {
                return mapMDT.get(System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label);
            } else if(lstPsa[0].Id != null && mapMDT.containsKey(System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label))
            {
                return mapMDT.get(System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label);
            }else{
                return new TelosTouchSF__TT_Admin_Credentials__mdt();
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error is::'+e.getMessage() +'at line no::'+e.getLineNumber());
            return new TelosTouchSF__TT_Admin_Credentials__mdt();
        }
        
    }
      /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return TelosTouchSF__TT_Authentication_Credential__mdt TelosTouchSF__TT_Authentication_Credential__mdt ....
*/
    public static TelosTouchSF__TT_Authentication_Credential__mdt getAuthenticationCustomMetadata(){
        try{

            map<String, TelosTouchSF__TT_Authentication_Credential__mdt> mapMDT = new map<String, TelosTouchSF__TT_Authentication_Credential__mdt>();
            list<PermissionSetAssignment> lstPsa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getuserid() 
                                                    AND PermissionSet.Name =: System.Label.TelosTouch_Permission_Set_Name WITH SECURITY_ENFORCED];

            for(TelosTouchSF__TT_Authentication_Credential__mdt mdt : [SELECT MasterLabel, TelosTouchSF__Client_ID__c, TelosTouchSF__Client_Secret__c, 
                                                                        TelosTouchSF__Access_Token__c, TelosTouchSF__Refresh_Token__c
                                                                        FROM TelosTouchSF__TT_Authentication_Credential__mdt WITH SECURITY_ENFORCED])
            {
                mapMDT.put(mdt.MasterLabel, mdt);
            }

            if(Test.isRunningTest() && lstPsa[0].Id != null && mapMDT.containsKey(System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label))
            {
                return mapMDT.get(System.Label.TelosTouchSF.Custom_Metadata_Test_Record_Label);
            }else if(lstPsa[0].Id != null && mapMDT.containsKey(System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label))
            {
                return mapMDT.get(System.Label.TelosTouchSF.Custom_Metadata_Admin_Record_Label);
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
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
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
                       campaigns =[SELECT Name,TelosTouchSF__TT_Campaign_Id__c,RecordType.Name FROM Campaign WHERE Id=:recordId WITH SECURITY_ENFORCED];
                   }
                List<CampaignMember> campaignMembers = new List<CampaignMember>();
                if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isQueryable() &&
                   Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                   Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible()){
                       campaignMembers=  [SELECT ContactId, Contact.TelosTouchSF__TT_Client_Id__c,
                                          LeadId, Lead.TelosTouchSF__TT_Client_Id__c,
                                          Lead.Phone FROM CampaignMember WHERE CampaignId=:recordId WITH SECURITY_ENFORCED];
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
        List<AdminCredentialsWrapper> apiSettingList = (List<AdminCredentialsWrapper>)JSON.deserialize(apiSetting, List<AdminCredentialsWrapper>.class);
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
		        String respMessage = 'Response Status Code: '+response.getstatusCode()+' | Response Body: '+response.getBody();		
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
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
        if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
        if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
        Integer noOfDays = 0, expirationDays = 0;
        if(adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c != null){
            noOfDays = adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c.date().daysBetween( Date.today() );
        }
        if(adminCredentials.TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c != null){
            expirationDays = Integer.valueOf(adminCredentials.TelosTouchSF__Refresh_Token_Expiration_If_Inactive__c) - 1;
        }
        String[] StringList = adminCredentials.TelosTouchSF__Instance_URL__c.split('//');
        String[] StringList1 = StringList[1].split('\\.');
        String scope = 'profile';
        String body = 'scope='+EncodingUtil.urlEncode(scope,'UTF-8')
            +'&client_id='+EncodingUtil.urlEncode(authenticationCredentials.TelosTouchSF__Client_ID__c.trim(),'UTF-8')
            +'&client_secret='+EncodingUtil.urlEncode(authenticationCredentials.TelosTouchSF__Client_Secret__c.trim(),'UTF-8')
            +'&refresh_token='+EncodingUtil.urlEncode(authenticationCredentials.TelosTouchSF__Refresh_Token__c.trim(),'UTF-8')
            +'&grant_type=refresh_token';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(adminCredentials.TelosTouchSF__Authentication_URL__c+'/auth/realms/'+StringList1[0]+'/protocol/openid-connect/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            authenticationCredentials.TelosTouchSF__Access_Token__c = String.valueOf(responseMap.get('access_token'));
            if(noOfDays >= expirationDays) {
                authenticationCredentials.TelosTouchSF__Refresh_Token__c = String.valueOf(responseMap.get('refresh_token'));
            }
            adminCredentials.TelosTouchSF__Refresh_Token_Last_Used_Date__c = System.now();
            return new AdminCredentialsWrapper(adminCredentials, authenticationCredentials);
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
                User userUpdateObj = new User();
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
                        String strSalesforce = 'Salesforce';
                        String strSystemAdministrator = 'System Administrator';
                        String strAdministrateursysteme = 'Administrateur système';
                           user = [SELECT Id, userName, ProfileId, Profile.Name, firstName,phone, lastName, Email,TelosTouchSF__TT_UserId__c, TelosTouchSF__TT_UserName__c, IsActive,TelosTouchSF__Auth_Token__c FROM User
                                   WHERE IsActive = true AND UserPermissionsMarketingUser = true AND Profile.UserLicense.Name =: strSalesforce AND
                                   Id=:UserId AND profileId =:[SELECT id FROM Profile WHERE (Name =: strSystemAdministrator OR Name =: cstmLabel) OR (Name =: strAdministrateursysteme OR Name =: cstmLabel1) ] WITH SECURITY_ENFORCED LIMIT 1];
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
		                        String respMessage = 'Response Status Code: '+teamIdResponse.get('status_code')+' | Response Body: '+teamIdResponse.get('body');		
                            teamId = teamIdResponse.get('body');
                        }
                        String endpoint = adminCredentials.Instance_URL.trim()+'/api/v1/users?search='+user.Email;
                        Map<String, String> getResponseBody = getResponse('GET', endpoint, headersMap, null);
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
                        if(!getResponseMap.keySet().isEmpty()){
                            Map<String, String> getCurrentTeamBody = TelosTouchUtility.getResponse('GET', adminCredentials.Instance_URL+'/api/v1/users/'+String.valueOf(getResponseMap.get('id'))+'/teams', headersMap, null);
                            if(getCurrentTeamBody.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }
                            List<Object> getCurrentTeamList = (List<Object>) JSON.deserializeUntyped(getCurrentTeamBody.get('body'));
                            Map<String, Object> getCurrentTeamMap = (Map<String, Object>)getCurrentTeamList[0];
                            String currentTeamName = String.valueOf(getCurrentTeamMap.get('path')).split('/')[1].trim();
                            if(ttTeamName != currentTeamName){
                                Map<String,String> teamChangeReponseBody = TelosTouchSF.TelosTouchUtility.getResponse('PUT', adminCredentials.Instance_URL+'/api/v1/users/'+String.valueOf(getResponseMap.get('id'))+'/teams/'+teamId, headersMap, null);
                                if(teamChangeReponseBody.get('status_code') == '401'){
                                    logList.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                                }
                                Map<String, Object> teamChangeResponseMap = (Map<String, Object>) JSON.deserializeUntyped(teamChangeReponseBody.get('body')!=null ? teamChangeReponseBody.get('body') : '{}');
                                if(teamChangeResponseMap.containsKey('id')){
                                    userUpdateFlag = true;
                                }
                            }else if(ttTeamName == currentTeamName){
                                userUpdateFlag = true;
                            }
                            if(userUpdateFlag){
                                if (Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
                                    Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable()) {
                                        userUpdateObj.Id = user.Id;
                                        userUpdateObj.TelosTouchSF__TT_UserId__c = String.valueOf(getResponseMap.get('id'));
                                        userUpdateObj.TelosTouchSF__TT_UserName__c = String.valueOf(getResponseMap.get('username'));
                                        ttuserObj = getTokenForEachUser(String.valueOf(getResponseMap.get('username')),adminCredentials);
                                        userUpdateObj.TelosTouchSF__Auth_Token__c = ttuserObj.TTToken;
                                    }
                            }
                        }else{
                            String body = '{"firstName": "'+user.firstName
                                +'","lastName": "'+user.lastName
                                +'","username": "'+user.Username
                                +'","phone": "'+user.Phone
                                +'","email": "'+user.Email
                                +'","role":"professional","team":"'+teamId+'","otherId":"'
                                +user.Id+'"}';
                            Map<String, String> responseBody = getResponse('POST', adminCredentials.Instance_url.trim()+'/api/v1/users', headersMap, body);
                            if(responseBody.get('status_code') == '401'){
                                logList.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                            }
                            if(responseBody.get('body') != null){
                                Map<String, Object> responseMap2 = (Map<String, Object>)JSON.deserializeUntyped(responseBody.get('body'));
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
                                    if(SObjectType.User.getSObjectType().getDescribe().isAccessible() && SObjectType.User.getSObjectType().getDescribe().isUpdateable() && 
                                        Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() &&
                                       Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable() &&
                                       Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable()  
                                       ){
                                            userUpdateObj.Id = user.Id;
                                            userUpdateObj.TelosTouchSF__TT_UserId__c = String.valueof(responseMap2.get('id'));
                                            userUpdateObj.TelosTouchSF__TT_UserName__c = String.valueof(responseMap2.get('username'));
                                           ttuserObj = getTokenForEachUser(String.valueOf(responseMap2.get('username')), adminCredentials);
                                           userUpdateObj.TelosTouchSF__Auth_Token__c =   ttuserObj.TTToken;
                                       }
                                }
                            }else{
                                getActiveUserWrapper.errorMessage = 'This user is not validate with TT.';
                                return null;
                            }
                        }
                        String strTelosTouch_Custom_Permission = 'TelosTouch_Custom_Permission';
                        if(user.TelosTouchSF__TT_UserId__c != null && user.TelosTouchSF__TT_UserName__c != null && user.TelosTouchSF__Auth_Token__c != null
                           && [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name =: strTelosTouch_Custom_Permission AND AssigneeId =: UserInfo.getUserId()] == 0){
                               PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: strTelosTouch_Custom_Permission WITH SECURITY_ENFORCED];
                               if(ps != null && ps.Id != null){
                                   insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
                               }
                           }
                           if(SObjectType.User.getSObjectType().getDescribe().isAccessible() && SObjectType.User.getSObjectType().getDescribe().isUpdateable() && 
                           Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isUpdateable() &&
                          Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isUpdateable() &&
                          Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isUpdateable()){
                               //update user;
                               Database.update(userUpdateObj, AccessLevel.USER_MODE);
                           
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
                   customSettingList = [SELECT TelosTouchSF__RoleId__c, TelosTouchSF__RolesName__c FROM TelosTouchSF__TelosTouch_User_Role__c WHERE TelosTouchSF__RoleId__c != null AND TelosTouchSF__RolesName__c != null WITH SECURITY_ENFORCED LIMIT 1];
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
                    String strTelosTouch_Custom_Permission = 'TelosTouch_Custom_Permission';
                    String strTTPSetForInsightObjMDRelations = 'TTPSetForInsightObjMDRelations';

                       permissionSetList = [SELECT Id, PermissionSetId,AssigneeId
                                            FROM PermissionSetAssignment
                                            WHERE (PermissionSet.Name =: strTelosTouch_Custom_Permission OR  PermissionSet.Name =: strTTPSetForInsightObjMDRelations)
                                            AND AssigneeId IN: listofUserId WITH SECURITY_ENFORCED LIMIT 2];
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
            HttpResponse response = http.send(request);
            if(response.getBody() != null){
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
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
            String strSalesforce = 'Salesforce';
            String str1 = '1';

               userList = [SELECT Id, userName, ProfileId, firstName,phone, lastName, Email,TelosTouchSF__TT_UserId__c,IsActive FROM User WHERE IsActive = true AND UserPermissionsMarketingUser = true AND Profile.UserLicense.Name =: strSalesforce AND TelosTouchSF__TT_UserId__c !=: str1 WITH SECURITY_ENFORCED LIMIT 5000 ];
           }
        userCredentialsWrapper getActiveUserWrapper= new userCredentialsWrapper();
        for(User user: userList){
            setProfileIds.add(user.ProfileId);
        }
        List<Profile > profileList = new List<Profile >();
        if(Schema.SObjectType.Profile.isAccessible() && Schema.SObjectType.Profile.isQueryable() &&
           Schema.sObjectType.Profile.fields.Id.isAccessible() &&
           Schema.sObjectType.Profile.fields.Name.isAccessible()){
               profileList = [SELECT Id,Name FROM Profile WHERE Id IN:setProfileIds WITH SECURITY_ENFORCED];
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
* @author Cloud Analogy
* @date 02/08/2021
* @description This method schedules all the jobs.
* @return string OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static string scheduleAllJobsFromHere(){
        if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
        try {
            List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
            if(Schema.sObjectType.AsyncApexJob.isAccessible() && Schema.sObjectType.AsyncApexJob.isQueryable() &&
               Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() &&
               Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() ){
                String strCompleted = 'Completed';
                String strBatchForBulkDataInsertOrUpdate = 'BatchForBulkDataInsertOrUpdate';
                String strGetTaskFromTTQueueable = 'GetTaskFromTTQueueable';
                String strGetCampaignsFromTTQueueable = 'GetCampaignsFromTTQueueable';

                   asyncApexJobList = [SELECT Id FROM AsyncApexJob WHERE Status =: strCompleted AND (ApexClass.Name =: strBatchForBulkDataInsertOrUpdate
                                                                                                   OR ApexClass.Name =: strGetTaskFromTTQueueable
                                                                                                   OR ApexClass.Name =: strGetCampaignsFromTTQueueable)
                                                                                                   WITH SECURITY_ENFORCED LIMIT 3];
               }
            if (asyncApexJobList.size() < 3) {
                Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(null, null, null, 'Contact', null, null, null));
            }
            List<CronJobDetail> jobList = new List<CronJobDetail>();
            List<CronJobDetail> jobList3 = new List<CronJobDetail>();
            List<CronJobDetail> jobList5 = new List<CronJobDetail>();
            List<CronJobDetail> jobList6 = new List<CronJobDetail>();
            String strDeleteLogRecords = 'Delete Log Records%';
            jobList = [SELECT Id FROM CronJobDetail Where Name LIKE :strDeleteLogRecords WITH SECURITY_ENFORCED];
            String strUpdateUserTokenJob = 'Update User Token Job%';
            jobList3 = [SELECT Id FROM CronJobDetail Where Name LIKE :strUpdateUserTokenJob WITH SECURITY_ENFORCED];
            String strGetClientsFromTTJob = 'Get Clients From TT Job%';
            jobList5 = [SELECT Id FROM CronJobDetail Where Name LIKE :strGetClientsFromTTJob WITH SECURITY_ENFORCED];
            String strSyncFeatureToggleJob = 'Sync Feature Toggle Job%';
            jobList6 = [SELECT Id FROM CronJobDetail Where Name LIKE :strSyncFeatureToggleJob WITH SECURITY_ENFORCED];
            if(jobList5.size() == 0){
                System.schedule('Get Clients From TT Job', '0 0 0/1 1/1 * ? *', new TelosTouchSF.GetClientsFromTTScheduler());
            }if(jobList3.size() == 0){
                if((Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600) > 0){
                    System.schedule('Update User Token Job 1', '0 0 0/'+String.valueOf(Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600)+' 1/1 * ? *', new TelosTouchSF.UpdateUserTokenScheduler());
                    System.schedule('Update User Token Job 2', '0 30 0/'+String.valueOf(Integer.valueOf(adminCredentials.TelosTouchSF__Access_Token_Expiration_Time__c) / 3600)+' 1/1 * ? *', new TelosTouchSF.UpdateUserTokenScheduler());
                }
            }if(jobList.size() == 0){
                System.schedule('Delete Log Records Job', '0 5 0 1/1 * ? *', new TelosTouchSF.Schedule_DeleteLogRecords());
            }
            if(jobList6.size() == 0){
                String chronJobId = '0 0 1 * * ? *';
                System.schedule('Sync Feature Toggle Job', chronJobId,  new TelosTouchSF.TT_ScheduleTelosTouchFeatureToggle());
                TelosTouchSF.TT_FeatureToggle inviteBatch= new TelosTouchSF.TT_FeatureToggle();
                Database.executeBatch(inviteBatch, 200);
            }
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
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
            List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
            Map<String,User> userMap = new Map<String,User>();
            List<String> ttClientIdList = new List<String>();
            List<User> userList = new List<User>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()
               && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible()){
                   userList = [SELECT Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c,TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c  != NULL AND isActive = true WITH SECURITY_ENFORCED];
               }
            for(User u : userList){
                userMap.put(u.id,u);
            }
            Integer deleted = 0, undeleted = 0;
            String endPointURL='',methodType = 'DELETE';
            Map<String, String> headersMap = new Map<String, String>();
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            if(createdcontactlist != null && createdcontactlist.size() >0){
            
                for(Contact contact : createdcontactlist){
                    if(String.isNotEmpty(contact.TelosTouchSF__TT_Client_Id__c)){
                        ttClientIdList.add(contact.TelosTouchSF__TT_Client_Id__c);
                    }
                }
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/contacts';
                    headersMap.put('Authorization', 'Bearer '+ authenticationCredentials.TelosTouchSF__Access_Token__c);
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');

                    if(!ttClientIdList.isEmpty()) {
                        Map<String, List<String>> jsonMap = new Map<String, List<String>>();
                        jsonMap.put('ids', ttClientIdList);
                        String body = JSON.serialize(jsonMap);
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
                }
            }
            else if(createdleadlist !=null && createdleadlist.size() >0){
                for(Lead lead : createdleadlist){
                    if(String.isNotEmpty(lead.TelosTouchSF__TT_Client_Id__c)){
                        ttClientIdList.add(lead.TelosTouchSF__TT_Client_Id__c);
                    }
                }
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    if(Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible()){
                        endPointURL =   adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v1/admin/contacts';
                    }
                    headersMap.put('Authorization', 'Bearer '+ authenticationCredentials.TelosTouchSF__Access_Token__c);
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
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
                }
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

            response = http.send(request);
            system.debug(LoggingLevel.DEBUG, 'response body TU::'+response.getBody());
            system.debug(LoggingLevel.DEBUG, 'response Status Code TU::'+response.getStatusCode());
        	responseMap.put('status_code', String.valueOf(response.getStatusCode()));
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
                   task = [SELECT Id,TelosTouchSF__Share_with_client_s__c FROM Task WHERE Id =: recordId WITH SECURITY_ENFORCED];
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
            String strBatchPostInstallScript = 'BatchPostInstallScript';
            String strCompleted = 'Completed';

               postInstallBatchList = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name =: strBatchPostInstallScript AND Status !=: strCompleted WITH SECURITY_ENFORCED limit 3];
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
            String strCompleted = 'Completed';
               asyncApexJobList = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name =:apexJob AND Status =: strCompleted WITH SECURITY_ENFORCED LIMIT 1];
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
        if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
        if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
        ClientInviteWrapper obj = (ClientInviteWrapper)JSON.deserialize(recordObject, ClientInviteWrapper.class);
        String endPointURL,body,userAuthTOKEN;
        Map<String, String> getResponse = new Map<String, String>();
        Map<String, String> getResponse2 = new Map<String, String>();
        Map<String, String> headersMap = new Map<String, String>();
        List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
        if(String.isNotBlank(authenticationCredentials.TelosTouchSF__Access_Token__c) ){
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
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
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
        if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
        if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
        if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.isQueryable() &&
           Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible() &&
           Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
               List<User> user = [SELECT Id,TelosTouchSF__Auth_Token__c,TelosTouchSF__TT_UserName__c FROM User WHERE Id=:UserInfo.getUserId() AND TelosTouchSF__TT_UserId__c != Null WITH SECURITY_ENFORCED];
               if( user != null && user.size() > 0  && authenticationCredentials.TelosTouchSF__Access_Token__c != null){
                   if(user.size()>0 && user[0].TelosTouchSF__Auth_Token__c != null ){
                       userAuthTOKEN = user[0].TelosTouchSF__Auth_Token__c;
                   }
               }
           }
        return userAuthTOKEN;
    }
           /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param ObjectNameParam ...
* @return Boolean ....
*/
    public static boolean isObjectExist(String ObjectNameParam){
        for (Schema.SObjectType sObjectTypeObj : Schema.getGlobalDescribe().values() ) {
            String sobjName = String.valueOf(sObjectTypeObj);
            if (sobjName.contains(ObjectNameParam) ) {
                return true;
            }
        }
        return false;
    }
      /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return Boolean ....
*/
    @AuraEnabled
    public static Boolean checkInviteFunctionality(){
        if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
        if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
        List<TelosTouchSF__TT_Log__c> logList = new List<TelosTouchSF__TT_Log__c>();
        Map<String, String> headersMap = new Map<String, String>();
        if(adminCredentials != null && String.isNotEmpty(authenticationCredentials.TelosTouchSF__Access_Token__c)){
            headersMap.put('Authorization','Bearer '+authenticationCredentials.TelosTouchSF__Access_Token__c);
            headersMap.put('Content-Type', 'application/json');
            headersMap.put('Accept', 'application/json');
            Map<String, String> getResponseMap = getResponse('GET', adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/preferences', headersMap, null);
            if(getResponseMap.containsKey('adminToken')){
                authenticationCredentials.TelosTouchSF__Access_Token__c = getResponseMap.get('adminToken');
                System.enqueueJob(new TelosTouchSF.UpdateCustomMetadataQueueable(adminCredentials, authenticationCredentials));
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
	
        /**	
* @author Cloud Analogy	
* @date 02/08/2021	
* @description used to fetch the campaign detail.	
* @param campSfId stores the campaign Id	
* @return String ....
*/
    @AuraEnabled
    public static String getCampaignDetails(Id campSfId){
        try{
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
            Set<Id> insightsIdSet = new Set<Id>();
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('campMemList', (Object) new List<Object>());
            if(String.isNotEmpty(authenticationCredentials.TelosTouchSF__Access_Token__c)){
                returnMap.put('accessTokenPresent', (Object)true);
            }else{
                returnMap.put('accessTokenPresent', (Object)false);
            }
            Campaign campObj = [SELECT Id, TelosTouchSF__TT_Campaign_Id__c, TelosTouchSF__TouchPoint_Template_Id__c,CreatedDate  FROM Campaign WHERE Id =: campSfId WITH SECURITY_ENFORCED LIMIT 1];
            if(campObj != null && campObj.CreatedDate !=null){
                returnMap.put('CreatedDate', (Object)campObj.CreatedDate);
            }
            if(campObj != null && String.isNotEmpty(campObj.TelosTouchSF__TT_Campaign_Id__c)){
                returnMap.put('synced', (Object)true);
                List<CampaignMember> campMemList = new List<CampaignMember>();
                List<CampaignMember> campMemReturnList = new List<CampaignMember>();
                Integer campMemCount = [SELECT count() FROM CampaignMember WHERE campaignId =: campObj.Id WITH SECURITY_ENFORCED ];
                returnMap.put('campMemberAmount', campMemCount);
                if(campMemCount == 0){
                    returnMap.put('campMemberPresent', (Object)false);
                }else{
                    returnMap.put('campMemberPresent', (Object)true);
                }
                campMemList = [SELECT Id, campaignId, contactId, leadId FROM CampaignMember WHERE campaignId =: campObj.Id WITH SECURITY_ENFORCED ];
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
                Integer campMemCount = [SELECT count() FROM CampaignMember WHERE campaignId =: campObj.Id WITH SECURITY_ENFORCED ];
                returnMap.put('campMemberAmount', campMemCount);
                if(campMemCount == 0){
                    returnMap.put('campMemberPresent', (Object)false);
                }else{
                    returnMap.put('campMemberPresent', (Object)true);
                }
                returnMap.put('synced', (Object)false);
                returnMap.put('actionRequired', (Object)false);
            }
	        if(String.isNotEmpty(campObj.TelosTouchSF__TouchPoint_Template_Id__c)){	
                returnMap.put('templateId', (Object)campObj.TelosTouchSF__TouchPoint_Template_Id__c);	
            }else{	
                returnMap.put('templateId', (Object)'');
            }
            if(returnMap.containsKey('actionRequired')){
                returnMap.put('openTouchPointModal', returnMap.get('actionRequired'));
            }
            String strBatchCreateInsightsForNewRecipients = 'BatchCreateInsightsForNewRecipients';
            String strBatchAddRecipientsIntoTouchPoint  = 'BatchAddRecipientsIntoTouchPoint';
            if(returnMap.containsKey('openTouchPointModal') && [SELECT count() FROM AsyncApexJob WHERE (ApexClass.Name =: strBatchCreateInsightsForNewRecipients OR ApexClass.Name =: strBatchAddRecipientsIntoTouchPoint)
                AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing') WITH SECURITY_ENFORCED ] > 0)
            {
                returnMap.put('openTouchPointModal', (Object)false);
            }
            return JSON.serialize(returnMap);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'exception::'+ex.getMessage() +'At line ::'+ex.getLineNumber());
            return null;
        }
    }
	
        /**	
* @author Cloud Analogy	
* @date 02/08/2021	
* @description used to add clients in the touchpoint.	
* @param campMemListStr stores the camapaignMember list	
* @return Boolean ...
*/	    
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
* @return boolean  ....
*/
    @AuraEnabled
    public static Boolean getInviteFlag(){
        try {
            String strInvite = 'Invite';
            TelosTouchSF__TT_Feature_Flag__mdt inviteRecord = [SELECT Id,MasterLabel ,TelosTouchSF__TT_Flag__c, TelosTouchSF__SF_Flag__c from TelosTouchSF__TT_Feature_Flag__mdt WHERE MasterLabel=: strInvite WITH SECURITY_ENFORCED LIMIT 1];
            if(inviteRecord.TelosTouchSF__TT_Flag__c && inviteRecord.TelosTouchSF__SF_Flag__c){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
      /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return AdminCredentialsWrapper  ....
*/
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
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @return Boolean  ....
*/
    @AuraEnabled
    public static Boolean checkIfEnterpriseClient(){
        try{
            
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
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
	            String respMessage = 'Response Status Code: '+res.getstatusCode()+' | Response Body: '+res.getBody();		
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
       /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param ex ...
* @param className ...
* @param classMethod ...
* @param recordId ...
*/
    public static void generateErrorLog(Exception ex, String className, String classMethod, String recordId){
        String aError = ex.getTypeName()+': '+ex.getMessage()+' '+className+'.'+classMethod+': line '+ex.getLineNumber();
        System.debug(logginglevel.ERROR, aError);
        if(TT_FeatureSettingsController.getFinestLogValue()){
	        aError = aError.abbreviate(254);
            Database.insert(SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', aError, recordId));
        }
    }
 /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param message ...
* @param className ...
* @param classMethod ...
* @param recordId ...
*/
    public static void generateLog(String message, String className, String classMethod, String recordId){
        String aMessage = className+'.'+classMethod+': '+message;
        System.debug(aMessage);
        if(TT_FeatureSettingsController.getFinestLogValue()){
            aMessage = aMessage.abbreviate(254);
            Database.insert(SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', aMessage, recordId));
        }
    }
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param userId ...
* @param listOfTTUser ...
* @return  map<String, String> ...
*/
    @AuraEnabled
    public static map<String, String> revokeUserAccess(String userId,List<Id> listOfTTUser)
    {
        map<String, String> mapResult = new map<String, String>();
        try {            
            if(userId != Null)
            {
                Database.executeBatch(new SFBatchToRevokeLicence(new list<Id>{userId}),1);
            }
            if(listOfTTUser.size()>0){
                Database.executeBatch(new SFBatchToRevokeLicence(listOfTTUser),20);
            }
            mapResult.put('status', 'success');
            return mapResult;
        } catch (Exception e) {
            String errorMessage = 'Exception '+e.getMessage()+' at line '+e.getLineNumber();
            system.debug(errorMessage);
            mapResult.put('status', 'error');
            mapResult.put('error', errorMessage);
            return mapResult;
        }
    }
    
    /**
* @author Charbel Dagher
* @date 19/07/2022
* @description This method calls the job to refresh the token
* @return string response
*/
    @AuraEnabled
    public static string refreshTokenController(){
        try {
            System.enqueueJob(new TelosTouchSF.UpdateUserTokenQueueable());
            return 'success';
        }catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
            return null;
        }
        
    }    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetch the touchpoint templates.
* @param recordId ...
* @return Campaign ...
*/
    @AuraEnabled
    public static Campaign getCampaignData(String recordId){
        try {
            
            Campaign camp = [SELECT Id,TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__TT_Last_Sync_Time__c,TelosTouchSF__Type__c 
                            FROM Campaign WHERE Id =: recordId  WITH SECURITY_ENFORCED LIMIT 1];
            if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
            return camp;
        } catch (Exception ex) {
            System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
            throw new AuraHandledException('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
    }
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetch the touchpoint templates.
* @param recordId ...
* @return String ...
*/
    @AuraEnabled
    public static string getTouchPointTemplates(String recordId){
        try {

            String conditions = '';

            if(String.isNotBlank(recordId)){
                Campaign camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: recordId WITH SECURITY_ENFORCED];
                if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
                conditions = '?type='+camp.TelosTouchSF__Type__c;
            }

            List<Map<String, String>> returnList = new List<Map<String, String>>();
            List<Object> responseList = new List<Object>();
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            if(authenticationCredentials == null){ authenticationCredentials = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata(); }
            String endPointURL ='', userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
            List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Map<String, String> headersMap = new Map<String, String>();
            if(userToken != null && String.isNotBlank(userToken) ){
                headersMap.put('Authorization','Bearer ' +userToken);
                headersMap.put('Accept', 'application/json');
                headersMap.put('Content-Type', 'application/json');
            }
            if(adminCredentials.TelosTouchSF__Instance_URL__c!= null && String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates'+conditions;
            } 
            Map<String, String> responseBody = TelosTouchSF.TelosTouchUtility.getResponse('GET', endPointURL, headersMap, null);
            if(responseBody.get('status_code') == '401'){
                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
            }else if(responseBody.get('status_code') == '500'){
                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
            }else{
                if(responseBody.get('status_code').length() > 0){
                    list<String> statusCodeList = responseBody.get('status_code').split('0');
                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBody.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBody.get('status_code'),1));
                    }
                }
            }
            if(responseBody.get('body') != null){
                responseList = (List<Object>)JSON.deserializeUntyped(responseBody.get('body'));
                for(Object obj : responseList){
                    Map<String, Object> responseMap = new Map<String, Object>();
                    responseMap = (Map<String, Object>) obj;
                    Map<String, String> returnMap = new Map<String, String>();
                    JSONParser parser = JSON.createParser( '{"t":"'+String.valueOf(responseMap.get('modified_at'))+'"}');
                    parser.nextToken();
                    parser.nextValue();
                    Datetime dt = DateTime.newInstance( parser.getDateTimeValue().getTime());
                    if(UserInfo.getLanguage().contains('en')){
                        if(responseMap.get('is_private') == true){
                            returnMap.put('label', String.valueOf(responseMap.get('name')) + ' : ' + dt.format('yyyy-MM-dd HH:mm:ss') + ' : 🔒');
                        }else{
                            returnMap.put('label', String.valueOf(responseMap.get('name')) + ' : ' + dt.format('yyyy-MM-dd HH:mm:ss'));
                        }
                    }else if(UserInfo.getLanguage().contains('fr')){
                        returnMap.put('label', String.valueOf(responseMap.get('name_fr')) + ' : ' + dt.format('yyyy-MM-dd HH:mm:ss'));
                    }
                    returnMap.put('value', String.valueOf(responseMap.get('id')));
                    returnMap.put('createdDate', String.valueOf(responseMap.get('created_at')));
                    returnMap.put('isPrivate', String.valueOf(responseMap.get('is_private')));
                    returnList.add(returnMap);
                }
            }
            if(!createListOfLog.isEmpty()){
                insert createListOfLog;
            }
            return JSON.serialize(returnList);
        } catch (Exception ex) {
            System.debug('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
            throw new AuraHandledException('Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint template Id in the campaign.
* @param campaignRecordId stores the campaign Id
* @param touchPointTemplateId   stores the touchpoint template id
* @return String ....
*/
    @AuraEnabled
    public static string setTouchPointTemplateId(Id campaignRecordId, String touchPointTemplateId){
        try {
            Campaign campObj = [SELECT Id, TelosTouchSF__TouchPoint_Template_Id__c FROM Campaign WHERE Id =: campaignRecordId WITH SECURITY_ENFORCED LIMIT 1];
            campObj.TelosTouchSF__TouchPoint_Template_Id__c = touchPointTemplateId;
            if (Schema.sObjectType.Campaign.isUpdateable() && Schema.sObjectType.Campaign.isAccessible()){
                update campObj;
            }
            return campObj.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint template Id in the campaign.
* @param campaignRecordId stores the campaign Id
* @return String ....
*/
    @AuraEnabled
    public static string getCurrentTemplateId(Id campaignRecordId){
        try {
            return [SELECT TelosTouchSF__TouchPoint_Template_Id__c FROM Campaign WHERE Id =: campaignRecordId WITH SECURITY_ENFORCED LIMIT 1].TelosTouchSF__TouchPoint_Template_Id__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param campaignSFId stores the campaign Id
* @param touchPointTemplateId   stores the touchpoint templateId
* @param isSynced   stores if the camapign is synced or not
* @return String ...
*/
    @AuraEnabled
    public static String sendTouchPointFromSF(String campaignSFId, String touchPointTemplateId, Boolean isSynced){
        try{
            if( !isSynced ){
                Campaign camp = [SELECT Id,TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Questions__c,TelosTouchSF__Type__c
                                 FROM Campaign WHERE Id=:campaignSFId WITH SECURITY_ENFORCED LIMIT 1];
                if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
                String methodType = 'POST';
                List<TelosTouchSF__TT_Log__c> createListOfLog = new List<TelosTouchSF__TT_Log__c>();
                String endPointURL;
                String getResponseClients;
                String userAuthTOKEN;
                Map<String, Object> bodyMap = new Map<String, Object>();
                bodyMap.put('all_recipients',(Object)false);
                bodyMap.put('other_id', (Object)campaignSFId);
                bodyMap.put('recipients', (Object)new List<Object>());
                bodyMap.put('template_id', (Object)touchPointTemplateId);
                Map<String, String> headersMap = new Map<String, String>();
                userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentUserTOKEN();
                headersMap.put('Authorization','Bearer '+userAuthTOKEN);
                headersMap.put('Content-Type', 'application/json');
                headersMap.put('Accept', 'application/json');
                if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
                if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c;
                    if(camp.TelosTouchSF__Type__c == 'email'){ endPointURL +='/api/v1/campaign/email/create'; }
                    else { endPointURL +='/api/v1/touchpoint/templateGraph/touchpoints'; }
                }
                Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, JSON.serialize(bodyMap));
                if(getResponseMap.get('status_code') == '200' && String.isNotEmpty(getResponseMap.get('body'))){
                    Map<String, Object> responseMap1 = (Map<String, Object>)JSON.deserializeUntyped(getResponseMap.get('body'));
                    Map<String, Object> responseMap2 = (Map<String, Object>) responseMap1.get('touchpoint');
                    if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isUpdateable() &&  
                        Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() && Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isCreateable() &&
                        Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isUpdateable() && camp!= null){
                            camp.TelosTouchSF__TT_Campaign_Id__c = (String) responseMap2.get('id');
                            camp.TelosTouchSF__Questions__c =  JSON.serialize(responseMap2.get('questions'));
                            update camp;
                    }
                }else if(getResponseMap.get('status_code') == '401'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié',1));
                }else if(getResponseMap.get('status_code') == '500'){
                    createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                }else if(getResponseMap.get('status_code').length() > 0){
                    list<String> statusCodeList = getResponseMap.get('status_code').split('0');
                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1));
                    }
                }
                if(!createListOfLog.isEmpty()){
                    insert createListOfLog;
                }
                if(camp != null){
                    List<CampaignMember> campaignMembers = [ SELECT ContactId, Contact.TelosTouchSF__TT_Client_Id__c, LeadId, Lead.TelosTouchSF__TT_Client_Id__c, CampaignId,
                                                                        Lead.Phone FROM CampaignMember WHERE (CampaignId=:camp.Id) WITH SECURITY_ENFORCED LIMIT 44999];
                    CampMemberNotAddInCampHandler.addRecipientsIntoTouchPoint(campaignMembers);
                }
            }
            return 'success';
        }catch(Exception ex){
            return ('error#'+ex.getMessage());
        }
    }

        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to savE the touchpoint.
* @param templateId stores the touchpoint template Id
* @param campaignId stores the touchpoint template Id
* @param templateInfo stores the touchpoint template Id
* @return String ....
*/
    @AuraEnabled
    public static String generateCustomizeIFrame(String templateId, String campaignId, String templateInfo){
        try {

            Campaign camp = new Campaign();
            if(String.isNotBlank(campaignId)){ 
                camp = [SELECT TelosTouchSF__Type__c FROM Campaign WHERE Id =: campaignId WITH SECURITY_ENFORCED LIMIT 1];
                if(camp.TelosTouchSF__Type__c == null){ camp.TelosTouchSF__Type__c = 'touchpoint'; }
            }
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c 
                          FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

            Boolean isCopy = false;
            if(String.isNotBlank(templateInfo)){
                map<String,Object> mapTempInfo = (map<String,Object>) JSON.deserializeUntyped(templateInfo);
                if(mapTempInfo.containsKey('status')){
                    String status = (String) mapTempInfo.get('status');
                    isCopy |= (status.toLowerCase() == 'sent');
                } 
                if(!isCopy && mapTempInfo.containsKey('created_by')){
                    String createdBy = (String) mapTempInfo.get('created_by');
                    isCopy |= (createdBy != aUser.TelosTouchSF__TT_UserId__c);
                }
            }

            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
            String userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
            String iFrameURL;

            if(String.isNotBlank(campaignId) && camp.TelosTouchSF__Type__c == 'email'){
                iFrameURL = adminCredentials.TelosTouchSF__Instance_URL__c + '/app/v1/#/email/edit/' + templateId + '?fullscreen=true&access_token=' + userToken;
            } else {
                if(isCopy){
                    String endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/'+templateId+'/copy';

                    Map<String, String> mapHeader = new Map<String, String>();
                    mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
                    mapHeader.put('Content-Type', 'application/json');
                    mapHeader.put('Accept', 'application/json');
        
                    Map<String, String> mapResponse = getResponse('PUT', endPointURL, mapHeader, null);

                    if(mapResponse.get('status_code') != '200'){
                        throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
                    } else {
                        String responseBody = mapResponse.get('body');
                        map<String,Object> mapResponseBody = (map<String,Object>)JSON.deserializeUntyped(responseBody);
                        templateId = (String)mapResponseBody.get('id');
                        camp.TelosTouchSF__TouchPoint_Template_Id__c = templateId;
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/publish/'+templateId;
                        Map<String, String> mapResponse2 = getResponse('PUT', endPointURL, mapHeader, null);

                        if(mapResponse.get('status_code') != '200'){
                            throw new AuraHandledException('Response Code 2: '+mapResponse2.get('status_code'));
                        } else {
                            update camp;
                        }
                    } 

                }
                iFrameURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/app/v1/#/touchpoint/'+templateId+'/customize-sf?fullscreen=true&access_token='+userToken;
            }

            if(UserInfo.getLanguage().contains('en')){
                iFrameURL += '&lang=en_US';
            }else if(UserInfo.getLanguage().contains('fr')){
                iFrameURL += '&lang=fr_FR';
            }
            return iFrameURL;
        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TelosTouchUtility', 'generateCustomizeIFrame', null);
            return null;
        }
    }

        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description used to fetch the touchpoint template.
* @param recordId stores the campaign  Id
* @return String ....
*/    
    @AuraEnabled
    public static String fetchSelectedTouchPointTemplate(String recordId){
        try {
            Campaign camp = [SELECT Id, TelosTouchSF__TouchPoint_Template_Id__c, TelosTouchSF__Type__c
                                FROM Campaign WHERE Id =: recordId LIMIT 1];
            
            if(String.isBlank(camp.TelosTouchSF__TouchPoint_Template_Id__c)){ return null; }
            
            TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchUtility.getCustomMetadata();
            TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchUtility.getAuthenticationCustomMetadata();
            String endpoint;
            map<String, String> mapHeader = new map<String, String>();
            String templateName;

            if(camp.TelosTouchSF__Type__c == 'email'){
                endpoint = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/templates/'+camp.TelosTouchSF__TouchPoint_Template_Id__c;
            } else {
                endpoint = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoint/templateGraph/'+camp.TelosTouchSF__TouchPoint_Template_Id__c;
            }

            mapHeader.put('Authorization', 'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            map<String, String> mapResponse = TelosTouchUtility.getResponse('GET',endpoint,mapHeader,null);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){
                map<String,Object> mapBody = (map<String,Object>) JSON.deserializeUntyped(mapResponse.get('body'));
                if(mapBody.containsKey('deleted') && (Boolean)mapBody.get('deleted')){
                    camp.TelosTouchSF__TouchPoint_Template_Id__c = null;
                    update camp;
                    return null;
                } else {
                    return mapResponse.get('body');
                }
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }
            
        } catch (Exception e) {
            System.debug('Error is:'+ e.getMessage()+' at line no: '+ e.getLineNumber());
            return null;
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description syncClientsBeforeTouchpoint ....
* @param campaignId stores the campaign  Id
*/ 
    @AuraEnabled
    public static void syncClientsBeforeTouchpoint(String campaignId){
        try {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            for(CampaignMember cmObj: [SELECT ContactId, LeadId FROM CampaignMember WHERE CampaignId =: campaignId AND (Contact.TelosTouchSF__TT_Needs_Sync__c = true OR Lead.TelosTouchSF__TT_Needs_Sync__c = true) WITH SECURITY_ENFORCED]){
                if(cmObj.ContactId != null){
                    contactIds.add(cmObj.ContactId);
                }else{
                    leadIds.add(cmObj.LeadId);
                }
            }
            Set<String> setFields = new Set<String>{
                'TelosTouchSF__Language__c',
                'TelosTouchSF__Source__c',
                'TelosTouchSF__Subscribed__c',
                'TelosTouchSF__TT_Client_Id__c'
            };
            List<Contact> conList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            if(contactIds.size() > 0){
                String query = 'SELECT Owner.TelosTouchSF__TT_UserName__c, Owner.TelosTouchSF__TT_UserId__c, Owner.TelosTouchSF__Auth_Token__c,';
                String strContact ='Contact';
                String strAccountId = 'AccountId';
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable()){
                    for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                            FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                            WHERE TelosTouchSF__Object_Name__c =: strContact 
                                                                            AND TelosTouchSF__Salesforce_Field__c !=: strAccountId WITH SECURITY_ENFORCED])
                    {
                        setFields.add(fieldAPI.TelosTouchSF__Salesforce_Field__c);
                    }
                }
                query += String.join(new List<String>(setFields), ',');
                query = query.removeEnd(',');
                query += ' FROM Contact WHERE Id IN: contactIds';
                query = query.removeEnd('WHERE');
                query = query.removeEnd('AND');
                conList = Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            }
            if(leadIds.size() > 0){
                String query = 'SELECT Owner.username, Owner.id, Status, ';
                String strContact ='Lead';
                String strAccountId = 'AccountId';
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isQueryable()){
                    for(TelosTouchSF__TT_Salesforce_Mapping__c fieldAPI : [SELECT Id, TelosTouchSF__Salesforce_Field__c 
                                                                            FROM TelosTouchSF__TT_Salesforce_Mapping__c 
                                                                            WHERE TelosTouchSF__Object_Name__c =: strContact 
                                                                            AND TelosTouchSF__Salesforce_Field__c !=: strAccountId WITH SECURITY_ENFORCED])
                    {
                        setFields.add(fieldAPI.TelosTouchSF__Salesforce_Field__c);
                    }
                }
                query += String.join(new List<String>(setFields), ',');
                query = query.removeEnd(',');
                query += ' FROM Lead WHERE Id IN: leadIds AND IsConverted = false';
                query = query.removeEnd('WHERE');
                query = query.removeEnd('AND');
                leadList = Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
            }
            if(!conList.isEmpty() || !leadList.isEmpty()){
                TelosTouchSF.SFDataSyncWithTelosTouch.updateContactDetails(!conList.isEmpty() ? conList : null, !leadList.isEmpty() ? leadList : null, null, null, null, null);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error is: '+ e.getMessage() + ' at line no: '+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
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
                      /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        @AuraEnabled
        public String Team_Name {get; set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description  constructor for initializing the values.
*/
        public AdminCredentialsWrapper(){
            if(adminCredentials == null){ adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata(); }
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