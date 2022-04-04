({
  doInit_helper: function (c, e, h) {
    try {
      c.set("v.columns", [
        {
          label: $A.get("$Label.c.Name_Text"),
          Id: "Id",
          fieldName: "nameURL",
          type: "url",
          typeAttributes: { label: { fieldName: "name" }, target: "_blank" }
        },
        {
          label: $A.get("$Label.c.Opened_At_Text"),
          fieldName: "TTOpened_At",
          type: "text"
        },
        {
          label: $A.get("$Label.c.Completed_At_Text"),
          fieldName: "TTCompleted_At",
          type: "text"
        },
        {
          label: $A.get("$Label.c.Answers_Text"),
          type: "button",
          typeAttributes: {
            label: $A.get("$Label.c.Answers_Text"),
            fieldName: "Answers",
            title: "Answers",
            value: "Answers",
            disabled: { fieldName: "isActive" },
            iconPosition: "left"
          }
        },
        {
          label: $A.get("$Label.c.Actions_Text"),
          type: "button",
          typeAttributes: {
            label: $A.get("$Label.c.Create_Task_Text"),
            fieldName: "Create Task",
            title: $A.get("$Label.c.Create_Task_Text"),
            value: "Create Task",
            iconPosition: "left"
          }
        }
      ]);
      var action = c.get("c.getTaskDetails");
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (
            response.getReturnValue() != null &&
            response.getReturnValue() != undefined
          ) {
            c.set("v.wrapperList", response.getReturnValue());
            if (!$A.util.isEmpty(response.getReturnValue().currentuser)) {
              var setItem = {};
              setItem.objName = "User";
              setItem.text = response.getReturnValue().currentuser.Name;
              setItem.Id = response.getReturnValue().currentuser.Id;
              c.set("v.currentUser", setItem);
              c.set(
                "v.newTask.OwnerId",
                response.getReturnValue().currentuser.Id
              );
              if (
                response
                  .getReturnValue()
                  .currentuser.LanguageLocaleKey.includes("fr")
              ) {
                c.set("v.frenchUserFlag", true);
              }
            }
          }
        }
      });
      $A.enqueueAction(action);
      h.initializeWrapper(c, e, h);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },
  initializeWrapper: function (c, e, h) {
    try {
      c.set("v.isShowSpinner", true);
      var action = c.get("c.doinitApex");
      action.setParams({
        campainId: c.get("v.recordId")
      });
      action.setCallback(this, function (response) {
        c.set("v.isShowSpinner", false);
        var state = response.getState();
        var rtnValue = response.getReturnValue();
        //console.log('rtnValue>>');
        //console.log(rtnValue);
        if (
          !$A.util.isEmpty(rtnValue) &&
          rtnValue != null &&
          state == "SUCCESS"
        ) {
          c.set("v.fielterDetails", rtnValue.ttFilterWrapperObj);
          c.set("v.data", rtnValue.userWrapperList);
          console.log(
            "fielterDetails==",
            JSON.stringify(rtnValue.ttFilterWrapperObj.questionAnswerList)
          );
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },
  fielterEvent_helper: function (c, e, h, isFormType) {
    try {
      var action = c.get("c.getUserDetails");
      action.setParams({
        campainId: c.get("v.recordId"),
        filterWrapper: JSON.stringify(c.get("v.fielterDetails")),
        isFormType: isFormType
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var rtnValue = response.getReturnValue();
        if (rtnValue != null && state == "SUCCESS") {
          c.set("v.data", rtnValue);
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },
  sendReminder_Helper: function (c, e, h, recordId) {
    try {
      c.set("v.isShowSpinner", true);
      var action = c.get("c.sendReminder");
      action.setParams({
        campainId: c.get("v.recordId"),
        userList: JSON.stringify(c.get("v.data"))
      });
      action.setCallback(this, function (response) {
        c.set("v.isShowSpinner", false);
        var state = response.getState();
        var rtnValue = response.getReturnValue();
        if (
          state == "SUCCESS" &&
          rtnValue != null &&
          rtnValue == "Reminder Sent Successfully"
        ) {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.SUCCESS_Text"),
            "success",
            $A.get("$Label.c.Reminder_Sent_Successfully_Text")
          );
          //h.showToast_Helper(c,'success',rtnValue);
        } else if (
          state == "SUCCESS" &&
          rtnValue != null &&
          rtnValue == "No Valid Clients"
        ) {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.ERROR_Text"),
            "error",
            $A.get("$Label.c.No_Valid_Client_Found_Toast")
          );
          //h.showToast_Helper(c,'error',$A.get("$Label.c.No_Valid_Client_Found_Toast"));
        } else if (
          state == "SUCCESS" &&
          rtnValue != null &&
          rtnValue == "The Touchpoint was created less than 24 Hours ago"
        ) {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.ERROR_Text"),
            "error",
            $A.get("$Label.c.Send_Reminder_Time_Error_Text")
          );
          //h.showToast_Helper(c,'error',$A.get("$Label.c.Send_Reminder_Time_Error_Text"));
        } else if (
          state == "SUCCESS" &&
          rtnValue != null &&
          rtnValue == "Unauthorized User"
        ) {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.ERROR_Text"),
            "error",
            $A.get("$Label.c.Unauthorized_User_Label")
          );
          //h.showToast_Helper(c,'error',$A.get("$Label.c.Unauthorized_User_Label"));
        } else if (
          state == "SUCCESS" &&
          rtnValue != null &&
          rtnValue == "Internal Server Error"
        ) {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.ERROR_Text"),
            "error",
            $A.get("$Label.c.Internal_Server_Error_Text")
          );
          //h.showToast_Helper(c,'error',$A.get("$Label.c.Internal_Server_Error_Text"));
        } else {
          h.showSuccess(
            c,
            e,
            h,
            $A.get("$Label.c.ERROR_Text"),
            "error",
            $A.get("$Label.c.Reminder_Not_Sent_Toast")
          );
          //h.showToast_Helper(c,'error',$A.get("$Label.c.Reminder_Not_Sent_Toast"));
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },
  selectedUserList_Helper: function (c, e, h) {
    var userList = c.get("v.userList");
    for (var i = 0; i < userList.length; i++) {
      if (
        userList[i].ContactCLientId == null &&
        userList[i].LeadCLientId == null
      ) {
        if (userList.length > 1) {
          h.showSuccess(
            c,
            e,
            h,
            "Error",
            "error",
            "Some selected members does not exist."
          );
        } else {
          h.showSuccess(
            c,
            e,
            h,
            "Error",
            "error",
            "Selected member does not exist."
          );
        }
        return false;
      }
    }
  },
  viewRecord_helper: function (c, e, h, recordId) {
    try {
      var count = 2;
      c.set("v.isShowSpinner", true);
      var action = c.get("c.getUserAnswers");
      action.setParams({
        recordId: recordId
      });
      action.setCallback(this, function (response) {
        c.set("v.isShowSpinner", false);
        var state = response.getState();
        var rtnValue = response.getReturnValue();
        console.log(rtnValue);
        if (rtnValue != null && state == "SUCCESS") {
          //c.set("v.isShowModel",true);
          c.set("v.answers", rtnValue[0]);
          $A.createComponents(
            [
              [
                "aura:unescapedHtml",
                {
                  value: rtnValue[0].TouchPointName + "<br/>" + rtnValue[0].Name
                }
              ],
              [
                "c:ModalBodyComponent",
                {
                  showAnswerModal: true,
                  answers: c.get("v.answers")
                }
              ]
            ],
            function (components, status) {
              if (status === "SUCCESS") {
                c.find("overlayLib")
                  .showCustomModal({
                    //header: rtnValue[0].TouchPointName+'\n'+rtnValue[0].Name,
                    header: components[0],
                    body: components[1],
                    showCloseButton: true,
                    cssClass: "mymodal"
                  })
                  .then(function (overlay) {});
              }
            }
          );
          //console.log('answers::'+JSON.stringify(c.get("v.answers")));
        } else {
          h.showSuccess(
            c,
            e,
            h,
            "Error",
            "error",
            "Conversation Details Not found"
          );
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },

  showSuccess: function (component, event, helper, title, type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      duration: " 2000",
      key: "info_alt",
      type: type
    });
    toastEvent.fire();
  },

  SendTouchPoint_helper: function (c, e, h) {
    try {
      c.set("v.isShowSpinner", true);
      var action = c.get("c.campaignInsertandSendTouchPoint");
      action.setParams({
        campaignName: c.get("v.campaignName"),
        userList: JSON.stringify(c.get("v.userList"))
      });
      action.setCallback(this, function (response) {
        c.set("v.isShowSpinner", false);
        var state = response.getState();
        var rtnValue = response.getReturnValue();
        if (
          !$A.util.isEmpty(rtnValue) &&
          rtnValue != null &&
          state == "SUCCESS"
        ) {
          c.set("v.campaignName", "");
          c.set("v.createCampaign", false);
          c.set("v.clientIdsList", rtnValue.clientIdlist);
          c.set("v.campaignSFid", rtnValue.campaignId);
          var clientIdsList = c.get("v.clientIdsList");
          var campaignSFid = c.get("v.campaignSFid");
          $A.createComponent(
            "c:SendTouchPointComponent",
            {
              clientIdsList: clientIdsList,
              campaignSFid: campaignSFid,
              campId: ""
            },
            function (content, status) {
              if (status === "SUCCESS") {
                var modalBody = content;
                c.find("overlayLib")
                  .showCustomModal({
                    body: modalBody,
                    showCloseButton: false,
                    closeCallback: function (ovl) {
                      c.set("v.data", []);
                      h.doInit_helper(c, e, h);
                    }
                  })
                  .then(function (overlay) {});
              }
            }
          );
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('Exception::'+ex);
    }
  },

  SaveCreateAction_Helper: function (c, e, h, userList) {
    try {
      let newTask = c.get("v.newTask");
      var tlist = [];
      if (!$A.util.isEmpty(userList)) {
        for (var userObj in userList) {
          let modifiedTaskObj = {};
          modifiedTaskObj.TelosTouchSF__Share_with_client_s__c =
            newTask.wrapperList.ShareWithClientlist;
          modifiedTaskObj.Status = newTask.wrapperList.StatusPicklist;
          modifiedTaskObj.Subject = newTask.Subject;
          modifiedTaskObj.Description = newTask.Description;
          modifiedTaskObj.ActivityDate = newTask.ActivityDate;
          modifiedTaskObj.OwnerId = newTask.OwnerId;
          modifiedTaskObj.WhoId = userList[userObj].ContactOrLeadSFId;
          tlist.push(modifiedTaskObj);
        }
      }
      c.set("v.isShowSpinner", true);
      var action = c.get("c.saveNewTask");
      action.setParams({
        tasklist: tlist
      });
      action.setCallback(this, function (response) {
        c.set("v.isShowSpinner", false);
        var state = response.getState();
        if (state === "SUCCESS") {
          $A.get("e.force:refreshView").fire();
          c.set("v.newTask", { sobjectType: "Task" });
          h.showSuccess(
            c,
            e,
            h,
            "Sucesss",
            "success",
            $A.get("$Label.c.Task_Create_Success_Text")
          );
          //h.showToast_Helper(c,'success',$A.get("$Label.c.Task_Create_Success_Text"));
          window.location.reload();
          c.set("v.createAction", false);
          var result = response.getReturnValue();
        }
      });
      $A.enqueueAction(action);
    } catch (error) {
      //console.log(error);
    }
  },

  showToast_Helper: function (c, variant, message) {
    c.set("v.variant", variant);
    c.set("v.message", message);
    c.set("v.showToast", true);
  },
  createAction_helper: function (c, e, h, contactOrLeadId) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    c.set("v.newTask.ActivityDate", today);
    c.set("v.TodayDate", today);
    if (h.selectedUserList_Helper(c, e, h) != false) {
      //c.set("v.createAction",true);
      var action = c.get("c.fetchRecordType");
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (
            response.getReturnValue() != null &&
            response.getReturnValue() != "No record type found"
          ) {
            var finalResponse = [];
            for (let x of JSON.parse(response.getReturnValue())) {
              var responseObj = {
                label: x.Name,
                value: x.Id
              };
              finalResponse.push(responseObj);
            }
            $A.createComponents(
              [
                [
                  "c:ModalBodyComponent",
                  {
                    createAction: true,
                    contactOrLeadId: contactOrLeadId,
                    recordTypeOptions: finalResponse,
                    recordTypeId: finalResponse[0].value
                  }
                ],
                ["c:ModalBodyComponent_Footer", { createMassAction: false }]
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
                      cssClass: "padding-initial"
                    })
                    .then(function (overlay) {
                      c._overlay = overlay;
                    });
                }
              }
            );
          } else if (response.getReturnValue() === "No record type found") {
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
              entityApiName: "Task",
              defaultFieldValues: {
                WhoId: contactOrLeadId
              }
            });
            createRecordEvent.fire();
          }
        }
      });
      $A.enqueueAction(action);
    }

    //h.getPicklistValues(c, e, h);
  }

  /*getPicklistValues: function(component, event) {
        var action = component.get("c.getSubectDefaultValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    }*/
});