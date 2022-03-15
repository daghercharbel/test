/**
* @author Cloud Analogy
* @date 02/08/2021
* @description MultiRequestMock class .
*/
public with sharing class MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Controller of the MultiObjectLookupController class .
	 * @param requests ......
*/
    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description HTTPResponse method .
	 * @param req ......
@return HTTPResponse ..
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else{
            return null;
        }
    }
    
}