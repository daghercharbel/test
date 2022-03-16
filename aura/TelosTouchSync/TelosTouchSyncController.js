({
    doinit: function (c, e, h) {
        var tHeight = screen.availHeight - 357;
        var pSize = (tHeight/52)-2;
        c.set("v.pageSize", parseInt(pSize));
        c.set("v.isShowSpinner", true);
        var pageNumber = c.get("v.PageNumber");  
        var pageSize = c.get("v.pageSize");
        h.doinit_helper(c, pageNumber, pageSize);
    }, 
     handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize =  component.get("v.pageSize");
        pageNumber++;
        helper.doinit_helper(component, pageNumber, pageSize);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize =  component.get("v.pageSize");
        pageNumber--;
        helper.doinit_helper(component, pageNumber, pageSize);
    },
 
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    submitDetails: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    seeMore:function(c, e, h){
        h.doinit_helper(c, e, h, true);
    },
})