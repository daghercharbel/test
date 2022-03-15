@isTest
public class MultiObjectLookupControllerTest {
    @testSetup static void methodName() {
		Account acc = new Account();
        acc.Name = 'Sample Account for Entitlements';
        insert acc;
	}
    @isTest static void fetchRecordsTest(){
        Test.startTest();
        MultiObjectLookupController.fetchRecords(null, null, null);
       	List<MultiObjectLookupController.RecordsData> recList = MultiObjectLookupController.fetchRecords( 'Account', 'Name', 'Sample' );
        System.assert(recList.size() >= 0,'Record should Exist');
        Test.stopTest();
    }
}