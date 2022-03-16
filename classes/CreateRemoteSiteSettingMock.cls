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
        res.setBody('UpsertResult:[apex_schema_type_info=(http://soap.sforce.com/2006/04/metadata, true, false), created=false, created_type_info=(created, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), errors=null, errors_type_info=(errors, http://soap.sforce.com/2006/04/metadata, null, 0, -1, false), field_order_type_info=(created, errors, fullName, success), fullName=FOR_REST_API_CALL, fullName_type_info=(fullName, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), success=true, success_type_info=(success, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false)], UpsertResult:[apex_schema_type_info=(http://soap.sforce.com/2006/04/metadata, true, false), created=false, created_type_info=(created, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), errors=null, errors_type_info=(errors, http://soap.sforce.com/2006/04/metadata, null, 0, -1, false), field_order_type_info=(created, errors, fullName, success), fullName=google, fullName_type_info=(fullName, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), success=true, success_type_info=(success, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false)]');
        res.setStatusCode(200);
        return res;
    }
}