@isTest
global with sharing class TTCampaignUserConversationMock implements HttpCalloutMock{
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
        res.setBody('{"id": "5f1ea4452512b42b00de68f7","created_at": "2020-07-27T09:54:13.569Z","created_by": "Himanshu Nigam","name": "Client Education","name_fr": "Client Education","touhpoint_template_id": "5f08c8770e7a9d038008d5f4","conversations": [{ "conversation_id": "5f1ea4452512b42b00de68f8", "completed_at": "2020-07-27T10:16:19.101Z", "opened_at": "2020-07-27T10:16:11.266Z", "status_touchpoint": "completed", "user_id": "5f1e88214b3173301", "contact_id": null, "user_name": "John Smith", "language": "en_US", "avatarId": null } ] }');
        res.setStatusCode(200);
        return res;
    }
}