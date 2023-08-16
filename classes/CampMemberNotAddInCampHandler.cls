/**
* @author Cloud Analogy
* @date 02/08/2021
* @description CampMemberNotAddInCampHandler class is using for Not add new campaign member if camapign already sent a touchpoint. .
*/
public with sharing class CampMemberNotAddInCampHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param memberList ...
*/
    public static void addRecipientsIntoTouchPoint( List<CampaignMember> memberList) {
        try{
            Set<Id> leadIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Id campaignId;
            for (CampaignMember member : memberList) {
                campaignId = member.CampaignId;
                if (member.LeadId != null) {
                    leadIds.add(member.LeadId);
                } else if (member.ContactId != null) {
                    contactIds.add(member.ContactId);
                }
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>( [SELECT Id, TelosTouchSF__TT_Client_Id__c, Name FROM Contact WHERE Id = :contactIds]);
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, TelosTouchSF__TT_Client_Id__c, Name FROM Lead WHERE Id = :leadIds]);
            Campaign campObj = new Campaign();
            if (Schema.SObjectType.Campaign.isAccessible() &&
                    Schema.SObjectType.Campaign.isQueryable() &&
                    Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible() &&
                    Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible()) {
                campObj = [SELECT Id,Name,TelosTouchSF__TT_Campaign_Id__c,TelosTouchSF__Questions__c,
                           TelosTouchSF__Type__c,RecordTypeId
                           FROM Campaign
                           WHERE Id =: campaignId LIMIT 1];
            }

            BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper objWrapper = new BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper();
            objWrapper.campId = String.valueof(campObj.ID);
            objWrapper.campName = campObj.Name;
            objWrapper.TTcampId = campObj.TelosTouchSF__TT_Campaign_Id__c;
            objWrapper.campType = campObj.TelosTouchSF__Type__c;
            for (CampaignMember cMemObj : memberList) {
                if (cMemObj.ContactId != null) {
                    if (contactMap.get(cMemObj.ContactId).TelosTouchSF__TT_Client_Id__c != null) {
                        objWrapper.TTClientIdVsContId.put(
                                contactMap.get(cMemObj.ContactId).TelosTouchSF__TT_Client_Id__c,
                                cMemObj.ContactId
                        );
                        objWrapper.clientIds.add(
                                contactMap.get(cMemObj.ContactId).TelosTouchSF__TT_Client_Id__c
                        );
                    }
                } else if (cMemObj.LeadId != null) {
                    if (leadMap.get(cMemObj.LeadId).TelosTouchSF__TT_Client_Id__c != null) {
                        objWrapper.TTClientIdVsLeadId.put(
                                leadMap.get(cMemObj.LeadId).TelosTouchSF__TT_Client_Id__c,
                                cMemObj.LeadId
                        );
                        objWrapper.clientIds.add(leadMap.get(cMemObj.LeadId).TelosTouchSF__TT_Client_Id__c);
                    }
                }
            }

            if (objWrapper != null && objWrapper.clientIds != null && objWrapper.clientIds.size() > 0) {
                Database.executeBatch(new BatchAddRecipientsIntoTouchPoint(objWrapper),500);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage()+' Occurred At Line Number: '+ex.getLineNumber());
        }
    }

    public static void blockDelete(list<CampaignMember> lstMember){

        list<String> lstCampId = new list<String>();
        list<String> lstCttId = new list<String>();
        list<String> lstLeadId = new list<String>();

        for(CampaignMember member : lstMember){

            lstCampId.add(member.CampaignId);
            if(String.isNotBlank(member.ContactId)){ lstCttId.add(member.ContactId); }
            if(String.isNotBlank(member.LeadId)){ lstLeadId.add(member.LeadId); }

        }

        list<String> lstBlockedMembers = new list<String>();
        for(TelosTouchSF__Insights__c insight : [SELECT TelosTouchSF__Campaign2__c,TelosTouchSF__Contact__c,TelosTouchSF__Lead__c 
                                                    FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__Sent_Status__c != 'initial' AND 
                                                    TelosTouchSF__Campaign2__c IN: (lstCampId) AND 
                                                    (TelosTouchSF__Contact__c IN: (lstCttId) OR 
                                                    TelosTouchSF__Lead__c IN: (lstLeadId))])
        {
            String key = insight.TelosTouchSF__Campaign2__c;
            key += (String.isBlank(insight.TelosTouchSF__Contact__c)) ? insight.TelosTouchSF__Lead__c : insight.TelosTouchSF__Contact__c;
            lstBlockedMembers.add(key);
        }

        for(CampaignMember member : lstMember){

            String key = member.CampaignId;
            key += (String.isBlank(member.ContactId)) ? member.LeadId : member.ContactId;
            if(lstBlockedMembers.contains(key)){ member.addError('Can\'t delete a sent member'); }

        }


    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to check Campaign Sync Or Not.
* @param memberList stores the CampaignMember Record
*/
    public static void checkCampaignSyncOrNot(List<CampaignMember> memberList) {
        try {
            Set<Id> camIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id, List<CampaignMember>> campIdVsCampMemMap = new Map<Id, List<CampaignMember>>();
            Id TTRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('TelosTouch').getRecordTypeId();
            for (CampaignMember member : memberList) {
                camIds.add(member.CampaignId);
                if (!campIdVsCampMemMap.containsKey(member.CampaignId)) {
                    campIdVsCampMemMap.put( member.CampaignId,new List<CampaignMember>{ member } );
                } else {
                    campIdVsCampMemMap.get(member.CampaignId).add(member);
                }
                if (member.LeadId != null) {
                    leadIds.add(member.LeadId);
                } else if (member.ContactId != null) {
                    contactIds.add(member.ContactId);
                }
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, TelosTouchSF__TT_Client_Id__c, Name, TelosTouchSF__TT_Conflict__c FROM Contact WHERE Id = :contactIds]);
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, TelosTouchSF__TT_Client_Id__c, Name, TelosTouchSF__TT_Conflict__c FROM Lead WHERE Id = :leadIds]);
            List<Campaign> campaignList = new List<Campaign>();
            if (Schema.SObjectType.Campaign.isAccessible() && Schema.SObjectType.Campaign.isQueryable() &&
                    Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() && Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible()
                    && Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible()) {
                campaignList = [SELECT Id, TelosTouchSF__TT_Campaign_Id__c, TelosTouchSF__Questions__c, RecordTypeId
                FROM Campaign
                WHERE Id IN :camIds
                ];
            }
            for (Campaign cam : campaignList) {
                if (cam.RecordTypeId == TTRecordTypeId) {
                    if (campIdVsCampMemMap.containsKey(cam.Id)) {
                        for (CampaignMember cMemObj : campIdVsCampMemMap.get(cam.Id)) {
                            if (cMemObj.ContactId != null && (contactMap.get(cMemObj.ContactId).TelosTouchSF__TT_Client_Id__c == null || contactMap.get(cMemObj.ContactId).TelosTouchSF__TT_Conflict__c)) {
                                cMemObj.addError(System.Label.Cannot_Add_Text +' '+ contactMap.get(cMemObj.ContactId).Name + ' '+System.Label.Cannot_Add_Contact_Text);
                            } else if (cMemObj.LeadId != null && (leadMap.get(cMemObj.LeadId).TelosTouchSF__TT_Client_Id__c == null || leadMap.get(cMemObj.LeadId).TelosTouchSF__TT_Conflict__c) ) {
                                cMemObj.addError(System.Label.Cannot_Add_Text +' ' +leadMap.get(cMemObj.LeadId).Name +' '+System.Label.Cannot_Add_Lead_Text);
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception :::::::' +ex.getMessage() +'at Line Number:::::: ' +ex.getLineNumber());
        }
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param newList ...
*/
    public static void publishEventOnInsertAndUpdate(List<CampaignMember> newList){
        try{
            Set<String> campaignIdSet = new Set<String>();
            List<TelosTouchSF__Insight_Creation_Event__e> insightEventList = new List<TelosTouchSF__Insight_Creation_Event__e>();
            for(CampaignMember campMem : newList){
                campaignIdSet.add(campMem.campaignId);
            }
            for(String campId : campaignIdSet){
                insightEventList.add(new TelosTouchSF__Insight_Creation_Event__e(TelosTouchSF__Campaign__c = campId));
            }
            EventBus.publish(insightEventList);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage()+' Occurred At Line Number: '+ex.getLineNumber());
        }
    }

    public static void removeTTCampaignMember(list<CampaignMember> lstOldMember){

        try{

            map<String, String> mapCampId = new map<String, String>();
            map<String, String> mapCttId = new map<String, String>();
            map<String, String> mapLeadId = new map<String, String>();

            for(CampaignMember member : lstOldMember){

                mapCampId.put(member.CampaignId, null);
                if(String.isNotBlank(member.ContactId)){ mapCttId.put(member.ContactId, null); }
                if(String.isNotBlank(member.LeadId)){ mapLeadId.put(member.LeadId, null); }

            }

            map<String, list<String>> mapMembersByCamp = new map<String, list<String>>();
            
            for(Campaign camp : [SELECT Id,TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id IN: mapCampId.keySet()
                                 AND TelosTouchSF__TT_Campaign_Id__c != null])
            {
                mapCampId.put(camp.Id, camp.TelosTouchSF__TT_Campaign_Id__c);
            }

            if(!mapCttId.isEmpty()){
                for(Contact ctt : [SELECT Id,TelosTouchSF__TT_Client_Id__c FROM Contact WHERE Id IN: mapCttId.keySet()
                                   AND TelosTouchSF__TT_Client_Id__c != null]){
                    mapCttId.put(ctt.Id, ctt.TelosTouchSF__TT_Client_Id__c);
                }
            }

            if(!mapLeadId.isEmpty()){
                for(Lead aLead : [SELECT Id,TelosTouchSF__TT_Client_Id__c FROM Lead WHERE Id IN: mapCttId.keySet()
                                  AND TelosTouchSF__TT_Client_Id__c != null]){
                    mapLeadId.put(aLead.Id, aLead.TelosTouchSF__TT_Client_Id__c);
                }
            }

            for(CampaignMember member : lstOldMember){
                String ttCampId = mapCampId.get(member.CampaignId);
                String ttClientId = (String.isNotBlank(member.ContactId)) ? mapCttId.get(member.ContactId) : mapLeadId.get(member.LeadId);

                if(String.isBlank(ttCampId) || String.isBlank(ttClientId)) continue;

                list<String> lstMember = mapMembersByCamp.get(ttCampId);
                if(lstMember == null) { lstMember = new list<String>(); }
                lstMember.add(ttClientId);
                mapMembersByCamp.put(ttCampId, lstMember);
            }

            if(!mapMembersByCamp.isEmpty()){ Database.executeBatch(new BatchRemoveCampaignRecipient(mapMembersByCamp),1); }

        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'CampMemberNotAddInCampHandler', 'removeTTCampaignMember', null);
        }

    }

    public static void updateTTCampaignMember(list<CampaignMember> lstMember){

        try {

            List<CampaignMember> lstSyncMember = [SELECT Id,Name,Campaign.Id,Campaign.Name,
                                                Campaign.TelosTouchSF__TT_Campaign_Id__c,Campaign.TelosTouchSF__Type__c,
                                                ContactId,Contact.TelosTouchSF__TT_Client_Id__c,
                                                LeadId,Lead.TelosTouchSF__TT_Client_Id__c 
                                                FROM CampaignMember WHERE Id IN: lstMember
                                                AND Campaign.TelosTouchSF__TT_Campaign_Id__c != null
                                                AND (Contact.TelosTouchSF__TT_Client_Id__c != null
                                                OR Lead.TelosTouchSF__TT_Client_Id__c != null)];
            
            if(lstSyncMember.isEmpty()){ return; }

            map<String, list<String>> mapCampMember = new map<String, list<String>>();
            map<String, Campaign> mapTTCamp = new map<String, Campaign>();
            map<String, String> mapTTCtt = new map<String, String>();
            map<String, String> mapTTLead = new map<String, String>();
            for(CampaignMember member : lstSyncMember){

                list<String> aLstMember = mapCampMember.get(member.Campaign.TelosTouchSF__TT_Campaign_Id__c);
                if(aLstMember == null){ aLstMember = new list<String>(); }

                if(member.Contact.TelosTouchSF__TT_Client_Id__c != null){
                    aLstMember.add(member.Contact.TelosTouchSF__TT_Client_Id__c);
                    mapTTCtt.put(member.Contact.TelosTouchSF__TT_Client_Id__c,member.ContactId);
                } else if(member.Lead.TelosTouchSF__TT_Client_Id__c != null){
                    aLstMember.add(member.Lead.TelosTouchSF__TT_Client_Id__c);
                    mapTTLead.put(member.Lead.TelosTouchSF__TT_Client_Id__c,member.LeadId);
                }

                mapCampMember.put(member.Campaign.TelosTouchSF__TT_Campaign_Id__c, aLstMember);
                mapTTCamp.put(member.Campaign.TelosTouchSF__TT_Campaign_Id__c, member.Campaign);

            }

            for(String ttCampId : mapCampMember.keySet()){

                Campaign camp = mapTTCamp.get(ttCampId);

                BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper objWrapper = new BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper();
                objWrapper.campId = camp.Id;
                objWrapper.campName = camp.Name;
                objWrapper.TTcampId = camp.TelosTouchSF__TT_Campaign_Id__c;
                objWrapper.campType = camp.TelosTouchSF__Type__c;
                objWrapper.clientIds = mapCampMember.get(ttCampId);
                objWrapper.TTClientIdVsContId = mapTTCtt;
                objWrapper.TTClientIdVsLeadId = mapTTLead;

                Database.executeBatch(new BatchAddRecipientsIntoTouchPoint(objWrapper),500);

            }


        } catch (Exception ex) {
            TelosTouchUtility.generateErrorLog(ex, 'CampMemberNotAddInCampHandler', 'updateTTCampaignMember', null);
        }

    }
}