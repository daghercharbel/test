/**
* @author Cloud Analogy
* @date 02/08/2021
* @description CreateRemoteSiteSetting class is is using to create a remote site setting.
*/
public with sharing class CreateRemoteSiteSetting {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ...
* @param remoteURL
* @param name
* @return String name ....
*/
    public static String getremoteSiteSetting(String remoteURL, String name) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/services/data/v44.0/tooling/query/?q=Select+EndpointUrl,SiteName+from+RemoteProxy'
        );
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        string resbody = res.getBody();
        remotesitesettingswrapper rss = new remotesitesettingswrapper();
        rss = (remotesitesettingswrapper) System.JSON.deserialize(
            resbody,
            remotesitesettingswrapper.class
        );
        set<String> epset = new Set<String>();
        set<String> sitenameset = new Set<String>();
        for (Integer i = 0; i < rss.size; i++) {
            epset.add(rss.records[i].EndpointUrl);
            sitenameset.add(rss.records[i].SiteName);
        }
        if (!epset.contains(remoteURL)) {
            if (!sitenameset.contains(name)) {
                return name;
            } else {
                name = name.replace(name, 'TT_' + name);
            }
            return name;
        } else {
            return 'Already Exists!';
        }
    }
    @future(callout=true)
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to remote Site Setting.
* @param remoteURL stores the remoteSiteSetting URL
* @param name stores the name
*/
    public static void remoteSiteSetting(String remoteURL, String name) {
        try {
            //Integer usagelimit, maxlimit;
            String name1 = getremoteSiteSetting(remoteURL, name);
            if (name1 != 'Already Exists!') {
                String json =
                    '{"FullName":"' +
                    name1 +
                    '","Metadata":{"disableProtocolSecurity":false,"isActive":true,"url":"' +
                    remoteURL +
                    '","urls":null,"description":"For TelosTouch"}}';
                String endpoint =
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/services/data/v41.0/tooling/sobjects/RemoteProxy/';
                string method = 'POST';
                HttpRequest request = new HttpRequest();
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                request.setHeader('Content-Type', 'application/json');
                request.setEndpoint(endpoint);
                request.setMethod(method);
                request.setBody(json);
                Http http = new Http();
                /*List<System.OrgLimit> limits = OrgLimits.getAll();
for (System.OrgLimit aLimit: limits){
if(aLimit.getName() == 'DailyApiRequests'){
usagelimit = aLimit.getValue();
maxlimit = aLimit.getLimit();
}
}
if(usagelimit < maxlimit){*/
                //HttpResponse response = 
                http.send(request);
                //system.debug('response::' + response);
                /* } else{
UserTriggerHandler.createLogRecord('Error','Org daily API requests limit has been exceeded!', 0);
}*/
            }
        } catch (Exception ex) {
            system.debug(LoggingLevel.WARN,'Message::' +ex.getMessage() +'Line No::' +ex.getLineNumber());
            //UserTriggerHandler.createLogRecord('failed','Create Remote Site:'+stList2[0]+'.com', 0);
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to remote Site Setting.
* @param remoteURL stores the remoteSiteSetting URL
* @param name stores the name
* @return HTTPResponse response ....
*/
    public static HTTPResponse remoteSiteSetting1(String remoteURL, String name) {
        try {
            //Integer usagelimit, maxlimit;
            String json =
                '{"FullName":"' +
                name +
                '","Metadata":{"disableProtocolSecurity":false,"isActive":true,"url":"' +
                remoteURL +
                '","urls":null,"description":"For TelosTouch"}}';
            String endpoint =
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/services/data/v41.0/tooling/sobjects/RemoteProxy/';
            string method = 'POST';
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(endpoint);
            request.setMethod(method);
            request.setBody(json);
            Http http = new Http();
            /*List<System.OrgLimit> limits = OrgLimits.getAll();
for (System.OrgLimit aLimit: limits){
if(aLimit.getName() == 'DailyApiRequests'){
usagelimit = aLimit.getValue();
maxlimit = aLimit.getLimit();
}
}
if(usagelimit < maxlimit){*/
            HttpResponse response = http.send(request);
            return response;
            /* } else{
UserTriggerHandler.createLogRecord('Error','Org daily API requests limit has been exceeded!', 0);
return null;
}*/
        } catch (Exception ex) {
            String[] stList = ex.getMessage().split('=');
            String[] stList2 = stList[1].split('.com');
            UserTriggerHandler.createLogRecord(
                System.Label.Failed_Text,
                'Create Remote Site: '+
                stList2[0] +
                '.com', 'Créer site à distance: '+stList2[0] + '.com',
                0
            );
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class remotesitesettingswrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public Integer size { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public List<Records> records { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class Records {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String EndpointUrl { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String SiteName { get; set; }
    }
}