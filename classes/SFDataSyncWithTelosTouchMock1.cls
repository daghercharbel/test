//For Lead and Contacts
@isTest
global class SFDataSyncWithTelosTouchMock1 implements HttpCalloutMock {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param request ...
* @return HTTPResponse response ......
*/
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().contains('/api/v1/organization/signup')) {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"id":"6196930c5811ef036c590962","expiration":3600}');
        }else if(request.getEndpoint().contains('/api/v1/organization') && request.getEndpoint().contains('?is_enterprise=true')){
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(404);
            response.setBody('');
        }else{
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('X-Total-Count', '2');
            response.setHeader('X-total-count', '2');
            response.setBody('{"emailAddress": "mojitihejgov@gmail.com","id":"5f4a2f6fbbf7da0b8","assignedUserId":"5e95dc6839a36082d","assignedUserName":"telostouch_advisor"}');
            response.setStatusCode(200);
        }
        return response; 
    }
}