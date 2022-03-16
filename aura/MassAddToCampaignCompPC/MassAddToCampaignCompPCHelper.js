({
    doInit_helper : function(c,e,h) {
        try {
             //c.set('v.isShowSpinner', true);
            var action = c.get("c.checkPersonAccountOrNot");
            action.setParams({
                recordIdsList : c.get("v.selectedRecordIds"),
                objectName : 'Account'
            });
            action.setCallback(this, function (response) {
                 c.set('v.isShowSpinner', false);
                var state = response.getState();
                //console.log('State:: '+state);
                if (state === "SUCCESS") {
                     //console.log('response:'+response.getReturnValue());
                   if(response.getReturnValue() != null && response.getReturnValue() != undefined){
                        if(response.getReturnValue() == 'Some Account is not PersonAccount'){
                            c.set('v.isNewOrExistCampaign', false);
                            h.showToast_Helper(c,'error','Please unselect those acccount which is not synced.');  
                            window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                            }), 2000); 
                        }else if (response.getReturnValue() == 'have PersonAccount'){
                            c.set("v.isNewOrExistCampaign", true); 
                        }
                    }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                        }
                    } 
                    h.showToast_Helper(c,'error','Something went wrong.');  
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                        }), 2000); 
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
        }
    },
    SaveContactIntoCampaign_Helper : function(c, e, h,result) {
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.addCamapignMember");
            action.setParams({
                camp :  result,
                recordIdsList :  c.get("v.selectedRecordIds"),
            });
            action.setCallback(this, function (response) {
                c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    //console.log(response.getReturnValue());
                    if(response.getReturnValue() != null && response.getReturnValue().length >0){
                        if(response.getReturnValue().includes('Already a campaign member') ){
                            h.showToast_Helper(c,'error','Selected Clients are Already Campaign Members'); 
                            //location.reload();
                        }else if(response.getReturnValue().includes('Campaign already sync')){
                            h.showToast_Helper(c,'error','Selected Campaign is Already Synced');
                        }else{
                                c.set("v.customErrorMessage",'');
                                c.set("v.isNewOrExistCampaign",false);
                                c.set("v.isExistCampaign",true);
                                h.showToast_Helper(c,'success','Campaign Member Added Successfully.');
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        window.open(window.location.origin+'/lightning/r/Campaign/'+response.getReturnValue()+'/view', '_self');
                                    }), 2000); 
                            }
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'errors',errors[0].message);
                        }
                    } 
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
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
                    //console.log('response.getReturnValue():'+response.getReturnValue());
                    if(response.getReturnValue() != null && response.getReturnValue().includes('isNotPersonAccount')){
                        c.set("v.customErrorMessage",'You have not permission to open it.');
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('Campaign already sync so you can not add campaign members.')){
                        c.set("v.customErrorMessage",'New members cannot be added to this campaign because a TouchPoint has already been sent.');
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('Already a campaign member')){
                        c.set("v.customErrorMessage",'This contact is already part of the campaign you selected.');
                    }else if(response.getReturnValue() != null && response.getReturnValue().includes('ERROR')){
                        h.showToast_Helper(c,'error','Somthing went wrong please contact to admin.');   
                    }else{
                        h.showToast_Helper(c,'success','Campaign member added in Campaign successfully.');    
                        window.open(window.location.origin+'/lightning/r/Campaign/'+response.getReturnValue()+'/view', '_self');
                    }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',errors[0].message); 
                        }
                    } 
                    h.showToast_Helper(c,'error','Something went wrong.');  
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    }
})