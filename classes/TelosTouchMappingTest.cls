@isTest
private with sharing class TelosTouchMappingTest {
    @isTest
    private static void getTTfields(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'emailAddress';
        mappingObj.Salesforce_Field__c = 'email';
        mappingObj.Object_Name__c = 'Contact';
        
        insert mappingObj;
        
        TT_Salesforce_Mapping__c mappingObj2 = new TT_Salesforce_Mapping__c();
        mappingObj2.Is_Sync_Empty_Field__c = true;
        mappingObj2.TT_Field__c = 'emailAddress';
        mappingObj2.Salesforce_Field__c = 'email';
        mappingObj2.Object_Name__c = 'Task';
        
        insert mappingObj2;
        
        TT_Salesforce_Mapping__c mappingObj3 = new TT_Salesforce_Mapping__c();
        mappingObj3.Is_Sync_Empty_Field__c = true;
        mappingObj3.TT_Field__c = 'emailAddress';
        mappingObj3.Salesforce_Field__c = 'email';
        mappingObj3.Object_Name__c = 'Lead';
        
        insert mappingObj3;
        
        TelosTouch_API_Settings__c credential = new TelosTouch_API_Settings__c();
        credential.Token__c = 'dGVsb3N0b3VjaF9hZHOmhhdmVmdW4xMjNA';
        credential.Instance_url__c = 'https://test.com'; 
        insert credential;
        list<string> lst = new list<string>{'FirstName','LastName'};
            String clientFakeResponseForFields = '{"total": 1868,"list": [{"id": "5e95dd22515e3dfd6","name": "Thomas Caceres","deleted": false,"salutationName": "N/A","firstName": "Thomas","lastName": "Caceres","accountId": null,"title": null,"description": null,"emailAddress": "thomabc223r@mysystelos.com","phoneNumber": null,"doNotCall": false,"addressStreet": null,"addressCity": null,"addressState": null,             "addressCountry": null,             "addressPostalCode": null,             "accountType": null,"createdAt": "2020-04-14 15:56:18","modifiedAt": "2020-08-29 19:15:17","lastLoginDate": "2020-06-12 16:34:04","status": "","birthday": null,"drinkPreference": null,"interestsHobbies": null,"position": "Other","income": null,"incorporated": false,             "businessOwner": false,"age": null,"yearsInCanada": null,"occupation": null,"retirement": null,"businessPhone": null,"mobilePhone": null,"spouseName": null,"weddingAnniversary": null,"interests": null,"firmAnniversary": null,             "notes": null,             "birthdayUpcoming": null,"faxNumber": null,"otherPhone": null,"sINNumber": null,"languagePreference": null,"citizenship": null,"countryOfResidence": null,"locationOfIncomeTaxFiling": null,"corporateTaxID": null,"integrationId": null,"integrationType": null,"integrationSource": null,"companyName": null,"isDummyAccount": false,"inviteStatus": "completed","language": "en_US","customFields": null,"incomeCurrency": null,"accountName": null,"campaignId": null,"createdById": "5e95dc6839a36082d","createdByName": "Jad Chehlawi","modifiedById": "5e95dc6839a36082d","modifiedByName": "Jad Chehlawi","assignedUserId": "5e95dc6839a36082d","assignedUserName": "Jad Chehlawi","incomeConverted": null,"defaultTeamId": null,"defaultTeamName": null,"userId": "5eb5a1bfcc5a9c21b","userName": "Thomas Caceres","avatarName": "profile.png","avatarId": "5ed94fbb4760dbccd"}]}}}}';
        String taskFakeResponseForFields = '[{"id": "5f5093bc92700a83bca64cd","name": "Call  Test 1","type": "task","status": "open","client_id": "5f4c8e38e71d233e4","client_name": "Yadu Nagar","description": "","created_by_id": "1","created_by_name": "Admin Admin","assigned_user_id": "1","assigned_user_name": "Admin Admin","touchpoint_send_id": "","touchpoint_send_name": "","touchpoint_send_name_fr": null,"default_team_id": "5925d8eeaedb9e14c","shared": true,"instance": "https://test.com","deleted": false,"date_due": "2020-09-25T00:00:00.000Z","completed_at": null,"modified_at": "2020-09-03T00:00:00.000Z","created_at": "2020-09-02T00:00:00.000Z"}]';
        
        String createCustomFields = '{"data": "[\"custom3\"]","modified_by": "1","modified_at": "2020-09-07T14:59:23.889Z","key": "touchpoint.custom.fields","instance": "https://test.com"}';
        SingleRequestMock clientFakeResponse = new SingleRequestMock(200,'OK',clientFakeResponseForFields,null);
        System.assert(clientFakeResponse != null, 'clientFakeResponse must not be NULL');
        SingleRequestMock taskFakeResponse = new SingleRequestMock(200,'OK',taskFakeResponseForFields,null);
        System.assert(taskFakeResponse != null, 'taskFakeResponse must not be NULL');
        SingleRequestMock createCustomfield = new SingleRequestMock(200,'OK',createCustomFields,null);
        System.assert(createCustomfield != null, 'createCustomfield must not be NULL');
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/crm-v2/api/v1/Contact?maxSize=1',clientFakeResponse);
        endpoint2TestResp.put('https://test.com/chat/actions?skip=0&limit=1',taskFakeResponse);
        endpoint2TestResp.put('https://test.com/api/v1/settings/touchpoint.custom.fields',createCustomfield);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();        
        List<TelosTouchMapping.FieldWrapper> FieldWrapper = TelosTouchMapping.getTelosTouchFields();
        System.assert(FieldWrapper.size() >0,'FieldWrapper must not be NULL');
        List<TelosTouchMapping.FieldWrapper> FieldWrapper1 = TelosTouchMapping.getTelosTouchTaskFields();
        System.assert(FieldWrapper1.size() >0,'FieldWrapper1 must not be NULL');
        List<TelosTouchMapping.FieldWrapper> FieldWrapper2 = TelosTouchMapping.getObjectAllFields('Contact');
        System.assert(FieldWrapper2.size() >0,'FieldWrapper2 must not be NULL');
        List<TelosTouchMapping.FieldWrapper> FieldWrapper3 = TelosTouchMapping.getTelosTouchLeadFields();
        System.assert(FieldWrapper3.size() >0,'FieldWrapper3 must not be NULL');
        List<SObject> listObject = TelosTouchMapping.getExistingMappingApex('Contact');
        System.assert(listObject.size() > 0,'listObject must not be NULL');
        Boolean returnBollean = TelosTouchMapping.sendCustomFieldsSFToTT(lst, 'Contact');
        System.assertEquals(true, returnBollean, 'returnBollean must be TRUE');
        Test.stopTest();
        
    }
    @isTest
    private static void saveFieldsMappingTest(){
        List<TT_Salesforce_Mapping__c> ttObjNewList = New List<TT_Salesforce_Mapping__c>();
        TT_Salesforce_Mapping__c ttObjNew = New TT_Salesforce_Mapping__c();
        ttObjNew.Salesforce_Field__c = 'firstName';
        ttObjNew.TT_Field__c = 'firstName';
        ttObjNew.Object_Name__c = 'Contact';
        ttObjNewList.add(ttObjNew);
        
        Test.startTest();    
        Boolean returnBollean = TelosTouchMapping.saveFieldsMappingApex(ttObjNewList, 'Contact');
        System.assertEquals(true, returnBollean, 'returnBollean must be TRUE');
        Test.stopTest();
    }
    @isTest
    private static void deleteCustomFieldsTest(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'emailAddress';
        mappingObj.Salesforce_Field__c = 'email';
        mappingObj.Object_Name__c = 'Contact';
        
        insert mappingObj;
        
        TT_Salesforce_Mapping__c mappingObj2 = new TT_Salesforce_Mapping__c();
        mappingObj2.Is_Sync_Empty_Field__c = true;
        mappingObj2.TT_Field__c = 'Custom Fields';
        mappingObj2.Salesforce_Field__c = 'phone';
        mappingObj2.Object_Name__c = 'Contact';
        
        insert mappingObj2;        
        
        Test.startTest();
        Boolean returnValue = TelosTouchMapping.deleteCustomFields(new List<String>{mappingObj.Salesforce_Field__c, mappingObj2.Salesforce_Field__c}, 'Contact');
        System.assertEquals(true, returnValue, 'returnValue must be TRUE');
        Test.stopTest();
    }
    /*@isTest
    private static void updateSyncFieldTest(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'phoneNumber';
        mappingObj.Salesforce_Field__c = 'phone';
        mappingObj.Object_Name__c = 'Contact';
        
        insert mappingObj;
        
        Test.startTest();
        TelosTouchMapping.updateSyncField(true, 'phoneNumber', 'Contact');
        Test.stopTest();
    }*/
    @isTest
    private static void addingStandardFieldsTest(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'phoneNumber';
        mappingObj.Salesforce_Field__c = 'phone';
        mappingObj.Object_Name__c = 'Contact';
        
        insert mappingObj;   
        
        Test.startTest();
        List<TT_Salesforce_Mapping__c> mappingList = TelosTouchMapping.addingStandardFields();
        System.assertEquals(mappingList.size()>0, true, 'mappingList must not be NULL');
        Test.stopTest();
    }
    @isTest
    private static void populateDeletedFieldsApexTest(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'phoneNumber';
        mappingObj.Salesforce_Field__c = 'phone';
        mappingObj.Object_Name__c = 'Contact';
        mappingObj.Is_Deleted__c = true;
        
        insert mappingObj; 
        
        Test.startTest();
        List<TelosTouchMapping.deletedMappingsWrapper> mappingWrapper = TelosTouchMapping.populateDeletedFieldsApex('Contact');
        System.assertEquals(mappingWrapper.size()>0, true, 'mappingWrapper must not be NULL');
        Test.stopTest();
    }
    @isTest
    private static void addDeletedFieldsToMappingApexTest(){
        TT_Salesforce_Mapping__c mappingObj = new TT_Salesforce_Mapping__c();
        mappingObj.Is_Sync_Empty_Field__c = true;
        mappingObj.TT_Field__c = 'phoneNumber';
        mappingObj.Salesforce_Field__c = 'phone';
        mappingObj.Object_Name__c = 'Contact';
        mappingObj.Is_Deleted__c = true;
        
        insert mappingObj; 
        
        TT_Salesforce_Mapping__c mappingObj2 = new TT_Salesforce_Mapping__c();
        mappingObj2.Is_Sync_Empty_Field__c = true;
        mappingObj2.TT_Field__c = 'emailAddress';
        mappingObj2.Salesforce_Field__c = 'email';
        mappingObj2.Object_Name__c = 'Contact';
        mappingObj2.Is_Deleted__c = true;
        
        insert mappingObj2; 
        
        Test.startTest();
        Boolean returnValue = TelosTouchMapping.addDeletedFieldsToMappingApex('["'+mappingObj.Id+','+mappingObj2.Id+'"]');
        System.assertEquals(true, returnValue, 'returnValue must not be NULL');
        Test.stopTest();
    }
}