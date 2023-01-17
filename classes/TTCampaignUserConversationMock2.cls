@isTest
global with sharing  class TTCampaignUserConversationMock2 implements HttpCalloutMock{
    /**
	  * @author Cloud Analogy
	  * @date 02/08/2021
	  * @description ......
	  * @param req ...
	  * @return HTTPResponse res ......
	  */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "answers": [ { "id": "5f5a3cdebad093641a5b412f", "conversation_id": "5f5a3ca7bad093641a5b4129", "questionsandanswers": [ { "question": "Thanks for watching or reading, would you like to learn more regarding any of the below:", "answers": [ "Portfolio management & trades " ], "type": "button", "key": "5f08c8770e7a9d038008d811" }, { "question": "Protecting your assets is our primary responsibility. If you would like to discuss trade decisions further, please let us know.", "answers": [ " fine, thank you" ], "type": "button", "key": "5f08c8770e7a9d038008d816" } ], "user_id": "5f3154b14fcfcde2c", "modified_by": "System", "modified_at": "2020-09-10T14:49:17.049Z", "created_by": "System", "created_at": "2020-09-10T14:49:02.273Z", "touchpoint_template_id": "5f08c8770e7a9d038008d5f5" } ], "questions": [ { "question": "Thanks for watching or reading, would you like to learn more regarding any of the below:", "key": "5f08c8770e7a9d038008d811", "type": "button", "answers": [ "Portfolio management & trades ", "COVID-19 relief government initiatives ","m fine, thank you" ], "question_fr":"en avoir pris connaissance. Aimeriez-vous en savoir plus sur lun des sujets suivants?", "answers_fr": [ "Gestion de portefeuille et transactions", "COVID-19 mesures de support gouvernementales", "Non, merci" ] }, { "question": "Protecting your assets is our primary responsibility. If you would like to discuss trade decisions further, please let us know.", "key": "5f08c8770e7a9d038008d816", "type": "button", "answers": [ "Yes I would like to lear r" fine, thank you" ], "question_fr": "La protection de vos actifs est notre première responsabilité. Laissez-nous savoir si vous souhaitez discuter plus en détails de la gestion de portefeuille", "answers_fr": [ "Oui,aimerais en savoir plus", "Non, merci" ] }, { "question": "COVID-19 has been a difficult time. If you would like to discuss for any of these programs further, please let us know.", "key": "5f08c8770e7a9d038008d81b", "type": "button", "answers": [ "Yes I would like to learn more", "m fine, thank you " ], "question_fr": "La COVID-19 a amené son lot de difficultés. Laissez-nous savoir si vous souhaitez discuter plus en détails de ces mesures gouvernementales", "answers_fr": [ "Oui, jimerais en savoir plus", "Non, merci" ] } ] }');
        res.setStatusCode(200);
        return res;
    }
}