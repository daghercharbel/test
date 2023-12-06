@isTest
public with sharing class TTBrandingControllerTest {
  @isTest
  static void createAttachmentTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    map<String,String> returnMap1 = TTBrandingController.createAttachment('{body}');
    map<String,String> returnMap2 = TTBrandingController.createAttachment(null);
    Test.stopTest();
      System.assert(returnMap1 != null, 'returnMap1 should not be null');
      System.assert(returnMap2 != null, 'returnMap2 should not be null');
  }

  @isTest
  static void getSignatureTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    map<String,String> returnMap1 = TTBrandingController.getSignature();
    Test.stopTest();
      System.assert(returnMap1 != null, 'returnMap1 should not be null');
  }

  @isTest
  static void putSignatureTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    map<String,String> returnMap1 = TTBrandingController.putSignature('{body}');
    map<String,String> returnMap2 = TTBrandingController.putSignature(null);
    Test.stopTest();
      System.assert(returnMap1 != null, 'returnMap1 should not be null');
      System.assert(returnMap2 != null, 'returnMap2 should not be null');
  }
}