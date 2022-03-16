({
    SendTouchPoint_helper : function(c, e, h){
        try{
            c.set('v.isShowSpinner', true);
            var action = c.get("c.campaignInsertandSendTouchPoint");
            action.setParams({
                campaignName : c.get("v.campaignName"),
                userList : JSON.stringify(c.get("v.userList"))
            });
            action.setCallback(this,function (response) {
                var state = response.getState();
                var rtnValue = response.getReturnValue();
                if(!$A.util.isEmpty(rtnValue) && rtnValue != null && state == 'SUCCESS'){
                    c.set('v.campaignName', '');
                    window.setTimeout(
                        $A.getCallback(function() {
                            c.set('v.isShowSpinner', false);
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": rtnValue.campaignId,
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }), 1000);
                }else{
                    c.set('v.isShowSpinner', false);
                    h.showSuccess(c,e,h,'Error','error',$A.get("$Label.c.Add_To_Campaign_Error_Text"));
                }
            });
            $A.enqueueAction(action);
        }catch(ex){
            //console.log('Exception::'+ex);
        }
    },
    showSuccess : function(component, event, helper, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 2000',
            key: 'info_alt',
            type: type
        });
        toastEvent.fire();
    },

    SaveCreateAction_Helper : function(c,e,h,userList) {
        try{
            let newTask = c.get("v.newTask");
            var tlist = [];
            if(!$A.util.isEmpty(userList)){
                for(var userObj in userList){
                    let modifiedTaskObj = {};
                    modifiedTaskObj.TelosTouchSF__Share_with_client_s__c = newTask.wrapperList.ShareWithClientlist;
                    modifiedTaskObj.Status = newTask.wrapperList.StatusPicklist;
                    modifiedTaskObj.Subject = newTask.Subject;
                    modifiedTaskObj.Description = newTask.Description;
                    modifiedTaskObj.ActivityDate = newTask.ActivityDate;
                    modifiedTaskObj.OwnerId = newTask.OwnerId;
                    modifiedTaskObj.WhoId = userList[userObj].ContactOrLeadSFId;
                    tlist.push(modifiedTaskObj);
                }
            }
            c.set('v.isShowSpinner', true);
            var action = c.get("c.saveNewTask");
            action.setParams({
                "tasklist" : tlist,
            });
            action.setCallback(this, function(response) {
                c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    c.set("v.newTask", {'sobjectType': 'Task'});
                    h.showSuccess(c,e,h,'Sucesss','success',$A.get("$Label.c.Task_Create_Success_Text"));
                    //h.showToast_Helper(c,'success',$A.get("$Label.c.Task_Create_Success_Text"));
                    //window.location.reload()
                    //c.set("v.createAction", false);
                    var result = response.getReturnValue();
                    c.find('overlayLib2').notifyClose();
                }
            });
            $A.enqueueAction(action);
        }
        catch(error){
            //console.log(error);
        }
    },
    SaveCreateAction : function(c, e, h) {
        var currentuserId = c.get("v.currentUser");
        var cmpTarget = c.find('subjectId');
        if($A.util.isEmpty(c.get("v.newTask.Subject"))) {
            $A.util.addClass(cmpTarget, 'slds-has-error');
            c.set("v.subjectMessage",$A.get("$Label.c.Complete_this_field_Label"));
            return;
        } else {
            c.set("v.subjectMessage",'');
            $A.util.removeClass(cmpTarget, 'slds-has-error');
        }
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var userList = c.get("v.userList");
        var newTask = c.get("v.newTask");
        if(!$A.util.isEmpty(c.get("v.currentUser"))){
            newTask.OwnerId = currentuserId.Id;
        }
        var allValid = c.find('validFields').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            if(!$A.util.isEmpty(newTask)){
                h.SaveCreateAction_Helper(c, e, h, userList);
            }
        }
        else{
            h.showToast_Helper(c,'error','Please complete all required fields.');
        }
    },
})