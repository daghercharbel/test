@isTest
global with sharing class TTUserConversationTestMock implements HttpCalloutMock{
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
        res.setBody('[{ "id": "5f528a81aa941c1bda3b0088", "content": "You are looking at buying a home or recreational property. ", "touchpoint_action_id": "", "touchpoint_step_id": "", "is_robot": true, "type": "text", "status": "",         "resource_url": "",         "deleted": false,         "sent_by": "",         "created_by": "",         "modified_by": "System",         "modified_at": "2020-09-04T18:42:09.550Z",         "created_at": "2020-09-04T17:45:55.856Z", "conversation_id": "5f527d53aa941c1bda3b0073"}]');
        res.setStatusCode(200);
        return res;
    }
}