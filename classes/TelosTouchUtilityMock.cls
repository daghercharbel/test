@isTest
global class TelosTouchUtilityMock implements HttpCalloutMock {
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
        }else if(endpoint.contains('/api/v1/templates') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":"62ab832e0801561673cd922a","name":"Your Registered Education Savings Plan","name_fr":"Votre régime enregistré dépargne études","description":null,"is_published":false,"deleted":false,"image_id":"62ab832e0801561673cd922b","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:26.725Z","modified_at":"2022-08-16T11:10:48.450Z","last_send_at":"2022-08-16T11:10:48.446Z","copy_from":null,"is_private":false},{"id":"62ab832d0801561673cd9205","name":"Your Retirement Planning","name_fr":"Planification de votre retraite","description":null,"is_published":false,"deleted":false,"image_id":"62ab832d0801561673cd9206","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:26.143Z","modified_at":"2022-08-16T11:02:45.626Z","last_send_at":"2022-08-16T11:02:45.613Z","copy_from":null,"is_private":false}]');
            res.setStatusCode(200);
        }else if(endpoint.contains('/preview/portalurl?language=en_US') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('https://sf1.systelospro.com/api/v1/templates/62ab832e0801561673cd922a/preview/public/email?lang=en_US&custom_messages=%5B%5D&access_token=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJqdkVwSWpZU3BBSDRXbFlTYllYc0ptNHNDdU1udmRDeGU5eEFlRFBTV2w4In0.eyJleHAiOjE2NjA2NTg0NjksImlhdCI6MTY2MDY1NDg2OSwianRpIjoiYTY4ZTcxNjYtN2M5ZS00M2E0LWFiNjUtNTIyYjM3MGQ2MmVlIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL3NmMSIsImF1ZCI6WyJzYWxlc2ZvcmNlIiwiYWNjb3VudCJdLCJzdWIiOiIyNTNhZjgzMS00Mzg2LTQ2NDUtOTYzZS1mMmY3Yzk4NzU5NTgiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJzYWxlc2ZvcmNlXzAwRDU0MDAwMDAwbURNbUVBTSIsInNlc3Npb25fc3RhdGUiOiIzNmZlNDVmYy1mOGIxLTQ4ZjMtYWMwYy1lZmQxODNkODAyZWIiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsInByb2Zlc3Npb25hbCJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiY3VzdG9tIG9mZmxpbmVfYWNjZXNzIHNhbGVzZm9yY2UiLCJzaWQiOiIzNmZlNDVmYy1mOGIxLTQ4ZjMtYWMwYy1lZmQxODNkODAyZWIiLCJncm91cHMiOlsiL3NhbGVzZm9yY2VfMDBENTQwMDAwMDBtRE1tRUFNL3Byb2Zlc3Npb25hbCJdfQ.QJ2-v700lvoCXxeqKtF-g8gpLf2VjkNQ_mSU3E45WTKD8wbaoqAuXs0_AXIXuIxGwlzhuNwKwkpQdtWK6VbEUdRvUD1GP_rqO1lUSu4RIaf6QchM3UhNmXFqpGeorWmqUWcR60ZUK1_hbqIWPsi7ASSHP5_RcmOfkbBUJzBayUQULfdXBOPZfPf1Cb3qzwDPIq5YNR9mskjLiQZfbbCR0OWVtNDLkDpgwbpScDWlY-ay-fCrmyLz3riq7sgXYl8TRLHzFFssv8h7w13q3Q5xZkV3fu66gUJaW4BfGAYocO0oXo4MiTVLz8iaN0sXUGNfMUf1r6PTtxcwNqzSW4XCcw');
            res.setStatusCode(200);
        }else if(endpoint.contains('/api/v1/touchpoint/templates/send') && req.getMethod() == 'GET'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"62fb7b388c07c43a3513e057","touchpoint_template_name":"Your Registered Education Savings Plan","touchpoint_template_name_fr":"Votre régime enregistré d études","questions":[{"question":"Would you like to discuss how you can optimize your RESP contributions?","key":"62ab832e0801561673cd9232","type":"button","answers":{"62ab832e0801561673cd9233":"Yes, I would like to discuss my contributions","62ab832e0801561673cd9234":"No, not at this time."},"question_fr":"Souhaitez-vous discuter de la manière dont vous pouvez optimiser vos cotisations à un REEE ?","answers_fr":{"62ab832e0801561673cd9233":"Oui,  discuter des mes contributions au compte REEE","62ab832e0801561673cd9234":"Merci, pas maintenant"}}],"questions_fr":[{"question":"Souhaitez-vous discuter de la manière dont vous pouvez optimiser vos cotisations à un REEE ?","key":"62ab832e0801561673cd9232","type":"button","answers":{"62ab832e0801561673cd9233":"Oui,  discuter des mes contributions au compte REEE","62ab832e0801561673cd9234":"Merci, pas maintenant"}}],"deleted":false,"is_email_action":false,"created_by_id":"253af831-4386-4645-963e-f2f7c9875958","modified_by":"253af831-4386-4645-963e-f2f7c9875958","modified_at":"2022-08-18T08:00:57.673Z","created_by":"User User","created_at":"2022-08-16T11:10:48.446Z","other_id":"70154000000YOpIAAW","has_customized_messages":false,"compliance_sent":false,"touchpoint_template_id":"62ab832e0801561673cd922a"}');
            res.setStatusCode(200);
        }
        else{
            res.setBody('{ "user": { "id": "5e95dc6839a36082d", "name": "Jad Chehlawi", "deleted": false, "isAdmin": true, "userName": "telostouch_advisor","token": "123", "password": "iVfG75z9CU9.lDwGySc.iTkkGWaBPRyJEq7o1EODInLbPJSf21pS5yOxta9HiuJLO33Kn3Q0kaXGqRoKs8pNn1", "salutationName": null, "firstName": "Jad", "lastName": "Chehlawi", "isActive": true, "isPortalUser": false, "isSuperAdmin": false, "title": "Advisor", "emailAddress": "nitesh+telostouch_advisor@telostouch.com", "phoneNumber": null, "gender": "", "createdAt": "2020-04-14 15:53:12", "userName2": null, "occupation": "None", "passwordGenerated": true, "integrationId": null, "integrationType": null, "integrationSource": null, "acceptedTermsOfUse": true, "acceptedTermsOfUseAt": "2020-04-14 11:54:00", "addressStreet": null, "addressCity": null, "addressState": null, "addressCountry": null, "addressPostalCode": null, "defaultTeamId": "5e95dc68455165000", "defaultTeamName": "Jad Chehlawi", "teamsIds": [ "5926fca6c9a784020", "5e95dc68455165000", "5eb5a1bfe4d45b69a", "5ea047ca503baf727", "5ea047caae48f3337", "5eea75398da5f0284", "5ef6413c4e2f9128d", "5ef6434ade485424c", "5efb6878dd44a4c96", "5efb6cd75ddaed7e4", "5f034f80427c57163", "5f343543c940c4cb6", "5f3c19f284851b1ac", "5f4aa7eba6f061112", "5f4aa9027f7751ba4", "5f50058844de005bb", "5f5027f50f0f344f8", "5f523c972ecd4edb5", "5f526a4d3121faa0a", "5f53614b8ec16621d" ], "teamsNames": { "5926fca6c9a784020": "Professionals", "5e95dc68455165000": "Jad Chehlawi", "5eb5a1bfe4d45b69a": "Eduardo Caceres", "5ea047ca503baf727": "first_name_00011375 last_name_00011375", "5ea047caae48f3337": "first_name_00024050 last_name_00024050", "5eea75398da5f0284": "Alejandro Caceres", "5ef6413c4e2f9128d": "wcww wcwrc", "5ef6434ade485424c": "qqa qa", "5efb6878dd44a4c96": "egtegt tgeetget", "5efb6cd75ddaed7e4": "wfwrf wrfwrfw", "5f034f80427c57163": "Nicky Android", "5f343543c940c4cb6": "John Smith", "5f3c19f284851b1ac": "sfhn sfv", "5f4aa7eba6f061112": "Thomas One", "5f4aa9027f7751ba4": "Timbo Set", "5f50058844de005bb": "efveqerv rve", "5f5027f50f0f344f8": "erg eg", "5f523c972ecd4edb5": "Alex Smith", "5f526a4d3121faa0a": "fhfnh qa Kemmer", "5f53614b8ec16621d": "Mohd Rais" }, "contactId": null, "contactName": null, "avatarName": null, "avatarId": null, "emailAddressList": [ "nitesh+telostouch_advisor@telostouch.com" ] }, "token": null, "language": "en_US", "announcements": []}');
            res.setStatusCode(200);
        }
        return res;
    }
}