({
    doInit_helper : function(c,e,h) {
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.getObjectDetails");
            action.setParams({
                objectName : c.get("v.sObjectName"),
                recordId : c.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                 c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null && response.getReturnValue() != undefined){
                        if(response.getReturnValue() == 'IsNotPersonAccount'){
                            h.showToast_Helper(c,'error',$A.get("$Label.c.No_Permit_To_Open_Toast"));
                            window.setTimeout(
                                $A.getCallback(function () {
                                    $A.get("e.force:closeQuickAction").fire();
                                }), 1000
                            );
                        }else{
                            c.set("v.objectRecordName", response.getReturnValue()); 
                        }
                    }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                        }
                    } 
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
        }
    },
    saveCampaign_helper : function(c,e,h) {
        try {
             c.set('v.isShowSpinner', true);
            var action = c.get("c.updateCampaignRecord");
            action.setParams({
                objectName : c.get("v.sObjectName"),
                recordId : c.get("v.recordId"),
                campId : c.get("v.campaignObj.Id"),
                campName : c.get("v.campaignObj.text")
            });
            action.setCallback(this, function (response) {
                 c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                   if(response.getReturnValue() != null && response.getReturnValue().includes('IsNotPersonAccount')){
                        c.set("v.customErrorMessage",'You have not permission to open it.');
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('Campaign already sync so you can not add campaign members.')){
                        c.set("v.customErrorMessage",$A.get("$Label.c.New_Member_Toast"));
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('Already a campaign member')){
                        c.set("v.customErrorMessage",$A.get("$Label.c.Contact_Already_Toast"));
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('ERROR')){
                        h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Wrong_Contact_Admin_Toast"));
                    }else{
                        h.showToast_Helper(c,'success',$A.get("$Label.c.Camp_Mem_Added_Toast"));
                        var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": response.getReturnValue(),
                              "slideDevName": "detail"
                            });
                            navEvt.fire();
                    }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',errors[0].message); 
                        }
                    } 
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    }
})