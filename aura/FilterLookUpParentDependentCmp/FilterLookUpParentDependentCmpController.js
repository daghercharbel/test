({
    doInit: function(c, e, h){
        //console.log('Do Init Ran');
        //console.log('selItem Value:: '+c.get("v.selItem"));
        if($A.util.isEmpty(c.get('v.selItem'))){
            //console.log('If Ran in Do Init');
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
         //console.log('firstServerCall');
        helper.serverCall(component, event, helper);
    },
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    firstServerCall : function(component, event, helper){
         //console.log('firstServerCall');
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
        //console.log('Event Value:: '+JSON.stringify(value));
        //console.log('CampaignName Value:: '+JSON.stringify(campaignName));
        //console.log('LookUpLabel Value:: '+c.get("v.lookUpLabel"));
        //console.log('ChildLookup Value:: '+c.get("v.childlookup"));
        c.set('v.newCampRecord',value);
        //console.log('newCampRecord Value:: '+c.get("v.newCampRecord"));
        if(c.get("v.lookUpLabel") == $A.get('$Label.c.Campaign_Text')){
            //console.log('if ran');
            c.set("v.selItem", campaignName);
            //console.log('selItem Value:: '+c.get("v.selItem"));
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