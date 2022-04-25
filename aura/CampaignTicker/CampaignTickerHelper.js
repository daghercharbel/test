({
    doInitHelper : function(c, e, h) {
        var action = c.get('c.getCampaignDetails');
        action.setParams({
            'campSfId' : c.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                var responseObj = JSON.parse(response.getReturnValue());
                c.set('v.CampaignSynced', responseObj.synced);
                c.set('v.ActionRequired', responseObj.actionRequired);
                c.set('v.CampMemberPresent', responseObj.campMemberPresent);
                c.set('v.OpenTouchPointModal', responseObj.openTouchPointModal);
            }
            if(!responseObj.synced && !responseObj.actionRequired && !responseObj.campMemberPresent){
               c.set('v.disableValue',true);
            }else if(!responseObj.actionRequired && !responseObj.synced && responseObj.campMemberPresent){
               c.set('v.disableValue',false);
            }else if(!responseObj.actionRequired && responseObj.synced && responseObj.campMemberPresent){
               c.set('v.disableValue',true);
            }else if(responseObj.actionRequired && responseObj.synced && responseObj.campMemberPresent && responseObj.openTouchPointModal){
               c.set('v.disableValue',false);
            }else if(responseObj.actionRequired && responseObj.synced && responseObj.campMemberPresent && !responseObj.openTouchPointModal){
                //console.log('processing');
               c.set('v.disableValue',true);
            }
        });
        $A.enqueueAction(action);
    },
    openSendTouchpointModal : function(c, e, h){
        var action = c.get('c.getCampaignDetails');
        action.setParams({
            'campSfId' : c.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                var responseObj = JSON.parse(response.getReturnValue());
                if(responseObj.synced && responseObj.openTouchPointModal){
                    $A.createComponent("c:ModalBodyComponent", {sendTouchpoint : true},
                        function(content, status) {
                            if (status === "SUCCESS") {
                                c.find('overlayLib').showCustomModal({
                                    header: $A.get("$Label.c.Send_Touchpoint_Text"),
                                    body: content,
                                    showCloseButton: true,
                                    cssClass: "padding-initial"
                                })
                            }
                        });
                }
            }
        });
        $A.enqueueAction(action);
    },
    sendTouchpointHelper : function(c, e, h){
        var action = c.get('c.getCampaignDetails');
        action.setParams({
            'campSfId' : c.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                var responseObj = JSON.parse(response.getReturnValue());
                if(responseObj.synced && responseObj.actionRequired){
                    if(responseObj.accessTokenPresent){
                        h.addClientsToTouchpoint(c,e,h,responseObj.campMemList);
                    }else{
                        h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    addClientsToTouchpoint : function(c, e, h, campMemList){
        var action = c.get('c.addClientsToTouchpoint');
        action.setParams({
            'campMemListStr' : JSON.stringify(campMemList)
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){
                    h.showInfoToast(c, e, h, "Success", 'success', 'Touchpoint Sent to New Campaign Members');
                }else{
                    h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                }
            }else{
                h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
            }
        });
        $A.enqueueAction(action);
    },
    showInfoToast: function (c, e, h, title,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    }
})