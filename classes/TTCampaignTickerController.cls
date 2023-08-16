public with sharing class TTCampaignTickerController {

    private static final TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials = TelosTouchUtility.getCustomMetadata();

    @AuraEnabled
    public static map<String,String> AddMissingClient(String campId){
        
        map<String, String> mapResult = new map<String, String>();

        try {
            
            
            Campaign camp = [SELECT Id,Name,TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Type__c,
                             (SELECT Id,TelosTouchSF__Contact__c,TelosTouchSF__Lead__c FROM TelosTouchSF__Insights__r),
                             (SELECT Id,ContactId,Contact.TelosTouchSF__TT_Client_Id__c,LeadId,Lead.TelosTouchSF__TT_Client_Id__c FROM CampaignMembers)
                             FROM Campaign WHERE Id =: campId];

            set<String> setClientId = new set<String>();
            for(TelosTouchSF__Insights__c insight : camp.TelosTouchSF__Insights__r){
                if(String.isNotBlank(insight.TelosTouchSF__Contact__c)){
                    setClientId.add(insight.TelosTouchSF__Contact__c);
                } else if(String.isNotBlank(insight.TelosTouchSF__Lead__c)){
                    setClientId.add(insight.TelosTouchSF__Lead__c);
                }
            }

            BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper wrp = new BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper();
            wrp.campId = camp.Id;
            wrp.campName = camp.Name;
            wrp.TTcampId = camp.TelosTouchSF__TT_Campaign_Id__c;
            wrp.campType = camp.TelosTouchSF__Type__c;
            for(CampaignMember member : camp.CampaignMembers){

                String clientIdSF = (String.isNotBlank(member.ContactId)) ? member.ContactId : member.LeadId;
                String clientIdTT;

                if(String.isNotBlank(member.ContactId)){
                    clientIdSF = member.ContactId;
                    clientIdTT = member.Contact.TelosTouchSF__TT_Client_Id__c;
                } else {
                    clientIdSF = member.LeadId;
                    clientIdTT = member.Lead.TelosTouchSF__TT_Client_Id__c;
                }

                if(setClientId.contains(clientIdSF)){ continue; }

                wrp.TTClientIdVsContId.put(clientIdTT,clientIdSF);
                wrp.clientIds.add(clientIdTT);

            }

            if (wrp.clientIds != null && !wrp.clientIds.isEmpty()) {
                Database.executeBatch(new BatchAddRecipientsIntoTouchPoint(wrp),500);
            }

            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'removeExtraClient', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String,String> getCampaignData(String campId){
        
        map<String, String> mapResult = new map<String, String>();

        try {
            
            Campaign camp = [SELECT Id,CreatedDate,TelosTouchSF__Email_Template_Id__c,Name,
                             TelosTouchSF__Questions__c,TelosTouchSF__TouchPoint_Template_Id__c,
                             TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Type__c,
                             (SELECT Id,TelosTouchSF__Sent_Status__c FROM TelosTouchSF__Insights__r),
                             (SELECT Id FROM CampaignMembers) 
                             FROM Campaign WHERE Id =: campId];
            
            mapResult.put('status', 'success');
            mapResult.put('value', JSON.serialize(camp));
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'getCampaignData', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String,String> getCustomizeUrl(String templateType, String campId, String templateInfo){

        map<String, String> mapResult = new map<String, String>();

        try {

            if(templateType == null){ templateType = 'touchpoint'; }
            Campaign camp = [SELECT Id,TelosTouchSF__Email_Template_Id__c,
                             TelosTouchSF__TouchPoint_Template_Id__c FROM Campaign WHERE Id =: campId];
            
            User aUser = [SELECT Id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c 
                          FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                          
            String templateId;

            //CHECKING IF A COPY MUST BE CREATED
            Boolean isCopy = false;
            map<String,Object> mapTempInfo = (map<String,Object>) JSON.deserializeUntyped(templateInfo);
            templateId = (String) mapTempInfo.get('id');
            if(mapTempInfo.containsKey('status')){
                String status = (String) mapTempInfo.get('status');
                isCopy |= (status.toLowerCase() == 'sent');
            }
            
            if(!isCopy && mapTempInfo.containsKey('created_by')){
                String createdBy = (String) mapTempInfo.get('created_by');
                isCopy |= (createdBy != aUser.TelosTouchSF__TT_UserId__c);
            }
            
            String userToken = TelosTouchSF.TelosTouchUtility.getCurrentuserTOKEN();
            String iFrameURL;

            
            //CREATING COPY OF THE TEMPLATE
            if(isCopy){
                String endPointURL;
                if(templateType == 'email'){
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/templates/'+templateId+'/copy';
                } else {
                    endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/'+templateId+'/copy';
                }

                Map<String, String> mapHeader = new Map<String, String>();
                mapHeader.put('Authorization','Bearer ' +aUser.TelosTouchSF__Auth_Token__c);
                mapHeader.put('Content-Type', 'application/json');
                mapHeader.put('Accept', 'application/json');
    
                Map<String, String> mapResponse = TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, null);
                String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');	
                TelosTouchUtility.generateLog(respMessage, 'TTCampaignTickerController', 'getCustomizeUrl', campId);

                if(mapResponse.get('status_code') == '200'){
                    String responseBody = mapResponse.get('body');
                    String oldTemplateId = templateId;
                    map<String,Object> mapBody = (map<String,Object>)JSON.deserializeUntyped(responseBody);
                    templateId = (String)mapBody.get('id');

                    if(templateType == 'email'){
                        camp.TelosTouchSF__Email_Template_Id__c = camp.TelosTouchSF__Email_Template_Id__c.replace(oldTemplateId, templateId);
                    } else {
                        camp.TelosTouchSF__TouchPoint_Template_Id__c = templateId;
                    }
                    
                    if(templateType == 'touchpoint'){
                        endPointURL = adminCredentials.TelosTouchSF__Instance_URL__c.trim()+'/api/v1/touchpoint/templateGraph/publish/'+templateId;
                        Map<String, String> mapResponse2 = TelosTouchUtility.getResponse('PUT', endPointURL, mapHeader, null);
    
                        if(mapResponse.get('status_code') != '200'){
                            throw new AuraHandledException('Response Code 2: '+mapResponse2.get('status_code'));
                        } else {
                            TemplateGalleryCompHandler.sendTouchpointTemplate(campId, templateId);
                        }
                    } else {
                        TemplateGalleryCompHandler.sendEmailTemplate(campId, templateId, (String)mapTempInfo.get('language'));
                    }
                    
                } else {
                    throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
                }

            }

            if(templateType == 'email'){
                iFrameURL = adminCredentials.TelosTouchSF__Instance_URL__c + '/app/v1/#/email/edit/' + templateId + '?fullscreen=true&access_token=' + userToken;
            } else {
                iFrameURL = adminCredentials.TelosTouchSF__Instance_URL__c+'/app/v1/#/touchpoint/'+templateId+'/customize-sf?fullscreen=true&access_token='+userToken;
            }

            if(UserInfo.getLanguage().contains('en')){
                iFrameURL += '&lang=en_US';
            }else if(UserInfo.getLanguage().contains('fr')){
                iFrameURL += '&lang=fr_FR';
            }

            mapResult.put('status', 'success');
            mapResult.put('value', iFrameURL);
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'getTTCampaignId', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String,String> getTTClients(String campId){
        
        map<String, String> mapResult = new map<String, String>();

        try {

            Campaign camp = [SELECT TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id =: campId];

            String userAuthTOKEN = TelosTouchUtility.getCurrentuserTOKEN();

            String endpoint = adminCredentials.TelosTouchSF__Instance_URL__c + '/api/v2/campaign2/'+camp.TelosTouchSF__TT_Campaign_Id__c+'/clients';
            
            map<String, String> mapHeader = new map<String, String>();
            mapHeader.put('Authorization', 'Bearer ' + userAuthTOKEN);
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');

            map<String, String> mapResponse = TelosTouchUtility.getResponse('GET',endpoint,mapHeader,null);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');	
            TelosTouchUtility.generateLog(respMessage, 'TTCampaignTickerController', 'getTTClients', campId);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){
                mapResult.put('status', 'success');
                mapResult.put('value', mapResponse.get('body'));
            } else {
                throw new AuraHandledException('Response Code: '+mapResponse.get('status_code'));
            }

            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'getTTClients', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String,String> removeExtraClient(String campId){
        
        map<String, String> mapResult = new map<String, String>();

        try {
            
            set<String> setConversationId = new set<String>();
            for(TelosTouchSF__Insights__c insight : [SELECT TelosTouchSF__Conversation_Id__c FROM TelosTouchSF__Insights__c
                                                     WHERE TelosTouchSF__Campaign2__c =: campId])
            {
                setConversationId.add(insight.TelosTouchSF__Conversation_Id__c);
            }

            map<String,String> mapClients = getTTClients(campId);
            if(mapClients.get('status') == 'error'){ throw new AuraHandledException('Unable to retrieve TT clients'); }

            list<Object> lstClientsTT = (list<Object>)JSON.deserializeUntyped(mapClients.get('value'));

            list<String> lstClientId = new list<String>();
            for(Object client : lstClientsTT){

                map<String,Object> mapClientData = (map<String,Object>)client;
                String clientId = String.valueOf(mapClientData.get('id'));
                if(!setConversationId.contains(clientId)){ lstClientId.add(clientId); }

            }

            if(!lstClientId.isEmpty()){

                Campaign camp = [SELECT TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id =: campId];

                map<String, list<String>> mapMembersByCamp = new map<String, list<String>>();
                mapMembersByCamp.put(camp.TelosTouchSF__TT_Campaign_Id__c, lstClientId);
                Database.executeBatch(new BatchRemoveCampaignRecipient(mapMembersByCamp),1);
            } 
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'removeExtraClient', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static map<String,String> updateSentInsight(String campId){
        
        map<String, String> mapResult = new map<String, String>();

        try {

            list<TelosTouchSF__Insights__c> lstInsight = new list<TelosTouchSF__Insights__c>();
            String insightStatus = 'initial';

            for(TelosTouchSF__Insights__c insight : [SELECT Id,TelosTouchSF__Sent_Status__c FROM TelosTouchSF__Insights__c 
                                                     WHERE TelosTouchSF__Sent_Status__c =: insightStatus])
            {
                insight.TelosTouchSF__Sent_Status__c = 'sending';
                lstInsight.add(insight);
            }

            Database.update(lstInsight);
            
            mapResult.put('status', 'success');
            return mapResult;

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'TTCampaignTickerController', 'removeExtraClient', null);
            mapResult.put('status', 'error');
            mapResult.put('error', ex.getMessage());
            return mapResult;
        }
    }

}