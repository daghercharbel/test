({
  doInit: function (c, e, h) {
    const empApi = c.find("empApi");
    empApi
      .subscribe(
        "/event/TelosTouchSF__Insight_Creation_Event__e",
        "-1",
        $A.getCallback((eventReceived) => {
          if (
            c.get("v.recordId") ==
            eventReceived.data.payload.TelosTouchSF__Campaign__c
          ) {
            h.doInitHelper(c, e, h);
            h.labelSelection(c);
          }
        })
      )
      .then((subscription) => {
      });
    h.doInitHelper(c, e, h);
    h.labelSelection(c);
  },
  
  handleModalCloseEvent: function (c, e, h) {
    if (e.getParam("SendTouchpoint") == true) {
      h.sendTouchpointHelper(c, e, h);
    }
  },
  doRefresh: function (c, e, h) {
    h.doInitHelper(c, e, h);
    var myEvent = $A.get("e.c:RefreshCampaignEvent");
    myEvent.setParams({ doRefresh: true });
    myEvent.fire();
  },
  openChooseTouchPointModal: function (c, e, h) {
    try {
      c.set("v.disableValue", true);
      $A.createComponent(
        "c:templateGalleryComp",
        { 
          onclosemodalevent: c.getReference("c.handleModalClose"),
          isOpenTouchPoints: true, 
          campSfId: c.get("v.recordId"),
          campaignType: c.get("v.campaignType")
        },
        function (content, status) {
          if (status === "SUCCESS") {
            var modalPromise = c.find("overlayLib").showCustomModal({
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_large touchpoint-modal",
              closeCallback: function () {
                h.doInitHelper(c, e, h);
              }
            });
            c.set("v.modalPromise", modalPromise);
          }
        }
      );
    } catch (error) {
    }
  },

  openSendTest: function (c, e, h){
    try {
      $A.createComponent(
        "c:ttSendTestCampaign",
        { 
          onclosemodalevent: c.getReference("c.handleModalClose"),
          campaignId: c.get("v.recordId"),
        },
        function (content, status) {
          if (status === "SUCCESS") {
            var modalPromise = c.find("overlayLib").showCustomModal({
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_small touchpoint-modal"
            });
            c.set("v.modalPromise", modalPromise);
          }
        }
      );
    } catch (error) {
    }
  },

  handleModalClose: function (c, e, h){
    var modalPromise = c.get('v.modalPromise');
    modalPromise.then(
      function (modal) {
          modal.close();
      }
    );
  },

  skipClicked: function (c, e, h) {
    if (e.getParam("skipClicked") === true) {
      h.doInitHelper(c, e, h);
    }
  },
  previewSelectedTouchPoint: function (c, e, h) {
    try {
      $A.createComponent(
        "c:showTouchPointPreview",
        { recordId: c.get("v.recordId") },
        function (content, status) {
          if (status === "SUCCESS") {
            c.find("overlayLib").showCustomModal({
              header: $A.get("$Label.c.TouchPoint_Preview_Text"),
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_large preview-modal",
              closeCallback: function () {}
            });
          }
        }
      );
    } catch (error) {
    }
  },

  createTouchPointinTT: function (c, e, h) {
    c.set("v.sendDisabled", true);
    // call backend for syncing the CM
    h.checkAllCM(c,e,h);
  },
  handleCustomizeClick: function (c, e, h) {
    try {
      h.getUserAccessToken(c, e, h);
    } catch (error) {
    }
  }
});