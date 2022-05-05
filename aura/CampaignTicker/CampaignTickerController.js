({
    doInit: function (c, e, h) {
        const empApi = c.find("empApi");
        empApi
        .subscribe(
            "/event/TelosTouchSF__Insight_Creation_Event__e",
            "-1",
            $A.getCallback((eventReceived) => {
                // Process event (this is called each time we receive an event)\
                console.log('Campaign Ticker Event:: '+JSON.stringify(eventReceived));
                if (
                c.get("v.recordId") ==
                eventReceived.data.payload.TelosTouchSF__Campaign__c
                ) {
                h.doInitHelper(c, e, h);
                //h.openSendTouchpointModal(c, e, h);
            }
                           })
        )
        .then((subscription) => {
            // Subscription response received.
            // We haven't received an event yet.
            console.log('Ticker Subscription request sent to: ', subscription.channel);
            // Save subscription to unsubscribe later
        });
        h.doInitHelper(c, e, h);
    },
    handleModalCloseEvent: function (c, e, h) {
        //console.log(e.getParam("SendTouchpoint"));
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
        //console.log("open modal on click is called");
        c.set('v.disableValue', true);
        $A.createComponent(
            "c:SendTouchPointComponent",
            { recordId: c.get("v.recordId") },
            function (content, status) {
                if (status === "SUCCESS") {
                    c.find("overlayLib").showCustomModal({
                        body: content,
                        showCloseButton: false,
                        cssClass: "slds-modal_large touchpoint-modal",
                        closeCallback: function() {
                            h.doInitHelper(c, e, h);
                        }
                    });
                }
            }
        );
    },
    skipClicked: function (c, e, h) {
        if (e.getParam("skipClicked") === true) {
            h.doInitHelper(c, e, h);
        }
    }
});