({
    AllSynchedRecords: function (c, e, h) {
        var action = c.get("c.SyncAllRecords_APEX");
        action.setParams({
            syncType : c.get('v.syncTypeValue'),
            syncObject : c.get('v.syncObjectValue')
        });
        action.setCallback(this, function(response) {
            c.set("v.isShowSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                c.set("v.isModalOpen", true);
            } else if (state === "ERROR") {
                c.set("v.WarningModalisOpen", true);
                c.set("v.isShowSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
   
    doinit_helper: function (c, e, h) {
        c.set("v.isShowSpinner", true);
        var action = c.get("c.getLatestLogs");
        action.setCallback(this, function(response) {
            c.set("v.isShowSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storedResponse = response.getReturnValue();
                //console.log('storedResponse::'+JSON.stringify(storedResponse));
                if(storedResponse != null && storedResponse.allLogsList != null){
                    c.set("v.logsList", storedResponse.allLogsList );
               }if(storedResponse != null && storedResponse.getCustomMetadataSetting != null){
                    c.set("v.setting", storedResponse.getCustomMetadataSetting );
               }if(storedResponse != null && storedResponse.asyncJobstatus != null){
                    c.set("v.asyncJobStatus", storedResponse.asyncJobstatus );
               }
               //console.log('v.asyncJobStatus:: '+c.get('v.asyncJobStatus'));
               //console.log('v.setting.Approval__c:: '+c.get('v.setting.Approval__c'));
            }
        });
        $A.enqueueAction(action); 
    }
})