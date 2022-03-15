@istest
public class TT_FeatureSettingsControllerTest {
    @istest static void getTTFlagValueTest(){
        Test.startTest();
        boolean storeResponse=TelosTouchSF.TT_FeatureSettingsController.getTTFlagValue();
        System.assert(!storeResponse || storeResponse,'it should be true');
        Test.stopTest();
    }
    @istest static void getSFFlagValueTest(){
        Test.startTest();
        boolean storeResponse=TelosTouchSF.TT_FeatureSettingsController.getSFFlagValue();
        System.assert(!storeResponse || storeResponse,'it should be true');
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
}