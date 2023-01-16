@isTest
global with sharing class CreateRemoteSiteSettingMock implements HttpCalloutMock {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ...
* @return HTTPResponse res ......
*/
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"0rp5g000000pqRnAAI","success":true,"errors":[],"warnings":[]}');
        res.setStatusCode(200);
        return res;
    }
}