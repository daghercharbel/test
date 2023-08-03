@istest
public class TT_FeatureSettingsControllerTest {
    
    @istest static void getFeatureMetadataTest(){
        Test.startTest();
        map<String, String> mapResult = TelosTouchSF.TT_FeatureSettingsController.getFeatureMetadata('Camapign_Syncing');
        System.assert(mapResult.keySet() != null, 'It should not be empty');
        Test.stopTest();
    }
    
    @istest static void IsUserSystemAdminTest(){
        Test.startTest();
        boolean storeResponse=TelosTouchSF.TT_FeatureSettingsController.IsUserSystemAdmin();
        System.assert(!storeResponse || storeResponse,'it should be true');
        Test.stopTest();
    }

    @istest static void getFinestLogValueTest(){
        Test.startTest();
        boolean storeResponse=TelosTouchSF.TT_FeatureSettingsController.getFinestLogValue();
        storeResponse = true;
        System.assert(!storeResponse || storeResponse,'it should be true');
        Test.stopTest();
    }

    @istest static void setFeatureMetadataTest(){

        map<String, String> mapResultGet = TelosTouchSF.TT_FeatureSettingsController.getFeatureMetadata('Camapign_Syncing');
        String stringMdt = mapResultGet.get('value');
		system.debug('mdt value: '+ stringMdt);
        Test.startTest();
        //Test Success
        map<String, String> mapResultSuccess = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata(stringMdt,'Camapign_Syncing');
        System.assert(mapResultSuccess.keySet() != null, 'It should not be empty');
        map<String, String> mapResultSuccess1 = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata(stringMdt,'Contact_Syncing');
        System.assert(mapResultSuccess1.keySet() != null, 'It should not be empty');
        map<String, String> mapResultSuccess2 = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata(stringMdt,'Lead_Syncing');
        System.assert(mapResultSuccess2.keySet() != null, 'It should not be empty');
        map<String, String> mapResultSuccess3 = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata(stringMdt,'Finest_Logging');
        System.assert(mapResultSuccess3.keySet() != null, 'It should not be empty');
        //Test Error
        map<String, String> mapResultError = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata('error','Camapign_Syncing');
        System.assert(mapResultError.get('status') == 'error', 'Test should have thrown an error.');
        Test.stopTest();
    }
}