/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
public with sharing class TelosTouchWrapperUtils {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class userSignInWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public user user { get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class TT_CreatedContactRecord {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdAt { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean doNotCall { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modifiedAt { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String phoneNumber { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String emailAddress { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String position { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String title { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean incorporated { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String accountId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean businessOwner { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String lastName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isDummyAccount { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String firstName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdById { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String salutationName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean deleted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isFollowed { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id { get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class user{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String contactName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressStreet { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressCity { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String gender { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String token { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String phoneNumber { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String read { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String emailAddress { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String edit { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String title { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isSuperAdmin { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isPortalUser { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isActive { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String lastName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String firstName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String salutationName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String password { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String userName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isAdmin { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean deleted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id { get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class getClientWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String integrationId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String countryOfResidence { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String locationOfIncomeTaxFiling { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String citizenship { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String corporateTaxID { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String languagePreference { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String integrationType { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String sINNumber { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String integrationSource { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String otherPhone { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String companyName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String faxNumber { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isDummyAccount { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String birthdayUpcoming { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String inviteStatus { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String notes { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String language { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String firmAnniversary { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String incomeCurrency { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String interests { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String mobilePhone { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String spouseName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String businessPhone { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String weddingAnniversary { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String retirement { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String occupation { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String yearsInCanada { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String accountName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String age { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean businessOwner { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean incorporated { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String income { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String campaignId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String position { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String campaignName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String interestsHobbies { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdById { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String drinkPreference { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdByName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String birthday { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modifiedById { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modifiedByName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String lastLoginDate { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modifiedAt { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assignedUserName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String createdAt { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String accountType { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressPostalCode { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String portalUserId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressCountry { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String portalUserName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressState { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String originalLeadId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressCity { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String originalLeadName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String addressStreet { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String incomeConverted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean doNotCall { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String defaultTeamId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String phoneNumber { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String defaultTeamName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String emailAddress { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String userId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String description { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String userName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String title { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean isFollowed { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String accountId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String lastName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String firstName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String salutationName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String avatarName { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean deleted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String avatarId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id { get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
    public class checkClientInviteWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled public String  returnMessage { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled public sobject recordObj { get; set; }
    }
    /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ...
 */
    public class getConversationMessagesWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String resource_url { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean deleted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String sent_by { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String type { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String created_by { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean is_robot { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modified_by { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_step_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modified_at { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_action_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String created_at { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String content { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String conversation_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id { get;set;}
    }
    /**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description ...
  */
    public class salesforceCamapaignWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String returnMessage { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String inviteMessage { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public Campaign campaignObject { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public String CampId { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        @AuraEnabled
        public List<String> clientIds { get;set;}
    }
    /**
 * @author Cloud Analogy
 * @date 02/08/2021
 * @description ...
 */
    public class TaskSyncWithTTWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_send_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assigned_user_name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_send_name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String assigned_user_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String touchpoint_send_name_fr { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String created_by_name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String default_team_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String created_by_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean shared { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String description { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String instance { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String client_name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public Boolean deleted { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String client_id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String date_due { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String status { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String completed_at { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String type { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String modified_at { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String name { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String created_at { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String id { get;set;}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
*/
        public String other_id { get;set;}
    }
}