/**
* @author Cloud Analogy
* @date 02/08/2021
* @description This trigger is written on the user object to update users.
*/
trigger UserTrigger on User (before update) {
    if(TelosTouchSF.UserTriggerHandler.run == true){
        if(trigger.isbefore && trigger.isUpdate){
            List<User> newUserList = new List<User>();
            for(User usr : Trigger.new){
                if((usr.TelosTouchSF__TT_UserId__c != null) &&
                        (usr.isActive != Trigger.oldMap.get(usr.Id).isActive) ||
                        ((usr.LanguageLocaleKey != null && usr.LanguageLocaleKey != Trigger.oldMap.get(usr.Id).LanguageLocaleKey) ||
                                (usr.TimeZoneSidKey != null && usr.TimeZoneSidKey != Trigger.oldMap.get(usr.Id).TimeZoneSidKey))){
                    newUserList.add(usr);
                }
            }
            if(!newUserList.isEmpty()){
                UserTriggerHandler.getUserList(newUserList,Trigger.oldMap);
            }
        }
    }
}