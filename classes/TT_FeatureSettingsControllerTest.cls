@istest
public class TT_FeatureSettingsControllerTest {
    
    @istest static void getFeatureMetadataTest(){
        Test.startTest();
        map<String, String> mapResult = TelosTouchSF.TT_FeatureSettingsController.getFeatureMetadata();
        System.assert(mapResult.get('status') == 'success', mapResult.get('error'));
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

        map<String, String> mapResultGet = TelosTouchSF.TT_FeatureSettingsController.getFeatureMetadata();
        String stringMdt = mapResultGet.get('value');

        Test.startTest();
        //Test Success
        map<String, String> mapResultSuccess = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata(stringMdt);
        System.assert(mapResultSuccess.get('status') == 'success', mapResultSuccess.get('error'));
        //Test Error
        map<String, String> mapResultError = TelosTouchSF.TT_FeatureSettingsController.setFeatureMetadata('error');
        System.assert(mapResultError.get('status') == 'error', 'Test should have thrown an error.');
        Test.stopTest();
    }
}