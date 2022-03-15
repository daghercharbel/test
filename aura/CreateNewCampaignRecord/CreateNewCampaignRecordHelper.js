({
    doInit_Helper : function(c, e, h) {
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.getCampaignRecordType");
            //console.log('getCampaignRecordType');
            action.setCallback(this, function (response) {
                c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null && response.getReturnValue().length >0){
                        var result = response.getReturnValue();
                        var recordTypeList =[];
                        for(let i=0;i<result.length;i++){
                            var obj ={};
                            obj.label = result[i].Name;
                            obj.value = result[i].Name;
                            recordTypeList.push(obj);
                            if(result[i].Name.includes('TelosTouch')){
                                c.set("v.recordTypeValue",result[i].Name);
                            }
                        }
                        c.set("v.recordTypeDataList", recordTypeList);
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'errors',errors[0].message);
                        }
                    } 
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
        }
        
    },
    createNewCampaign_Helper : function(c, e, h){
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.createNewCampaignApex");
            action.setParams({
                campName :  c.get("v.campName"),
                campRecordTypeName :  c.get("v.recordTypeValue"),
            });
            action.setCallback(this, function (response) {
                c.set('v.isShowSpinner', false);
                var state = response.getState();
                //console.log('state::'+state);
                //console.log(response.getReturnValue() );
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null){
                        var result = response.getReturnValue();
                        var name = {};  
                        name.text = result.Name;
                        name.Id = result.Id;
                        name.objName = 'Campaign';
                        var myEvent = $A.get("e.c:CampaignDetailEvent");
                        myEvent.setParams({"newCampRecord": result,
                                           "campaignName":name});
                        //console.log('myEvent'+typeof myEvent);
                        //console.log('myEvent'+ myEvent);
                        myEvent.fire();
                        c.set("v.isNewCampaigScreen",false);
                        c.set("v.isRecordTypeScreen",false);
                        c.set("v.childlookup",false);
                        /*$A.createComponent('c:MassAddToCampaignCompPC', {
                            "selectedRecordIds": c.get("v.selectedRecordIds"),
                            "isPersonAccount" : c.get("v.isPersonAccount"),
                            "fromChildlookup" : true,
                            "campaignObj" : name                            
                        }, function attachModal(modalCmp, status) {
                            if (c.isValid() && status === 'SUCCESS') {
                                var body = c.get("v.body");
                                body.push(modalCmp);
                                c.set("v.body", body);    
                            }
                        });*/
                         /*c.set("v.childlookup",false);
                        console.log('childlookups'+c.get("v.childlookup"));
                        h.SaveContactIntoCampaign_Helper(c,e,h,result)
                         //h.showToast_Helper(c,'success','Campaign Added Successfully.');  
                            window.setTimeout(
                            $A.getCallback(function() {
                               // window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                            }), 400); */
                        //myEvent.fire();
                        //c.find("overlayLib1").notifyClose();
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'errors',errors[0].message);
                        }
                    } 
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
        }
    },
    SaveContactIntoCampaign_Helper : function(c, e, h,result) {
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.addCamapignMember");
            action.setParams({
                camp :  result,
                recordIdsList :  c.get("v.selectedRecordIds"),
            });
            action.setCallback(this, function (response) {
                c.set('v.isShowSpinner', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null && response.getReturnValue().length >0){
                        h.showToast_Helper(c,'success','Campaign Member Added Successfully.'); 
                        window.setTimeout(
                            $A.getCallback(function() {
                               window.open(window.location.origin+'/lightning/r/Campaign/'+response.getReturnValue()+'/view', '_self');
                            }), 2000); 
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'errors',errors[0].message);
                        }
                    } 
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log('Message ' + exp.message);
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    }
})