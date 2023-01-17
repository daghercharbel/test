@isTest
public class SFBatchToRevokeLicenceTest {
    @isTest
    public static void sfBatchToRevokeLicenceTestMethod(){
        List<Id> userIdList = new List<Id>();
        userIdList.add([SELECT Id FROM User WHERE Username = 'telostouchsf@telostouch.com'].Id);
        Test.startTest();
        Id jobId = Database.executeBatch(new SFBatchToRevokeLicence(userIdList));
    	Test.stopTest();
        System.assert(jobId != null);
    }
}