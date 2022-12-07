/**
* @author Cloud Analogy
* @date 02/08/2021
* @description GetClientsFromTTQueueable class is used to get clients within last 2 hours from TT and insert those reocords in SF.
*/
global with sharing class GetClientsFromTTQueueable implements Queueable, Database.AllowsCallouts{
    
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    global String message;
    global integer totalSyncedUser = 0;
    public Integer startPoint;
    public Integer endPoint;
    public Integer NumberOfRecords;
    public boolean forFirstTime;
    public String syncObject;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param startPoint ...
* @param endPoint ......
* @param NumberOfRecords ...
* @param forFirstTime ......
* @param syncObject ......
*/
    public GetClientsFromTTQueueable(Integer startPoint, Integer endPoint, Integer NumberOfRecords,boolean forFirstTime, String syncObject){
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.NumberOfRecords = NumberOfRecords;
        this.forFirstTime = forFirstTime;
        this.syncObject = syncObject;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ...
*/
    global void execute(QueueableContext context){
        try{
            Integer ownerNotFoundCount = 0;
            Set<String> convertedLeadIdSet = new Set<String>();
            Set<String> setTTid = new Set<String>();
            Set<String> emailSet = new Set<String>();
            Set<String> setOfMoreThanOneEmail = new Set<String>();
            Set<String> setTTEmailId = new Set<String>();
            Set<Id> setSFId = new Set<Id>();
            Set<String> setTTEmailDuplicate = new Set<String>();
            Map<String, String> headersMap = new Map<String, String>();
            Map<String,Lead> leadMap = new Map<String,Lead>();
            Map<String,Contact> contactMap = new Map<String,Contact>();
            Map<String,Contact> contactMapEmailVsObj = new Map<String,Contact>();
            Map<String,Lead> leadMapEmailVsObj = new Map<String,Lead>();
            List<Contact> contactList = new List<Contact>();
            List<Lead> leadList = new List<Lead>();
            List<Contact> contactupsertList = new List<Contact>();
            List<Lead> leadupdateList = new List<Lead>();
            List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            List<ResponseWrapper> resdata = new List<ResponseWrapper>();
            List<ResponseWrapper> resdata1 = new List<ResponseWrapper>();
			Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();

            List<TelosTouchSF__TT_Salesforce_Mapping__c> telosTouchMappingList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isQueryable() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isAccessible() &&
                    Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Is_Sync_Empty_Field__c.isAccessible()){
                telosTouchMappingList = [SELECT Id, TelosTouchSF__Salesforce_Field__c, TelosTouchSF__TT_Field__c, TelosTouchSF__Object_Name__c, TelosTouchSF__Is_Sync_Empty_Field__c FROM TelosTouchSF__TT_Salesforce_Mapping__c WHERE TelosTouchSF__Object_Name__c IN ('Contact', 'Lead') AND TelosTouchSF__Is_Deleted__c = false LIMIT 1000];
            }
            Map<String, Id> userMap = new Map<String, Id>();
            for(User userObj : [SELECT Id, TelosTouchSF__TT_UserId__c FROM User WHERE TelosTouchSF__TT_UserId__c!=null AND IsActive=true WITH SECURITY_ENFORCED LIMIT 2000]){
                userMap.put(userObj.TelosTouchSF__TT_UserId__c, userObj.Id);
            }
            Map<String, TelosTouchSF__TT_Salesforce_Mapping__c> TTContactFieldsMap = new Map<String, TelosTouchSF__TT_Salesforce_Mapping__c>();
            Map<String, TelosTouchSF__TT_Salesforce_Mapping__c> TTLeadFieldsMap = new Map<String, TelosTouchSF__TT_Salesforce_Mapping__c>();

            Map <String, Schema.SObjectType> schemaMapofAllSobject = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> MapofContactObj = schemaMapofAllSobject.get('Contact').getDescribe().fields.getMap();
            List<String> ContactFieldApiNameList = new List<String>();
            for(Schema.SObjectField sObjectfield : MapofContactObj.Values())
                {
                    schema.describefieldresult dfield = sObjectfield.getDescribe();
                    ContactFieldApiNameList.add(dfield.getname());
                }
            Map <String, Schema.SObjectField> MapofLeadtObj = schemaMapofAllSobject.get('Lead').getDescribe().fields.getMap();
            List<String> LeadFieldApiNameList = new List<String>();
            for(Schema.SObjectField sObjectfield : MapofLeadtObj.Values())
                {
                    schema.describefieldresult dfield = sObjectfield.getDescribe();
                    LeadFieldApiNameList.add(dfield.getname());
                }
            if(telosTouchMappingList != null && telosTouchMappingList.size() >0){
                for(TelosTouchSF__TT_Salesforce_Mapping__c mappingObj : telosTouchMappingList){
                    if(mappingObj.TelosTouchSF__Object_Name__c == 'Contact'){
                        TTContactFieldsMap.put(mappingObj.TelosTouchSF__TT_Field__c,mappingObj);
                    }
                    else if(mappingObj.TelosTouchSF__Object_Name__c == 'Lead'){
                        TTLeadFieldsMap.put(mappingObj.TelosTouchSF__TT_Field__c,mappingObj);
                    }
                }
            }
            String methodType = 'GET',endPointURL = '',responseBody;
            DateTime LAST_HOUR = System.NOW().addMinutes(-62);
            String formatted = LAST_HOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            headersMap.put('Content-Type', 'application/json');
            if(String.isNotBlank(adminCredentials.TelosTouchSF__Instance_URL__c) ){
                headersMap.put('Accept', 'application/json');
                for(Integer i=startPoint;i<endPoint;i=i+200){
                    try {
                        if (forFirstTime == true) {
                            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c +
                                    '/api/v1/admin/contacts?deleted=false&skip=' + i + '&limit=200';
                        } else {
                            endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c +
                                    '/api/v1/admin/contacts?deleted=false&modified_at={">=":"' + formatted +
                                    '"}&skip=' + i + '&limit=200';
                        }
                        if (authenticationCredential.TelosTouchSF__Access_Token__c != null) {
                            headersMap.put('Authorization', 'Bearer ' + authenticationCredential.TelosTouchSF__Access_Token__c);
                            Map<String, String> responseBodyMap =
                                    TelosTouchUtility.getResponse(methodType, endPointURL, headersMap, null);
                            if (responseBodyMap.get('status_code') == '401') {
                                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure',
                                        'User Could Not be Authenticated', 'L\'usager n\'a pu être identifié', 1));
                            }else if(responseBodyMap.get('status_code') == '500'){
                                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Internal Server Error', 'Erreur de serveur interne',1));
                            }else{
                                if(responseBodyMap.get('status_code').length() > 0){
                                    list<String>StatusCodeList = responseBodyMap.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Something went wrong. Status Code: '+responseBodyMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+responseBodyMap.get('status_code'),1));
                                    }
                                }
                            }
                            responseBody = responseBodyMap.get('body');
                        }
                        if (responseBody != null && responseBody.contains('id')) {
                            resdata =
                            (List<ResponseWrapper>) System.JSON.deserialize(responseBody, List<ResponseWrapper>.class);
                            resdata1.addAll(resdata);
                        } else {
                            break;
                        }
                    }catch(Exception ex){
                        System.debug(LoggingLevel.ERROR,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
                    }
                }
            }
            if(resdata1.size() > 0){
                for(Integer i=0; i< resdata1.size(); i++){
                    setTTid.add(resdata1[i].id);
                    setTTEmailId.add(resdata1[i].email);
                }
                String contactQuery = 'SELECT id,FirstName,LastName,Phone,TelosTouchSF__Language__c,TelosTouchSF__Source__c,TelosTouchSF__Subscribed__c,TelosTouchSF__TT_Client_Id__c,Email,LastModifiedDate,TelosTouchSF__TT_Last_Login__c,TelosTouchSF__TT_UserId__c';
                String contactQuery2 = contactQuery;
                contactQuery += ' FROM Contact WHERE (IsDeleted = false) AND (TelosTouchSF__TT_Client_Id__c IN: setTTid) ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST LIMIT 1600 ALL ROWS';
                contactQuery2 += ' FROM Contact WHERE (IsDeleted = false) AND (Email =:setTTEmailId) ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST LIMIT 1600 ALL ROWS';
                contactList = Database.query(contactQuery);
                contactList.addAll((List<Contact>)Database.query(contactQuery2));
                String leadQuery = 'SELECT id,FirstName,LastName,Phone,TelosTouchSF__Language__c,TelosTouchSF__Source__c,TelosTouchSF__Subscribed__c,TelosTouchSF__TT_Client_Id__c,Email,LastModifiedDate,TelosTouchSF__TT_Last_Login__c,TelosTouchSF__TT_UserId__c';
                String leadQuery2 = leadQuery;
                leadQuery += ' FROM Lead WHERE (IsDeleted = false) AND (TelosTouchSF__TT_Client_Id__c IN: setTTid) ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST LIMIT 1600 ALL ROWS';
                leadQuery2 += ' FROM Lead WHERE (IsDeleted = false) AND (Email =:setTTEmailId) ORDER BY TelosTouchSF__TT_Client_Id__c NULLS LAST LIMIT 1600 ALL ROWS';
                if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isQueryable() &&
                        Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                        Schema.sObjectType.Lead.fields.Email.isAccessible() &&  Schema.sObjectType.Lead.fields.FirstName.isAccessible() &&
                        Schema.sObjectType.Lead.fields.LastName.isAccessible() && Schema.sObjectType.Lead.fields.Phone.isAccessible() &&
                        Schema.sObjectType.Lead.fields.TelosTouchSF__Language__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__Subscribed__c.isAccessible() &&
                        Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Last_Login__c.isAccessible() && Schema.sObjectType.Lead.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
                    leadList = Database.query(leadQuery);
                    leadList.addAll((List<Lead>)Database.query(leadQuery2));
                }
                if(contactList.size() > 0){
                    for(Contact conObj : contactList){
                        if(conObj.TelosTouchSF__TT_Client_Id__c != null){
                            contactMap.put(conObj.TelosTouchSF__TT_Client_Id__c, conObj);
                            if(emailSet.contains(conObj.Email)){
                                contactMap.remove(conObj.Email);
                            }
                            contactMapEmailVsObj.put(conObj.Email, conObj);
                            emailSet.add(conObj.Email);
                        }else{
                            if(!emailSet.contains(conObj.Email)){
                                contactMap.put(conObj.Email, conObj);
                            }
                            emailSet.add(conObj.Email);
                        }
                    }
                }
                if(leadList.size() > 0){
                    for(Lead leadObj : leadList){
                        if(leadObj.TelosTouchSF__TT_Client_Id__c != null){
                            leadMap.put(leadObj.TelosTouchSF__TT_Client_Id__c, leadObj);
                            if(emailSet.contains(leadObj.Email)){
                                leadMap.remove(leadObj.Email);
                            }
                            leadMapEmailVsObj.put(leadObj.Email, leadObj);
                            emailSet.add(leadObj.Email);
                        }else{
                            if(!emailSet.contains(leadObj.Email)){
                                leadMap.put(leadObj.Email, leadObj);
                            }
                            emailSet.add(leadObj.Email);
                        }
                    }
                }
                for(ResponseWrapper obj1 : resdata1){
                    String notificationValue,email,first_name,last_name,language,phone,sfLastLoginDetail,formattedDate;
                    Datetime last_login_date,sFLastLoginDate;
                    Datetime dt = (DateTime)JSON.deserialize('"' + obj1.modified_at + '"', DateTime.class);
                    if((contactMap.containskey(obj1.id) && contactMap.get(obj1.id) != null) || (contactMap.containskey(obj1.email) && contactMap.get(obj1.email) != null)){
                        if((contactMap.containskey(obj1.id) && contactMap.get(obj1.id).LastModifiedDate.getTime() < dt.getTime()) || (contactMap.containskey(obj1.email) && contactMap.get(obj1.email).LastModifiedDate.getTime() < dt.getTime())){
                            Contact contact = new Contact();
                            if(contactMap.containskey(obj1.id) ){
                                contact = contactMap.get(obj1.id);
                            }else if((contactMap.containskey(obj1.email)) && (!setOfMoreThanOneEmail.contains(obj1.email))){
                                contact = contactMap.get(obj1.email);
                                setOfMoreThanOneEmail.add(obj1.email);
                            }
                            if(contact.Id != null && (!setSFId.contains(contact.Id))){
                                setSFId.add(contact.Id);
                                if(obj1.preferences.notificationTouchpointSend == false){
                                    notificationValue = 'No';
                                }else{
                                    notificationValue = 'Yes';
                                }if(contact.Email == null){
                                    email = '';
                                }else{
                                    email = contact.Email;
                                }
                                if(contact.FirstName == null){
                                    first_name = '';
                                }else{
                                    first_name = contact.FirstName;
                                }
                                if(contact.LastName == null){
                                    last_name = '';
                                }else{
                                    last_name = contact.LastName;
                                }
                                if(contact.TelosTouchSF__Language__c == null){
                                    language = '';
                                }else if(contact.TelosTouchSF__Language__c == 'English'){
                                    language = 'en_US';
                                }else if(contact.TelosTouchSF__Language__c == 'French'){
                                    language = 'fr_FR';
                                }
                                if(contact.Phone == null){
                                    phone = '';
                                }else{
                                    phone = contact.Phone;
                                }
                                if(obj1.invited_at != null ){
                                    sfLastLoginDetail = contact.TelosTouchSF__TT_Last_Login__c;
                                    contact.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        if(contact.TelosTouchSF__TT_Last_Login__c != null && contact.TelosTouchSF__TT_Last_Login__c != System.Label.After_TT_invite && contact.TelosTouchSF__TT_Last_Login__c != System.Label.Not_Invite){
                                            sFLastLoginDate = getDateFormate(contact.TelosTouchSF__TT_Last_Login__c);
                                        }
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        contact.TelosTouchSF__TT_Last_Login__c = formattedDate;

                                    }else{
                                        contact.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                if(first_name != obj1.first_name || last_name != obj1.last_name ||
                                                phone != obj1.phone || language != obj1.preferences.language ||
                                                notificationValue != contact.TelosTouchSF__Subscribed__c || email != obj1.email){
                                    if(TTContactFieldsMap.containskey('email')){
                                        System.debug(LoggingLevel.DEBUG,'email');
                                    }
                                    contact.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                    if(TTContactFieldsMap.containskey('first_name')){
                                        System.debug(LoggingLevel.DEBUG,'first_name');
                                    }
                                    if(TTContactFieldsMap.containskey('last_name')){
                                        System.debug(LoggingLevel.DEBUG,'last_name');
                                    }
                                    if(TTContactFieldsMap.containskey('phone')){
                                        if(obj1.phone != ''){
                                            System.debug(LoggingLevel.DEBUG,'phone');
                                        }else if(obj1.phone == '' && TTContactFieldsMap.get('phone').TelosTouchSF__Is_Sync_Empty_Field__c == true){
                                            System.debug(LoggingLevel.DEBUG,'phone in else condition');
                                        }
                                    }
                                    if(TTContactFieldsMap.containskey('subscribed')){
                                        if(notificationValue != null){
                                            contact.put(TTContactFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , notificationValue);
                                        }
                                        else if(notificationValue == null && TTContactFieldsMap.get('subscribed').TelosTouchSF__Is_Sync_Empty_Field__c == true){
                                            contact.put(TTContactFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , null);
                                        }
                                    }
                                    if(TTContactFieldsMap.containskey('language')){
                                        if(obj1.preferences.language == null || obj1.preferences.language == 'en_US'){
                                            System.debug(LoggingLevel.DEBUG,'english language');
                                        }else if(obj1.preferences.language != null && obj1.preferences.language == 'fr_FR'){
                                            System.debug(LoggingLevel.DEBUG,'french language');
                                        }
                                    }
                                    contact.TelosTouchSF__TT_Conflict__c = false;
                                    contact.TelosTouchSF__Error_Message__c = '';
                                    contactupsertList.add(contact);
                                }else{
                                    if((obj1.last_login_date != null && sfLastLoginDetail == System.Label.After_TT_invite) || (sfLastLoginDetail == null && ((obj1.last_login_date != null) || (obj1.invited_at != null)))
                                            || (last_login_date != null && sFLastLoginDate != null && last_login_date.getTime()  > sFLastLoginDate.getTime())){
                                        contactupsertList.add(contact);
                                    }
                                }
                            }else{
                                if(contactMap.containskey(obj1.email)){
                                    contact = contactMap.get(obj1.email);
                                }if(contact != null && (!setSFId.contains(contact.Id))){
                                    contact.TelosTouchSF__Error_Message__c = 'Duplicate Email';
                                    if(contact.TelosTouchSF__Source__c == null){
                                        contact.TelosTouchSF__Source__c = 'Salesforce';
                                    }
                                    if(contact.TelosTouchSF__Subscribed__c == null){
                                        contact.TelosTouchSF__Subscribed__c = 'Yes';
                                    }
                                    if(contact.TelosTouchSF__Language__c == null){
                                        contact.TelosTouchSF__Language__c = 'English';
                                    }
                                    contactupsertList.add(contact);
                                }
                                setSFId.add(contact.Id);
                                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Duplicate:'+' '+obj1.email,'Doublon:'+' '+obj1.email,1));
                            }
                        }else if(contactMap.containskey(obj1.email) && contactMap.get(obj1.email) != null){
                            Contact contact = new Contact();
                            contact = contactMap.get(obj1.email);
                            if(!setSFId.contains(contact.Id)){
                                if(contact.TelosTouchSF__Source__c == null){
                                    contact.TelosTouchSF__Source__c = 'Salesforce';
                                }
                                if(contact.TelosTouchSF__Subscribed__c == null){
                                    contact.TelosTouchSF__Subscribed__c = 'Yes';
                                }
                                if(contact.TelosTouchSF__Language__c == null){
                                    contact.TelosTouchSF__Language__c = 'English';
                                }
                                contact.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                contact.TelosTouchSF__Error_Message__c = '';
                                if(obj1.invited_at != null ){
                                    contact.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        contact.TelosTouchSF__TT_Last_Login__c = formattedDate;

                                    }else{
                                        contact.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                contact.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                contactupsertList.add(contact);
                            }
                            setSFId.add(contact.Id);
                        }
                    }else if((leadMap.containskey(obj1.id) && leadMap.get(obj1.id) != null) || (leadMap.containskey(obj1.email) && leadMap.get(obj1.email) != null)){
                        if((leadMap.containskey(obj1.id) && leadMap.get(obj1.id).LastModifiedDate.getTime() < dt.getTime()) || (leadMap.containskey(obj1.email) && leadMap.get(obj1.email).LastModifiedDate.getTime() < dt.getTime())){
                            Lead leadObject = new Lead();
                            if(leadMap.containskey(obj1.id) && (obj1.type == 'client' || obj1.type == 'expert' || obj1.type == 'other')){
                                leadObject = leadMap.get(obj1.id);
                                convertedLeadIdSet.add(leadObject.id);
                            }
                            if(leadMap.containskey(obj1.id)  && obj1.type == 'lead'){
                                leadObject = leadMap.get(obj1.id);
                            }else if((leadMap.containskey(obj1.email)) && (!setOfMoreThanOneEmail.contains(obj1.email))){
                                leadObject = leadMap.get(obj1.email);
                                setOfMoreThanOneEmail.add(obj1.email);
                            }
                            if(leadObject.Id != null && (!setSFId.contains(leadObject.Id))){
                                setSFId.add(leadObject.Id);
                                if(obj1.preferences.notificationTouchpointSend == false){
                                    notificationValue = 'No';
                                }else{
                                    notificationValue = 'Yes';
                                }if(leadObject.Email == null){
                                    email = '';
                                }else{
                                    email = leadObject.Email;
                                }
                                if(leadObject.FirstName == null){
                                    first_name = '';
                                }else{
                                    first_name = leadObject.FirstName;
                                }
                                if(leadObject.LastName == null){
                                    last_name = '';
                                }else{
                                    last_name = leadObject.LastName;
                                }
                                if(leadObject.TelosTouchSF__Language__c == null){
                                    language = '';
                                }else if(leadObject.TelosTouchSF__Language__c == 'English'){
                                    language = 'en_US';
                                }else if(leadObject.TelosTouchSF__Language__c == 'French'){
                                    language = 'fr_FR';
                                }
                                if(leadObject.Phone == null){
                                    phone = '';
                                }else{
                                    phone = leadObject.Phone;
                                }
                                if(obj1.invited_at != null ){
                                    sfLastLoginDetail = leadObject.TelosTouchSF__TT_Last_Login__c;
                                    leadObject.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        if(leadObject.TelosTouchSF__TT_Last_Login__c != null && leadObject.TelosTouchSF__TT_Last_Login__c != System.Label.After_TT_invite && leadObject.TelosTouchSF__TT_Last_Login__c != System.Label.Not_Invite){
                                            sFLastLoginDate = getDateFormate(leadObject.TelosTouchSF__TT_Last_Login__c);
                                        }
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        leadObject.TelosTouchSF__TT_Last_Login__c = formattedDate;
                                    }else{
                                        leadObject.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                if(first_name != obj1.first_name || last_name != obj1.last_name ||
                                                phone != obj1.phone || language != obj1.preferences.language ||
                                                notificationValue != leadObject.TelosTouchSF__Subscribed__c || email != obj1.email ){
                                    leadObject.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                    if(TTLeadFieldsMap.containskey('first_name')){
                                        System.debug(LoggingLevel.DEBUG,' lead first_name');
                                    }
                                    if(TTLeadFieldsMap.containskey('last_name')){
                                        System.debug(LoggingLevel.DEBUG,' lead last_name');
                                    }
                                    if(TTLeadFieldsMap.containskey('email')){
                                        System.debug(LoggingLevel.DEBUG,' lead email');
                                    }
                                    if(TTLeadFieldsMap.containskey('phone')){
                                        if(obj1.phone != ''){
                                            System.debug(LoggingLevel.DEBUG,' lead phone');
                                        }else if(obj1.phone == '' && TTLeadFieldsMap.get('phone').TelosTouchSF__Is_Sync_Empty_Field__c == true){
                                            System.debug(LoggingLevel.DEBUG,' lead phone in else condition');
                                        }
                                    }
                                    if(TTLeadFieldsMap.containskey('subscribed')){
                                        if(notificationValue != null){
                                            leadObject.put(TTLeadFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , notificationValue);
                                        }
                                        else if(notificationValue == null && TTLeadFieldsMap.get('subscribed').TelosTouchSF__Is_Sync_Empty_Field__c == true){
                                            leadObject.put(TTLeadFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , null);
                                        }
                                    }
                                    if(TTLeadFieldsMap.containskey('language')){
                                        if(obj1.preferences.language == null || obj1.preferences.language == 'en_US'){
                                            System.debug(LoggingLevel.DEBUG,' lead English language');
                                        }else if(obj1.preferences.language != null && obj1.preferences.language == 'fr_FR'){
                                            System.debug(LoggingLevel.DEBUG,' lead French language');
                                        }
                                    }
                                    leadObject.TelosTouchSF__TT_Conflict__c = false;
                                    leadObject.TelosTouchSF__Error_Message__c = '';
                                    leadupdateList.add(leadObject);
                                }  else{
                                    if((obj1.last_login_date != null && sfLastLoginDetail == System.Label.After_TT_invite) || (sfLastLoginDetail == null && ((obj1.last_login_date != null) || (obj1.invited_at != null)))
                                            || (last_login_date != null && sFLastLoginDate != null && last_login_date.getTime()  > sFLastLoginDate.getTime())){
                                        leadupdateList.add(leadObject);
                                    }
                                }
                            }else{
                                if(leadMap.containskey(obj1.email)){
                                    leadObject = leadMap.get(obj1.email);
                                }
                                if(leadObject != null && (!setSFId.contains(leadObject.Id))){
                                    leadObject.TelosTouchSF__Error_Message__c = 'Duplicate Email';
                                    leadupdateList.add(leadObject);
                                }
                                setSFId.add(leadObject.Id);
                                createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Duplicate:'+' '+obj1.email,'Doublon:'+' '+obj1.email,1));
                            }
                        }else if(leadMap.containskey(obj1.email) && leadMap.get(obj1.email) != null){
                            Lead leadObject = new Lead();
                            leadObject = leadMap.get(obj1.email);
                            if(!setSFId.contains(leadObject.Id)){
                                leadObject.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                leadObject.TelosTouchSF__Error_Message__c = '';
                                if(obj1.invited_at != null ){
                                    leadObject.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        leadObject.TelosTouchSF__TT_Last_Login__c = formattedDate;

                                    }else{
                                        leadObject.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                leadObject.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                leadupdateList.add(leadObject);
                            }
                            setSFId.add(leadObject.Id);
                        }
                    }else if(contactMapEmailVsObj.containskey(obj1.email)){
                        Contact contact = new Contact();
                        contact = contactMapEmailVsObj.get(obj1.email);
                        contact.TelosTouchSF__Error_Message__c = 'Duplicate Email';
                        contactupsertList.add(contact);
                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Duplicate:'+' '+obj1.email,'Doublon:'+' '+obj1.email,1));
                    }else if(leadMapEmailVsObj.containskey(obj1.email)){
                        Lead leadObject = new Lead();
                        leadObject = leadMapEmailVsObj.get(obj1.email);
                        leadObject.TelosTouchSF__Error_Message__c = 'Duplicate Email';
                        leadupdateList.add(leadObject);
                        createListOfLog.add(SFDataSyncWithTelosTouch.addLogRecord('Failure','Duplicate:'+' '+obj1.email,'Doublon:'+' '+obj1.email,1));
                    }else{
                        if(!setTTEmailDuplicate.contains(obj1.email)){
                            if(obj1.type == 'client' || obj1.type == 'expert' || obj1.type == 'other'){
                                Contact contactObject = new Contact();
                                contactObject.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                if(TTContactFieldsMap.containskey('first_name')){
                                    contactObject.put(TTContactFieldsMap.get('first_name').TelosTouchSF__Salesforce_Field__c, obj1.first_name);
                                }
                                if(TTContactFieldsMap.containskey('last_name')){
                                    contactObject.put(TTContactFieldsMap.get('last_name').TelosTouchSF__Salesforce_Field__c, obj1.last_name);
                                }
                                if(TTContactFieldsMap.containskey('email')){
                                    contactObject.put(TTContactFieldsMap.get('email').TelosTouchSF__Salesforce_Field__c, obj1.email);
                                }
                                if(TTContactFieldsMap.containskey('phone')){
                                    contactObject.put(TTContactFieldsMap.get('phone').TelosTouchSF__Salesforce_Field__c, obj1.phone);
                                }
                                contactObject.TelosTouchSF__Error_Message__c = '';
                                contactObject.TelosTouchSF__Source__c = 'TelosTouch';
                                if(TTContactFieldsMap.containskey('language')){
                                    if(obj1.preferences.language == null || obj1.preferences.language == 'en_US'){
                                        contactObject.put(TTContactFieldsMap.get('language').TelosTouchSF__Salesforce_Field__c , 'English');
                                    }else if(obj1.preferences.language != null && obj1.preferences.language == 'fr_FR'){
                                        contactObject.put(TTContactFieldsMap.get('language').TelosTouchSF__Salesforce_Field__c , 'French');
                                    }
                                }
                                if(TTContactFieldsMap.containskey('subscribed')){
                                    if(obj1.preferences.notificationTouchpointSend == false){
                                        contactObject.put(TTContactFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , 'No');
                                    }else{
                                        contactObject.put(TTContactFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , 'Yes');
                                    }
                                }
                                if(obj1.invited_at != null ){
                                    contactObject.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        contactObject.TelosTouchSF__TT_Last_Login__c = formattedDate;

                                    }else{
                                        contactObject.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                if(userMap.containsKey(obj1.created_by)){
                                    contactObject.OwnerId = userMap.get(obj1.created_by);
                                    contactObject.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                    contactupsertList.add(contactObject);
                                }else{
                                    ownerNotFoundCount++;
                                }
                            }else if(obj1.type == 'lead'){
                                lead leadObject = new lead();
                                leadObject.Company = 'TT Company';
                                leadObject.TelosTouchSF__TT_Client_Id__c = obj1.id;
                                if(TTLeadFieldsMap.containskey('first_name')){
                                    leadObject.put(TTLeadFieldsMap.get('first_name').TelosTouchSF__Salesforce_Field__c, obj1.first_name);
                                }
                                if(TTLeadFieldsMap.containskey('last_name')){
                                    leadObject.put(TTLeadFieldsMap.get('last_name').TelosTouchSF__Salesforce_Field__c, obj1.last_name);
                                }
                                if(TTLeadFieldsMap.containskey('email')){
                                    leadObject.put(TTLeadFieldsMap.get('email').TelosTouchSF__Salesforce_Field__c, obj1.email);
                                }
                                if(TTLeadFieldsMap.containskey('phone')){
                                    leadObject.put(TTLeadFieldsMap.get('phone').TelosTouchSF__Salesforce_Field__c, obj1.phone);
                                }
                                leadObject.TelosTouchSF__Error_Message__c = '';
                                leadObject.TelosTouchSF__Source__c = 'TelosTouch';
                                if(TTLeadFieldsMap.containskey('language')){
                                    if(obj1.preferences.language == null || obj1.preferences.language == 'en_US'){
                                        leadObject.put(TTLeadFieldsMap.get('language').TelosTouchSF__Salesforce_Field__c , 'English');
                                    }else if(obj1.preferences.language != null && obj1.preferences.language == 'fr_FR'){
                                        leadObject.put(TTLeadFieldsMap.get('language').TelosTouchSF__Salesforce_Field__c , 'French');
                                    }
                                }
                                if(TTLeadFieldsMap.containskey('subscribed')){
                                    if(obj1.preferences.notificationTouchpointSend == false){
                                        leadObject.put(TTLeadFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , 'No');
                                    }else{
                                        leadObject.put(TTLeadFieldsMap.get('subscribed').TelosTouchSF__Salesforce_Field__c , 'Yes');
                                    }
                                }
                                if(obj1.invited_at != null ){
                                    leadObject.TelosTouchSF__TT_UserId__c = obj1.user_id;
                                    if(obj1.last_login_date != null){
                                        last_login_date = (DateTime)JSON.deserialize('"' + obj1.last_login_date + '"', DateTime.class);
                                        formattedDate = last_login_date.formatGMT('MMM d yyyy HH:mm:a');
                                        leadObject.TelosTouchSF__TT_Last_Login__c = formattedDate;

                                    }else{
                                        leadObject.TelosTouchSF__TT_Last_Login__c = System.Label.After_TT_invite;
                                    }
                                }
                                if(userMap.containsKey(obj1.created_by)){
                                    leadObject.OwnerId = userMap.get(obj1.created_by);
                                    leadObject.TelosTouchSF__TT_LastSyncTime__c = Datetime.now();
                                    leadupdateList.add(leadObject);
                                }else{
                                    ownerNotFoundCount++;
                                }
                            }

                        }else{
                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecord('Failure','Duplicate:'+' '+obj1.email,'Doublon:'+' '+obj1.email,1));
                        }
                        setTTEmailDuplicate.add(obj1.email);
                    }
                }
                if(contactupsertList.size()> 0){
                    if(Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isCreateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.FirstName.isAccessible() &&
                            Schema.sObjectType.Contact.fields.FirstName.isCreateable() &&
                            Schema.sObjectType.Contact.fields.FirstName.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.LastName.isAccessible() &&
                            Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
                            Schema.sObjectType.Contact.fields.LastName.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Source__c.isAccessible() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Source__c.isCreateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Source__c.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.Email.isAccessible() &&
                            Schema.sObjectType.Contact.fields.Email.isCreateable() &&
                            Schema.sObjectType.Contact.fields.Email.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.Phone.isAccessible() &&
                            Schema.sObjectType.Contact.fields.Phone.isCreateable() &&
                            Schema.sObjectType.Contact.fields.Phone.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Language__c.isAccessible() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Language__c.isCreateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Language__c.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Subscribed__c.isAccessible() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Subscribed__c.isCreateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Subscribed__c.isUpdateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isAccessible() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isCreateable() &&
                            Schema.sObjectType.Contact.fields.TelosTouchSF__Error_Message__c.isUpdateable() ){
                        Database.UpsertResult[] srList = Database.upsert(contactupsertList,false);
                                for (Database.UpsertResult sr : srList) {
                                    String errorMessage = 'Failed Contact sync records from TelosTouch to Salesforce :';
                                    if (sr.isSuccess()) {
                                        if(showLogs){
                                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', 'Contact sync successfully from TelosTouch to Salesforce.',sr.getId()));
                                        }
                                    }
                                    else {
                                        for(Database.Error err : sr.getErrors()) {
                                            errorMessage += err.getMessage();
                                        }
                                        if(showLogs){
                                            createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, sr.getId()));
                                        }
                                    }
                                }
                    }
                    totalSyncedUser = contactupsertList.size();
                }
                if(leadupdateList.size()> 0){
                    if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.isCreateable() && Schema.sObjectType.Lead.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isAccessible() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isCreateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__TT_Client_Id__c.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.FirstName.isAccessible() &&
                            Schema.sObjectType.Lead.fields.FirstName.isCreateable() &&
                            Schema.sObjectType.Lead.fields.FirstName.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.LastName.isAccessible() &&
                            Schema.sObjectType.Lead.fields.LastName.isCreateable() &&
                            Schema.sObjectType.Lead.fields.LastName.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.Company.isAccessible() &&
                            Schema.sObjectType.Lead.fields.Company.isCreateable() &&
                            Schema.sObjectType.Lead.fields.Company.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Source__c.isAccessible() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Source__c.isCreateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Source__c.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.Email.isAccessible() &&
                            Schema.sObjectType.Lead.fields.Email.isCreateable() &&
                            Schema.sObjectType.Lead.fields.Email.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.Phone.isAccessible() &&
                            Schema.sObjectType.Lead.fields.Phone.isCreateable() &&
                            Schema.sObjectType.Lead.fields.Phone.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Language__c.isAccessible() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Language__c.isCreateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Language__c.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Subscribed__c.isAccessible() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Subscribed__c.isCreateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Subscribed__c.isUpdateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isAccessible() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isCreateable() &&
                            Schema.sObjectType.Lead.fields.TelosTouchSF__Error_Message__c.isUpdateable() ){
                            Database.UpsertResult[] srList = Database.upsert(leadupdateList,false);
                            for (Database.UpsertResult sr : srList) {
                                String errorMessage = 'Failed Lead sync records from TelosTouch to Salesforce :';
                                if (sr.isSuccess()) {
                                    if(showLogs){
                                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', 'Lead sync successfully from TelosTouch to Salesforce.',sr.getId()));
                                    }
                                }
                                else {
                                    for(Database.Error err : sr.getErrors()) {
                                        errorMessage += err.getMessage();
                                    }
                                    if(showLogs){
                                        createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, sr.getId()));
                                    }
                                }
                            }
                    }
                    totalSyncedUser = totalSyncedUser + leadupdateList.size();
                }
                if(totalSyncedUser >0){
                    TelosTouchSF.UserTriggerHandler.createLogRecord('success','Clients sync successfully from TelosTouch to Salesforce.','Clients syncronisés avec succès de TelosTouch à Salesforce.', totalSyncedUser);
                }
                if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                    insert createListOfLog;
                }
            }
            if(endPoint == NumberOfRecords){
                if(syncObject == null){
                    Database.executeBatch(new TelosTouchSF.BatchForBulkDataInsertOrUpdate(null, null, null, 'Task', null, null, null));
                }else{
                    Batch_UpdateContactAndLead2 batchObj = new Batch_UpdateContactAndLead2(syncObject, forFirstTime, 'Contact');
                    Database.executeBatch(batchObj,500);
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage()+' on Line::'+ex.getLineNumber());
            TelosTouchSF__TT_Log__c logObj = new TelosTouchSF__TT_Log__c();
            List<TelosTouchSF__TT_Log__c>  createListOfLog = new List<TelosTouchSF__TT_Log__c>();
            Boolean showLogs = TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isCreateable()
                    && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Result__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Comments__c.isAccessible()){
                logObj.TelosTouchSF__Result__c = 'Failure';
                logObj.TelosTouchSF__Comments__c = ex.getMessage();
                String errorMessage = ex.getMessage() + ex.getStackTraceString() + ' Line number: ' + ex.getLineNumber() + ' Class: GetClientsFromTTQueueable';
                if(showLogs){
                       createListOfLog.add(TelosTouchSF.SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Failure', errorMessage, ''));
                 }
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Total_Records_Count__c.isAccessible()){
                logObj.TelosTouchSF__Total_Records_Count__c = 0;
            }
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__LastUpdated__c.isCreateable()){
                logObj.TelosTouchSF__LastUpdated__c = local;
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.Log_Type__c.isAccessible() && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.LastUpdated__c.isCreateable()){
                logObj.Log_Type__c='Main Log';
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible()){
                insert logObj;
            }
             if(createListOfLog.size() >0 && Schema.sObjectType.TelosTouchSF__TT_Log__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Log__c.isAccessible() ){
                insert createListOfLog;
            }
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param sfLoginDate ...
* @return Datetime dt ......
*/
    public static Datetime getDateFormate(String sfLoginDate){
        String dtStr = sfLoginDate;
        List<String> dateStr = dtStr.split(' ');
        List<String> timeStr = dateStr[3].split(':');
        Map<String, Integer> monthMap = new Map<String, Integer>();
        monthMap.put('Jan', 1); monthMap.put('Feb', 2); monthMap.put('Mar', 3);  monthMap.put('Apr', 4); monthMap.put('May', 5); monthMap.put('Jun', 6);
        monthMap.put('Jul', 7);  monthMap.put('Aug', 8); monthMap.put('Sep', 9);  monthMap.put('Oct', 10);  monthMap.put('Nov', 11); monthMap.put('Dec', 12);
        Datetime dt = Datetime.newInstanceGmt(Integer.valueOf(dateStr[2]), monthMap.get(dateStr[0]), Integer.valueOf(dateStr[1]), (timeStr[2] == 'PM'? (Integer.valueOf(timeStr[0])+12):Integer.valueOf(timeStr[0])), Integer.valueOf(timeStr[1]), 0);
        return dt;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ResponseWrapper is used to get id,name,first_name,last_name,email,modified_at and Preferences.
*/
    public class ResponseWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String id { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String name { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String first_name { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String last_name { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String email { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String phone { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String modified_at { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String invited_at { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String user_id { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String type { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String last_login_date { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String created_by { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Preferences preferences { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Preferences is used to get language and notificationTouchpointSend.
*/
    public class Preferences {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String language { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Boolean notificationTouchpointSend { get; set; }
    }
}