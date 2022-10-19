({
    doInit: function(c, e, h){
        if($A.util.isEmpty(c.get('v.selItem'))){
            window.setTimeout(
                $A.getCallback(function () {
                    c.find("inputBox").focus();
                }), 10
            );
        }
    },
    itemSelected : function(component, event, helper) {
        helper.itemSelected(component, event, helper);
    },
    serverCall :  function(component, event, helper) {
        helper.serverCall(component, event, helper);
    },
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    firstServerCall : function(component, event, helper){
        helper.firstServerCall(component, event, helper);
    },
    createNewRecord :function(component, event, helper){
        component.set("v.selItem", null);
        component.set("v.server_result", null);
        component.set("v.searchText", '');
        component.set("v.childlookup",true);
        var cmp = component.find('addborder');
        helper.createNewRecord_Helper(component, event, helper);
    },
    handleCampaignDetailEvent :function(c, e, h){
        c.set("v.childlookup",false);
        var value = e.getParam("newCampRecord");
        var campaignName = e.getParam("campaignName");
        c.set('v.newCampRecord',value);
        if(c.get("v.lookUpLabel") == $A.get('$Label.c.Campaign_Text')){
            c.set("v.selItem", campaignName);
        }
    },
    handleChildModalClose: function(c, e, h){
        var eventAction = e.getParam("eventAction");
        if(eventAction === 'ModalClosed'){
            c.set("v.childlookup",false);
            c.set("v.server_result", null);
            c.set("v.searchText", '');
            var action = c.get('c.doInit');
            $A.enqueueAction(action);
        }
    },
    clearList :function(component, event, helper) {
        component.set("v.server_result", null);
    }
})