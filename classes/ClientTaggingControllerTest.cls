@istest
public with sharing class ClientTaggingControllerTest {

    @TestSetup
    static void setupMethod(){
        
        Contact cttTest = new Contact(
            LastName = 'ClientTaggingControllerTest',
            Email = 'ClientTaggingControllerTest@test.com',
            TT_Client_Id__c = 'ClientTaggingControllerTest'
        );
        insert cttTest;

        Topic topicTest = new Topic(
            name = 'ClientTaggingControllerTest'
        );
        insert topicTest;

    }

    @isTest
    static void deleteAssignmentsTest(){

        list<Contact> lstCtt = [SELECT Id FROM Contact WHERE TT_Client_Id__c = 'ClientTaggingControllerTest'];
        list<Topic> lstTopic = [SELECT Id FROM Topic WHERE Name = 'ClientTaggingControllerTest'];
        list<String> lstRecordId = new list<String>{lstCtt[0].Id};
        list<String> lstTopicId = new list<String>{lstTopic[0].Id};

        Test.startTest();
        //TEST SUCCESS
        map<String, String> mapResult = TelosTouchSF.ClientTaggingController.deleteAssignments(lstTopicId, lstRecordId);
        System.assert(mapResult.get('status') == 'success', mapResult.get('error'));
        //TEST ERROR
        map<String, String> mapResultError = TelosTouchSF.ClientTaggingController.deleteAssignments(null, null);
        System.assert(mapResultError.get('status') == 'error', 'Test should have thrown an error.');
        Test.stopTest();

    }

    @isTest
    static void getTopicsTest(){

        list<Contact> lstCtt = [SELECT Id FROM Contact WHERE TT_Client_Id__c = 'ClientTaggingControllerTest'];
        list<String> lstRecordId = new list<String>{lstCtt[0].Id};

        Test.startTest();
        //TEST SUCCESS
        map<String, String> mapResult = TelosTouchSF.ClientTaggingController.getTopics(lstRecordId);
        System.assert(mapResult.get('status') == 'success', mapResult.get('error'));
        //TEST ERROR
        map<String, String> mapResultError = TelosTouchSF.ClientTaggingController.getTopics(null);
        System.assert(mapResultError.get('status') == 'error', 'Test should have thrown an error.');
        Test.stopTest();

    }

    @isTest
    static void upsertTopicsTest(){

        list<Contact> lstCtt = [SELECT Id FROM Contact WHERE TT_Client_Id__c = 'ClientTaggingControllerTest'];
        list<String> lstRecordId = new list<String>{lstCtt[0].Id};

        Test.startTest();
        //TEST SUCCESS
        map<String, String> mapResult = TelosTouchSF.ClientTaggingController.upsertTopics('ClientTaggingControllerTest2', lstRecordId);
        System.assert(mapResult.keySet() != null, 'It should not be empty');
        //TEST ERROR
        map<String, String> mapResultError = TelosTouchSF.ClientTaggingController.upsertTopics(null, null);
        System.assert(mapResultError.get('status') == 'error', 'Test should have thrown an error.');
        Test.stopTest();

    }

}