({
    doInit: function(component, event, helper) {
        helper.doInit_Helper(component, event, helper);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isRecordTypeScreen",false);
        component.set("v.isNewCampaigScreen",false);
        location.reload();
        // component.find("overlayLib").notifyClose();
    },
    newCampaignPage: function (c, e, h) {
        if(c.get("v.isRecordTypeScreen")){
            c.set("v.isRecordTypeScreen",false);
            c.set("v.isNewCampaigScreen",true);
        }
    },
    createNewCampaign : function(c, e, h){
        try{ 
            //console.log('createNewCampaign::');
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
                h.showInfoToast(c, e, h, 'Error', 'Please fill required value.', 'info_alt', 'error', 'dismissible'); 
            } 
        }catch(ex){
            //console.log('error is-->'+ex);
        }
    },
})