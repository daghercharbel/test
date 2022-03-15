({
    doInit  : function(c, e, h) {
        var action = c.get('c.getCampaignDetails');
        action.setParams({
            'campSfId' : c.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                var responseObj = JSON.parse(response.getReturnValue());
                if(!responseObj.synced){
                    h.getAuthToken_helper(c,e,h);
                }else if(responseObj.synced && responseObj.actionRequired){
                    if(responseObj.accessTokenPresent){
                        h.addClientsToTouchpoint(c,e,h,responseObj.campMemList);
                    }else{
                        h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else if(responseObj.synced && !responseObj.actionRequired){
                    h.getAuthToken_helper(c,e,h);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleClose : function(c, e, h) {
        if((!$A.util.isEmpty(c.get("v.campId")) && c.get("v.campId") != undefined) || (!$A.util.isEmpty(c.get("v.campaignSFid")) && c.get("v.campaignSFid") != undefined)){
            h.getTTCampaignId_helper(c,e,h); 
        }else{
            //$A.get("e.force:closeQuickAction").fire(); 
            c.find('overlayLib').notifyClose();
        }
    },
    
})