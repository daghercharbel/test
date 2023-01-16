//For Task
@isTest
global class SFDataSyncWithTelosTouchMock2 implements HttpCalloutMock {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param request ...
* @return HTTPResponse response ......
*/
    global HTTPResponse respond(HTTPRequest request) {
        String endpoint = request.getEndpoint();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(endpoint.contains('https://test.com/api/v1/contacts/mass')){
            if(request.getMethod() == 'PUT'){
                response.setBody('[{"deviceToken":null,"id":"60e435f0d0c2a8a2a3da19bd","first_name":"Swapnil","last_name":"PUT Sen Keycloak 4","email":"demo@gmail.com","user_id":null,"phone":"","language":"en_US","created_by":"6240d32f-a652-472c-85bf-42cb27dd2420","invited_at":null,"modified_at":"2021-07-06T10:55:06.000Z","created_at":"2021-07-06T10:52:32.000Z","last_login_date":null,"avatar_id":null,"deleted":false,"custom_fields":null,"preferences":{"notificationTouchpointSend":true,"language":"en_US"},"accepts_calls":true,"type":"client","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420","other_id":null},{"deviceToken":null,"id":"60e435f0d0c2a8a2a3da19be","first_name":"Swapnil","last_name":"PUT Sen Keycloak 5","email":"random@gmail.com","user_id":null,"phone":"","language":"en_US","created_by":"6240d32f-a652-472c-85bf-42cb27dd2420","invited_at":null,"modified_at":"2021-07-06T10:55:06.000Z","created_at":"2021-07-06T10:52:32.000Z","last_login_date":null,"avatar_id":null,"deleted":false,"custom_fields":null,"preferences":{"notificationTouchpointSend":true,"language":"en_US"},"accepts_calls":true,"type":"client","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420","other_id":null}]');
                response.setStatusCode(200);
            }else if(request.getMethod() == 'POST'){
                response.setBody('{"created":[{"id":"60e435f0d0c2a8a2a3da19bd","other_id":null,"email":"demo@gmail.com"},{"id":"60e435f0d0c2a8a2a3da19be","other_id":null,"email":"random@gmail.com"}],"alreadyExists":[]}');
                response.setStatusCode(200);
            }
        }else {
            response.setBody('[{"id":"60e3019ed0c2a8a2a3da19a2","name":"sampleUpdatedbyShubham","description":"sampleUpdatedbyShubham","shared":true,"date_due":"2020-12-14T21:14:11.508Z","modified_date":"2021-07-06T08:06:30.622Z"}]}');
            response.setStatusCode(200);
        }
        return response; 
    }
}