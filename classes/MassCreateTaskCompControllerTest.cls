@isTest
public class MassCreateTaskCompControllerTest {
    @testSetup static void setupMethod(){
        Contact con = new Contact();
        con.FirstName = 'Swapnil';
        con.LastName = 'Sen';
        con.TelosTouchSF__TT_Client_Id__c = '278e87ye289';
        con.Email = 'swapnil.sen+8327947249@telostouch.com';
        insert con;
    }
    @isTest static void createTasksTest(){
        Test.startTest();
        String taskObjStr = '{"subject":"Test Task","activitydate":"2022-02-08","status":"Not Started","priority":"Low"}';
        Contact con = [SELECT Id, Name, TelosTouchSF__TT_Client_Id__c FROM Contact LIMIT 1];
        String userListStr = '[{"ContactCLientId":"'+con.TelosTouchSF__TT_Client_Id__c+'","ContactOrLeadSFId":"'+con.Id+'","Id":"","isActive":true,"name":"'+con.Name+'","nameURL":"","TTCompleted_At":"Pending","TTOpened_At":"Pending"}]';
        TelosTouchSF.MassCreateTaskCompController.createTasks(taskObjStr, userListStr);
        System.assert([SELECT COUNT() FROM Task] > 0);
        Test.stopTest();
    }
    @isTest static void getTaskFieldsWrapperTest(){
        Test.startTest();
        list<TelosTouchSF.MassCreateTaskCompController.TaskFieldsWrapper> taskFields = TelosTouchSF.MassCreateTaskCompController.getTaskFieldsWrapper();
        System.assertEquals(taskFields.size()>0, true);
        Test.stopTest();
    }
    @isTest static void getFieldVsPicklistMap(){
        Test.startTest();
        Map<String,list<TelosTouchSF.MassCreateTaskCompController.PickListInfo>> taskFields = TelosTouchSF.MassCreateTaskCompController.getFieldVsPicklistMap();
        System.assertEquals(taskFields.size()>0, true);
        Test.stopTest();
    }
    @isTest static void getReferenceObjectstAPIvsLabelMapTest(){
        Test.startTest();
        Map<String,String> taskFields = TelosTouchSF.MassCreateTaskCompController.getReferenceObjectstAPIvsLabelMap();
        System.assertEquals(taskFields.size()>0, true);
        Test.stopTest();
    }
    @isTest static void getStandardObjectIconsMapTest(){
        Test.startTest();
        Map<String,String> objectIcons = TelosTouchSF.MassCreateTaskCompController.getStandardObjectIconsMap();
        System.assertEquals(objectIcons.size()>0, true);
        Test.stopTest();
    }
    @isTest static void getCustomObjectIconsMapTest(){
        Test.startTest();
        Map<String,String> objectIcons = TelosTouchSF.MassCreateTaskCompController.getCustomObjectIconsMap();
        System.assert(objectIcons.size()>0);
        Test.stopTest();
    }
    @isTest static void getReferenceObjectstAPIvsIconMapTest(){
        Test.startTest();
        Map<String,String>refObjectListWithICons = TelosTouchSF.MassCreateTaskCompController.getReferenceObjectstAPIvsIconMap();
        System.assertEquals(refObjectListWithICons.size()>0, true);
        Test.stopTest();
    }
    @isTest static void getfieldVsReferenceObjectsTest(){
        Test.startTest();
        Map<String,list<String>> objectsWithFields = TelosTouchSF.MassCreateTaskCompController.getfieldVsReferenceObjects();
        System.assertEquals(objectsWithFields.size()>0, true);
        Test.stopTest();
    }
    @isTest static void restGetTest(){
        Test.startTest();
        PageReference pageRef = Page.SessionID;
        Test.setCurrentPageReference(pageRef);
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.MassCreateTaskCompControllerMock());
        String str = TelosTouchSF.MassCreateTaskCompController.restGet('endPoint');
        System.assertEquals(str.length() > 0, true);
        Test.stopTest();
    }
    @isTest static void getLayoutNameForObjectTest(){
        Test.startTest();
        PageReference pageRef = Page.SessionID;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.MassCreateTaskCompControllerMock());
        Map<String, String> layoutNames = TelosTouchSF.MassCreateTaskCompController.getLayoutNameForObject('recordTypeId');
        System.assertEquals(layoutNames.keySet().size() > 0, true);
        Test.stopTest();
    }
    @isTest static void getSectionNameVsFieldsMapTest(){
        Test.startTest();
        PageReference pageRef = Page.SessionID;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TelosTouchSF.MassCreateTaskCompControllerMock());
        Map<String,list<TelosTouchSF.MassCreateTaskCompController.FieldInfo>> sectionWithFields = TelosTouchSF.MassCreateTaskCompController.getSectionNameVsFieldsMap('RecordTypeId');
        System.assert(Page.SessionID!= null);
        Test.stopTest();
    }
}