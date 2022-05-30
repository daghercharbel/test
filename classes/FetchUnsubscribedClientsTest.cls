@isTest
public class FetchUnsubscribedClientsTest {
	@TestSetup
    static void testSetup(){
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Name';
        con.Email = 'swapnil.sen+832983@telostouch.com';
        con.TelosTouchSF__Subscribed__c = 'No';
        con.TelosTouchSF__TT_Client_Id__c = '387268ewgdj';
        insert con;
        
        Lead leadObj = new Lead();
        leadObj.LastName='Lead Test';
        leadObj.Email = 'swapnil.sen+34673486@telostouch.com';
        leadObj.Company='Cloud';
        leadObj.TelosTouchSF__Subscribed__c = 'No';
        leadObj.TelosTouchSF__TT_Client_Id__c = '2309230239';
        insert leadObj;
        
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign 1';
        insert camp;
        
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Campaign 2';
        insert camp2;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = camp.Id;
        cm1.ContactId = con.Id;
        insert cm1;
    }
    @isTest
    static void getUnsubscribedClientsFromCampaignTest(){
        List<Object> objList1 = TelosTouchSF.FetchUnsubscribedClients.getUnsubscribedClientsFromCampaign([SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1].Id);
        List<Object> objList2 = TelosTouchSF.FetchUnsubscribedClients.getUnsubscribedClientsFromCampaign([SELECT Id FROM Campaign WHERE Name = 'Test Campaign 2' LIMIT 1].Id);
        System.assert(objList1 != null);
        System.assert(objList2 == null);
    }
    @isTest
    public static void removeClientTest()
    {        
        test.startTest();
        List<Id> campMemIdList = new List<Id>();
        List<Id> campMemIdList2 = new List<Id>();
        
        for(CampaignMember campMem : [SELECT Id FROM CampaignMember]){
            campMemIdList.add(campMem.Id);
        }
        String response = TelosTouchSF.FetchUnsubscribedClients.removeClient(JSON.serialize(campMemIdList2));
        String response2 = TelosTouchSF.FetchUnsubscribedClients.removeClient(JSON.serialize(campMemIdList));
        //system.assert(campMemIdList2 == null);
        System.assert(response == null);
        System.debug('response2:::'+response2);
        System.assert(response2 != null);
        test.stopTest();
    }
   
    @isTest
    public static void resubscribeClientTest()
    {
        Test.startTest();
        List<String> conIdList= new List<String>();
        List<String> leadList= new List<String>();
        
        List<String> conIdList2= new List<String>();
        List<String> leadList2= new List<String>();
        
        for(contact con2 : [SELECT Id FROM Contact]){
            conIdList.add(con2.Id);
        }
        for(Lead ld : [SELECT Id FROM Lead]){
            leadList.add(ld.Id);
        }
        
        String response = TelosTouchSF.FetchUnsubscribedClients.resubscribeClient(JSON.serialize(conIdList2), JSON.serialize(leadList2));
        String response2 = TelosTouchSF.FetchUnsubscribedClients.resubscribeClient(JSON.serialize(conIdList), JSON.serialize(leadList));
        System.debug('response:::'+response);
        System.assert(response == null);
        System.assert(response2 != null);   
        Test.stopTest();
    }
}