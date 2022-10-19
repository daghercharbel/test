public with sharing class FetchUnsubscribedClients {
    @AuraEnabled
    public static List<Object> getUnsubscribedClientsFromCampaign(String recId) {
        try {
            String query = 'SELECT Name, Email,ContactId, LeadId, Phone FROM CampaignMember WHERE CampaignId =:recId AND (Contact.TelosTouchSF__Subscribed__c = \'No\' OR Lead.TelosTouchSF__Subscribed__c = \'No\')';
            List<Object> cmData = Database.query(query);
            System.debug(cmData);
            if(cmData.size()>0 && cmData != Null){
                System.debug('data:: '+ cmData);
                return cmData;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error is:: '+e.getMessage() + ' at line no:: '+ e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static String removeClient(String idsData){
        try {
            List<Id> deleteIdSet = (List<Id>) JSON.deserialize(idsData, List<Id>.class);
            System.debug(deleteIdSet);
            List<CampaignMember> campaignMemList = new List<CampaignMember>();
            campaignMemList = [SELECT Id, ContactId, LeadId, CampaignId FROM CampaignMember WHERE Id IN: deleteIdSet WITH SECURITY_ENFORCED];
            Map<Id, CampaignMember> clientIdVsCampMemMap = new Map<Id, CampaignMember>();
            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            Boolean campaignSynced = false;
            if(campaignMemList.size() > 0){
                campaignSynced = [SELECT Id, TelosTouchSF__TT_Campaign_Id__c FROM Campaign WHERE Id =: campaignMemList[0].CampaignId].TelosTouchSF__TT_Campaign_Id__c != null ? true : false;
                if(campaignSynced){
                    for(CampaignMember campMemObj : campaignMemList){
                        if(campMemObj.ContactId != null && campMemObj.LeadId == null){
                            contactIdSet.add(campMemObj.ContactId);
                            clientIdVsCampMemMap.put(campMemObj.ContactId, campMemObj);
                        }else if(campMemObj.ContactId == null && campMemObj.LeadId != null){
                            leadIdSet.add(campMemObj.LeadId);
                            clientIdVsCampMemMap.put(campMemObj.LeadId, campMemObj);
                        }
                    }
                    if(contactIdSet.size() > 0 || leadIdSet.size() > 0){
                        List<TelosTouchSF__Insights__c> insightsList = new List<TelosTouchSF__Insights__c>();
                        insightsList = [SELECT Id, TelosTouchSF__Contact__c, TelosTouchSF__Lead__c FROM TelosTouchSF__Insights__c 
                        WHERE (TelosTouchSF__Campaign2__c =: campaignMemList[0].CampaignId) AND
                        (TelosTouchSF__Contact__c IN: contactIdSet OR TelosTouchSF__Lead__c IN: leadIdSet) WITH SECURITY_ENFORCED];
                        for(TelosTouchSF__Insights__c insight : insightsList){
                            if(insight.TelosTouchSF__Contact__c != null && insight.TelosTouchSF__Lead__c == null && clientIdVsCampMemMap.containsKey(insight.TelosTouchSF__Contact__c)){
                                clientIdVsCampMemMap.remove(insight.TelosTouchSF__Contact__c);
                            }else if(insight.TelosTouchSF__Contact__c == null && insight.TelosTouchSF__Lead__c != null && clientIdVsCampMemMap.containsKey(insight.TelosTouchSF__Lead__c)){
                                clientIdVsCampMemMap.remove(insight.TelosTouchSF__Lead__c);
                            }
                        }
                    }
                }else{
                    for(CampaignMember campMemObj : campaignMemList){
                        if(campMemObj.ContactId != null && campMemObj.LeadId == null){
                            clientIdVsCampMemMap.put(campMemObj.ContactId, campMemObj);
                        }else if(campMemObj.ContactId == null && campMemObj.LeadId != null){
                            clientIdVsCampMemMap.put(campMemObj.LeadId, campMemObj);
                        }
                    }
                }
            }else{
                return null;
            }
            Database.DeleteResult[] drList;
            if(deleteIdSet.size() == clientIdVsCampMemMap.values().size()){
                drList = Database.delete(deleteIdSet, true);
            }else if(clientIdVsCampMemMap.values().size() < deleteIdSet.size()){
                drList = Database.delete(clientIdVsCampMemMap.values(), true);
            }
            if(drList.size()>0 && drList.size() == deleteIdSet.size()){
                return 'success';
            }else if(drList.size()>0 && drList.size() == clientIdVsCampMemMap.values().size()){
                return 'partial success';
            }
            return null;
        } catch (Exception e) {
            System.debug('Error is:: '+e.getMessage() + ' at line no:: '+ e.getLineNumber());
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static String resubscribeClient(String conIds, String leadIds){
        try {
            system.debug('conIds:::'+conIds);
            system.debug('leadIds:::'+leadIds);
            Set<Id> contactIdSet = (Set<Id>) JSON.deserialize(conIds, Set<Id>.class);
            Set<Id> leadIdSet = (Set<Id>) JSON.deserialize(leadIds, Set<Id>.class);
            List<Contact> conList = [SELECT TelosTouchSF__Subscribed__c FROM Contact WHERE Id IN: contactIdSet WITH Security_Enforced];
            List<Lead> leadList = [SELECT TelosTouchSF__Subscribed__c FROM Lead WHERE Id IN: leadIdSet WITH Security_Enforced];
            System.debug('contact:: '+ conList);
            System.debug('lead:: '+ leadList);
            if(conList.size()>0 && conList != Null){
                for(Contact con: conList){
                    con.TelosTouchSF__Subscribed__c = 'Yes';
                }
            }
            if(leadList.size()>0 && leadList != Null){
                for(Lead leadObj: leadList){
                    leadObj.TelosTouchSF__Subscribed__c = 'Yes';
                }
            }
            Boolean flag = false, flag1 = false;
            if(conList.size()>0){
                update conList;
                flag = true;
            }
            if(leadList.size()>0){
                update leadList;
                flag1 = true;
            }
            if(flag || flag1){
                return 'success';
            }
            return null;
        } catch (Exception e) {
            System.debug('Error is:: '+e.getMessage() + ' at line no:: '+ e.getLineNumber());
            return e.getMessage();
        }
    }
}