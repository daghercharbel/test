/**
* @author Cloud Analogy
* @date 02/08/2021
* @description CampMemberNotAddInCampHandler class is using for Not add new campaign member if camapign already sent a touchpoint. .
*/
public with sharing class CampMemberNotAddInCampHandler {
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
                if (cam.RecordTypeId == TTRecordTypeId /*&& cam.TelosTouchSF__TT_Campaign_Id__c != null && String.isNotEmpty(cam.TelosTouchSF__TT_Campaign_Id__c)*/) {
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
* @param memberList ...
*/
    public static void addRecipientsIntoTouchPoint( List<CampaignMember> memberList) {
        try{
            Set<Id> leadIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id, List<CampaignMember>> campIdVsCampMemMap = new Map<Id, List<CampaignMember>>();
            for (CampaignMember member : memberList) {
                if (!campIdVsCampMemMap.containsKey(member.CampaignId)) {
                    campIdVsCampMemMap.put( member.CampaignId, new List<CampaignMember>{ member });
                } else {
                    campIdVsCampMemMap.get(member.CampaignId).add(member);
                }
                if (member.LeadId != null) {
                    leadIds.add(member.LeadId);
                } else if (member.ContactId != null) {
                    contactIds.add(member.ContactId);
                }
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>( [SELECT Id, TelosTouchSF__TT_Client_Id__c, Name FROM Contact WHERE Id = :contactIds]);
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, TelosTouchSF__TT_Client_Id__c, Name FROM Lead WHERE Id = :leadIds]);
            List<Campaign> campaignList = new List<Campaign>();
            if (Schema.SObjectType.Campaign.isAccessible() &&
                Schema.SObjectType.Campaign.isQueryable() &&
                Schema.sObjectType.Campaign.fields.TelosTouchSF__TT_Campaign_Id__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.TelosTouchSF__Questions__c.isAccessible() &&
                Schema.sObjectType.Campaign.fields.RecordTypeId.isAccessible()) {
                    campaignList = [SELECT Id, Name, TelosTouchSF__TT_Campaign_Id__c, TelosTouchSF__Questions__c, RecordTypeId
                                    FROM Campaign
                                    WHERE Id IN :campIdVsCampMemMap.keyset()];
                }
            List<BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper> finalCamMemList = new List<BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper>();
            
            for (Campaign cam : campaignList) {
                if (campIdVsCampMemMap.containsKey(cam.Id) && cam.TelosTouchSF__TT_Campaign_Id__c != null && String.isNotEmpty(cam.TelosTouchSF__TT_Campaign_Id__c)) {
                    BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper objWrapper = new BatchAddRecipientsIntoTouchPoint.AddRecipientsWrapper();
                    objWrapper.campId = String.valueof(cam.ID);
                    objWrapper.campName = cam.Name;
                    objWrapper.TTcampId = cam.TelosTouchSF__TT_Campaign_Id__c;
                    finalCamMemList.add(objWrapper);
                    for (CampaignMember cMemObj : campIdVsCampMemMap.get(cam.Id)) {
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
                }
            }
            
            if (finalCamMemList != null && finalCamMemList.size() > 0) {
                Database.executeBatch(new BatchAddRecipientsIntoTouchPoint(finalCamMemList),50);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage()+' Occurred At Line Number: '+ex.getLineNumber());
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
}