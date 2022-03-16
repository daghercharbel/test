({
    doInit : function(c, e, h) {
        var action = c.get("c.getInviteFlag");
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue() == true){
                    c.set('v.isComponentDisabled', false);
                    if(c.get("v.selectedRecordIds") != ''){
                        h.massSendInviteToClients(c,e,h);
                    }else{
                        h.doInit_helper(c,e,h);
                    }
                }else{
                    c.set('v.isComponentDisabled', true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    sendInvitation : function(c, e, h) {
        c.set("v.isModalOpen",true);
    },
    reSendPassword : function(c, e, h) {
        var recordObject = c.get("v.clientInviteWrapper");
        if(recordObject.clientId != undefined && recordObject.clientId != ''){
            h.sendInvitation_helper(c,e,h,recordObject,'reSendPassword');
        }else{
            h.showInfoToast(c,e,h,'Error','error',$A.get("$Label.c.Client_Not_Have_UserID_Toast"));
        }
    },
    handleConfirm : function(c, e, h) {
        var recordObject = c.get("v.clientInviteWrapper");
        if(recordObject.clientId != undefined && recordObject.clientId != ''){
            h.sendInvitation_helper(c,e,h,recordObject,'invite');
            c.set("v.isModalOpen",false);
        }
    },
    handleClose : function(c, e, h) {
        c.set("v.isModalOpen",false);
    },
})