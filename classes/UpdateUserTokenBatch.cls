/**
* @author Cloud Analogy
* @date 02/08/2021
* @description UpdateUserTokenBatch class is a batch class and it is used to update token of each user.
*/
global  with sharing class UpdateUserTokenBatch implements Database.batchable<sObject>, Database.AllowsCallouts {
    global List<User> userList;
    public static final TelosTouchUtility.AdminCredentialsWrapper adminCredentials = TelosTouchSF.TelosTouchUtility.refreshAdminAccessToken();
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description This constructor initializes userList.
* @param getUserList stores list of all users in the org.
*/
    global UpdateUserTokenBatch(List<User> getUserList){
        userList = new List<User>();
        userList = getUserList;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param bc ....
* @return sObject userList ....
*/
    global Iterable<sObject> start(Database.BatchableContext bc){
        return userList;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param BC ....
* @param userList ....
*/
    global  void execute(Database.BatchableContext BC,List<User> userList){
        if(userList.size() >0){
            TelosTouchSF.TelosTouchUtility.TTUserWrapper  ttuserObj = new TelosTouchSF.TelosTouchUtility.TTUserWrapper();
            for(User userObj: userList){
                if(Schema.sObjectType.User.fields.TelosTouchSF__Token__c.isAccessible() && Schema.sObjectType.User.fields.TelosTouchSF__Token__c.isUpdateable() ){
                    if(adminCredentials != null){
                        ttuserObj = TelosTouchSF.TelosTouchUtility.getTokenForEachUser(userObj.TelosTouchSF__TT_UserName__c, adminCredentials);
                        if(ttuserObj != null){
                            userObj.TelosTouchSF__Auth_Token__c = ttuserObj.TTToken;
                            userObj.TelosTouchSF__TT_UserName__c = ttuserObj.TTUserName;
                        }
                    }
                }
            }
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isUpdateable() && !Test.isRunningTest()){
                UPDATE userList;
            } 
        }
    } 
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
* @param BC ....
*/
    global void finish(Database.BatchableContext BC){
        /*if(adminCredentials != null){
Integer noOfDays = 0;
if(adminCredentials.RefreshTokenLastmodifiedDate != null){
noOfDays = adminCredentials.RefreshTokenLastmodifiedDate.date().daysBetween( Date.today() );   
if(noOfDays >8){

}
}
}*/
        if(adminCredentials != null){
            TelosTouchUtility.updateCustomMetadata(adminCredentials);
        }
    }
}