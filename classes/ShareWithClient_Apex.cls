/*
* @author Cloud Analogy
* @date 26/08/2021.
* @description ShareWithClient_Apex ....
*/
public with sharing class ShareWithClient_Apex {
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description....
*/
    public List<Task> contactList { get; set; }
    private ApexPages.StandardSetController standardController;
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description ...
*/
    public List<String> insertContactIdSet { get; set; }
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description ....
*/
    public String jsonStr { get; set; }
    /*
* @author Cloud Analogy
* @date 26/08/2021.
* @description constructor of the SessionIDController class ....
* @param standardController ......
*/
    public ShareWithClient_Apex(ApexPages.StandardSetController standardController){
        try{
            insertContactIdSet = new List<String>();
            this.standardController = standardController;
            contactList = new List<Task>(); 
            for (Task mem : (List<Task>)standardController.getSelected()){ 
                insertContactIdSet.add(mem.Id); 
            }
            jsonStr = JSON.serialize(insertContactIdSet);
        }
        catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, 'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
        } 
    }
}