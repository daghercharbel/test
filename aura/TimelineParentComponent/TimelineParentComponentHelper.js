({
    doInit_helper:function(cmp,event, helper)
    {
        try{
             cmp.set('v.isShowSpinner', true);
            var action  = cmp.get("c.getTaskData");
            var recordId = cmp.get("v.recordId");
            action.setParams({
                recordId:recordId,
                objectName : cmp.get("v.sObjectName")
            });
            action.setCallback(this, function(response) {
                 cmp.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storedResponse = response.getReturnValue();
                    //console.log('storedResponse::'+JSON.stringify(storedResponse));
                    if(storedResponse != null){
                        cmp.set("v.timeLineWrapper",storedResponse)
                    }
                } else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " +errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch (error) {
           // console.error(error);
        }
    },
    
})