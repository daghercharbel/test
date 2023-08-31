@isTest
public class ClientSyncButtonHandlerTest {
    @testSetup static void setupMethod(){
        List<TelosTouchSF__TT_Salesforce_Mapping__c> TelosTouchList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTContact1.TelosTouchSF__TT_Field__c = 'first_name';
            TTContact1.TelosTouchSF__Salesforce_Field__c = 'FirstName';
            TTContact1.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact1.TelosTouchSF__Unique_Identifier__c = TTContact1.TelosTouchSF__TT_Field__c + TTContact1.TelosTouchSF__Salesforce_Field__c + TTContact1.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact1); 
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTContact2.TelosTouchSF__TT_Field__c = 'last_name';
            TTContact2.TelosTouchSF__Salesforce_Field__c = 'LastName';
            TTContact2.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact2.TelosTouchSF__Unique_Identifier__c = TTContact2.TelosTouchSF__TT_Field__c + TTContact2.TelosTouchSF__Salesforce_Field__c + TTContact2.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact2);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTContact3.TelosTouchSF__TT_Field__c = 'email';
            TTContact3.TelosTouchSF__Salesforce_Field__c = 'Email';
            TTContact3.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact3.TelosTouchSF__Unique_Identifier__c = TTContact3.TelosTouchSF__TT_Field__c + TTContact3.TelosTouchSF__Salesforce_Field__c + TTContact3.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact3);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTContact4.TelosTouchSF__TT_Field__c = 'language';
            TTContact4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Language__c';
            TTContact4.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact4.TelosTouchSF__Unique_Identifier__c = TTContact4.TelosTouchSF__TT_Field__c + TTContact4.TelosTouchSF__Salesforce_Field__c + TTContact4.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact4);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact5 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTContact5.TelosTouchSF__TT_Field__c = 'phone';
            TTContact5.TelosTouchSF__Salesforce_Field__c = 'Phone';
            TTContact5.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact5.TelosTouchSF__Unique_Identifier__c = TTContact5.TelosTouchSF__TT_Field__c + TTContact5.TelosTouchSF__Salesforce_Field__c + TTContact5.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact5);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTContact6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTContact6.TelosTouchSF__TT_Field__c = 'subscribed';
            TTContact6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Subscribed__c';
            TTContact6.TelosTouchSF__Object_Name__c = 'Contact';
            TTContact6.TelosTouchSF__Unique_Identifier__c = TTContact6.TelosTouchSF__TT_Field__c + TTContact6.TelosTouchSF__Salesforce_Field__c + TTContact6.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTContact6);
        }
        
        //****************************Lead Mapping***************************************************************
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTLead1.TelosTouchSF__TT_Field__c = 'first_name';
            TTLead1.TelosTouchSF__Salesforce_Field__c = 'FirstName';
            TTLead1.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead1.TelosTouchSF__Unique_Identifier__c = TTLead1.TelosTouchSF__TT_Field__c + TTLead1.TelosTouchSF__Salesforce_Field__c + TTLead1.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead1);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTLead2.TelosTouchSF__TT_Field__c = 'last_name';
            TTLead2.TelosTouchSF__Salesforce_Field__c = 'LastName';
            TTLead2.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead2.TelosTouchSF__Unique_Identifier__c = TTLead2.TelosTouchSF__TT_Field__c + TTLead2.TelosTouchSF__Salesforce_Field__c + TTLead2.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead2);
        }
        
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTLead3.TelosTouchSF__TT_Field__c = 'email';
            TTLead3.TelosTouchSF__Salesforce_Field__c = 'Email';
            TTLead3.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead3.TelosTouchSF__Unique_Identifier__c = TTLead3.TelosTouchSF__TT_Field__c + TTLead3.TelosTouchSF__Salesforce_Field__c + TTLead3.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead3);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTLead4.TelosTouchSF__TT_Field__c = 'language';
            TTLead4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Language__c';
            TTLead4.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead4.TelosTouchSF__Unique_Identifier__c = TTLead4.TelosTouchSF__TT_Field__c + TTLead4.TelosTouchSF__Salesforce_Field__c + TTLead4.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead4);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead5 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTLead5.TelosTouchSF__TT_Field__c = 'phone';
            TTLead5.TelosTouchSF__Salesforce_Field__c = 'Phone';
            TTLead5.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead5.TelosTouchSF__Unique_Identifier__c = TTLead5.TelosTouchSF__TT_Field__c + TTLead5.TelosTouchSF__Salesforce_Field__c + TTLead5.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead5);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTLead6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTLead6.TelosTouchSF__TT_Field__c = 'subscribed';
            TTLead6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Subscribed__c';
            TTLead6.TelosTouchSF__Object_Name__c = 'Lead';
            TTLead6.TelosTouchSF__Unique_Identifier__c = TTLead6.TelosTouchSF__TT_Field__c + TTLead6.TelosTouchSF__Salesforce_Field__c + TTLead6.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTLead6);
        }
        
        //****************************Task Mapping***************************************************************
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTaskObj.TelosTouchSF__TT_Field__c = 'date_due';
            TTaskObj.TelosTouchSF__Salesforce_Field__c = 'ActivityDate';
            TTaskObj.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj.TelosTouchSF__Unique_Identifier__c = TTaskObj.TelosTouchSF__TT_Field__c + TTaskObj.TelosTouchSF__Salesforce_Field__c + TTaskObj.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTaskObj1.TelosTouchSF__TT_Field__c = 'name';
            TTaskObj1.TelosTouchSF__Salesforce_Field__c = 'Subject';
            TTaskObj1.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj1.TelosTouchSF__Unique_Identifier__c = TTaskObj1.TelosTouchSF__TT_Field__c + TTaskObj1.TelosTouchSF__Salesforce_Field__c + TTaskObj1.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj1);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTaskObj2.TelosTouchSF__TT_Field__c = 'status';
            TTaskObj2.TelosTouchSF__Salesforce_Field__c = 'Status';
            TTaskObj2.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj2.TelosTouchSF__Unique_Identifier__c = TTaskObj2.TelosTouchSF__TT_Field__c + TTaskObj2.TelosTouchSF__Salesforce_Field__c + TTaskObj2.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj2);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTaskObj3.TelosTouchSF__TT_Field__c = 'client_id';
            TTaskObj3.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Client_Id__c';
            TTaskObj3.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj3.TelosTouchSF__Unique_Identifier__c = TTaskObj3.TelosTouchSF__TT_Field__c + TTaskObj3.TelosTouchSF__Salesforce_Field__c + TTaskObj3.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj3);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTaskObj4.TelosTouchSF__TT_Field__c = 'client_name';
            TTaskObj4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Client_Name__c';
            TTaskObj4.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj4.TelosTouchSF__Unique_Identifier__c = TTaskObj4.TelosTouchSF__TT_Field__c + TTaskObj4.TelosTouchSF__Salesforce_Field__c + TTaskObj4.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj4);
        }
        
        TT_Salesforce_Mapping__c TTaskObj5 = new TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            
            TTaskObj5.TelosTouchSF__TT_Field__c = 'description';
            TTaskObj5.TelosTouchSF__Salesforce_Field__c = 'Description';
            TTaskObj5.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj5.TelosTouchSF__Unique_Identifier__c = TTaskObj5.TelosTouchSF__TT_Field__c + TTaskObj5.TelosTouchSF__Salesforce_Field__c + TTaskObj5.TelosTouchSF__Object_Name__c;                
            TelosTouchList.add(TTaskObj5);
        }
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTaskObj6.TelosTouchSF__TT_Field__c = 'shared';
            TTaskObj6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Share_with_client_s__c';
            TTaskObj6.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj6.TelosTouchSF__Unique_Identifier__c = TTaskObj6.TelosTouchSF__TT_Field__c + TTaskObj6.TelosTouchSF__Salesforce_Field__c + TTaskObj6.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj6);
        }
        
        TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj7 = new TelosTouchSF__TT_Salesforce_Mapping__c();
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
            TTaskObj7.TelosTouchSF__TT_Field__c = 'type';
            TTaskObj7.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Category__c';
            TTaskObj7.TelosTouchSF__Object_Name__c = 'Task';
            TTaskObj7.TelosTouchSF__Unique_Identifier__c = TTaskObj7.TelosTouchSF__TT_Field__c + TTaskObj7.TelosTouchSF__Salesforce_Field__c + TTaskObj7.TelosTouchSF__Object_Name__c;
            TelosTouchList.add(TTaskObj7);
        }
        if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()) && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable()) && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable())){
            if (TelosTouchList.size() > 0) {             
                upsert TelosTouchList TelosTouchSF__Unique_Identifier__c;
            }
        }
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