/*
 * Created by GET IT RENT on 08-11-2021.
 */
@isTest
public class TT_AddToCampaignMobile_Test {
	@isTest
	public static void fetchDataTest(){
		Contact conObj = new Contact();
		conObj.LastName = 'Test';
		conObj.TelosTouchSF__Subscribed__c = 'Yes';
		conObj.Email = 'test@abc.com';
		conObj.TelosTouchSF__Language__c = 'English';
        conObj.TelosTouchSF__TT_Client_Id__c = '98479437wjdoir5';
		Insert conObj;
		Contact conObj1 = new Contact();
		conObj1.LastName = 'Test conattc';
		conObj1.TelosTouchSF__Subscribed__c = 'Yes';
		conObj1.Email = 'test123@abc.com';
		conObj1.TelosTouchSF__Language__c = 'English';
        conObj1.TelosTouchSF__TT_Client_Id__c = '5798549rireuo49';
		Insert conObj1;
		Campaign camp = new Campaign();
		camp.Name = 'Test Camp';
		Insert camp;
		List<Id> idList = new List<Id>();
		List<Id> idList1 = new List<Id>();
		idList.add(conObj.id);
		TT_AddToCampaignMobile.dataWrapper wrapp= new TT_AddToCampaignMobile.dataWrapper();
		wrapp.Id = conObj.Id;
		List<TT_AddToCampaignMobile.dataWrapper> listdata = new List<TT_AddToCampaignMobile.dataWrapper>();
		listdata.add(wrapp);
		Test.startTest();
		TT_AddToCampaignMobile.fetchData('Contact',JSON.serialize(idList),'Te');
		TT_AddToCampaignMobile.fetchData('Contact',JSON.serialize(idList),'');
		TT_AddToCampaignMobile.fetchData('Contact',JSON.serialize(idList1),'');
		TT_AddToCampaignMobile.fetchRecordCounts(camp.Id);
		boolean variable=TT_AddToCampaignMobile.createCampaignMembers(JSON.serialize(listdata),camp.Id,'Contact');
        System.assertEquals(variable, true);
		test.stopTest();

	}
}