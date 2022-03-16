({
    doInitHelper : function(c ,e, h){
        try{
            var action = c.get('c.fetchRecordCounts');
            action.setParams({
                campaignId : c.get('v.recordId')
            });
             action.setCallback(this, function(response) {
             var state = response.getState();
                 if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var splitResult = result.counts.split('&&');
                    c.set('v.LeadCount',splitResult[0]);
                    c.set('v.ContactCount',splitResult[1]);
                    c.set('v.memberIds',result.memberIds);
                 }
             });
             $A.enqueueAction(action);
        }catch(err){
            //console.log(err);
        }
    },
	fetchData_helper : function(c,e,h,tab,searchKey) {
		try{
		    var length = c.get('v.Data').length;
		    var oldSelectedRows = c.get('v.selectedRecords');
		    var data = c.get('v.Data');
		    var dataIdSet = [];
		    if(length > 0){
		        for(var i=0;i<data.length;i++){
		            dataIdSet.push(data[i].Id);
		        }
		    }
		    if(searchKey != ''){
		        c.set('v.inSearch',false);
		    }
		    else{
		        c.set('v.inSearch',true);
		    }
            var action = c.get('c.fetchData');
            action.setParams({
                objectName : tab,
                dataIdSet : JSON.stringify(dataIdSet),
                searchKey : searchKey
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                var records = response.getReturnValue();
                    if(records != null){

                            for(var i=0;i<records.length;i++){
                            var count = 1;
                             if(oldSelectedRows.length > 0){
                                for(var j=0;j<oldSelectedRows.length;j++){
                                    if(oldSelectedRows[j].Id == records[i].Id){
                                        count = 0;
                                        break;
                                    }
                                }
                             }
                                if(count == 1){
                                    records[i].isSelected = false;
                                }else{
                                    records[i].isSelected = true;
                                }
                            }

                        var currentData = c.get('v.Data');
                        c.set("v.Data", currentData.concat(records));
                    }
                    c.set('v.isSpin',false);
                }
            });
            $A.enqueueAction(action);
        }catch(exp){
		    //console.log(exp);
		}
	},
	createCampMember : function(c, e, h){
	    try{
	        var records = c.get('v.selectedRecords');
	        var members = c.get('v.memberIds');
	        var recordId = c.get('v.recordId');
	        var selectedTab = c.get('v.SelectedTabId');
	        var action = c.get('c.createCampaignMembers');
	        var recordsToInsert = [];
	        var recordsAlreadyMember = [];
	        for(var i=0; i <records.length; i++ ){
	            var count = 1;
	            if(members.length > 0){
	                for(var j=0; j < members.length; j++){
	                    if(members[j] == records[i].Id){
	                        count = 0;
	                        recordsAlreadyMember.push(records[i]);
	                        break;
	                    }
	                }
	            }
	            if(count == 1){
	                recordsToInsert.push(records[i]);
	            }
	        }
	        if(recordsToInsert.length > 0){
	        action.setParams({
	            dataList : JSON.stringify(recordsToInsert),
	            campaignId : recordId,
	            objectName : selectedTab
	        });
	        action.setCallback(this, function(response) {
             var state = response.getState();
             var result = response.getReturnValue();
             if (state === "SUCCESS") {
                if(result == true){
                    h.showToastHelper(c,e,h,$A.get("$Label.c.SUCCESS_Text"),': '+recordsToInsert.length+' '+$A.get("$Label.c.new_member_added_text"),'success');
                    c.find("overlayLib").notifyClose();
                }
                else{
                    h.showToastHelper(c,e,h,$A.get("$Label.c.ERROR_Text"),$A.get("$Label.c.Something_went_wrong_Text"),'error');
                }
             }
             });
             $A.enqueueAction(action);
             }else{
                h.showToastHelper(c,e,h,$A.get("$Label.c.ERROR_Text"),': The selected records are already members of current campaign ..','error');
             }
	    }catch(err){
	        //console.log(err);
	    }
	},
	searchRecordHelper : function(c, e, h){
	        var tab = c.get('v.SelectedTabId');
            var searchFilter =document.getElementById("search").value;
            h.fetchData_helper(c,e,h,tab,searchFilter);
    },
    showToastHelper : function(component, event, helper,title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            type: type
        });
        toastEvent.fire();
    },
})