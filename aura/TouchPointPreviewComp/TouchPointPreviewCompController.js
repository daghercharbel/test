({
    doInit : function(component, event, helper) {
        var action= component.get("c.getIFrameDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()!=null){
                    var iframeURL='';
                    if($A.get("$Locale.language") === 'en'){
                        iframeURL  = response.getReturnValue().instanceURL+"/app/v1/#/template/preview?fullscreen=true&language=en&access_token="+response.getReturnValue().accessToken;
                    }else if($A.get("$Locale.language") === 'fr'){
                        iframeURL  = response.getReturnValue().instanceURL+"/app/v1/#/template/preview?fullscreen=true&language=fr&access_token="+response.getReturnValue().accessToken;
                    }
                    component.set('v.iFrameUrl', iframeURL);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    handleClick: function(component, event, helper) {
        var action = component.get("c.getListId");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null){
                    var returnVal = JSON.parse(response.getReturnValue());
                    window.open(returnVal.url+'/lightning/o/Campaign/list?filterName='+returnVal.listId, '_self')
                }
            }
        });
        $A.enqueueAction(action);
    }
})