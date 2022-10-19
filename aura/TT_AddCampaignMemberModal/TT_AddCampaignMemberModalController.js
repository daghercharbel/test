({
	openModal: function(component, event, helper) {
      try{
        var modalBody;
        var modalFooter;
        var records = component.get('v.recordId');
        $A.createComponents([
            ["c:TT_AddToCampaignMobile", {"recordId":records}],
            ["c:TT_AddToCampaignMobileFooter", {}]
        ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    modalFooter = content[1];
                    component.find('overlayLib').showCustomModal({
                        header: $A.get("$Label.c.Add_Campaign_Members_Text"),
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function() {
                        }
                    })
                }
            });
      }catch(e){
      }
   } 
})