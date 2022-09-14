({
    itemSelected: function (component, event, helper) {
        var target = event.target;
        var SelIndex = helper.getIndexFrmParent(target, helper, "data-selectedIndex");
        if (SelIndex) {
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if (selItem.Id) {
                component.set("v.selItem", selItem);
                component.set("v.last_ServerResult", serverResult);
                var cmp = component.find('addborder');
            }
            component.set("v.server_result", null);
        }
    },
    firstServerCall: function (component, event, helper) {
        if (event.keyCode == 27) {
            helper.clearSelection(component, event, helper);
        } else {
            if (component.get('v.searchText') == '') {
                //Save server call, if last text not changed
                var objectName = component.get("v.objectName");
                var field_API_text = component.get("v.field_API_text");
                var field_API_val = component.get("v.field_API_val");
                var field_API_search = component.get("v.field_API_search");
                var limit = component.get("v.limit");
                var parentFiledName = component.get("v.parentFiledName");
                var parentFiledId = component.get("v.parentFiledId");
                var searchTextStartsWithFilter = component.get("v.searchTextStartsWithFilter");
                var action = component.get('c.searchDB');
                action.setStorable();
                action.setParams({
                    objectName: objectName,
                    fld_API_Text: field_API_text,
                    fld_API_Val: field_API_val,
                    lim: limit,
                    fld_API_Search: field_API_search,
                    searchText: null,
                    parentFiledName: parentFiledName,
                    parentFiledId: parentFiledId,
                    searchTextStartsWithFilter :searchTextStartsWithFilter
                });
                action.setCallback(this, function (a) {
                    this.handleResponse(a, component, helper);
                });
                $A.enqueueAction(action);
            }
        }
    },
    serverCall: function (component, event, helper) {
        var target = event.target;
        var searchText = component.get("v.searchText");
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed
        if (event.keyCode == 27 || !searchText.trim()) {
            helper.clearSelection(component, event, helper);
        } else if (searchText.trim() != last_SearchText) {
            //Save server call, if last text not changed
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_val = component.get("v.field_API_val");
            var field_API_search = component.get("v.field_API_search");
            var limit = component.get("v.limit");
            var parentFiledName = component.get("v.parentFiledName");
            var parentFiledId = component.get("v.parentFiledId");
            var searchTextStartsWithFilter = component.get("v.searchTextStartsWithFilter");
            var action = component.get('c.searchDB');
            action.setStorable();
            
            action.setParams({
                objectName: objectName,
                fld_API_Text: field_API_text,
                fld_API_Val: field_API_val,
                lim: limit,
                fld_API_Search: field_API_search,
                searchText: searchText,
                parentFiledName: parentFiledName,
                parentFiledId: parentFiledId,
                searchTextStartsWithFilter :searchTextStartsWithFilter
            });
            action.setCallback(this, function (a) {
                this.handleResponse(a, component, helper);
            });
            component.set("v.last_SearchText", searchText.trim());
            $A.enqueueAction(action);
        } else if (searchText && last_SearchText && searchText.trim() == last_SearchText.trim()) {
            component.set("v.server_result", component.get("v.last_ServerResult"));
        }
    },
    handleResponse: function (res, component, helper) {
        if (res.getState() === 'SUCCESS') {
            if (res.getReturnValue() != null) {
                var retObj = JSON.parse(res.getReturnValue());
                if (retObj.length <= 0) {
                    var noResult = JSON.parse('[{"text":"'+$A.get("$Label.c.No_Results_Found_Text")+'"}]');
                    component.set("v.server_result", noResult);
                    component.set("v.last_ServerResult", noResult);
                } else {
                    component.set("v.server_result", retObj);
                    component.set("v.last_ServerResult", retObj);
                }
            }
        } else if (res.getState() === 'ERROR') {
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            }
        }
    },
    getIndexFrmParent: function (target, helper, attributeToFind) {
        try{
            //User can click on any child element, so traverse till intended parent found
            if(target != null){ 
                var SelIndex = target.getAttribute(attributeToFind);
                while (!SelIndex) {
                    target = target.parentNode;
                    SelIndex = helper.getIndexFrmParent(target, helper, attributeToFind);
                }
                return SelIndex;
            }
        }catch(ex){
        }
    },
    clearSelection: function (component, event, helper) {
        component.set("v.selItem", null);
        component.set("v.server_result", null);
        component.set("v.searchText", '');
        var cmp = component.find('addborder');
        helper.firstServerCall(component, event, helper);
    },
    createNewRecord_Helper: function (component, event, helper) {
        try{
            var modalBody;
            if(component.get('v.fromPcComp') == false){
                $A.createComponent("c:FilterLookup_CreateChildRecord",{
                    "recordId": component.get("v.recordId"),
                    "sObjectName": component.get("v.sObjectName"),
                },
                   function (content, status) {
                       if (status === "SUCCESS") {
                           modalBody = content;
                           component.find('overlayLib').showCustomModal({
                               header: $A.get('$Label.c.New_Campaign_Header_Text'),
                               body: modalBody,
                               showCloseButton: true,
                               closeCallback: function () {
                                   helper.itemSelected(component, event, helper);
                                   var myEvent = $A.get("e.c:ChildModalCloseEvent");
                                   myEvent.setParams({"eventAction": 'ModalClosed'});
                                   myEvent.fire();
                               }
                           }).then(function(overlay){
                           });
                       }
                   }
                  );
            }
        }catch(ex){
        }
    },
    
})