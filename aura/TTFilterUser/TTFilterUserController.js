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
    var recId = e.getParam("row").Id;
    if (e.getParam("action").fieldName == "Create Task") {
      h.createAction_helper(c, e, h, e.getParam("row").ContactOrLeadSFId);
    } else {
      if (!$A.util.isEmpty(recId)) {
        c.set("v.convId", recId);
        h.viewRecord_helper(c, e, h, recId);
      }
    }
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
    if (h.selectedUserList_Helper(c, e, h) != false) {
      //c.set("v.createCampaign",true);
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
            //console.log(JSON.stringify(c.get("v.userList")));
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
                      //header: rtnValue[0].TouchPointName+'\n'+rtnValue[0].Name,
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
    }
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
  getSelectedClientsRecords: function (c, e, h) {
    var selectedRows = e.getParam("selectedRows");
    if (selectedRows.length > 0 && selectedRows != undefined) {
      c.set("v.isDisableSendTouchPointBtn", false);
      c.set("v.userList", selectedRows);
    } else {
      c.set("v.isDisableSendTouchPointBtn", true);
    }
  },
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
    h.doInit_helper(c, e, h);
  },
});