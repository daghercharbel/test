public with sharing class FetchUnsubscribedClients {
    @AuraEnabled
    public static List<Object> getUnsubscribedClientsFromCampaign(String recId) {
        try {
            //String val= '\'%' + String.escapeSingleQuotes(name.trim()) + '%\'';
            String query = 'SELECT Name, Email, Phone FROM CampaignMember WHERE CampaignId =:recId AND (Contact.TelosTouchSF__Subscribed__c = \'No\' OR Lead.TelosTouchSF__Subscribed__c = \'No\')';
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
}