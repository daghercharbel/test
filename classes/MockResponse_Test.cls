@isTest
global with sharing class MockResponse_Test implements HttpCalloutMock {
    // Implement this interface method
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param req ...
* @return HTTPResponse res ......
*/
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('FieldsName')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"5f1e880266a802a09","name":"John Smith","deleted":false,"salutationName":"NA","firstName":"John","lastName":"Smith","accountId":null,"title":null,"description":null,"emailAddress":"mohd.test@cloudanalogy.com","phoneNumber":"1234567890","doNotCall":false,"addressStreet":null,"addressCity":null,"addressState":null,"addressCountry":null,"addressPostalCode":null,"accountType":null,"createdAt":"2020-07-27 07:53:38","modifiedAt":"2020-08-10 09:56:41","lastLoginDate":"2020-07-27 15:46:30","status":"Single","birthday":null,"drinkPreference":null,"interestsHobbies":null,"position":"Other","income":null,"incorporated":false,"businessOwner":false,"age":null,"yearsInCanada":null,"occupation":null,"retirement":null,"businessPhone":null,"mobilePhone":null,"spouseName":null,"weddingAnniversary":null,"interests":null,"firmAnniversary":null,"notes":null,"birthdayUpcoming":null,"faxNumber":null,"otherPhone":null,"sINNumber":null,"languagePreference":null,"citizenship":null,"countryOfResidence":null,"locationOfIncomeTaxFiling":null,"corporateTaxID":null,"integrationId":null,"integrationType":null,"integrationSource":null,"companyName":null,"isDummyAccount":false,"inviteStatus":"completed","language":"en_US","incomeCurrency":null,"emailAddressData":[{"emailAddress":"mohd.test@cloudanalogy.com","lower":"mohd.test@cloudanalogy.com","primary":true,"optOut":false,"invalid":false}],"phoneNumberData":[{"phoneNumber":"1234567890","primary":true,"type":"Other"}],"accountName":null,"accountsIds":[],"accountsNames":{},"accountsColumns":{},"campaignId":null,"campaignName":null,"createdById":"5f08d05d6eed1d5b2","createdByName":"Himanshu Nigam","modifiedById":"5f08d05d6eed1d5b2","modifiedByName":"Himanshu Nigam","assignedUserId":"5f08d05d6eed1d5b2","assignedUserName":"Himanshu Nigam","teamsIds":["5f08d05d771e4e23d"],"teamsNames":{"5f08d05d771e4e23d":"Himanshu Nigam"},"portalUserId":null,"portalUserName":null,"originalLeadId":null,"originalLeadName":null,"incomeConverted":null,"defaultTeamId":null,"defaultTeamName":null,"userId":"5f1e88214b3173301","userName":"John Smith","isFollowed":true,"followersIds":["5f08d05d6eed1d5b2"],"followersNames":{"5f08d05d6eed1d5b2":"Himanshu Nigam"},"avatarName":null,"avatarId":null,"addressData":[],"isActive":true,"loginUsername":"md.imran@cloudanalogy.com"}');
            res.setStatusCode(200);
        }else if (req.getEndpoint().contains('/api/v1/organization/signup')) {
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id":"6196930c5811ef036c590962","expiration":3600}');
        }else if(req.getEndpoint().contains('/api/v1/organization') && req.getEndpoint().contains('?is_enterprise=true')){
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('');
        }
        return res;
    }
}