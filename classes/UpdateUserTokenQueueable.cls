/**
* @author Cloud Analogy
* @date 02/08/2021
* @description UpdateUserTokenQueueable class is a Queueable Class used to update user token.
*/
global  with sharing class UpdateUserTokenQueueable implements Queueable, Database.AllowsCallouts { 
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param context ....
*/
    global  void execute(QueueableContext context) {
        List<User> userList = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isQueryable() &&
           Schema.sObjectType.User.fields.TelosTouchSF__Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserName__c.isAccessible()
           && Schema.sObjectType.User.fields.TelosTouchSF__Auth_Token__c.isAccessible()
           && Schema.sObjectType.User.fields.TelosTouchSF__TT_UserId__c.isAccessible()){
              if(!Test.isRunningTest()){
                  userList = [SELECT id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c,TelosTouchSF__TT_UserName__c FROM User WHERE TelosTouchSF__TT_UserId__c != null AND isActive = true LIMIT 10000];
              }else if(Test.isRunningTest()){
                  userList = [SELECT id, TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserName__c, TelosTouchSF__TT_UserId__c FROM User LIMIT 10000];
              }
          }
        if(userList.size() >0){
            Database.executeBatch(new UpdateUserTokenBatch(userList),50);
        }
    }
}