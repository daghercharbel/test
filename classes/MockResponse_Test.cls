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
      res.setBody(
        '{"id":"5f1e880266a802a09","name":"John Smith","deleted":false,"salutationName":"NA","firstName":"John","lastName":"Smith","accountId":null,"title":null,"description":null,"emailAddress":"mohd.test@cloudanalogy.com","phoneNumber":"1234567890","doNotCall":false,"addressStreet":null,"addressCity":null,"addressState":null,"addressCountry":null,"addressPostalCode":null,"accountType":null,"createdAt":"2020-07-27 07:53:38","modifiedAt":"2020-08-10 09:56:41","lastLoginDate":"2020-07-27 15:46:30","status":"Single","birthday":null,"drinkPreference":null,"interestsHobbies":null,"position":"Other","income":null,"incorporated":false,"businessOwner":false,"age":null,"yearsInCanada":null,"occupation":null,"retirement":null,"businessPhone":null,"mobilePhone":null,"spouseName":null,"weddingAnniversary":null,"interests":null,"firmAnniversary":null,"notes":null,"birthdayUpcoming":null,"faxNumber":null,"otherPhone":null,"sINNumber":null,"languagePreference":null,"citizenship":null,"countryOfResidence":null,"locationOfIncomeTaxFiling":null,"corporateTaxID":null,"integrationId":null,"integrationType":null,"integrationSource":null,"companyName":null,"isDummyAccount":false,"inviteStatus":"completed","language":"en_US","incomeCurrency":null,"emailAddressData":[{"emailAddress":"mohd.test@cloudanalogy.com","lower":"mohd.test@cloudanalogy.com","primary":true,"optOut":false,"invalid":false}],"phoneNumberData":[{"phoneNumber":"1234567890","primary":true,"type":"Other"}],"accountName":null,"accountsIds":[],"accountsNames":{},"accountsColumns":{},"campaignId":null,"campaignName":null,"createdById":"5f08d05d6eed1d5b2","createdByName":"Himanshu Nigam","modifiedById":"5f08d05d6eed1d5b2","modifiedByName":"Himanshu Nigam","assignedUserId":"5f08d05d6eed1d5b2","assignedUserName":"Himanshu Nigam","teamsIds":["5f08d05d771e4e23d"],"teamsNames":{"5f08d05d771e4e23d":"Himanshu Nigam"},"portalUserId":null,"portalUserName":null,"originalLeadId":null,"originalLeadName":null,"incomeConverted":null,"defaultTeamId":null,"defaultTeamName":null,"userId":"5f1e88214b3173301","userName":"John Smith","isFollowed":true,"followersIds":["5f08d05d6eed1d5b2"],"followersNames":{"5f08d05d6eed1d5b2":"Himanshu Nigam"},"avatarName":null,"avatarId":null,"addressData":[],"isActive":true,"loginUsername":"md.imran@cloudanalogy.com"}'
      );
      res.setStatusCode(200);
    } else if (req.getEndpoint().contains('/api/v1/organization/signup')) {
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      res.setBody('{"id":"6196930c5811ef036c590962","expiration":3600}');
    } else if (
      req.getEndpoint().contains('/api/v1/organization') &&
      req.getEndpoint().contains('?is_enterprise=true')
    ) {
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      res.setBody('');
    } else if (req.getEndpoint().contains('/api/v1/templates')) {
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      res.setBody(
        '[{"id":"62ab832c0801561673cd9173","name":"How can we serve you better?","name_fr":"Comment mieux vous servir ?","description":null,"is_published":false,"deleted":false,"image_id":"62ab832c0801561673cd9174","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:24.370Z","modified_at":"2022-06-20T15:50:23.258Z","last_send_at":"2022-06-20T15:50:23.233Z","copy_from":null,"is_private":false},{"id":"62ab832e0801561673cd922a","name":"Your Registered Education Savings Plan","name_fr":"Votre rgime enregistr pargne tudes","description":null,"is_published":false,"deleted":false,"image_id":"62ab832e0801561673cd922b","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:26.725Z","modified_at":"2022-06-20T11:01:03.564Z","last_send_at":"2022-06-20T11:01:03.548Z","copy_from":null,"is_private":false},{"id":"62ab832c0801561673cd918a","name":"Our Meeting Preparation","name_fr":"Planification de notre rencontre","description":null,"is_published":false,"deleted":false,"image_id":"62ab832c0801561673cd918b","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:24.656Z","modified_at":"2022-06-16T19:23:24.656Z","last_send_at":"2022-06-09T17:38:09.301Z","copy_from":null,"is_private":false},{"id":"62ab832d0801561673cd91e8","name":"Contributions to your RRSP & TFSA","name_fr":"Cotisations à vos REER et CELI","description":null,"is_published":false,"deleted":false,"image_id":"62ab832d0801561673cd91e9","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:25.807Z","modified_at":"2022-06-16T19:23:25.807Z","last_send_at":"2022-06-03T17:37:45.716Z","copy_from":null,"is_private":false},{"id":"62ab832d0801561673cd91d0","name":"Your RRSP contribution","name_fr":"Cotisation à votre Rgime enregistr pargne-retraite","description":null,"is_published":false,"deleted":false,"image_id":"62ab832d0801561673cd91d1","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:25.581Z","modified_at":"2022-06-16T19:23:25.581Z","last_send_at":"2022-06-03T17:35:24.250Z","copy_from":null,"is_private":false},{"id":"62ab832d0801561673cd91c0","name":"Congratulations! The family is growing!","name_fr":"La famille s\'agrandit ! Flicitations !","description":null,"is_published":false,"deleted":false,"image_id":"62ab832d0801561673cd91c1","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:25.201Z","modified_at":"2022-06-16T19:23:25.201Z","last_send_at":"2022-06-03T17:33:12.062Z","copy_from":null,"is_private":false},{"id":"62ab832c0801561673cd91a8","name":"Your Tax-Free Savings Account","name_fr":"Votre compte pargne libre impôt","description":null,"is_published":false,"deleted":false,"image_id":"62ab832c0801561673cd91a9","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:24.954Z","modified_at":"2022-06-16T19:23:24.954Z","last_send_at":"2022-06-03T17:30:47.582Z","copy_from":null,"is_private":false},{"id":"62ab832e0801561673cd9215","name":"Our latest Newsletter","name_fr":"Notre plus rcente infolettre","description":null,"is_published":false,"deleted":false,"image_id":"62ab832e0801561673cd9216","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:26.350Z","modified_at":"2022-06-16T19:23:26.350Z","last_send_at":"2022-06-03T17:27:36.777Z","copy_from":null,"is_private":false},{"id":"62ab832d0801561673cd9205","name":"Your Retirement Planning","name_fr":"Planification de votre retraite","description":null,"is_published":false,"deleted":false,"image_id":"62ab832d0801561673cd9206","system_id":null,"created_by":"40c5749c-5bca-4812-8f11-4c9183364314","modified_by":"","created_at":"2022-06-16T19:23:26.143Z","modified_at":"2022-06-16T19:23:26.143Z","last_send_at":"2022-06-03T17:24:07.013Z","copy_from":null,"is_private":false}]'
      );
    }
    return res;
  }
}
