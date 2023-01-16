/**
* @File Name     : KnowledgeBaseCompControllerTest.cls
* @author        : CD
* @date          : 27/07/2022
* @description   : Test Class for the apex class <KnowledgeBaseCompController>
*/

@isTest
public without sharing class KnowledgeBaseCompControllerTest {
    
    @isTest
    static void GetImagesLinksKnowledgebaseTest(){
        Test.startTest();
        String Teste = KnowledgeBaseCompController.GetImagesLinksKnowledgebase();
        Test.stopTest();
        System.assert(Teste !=null); 
        
    }
}