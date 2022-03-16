@isTest
public class SessionIDControllerTest {
    @isTest static void getSessionIdTest(){
        Test.startTest();
        	String sessionId = SessionIDController.getSessionId(Page.SessionID);
        System.assertEquals(sessionId.length()>0,true);
        Test.stopTest();
    }
}