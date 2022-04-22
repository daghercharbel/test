({
    doInit_helper : function(c,e,h) {
        try{
            //console.log('doInit_helper');
            c.set("v.isShowSpinner",true);
            var action = c.get("c.sendCampaignTouchPoint");
            action.setParams({
                recordId:c.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        if(storedResponse.returnMessage == 'Campaign is not having the TelosTouch record type.'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Cam_Not_Have_TT_Record_Toast"));
                            return;
                        }else if(storedResponse.returnMessage == 'You have already sent a touchpoint for this campaign.'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.You_Already_Sent_TouchPoint_For_Cam_Toast"));
                            return;
                        }else if(storedResponse.returnMessage == 'Please add Campaign members'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            c.set("v.openfromCampaign",false);
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Please_Add_Cam_Mem_Toast"));
                        }else if(storedResponse.returnMessage == 'Please check all Campaign members synced or not.'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            c.set("v.openfromCampaign",false);
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Check_Cam_Mem_Sync_Toast"));
                        }else if(storedResponse.returnMessage == 'not synced contact'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            c.set("v.openfromCampaign",false);
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Check_Contact_Sync_Toast"));
                        }else if(storedResponse.returnMessage == 'not synced lead'){
                            //$A.get("e.force:closeQuickAction").fire();
                            c.find('overlayLib').notifyClose();
                            c.set("v.openfromCampaign",false);
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Check_Lead_Sync_Toast"));
                        }else if(!$A.util.isEmpty(storedResponse.clientIds) && storedResponse.clientIds != undefined){
                            var ids = '', firstBatchSize = 1;
                            var remainingIds = [];
                            //console.log('clientIds:: '+storedResponse.clientIds);
                            //console.log('clientIds length:: '+storedResponse.clientIds.length);
                            for(var i=0;i<storedResponse.clientIds.length;i++){
                                if(i < firstBatchSize){
                                    if($A.util.isEmpty(ids)){
                                        ids = storedResponse.clientIds[i];
                                    }else{
                                        ids = ids+','+storedResponse.clientIds[i];
                                    }
                                }else{
                                    remainingIds.push(storedResponse.clientIds[i]);
                                }
                            }
                            c.set('v.remainingIdsList', remainingIds);
                            var settingObj = c.get("v.settingAPIObj");
                            var authToken = c.get("v.authToken");
                            if(settingObj != null){
                                var iframeURL = '';
                                if(!$A.util.isEmpty(storedResponse.CampId) && storedResponse.CampId != undefined){
                                    c.set("v.campId",storedResponse.CampId);
                                    //iframeURL  = settingObj.Instance_URL+"/app-v2/#/contacts?page=contacts&send_touchpoint="+ids.trim()+"&auth_token="+authToken+"&sf_campaign_id="+storedResponse.CampId+"&fullscreen=true";
                                    if($A.get("$Locale.language") === 'en'){
                                        iframeURL  = settingObj.Instance_URL+"/app/v1/#/contacts?fullscreen=true&lang=en_US&send_touchpoint="+ids.trim()+"&access_token="+authToken+"&other_id="+storedResponse.CampId;
                                    }else if($A.get("$Locale.language") === 'fr'){
                                        iframeURL  = settingObj.Instance_URL+"/app/v1/#/contacts?fullscreen=true&lang=fr_FR&send_touchpoint="+ids.trim()+"&access_token="+authToken+"&other_id="+storedResponse.CampId;
                                    }
                                }
                                console.log('iframeURL::'+iframeURL);
                                c.set("v.iframeUrl",iframeURL);   
                            }   
                        }
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    } 
                }else{
                    h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                    h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Check_Lead_Sync_Toast"));
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            //console.log(ex);
        }
    },
    getAuthToken_helper : function(c,e,h) {
        try{
            var campaignid = c.get("v.campaignSFid");
            var TTClientIds = c.get("v.clientIdsList");
            c.set("v.isShowSpinner",true);
            var action = c.get("c.getSettingAPI");
            if(!$A.util.isEmpty(c.get("v.campaignSFid")) &&  c.get("v.campaignSFid") != undefined){
                action.setParams({
                    isCallingFrom : 'SendTouchPoint',
                    campId : campaignid
                });
            } 
            else{
                action.setParams({
                    isCallingFrom : 'SendTouchPoint',
                    campId : c.get("v.recordId")
                });
            }
            
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    //console.log('storedResponse');
                    //console.log(storedResponse);
                    if(storedResponse != null && !$A.util.isEmpty(storedResponse.authToken) && storedResponse.authToken != undefined && storedResponse.authToken != null){
                        c.set("v.authToken",storedResponse.authToken);
                        //console.log('v.authToken:: '+c.get('v.authToken'));
                    }
                    if(storedResponse != null &&  !$A.util.isEmpty(storedResponse.adminCredentials) && storedResponse.adminCredentials != undefined && storedResponse.adminCredentials != null){
                        c.set("v.settingAPIObj",storedResponse.adminCredentials);
                        if(!$A.util.isEmpty(c.get("v.campaignSFid")) &&  c.get("v.campaignSFid") != undefined  &&  !$A.util.isEmpty(c.get("v.clientIdsList")) &&  c.get("v.clientIdsList") != undefined ){
                            h.campaignnewHelper(c,e,h);
                        }else if(c.get("v.recordId") != undefined && !$A.util.isEmpty(c.get("v.recordId"))){
                            c.set("v.openfromCampaign",true);
                            h.doInit_helper(c,e,h);
                        }else{
                            //console.log('doInit_helper');
                            var iframeURL = storedResponse.Instance_URL+"/app-v2/#/contacts?page=contacts&send_touchpoint="+null+"&auth_token="+storedResponse.authToken+"&fullscreen=true";
                            c.set("v.iframeUrl",iframeURL); 
                        }
                        c.set("v.iframeUrl2",iframeURL); 
                    }else if(storedResponse == null || storedResponse == undefined){
                        //$A.get("e.force:closeQuickAction").fire();
                        c.find('overlayLib').notifyClose();
                        h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Current_User_No_Auth_Toast"));
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    } 
                }else{
                    h.showInfoToast(c,e,h,'Error!', 'error',$A.get("$Label.c.Something_Went_Wrong"));
                }
            });
            $A.enqueueAction(action);
            
        } catch (ex) {
            //console.log(ex);
        }
    },
    
    getTTCampaignId_helper : function(c,e,h) {
        try{
            c.set("v.isShowSpinner",true);
            var action = c.get("c.getTTCampaignId");
            if(c.get("v.campaignSFid") != undefined &&  c.get("v.campaignSFid") != null && c.get("v.campaignSFid") != ''){
                action.setParams({
                    campId : c.get("v.campaignSFid"),
                    remainingClientIds : JSON.stringify(c.get('v.remainingIdsList'))
                });
            } else{
                action.setParams({
                    campId : c.get("v.campId"),
                    remainingClientIds : JSON.stringify(c.get('v.remainingIdsList'))
                });
            }
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                $A.get("e.force:refreshView").fire();
                //$A.get("e.force:closeQuickAction").fire();
                c.find('overlayLib').notifyClose(); 
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(c.get("v.campaignSFid")) && c.get("v.campaignSFid") != undefined){
                        //window.open(window.location.origin + '/lightning/r/Campaign/'+c.get("v.campaignSFid")+'/view');
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": c.get("v.campaignSFid"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        c.find("overlayLib").notifyClose();
                        c.set("v.campId",'');
                        c.set("v.campaignSFid",'');
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //c.set('v.errorMessage',errors[0].message);
                        }
                    } 
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            //console.log(ex);
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
    campaignnewHelper : function (c, e, h) {
        //console.log('campaignnewHelper');
        var campaignid = c.get("v.campaignSFid");
        var TTClientIds = c.get("v.clientIdsList");
        var settingObj = c.get("v.settingAPIObj");
        var authToken = c.get("v.authToken");
        if(settingObj != null){
            var iframeURL  = settingObj.Instance_URL+"/app/v1/#/contacts?fullscreen=true&send_touchpoint="+TTClientIds+"&access_token="+authToken+"&other_id="+campaignid;
            //console.log('iframeURL::'+iframeURL);
            //console.log('TTClientIds::'+TTClientIds);
            c.set("v.iframeUrl",iframeURL);
            c.set("v.openfromCampaign",true);
        }   
    },
    addClientsToTouchpoint : function(c, e, h, campMemList){
        var action = c.get('c.addClientsToTouchpoint');
        action.setParams({
            'campMemListStr' : JSON.stringify(campMemList)
        });
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){
                    h.showInfoToast(c, e, h, $A.get("$Label.c.Success_Toast"), 'success', $A.get("$Label.c.Touchpoint_Sent_to_Camp_Mem_Text"));
                    //$A.get("e.force:closeQuickAction").fire();
                    c.find('overlayLib').notifyClose();
                }else{
                    h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                    //$A.get("e.force:closeQuickAction").fire();
                    c.find('overlayLib').notifyClose();
                }
            }else{
                h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                //$A.get("e.force:closeQuickAction").fire();
                c.find('overlayLib').notifyClose();
            }
        });
        $A.enqueueAction(action);
    }
})