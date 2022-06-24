/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTFilterUserController class is used to get filter user which is based on Question and Answer.We are using a  custom component on Camapign record view page.
*/
public with sharing class TTFilterUserController {
    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchSF.TelosTouchUtility.getCustomMetadata();
    private static final TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential = TelosTouchSF.TelosTouchUtility.getAuthenticationCustomMetadata();
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method queries the details of campaigns.
* @param campainId stores a id of campaign.
* @return TTDoinitWrapper ttDoinitWrapperObj ....
*/
    @AuraEnabled
    public static TTDoinitWrapper doinitApex(String campainId){
        try{
            if(campainId != null){
                List<TelosTouchSF__Insights__c> conversationUserList = new List<TelosTouchSF__Insights__c>();
                TTDoinitWrapper ttDoinitWrapperObj = new TTDoinitWrapper();
                String question = '';
                List<Campaign> campaignList = new List<Campaign>();
                if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() &&
                   Schema.sObjectType.Campaign.fields.CreatedDate.isAccessible() && Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
                   Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible()){
                       campaignList= [SELECT Id,Name,TelosTouchSF__Questions__c,CreatedDate FROM Campaign WHERE Id=:campainId];
                   }
                if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.TelosTouchSF__Insights__c.isQueryable() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.Id.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isAccessible()){
                       conversationUserList = [SELECT Id,
                                               Name,
                                               TelosTouchSF__Conversation_Id__c,
                                               TelosTouchSF__Campaign2__c,
                                               TelosTouchSF__Contact__c,
                                               TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c,
                                               TelosTouchSF__Contact__r.TelosTouchSF__Subscribed__c  ,
                                               TelosTouchSF__Contact__r.Name,
                                               TelosTouchSF__Lead__r.Name,
                                               TelosTouchSF__Lead__r.TelosTouchSF__Subscribed__c  ,
                                               TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c,
                                               TelosTouchSF__Lead__c,
                                               TelosTouchSF__Answers__c,
                                               TelosTouchSF__Completed_At__c,
                                               TelosTouchSF__Opened_At__c
                                               FROM TelosTouchSF__Insights__c
                                               WHERE TelosTouchSF__Campaign2__c =: campainId  LIMIT 10000];
                   }
                for(Campaign campaignObj : campaignList){
                    question = (campaignObj.TelosTouchSF__Questions__c).unescapeHtml4();
                    question = question.replaceAll('<p>', '');
                }
                if(String.isNotBlank(question)){
                    List<Object> questionList = (List<Object>)JSON.deserializeUntyped(question);
                    if(questionList != null && questionList.size() > 0){
                        for(Object questionObj : questionList){
                            QuestionAnswerWrapper questionAnswerWrapperObj = new QuestionAnswerWrapper();
                            Map<String, Object> questionMap1 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(questionObj));
                            if(questionMap1.containsKey('question')){
                                questionAnswerWrapperObj.question = String.valueOf(questionMap1.get('question'));
                                questionAnswerWrapperObj.questionKey = String.valueOf(questionMap1.get('key'));
                                questionAnswerWrapperObj.questionType = String.valueOf(questionMap1.get('type'));
                            }
                            if(questionMap1.containsKey('question_fr')){
                                questionAnswerWrapperObj.question_fr = String.valueOf(questionMap1.get('question_fr'));
                            }
                            if(questionMap1.containsKey('answers') && !JSON.serialize(questionMap1.get('answers')).startsWith('[')){
                                //List<Object> answerList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(questionMap1.get('answers')));
                                Map<String, Object> answerMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(questionMap1.get('answers')));
                                if(answerMap != null){
                                    if(answerMap.values() != null && answerMap.values().size() > 0){
                                        for(String answerKey : answerMap.keySet()){
                                            PicklistValue  picklistValueObj = new PicklistValue();
                                            picklistValueObj.key = answerKey;
                                            picklistValueObj.question =  String.valueOf(answerMap.get(answerKey));
                                            
                                            questionAnswerWrapperObj.picklistValueList.add(picklistValueObj);
                                        }
                                        PicklistValue  picklistValueObj = new PicklistValue();
                                        picklistValueObj.key = 'null';
                                        picklistValueObj.question =  'N/A';
                                        
                                        questionAnswerWrapperObj.picklistValueList.add(picklistValueObj);
                                    }
                                }
                            }
                            if(questionMap1.containsKey('answers_fr') && !JSON.serialize(questionMap1.get('answers_fr')).startsWith('[')){
                                //List<Object> answerList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(questionMap1.get('answers_fr')));
                                Map<String, Object> answerMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(questionMap1.get('answers_fr')));
                                if(answerMap != null){
                                    if(answerMap.values() != null && answerMap.values().size() > 0){
                                        for(String answerKey : answerMap.keySet()){
                                            PicklistValue  picklistValueObj = new PicklistValue();
                                            picklistValueObj.key = answerKey;
                                            picklistValueObj.question =  String.valueOf(answerMap.get(answerKey));
                                            questionAnswerWrapperObj.picklistValueList_fr.add(picklistValueObj);
                                        }
                                        PicklistValue  picklistValueObj = new PicklistValue();
                                        picklistValueObj.key = 'null';
                                        picklistValueObj.question =  'N/A';
                                        
                                        questionAnswerWrapperObj.picklistValueList_fr.add(picklistValueObj);
                                    }
                                }
                            }
                            ttDoinitWrapperObj.ttFilterWrapperObj.questionAnswerList.add(questionAnswerWrapperObj);
                        }
                    }
                    for(TelosTouchSF__Insights__c conversationUserObj :conversationUserList){
                        UserWrapper userWrapperObj = new UserWrapper();
                        userWrapperObj.Id = conversationUserObj.Id;
                        if(conversationUserObj.TelosTouchSF__Contact__c != null){
                            userWrapperObj.nameURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Contact/'+conversationUserObj.TelosTouchSF__Contact__c+'/view';
                            userWrapperObj.name = conversationUserObj.TelosTouchSF__Contact__r.Name;
                            userWrapperObj.ContactCLientId = conversationUserObj.TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c;
                            userWrapperObj.ContactOrLeadSFId = conversationUserObj.TelosTouchSF__Contact__c;
                            userWrapperObj.ContactOrLeadSubscribed = conversationUserObj.TelosTouchSF__Contact__r.TelosTouchSF__Subscribed__c;
                            
                            
                        }else if(conversationUserObj.TelosTouchSF__Lead__c != null){
                            userWrapperObj.nameURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Lead/'+conversationUserObj.TelosTouchSF__Lead__c+'/view';
                            userWrapperObj.name = conversationUserObj.TelosTouchSF__Lead__r.Name;
                            userWrapperObj.LeadCLientId = conversationUserObj.TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c;
                            userWrapperObj.ContactOrLeadSFId = conversationUserObj.TelosTouchSF__Lead__c;
                            userWrapperObj.ContactOrLeadSubscribed = conversationUserObj.TelosTouchSF__Lead__r.TelosTouchSF__Subscribed__c;
                            
                        }
                        
                        if(conversationUserObj.TelosTouchSF__Opened_At__c != null){
                            userWrapperObj.TTOpened_At = conversationUserObj.TelosTouchSF__Opened_At__c.format('MMM dd, yyyy hh:mm a');
                            userWrapperObj.isActive = false;
                        }else{
                            userWrapperObj.TTOpened_At = System.label.Pending_Text;
                            userWrapperObj.isActive = true;
                        }
                        if(conversationUserObj.TelosTouchSF__Completed_At__c != null){
                            userWrapperObj.TTCompleted_At = conversationUserObj.TelosTouchSF__Completed_At__c.format('MMM dd, yyyy hh:mm a');
                            userWrapperObj.isActive = false;
                        }else{
                            userWrapperObj.TTCompleted_At = System.label.Pending_Text;
                            userWrapperObj.isActive = true;
                        }
                        ttDoinitWrapperObj.userWrapperList.add(userWrapperObj);
                    }
                    System.debug('doinitApex'+JSON.serialize(ttDoinitWrapperObj));
                    return ttDoinitWrapperObj;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());          }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the details of the users.
* @param campainId stores a id of campaign.
* @param filterWrapper stores wrapper.
* @param isFormType stores a value of form type.
* @return UserWrapper userWrapperList ....
*/
    @AuraEnabled
    public static List<UserWrapper> getUserDetails(String campainId, String filterWrapper, Boolean isFormType){
        try{
            if(campainId != null && filterWrapper != null){
                //List<String> stringList = new List<String>();
                List<Campaign> campaignList = new List<Campaign>();
                Map<String,Set<String>> formStringMap = new Map<String,Set<String>>();
                List<TelosTouchSF__Insights__c> conversationUserList = new List<TelosTouchSF__Insights__c>();
                //List<Insights__c> conversationUserAnswerList = new List<Insights__c>();
                Map<String, Object> questionMap1 = (Map<String, Object>)JSON.deserializeUntyped(filterWrapper);
                List<UserWrapper> userWrapperList  = new List<UserWrapper>();
                Set<UserWrapper> userWrapperSet  = new Set<UserWrapper>();
                Set<String> conversationIdSet = new Set<String>();
                Map<String, String> PickListValueEnKeyMap = new Map<String, String>();
                Map<String, String> PickListValueEnAnswerMap = new Map<String, String>();
                Map<String, String> PickListValueFrKeyMap = new Map<String, String>();
                Map<String, String> PickListValueFrAnswerMap = new Map<String, String>();
                if(questionMap1.containsKey('questionAnswerList')){
                    List<Object> responseAnswerList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(questionMap1.get('questionAnswerList')));
                    if(responseAnswerList != null){
                        for(Object questionAnswerWrapperObj : responseAnswerList) {
                            Map<String, Object> questionMap2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(questionAnswerWrapperObj));
                            if(questionMap2.containsKey('picklistValueList')){
                                for(Object picklistValueObj : (List<Object>)questionMap2.get('picklistValueList')){
                                    Map<String, Object> picklistValueMap = (Map<String, Object>)picklistValueObj;
                                    PickListValueEnKeyMap.put((String)picklistValueMap.get('key'), (String)picklistValueMap.get('question'));
                                    PickListValueEnAnswerMap.put((String)picklistValueMap.get('question'), (String)picklistValueMap.get('key'));
                                }
                            }
                            if(questionMap2.containsKey('picklistValueList_fr')){
                                for(Object picklistValueObj : (List<Object>)questionMap2.get('picklistValueList_fr')){
                                    Map<String, Object> picklistValueMap = (Map<String, Object>)picklistValueObj;
                                    PickListValueFrKeyMap.put((String)picklistValueMap.get('key'), (String)picklistValueMap.get('question'));
                                    PickListValueFrAnswerMap.put((String)picklistValueMap.get('question'), (String)picklistValueMap.get('key'));
                                }
                            }
                            if(questionMap2.containsKey('answerList')){
                                List<Object> responseList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(questionMap2.get('answerList')));
                                if(responseList != null && responseList.size() > 0){
                                    //formStringMap.put(String.valueOf(questionMap2.get('question')),new Set<String>());
                                    formStringMap.put(String.valueOf(questionMap2.get('questionKey')),new Set<String>());
                                    for(Object obj : responseList){
                                        if(PickListValueEnAnswerMap.containsKey((String)obj)){
                                            formStringMap.get(String.valueOf(questionMap2.get('questionKey'))).add(String.valueOf(obj));
                                            formStringMap.get(String.valueOf(questionMap2.get('questionKey'))).add((String)PickListValueFrKeyMap.get((String)PickListValueEnAnswerMap.get((String)obj)));
                                        }else if(PickListValueFrAnswerMap.containsKey((String)obj)){
                                            formStringMap.get(String.valueOf(questionMap2.get('questionKey'))).add(String.valueOf(obj));
                                            formStringMap.get(String.valueOf(questionMap2.get('questionKey'))).add((String)PickListValueEnKeyMap.get((String)PickListValueFrAnswerMap.get((String)obj)));
                                        }
                                    }
                                }
                                if(questionMap2.containsKey('answer') && String.isNotBlank(String.valueOf(questionMap2.get('answer')))){
                                    formStringMap.put(String.valueOf(questionMap2.get('questionKey')),new Set<String>());
                                    formStringMap.get(String.valueOf(questionMap2.get('questionKey'))).add(String.valueOf(questionMap2.get('answer')));
                                }
                            }
                        }
                    }
                }
                if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() &&
                   Schema.sObjectType.Campaign.fields.Name.isAccessible() &&  Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible() &&
                   Schema.sObjectType.Campaign.fields.TelosTouchSF__Answers__c.isAccessible()){
                       campaignList = [SELECT Id,Name, TelosTouchSF__Questions__c, TelosTouchSF__Answers__c FROM Campaign WHERE Id =:campainId];
                   }
                if(campaignList.size() > 0 && campaignList[0].TelosTouchSF__Answers__c != null){
                    List<Object> campUserList = (List<Object>)JSON.deserializeUntyped(campaignList[0].TelosTouchSF__Answers__c.unescapeHtml4());
                    for(Object campUserObj : campUserList) {
                        Map<String, Object> campUserMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(campUserObj));
                        List<Object> campAnswerList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(campUserMap.get('questionsandanswers')));
                        Boolean questionMatch = false, questionNotMatch = false;
                        Integer userSelectedQuestion = 0;
                        for(Object campAnswerObj : campAnswerList) {
                            Map<String, Object> campAnswerMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(campAnswerObj));
                            List<Object> allAnswerList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(campAnswerMap.get('answers')));
                            //Set<String> answerSet = new Set<String>();
                            if(formStringMap.containsKey(String.valueOf(campAnswerMap.get('key'))) && formStringMap.get(String.valueOf(campAnswerMap.get('key'))).size() > 0){
                                for(Object allAnswerObj : allAnswerList) {
                                    if(formStringMap.get(String.valueOf(campAnswerMap.get('key'))).contains(String.valueOf(allAnswerObj))){
                                        questionMatch = true;
                                    }else if(allAnswerList.size() == 1){
                                        questionNotMatch = true;
                                    }
                                }
                            }else{
                                userSelectedQuestion ++;
                            }
                        }
                        if(questionMatch == true &&  questionNotMatch != true){
                            conversationIdSet.add(String.valueOf(campUserMap.get('conversation_id')));
                        }else if(userSelectedQuestion != 0 && userSelectedQuestion == campAnswerList.size()){
                            conversationIdSet.add(String.valueOf(campUserMap.get('conversation_id')));
                        }
                    }
                }
                Boolean containsNA = false;
                for(Set<String> stringEachSet : formStringMap.values()){
                    for(String strEach : stringEachSet){
                        if(strEach == 'N/A'){
                            containsNA = true;
                            break;
                        }
                    }
                }
                if(containsNA){
                    for(TelosTouchSF__Insights__c each : [SELECT Id, TelosTouchSF__Conversation_Id__c FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__Completed_At__c = null AND TelosTouchSF__Campaign2__c =:campainId WITH SECURITY_ENFORCED LIMIT 20000]){
                        conversationIdSet.add(each.TelosTouchSF__Conversation_Id__c);
                    }
                }
                String conversationUserQuery = 'SELECT Id, Name, TelosTouchSF__Conversation_Id__c, TelosTouchSF__Campaign2__c, TelosTouchSF__Contact__c, TelosTouchSF__Lead__c, TelosTouchSF__Completed_At__c, TelosTouchSF__Opened_At__c,TelosTouchSF__Answers__c,TelosTouchSF__Contact__r.Name,TelosTouchSF__Contact__r.TelosTouchSF__Subscribed__c,TelosTouchSF__Lead__r.Name,TelosTouchSF__Lead__r.TelosTouchSF__Subscribed__c,TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c,TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c FROM TelosTouchSF__Insights__c ';
                if(!formStringMap.isEmpty() && (formStringMap.keySet()).size() > 0){
                    conversationUserQuery +=  ' WHERE TelosTouchSF__Conversation_Id__c IN:conversationIdSet ';
                }else{
                    conversationUserQuery +=  ' WHERE TelosTouchSF__Campaign2__c =:campainId ';
                }
                if(questionMap1.containsKey('pendingOpened_At') && questionMap1.get('pendingOpened_At') != null && String.isNotBlank(String.valueOf(questionMap1.get('pendingOpened_At'))) && String.valueOf(questionMap1.get('pendingOpened_At')) == 'Pending'){
                    conversationUserQuery += ' AND TelosTouchSF__Opened_At__c = null ';
                }
                if(questionMap1.containsKey('pendingOpened_At') && questionMap1.get('pendingOpened_At') != null && String.isNotBlank(String.valueOf(questionMap1.get('pendingOpened_At'))) && String.valueOf(questionMap1.get('pendingOpened_At')) == 'Opened'){
                    conversationUserQuery += ' AND TelosTouchSF__Opened_At__c != null ';
                }
                if(questionMap1.containsKey('pendingCompleted_At') && questionMap1.get('pendingCompleted_At') != null && String.isNotBlank(String.valueOf(questionMap1.get('pendingCompleted_At'))) && String.valueOf(questionMap1.get('pendingCompleted_At')) == 'Pending'){
                    conversationUserQuery += ' AND TelosTouchSF__Completed_At__c = null ';
                }
                if(questionMap1.containsKey('pendingCompleted_At') && questionMap1.get('pendingCompleted_At') != null && String.isNotBlank(String.valueOf(questionMap1.get('pendingCompleted_At'))) && String.valueOf(questionMap1.get('pendingCompleted_At')) == 'Completed'){
                    conversationUserQuery += ' AND TelosTouchSF__Completed_At__c != null ';
                }
                
                conversationUserQuery += ' AND (TelosTouchSF__Contact__c != null OR TelosTouchSF__Lead__c != null) ';
                conversationUserQuery += ' LIMIT 10000 ';
                conversationUserList = Database.query(String.escapeSingleQuotes(conversationUserQuery).replace('\\',''));
                if(questionMap1.containsKey('name') &&  questionMap1.get('name') != null && String.isNotBlank(String.valueOf(questionMap1.get('name')))){
                    for(Integer i=0; i<conversationUserList.size(); i++){
                        if((conversationUserList[i].TelosTouchSF__Contact__r.Name != null && !conversationUserList[i].TelosTouchSF__Contact__r.Name.contains((String)questionMap1.get('name'))) ||
                           (conversationUserList[i].TelosTouchSF__Lead__r.Name != null && !conversationUserList[i].TelosTouchSF__Lead__r.Name.contains((String)questionMap1.get('name'))) ){
                               conversationUserList.remove(i);
                               i--;
                           }
                    }
                }
                for(TelosTouchSF__Insights__c conversationUserObj :conversationUserList){
                    UserWrapper userWrapperObj = new UserWrapper();
                    userWrapperObj.Id = conversationUserObj.Id;
                    if(conversationUserObj.TelosTouchSF__Contact__c != null){
                        userWrapperObj.nameURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Contact/'+conversationUserObj.TelosTouchSF__Contact__c+'/view';
                        userWrapperObj.name = conversationUserObj.TelosTouchSF__Contact__r.Name;
                        userWrapperObj.ContactCLientId = conversationUserObj.TelosTouchSF__Contact__r.TelosTouchSF__TT_Client_Id__c;
                        userWrapperObj.ContactOrLeadSFId = conversationUserObj.TelosTouchSF__Contact__c;
                        userWrapperObj.ContactOrLeadSubscribed = conversationUserObj.TelosTouchSF__Contact__r.TelosTouchSF__Subscribed__c;
                        
                    }else if(conversationUserObj.TelosTouchSF__Lead__c != null){
                        userWrapperObj.nameURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Lead'+conversationUserObj.TelosTouchSF__Lead__c+'/view';
                        userWrapperObj.name = conversationUserObj.TelosTouchSF__Lead__r.Name;
                        userWrapperObj.LeadCLientId = conversationUserObj.TelosTouchSF__Lead__r.TelosTouchSF__TT_Client_Id__c;
                        userWrapperObj.ContactOrLeadSFId = conversationUserObj.TelosTouchSF__Lead__c;
                        userWrapperObj.ContactOrLeadSubscribed = conversationUserObj.TelosTouchSF__Lead__r.TelosTouchSF__Subscribed__c;
                        
                    }
                    if(conversationUserObj.TelosTouchSF__Opened_At__c != null){
                        userWrapperObj.TTOpened_At = conversationUserObj.TelosTouchSF__Opened_At__c.format('MMM dd, yyyy hh:mm a');
                        userWrapperObj.isActive = false;
                    }else{
                        userWrapperObj.TTOpened_At = System.label.Pending_Text;
                        userWrapperObj.isActive = true;
                    }
                    if(conversationUserObj.TelosTouchSF__Completed_At__c != null){
                        userWrapperObj.TTCompleted_At = conversationUserObj.TelosTouchSF__Completed_At__c.format('MMM dd, yyyy hh:mm a');
                        userWrapperObj.isActive = false;
                    }else{
                        userWrapperObj.TTCompleted_At = System.label.Pending_Text;
                        userWrapperObj.isActive = true;
                    }
                    userWrapperSet.add(userWrapperObj);
                }
                userWrapperList.addAll(userWrapperSet);
                return userWrapperList;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());          }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets the answers of the users.
* @param recordId stores a id of record.
* @return AnswerWrapperDetails userWrapperList ....
*/
    @AuraEnabled
    public static List<AnswerWrapperDetails> getUserAnswers(String recordId){
        try{
            List<TelosTouchSF__Insights__c> conversationUserList = new List<TelosTouchSF__Insights__c>();
            List<AnswerWrapperDetails> answerWrapperDetailsList = new List<AnswerWrapperDetails>();
            AnswerWrapperDetails answerWrapperDetailsObj = new AnswerWrapperDetails();
            if(recordId != null){
                if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible() && Schema.sObjectType.Insights__c.isQueryable() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.Id.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Conversation_Id__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Contact__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Lead__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Answers__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__TouchPoint_Name__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isAccessible() &&
                   Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isAccessible()){
                       conversationUserList = [SELECT Id,
                                               Name,
                                               TelosTouchSF__Conversation_Id__c,
                                               TelosTouchSF__Campaign2__c,
                                               TelosTouchSF__Contact__c,
                                               TelosTouchSF__Contact__r.Name,
                                               TelosTouchSF__Lead__c,
                                               TelosTouchSF__Lead__r.Name,
                                               TelosTouchSF__Answers__c,
                                               TelosTouchSF__TouchPoint_Name__c,
                                               TelosTouchSF__Completed_At__c,
                                               TelosTouchSF__Opened_At__c
                                               FROM TelosTouchSF__Insights__c
                                               WHERE (Id =: recordId OR TelosTouchSF__Campaign2__c=: recordId) LIMIT 2000];
                   }
                for(TelosTouchSF__Insights__c conversationUserObj : conversationUserList){
                    answerWrapperDetailsObj.TouchPointName = conversationUserObj.TelosTouchSF__TouchPoint_Name__c;
                    
                    if(conversationUserObj.TelosTouchSF__Contact__r.Name != null){
                        answerWrapperDetailsObj.Name = conversationUserObj.TelosTouchSF__Contact__r.Name;
                    }else if(conversationUserObj.TelosTouchSF__Lead__r.Name !=  null){
                        answerWrapperDetailsObj.Name = conversationUserObj.TelosTouchSF__Lead__r.Name;
                    }else{
                        answerWrapperDetailsObj.Name = conversationUserObj.Name;
                    }
                    
                    conversationUserObj.TelosTouchSF__Answers__c =   conversationUserObj.TelosTouchSF__Answers__c.unescapeHtml4();
                    if(conversationUserObj.TelosTouchSF__Answers__c != null){
                        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(conversationUserObj.TelosTouchSF__Answers__c);
                        for(Object response : responseList){
                            Map<String, Object> questionMap3 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(response));
                            AnswerWrapper answerWrapperObj = new AnswerWrapper();
                            answerWrapperObj.content = String.valueOf(questionMap3.get('content'));
                            answerWrapperObj.type = String.valueOf(questionMap3.get('type'));
                            if(answerWrapperObj.type.contains('video')){
                                answerWrapperObj.type = 'video';
                            }
                            else if(answerWrapperObj.type.contains('application')){
                                answerWrapperObj.type = 'application';
                            }
                            else if(answerWrapperObj.type.contains('image')){
                                answerWrapperObj.type = 'image';
                            }
                            answerWrapperObj.is_robot = Boolean.valueOf(questionMap3.get('is_robot'));
                            answerWrapperObj.resource_url = String.valueOf(questionMap3.get('resource_url'));
                            answerWrapperDetailsObj.answerWrapperList.add(answerWrapperObj);
                            answerWrapperDetailsList.add(answerWrapperDetailsObj);
                        }
                    }
                }
                if(answerWrapperDetailsList.size() > 0){
                    return answerWrapperDetailsList;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());          }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method inserts a campaign and sends touchpoint.
* @param campaignName stores the name of the campaign.
* @param userList stores list of users.
* @return ClientIdAndCampaignWrapper userWrapperList ....
*/
    @AuraEnabled
    public static ClientIdAndCampaignWrapper campaignInsertandSendTouchPoint( String campaignName, String userList){
        try{
            Id telosTouchRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
            List<CampaignMember> cmList = new List<CampaignMember>();
            ClientIdAndCampaignWrapper wraperObj = new ClientIdAndCampaignWrapper();
            Campaign campaignObject = new Campaign();
            if(campaignName != null){
                if(Schema.sObjectType.Campaign.fields.Name.isAccessible() && Schema.sObjectType.Campaign.fields.Name.isCreateable() &&
                   Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible() && Schema.sObjectType.Campaign.fields.RecordTypeId.isCreateable()){
                       campaignObject.Name = campaignName;
                       campaignObject.RecordTypeId = telosTouchRecordTypeId;
                       if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isCreateable()){
                           insert campaignObject;
                       }
                   }
            }
            List<UserWrapper> userwrapperlist = new List<UserWrapper>();
            userwrapperlist =  (List<UserWrapper>) JSON.deserialize(userList, List<UserWrapper>.class);
            List<String> clientIdsSet = new List<String>();
            for(UserWrapper userObj : userwrapperlist){
                CampaignMember cmObj = new CampaignMember();
                if(userObj.ContactCLientId != null && Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() && Schema.sObjectType.CampaignMember.fields.ContactId.isCreateable()){
                    cmObj.ContactId = userObj.ContactOrLeadSFId;
                    clientIdsSet.add(userObj.ContactCLientId);
                }else if(userObj.LeadCLientId != null && Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() && Schema.sObjectType.CampaignMember.fields.LeadId.isCreateable()){
                    cmObj.LeadId = userObj.ContactOrLeadSFId;
                    clientIdsSet.add(userObj.LeadCLientId);
                }
                if(Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible() && Schema.sObjectType.CampaignMember.fields.CampaignId.isCreateable()){
                    cmObj.CampaignId = campaignObject.Id;
                }
                cmList.add(cmObj);
            }
            if(cmList.size() > 0){
                if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isCreateable()){
                    insert cmList;
                }
            }
            wraperObj.clientIdlist = clientIdsSet;
            wraperObj.campaignId = campaignObject.Id;
            return wraperObj;
        }
        catch(Exception ex ){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param campainId ....
* @param userList ....
* @return String picklistWrapperObj ....
*/
    @AuraEnabled
    public static String sendReminder(String campainId,String userList){
        try{
            //System.debug('User Wrapper: '+userList);
            Boolean flag = false;
            Campaign campaignObj = new Campaign();
            List<UserWrapper> userwrapperlist = new List<UserWrapper>();
            Set<String> clientList = new Set<String>();
            Set<String> clientList2 = new Set<String>();
            Map<Integer, Set<String>> clientListMap = new Map<Integer, Set<String>>();
            Integer count = 0;
            String endPointURL,body,getResponse,userAuthTOKEN;
            Map<String, String> headersMap = new Map<String, String>();
            if(Schema.sObjectType.Campaign.isAccessible() && Schema.sObjectType.Campaign.isQueryable() &&
               Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() && Schema.sObjectType.Campaign.fields.Name.isAccessible() &&
               Schema.sObjectType.Campaign.fields.CreatedDate.isAccessible()){
                   campaignObj= [SELECT Id,Name,TelosTouchSF__TT_Campaign_Id__c, CreatedDate FROM Campaign WHERE Id=:campainId AND TelosTouchSF__TT_Campaign_Id__c != null];
               }
            Long now0TimeinMilliseconds = Datetime.now().getTime();
            Long createdTimeinMilliseconds = campaignObj.CreatedDate.getTime();
            Long hourDifference = (now0TimeinMilliseconds - createdTimeinMilliseconds)/(1000*60*60);
            /*if(hourDifference <= 24 && !Test.isRunningTest()){
                return 'The Touchpoint was created less than 24 Hours ago';
            }*/
            userwrapperlist =  (List<UserWrapper>) JSON.deserialize(userList, List<UserWrapper>.class);
            if(campaignObj.Id != null){
                if(String.isNotEmpty(authenticationCredential.TelosTouchSF__Access_Token__c) &&  String.isNotEmpty(adminCredentials.TelosTouchSF__Instance_URL__c)){
                    userAuthTOKEN = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
                    if(userAuthTOKEN != null){
                        headersMap.put('Authorization','Bearer '+userAuthTOKEN);
                    }
                    headersMap.put('Content-Type', 'application/json');
                    headersMap.put('Accept', 'application/json');
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/api/v1/touchpoints/'+campaignObj.TelosTouchSF__TT_Campaign_Id__c+'/clients/reminder';
                    //System.debug('endPointURL:: '+endPointURL);
                    for(UserWrapper userObj : userwrapperlist){
                        //System.debug('userObj:: '+userObj);
                        if(userObj.TTOpened_At != null && userObj.TTOpened_At == System.label.Pending_Text
                           || userObj.TTCompleted_At != null && userObj.TTCompleted_At == System.label.Pending_Text){
                               if(userObj.ContactCLientId != null){
                                   clientList.add(userObj.ContactCLientId);
                               }else if(userObj.LeadCLientId != null){
                                   clientList.add(userObj.LeadCLientId);
                               }
                           }
                    }
                    for(Contact conNoConflictObj: [SELECT TelosTouchSF__TT_Client_Id__c FROM Contact WHERE TelosTouchSF__TT_Client_Id__c IN: clientList AND TelosTouchSF__TT_Conflict__c = false WITH SECURITY_ENFORCED]){
                        clientList2.add(conNoConflictObj.TelosTouchSF__TT_Client_Id__c);
                        if(clientList2.size() == 500){
                            count++;
                            clientListMap.put(count, clientList2);
                            clientList2 = new Set<String>();
                        }
                    }
                    for(Lead ldNoConflictObj: [SELECT TelosTouchSF__TT_Client_Id__c FROM Lead WHERE TelosTouchSF__TT_Client_Id__c IN: clientList AND TelosTouchSF__TT_Conflict__c = false WITH SECURITY_ENFORCED]){
                        clientList2.add(ldNoConflictObj.TelosTouchSF__TT_Client_Id__c);
                        if(clientList2.size() == 500){
                            count++;
                            clientListMap.put(count, clientList2);
                            clientList2 = new Set<String>();
                        }
                    }
                    if(!clientList2.isEmpty()){
                        clientListMap.put(++count, clientList2);
                    }
                    if(clientListMap.keySet().isEmpty()){
                        return 'No Valid Clients';
                    }else{
                        for(Integer index : clientListMap.keySet()){
                            body = '{ "clients": ' + JSON.serialize(clientListMap.get(index)) + '}';
                            Map<String, String> getResponseMap = TelosTouchSF.TelosTouchUtility.getResponse('PUT', endPointURL, headersMap, body);
                            if(getResponseMap.get('status_code') == '401'){
                                UserTriggerHandler.createLogRecord('failure','User Could Not be Authenticated','L\'usager n\'a pu être identifié', 1);
                                return 'Unauthorized User';
                            }else if(getResponseMap.get('status_code') == '500'){
                                UserTriggerHandler.createLogRecord('failure','Internal Server Error' ,'Erreur de serveur interne', 1);
                                return 'Internal Server Error';
                            }else{
                                if(getResponseMap.get('status_code').length() > 0){
                                    list<String>StatusCodeList = getResponseMap.get('status_code').split('0');
                                    if(StatusCodeList[0] == '4' || StatusCodeList[0] == '5'){
                                        TelosTouchSF.UserTriggerHandler.createLogRecord('Failure','Something went wrong. Status Code: '+getResponseMap.get('status_code'),'Quelque chose s\'est mal passé  Code d\'état :'+getResponseMap.get('status_code'),1);
                                    }
                                }
                            }
                            getResponse = getResponseMap.get('body');
                            //System.debug('getResponse:: '+getResponse);
                        }
                        if(String.isNotEmpty(getResponse) && getResponse != null){
                            flag = true;
                            UserTriggerHandler.createLogRecord('success','Reminder for Answering Touchpoint: '+campaignObj.Name+' Sent','Rappel de compléter un TouchPoint: '+campaignObj.Name+' envoyés', 1);
                        }else{
                            flag = false;
                            UserTriggerHandler.createLogRecord('failure','Reminder for Answering Touchpoint: '+campaignObj.Name+' Not Sent','Rappel de compléter un TouchPoint: '+campaignObj.Name+' Pas envoyé', 1);
                        }
                        if(flag){
                            return 'Reminder Sent Successfully';
                        }else{
                            return 'Reminder Failed';
                        }
                    }
                }
            }
            
            return null;
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            return null;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method gets all details of task.
* @return PicklistWrapper Reminder Failed ....
*/
    @AuraEnabled
    public static PicklistWrapper getTaskDetails(){
        PicklistWrapper picklistWrapperObj = new PicklistWrapper();
        picklistWrapperObj.currentuser = [SELECT id,Name,LanguageLocaleKey from USER where Id =: userinfo.getuserid()];
        //Schema.DescribeFieldResult statusSchemaObj = Task.Status.getDescribe();
        //List<Schema.PicklistEntry> statusSchemaObjList = statusSchemaObj.getPicklistValues();
        picklistWrapperObj.StatusPicklist = getPicklistValues('Task', 'Status');
        picklistWrapperObj.SubjectDefaultValuePicklist = getPicklistValues('Task', 'Subject');
        picklistWrapperObj.ShareWithClientlist = getPicklistValues('Task', 'TelosTouchSF__Share_with_client_s__c');
        /*for(Schema.PicklistEntry obj : statusSchemaObjList) {
picklistWrapperObj.StatusPicklist.add(String.valueOf(obj.getValue()));
}
Schema.DescribeFieldResult clientSchemaObj = Task.Share_with_client_s__c.getDescribe();
List<Schema.PicklistEntry> clientSchemaObjList = clientSchemaObj.getPicklistValues();
picklistWrapperObj.ShareWithClientlist = new List<String>();
for(Schema.PicklistEntry obj : clientSchemaObjList) {
picklistWrapperObj.ShareWithClientlist.add(String.valueOf(obj.getValue()));
}*/
        return picklistWrapperObj;
    }
    
    /** ------------------------Get picklist values if field type is picklist------------------------- */
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param ObjectApi_name ....
* @param Field_name ....
* @return listObject lstPickvals ....
*/
    public static List<listObject> getPicklistValues(String ObjectApi_name, String Field_name) {
        
        List <listObject> lstPickvals = new List <listObject>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry pickObj : pick_list_values) { //for all values in the picklist list
            //System.debug('pickObj>>>'+pickObj.getValue());
            listObject obj = new listObject();
            obj.label = pickObj.getLabel();
            obj.value = pickObj.getValue();
            lstPickvals.add(obj);//add the value  to our final list
        }
        return lstPickvals;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method inserts a campaign and sends touchpoint.
* @param tasklist stores list of task.
* @return Task tasklist ....
*/
    @AuraEnabled
    public static List<Task> saveNewTask(List<Task> tasklist) {
        try{
            if(tasklist != null && tasklist.size()>0){
                if(Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isCreateable()){
                    insert tasklist;
                }
            }
            return tasklist;
        }catch(Exception ex ){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description fetchRecordType method will return the recordType of the Task Object ....
@return String ..
*/
    @AuraEnabled
    public static String fetchRecordType() {
        try {
            list<RecordType> recordTypeList = new list<RecordType>();
            for(RecordTypeInfo info: Task.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.isActive() && info.getDeveloperName()!='Master' && info.getDeveloperName()!='Principal') {
                    RecordType record = new RecordType();
                    record.Id = info.getRecordTypeId();
                    record.Name = info.getName();
                    recordTypeList.add(record);
                }
            }
            if (recordTypeList.size() > 0 && recordTypeList != null) {
                return JSON.serialize(recordTypeList);
            }else{
                return 'No record type found';
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static String fetchCampaignRecordType() {
        try {
            System.debug('fetch Campaign Record Type method called');
            list<RecordType> recordTypeList = new list<RecordType>();
            for(RecordTypeInfo info: Campaign.SObjectType.getDescribe().getRecordTypeInfos()) {
                //System.debug('info:: '+ info.getDeveloperName());
                //System.debug('info name:: '+ info.getName());
                if(info.isAvailable() && info.isActive() && info.getDeveloperName()!='Master' && info.getDeveloperName()!='Principal') {
                    RecordType record = new RecordType();
                    record.Id = info.getRecordTypeId();
                    record.Name = info.getName();
                    recordTypeList.add(record);
                }
            }            
            //System.debug('recordTypeList:: '+recordTypeList);
            if (recordTypeList.size() > 0 && recordTypeList != null) {
                return JSON.serialize(recordTypeList);
            }else{
                return 'No record type found';
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static string addClientsToCampaign(String campRecordId, String userListStr){
        try {
            List<Object> userList = new List<Object>();
            userList = (List<Object>) JSON.deserializeUntyped(userListStr);
            //System.debug('userList:: '+userList);
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            for(Object each : userList){
                Map<String, Object> userMap = new Map<String, Object>();
                userMap = (Map<String, Object>) each;
                Id clientSfId = (Id) userMap.get('ContactOrLeadSFId');
                String sObjName = clientSfId.getSObjectType().getDescribe().getName();
                //System.debug('sObjName:: '+sObjName);
                //System.debug('clientSfId:: '+clientSfId);
                if(sObjName == 'Contact'){
                    if(Schema.sObjectType.CampaignMember.isCreateable() && Schema.sObjectType.CampaignMember.isUpdateable() &&
                       Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.fields.ContactId.isAccessible() &&
                       Schema.sObjectType.CampaignMember.fields.ContactId.isCreateable() && Schema.sObjectType.CampaignMember.fields.CampaignId.isCreateable() 
                       && Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible()) {
                           CampaignMember memberObj = new CampaignMember();
                           memberObj.ContactId = clientSfId;
                           memberObj.CampaignId = campRecordId;
                           campaignMemberList.add(memberObj);
                           //System.debug('memberObj:: '+memberObj);
                       }
                }else if(sObjName =='Lead'){
                    if(Schema.sObjectType.CampaignMember.isCreateable() && Schema.sObjectType.CampaignMember.isUpdateable() &&
                       Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.fields.LeadId.isAccessible() &&
                       Schema.sObjectType.CampaignMember.fields.LeadId.isCreateable() && Schema.sObjectType.CampaignMember.fields.LeadId.isUpdateable() &&
                       Schema.sObjectType.CampaignMember.fields.CampaignId.isCreateable() && Schema.sObjectType.CampaignMember.fields.CampaignId.isAccessible()
                       && Schema.sObjectType.CampaignMember.fields.CampaignId.isUpdateable()){
                           CampaignMember memberObj = new CampaignMember();
                           memberObj.LeadId = clientSfId;
                           memberObj.CampaignId = campRecordId;
                           campaignMemberList.add(memberObj);
                       }
                }
            }
            //System.debug('campaignMemberList:: '+campaignMemberList);
            if(Schema.sObjectType.CampaignMember.isAccessible() && Schema.sObjectType.CampaignMember.isUpdateable() && Schema.sObjectType.CampaignMember.isCreateable()){
                System.debug('campaignMemberList inserted:: '+ campaignMemberList);
                insert campaignMemberList;
                System.debug('campaignMemberList inserted:: '+ campaignMemberList);
            }
            return campRecordId;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage() + ' at Line: '+e.getLineNumber());
            if(e.getMessage().contains('Already a campaign member')){
                System.debug('return label value::'+System.Label.Clients_Already_Added_To_Campaign_Text );
                return ('error#'+ System.Label.Clients_Already_Added_To_Campaign_Text);
            }else{
                return ('error#'+e.getMessage());
            }
        }
    }
    @AuraEnabled 
    public static String fetchRecords( String objectName, String filterField, String searchString, Id campaignRecordId ) {
        try{ 
            List<RecordsData> recordsDataList = new List<RecordsData>();
            try {
                String query = 'SELECT Id, ' + filterField+ ' FROM '+objectName+' WHERE Id !=: campaignRecordId AND '+filterField+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' ORDER BY CreatedDate DESC LIMIT 5';
                for(SObject s : Database.query(query)){
                    recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                } 
            } catch(Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
            System.debug('return search data::'+recordsDataList);
            return JSON.serialize(recordsDataList);
        }catch(Exception e){
            system.debug('Error'+e.getMessage());
            return '';
        }
    }
    @AuraEnabled 
    public static String fetchLimitedRecords(Id campaignRecordId) { 
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, Name FROM Campaign WHERE Id !=: campaignRecordId ORDER BY CreatedDate DESC LIMIT 5';
            for(SObject s : Database.query(query)){
                recordsDataList.add( new RecordsData((String)s.get('Name'), (String)s.get('id')) );
            } 
            System.debug('data:: '+ recordsDataList);
            return JSON.serialize(recordsDataList);
        } catch(Exception e) {
            System.debug('Error is:: '+e.getMessage()+'at line no:: '+ e.getLineNumber());
            return '';
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description RecordsData is used to get CampaignRecords.
*/
    public class RecordsData{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description RecordsData is used tto get CampaignRecords.
*/
        @AuraEnabled public String label;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description RecordsData is used to get CampaignRecords.
*/
        @AuraEnabled public String value;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description RecordsData is used to get CampaignRecords.
*/
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description AnswerWrapperDetails is used to get TouchPointName,Name and list of answerWrapperList.
*/
    public class AnswerWrapperDetails{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  TouchPointName;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  Name;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<AnswerWrapper> answerWrapperList;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public AnswerWrapperDetails(){
            answerWrapperList = new List<AnswerWrapper>();
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description AnswerWrapper is used to get content,is_robot,type,resource_url and conversation_id.
*/
    public class AnswerWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  content;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public Boolean is_robot;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  type;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  resource_url;
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String  conversation_id;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTDoinitWrapper is used to get TTFilterWrapperObj and userWrapperList.
*/
    public class TTDoinitWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public TTFilterWrapper ttFilterWrapperObj {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<UserWrapper> userWrapperList {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public TTDoinitWrapper(){
            userWrapperList = new List<UserWrapper>();
            ttFilterWrapperObj = new TTFilterWrapper();
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTFilterWrapper is used to get name,pendingOpened_At,pendingCompleted_At and list of questionAnswerList.
*/
    public class TTFilterWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String name {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String pendingOpened_At {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String pendingCompleted_At {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<QuestionAnswerWrapper> questionAnswerList {get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public TTFilterWrapper(){
            questionAnswerList = new List<QuestionAnswerWrapper>();
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description QuestionAnswerWrapper is used to get answer,answerList,question,questionType and picklistValueList.
*/
    public class QuestionAnswerWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String answer { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<String> answerList { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String question { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/  @AuraEnabled public String questionKey { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/  @AuraEnabled public String question_fr { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String questionType { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<PicklistValue> picklistValueList { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/  @AuraEnabled public List<PicklistValue> picklistValueList_fr { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public QuestionAnswerWrapper(){
            picklistValueList = new List<PicklistValue>();
            picklistValueList_fr = new List<PicklistValue>();
            answerList = new List<String>();
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description PicklistValue is used to get question and isSelected.
*/
    public class PicklistValue{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String question { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public Boolean isSelected { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String key { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
        public PicklistValue(){
            isSelected = false;
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description UserWrapper is used to get Id,name,nameURL,TTOpened_At,TTCompleted_At,isActive,ContactCLientId,LeadCLientId and ContactOrLeadSFId.
*/
    public class UserWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String Id { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String name { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String nameURL { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String TTOpened_At { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String TTCompleted_At { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public Boolean isActive { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String ContactCLientId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String LeadCLientId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String ContactOrLeadSFId { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String ContactOrLeadSubscribed { get; set; }
        
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ClientIdAndCampaignWrapper is used to get clientIdlist and campaignId.
*/
    public class ClientIdAndCampaignWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<String> clientIdlist { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public String campaignId { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
    public class listObject {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled   public String value { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled   public String label { get; set; }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description PicklistWrapper is used to get StatusPicklist and ShareWithClientlist.
*/
    public class PicklistWrapper{
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<listObject> StatusPicklist { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<listObject> ShareWithClientlist { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public List<listObject> SubjectDefaultValuePicklist { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        @AuraEnabled public User currentuser { get; set; }
    }
}