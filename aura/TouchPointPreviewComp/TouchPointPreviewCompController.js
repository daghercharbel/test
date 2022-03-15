({
    doInit : function(component, event, helper) {
        var action= component.get("c.getIFrameDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state ==>'+state);
            if (state === "SUCCESS") {
                //console.log("response::"+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue()!=null){
                    //console.log("enter");
                    var iframeURL='';
                    if($A.get("$Locale.language") === 'en'){
                        //console.log('again');
                        iframeURL  = response.getReturnValue().instanceURL+"/app/v1/#/template/preview?fullscreen=true&language=en&access_token="+response.getReturnValue().accessToken;
                    }else if($A.get("$Locale.language") === 'fr'){
                        iframeURL  = response.getReturnValue().instanceURL+"/app/v1/#/template/preview?fullscreen=true&language=fr&access_token="+response.getReturnValue().accessToken;
                    }
                    //console.log("final output is::"+iframeURL);
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
                //console.log(response.getReturnValue());
                if(response.getReturnValue() != null){
                    var returnVal = JSON.parse(response.getReturnValue());
                    window.open(returnVal.url+'/lightning/o/Campaign/list?filterName='+returnVal.listId, '_self')
                }
            }
        });
        $A.enqueueAction(action);
    }
})