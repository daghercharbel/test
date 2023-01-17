/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description FilterLookUpParentDependentCmpCtrl_Test ...
 */
@isTest
private with sharing class FilterLookUpParentDependentCmpCtrl_Test {
    /*
	 * @author Cloud Analogy
	 * @date 26/08/2021.
	 * @description searchDB_Test ...
	 */
    @isTest static void searchDB_Test() {
        System.Test.startTest();
        Account account = new Account();
        account.Name = 'TEST';
        insert account;
        Contact contact = new Contact();
        contact.LastName = 'Last';
        contact.AccountId = account.Id;
        contact.FirstName = 'First';
        Insert contact;
        String expected = '[{"text":"' + contact.LastName + '","objName":"Contact","Id":"First"}]';
        String actual = TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', 'Last', 'AccountId', null, 'none');
        String actual2 = TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', null, 'AccountId', account.Id, 'none');
        String parentFiledId = account.Id + ',Last';
        TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName,FirstName', 'FirstName', 1, 'LastName', null, 'AccountId,LastName', parentFiledId, 'none');
        TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName,Name', 'FirstName', 1, 'LastName', 'Last', 'AccountId,LastName', parentFiledId, 'none');
        System.assertEquals(expected, actual, 'actual should be equal to expected');
        System.assertEquals(expected, actual2, 'actual2 should be equal to expected');
        System.Test.stopTest();
    }
    /*
	 * @author Cloud Analogy
	 * @date 26/08/2021.
	 * @description searchDB_Test2 ...
	 */
    @isTest static void searchDB_Test2() {
        System.Test.startTest();
        Account account = new Account();
        account.Name = 'TEST';
        insert account;
        Contact contact = new Contact();
        contact.LastName = 'Last';
        contact.AccountId = account.Id;
        contact.FirstName = 'First';
        Insert contact;
        String expected = '[{"text":"Last","objName":"Contact","Id":"First"}]';
        TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', 'Last', 'AccountId', null, 'none');
        String actual2 = TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', null, 'AccountId', null, 'none');
        System.assertEquals(expected, actual2, 'actual2 should be equal to expected');
        System.Test.stopTest();

    }
    /*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description searchDB_WithStartString_Test2 ...
 */
    @isTest static void searchDB_WithStartString_Test2() {
        System.Test.startTest();
        Account account = new Account();
        account.Name = 'TEST';
        insert account;
        Contact contact = new Contact();
        contact.LastName = 'Last';
        contact.AccountId = account.Id;
        contact.FirstName = 'First';
        Insert contact;
        String expected = '[{"text":"Last","objName":"Contact","Id":"First"}]';
        TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', null, 'AccountId', account.Id, '00');
        String resultString = TelosTouchSF.FilterLookUpParentDependentCmpCtrl.searchDB('Contact', 'LastName', 'FirstName', 1, 'LastName', null, 'AccountId', account.Id, '066');
        System.assertEquals(expected, resultString, 'resultString should be equal to expected');
        System.Test.stopTest();

    }
}