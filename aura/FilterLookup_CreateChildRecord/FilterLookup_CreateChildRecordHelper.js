({
    doInit_Helper : function(c, e, h) {
        try {
            c.set('v.isShowSpinner', true);
            var action = c.get("c.getCampaignRecordType");
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
                        myEvent.fire();
                        c.find("overlayLib").notifyClose();
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
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    }
})