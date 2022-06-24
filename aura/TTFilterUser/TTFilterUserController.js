({
  doInit: function (c, e, h) {
    const empApi = c.find("empApi");
    empApi
      .subscribe(
        "/event/TelosTouchSF__Insight_Creation_Event__e",
        "-1",
        $A.getCallback((eventReceived) => {
          // Process event (this is called each time we receive an event)\
          //console.log('TTFilterEvent:: '+JSON.stringify(eventReceived));
          if (
            c.get("v.recordId") ==
            eventReceived.data.payload.TelosTouchSF__Campaign__c
          ) {
            h.doInit_helper(c, e, h);
          }
        })
      )
      .then((subscription) => {
        // Subscription response received.
        // We haven't received an event yet.
        //console.log('Subscription request sent to: ', subscription.channel);
        // Save subscription to unsubscribe later
      });
      let countV = 0;
      c.set("v.count", countV);
      c.set("v.countSelectAll", countV);
    h.doInit_helper(c, e, h);
  },
  fielterEvent: function (c, e, h) {
    if (c.get("v.fielterDetailsChanges") == "EventFire") {
      c.set("v.fielterDetailsChanges", "");
      h.fielterEvent_helper(c, e, h, false);
    }
  },
  fielterDetailsChanges: function (c, e, h) {
    c.set("v.fielterDetailsChanges", "EventFire");
  },
  viewRecord: function (c, e, h) {
    let sfId = e.getSource().get("v.value");
    var recId = e.getSource().get("v.value").Id;
    var fieldName='';
    if(e.getSource().getLocalId()){
      fieldName  = e.getSource().getLocalId();
    }
    if(fieldName == "Create Task"){
      h.createAction_helper(c, e, h, sfId.ContactOrLeadSFId);
    }else{
      if (!$A.util.isEmpty(recId)) {
        c.set("v.convId", recId);
        h.viewRecord_helper(c, e, h, recId);
      }
    }
    // var recId = e.getParam("row").Id;
    // console.log(e.getParam("row"));
    // if (e.getParam("action").fieldName == "Create Task") {
    //   h.createAction_helper(c, e, h, e.getParam("row").ContactOrLeadSFId);
    // } else {
    //   if (!$A.util.isEmpty(recId)) {
    //     c.set("v.convId", recId);
    //     h.viewRecord_helper(c, e, h, recId);
    //   }
    // }
  },
  closeModel: function (c, e, h) {
    if (!c.get("v.clickOnInnerSection")) {
      c.set("v.isShowModel", false);
    }
    c.set("v.clickOnInnerSection", false);
  },
  closeModelInnerSection: function (c, e, h) {
    c.set("v.clickOnInnerSection", true);
  },
  //Will WOrk when someone click on send Touch Point Btn after selecting SOme lead/contacts
  sendTouchPoint: function (c, e, h) {
    // if (h.selectedUserList_Helper(c, e, h) != false) {
    //   //c.set("v.createCampaign",true);
    //   let action = c.get("c.fetchCampaignRecordType");
    //   action.setCallback(this, (result) => {
    //     if (result.getState() === "SUCCESS") {
    //       if (
    //         result.getReturnValue() != null &&
    //         result.getReturnValue() !== "No record type found"
    //       ) {
    //         var finalResponse = [];
    //         for (let x of JSON.parse(result.getReturnValue())) {
    //           var responseObj = {
    //             label: x.Name,
    //             value: x.Id,
    //           };
    //           finalResponse.push(responseObj);
    //         }
            //console.log(JSON.stringify(c.get("v.userList")));
            $A.createComponents([
                ["c:TTFilterAddToCampaign",{userList: c.get("v.userList"), recordId : c.get('v.recordId')}],
              ["c:TTFilterAddToCampaignFooter",{userList: c.get("v.userList")}]
          ],
              function (content, status) {
                if (status === "SUCCESS") {
                  c.find("overlayLib")
                  .showCustomModal({
                      header: $A.get("$Label.c.Add_Campaign_Modal_Header_Text"),
                      body: content[0],
                      footer: content[1],
                      showCloseButton: true,
                  })
                  .then(function (overlay) {
                      c._overlay = overlay;
                  });
                }
              }
            );
      //     } else {
      //     }
      //   } else {
      //     h.showSuccess(
      //       c,
      //       e,
      //       h,
      //       "Error",
      //       "error",
      //       "Campaign creation failed to initialize. Please try again."
      //     );
      //   }
      // });
      $A.enqueueAction(action);
  },

  // Send Reminder to the Clients
  sendReminderController: function (c, e, h) {
    c.set("v.isSendReminder", false);
    h.sendReminder_Helper(c, e, h);
  },
  openSendReminderModal: function (c, e, h) {
    if (h.selectedUserList_Helper(c, e, h) != false) {
      c.set("v.isSendReminder", true);
    }
  },
  //Will Work when someone click on users after filtering answers
  // getSelectedClientsRecords: function (c, e, h) {
  //   var selectedRows = e.getParam("selectedRows");
  //   if (selectedRows.length > 0 && selectedRows != undefined) {
  //     c.set("v.isDisableSendTouchPointBtn", false);
  //     c.set("v.userList", selectedRows);
  //   } else {
  //     c.set("v.isDisableSendTouchPointBtn", true);
  //   }
  // },
  //Send Touch Point Modal 1
  closeCreateCampaignModel: function (component, event, helper) {
    component.set("v.createCampaign", false);
    component.set("v.campaignName", "");
  },
  //Send Touch Point Modal 2 Appears WHen we enter campaign name and send to tt
  submitCreateCampaignDetails: function (c, e, h) {
    if (c.get("v.campaignName") != undefined) {
      c.set("v.campaignName", c.get("v.campaignName").trim());
    }
    var allValid = c
      .find("Campaigninput")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
    if (allValid) {
      h.SendTouchPoint_helper(c, e, h);
    } else {
      h.showSuccess(
        c,
        e,
        h,
        "Error",
        "error",
        $A.get("$Label.c.Add_To_Campaign_Error_Text")
      );
    }
  },
  CloseModal: function (component, event, helper) {
    component.set("v.isSendReminder", false);
    component.set("v.createAction", false);
    component.set("v.newTask", { sobjectType: "Task" });
  },

  SaveCreateAction: function (c, e, h) {
    var currentuserId = c.get("v.currentUser");
    var cmpTarget = c.find("subjectId");
    if ($A.util.isEmpty(c.get("v.newTask.Subject"))) {
      $A.util.addClass(cmpTarget, "slds-has-error");
      c.set("v.subjectMessage", $A.get("$Label.c.Complete_this_field_Label"));
      return;
    } else {
      c.set("v.subjectMessage", "");
      $A.util.removeClass(cmpTarget, "slds-has-error");
    }
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var userList = c.get("v.userList");
    var newTask = c.get("v.newTask");
    if (!$A.util.isEmpty(c.get("v.currentUser"))) {
      newTask.OwnerId = currentuserId.Id;
    }
    var allValid = c
      .find("validFields")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && !inputCmp.get("v.validity").valueMissing;
      }, true);
    if (allValid) {
      if (!$A.util.isEmpty(newTask)) {
        h.SaveCreateAction_Helper(c, e, h, userList);
      }
    } else {
      h.showToast_Helper(c, "error", "Please complete all required fields.");
    }
  },

  showpList: function (c, e, h) {
    c.set("v.SubjectListItems", true);
    var newTaskSubject = e.getSource().get("v.value");
    if (!$A.util.isEmpty(newTaskSubject)) {
      c.set("v.SubjectListItems", false);
    }
  },

  itemValue: function (c, e, h) {
    var select = e.currentTarget.name;
    //c.set('v.newTask.Subject',select);
    var select = e.currentTarget.dataset.id;
    c.set("v.newTask.Subject", select);
    c.set("v.SubjectListItems", false);
  },
  showlist: function (c, e, h) {
    c.set("v.SubjectListItems", true);
  },

  hidelist: function (c, e, h) {
    c.set("v.subjectMessage", "");
    window.setTimeout(
      $A.getCallback(function () {
        c.set("v.SubjectListItems", false);
      }),
      1000
    );
  },
  selectedSubject: function (c, e, h) {
    var value = e.target.dataset.value;
    c.set("v.newTask.Subject", value);
    c.set("v.SubjectListItems", false);
  },
  validateFTE: function (component, event, helper) {
    var cmpDiv = c.find("validFields");
    if (!$A.util.isEmpty(cmpDiv)) {
      $A.util.addClass(component.find("fteError"), "show");
    } else {
      $A.util.removeClass(component.find("fteError"), "show");
    }
  },
  handleModalCloseEvent: function (c, e, h) {
    //console.log(e.getParam("CloseModal"));
    if (e.getParam("CloseModal") == true) {
      c._overlay.close();
    }
  },
  createAction: function (c, e, h) {
    if (h.selectedUserList_Helper(c, e, h) != false) {
      //c.set("v.createAction",true);
      var action = c.get("c.fetchRecordType");
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (
            response.getReturnValue() != null &&
            response.getReturnValue() !== "No record type found"
          ) {
            var finalResponse = [];
            for (let x of JSON.parse(response.getReturnValue())) {
              var responseObj = {
                label: x.Name,
                value: x.Id,
              };
              finalResponse.push(responseObj);
            }
            $A.createComponents(
              [
                [
                  "c:ModalBodyComponent",
                  {
                    createAction: true,
                    userList: c.get("v.userList"),
                    recordTypeOptions: finalResponse,
                    recordTypeId: finalResponse[0].value,
                    recordId: c.get("v.recordId"),
                  },
                ],
                ["c:ModalBodyComponent_Footer", { createMassAction: true }],
              ],
              function (content, status) {
                if (status === "SUCCESS") {
                  c.find("overlayLib")
                    .showCustomModal({
                      //header: rtnValue[0].TouchPointName+'\n'+rtnValue[0].Name,
                      header: $A.get("$Label.c.Create_Task_Text"),
                      body: content[0],
                      footer: content[1],
                      showCloseButton: true,
                      cssClass: "padding-initial",
                    })
                    .then(function (overlay) {
                      c._overlay = overlay;
                    });
                }
              }
            );
          } else if (response.getReturnValue() === "No record type found") {
            //alert('No Record Type Found');
            $A.createComponents(
              [
                [
                  "c:massCreateTaskComp",
                  {
                    recordTypeId: "",
                    recordTypeName: "",
                    userList: c.get("v.userList"),
                    recordId: c.get("v.recordId"),
                  },
                ],
                ["c:lwcModalFooter", {}],
              ],
              function (content, status) {
                if (status === "SUCCESS") {
                  c.find("overlayLib")
                    .showCustomModal({
                      header: $A.get("$Label.c.Create_Task_Text"),
                      body: content[0],
                      footer: content[1],
                      showCloseButton: true,
                      cssClass: "taskModal slds-modal_medium",
                    })
                    .then(function (overlay) {
                      c._overlay = overlay;
                    });
                }
              }
            );
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  onEventHandle_Save: function (c, e, h) {
    if (e.getParam("isCreateMassTask") === true) {
      window.setTimeout(
        $A.getCallback(function () {
          c._overlay.close();
        }),
        2000
      );
    }
  },
  doRefresh: function (c, e, h) {
    if (e.getParam("doRefresh") === true) {
      h.doInit_helper(c, e, h);
    }
  },
  handleClick: function(c,e,h) {
    let label = e.target.label;
    if (label === "Previous") {
        h.handlePrevious(c,e,h);
    } else if (label === "Next") {
        h.handleNext(c,e,h);
    }
},
  handleNext: function(c,e,h) {
    let incValue = c.get("v.pageNo");
    incValue +=1;
    c.set("v.pageNo", incValue);
    c.set("v.isCheckedList", []);
    h.preparePaginationList(c,e,h);
    let flag = 0;
     for(let x of c.get("v.listData")){
       if(!x.isChecked){
        flag = 1;
        break;
       }
     }
     if(flag){
        c.set("v.selectAllList", false);
      }else{
        c.set("v.selectAllList", true);
      }
  },

  handlePrevious: function(c,e,h) {
    if(c.get("v.pageNo")>1){
      let decValue = c.get("v.pageNo");
      decValue -= 1;
      c.set("v.pageNo", decValue);
    }
    c.set("v.isCheckedList", []);
    h.preparePaginationList(c,e,h);
    let flag = 0;
    for(let x of c.get("v.listData")){
      if(!x.isChecked){
        flag = 1;
        break;
      }
    }
    if(flag){
      c.set("v.selectAllList", false);
    }else{
      c.set("v.selectAllList", true);
    }
  },
  handleCheckboxChange: function(c,e,h){
    try {
      let updatedWithCheckboxList = [];
      let paginationList = c.get("v.listData");
      for(var each of paginationList){
        if(each.Id == e.getSource().get("v.value")){
          each.isChecked = each.isChecked!=null || each.isChecked != undefined ? each.isChecked:true;
          updatedWithCheckboxList.push(each);
        }
      }
     let flag = 0;
     for(let x of paginationList){
       if(!x.isChecked){
        flag = 1;
        break;
       }
     }
     if(flag){
        c.set("v.selectAllList", false);
      }else{
        c.set("v.selectAllList", true);
      }
      h.getSelectedClientsRecords(c,e,h, updatedWithCheckboxList);
    } catch (error) {
      console.log(error);
    }
    
  },
  selectAll: function(c,e,h){
    //console.log('Event value >> '+ e.getSource().get("v.checked"))
    let updatedWithCheckboxList = [];
    let paginationList = c.get("v.listData");
    c.set("v.selectAllList",e.getSource().get("v.checked"));
    for(var each of paginationList){
      if(e.getSource().get("v.checked")){
        each.isChecked = true;
        updatedWithCheckboxList.push(each);
      }else {
        each.isChecked = false;
        updatedWithCheckboxList.push(each);
      }
    }
    //console.log('updatedWithCheckboxList >> '+ JSON.stringify(updatedWithCheckboxList))
    c.set("v.listData", updatedWithCheckboxList);
    let flag = 0;
     for(let x of updatedWithCheckboxList){
       if(!x.isChecked){
        flag = 1;
        break;
       }
     }
     if(flag){
        c.set("v.selectAllList", false);
      }else{
        c.set("v.selectAllList", true);
      }
    h.getSelectedAllClientsRecords(c,e,h, updatedWithCheckboxList);
    //h.onOffSelectAll(c,e,h);
  },
  
});