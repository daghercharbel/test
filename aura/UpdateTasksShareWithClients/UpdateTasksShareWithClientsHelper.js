({
    SelectedTasksSync_Helper: function (c, e, h) {
        var taskIdsList = c.get('v.SelectedTaskIds');
        var lengthofIds =  taskIdsList.length; 
        if(lengthofIds !=2){
            var action = c.get("c.syncSelectedTasks");
            action.setParams({
                'taskIdsList': taskIdsList
            });
            action.setCallback(this, function(response) {
                c.set("v.isShowSpinner", false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storedResponse = response.getReturnValue();
                    c.set("v.isModalOpen", true);
                } 
                window.open(window.location.origin+'/lightning/o/Task/home', '_self');
            });
            $A.enqueueAction(action);
        }
        else{ 
            c.set("v.isShowSpinner", false);
            h.showToast_Helper(c,'error','Please select any record.');            
            window.open(window.location.origin+'/lightning/o/Task/home', '_self');
        }
    },
    showToast_Helper: function (c, variant, message) {
        c.set('v.variant', variant);
        c.set('v.message', message);
        c.set('v.showToast', true);
    }
})