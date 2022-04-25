({
    doinit : function (c, e, h) {
        var syncTypeOptions = [];
        var syncTypeObj1 = {};
        syncTypeObj1.label = $A.get("$Label.c.Soft_Sync_Text");
        syncTypeObj1.value = 'Soft';
        var syncTypeObj2 = {};
        syncTypeObj2.label = $A.get("$Label.c.Hard_Sync_Text");
        syncTypeObj2.value = 'Hard';
        syncTypeOptions.push(syncTypeObj1);
        syncTypeOptions.push(syncTypeObj2);
        c.set('v.syncTypeOptions', syncTypeOptions);
        var syncObjectOptions = [];
        var syncObjectOptionsObj1 = {};
        syncObjectOptionsObj1.label = $A.get("$Label.c.All_Label");
        syncObjectOptionsObj1.value = 'All';
        var syncObjectOptionsObj2 = {};
        syncObjectOptionsObj2.label = $A.get("$Label.c.Clients_Text");
        syncObjectOptionsObj2.value = 'Contact';
        var syncObjectOptionsObj3 = {};
        syncObjectOptionsObj3.label = $A.get("$Label.c.Tasks_Text");
        syncObjectOptionsObj3.value = 'Task';
        var syncObjectOptionsObj4 = {};
        syncObjectOptionsObj4.label = $A.get("$Label.c.Campaigns_Text");
        syncObjectOptionsObj4.value = 'Campaign';
        syncObjectOptions.push(syncObjectOptionsObj1);
        syncObjectOptions.push(syncObjectOptionsObj2);
        syncObjectOptions.push(syncObjectOptionsObj3);
        syncObjectOptions.push(syncObjectOptionsObj4);
        c.set('v.syncObjectOptions', syncObjectOptions);  
        var action = c.get("c.startRegistrationOnTT");
        action.setCallback(this, function(response) {
            c.set("v.isShowSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storedResponse = response.getReturnValue();
                if(storedResponse === 'Registration Successful'){
                    window.setTimeout(
                        $A.getCallback(function () {
                            c.set("v.showConfigSpinner", false);
                            c.set("v.isShowSpinner", true);  
                            h.doinit_helper(c,e,h);
                        }), 30000
                    );
                }else if(storedResponse === 'Registration Unsuccessful'){
                    c.set("v.showConfigSpinner", false);
                    c.set("v.showConfigErrorMessage", true);
                    c.set("v.packageConfigFailText", 'Package could not auto register on TT Server. Please Reload Page.');
                }else if(storedResponse === 'No Action'){
                    c.set("v.showConfigSpinner", false);
                    c.set("v.isShowSpinner", true);
                    h.doinit_helper(c,e,h);
                }else if(storedResponse === 'Registration Not Required'){
                    window.setTimeout(
                        $A.getCallback(function () {
                            c.set("v.showConfigSpinner", false);
                            c.set("v.isShowSpinner", true);
                            h.doinit_helper(c,e,h);
                        }), 30000
                    );
                }else{
                    c.set("v.showConfigSpinner", false);
                    c.set("v.showConfigErrorMessage", true);
                    c.set("v.packageConfigFailText", storedResponse);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    handleActive: function (c, e, h) {
    },
    SyncAllRecords: function (c, e, h) {
        c.set("v.isModalOpen", false);
        c.set("v.isShowSpinner", true);                    
        h.AllSynchedRecords(c,e,h);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    submitDetails: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var a = component.get('c.doinit');
        $A.enqueueAction(a);    
    },
    openMail: function(component, event, helper) {
        var a = document.createElement("a");
        a.href = "mailto:"+encodeURIComponent("support@telostouch.com");
        a.click();
    },
    onSyncChange : function (c,e,h) {
        if( !$A.util.isUndefinedOrNull(c.get('v.syncTypeValue')) && !$A.util.isEmpty(c.get('v.syncTypeValue')) &&
            !$A.util.isUndefinedOrNull(c.get('v.syncObjectValue')) && !$A.util.isEmpty(c.get('v.syncObjectValue')) ){
            c.set('v.manualSyncDisabled', false);
        }
    }
})