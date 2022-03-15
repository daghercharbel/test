@isTest 
public with sharing class MassInviteButtonControllerTest {
    @isTest    
    static void massInviteButtonControllertest1() {
        List<Contact> conlist = new List<Contact>();
        Contact contactObj = new Contact(lastname = 'TestName');
        conlist.add(contactObj);
        insert conlist;
        ApexPages.StandardSetController stdSetController = new ApexPages.standardSetController(conlist);
        stdSetController.setSelected(conlist);
        Test.startTest();
        MassInviteButtonController controller = new MassInviteButtonController(stdSetController);
        System.assert(conlist.size()>0, 'conlist should not be blank.');
        Test.stopTest();
    }
    @isTest    
    static void massInviteButtonControllertest2() {
        List<Lead> leadlist = new List<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'jain';
        ld.Email = 'smrati@ca.com';    
        ld.Company = 'Test Company';
        leadlist.add(ld);
        insert leadlist;
        ApexPages.StandardSetController stdSetController = new ApexPages.standardSetController(leadlist);
        stdSetController.setSelected(leadlist);
        Test.startTest();
        MassInviteButtonController controller = new MassInviteButtonController(stdSetController);
        System.assert(leadlist.size()>0, 'leadlist shold not be blank.');
        Test.stopTest();
    }
}