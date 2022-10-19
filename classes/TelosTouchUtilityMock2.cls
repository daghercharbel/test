@isTest
global class TelosTouchUtilityMock2 implements HttpCalloutMock {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ....
* @return HTTPResponse res ....
*/
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-Total-Count', '1');
        res.setHeader('X-total-count', '1');
        if(req.getEndpoint().contains('abc')){
            res.setBody('{"id":"62179c6ddb89ab621bb6878b","lastLoginDate":"2022-02-25T10:19:00.000Z","userId":"d15736ce-1239-4c4e-b196-6f505b34cec7"}');            
        }else if(req.getEndpoint().contains('bcd')){
            res.setBody('{"id":"62179c6ddb89ab621bb6878b","lastLoginDate":null,"userId":null}');
        }else if(req.getEndpoint().contains('cde')){
            res.setBody('{"id":"62179c6ddb89ab621bb6878b","lastLoginDate":null,"userId":"d15736ce-1239-4c4e-b196-6f505b34cec7"}');
        }else if(req.getEndpoint().contains('user123')){
            res.setBody('{"id":"62179c6ddb89ab621bb6878b","lastLoginDate":"2022-02-25T10:19:00.000Z","userId":"d15736ce-1239-4c4e-b196-6f505b34cec7"}');
        }else{
            res.setBody('{"id":"62179c6ddb89ab621bb6878b","lastLoginDate":null,"userId":"d15736ce-1239-4c4e-b196-6f505b34cec7"}');
        }
        res.setStatusCode(200);
        return res;
    }
}