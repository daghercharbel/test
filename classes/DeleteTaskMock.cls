@isTest
global with sharing class DeleteTaskMock implements HttpCalloutMock {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param request ...
* @return HTTPResponse res ......
*/
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/plain');
        response.setHeader('instance-name', 'https://test2.systelospro.com');
        response.setBody('{"deleted":true}');
        response.setStatusCode(200);
        return response; 
    }
}