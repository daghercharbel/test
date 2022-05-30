public with sharing class FetchUnsubscribedClients {
    @AuraEnabled
    public static List<Object> getUnsubscribedClientsFromCampaign(String recId) {
        try {
            //String val= '\'%' + String.escapeSingleQuotes(name.trim()) + '%\'';
            String query = 'SELECT Name, Email,ContactId, LeadId, Phone FROM CampaignMember WHERE CampaignId =:recId AND (Contact.TelosTouchSF__Subscribed__c = \'No\' OR Lead.TelosTouchSF__Subscribed__c = \'No\')';
            List<Object> cmData = Database.query(query);
            System.debug(cmData);
            //List<CampaignMember> cmList = [SELECT Name, Email, Phone FROM CampaignMember WHERE CampaignId =: recId AND (Contact.TelosTouchSF__Subscribed__c = 'No' OR Lead.TelosTouchSF__Subscribed__c = 'No') WITH Security_Enforced];
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
            Database.DeleteResult[] drList = Database.delete(deleteIdSet, true);
            if(drList.size()>0){
                return 'success';
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