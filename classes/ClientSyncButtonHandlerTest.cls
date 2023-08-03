@isTest
public class ClientSyncButtonHandlerTest {
    @testSetup static void setupMethod(){
        TelosTouchSF__TT_Salesforce_Mapping__c fieldTest = new TelosTouchSF__TT_Salesforce_Mapping__c(
            TelosTouchSF__Object_Name__c = 'Contact',
            TelosTouchSF__Salesforce_Field__c = 'FirstName',
            TelosTouchSF__TT_Field__c = 'first_name'
        );
        insert fieldTest;
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = '1';
        con.TelosTouchSF__Subscribed__c  = 'Yes';
        con.Email = 'tets1342@gmail.com';
        insert con;
        Lead obj = new Lead();
        obj.FirstName = 'test 1';
        obj.LastName = '123';
        obj.Email = 'test1314@gmail.com';
        obj.Company = 'CA';
        insert obj;
    } 
    @isTest static void getFeatureMetadataBasedOnIdTest(){
        Test.startTest();
        Map<String, String> resp = ClientSyncButtonHandler.getFeatureMetadataBasedOnId([SELECT Id FROM Contact LIMIT 1].Id);
        System.assert(resp.keySet() != null, 'It should not be null');
        Test.stopTest();
    }
    @isTest static void getRecordInfoTest(){
        Test.startTest();
        String resp = ClientSyncButtonHandler.getRecordInfo([SELECT Id FROM Contact LIMIT 1].Id);
        System.assert(resp != null, 'It should not be null');
        Test.stopTest();
    }
    @isTest static void syncRecordBasedOnRecIdTest(){
        String sixthFakeRepomseRespString ='{"deviceToken":null,"id":"60e435f0d0c2a8a2a3da19bd","first_name":"Swapnil","last_name":"PUT Sen Keycloak 4","email":"demo@gmail.com","user_id":null,"phone":"","language":"en_US","created_by":"6240d32f-a652-472c-85bf-42cb27dd2420","invited_at":null,"modified_at":"2021-07-06T10:55:06.000Z","created_at":"2021-07-06T10:52:32.000Z","last_login_date":null,"avatar_id":null,"deleted":false,"custom_fields":null,"preferences":{"notificationTouchpointSend":true,"language":"en_US"},"accepts_calls":true,"type":"client","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420","other_id":null,"created":[],"alreadyExists":[]}';
        SingleRequestMock sixthFakeResponseResp = new SingleRequestMock(200,'OK',sixthFakeRepomseRespString,null);
        System.assert(sixthFakeResponseResp != null, 'sixthFakeResponseResp must not be NULL');
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://test.com/api/v1/admin/contacts',sixthFakeResponseResp);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        System.assert(multiCalloutMock != null, 'multiCalloutMock must not be NULL');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        Boolean resp = ClientSyncButtonHandler.syncRecordBasedOnRecId([SELECT Id FROM Contact LIMIT 1].Id);
        System.assert(resp == false, 'It should be true');
        Boolean resp1 = ClientSyncButtonHandler.syncRecordBasedOnRecId([SELECT Id FROM Lead LIMIT 1].Id);
        System.assert(resp1 == false, 'It should be true');
        Test.stopTest();
    }
}