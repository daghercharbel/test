({
    doInit : function(c,e,h){
        try{
            h.doInitHelper(c,e,h);
        }catch(exp){
        }
    },
    handleActiveTab : function(c,e,h){
        try{
            c.set('v.isSpin',true);
            document.getElementById("search").value = '';
            var tab = e.getSource().get('v.id');
            var data = c.get('v.Data');
            data.length = 0;
            c.set('v.Data',data);
            c.set('v.SelectedTabId',tab);
            var selectedData = c.get('v.selectedRecords');
            selectedData.length = 0;
            c.set('v.selectedRecords',selectedData);
            h.fetchData_helper(c,e,h,tab,'');
        }catch(exp){
        }
    },
    loadMoreData : function(c,e,h){
        try{
            c.set('v.isSpin',true);
            var searchFilter =document.getElementById("search").value;
            e.getSource().set("v.isLoading", true);
            var tab = c.get('v.SelectedTabId');
            h.fetchData_helper(c,e,h,tab,'');
        }catch(exp){
        }
    },
    searchRecord: function (c,e, h) {
        try{
            var searchFilter = document.getElementById("search").value;
            if ($A.util.isEmpty(document.getElementById("search").value)) {
                c.set('v.isSpin',true);
                var data = c.get('v.Data');
                data.length = 0;
                c.set('v.Data',data);
                h.searchRecordHelper(c, e, h);
            }else if(searchFilter.length >= 3){
                c.set('v.errorMessage','');
            }
        }catch(exp){
        }
    },
    onSearchButton : function (c,e, h) {
        try{
            var searchKey = document.getElementById("search").value;
            if(searchKey.length < 3){
                c.set('v.errorMessage','Please enter minimum 3 letters of Email/ContactName');
            }
            else{
                c.set('v.isSpin',true);
                var data = c.get('v.Data');
                data.length = 0;
                c.set('v.Data',data);
                c.set('v.errorMessage','');
                h.searchRecordHelper(c, e, h);
            }
        }catch(err){
        }
    },
    onrowselection: function (c , e, h) {
        try{
            var data = c.get('v.Data');
            var selectedRow = e.getSource().get("v.value");
            var oldSelectedRows = c.get('v.selectedRecords');
            var count = 1;
            if(oldSelectedRows.length > 0){
                for(var i=0;i<oldSelectedRows.length;i++){
                    if(oldSelectedRows[i].Id == selectedRow.Id){
                        count = 0;
                        oldSelectedRows.splice(i,1);
                        break;
                    }
                }
            }
            if(data.length > 0){
                for(var j=0; j<data.length;j++){
                    if(data[j].Id == selectedRow.Id){
                        if(data[j].isSelected == false){
                            data[j].isSelected = true;
                        }
                        else{
                            data[j].isSelected = false;
                        }
                        break;
                    }
                }
            }
            if(count == 1){
                selectedRow.isSelected = true;
                oldSelectedRows.push(selectedRow);
            }
            c.set('v.Data',data);
            c.set('v.selectedRecords',oldSelectedRows);
        }catch(err){
        }
    },
    removePill : function(c, e, h){
        try{
            var data = c.get('v.Data');
            var selectedRecords = c.get('v.selectedRecords');
            var delItem = e.getSource().get("v.name");
            if(selectedRecords.length > 0){
                for(var j=0; j<selectedRecords.length;j++){
                    if(selectedRecords[j].Id == delItem){
                        selectedRecords.splice(j,1);
                        break;
                    }
                }
            }
            if(data.length > 0){
                for(var i=0; i<data.length;i++){
                    if(data[i].Id == delItem){
                        data[i].isSelected = false;
                        break;
                    }
                }
            }
            c.set('v.Data',data);
            c.set('v.selectedRecords',selectedRecords);
        }catch(err){
        }
    },
    onEventHandle_Add : function(c, e, h){
        try{
            var eventMessage = e.getParam("isCampaign");
            if(eventMessage == true){
                var records = c.get('v.selectedRecords');
                if(records.length > 0){
                    h.createCampMember(c, e, h);
                }else{
                    h.showToastHelper(c,e,h,$A.get("$Label.c.ERROR_Text"),$A.get("$Label.c.Please_Select_1_Record_Text"),'error');
                }
            }
            
        }catch(err){
        }
    }
})