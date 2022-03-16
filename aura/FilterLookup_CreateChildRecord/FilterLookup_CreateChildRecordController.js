({
    doInit: function(component, event, helper) {
        helper.doInit_Helper(component, event, helper);
    },
    
    closeModal : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
        var myEvent = $A.get("e.c:ChildModalCloseEvent");
        myEvent.setParams({"eventAction": 'ModalClosed'});
        myEvent.fire();
    },
    newCampaignPage: function (c, e, h) {
        if(c.get("v.isRecordTypeScreen")){
            c.set("v.isRecordTypeScreen",false);
            c.set("v.isNewCampaigScreen",true);
        }
    },
    createNewCampaign : function(c, e, h){
        try{  
            var campName = c.get('v.campName');
            if(!$A.util.isEmpty(campName)){
                campName = campName.trim();
            }
            c.set("v.campName",campName);
            var allValid = c.find('fieldId').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            if (allValid) {
                h.createNewCampaign_Helper(c, e, h);
            } else {
                h.showInfoToast(c, e, h, 'Error', $A.get("$Label.c.Fill_Required_Value_Toast"), 'info_alt', 'error', 'dismissible');
            } 
        }catch(ex){
            //console.log('error is-->'+ex);
        }
    },
})