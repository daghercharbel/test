@isTest
public with sharing class TTNativeHomeControllerTest {
    @TestSetup
    static void makeData(){
        Campaign campObj = new Campaign();
        campObj.Name = 'Test 1';
        insert campObj;

        Campaign campObj2 = new Campaign();
        campObj2.Name = 'Test 2';
        insert campObj2;

        Campaign campObj3 = new Campaign();
        campObj3.Name = 'Test 3';
        insert campObj3;

        Campaign campObj4 = new Campaign();
        campObj4.Name = 'Test 4';
        insert campObj4;

        TelosTouchSF__Insights__c insightobj = new TelosTouchSF__Insights__c();
        insightobj.TelosTouchSF__Campaign2__c = campObj.Id;
        insightobj.TelosTouchSF__TouchPoint_Name__c = 'Test 1';
        insightobj.TelosTouchSF__Completed_At__c = Datetime.now();
        insightobj.TelosTouchSF__Opened_At__c = Datetime.now();

        TelosTouchSF__Insights__c insightobj2 = new TelosTouchSF__Insights__c();
        insightobj2.TelosTouchSF__Campaign2__c = campObj.Id;
        insightobj2.TelosTouchSF__TouchPoint_Name__c = 'Test 1';
        insightobj2.TelosTouchSF__Completed_At__c = null;
        insightobj2.TelosTouchSF__Opened_At__c = null;

        TelosTouchSF__Insights__c insightobj3 = new TelosTouchSF__Insights__c();
        insightobj3.TelosTouchSF__Campaign2__c = campObj2.Id;
        insightobj3.TelosTouchSF__TouchPoint_Name__c = 'Test 2';
        insightobj3.TelosTouchSF__Completed_At__c = Datetime.now();
        insightobj3.TelosTouchSF__Opened_At__c = Datetime.now();

        TelosTouchSF__Insights__c insightobj5 = new TelosTouchSF__Insights__c();
        insightobj5.TelosTouchSF__Campaign2__c = campObj4.Id;
        insightobj5.TelosTouchSF__TouchPoint_Name__c = 'Test 2';
        insightobj5.TelosTouchSF__Completed_At__c = Datetime.now();
        insightobj5.TelosTouchSF__Opened_At__c = Datetime.now();

        TelosTouchSF__Insights__c insightobj6 = new TelosTouchSF__Insights__c();
        insightobj6.TelosTouchSF__Campaign2__c = campObj4.Id;
        insightobj6.TelosTouchSF__TouchPoint_Name__c = 'Test 2';
        insightobj6.TelosTouchSF__Completed_At__c = Datetime.now();
        insightobj6.TelosTouchSF__Opened_At__c = Datetime.now();

        insert new List<TelosTouchSF__Insights__c>{insightobj6, insightobj5, insightobj3, insightobj2, insightobj};
    }
    @isTest
    public static void getSentVsCompletedTest() {
        Test.startTest();
        String response = TTNativeHomeController.getSentVsCompletedData();
        Test.stopTest();
        System.assert(String.isNotEmpty(response), 'Response is not Empty');
    }
    @isTest
    public static void getChartDataTest() {
        Test.startTest();
        String response = TTNativeHomeController.getChartData();
        Test.stopTest();
        System.assert(String.isNotEmpty(response), 'Response is not Empty');
    }
}
