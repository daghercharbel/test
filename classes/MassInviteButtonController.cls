/**
* @author Cloud Analogy
* @date 02/08/2021
* @description MassInviteButtonController class .
*/
public with sharing class MassInviteButtonController {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
    public List<Contact> contactList { get; set; }
    private ApexPages.StandardSetController standardController;
    /**
  * @author Cloud Analogy
  * @date 02/08/2021
* @description ....
  */
    public List<String> recordIdList { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
*/
    public String jsonStr { get; set; }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description controller of the MassInviteButtonController class
* @param standardController ......
*/
    public MassInviteButtonController(ApexPages.StandardSetController standardController){
        try{
            recordIdList = new List<String>();
            this.standardController = standardController;
            contactList = new List<Contact>(); 
            for (Object mem : (List<Object>)standardController.getSelected()){
                Map<String, Object> stringVsObjMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mem));
                recordIdList.add(String.valueOf(stringVsObjMap.get('Id'))); 
            }
            jsonStr = JSON.serialize(recordIdList);
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        } 
    }
}