({
  scriptsLoaded: function (c, e, h) {
    const empApi = c.find("empApi");
    empApi
      .subscribe(
        "/event/TelosTouchSF__Insight_Creation_Event__e",
        "-1",
        $A.getCallback((eventReceived) => {
          // Process event (this is called each time we receive an event)
          //console.log('Graph Event:: '+JSON.stringify(eventReceived));
          if (
            c.get("v.recordId") ==
            eventReceived.data.payload.TelosTouchSF__Campaign__c
          ) {
            h.doinit_Helper(c, e, h);
          }
        })
      )
      .then((subscription) => {
        // Subscription response received.
        // We haven't received an event yet.
        //console.log('Subscription request sent to: ', subscription.channel);
        // Save subscription to unsubscribe later
      });
    h.doinit_Helper(c, e, h);
  },
  doRefresh: function (c, e, h) {
    if (e.getParam("doRefresh") === true) {
      h.doinit_Helper(c, e, h);
    }
  }
});