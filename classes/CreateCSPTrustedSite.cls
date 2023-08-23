public with sharing class CreateCSPTrustedSite {

    /*
    if(!CreateCSPTrustedSite.checkRecord(aUrl)){
        CreateCSPTrustedSite.createRecord(aUrl);
    }
    */

    public static Boolean checkRecord(String aUrl){
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v57.0/tooling/query/?q=Select+EndpointUrl+from+CspTrustedSite');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);
        string resbody = res.getBody();
        String respMessage = 'Response Status Code: '+res.getstatusCode()+' | Response Body: '+resbody;
        System.debug('CreateCSPTrustedSite.checkRecord: '+respMessage);

        map<String,Object> aObject = (map<String,Object>)JSON.deserializeUntyped(resbody);
        List<Object> lstRecord = new list<Object>();
        if(aObject.containsKey('records')){
            lstRecord = (List<Object>)aObject.get('records');
        }

        list<String> lstSiteName = new list<String>();
        for(Object record : lstRecord){
            map<String,Object> mapRecord = (map<String,Object>)record;
            lstSiteName.add((String)mapRecord.get('EndpointUrl'));
        }

        return lstSiteName.contains(aUrl);

    }

    public static void createRecord(String aUrl){
        
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/data/v57.0/tooling/sobjects/CspTrustedSite/';
        string method = 'POST';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod(method);

        String name = aUrl.substringBetween('://','.');
        if(name.contains('-')){ name = name.replace('-', '_'); }
        request.setBody('{"DeveloperName":"'+name+'", "context":"All", "endpointUrl":"'+aUrl+'", "isActive":true, "isApplicableToConnectSrc": true}');

        Http http = new Http();
        HttpResponse res = http.send(request);
        String respMessage = 'Response Status Code: '+res.getstatusCode()+' | Response Body: '+res.getBody();
        System.debug('CreateCSPTrustedSite.createRecord: '+respMessage);

    }
}