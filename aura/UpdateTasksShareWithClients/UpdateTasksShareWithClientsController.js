({
    doInit: function(c, e, h) {
        c.set("v.isShowSpinner", true);                    
        h.SelectedTasksSync_Helper(c, e, h);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        window.open(window.location.origin + '/lightning/o/Task/list', '_self');
    },
  
})