@isTest
global class TelosTouchUtilityMock1 implements HttpCalloutMock {
    // Implement this interface method
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ....
* @return HTTPResponse res ....
*/
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        //string endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-Total-Count', '2');
        res.setHeader('X-total-count', '2');
        if(req.getEndpoint().contains('/api/v1/user/settings')){
            res.setBody('{"language":"fr_FR","timezone":"America/Toronto","clientPortal":false,"notificationTouchpointSend":true,"notificationTouchpointCompleted":false,"notificationActionCreate":false}');
        }else if(req.getEndpoint() == 'https://test.com/api/v1/users/test2'){
            res.setBody('{"id":"3083da3a-4097-4b7a-a9f1-8d3c36822823","createdtimestamp":1639557177581,"username":"swapnil.sen+837928782397@telostouch.com","totp":false,"emailVerified":false,"firstName":"Swapnil","lastName":"Sen mailto:test","email":"swapnil.sen+837928782397@telostouch.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["fr-fr"],"phone":["8792379382"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0,"access":{"manageGroupMembership":true,"view":true,"mapRoles":true,"impersonate":true,"manage":true},"roles":[{"id":"b5908d73-45ec-46ca-8dca-2bc5594ebe83","name":"offline_access","description":"${role_offline-access}","composite":false,"clientRole":false,"containerId":"app"},{"id":"4302e86a-a42c-4021-8dfd-1b7c6f596938","name":"uma_authorization","description":"${role_uma_authorization}","composite":false,"clientRole":false,"containerId":"app"},{"id":"df5a9a35-6289-4639-93cc-dc2820f74f6b","name":"professional","composite":false,"clientRole":false,"containerId":"app"}],"groups":[{"id":"cb75ac8f-09c9-4d79-a981-76d1bc53c4ca","name":"professional","path":"/salesforce/professional"}]}');
        }
        else{
            res.setBody('{"id":"3083da3a-4097-4b7a-a9f1-8d3c36822823","createdtimestamp":1639557177581,"username":"swapnil.sen+837928782397@telostouch.com","enabled":true,"totp":false,"emailVerified":false,"firstName":"Swapnil","lastName":"Sen mailto:test","email":"swapnil.sen+837928782397@telostouch.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["fr-fr"],"phone":["8792379382"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0,"access":{"manageGroupMembership":true,"view":true,"mapRoles":true,"impersonate":true,"manage":true},"roles":[{"id":"b5908d73-45ec-46ca-8dca-2bc5594ebe83","name":"offline_access","description":"${role_offline-access}","composite":false,"clientRole":false,"containerId":"app"},{"id":"4302e86a-a42c-4021-8dfd-1b7c6f596938","name":"uma_authorization","description":"${role_uma_authorization}","composite":false,"clientRole":false,"containerId":"app"},{"id":"df5a9a35-6289-4639-93cc-dc2820f74f6b","name":"professional","composite":false,"clientRole":false,"containerId":"app"}],"groups":[{"id":"cb75ac8f-09c9-4d79-a981-76d1bc53c4ca","name":"professional","path":"/salesforce/professional"}]}');
        }
        res.setStatusCode(200);
        return res;
    }
}