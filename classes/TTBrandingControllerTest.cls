@isTest
public with sharing class TTBrandingControllerTest {
  @isTest
  static void createAttachmentTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    TTBrandingController.createAttachment('{body}');
    TTBrandingController.createAttachment(null);
    Test.stopTest();
  }

  @isTest
  static void getSignatureTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    TTBrandingController.getSignature();
    Test.stopTest();
  }

  @isTest
  static void putSignatureTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TelosTouchSF.TelosTouchUtilityMock()
    );
    Test.startTest();
    TTBrandingController.putSignature('{body}');
    TTBrandingController.putSignature(null);
    Test.stopTest();
  }
}