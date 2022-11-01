public with sharing class SFBatchToRevokeLicence implements Database.Batchable<sObject>,Database.Stateful{
    public List<Id> userList;
    public SFBatchToRevokeLicence(List<Id> userIdList){
        this.userList=userIdList;
        List<PermissionSetAssignment> permsList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE (PermissionSet.Name = 'TTPSetForInsightObjMDRelations' OR PermissionSet.Name = 'TelosTouch_Custom_Permission') AND AssigneeId IN:userList WITH SECURITY_ENFORCED LIMIT 2] ; 
                    if(Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.PermissionSetAssignment.isDeletable() && permsList.size()>0){
                        delete permsList;
                    }
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String q = 'SELECT TelosTouchSF__Auth_Token__c, TelosTouchSF__TT_UserId__c, TelosTouchSF__TT_UserName__c FROM User where Id IN :userList WITH SECURITY_ENFORCED';
       return Database.getQueryLocator(q);
    }
    public void execute(Database.BatchableContext BC,List<user> returnedUserList){
        List<User> ttUserAccess = new List<User> ();
        for(User obj: returnedUserList){
            obj.TelosTouchSF__Auth_Token__c ='';
            obj.TelosTouchSF__TT_UserId__c ='';
            obj.TelosTouchSF__TT_UserName__c ='';
            ttUserAccess.add(obj);
        } 
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.isUpdateable() && ttUserAccess.size()>0){
            update ttUserAccess;
        }
    }
    public void finish(Database.BatchableContext BC){

    } 
}