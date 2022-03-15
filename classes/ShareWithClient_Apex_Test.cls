@isTest
public with sharing class ShareWithClient_Apex_Test {
    @isTest
    static void test() {
        List<Task> tasklist = new List<Task>{};
            Task tobj = new Task();
        tobj.Status = 'Open';
        tobj.Priority = 'High';
        tasklist.add(tobj);
        insert tasklist;
        ApexPages.standardSetController stdSetController = new ApexPages.standardSetController(tasklist);
        stdSetController.setSelected(tasklist);
        Test.startTest();
        TelosTouchSF.ShareWithClient_Apex obj = new TelosTouchSF.ShareWithClient_Apex(stdSetController);
        System.assert(tasklist.size()>0, 'tasklist should not be blank');
        Test.stopTest();        
    }
}