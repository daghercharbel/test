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
}