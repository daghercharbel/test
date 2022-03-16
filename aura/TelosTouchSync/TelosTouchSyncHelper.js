({
    doinit_helper: function (c, pageNumber, pageSize) {
        c.set("v.isShowSpinner", true); 
        var action = c.get("c.getAllLogs");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(response) {
            c.set("v.isShowSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storedResponse = response.getReturnValue();
                var storedResponse = response.getReturnValue();
                if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined){
                    c.set("v.LogsList", storedResponse.allLogsList);
                    c.set("v.PageNumber", storedResponse.pageNumber);
                    c.set("v.TotalRecords", storedResponse.totalRecords);
                    c.set("v.RecordStart", storedResponse.recordStart);
                    c.set("v.RecordEnd", storedResponse.recordEnd);
                    c.set("v.TotalPages", Math.ceil(storedResponse.totalRecords / pageSize));
                    c.set("v.currentUserLanguage", storedResponse.currentUserLanguage);
                }else{
                    c.set('v.LogsList',[]);
                }
            } 
        });
        $A.enqueueAction(action);
    },
})