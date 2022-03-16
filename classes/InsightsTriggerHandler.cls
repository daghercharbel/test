/**
* @author Cloud Analogy
* @date 02/08/2021
* @description InsightsTriggerHandler..........
*/
public class InsightsTriggerHandler {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param newList ......
*/
    public static void publishEventOnInsertAndUpdate(List<TelosTouchSF__Insights__c> newList){
        try{
            Set<String> campaignIdSet = new Set<String>();
            List<TelosTouchSF__Insight_Creation_Event__e> insightEventList = new List<TelosTouchSF__Insight_Creation_Event__e>();
            for(TelosTouchSF__Insights__c insight : newList){
                campaignIdSet.add(insight.TelosTouchSF__Campaign2__c);
            }
            for(String campId : campaignIdSet){
                insightEventList.add(new TelosTouchSF__Insight_Creation_Event__e(TelosTouchSF__Campaign__c = campId));
            }
            EventBus.publish(insightEventList);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'Exception :::::::'+ex.getMessage()+'on Line Number:::::: '+ex.getLineNumber());
        }
    }
}