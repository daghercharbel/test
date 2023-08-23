@isTest
global class GetCampaignsFromTTMock implements HttpCalloutMock{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ...
* @return HTTPResponse res ......
*/
    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(endpoint.contains('/clients/reminder')){
            res.setBody('Reminder Sent');
            res.setStatusCode(200);
        } else if(endpoint.contains('/api/v2/campaign2/clients') && req.getMethod() == 'PUT'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('');
            res.setStatusCode(200);
        } else if(endpoint.contains('/api/v1/touchpoints/') && endpoint.contains('/clients') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "id": "5f527d53aa941c1bda3b0071", "created_at": "2020-09-04T17:45:55.826Z", "created_by": "Jad Chehlawi", "name": "Considering Purchase of a Property", "name_fr": null, "touchpoint_template_id": "5e947ef0574573795fa7f9a5", "conversations": [ { "conversation_id": "5f527d53aa941c1bda3b0073", "completed_at": "2020-09-04T18:42:23.772Z", "opened_at": "2020-09-04T17:59:38.301Z", "status_touchpoint": "completed", "user_id": "5f526a4d219d3865a", "contact_id": "5f5267ce48c9a601c", "user_name": null, "language": null, "avatarId": null } ] }');
            res.setStatusCode(200);
        } else if(endpoint.contains('clients')){
            res.setBody('{"id":"60e2ea83558b4da2a3b1e813","created_at":"2021-07-05T11:18:27.657Z","created_by":"Mohd Rais","name":"Image Touchpoint","name_fr":"nouveau modèle","touchpoint_template_id":"60dadf2d0cb607a3ced073d6","conversations":[{"conversation_id":"60e2ea83558b4da2a3b1e815","completed_at":"2021-07-05T11:22:55.681Z","opened_at":"2021-07-05T11:22:21.287Z","status_touchpoint":"completed","user_id":"2fdb10a0-07a1-4fc4-8d9a-46f4f6cf7429","user_name":"HR SF Lead M1 5-7","contact_id":"60e2c45fd0c2a8a2a3da197c","avatarId":null,"language":"en_US"},{"conversation_id":"60e2ea83558b4da2a3b1e816","completed_at":"2021-07-05T11:31:23.519Z","opened_at":"2021-07-05T11:31:17.176Z","status_touchpoint":"completed","user_id":"c0ca17d3-bc40-40a2-8682-0c52bce11655","user_name":"HR SF Contact M1 5-7","contact_id":"60e2c4b52cf3cea2af1d8a86","avatarId":null,"language":"en_US"}]}');
            res.setStatusCode(200);
        } else if(endpoint.contains('https://test.com/api/v1/touchpoints/')){
            res.setBody('{"id": "5fe0d1ba1132491ed677d03b","created_at": "2020-12-21T16:47:54.190Z","created_by": "Admin Admin","name": "DEPT","name_fr": "nouveau modèle","touchpoint_template_id": "5fe0d1704021971edd8a027b","conversations": [{"conversation_id": "5fe0d1ba1132491ed677d03c","completed_at": "2020-12-21T16:49:27.815Z","opened_at": "2020-12-21T16:49:27.722Z","status_touchpoint": "completed","user_id": "5fe0d1ba4ddddf67f","user_name": null,"contact_id": "5fe0d0c0afd1291ed6c51c54","avatarId": null,"language": "en_US"}]}}');
            res.setStatusCode(200);
        } else {
            res.setBody('[{"id": "5fe0d1ba1132491ed677d03b","touchpoint_template_name": "Post Tax Return Follow-Up","created_at": "2020-12-21T16:47:54.190Z","created_by": "Admin Admin","created_by_id": "85ce4caf-6ba3-4b42-a33e-de9797dcda93","name": "DEPT","name_fr": "nouveau modèle","touchpoint_template_id": "5fe0d1704021971edd8a027b","conversations": [{"conversation_id": "5fe0d1ba1132491ed677d03c","completed_at": "2020-12-21T16:49:27.815Z","opened_at": "2020-12-21T16:49:27.722Z","status_touchpoint": "completed","user_id": "5fe0d1ba4ddddf67f","user_name": null,"contact_id": "5fe0d0c0afd1291ed6c51c54","avatarId": null,"language": "en_US"}]}]');
            res.setStatusCode(200);
        }
        return res;
    }
}