({
    CloseModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    SaveCreateAction :function(c, e, h){
        var myEvent = $A.get("e.c:TT_AddToCampMobile_Evt");
        myEvent.setParams({"isCreateTask" : true});
        myEvent.setParams({"isCampaign" : false });
        myEvent.fire();
    },
    SaveCreateMassAction :function(c, e, h){
        var myEvent = $A.get("e.c:TT_AddToCampMobile_Evt");
        myEvent.setParams({"isCreateTask" : false});
        myEvent.setParams({"isCreateMassTask" : true});
        myEvent.setParams({"isCampaign" : false });
        myEvent.fire();
    }
})