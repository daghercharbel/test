({
    doInit_helper: function (c, e, h) {
        try{
            //console.log($A.get("$Locale.language"));
            c.set("v.isShowSpinner",true);
            var action = c.get("c.getSettingAPI");
            action.setParams({
                isCallingFrom : 'TTDeshboard'
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(storedResponse != null && !$A.util.isEmpty(storedResponse) && !$A.util.isEmpty(storedResponse.adminCredentials.Instance_URL) && storedResponse.authToken != undefined && storedResponse.authToken != null && !$A.util.isEmpty(storedResponse.authToken)){
                        //var iframURL = storedResponse.adminCredentials.Instance_URL+"/app-v2/#/dashboard?page=dashboard&auth_token="+storedResponse.authToken+"&fullscreen=true";
                        var iframURL;
                        if($A.get("$Locale.language") === 'en'){
                            iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/dashboard?fullscreen=true&lang=en_US&access_token="+storedResponse.authToken;
                        }else if($A.get("$Locale.language") === 'fr'){
                            iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/dashboard?fullscreen=true&lang=fr_FR&access_token="+storedResponse.authToken;
                        }
                        //console.log('iframeUrl:: '+iframURL);
                        c.set("v.IframeUrl", iframURL);
                    }else{
                        c.set("v.isNotAuthenticate",true);   
                    }
                }else if (state === 'ERROR'){
                    c.set("v.isNotAuthenticate",true);   
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                         //console.log("Error message: " +errors[0].message);            
                        }
                    } 
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            //console.log(ex);
        }
    },
})