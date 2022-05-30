({
    doInit : function(c, e, h) {
        c.set('v.isShowSpinner', true);
        c.set("v.hideOptions", true);
        var action = c.get('c.fetchLimitedRecords');
        action.setCallback(this,function(response){ 
            try{
                //c.set('v.isShowSpinner', false);
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
                //console.log(e);
            }
        });
        $A.enqueueAction(action);
    },
    onClickInputHandle: function(c,e,h){
        c.set('v.isShowSpinner', true);
        c.set("v.hideOptions", true);
        c.set("v.boolForNoRecord", false);
        var action = c.get('c.fetchLimitedRecords');
        action.setCallback(this,function(response){ 
            try{
                c.set('v.isShowSpinner', false);
                var result = response.getReturnValue();
                if(response.getState() === 'SUCCESS') {
                    if(!$A.util.isEmpty(result) && JSON.parse(result) != '') {
                        c.set('v.recordsList', JSON.parse(result));        
                    } else {
                        c.set('v.boolForNoRecord', true);

                    }
                }else{
                    c.set('v.boolForNoRecord', true);
                }
            }catch(e){
                //console.log(e);
            }
        });
        $A.enqueueAction(action);
    },
    setInputValue: function(c,e,h){
        c.set("v.searchString", e.getSource().get("v.value"));
    },
    searchCampaign: function(c,e,h){
        c.set('v.isShowSpinner', true);
        if(!$A.util.isEmpty(c.get("v.searchString"))){
            var action = c.get('c.fetchRecords');
            action.setParams({
                'objectName' : 'Campaign',
                'filterField' : 'Name',
                'searchString' : c.get('v.searchString')
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
                    //console.log(e);
                }
            });
            $A.enqueueAction(action);
        }else{
            c.set('v.isShowSpinner', false);
            c.set("v.hideOptions", true);
            c.set("v.boolForNoRecord", false);
            c.set('v.recordsList', []); 
        }
    },
    selectCampaignValue: function(c,e,h){
        var selectedCampignId = e.currentTarget.id;
        try {
            if(selectedCampignId != null){
                var recordsList = c.get('v.recordsList');
                var index = recordsList.findIndex(x => x.value === selectedCampignId)
                if(index != -1)
                    var selectedRecord = recordsList[index];
                c.set('v.selectedRecord', selectedRecord);
                c.set("v.hideOptions", false);
                c.set("v.boolForInput", false);
            }     
        } catch (error) {
            //console.log(error);
        }
    },
    onEventHandle_Save: function(c,e,h){
        if(e.getParam("addToExistingCampaign") === true && !$A.util.isEmpty(c.get('v.selectedRecord').value)){
            var action = c.get('c.addClientsToCampaign');
            action.setParams({
                'campRecordId' : c.get('v.selectedRecord').value,
                'userListStr' : JSON.stringify(c.get('v.userList'))
            });
            action.setCallback(this,function(response){ 
                try{
                    if(response.getState() === 'SUCCESS') {
                        var result = response.getReturnValue();
                        //console.log('resut:: '+ JSON.stringify(result));
                        if(result.includes('error')){
                            h.showSuccess(c,e,h,"Error","error",result.split('#')[1]);
                        }else{
                            h.showSuccess(c,e,h,"Success","success",$A.get("$Label.c.Clients_Added_To_Campaign_Text"));
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": result,
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                    }
                }catch(e){
                    //console.log(e);
                }
            });
            $A.enqueueAction(action);
        }else{
            h.showSuccess(c,e,h,"Error","error",$A.get("$Label.c.Select_Campaign_First_Text"));
        } 
    },
    removeItem: function(c,e,h){
        c.set('v.selectedRecord',{});
        c.set('v.searchString','');
        c.set("v.boolForInput", true);
        c.set("v.boolForNoRecord", false);
    },
    createNewRecord: function(c,e,h){
        try {
            if (h.selectedUserList_Helper(c, e, h) != false) {
                let action = c.get("c.fetchCampaignRecordType");
                action.setCallback(this, (result) => {
                  if (result.getState() === "SUCCESS") {
                    if (
                      result.getReturnValue() != null &&
                      result.getReturnValue() !== "No record type found"
                    ) {
                      var finalResponse = [];
                      for (let x of JSON.parse(result.getReturnValue())) {
                        var responseObj = {
                          label: x.Name,
                          value: x.Id,
                        };
                        finalResponse.push(responseObj);
                      }
                      $A.createComponent(
                        "c:ModalBodyComponent",
                        {
                          selectCampaignRecordType: true,
                          userList: c.get("v.userList"),
                          recordTypeOptions: finalResponse,
                          recordTypeId: finalResponse[0].value,
                        },
                        function (content, status) {
                          if (status === "SUCCESS") {
                            c.find("overlayLib")
                              .showCustomModal({
                                header: $A.get("$Label.c.Add_Campaign_Modal_Header_Text"),
                                body: content,
                                showCloseButton: true,
                                cssClass: "padding-initial",
                              })
                              .then(function (overlay) {
                                c._overlay = overlay;
                              });
                          }
                        }
                      );
                    } else {
                    }
                  } else {
                    h.showSuccess(
                      c,
                      e,
                      h,
                      "Error",
                      "error",
                      "Campaign creation failed to initialize. Please try again."
                    );
                  }
                });
                $A.enqueueAction(action);
            }  else{
            } 
        } catch (error) {
            //console.log(error);
        }
    }
})