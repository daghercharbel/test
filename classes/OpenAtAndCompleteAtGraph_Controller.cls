/**
* @author Cloud Analogy
* @date 02/08/2021
* @description OpenAtAndCompleteAtGraph_Controller is used to get the touchpoint conversation user.
*/
public with sharing class OpenAtAndCompleteAtGraph_Controller {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This method is used to get touchpoint conversation records.
* @param recordId gets the id of the record
* @return String OpenAtAndCompletedWrapperObj ....
*/
    @AuraEnabled
    public static String getConversationRecords(String recordId) {
        try{
            OpenAtAndCompletedWrapper OpenAtAndCompletedWrapperObj = new OpenAtAndCompletedWrapper();
            List<OpenedAtCompletedWrapper> OpenedAtCompletedWrapperList = new List<OpenedAtCompletedWrapper>();
            List<TelosTouchSF__Insights__c> insightsList = new List<TelosTouchSF__Insights__c>();
            List<StartAtEndAtWraper> startAtEndAtwrapperList = new List<StartAtEndAtWraper>();
            Map<Date,Map<String,Integer>> DateVSStartEndDateAtNameVSContactSizeMap = new Map<Date,Map<String,Integer>>();
            Set<Date> sameDate = new Set<Date>();
            Set<string> OpenAndCompletedNameSet = new Set<string>();
            List<string> OpenedAtCompletedNameList = new List<string>();
            if(Schema.sObjectType.TelosTouchSF__Insights__c.isAccessible()
               && Schema.sObjectType.TelosTouchSF__Insights__c.isQueryable()
               && Schema.sObjectType.TelosTouchSF__Insights__c.fields.Name.isAccessible()
               && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Opened_At__c.isAccessible()
               && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Completed_At__c.isAccessible()
              && Schema.sObjectType.TelosTouchSF__Insights__c.fields.TelosTouchSF__Campaign2__c.isAccessible()){
                  insightsList = [SELECT Id,
                                  Name,
                                  TelosTouchSF__Opened_At__c,
                                  TelosTouchSF__Completed_At__c
                                  FROM TelosTouchSF__Insights__c
                                  WHERE TelosTouchSF__Campaign2__c =:recordId
                                  ORDER BY TelosTouchSF__Opened_At__c ASC LIMIT 2000];
              }
            for(TelosTouchSF__Insights__c insightObj : insightsList){
                OpenAtAndCompletedWrapperObj.userName = insightObj.Name;
                if(insightObj.TelosTouchSF__Opened_At__c != null){
                    Date OpenDate = date.newinstance(insightObj.TelosTouchSF__Opened_At__c.year(), insightObj.TelosTouchSF__Opened_At__c.month(), insightObj.TelosTouchSF__Opened_At__c.day());
                    sameDate.add(OpenDate);
                }if(insightObj.TelosTouchSF__Completed_At__c != null){
                    Date completedDate = date.newinstance(insightObj.TelosTouchSF__Completed_At__c.year(), insightObj.TelosTouchSF__Completed_At__c.month(), insightObj.TelosTouchSF__Completed_At__c.day());
                    sameDate.add(completedDate);
                }
            }
            for(DateTime dt : sameDate){
                for(TelosTouchSF__Insights__c insightObj : insightsList){
                    if(insightObj.TelosTouchSF__Opened_At__c != null){
                        StartAtEndAtWraper startAndEndWrapperObj = new StartAtEndAtWraper();
                        if(date.newinstance(insightObj.TelosTouchSF__Opened_At__c.year(), insightObj.TelosTouchSF__Opened_At__c.month(), insightObj.TelosTouchSF__Opened_At__c.day()) == dt){
                            startAndEndWrapperObj.openAndCompletedDate = date.newinstance(insightObj.TelosTouchSF__Opened_At__c.year(), insightObj.TelosTouchSF__Opened_At__c.month(), insightObj.TelosTouchSF__Opened_At__c.day());
                            startAndEndWrapperObj.openNameAndCompletedName = System.Label.Campaign_Graph_Opened_Text;
                            startAtEndAtwrapperList.add(startAndEndWrapperObj);
                        }
                    }if(insightObj.TelosTouchSF__Completed_At__c != null){
                        StartAtEndAtWraper startAndEndWrapperObj = new StartAtEndAtWraper();
                        if(date.newinstance(insightObj.TelosTouchSF__Completed_At__c.year(), insightObj.TelosTouchSF__Completed_At__c.month(), insightObj.TelosTouchSF__Completed_At__c.day()) == dt){
                            startAndEndWrapperObj.openAndCompletedDate = date.newinstance(insightObj.TelosTouchSF__Completed_At__c.year(), insightObj.TelosTouchSF__Completed_At__c.month(), insightObj.TelosTouchSF__Completed_At__c.day());
                            startAndEndWrapperObj.openNameAndCompletedName = System.Label.Campaign_Graph_Completed_Text;
                            startAtEndAtwrapperList.add(startAndEndWrapperObj);
                        }
                    }
                }
            }
            for(StartAtEndAtWraper starEndObj : startAtEndAtwrapperList){
                if(String.isNotBlank(starEndObj.openNameAndCompletedName)){
                    OpenAndCompletedNameSet.add(starEndObj.openNameAndCompletedName);
                }
                if(!DateVSStartEndDateAtNameVSContactSizeMap.containsKey(starEndObj.openAndCompletedDate)){
                    DateVSStartEndDateAtNameVSContactSizeMap.put(starEndObj.openAndCompletedDate,new Map<String,Integer>());
                }
                Map<String,Integer> MapObj = DateVSStartEndDateAtNameVSContactSizeMap.get(starEndObj.openAndCompletedDate);
                if(String.isNotBlank(starEndObj.openNameAndCompletedName) && starEndObj.openNameAndCompletedName != ''){
                    if(!MapObj.containsKey(starEndObj.openNameAndCompletedName)){
                        MapObj.put(starEndObj.openNameAndCompletedName, 0);
                    }
                    MapObj.put(starEndObj.openNameAndCompletedName, MapObj.get(starEndObj.openNameAndCompletedName)+1);
                }
            }
            Set<Date> DateSSet = DateVSStartEndDateAtNameVSContactSizeMap.keySet();
            List<Date> DateList = new List<Date>();
            DateList.addAll(DateSSet);
            DateList.sort();
            for(Date d : DateList){
                OpenedAtCompletedWrapper OpenedAtCompletedWrapperObj = new OpenedAtCompletedWrapper();
                OpenedAtCompletedWrapperObj.name = d;
                List<DataWrapper> DataWrapperList = new List<DataWrapper>();
                Map<String,Integer> MapObj = DateVSStartEndDateAtNameVSContactSizeMap.get(d);
                for(string projectName : MapObj.keySet()){
                    DataWrapper DataWrapperObj = new DataWrapper();
                    DataWrapperObj.OpenAtCompletedAtName = projectName;
                    DataWrapperObj.Data = MapObj.get(projectName);
                    DataWrapperList.add(DataWrapperObj);
                }
                OpenedAtCompletedWrapperObj.dataWrapperList = DataWrapperList;
                OpenedAtCompletedWrapperList.add(OpenedAtCompletedWrapperObj);
            }
            OpenedAtCompletedNameList.addAll(OpenAndCompletedNameSet);
            OpenAtAndCompletedWrapperObj.OpenedAtCompletedNameList = OpenedAtCompletedNameList;
            OpenAtAndCompletedWrapperObj.OpenedAtCompletedWrapperList = OpenedAtCompletedWrapperList;
            return JSON.serialize(OpenAtAndCompletedWrapperObj);
        }catch (Exception ex) {
            System.debug(LoggingLevel.WARN,'Exception::'+ex.getMessage() +'On Line ::'+ex.getLineNumber());
            throw new AuraHandledException('Oops! Something went wrong: ' + ex.getMessage());
        }
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description OpenAtAndCompletedWrapper is used to get list of OpenedAtCompletedNameList, list of OpenedAtCompletedWrapperList and userName.
*/
    Public class OpenAtAndCompletedWrapper{
        @AuraEnabled
        public List<String> OpenedAtCompletedNameList;
        @AuraEnabled
        public List<OpenedAtCompletedWrapper> OpenedAtCompletedWrapperList;
        @AuraEnabled
        public String userName;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description OpenedAtCompletedWrapper is used to get name and list of DataWrapper.
*/
    public class OpenedAtCompletedWrapper{
        @AuraEnabled
        public Date name;
        @AuraEnabled
        public List<DataWrapper> dataWrapperList;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description DataWrapper is used to get OpenAtCompletedAtName and Data.
*/
    public class DataWrapper{
        @AuraEnabled
        public String OpenAtCompletedAtName;
        @AuraEnabled
        public Decimal Data;
    }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description StartAtEndAtWraper is used to get openNameAndCompletedName,openAndCompletedDate and openSizeAndCompletedSize.
*/
    public class StartAtEndAtWraper{
        @AuraEnabled 
        public String openNameAndCompletedName;
        @AuraEnabled
        public Date openAndCompletedDate;
        @AuraEnabled
        public Integer openSizeAndCompletedSize;
    }
}