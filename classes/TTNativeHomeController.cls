public with sharing class TTNativeHomeController {
    @AuraEnabled
    public static string getSentVsCompletedData(){
        try {
            List<Campaign> campaignList = [SELECT Id, Name, (SELECT Id FROM TelosTouchSF__Insights__r) FROM Campaign WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
            Set<Id> campaignIdSet = new Set<Id>();
            Map<Id, Map<String, Object>> campaignIdVsInsightsMap = new Map<Id, Map<String, Object>>();
            Integer count = 0;
            for(Campaign campObj : campaignList){
                if(campObj.TelosTouchSF__Insights__r.size()>0){
                    ++count;
                    campaignIdSet.add(campObj.Id);
                }
                if(count == 3){
                    break;
                }
            }
            for(TelosTouchSF__Insights__c insight :[SELECT Id, CreatedDate, TelosTouchSF__Completed_At__c, TelosTouchSF__Campaign2__c, TelosTouchSF__TouchPoint_Name__c, TelosTouchSF__Campaign2__r.CreatedDate FROM TelosTouchSF__Insights__c WHERE TelosTouchSF__Campaign2__c IN: campaignIdSet WITH SECURITY_ENFORCED ORDER BY LastModifiedDate ASC]){
                if(!campaignIdVsInsightsMap.containsKey(insight.TelosTouchSF__Campaign2__c)){
                    Map<String, Object> insightMap = new Map<String, Object>();
                    insightMap.put('name', (Object) insight.TelosTouchSF__TouchPoint_Name__c);
                    insightMap.put('id', (Object) insight.TelosTouchSF__Campaign2__c);
                    insightMap.put('createdAt', (Object) insight.TelosTouchSF__Campaign2__r.CreatedDate.format('MMM dd, yyyy hh:mm a'));
                    insightMap.put('sentCount', (Object) 1);
                    if(insight.TelosTouchSF__Completed_At__c != null){
                        insightMap.put('completedCount', (Object) 1);
                    }else{
                        insightMap.put('completedCount', (Object) 0);
                    }
                    insightMap.put('progress', (Object) ((Double.valueOf(insightMap.get('completedCount')) / Double.valueOf(insightMap.get('sentCount'))) * 100).round() );
                    if(Integer.valueOf(insightMap.get('progress')) == 100){
                        insightMap.put('checkBarProgress', (Object) true);
                        insightMap.put('checkRingProgress', (Object) false);
                    }else{
                        insightMap.put('checkBarProgress', (Object) false);
                        insightMap.put('checkRingProgress', (Object) true);
                    }
                    insightMap.put('progressString', (Object) String.valueOf(insightMap.get('sentCount')) + ' Sent / ' + String.valueOf(insightMap.get('completedCount')) + ' Completed');
                    campaignIdVsInsightsMap.put(insight.TelosTouchSF__Campaign2__c, insightMap);
                }else{
                    Map<String, Object> insightMap = campaignIdVsInsightsMap.get(insight.TelosTouchSF__Campaign2__c);
                    insightMap.put('sentCount', (Object) (Integer.valueOf(insightMap.get('sentCount')) + 1));
                    if(insight.TelosTouchSF__Completed_At__c != null){
                        insightMap.put('completedCount', (Object) (Integer.valueOf(insightMap.get('completedCount')) + 1));
                    }
                    insightMap.put('progress', (Object) ((Double.valueOf(insightMap.get('completedCount')) / Double.valueOf(insightMap.get('sentCount'))) * 100).round() );
                    if(Integer.valueOf(insightMap.get('progress')) == 100){
                        insightMap.put('checkBarProgress', (Object) true);
                        insightMap.put('checkRingProgress', (Object) false);
                    }else{
                        insightMap.put('checkBarProgress', (Object) false);
                        insightMap.put('checkRingProgress', (Object) true);
                    }
                    insightMap.put('progressString', (Object) String.valueOf(insightMap.get('sentCount')) + ' Sent / ' + String.valueOf(insightMap.get('completedCount')) + ' Completed');
                    campaignIdVsInsightsMap.put(insight.TelosTouchSF__Campaign2__c, insightMap);
                }
            }
            return JSON.serialize(campaignIdVsInsightsMap.values());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getChartData(){
        try {
            Date dt1 = Date.newInstance(Date.today().year(), Date.today().addMonths(-3).month(), 1);
            Map<String, Map<String, Object>> chartDataMap = new Map<String, Map<String, Object>>();
            for(Integer i=0; i>=-3; i--){
                Map<String, Object> insightMap = new Map<String, Object>();
                insightMap.put('opened', (Object) 0);
                insightMap.put('completed', (Object) 0);
                insightMap.put('sent', (Object) 0);
                chartDataMap.put(Datetime.now().addMonths(i).format('MMM'), insightMap);
            }
            for(TelosTouchSF__Insights__c insight : [SELECT Id, CreatedDate, TelosTouchSF__Opened_At__c, TelosTouchSF__Completed_At__c FROM TelosTouchSF__Insights__c WHERE CreatedDate >=: dt1 AND CreatedDate <=: Datetime.now() WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]){
                System.debug(insight);
                if(chartDataMap.containsKey(insight.CreatedDate.format('MMM'))){
                    Map<String, Object> insightMap = new Map<String, Object>();
                    insightMap = chartDataMap.get(insight.CreatedDate.format('MMM'));
                    if(insight.TelosTouchSF__Opened_At__c != null){
                        insightMap.put('opened', (Object) (Integer.valueOf(insightMap.get('opened')) + 1));
                    }
                    if(insight.TelosTouchSF__Completed_At__c != null){
                        insightMap.put('completed', (Object) (Integer.valueOf(insightMap.get('completed')) + 1));
                    }
                    insightMap.put('sent', (Object) (Integer.valueOf(insightMap.get('sent')) + 1));
                    chartDataMap.put(insight.CreatedDate.format('MMM'), insightMap);
                }
            }
            return JSON.serialize(chartDataMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
