/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
public with sharing class TT_FeatureToggle implements Database.Batchable<sObject>,  Database.AllowsCallouts {
   /**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description ....
  * @param BC
* @return Database.QueryLocator query ......
*/
   public Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT Id, MasterLabel, TelosTouchSF__TT_Flag__c, TelosTouchSF__SF_Flag__c from TelosTouchSF__TT_Feature_Flag__mdt LIMIT 1';
      return Database.getQueryLocator(String.escapeSingleQuotes(query).replace('\\', ''));
   }
   /**
   * @author Cloud Analogy
   * @date 02/08/2021
   * @description ....
   * @param BC
   * @param  scope
   */
   public void execute(Database.BatchableContext BC, List<TelosTouchSF__TT_Feature_Flag__mdt> scope){
      for(TelosTouchSF__TT_Feature_Flag__mdt featureMdt : scope){
         Boolean isActive = featureMdt.TelosTouchSF__TT_Flag__c;
         if(!(Test.isRunningTest())){
            if(featureMdt.MasterLabel == 'Invite'){
               isActive = TelosTouchUtility.checkInviteFunctionality();
            }
         }
         TelosTouchUtility.createUpdateMetadata(isActive, featureMdt.TelosTouchSF__SF_Flag__c, featureMdt.MasterLabel);
      }
   }
   /**
   * @author Cloud Analogy
   * @date 02/08/2021
   * @description finish method
   * @param BC
   */
   public void finish(Database.BatchableContext BC){
      System.debug(LoggingLevel.DEBUG,'Finish method is called');
   }
}