({
  doInit: function (component, event, helper) {
    /*document.getElementsByClassName('modal-glass slds-backdrop fadein slds-backdrop--open').addEventListener('click', $A.getCallback(function(){
            if(c.isValid()) {
                console.log('Clicked');
            }
        }));*/
  },
  closeCreateCampaignModel: function (component, event, helper) {
    component.find("overlayLib").notifyClose();
    //console.log(JSON.stringify(component.get("v.userList")));
  },
  itemValue: function (c, e, h) {
    var select = e.currentTarget.name;
    //c.set('v.newTask.Subject',select);
    //var select =(e.currentTarget.dataset.id );
    var select = e.currentTarget.id;
    c.set("v.newTask.Subject", select);
    c.set("v.SubjectListItems", false);
  },
  //Send Touch Point Modal 2 Appears WHen we enter campaign name and send to tt
  submitCreateCampaignDetails: function (c, e, h) {
    let campId = e.getParam("id");
    let action = c.get("c.addClientsToCampaign");
    action.setParams({
      campRecordId: campId,
      userListStr: JSON.stringify(c.get("v.userList"))
    });
    action.setCallback(this, (response) => {
      if (response.getState() === "SUCCESS") {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: response.getReturnValue()
        });
        navEvt.fire();
      } else {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: campId
        });
        navEvt.fire();
      }
    });
    $A.enqueueAction(action);
  },
  selectCampaignRecordType: function (c, e, h) {
    console.log("Record Type Id:: " + c.get("v.recordTypeId"));
    c.set("v.createCampaign", true);
    c.set("v.selectCampaignRecordType", false);
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
  showpList: function (c, e, h) {
    c.set("v.SubjectListItems", true);
    var newTaskSubject = e.getSource().get("v.value");
    if (!$A.util.isEmpty(newTaskSubject)) {
      c.set("v.SubjectListItems", false);
    }
  },
  CloseModal: function (component, event, helper) {
    component.find("overlayLib").notifyClose();
  },

  onEventHandle_Save: function (c, e, h) {
    var eventMessage = e.getParam("isCreateTask");
    //console.log(eventMessage);
    var contactOrLeadId = c.get("v.contactOrLeadId");
    if (eventMessage == true && c.get("v.recordTypeId") != null) {
      //h.SaveCreateAction(c,e,h);
      var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
        entityApiName: "Task",
        recordTypeId: c.get("v.recordTypeId"),
        defaultFieldValues: {
          WhoId: contactOrLeadId
        }
      });
      createRecordEvent.fire();
    } else if (
      e.getParam("isCreateMassTask") &&
      c.get("v.recordTypeId") != null
    ) {
      var recordTypeOptions = c.get("v.recordTypeOptions");
      var recordTypeId = c.get("v.recordTypeId");
      var recordTypeName = "";
      for (let x of recordTypeOptions) {
        if (x.value === recordTypeId) {
          recordTypeName = x.label;
        }
      }
      $A.createComponents(
        [
          [
            "c:massCreateTaskComp",
            {
              recordTypeId: recordTypeId,
              recordTypeName: recordTypeName,
              userList: c.get("v.userList"),
              recordId: c.get("v.recordId")
            }
          ],
          ["c:lwcModalFooter", {}]
        ],
        function (content, status) {
          if (status === "SUCCESS") {
            c.find("overlayLib2")
              .showCustomModal({
                header: $A.get("$Label.c.Create_Task_Text"),
                body: content[0],
                footer: content[1],
                showCloseButton: true,
                cssClass: "taskModal slds-modal_medium"
              })
              .then(function (overlay) {
                c._overlay = overlay;
              });
          }
        }
      );
    }
  },
  sendTouchpoint: function (c, e, h) {
    var myEvent = $A.get("e.c:ModalCloseEvent");
    myEvent.setParams({ SendTouchpoint: true });
    myEvent.fire();
    c.find("overlayLib").notifyClose();
  }
});
