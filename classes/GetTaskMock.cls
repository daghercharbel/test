@isTest
global with sharing class GetTaskMock implements HttpCalloutMock{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......s
* @param req ......
* @return HTTPResponse res ......
*/
    global HTTPResponse respond(HTTPRequest req) {
        DateTime LAST_HOUR = System.NOW().addMinutes(60);
        String formatted = LAST_HOUR.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{ "id": "5fdb3b82d1fd841edbb45c20","assigned_user_id": "6089318bbe0d39c3a","name": "Trailb","status": "open","client_id": "5fdb350b42f1f61ee23b9696","client_name": "NA BA 17","description": "","created_by_id": "1","shared": false,"date_due": "2020-12-17T11:05:13.000Z","modified_at": "'+formatted+'"},{ "id": "5fdb3b82d1fd841bb45c20","name": "Trailb","status": "open","client_id": "5fdb350b42f1f61ee23b9696","client_name": "NA BA 17","description": "","created_by_id": "1","shared": false,"date_due": "2020-12-17T11:05:13.000Z","modified_at": "'+formatted+'"}]');
        res.setStatusCode(200);
        return res;
    }
}