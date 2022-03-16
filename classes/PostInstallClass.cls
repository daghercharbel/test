/**
* @author Cloud Analogy
* @date 02/08/2021
* @description PostInstallClass class is used for creating fields mapping object records and during the package installation then this works.
*/
global with sharing class PostInstallClass implements InstallHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ...
*/
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            //****************************Contact Mapping And TelosTouch to Salesforce(Vice Versa)***************************************************************
            List<TelosTouchSF__TT_Salesforce_Mapping__c> TelosTouchList = new List<TelosTouchSF__TT_Salesforce_Mapping__c>();
            TelosTouchSF__TT_Salesforce_Mapping__c TTContact1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTContact1.TelosTouchSF__TT_Field__c = 'first_name';
                TTContact1.TelosTouchSF__Salesforce_Field__c = 'FirstName';
                TTContact1.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact1); 
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTContact2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTContact2.TelosTouchSF__TT_Field__c = 'last_name';
                TTContact2.TelosTouchSF__Salesforce_Field__c = 'LastName';
                TTContact2.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact2);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTContact3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTContact3.TelosTouchSF__TT_Field__c = 'email';
                TTContact3.TelosTouchSF__Salesforce_Field__c = 'Email';
                TTContact3.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact3);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTContact4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTContact4.TelosTouchSF__TT_Field__c = 'language';
                TTContact4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Language__c';
                TTContact4.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact4);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTContact5 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTContact5.TelosTouchSF__TT_Field__c = 'phone';
                TTContact5.TelosTouchSF__Salesforce_Field__c = 'Phone';
                TTContact5.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact5);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTContact6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTContact6.TelosTouchSF__TT_Field__c = 'subscribed';
                TTContact6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Subscribed__c';
                TTContact6.TelosTouchSF__Object_Name__c = 'Contact';
                TelosTouchList.add(TTContact6);
            }

            //****************************Lead Mapping***************************************************************

            TelosTouchSF__TT_Salesforce_Mapping__c TTLead1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTLead1.TelosTouchSF__TT_Field__c = 'first_name';
                TTLead1.TelosTouchSF__Salesforce_Field__c = 'FirstName';
                TTLead1.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead1);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTLead2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTLead2.TelosTouchSF__TT_Field__c = 'last_name';
                TTLead2.TelosTouchSF__Salesforce_Field__c = 'LastName';
                TTLead2.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead2);
            }


            TelosTouchSF__TT_Salesforce_Mapping__c TTLead3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTLead3.TelosTouchSF__TT_Field__c = 'email';
                TTLead3.TelosTouchSF__Salesforce_Field__c = 'Email';
                TTLead3.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead3);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTLead4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTLead4.TelosTouchSF__TT_Field__c = 'language';
                TTLead4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Language__c';
                TTLead4.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead4);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTLead5 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTLead5.TelosTouchSF__TT_Field__c = 'phone';
                TTLead5.TelosTouchSF__Salesforce_Field__c = 'Phone';
                TTLead5.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead5);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTLead6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTLead6.TelosTouchSF__TT_Field__c = 'subscribed';
                TTLead6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Subscribed__c';
                TTLead6.TelosTouchSF__Object_Name__c = 'Lead';
                TelosTouchList.add(TTLead6);
            }

            //****************************Task Mapping***************************************************************

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTaskObj.TelosTouchSF__TT_Field__c = 'date_due';
                TTaskObj.TelosTouchSF__Salesforce_Field__c = 'ActivityDate';
                TTaskObj.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj1 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTaskObj1.TelosTouchSF__TT_Field__c = 'name';
                TTaskObj1.TelosTouchSF__Salesforce_Field__c = 'Subject';
                TTaskObj1.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj1);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj2 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTaskObj2.TelosTouchSF__TT_Field__c = 'status';
                TTaskObj2.TelosTouchSF__Salesforce_Field__c = 'Status';
                TTaskObj2.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj2);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj3 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTaskObj3.TelosTouchSF__TT_Field__c = 'client_id';
                TTaskObj3.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Client_Id__c';
                TTaskObj3.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj3);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj4 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTaskObj4.TelosTouchSF__TT_Field__c = 'client_name';
                TTaskObj4.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Client_Name__c';
                TTaskObj4.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj4);
            }

            TT_Salesforce_Mapping__c TTaskObj5 = new TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                
                TTaskObj5.TelosTouchSF__TT_Field__c = 'description';
                TTaskObj5.TelosTouchSF__Salesforce_Field__c = 'Description';
                TTaskObj5.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj5);
            }
            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj6 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTaskObj6.TelosTouchSF__TT_Field__c = 'shared';
                TTaskObj6.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__Share_with_client_s__c';
                TTaskObj6.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj6);
            }

            TelosTouchSF__TT_Salesforce_Mapping__c TTaskObj7 = new TelosTouchSF__TT_Salesforce_Mapping__c();
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()){
                TTaskObj7.TelosTouchSF__TT_Field__c = 'type';
                TTaskObj7.TelosTouchSF__Salesforce_Field__c = 'TelosTouchSF__TT_Category__c';
                TTaskObj7.TelosTouchSF__Object_Name__c = 'Task';
                TelosTouchList.add(TTaskObj7);
            }
            if(Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isCreateable() && Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.isAccessible() && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Object_Name__c.isCreateable()) && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__TT_Field__c.isCreateable()) && (Schema.sObjectType.TelosTouchSF__TT_Salesforce_Mapping__c.fields.TelosTouchSF__Salesforce_Field__c.isCreateable())){
                if (TelosTouchList.size() > 0) {             
                    insert TelosTouchList;
                }
            }
            //system.debug('TelosTouchList>>'+TelosTouchList);
        }
        //Database.executeBatch(new BatchPostInstallScript('Lead'), 500);
        //Database.executeBatch(new BatchPostInstallScript('Task'), 1000);
    }
}