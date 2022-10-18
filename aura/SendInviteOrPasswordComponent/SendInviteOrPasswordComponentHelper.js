({
    doInit_helper: function (c, e, h) {
        try{
            c.set("v.isShowSpinner",true);
            var action = c.get("c.checkClientInvite");
            
            action.setParams({
                recordId : c.get("v.recordId"),
                objectName : c.get("v.sObjectName"),
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.clientInviteWrapper",storedResponse);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    massSendInviteToClients: function (c, e, h) {
        var recordIdsList = c.get('v.selectedRecordIds');
        var lengthofIds =  recordIdsList.length; 
        if(lengthofIds !=2){
            var action = c.get("c.massInvitationToClients");
            action.setParams({
                'recordIdsList': recordIdsList,
                'objectName' : c.get('v.objectName')
            });
            action.setCallback(this, function(response) {
                c.set("v.isShowSpinner", false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storedResponse = response.getReturnValue();
                    if(storedResponse != undefined && storedResponse == 'sent'){
                        h.showToast_Helper(c,'success',$A.get("$Label.c.Client_Invited_Success_Toast"));
                        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/'+c.get('v.objectName')+'/home', '_self');
                            }), 400); 
                    }else if (storedResponse != undefined && storedResponse == 'Please select valid records for invite.'){
                        h.showToast_Helper(c,'error',$A.get("$Label.c.Selece_Valid_Record_Invite_Toast"));
                        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/'+c.get('v.objectName')+'/home', '_self');
                            }), 400); 
                    }else if (storedResponse != undefined && storedResponse == 'Person Account Not Enabled'){
                        h.showToast_Helper(c,'error',$A.get("$Label.c.Person_Acc_Not_Enable_Toast"));
                        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/'+c.get('v.objectName')+'/home', '_self');
                            }), 400); 
                    }else{
                        h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/'+c.get('v.objectName')+'/home', '_self');
                            }), 400); 
                    }
                } 
            });
            $A.enqueueAction(action);
        }else{ 
            c.set("v.isShowSpinner", false);
            h.showToast_Helper(c,'error',$A.get("$Label.c.Please_Select_Record_Toast"));
            window.open(window.location.origin+'/lightning/o/Contact/home', '_self');
        }
    },
    sendInvitation_helper: function (c, e, h,recordObject,event ) {
        try{
            c.set("v.isShowSpinner",true);
            var action = c.get("c.sendUserInvitation");
            action.setParams({
                recordObject : JSON.stringify(recordObject),
                action : event 
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                $A.get('e.force:refreshView').fire();
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.clientInviteWrapper",storedResponse);
                        if(storedResponse.isInvite == true && (event == 'invite') ){ 
                             h.showInfoToast(c,e,h,$A.get("$Label.c.Success_Toast"),'success',$A.get("$Label.c.Client_Invited_Toast"));
                        }else if(storedResponse.reSendPassword == true && (event == 'invite') ){
                             h.showInfoToast(c,e,h,'Error','error',$A.get("$Label.c.Client_Already_Accept_Invite_Toast"));
                        }else if(storedResponse.reSendPassword == true && (event == 'reSendPassword') ){
                             h.showInfoToast(c,e,h,$A.get("$Label.c.Success_Toast"),'success',$A.get("$Label.c.Login_Credential_Toast"));
                        }else{
                            h.showInfoToast(c,e,h,'Error','error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    },
    showInfoToast: function (c, e, h, title,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    },
})