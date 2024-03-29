@isTest
public with sharing class SingleRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;
	/**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description ......
  * @param code ...
  * @param status ...
  * @param body ...
  * @param responseHeaders ...
  */
		public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}
	/**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description ......
  * @param code ...
  * @param status ...
  * @param body ...
  * @param responseHeaders ...
  */
		public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}
	/**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description ......
  * @param req ...
  * @return HTTPResponse resp ......
  */
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}