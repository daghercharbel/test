({
	doInit_helper: function (c, e, h) {
        try{
            c.set("v.isShowSpinner",true);
            var action = c.get("c.getSettingAPI");
            action.setParams({
                 isCallingFrom : 'ManageTouchPoint'
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && !$A.util.isEmpty(storedResponse.adminCredentials.Instance_URL) && storedResponse.adminCredentials != undefined && storedResponse.authToken != null && !$A.util.isEmpty(storedResponse.authToken)){
                        if(c.get("v.Notifications")){
                            //var iframURL = storedResponse.settingApi.Instance_url__c+"/app-v2/#/account/notifications-settings?page=notifications-settings&auth_token="+storedResponse.authToken+"&fullscreen=true";
                            var iframURL;
                            if($A.get("$Locale.language") === 'en'){
                                iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/account/notifications-settings?fullscreen=true&lang=en_US&access_token="+storedResponse.authToken;
                            }else if($A.get("$Locale.language") === 'fr'){
                                iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/account/notifications-settings?fullscreen=true&lang=fr_FR&access_token="+storedResponse.authToken;
                            }
                            c.set("v.style",'height:90vh;width:100%');
                            c.set("v.IframeUrl",iframURL);  
                        }
                    }else{
                         c.set("v.isNotAuthenticate",true);   
                    }
                }
                else if (state === 'ERROR'){
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