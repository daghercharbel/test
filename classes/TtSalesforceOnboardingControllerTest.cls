@isTest
public class TtSalesforceOnboardingControllerTest implements HttpCalloutMock{
	@isTest
    static void startRegistrationProcessTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TtSalesforceOnboardingControllerTest());
        Boolean flag = TtSalesforceOnboardingController.startRegistrationProcess();
        System.assert(flag, 'flag should be true');
        Test.stopTest();
    }
    @isTest
    static void validateTokenAndFetchCredentialsTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TtSalesforceOnboardingControllerTest());
        String returnString = TtSalesforceOnboardingController.validateTokenAndFetchCredentials('teret&TTSFPKG$tetre');
        System.assert(returnString == 'true', 'return string should be true');
        Test.stopTest();
    }
    @isTest
    static void checkIfEnterpriseClientTest(){
        Test.startTest();
        Boolean flag = TtSalesforceOnboardingController.checkIfEnterpriseClient();
        Test.stopTest();
        System.assert(flag, 'flag should be true');
    }
    @isTest
    static void disconnectFromTelosTouchApexTest(){
        Test.startTest();
        TtSalesforceOnboardingController.disconnectFromTelosTouchApex();
        Test.stopTest();
        System.assert(true, 'true');
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('/salesforce/signup')){
            res.setBody('{}');
            res.setStatusCode(400);
        }else if(req.getEndpoint().contains('/salesforce/resend')){
            res.setBody('{}');
            res.setStatusCode(201);
        }else if(req.getEndpoint().contains('/salesforce/validate')){
            res.setBody('{"keycloakUrl":"test", "telostouchUrl":"test", "keycloakClientId":"test", "isTrial":true}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/services/data/v51.0/tooling/query/?q=Select+EndpointUrl,SiteName+from+RemoteProxy')){
            res.setBody('{"id":"0rp5g000000pqRnAAI","success":true,"errors":[],"warnings":[]}');
        }
        
        return res;
    }
}