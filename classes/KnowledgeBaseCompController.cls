/**
* @File Name     : KnowledgeBaseCompController.cls
* @author        : CD
* @date          : 26/07/2022
* @description   : Apex Controller for the aura component : <KnowledgeBaseComp>
* Test Class     : KnowledgeBaseCompControllerTest.cls
*/

public without sharing class KnowledgeBaseCompController {
    // Get all the custom fields values from the custom metada : <TelosTouchSF__Knowledge_base_image__mdt>
    // and return a map having the the field api names as KEY as and the URL images as VALUES
         /**
* @author Cloud Analogy
* @date 02/08/2021
*@description GetImagesLinksKnowledgebase .....
@return string ...
     */
    @AuraEnabled
    public static String GetImagesLinksKnowledgebase(){
        try{
            Map<String,String> imgMap = new Map<String,String>();
            TelosTouchSF__Knowledge_base_image__mdt[] TTKbis = [SELECT QualifiedApiName, TelosTouchSF__Image_Url__c FROM TelosTouchSF__Knowledge_base_image__mdt WITH SECURITY_ENFORCED order by QualifiedApiName];

            for (TelosTouchSF__Knowledge_base_image__mdt TTKbi : TTKbis) { 
                imgMap.put(TTKbi.QualifiedApiName,TTKbi.TelosTouchSF__Image_Url__c);
            }
            return JSON.serialize(imgMap);
            
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR,'Exception :::::::'+ex.getMessage()+'at Line Number:::::: '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}