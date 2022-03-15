@isTest
global class TelosTouchUtilityMock implements HttpCalloutMock {
    // Implement this interface method
             /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ....
* @return HTTPResponse res ....
*/
    global HTTPResponse respond(HTTPRequest req) {
        string endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(endpoint.contains('/api/v1/contacts/') && req.getMethod() != 'DELETE'){
            res.setBody('{"id": "6063293ee8d77e086922af87","instance": "https://test4.systelospro.com", "first_name": "TT utility","last_name": "id","email": "smrati.jaintt@cloudanalogy.com","user_id": null,"phone": "","language": "en_US","created_by": "6049d04b6fb5748e0","invited_at": null,"modified_at": "2021-03-30T13:45:00.000Z", "created_at": "2021-03-30T13:35:59.000Z", "last_login_date": null, "avatar_id": null, "deleted": true, "custom_fields": null,"preferences":{ "language": "en_US","notificationTouchpointSend": true},"accepts_calls": true,"type": "lead", "other_id": "0035g000001v4lOAAQ" }');
            res.setStatusCode(200);
        }else if(endpoint.contains('/api/v1/contacts/invite')){
            res.setBody('{"id": "6063293ee8d77e086922af87"}');
            res.setStatusCode(200);
        }else if(endpoint.contains('/api/v1/contacts/mass') && req.getMethod() == 'DELETE'){
            res.setBody('[{"id":"60e2f1c12cf3cea2af1d8a8e","deleted":true,"modified_at":"2021-07-05T13:39:25.323Z","modified_by":"6240d32f-a652-472c-85bf-42cb27dd2420"}]');
            res.setStatusCode(200);
        }else if(endpoint.contains('api/v1/users?email') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":"85ce4caf-6ba3-4b42-a33e-de9797dcda93","createdTimestamp":1623226810361,"username":"mohd.rais@cloudanalogy.com","enabled":true,"totp":false,"emailVerified":true,"firstName":"Mohd","lastName":"Rais","email":"mohd.rais@cloudanalogy.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["en-us"],"phone":["123467"],"picture":["/api/v1/attachments/null"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0,"access":{"manageGroupMembership":true,"view":true,"mapRoles":true,"impersonate":true,"manage":true}}]');
            res.setStatusCode(200);
        }else if(endpoint.contains('/api/v1/preferences') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"plan":"standard","actions":[],"locales":["en_US","fr_FR"],"clientPortal":false,"fakeDashboard":false,"mixpanelToken":"7d59c86115539c188202dadafe885ed4"}');
            res.setStatusCode(200);
        }else{
            res.setBody('{ "user": { "id": "5e95dc6839a36082d", "name": "Jad Chehlawi", "deleted": false, "isAdmin": true, "userName": "telostouch_advisor","token": "123", "password": "iVfG75z9CU9.lDwGySc.iTkkGWaBPRyJEq7o1EODInLbPJSf21pS5yOxta9HiuJLO33Kn3Q0kaXGqRoKs8pNn1", "salutationName": null, "firstName": "Jad", "lastName": "Chehlawi", "isActive": true, "isPortalUser": false, "isSuperAdmin": false, "title": "Advisor", "emailAddress": "nitesh+telostouch_advisor@telostouch.com", "phoneNumber": null, "gender": "", "createdAt": "2020-04-14 15:53:12", "userName2": null, "occupation": "None", "passwordGenerated": true, "integrationId": null, "integrationType": null, "integrationSource": null, "acceptedTermsOfUse": true, "acceptedTermsOfUseAt": "2020-04-14 11:54:00", "addressStreet": null, "addressCity": null, "addressState": null, "addressCountry": null, "addressPostalCode": null, "defaultTeamId": "5e95dc68455165000", "defaultTeamName": "Jad Chehlawi", "teamsIds": [ "5926fca6c9a784020", "5e95dc68455165000", "5eb5a1bfe4d45b69a", "5ea047ca503baf727", "5ea047caae48f3337", "5eea75398da5f0284", "5ef6413c4e2f9128d", "5ef6434ade485424c", "5efb6878dd44a4c96", "5efb6cd75ddaed7e4", "5f034f80427c57163", "5f343543c940c4cb6", "5f3c19f284851b1ac", "5f4aa7eba6f061112", "5f4aa9027f7751ba4", "5f50058844de005bb", "5f5027f50f0f344f8", "5f523c972ecd4edb5", "5f526a4d3121faa0a", "5f53614b8ec16621d" ], "teamsNames": { "5926fca6c9a784020": "Professionals", "5e95dc68455165000": "Jad Chehlawi", "5eb5a1bfe4d45b69a": "Eduardo Caceres", "5ea047ca503baf727": "first_name_00011375 last_name_00011375", "5ea047caae48f3337": "first_name_00024050 last_name_00024050", "5eea75398da5f0284": "Alejandro Caceres", "5ef6413c4e2f9128d": "wcww wcwrc", "5ef6434ade485424c": "qqa qa", "5efb6878dd44a4c96": "egtegt tgeetget", "5efb6cd75ddaed7e4": "wfwrf wrfwrfw", "5f034f80427c57163": "Nicky Android", "5f343543c940c4cb6": "John Smith", "5f3c19f284851b1ac": "sfhn sfv", "5f4aa7eba6f061112": "Thomas One", "5f4aa9027f7751ba4": "Timbo Set", "5f50058844de005bb": "efveqerv rve", "5f5027f50f0f344f8": "erg eg", "5f523c972ecd4edb5": "Alex Smith", "5f526a4d3121faa0a": "fhfnh qa Kemmer", "5f53614b8ec16621d": "Mohd Rais" }, "contactId": null, "contactName": null, "avatarName": null, "avatarId": null, "emailAddressList": [ "nitesh+telostouch_advisor@telostouch.com" ] }, "token": null, "language": "en_US", "announcements": []}');
            res.setStatusCode(200);
        }
        return res;
    }
}