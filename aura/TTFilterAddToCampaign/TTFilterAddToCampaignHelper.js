({
    doInit_Helper : function(c, e, h){
        c.set('v.isShowSpinner', true);
        c.set("v.hideOptions", true);
        var action = c.get('c.fetchLimitedRecords');
        action.setParams({
            campaignRecordId : c.get('v.recordId')
        });
        action.setCallback(this,function(response){ 
            try{
                var result = response.getReturnValue();
                if(response.getState() === 'SUCCESS') {
                    if(!$A.util.isEmpty(result)) {
                        c.set('v.recordsList', JSON.parse(result));        
                    } else {
                        c.set('v.boolForNoRecord', true);
                        
                    }
                }else{
                    c.set('v.boolForNoRecord', true);
                }
                c.set('v.isShowSpinner', false);
            }catch(e){
            }
        });
        $A.enqueueAction(action);  
    },
    selectedUserList_Helper: function (c, e, h) {
        var userList = c.get("v.userList");
        for (var i = 0; i < userList.length; i++) {
            if (
                userList[i].ContactCLientId == null &&
                userList[i].LeadCLientId == null
            ) {
                if (userList.length > 1) {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        "Error",
                        "error",
                        "Some selected members does not exist."
                    );
                } else {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        "Error",
                        "error",
                        "Selected member does not exist."
                    );
                }
                return false;
            }
        }
    },
    showSuccess: function (c, e, h, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: " 2000",
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    },
    
    searchCampaign: function(c,e,h){
        if(!$A.util.isEmpty(c.get("v.searchString"))){
            var action = c.get('c.fetchRecords');
            action.setParams({
                objectName : 'Campaign',
                filterField : 'Name',
                searchString : c.get('v.searchString'),
                campaignRecordId : c.get('v.recordId')
            });
            action.setCallback(this,function(response){ 
                try{
                    c.set('v.isShowSpinner', false);
                    var result = response.getReturnValue();
                    if(response.getState() === 'SUCCESS') {
                        if(!$A.util.isEmpty(result) && JSON.parse(result) != '') {
                            c.set('v.recordsList', JSON.parse(result)); 
                            c.set("v.hideOptions", true);
                            c.set("v.boolForNoRecord", false);

                        } else {
                            c.set('v.hideOptions', false);
                            c.set('v.recordsList', []); 
                            c.set("v.boolForNoRecord", true);
                        }
                    }
                }catch(e){
                }
            });
            $A.enqueueAction(action);
        }
    }
})