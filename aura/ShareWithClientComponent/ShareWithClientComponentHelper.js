({
	doInit_Helper : function(c,e,h) {
        try{
            var action = c.get("c.shareWithClients");
            action.setParams({
                recordId:c.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                $A.get("e.force:closeQuickAction").fire();
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse == 'success'){
                        h.showInfoToast(c,e,h,'Success!', 'success',$A.get("$Label.c.Task_Update_Success_Toast"));
                    }else{
                        h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
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