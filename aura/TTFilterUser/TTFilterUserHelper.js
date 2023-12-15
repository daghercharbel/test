({
    doInit_helper: function (c, e, h) {
        try {
            if(c.get('v.showCreateSingleActions')){
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
            }else{
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
                    }
                ]);
            }
            
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
        }
    },

    checkClientTagging: function (c) {

        var action = c.get("c.isClientTaggingEnabled");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (!$A.util.isEmpty(response.getReturnValue())) {
                    c.set("v.showClientTaggingBtn", response.getReturnValue());
                } else {
                    console.error(response.getError());
                    this.showSuccess(c, null, null, $A.get("$Label.c.ERROR_Text"), "error", response.getError());
                }
            }
        });

        $A.enqueueAction(action);
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
                if (
                    !$A.util.isEmpty(rtnValue) &&
                    rtnValue != null &&
                    state == "SUCCESS"
                ) { 
                    c.set("v.fielterDetails", rtnValue.ttFilterWrapperObj);
                    c.set("v.data", rtnValue.userWrapperList);
                    c.set("v.selectAllDropDown", ($A.get("$Label.c.Select_All")+' '+c.get("v.data").length));
                    c.set("v.totalRecords", c.get("v.data").length);
                    if(c.get("v.data")){
                        c.set("v.disableSelectAllList", false);
                        c.set("v.disableSelectAllDropDown", false);
                    }else{
                        c.set("v.disableSelectAllList", true);
                        c.set("v.disableSelectAllDropDown", true);
                    }
                    h.updateCheckedData(c,e,h,c.get("v.data"));
                }else{
                    c.set("v.disableSelectAllList", true);
                    c.set("v.disableSelectAllDropDown", true);
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },

    handleCampaignData: function (c) {

        var action = c.get("c.getCampaignData");
        action.setParams({
            recordId: c.get("v.recordId")
        });

        action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
				var result = response.getReturnValue();
                c.set("v.campaignData", result);
                let isTouchpoint = (result.TelosTouchSF__Type__c == 'touchpoint' || result.TelosTouchSF__Type__c == null);
                c.set("v.isTouchpoint", isTouchpoint);
			} else {
				var errors = response.getError();
				if(!$A.util.isEmpty(errors)) {
					for(var i = 0; i < errors.length; i++) {
						console.error(errors[i].message);
					}
				} else {
                    console.error(errors);
                }
			}
            this.allowSyncCountdown(c);
		});

		$A.enqueueAction(action);
    },

    allowSyncCountdown: function (c) {
        var campaignData = c.get("v.campaignData");
        var lastSyncTime = campaignData.TelosTouchSF__TT_Last_Sync_Time__c;

        if($A.util.isEmpty(campaignData.TelosTouchSF__TT_Campaign_Id__c)){
            c.set("v.disableCampaignSync", true);
            c.set("v.syncLabel", $A.get("$Label.c.Sync_Campaign_Button"));
            return;
        } else if(lastSyncTime == undefined){
            c.set("v.disableCampaignSync", false);
            c.set("v.syncLabel", $A.get("$Label.c.Sync_Campaign_Button"));
            return;
        }

        if(!$A.util.isEmpty(c._TTintervalID)){ return; }

        function tick(){
            var now = new Date();
            var diff = now.getTime() - Date.parse(lastSyncTime);
            diff = diff/1000;

            if(diff >= 120){
                c.set("v.disableCampaignSync", false);
                c.set("v.syncLabel", $A.get("$Label.c.Sync_Campaign_Button"));
                window.clearInterval(c._TTintervalID);
                c._TTintervalID = null;
            } else {
                c.set("v.disableCampaignSync", true);
                var totalseconds = 120 - diff;
                var seconds=Math.floor(totalseconds%60);
                var minutes=Math.floor( (totalseconds%3600)/60);
                var  countdown='';
                countdown+=(minutes>=10?minutes:'0'+minutes);
                countdown+=':';
                countdown+=(seconds>=10?seconds:'0'+seconds);
                c.set("v.syncLabel", countdown);
            }

        }
        var tickBack=$A.getCallback(tick);
        c._TTintervalID= window.setInterval(tickBack, 1000);
    },

    requestCampaignSync: function (c) {

        c.set("v.isShowSpinner", true);
        var action = c.get("c.requestSync");
        action.setParams({
            recordId: c.get("v.recordId")
        });

        action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
                var campaignData = c.get("v.campaignData");
                campaignData.TelosTouchSF__TT_Last_Sync_Time__c = new Date();
                c.set("v.campaignData", campaignData);
			} else {
				var errors = response.getError();
				if(!$A.util.isEmpty(errors)) {
					for(var i = 0; i < errors.length; i++) {
						console.error(errors[i].message);
					}
				} else {
                    console.error(errors);
                }
			}
            this.allowSyncCountdown(c);
            c.set("v.isShowSpinner", false);
		});

		$A.enqueueAction(action);
    },

    fielterEvent_helper: function (c, e, h, isFormType) {
        try {
            c.set("v.isShowSpinner", true);
            var action = c.get("c.getUserDetails");
            action.setParams({
                campainId: c.get("v.recordId"),
                filterWrapper: JSON.stringify(c.get("v.fielterDetails")),
                isFormType: isFormType
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner", false);
                var state = response.getState();
                var rtnValue = response.getReturnValue();
                if (rtnValue != null && state == "SUCCESS") {
                    c.set("v.data", rtnValue);
                    c.set("v.selectAllDropDown", ("Select All "+c.get("v.data").length));
                    c.set("v.totalRecords", c.get("v.data").length);
                    c.set("v.userList", []);
                    c.set("v.countSelectedRecords", c.get("v.userList").length);
                    c.set("v.isDisableSendTouchPointBtn", c.get("v.userList").length >0 ? false : true);
                    c.set("v.selectAllList", false);
                    for(let x of c.get("v.storeCheckedValues")){
                        x.isChecked = false;
                    }
                    c.set("v.storeCheckedValues",[]);
                    if(c.get("v.updateSelectAll")){
                        var menuItems = c.find("menuItems");
                        menuItems.set("v.checked", h.handleSelectDropDownValue(c,e,h));
                    }
                    if(c.get("v.data").length !=0 ){
                        c.set("v.disableSelectAllList", false);
                        c.set("v.disableSelectAllDropDown", false);
                    }else{
                        c.set("v.disableSelectAllList", true);
                        c.set("v.disableSelectAllDropDown", true);
                    }
                    h.updateCheckedData(c,e,h,c.get("v.data"));
                }else{
                    c.set("v.disableSelectAllList", true);
                    c.set("v.disableSelectAllDropDown", true);
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
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
                } else {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        $A.get("$Label.c.ERROR_Text"),
                        "error",
                        $A.get("$Label.c.Reminder_Not_Sent_Toast")
                    );
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
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

    handleInsightCallout: function(c, recordId){

        c.set("v.isShowSpinner", true);
        var action = c.get("c.insightCallout");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if(state == 'SUCCESS'){
                this.viewRecord_helper(c, undefined, this, recordId);
            } else {
                c.set("v.isShowSpinner", false);
            }
        });
        $A.enqueueAction(action);

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
                if (rtnValue != null && state == "SUCCESS") {
                    let insight = JSON.parse(rtnValue.insight);
                    let answers = JSON.parse(rtnValue.answers);
                    c.set("v.answers", insight);
                    $A.createComponents(
                        [
                            [
                                "aura:unescapedHtml",
                                {
                                    value: insight.TouchPointName + "<br/>" + insight.Name
                                }
                            ],
                            [
                                "c:ModalBodyComponent",
                                {
                                    showAnswerModal: true,
                                    touchpoint: insight,
                                    answers: answers
                                }
                            ]
                        ],
                        function (components, status) {
                            if (status === "SUCCESS") {
                                c.find("overlayLib")
                                .showCustomModal({
                                    header: components[0],
                                    body: components[1],
                                    showCloseButton: true,
                                    cssClass: "mymodal"
                                })
                                .then(function (overlay) {});
                            }
                        }
                    );
                } else {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        $A.get("$Label.c.Warning"),
                        "warning",
                        $A.get("$Label.c.InsightAnswersEmpty")
                    );
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
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
                    window.location.reload();
                    c.set("v.createAction", false);
                    var result = response.getReturnValue();
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
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
    },

    preparePaginationList: function(c,e,h) {
        try{
            if(c.get("v.pageNo") <= c.get("v.totalPages") && c.get("v.pageNo") != 1){
                c.set("v.preDisable",false);
            }
            if(c.get("v.pageNo") == 1){
                c.set("v.preDisable", true);
            }
            if(c.get("v.totalPages") == c.get("v.pageNo")){
                c.set("v.nextDisable", true);
            }else{
                c.set("v.nextDisable", false);
            }
            
            let pgNo = c.get("v.pageNo");
            let begin = (pgNo - 1) * parseInt(c.get("v.recordPerPage"));
            let end = parseInt(begin) + parseInt(c.get("v.recordPerPage"));
            let slicingList = c.get("v.data").slice(begin, end);
            c.set("v.listData", slicingList);
            let listDataSize = c.get("v.listData");
            if(listDataSize.length == 0){
                c.set("v.preDisable", true);
                c.set("v.nextDisable", true);
                let totPage = 1;
                c.set("v.totalPages", totPage);
                c.set("v.pageNo", totPage);
            }
            let startRec = begin + parseInt(1);
            c.set("v.startRecord",startRec);
            let endRec = end > c.get("v.data").length ? c.get("v.data").length : end;
            c.set("v.endRecord", endRec);
            let finalEnd = end > c.get("v.data").length ? true : false;
            c.set("v.end", finalEnd);
        }catch(error){
        } 
    },
    getSelectedClientsRecords: function (c, e, h, updatedList) {
        if (updatedList.length > 0 && updatedList != undefined) {
            let tempFinalList = c.get("v.userList");
            for(let i=0; i<updatedList.length; i++){
                const isFound = tempFinalList.some(element => {
                    if (element.Id === updatedList[i].Id) {
                      return true;
                    }
                    return false;
                  });
                if(updatedList[i].isChecked == true && !isFound){
                    tempFinalList.push(updatedList[i]);
                }
            }
            for(let i=0;i<tempFinalList.length; i++){
                if(tempFinalList[i].isChecked == false){
                    tempFinalList.splice(i, 1);
                }else{
                    for(let x of updatedList){
                        if(x.Id == tempFinalList[i].Id && x.isChecked == false){
                            tempFinalList.splice(i,1);
                        }
                    }
                }
            }   
            for(let x of tempFinalList){
                for(let y of c.get("v.storeCheckedValues")){
                    if(x.Id == y.Id){
                        x.Id = y.Id;
                    }
                }
            }       
            c.set("v.storeCheckedValues", tempFinalList);

            c.set("v.userList", tempFinalList);
            c.set("v.countSelectedRecords", c.get("v.userList").length);
            c.set("v.showUnselectAndCount", c.get("v.countSelectedRecords") > 0 ? true : false);
            if(c.get("v.userList").length >0 ){
                c.set("v.isDisableSendTouchPointBtn", false);
            }else{
                c.set("v.isDisableSendTouchPointBtn", true);
            }
        } else {
           c.set("v.isDisableSendTouchPointBtn", true);

        }
    },
    getSelectedAllClientsRecords: function(c,e,h,updatedList){
        if (updatedList.length > 0 && updatedList != undefined) {
          let count = c.get("v.countSelectAll");
          let tempFinalList = c.get("v.userList");
          let temp = [];
          for(let i=0; i<updatedList.length; i++){
              const isFound = tempFinalList.some(element => {
                  if (element.Id === updatedList[i].Id) {
                    return true;
                  }
                  return false;
                });
              if(updatedList[i].isChecked == true && !isFound){
                  tempFinalList.push(updatedList[i]); 
                  count++;
              }
              else if(updatedList[i].isChecked == false){
                      for( let x of tempFinalList){
                          if(x.Id == updatedList[i].Id){
                              x.isChecked = updatedList[i].isChecked;
                          }
                      }
              }
          }
          for ( let k in tempFinalList){
              if(tempFinalList[k].isChecked ){
                  temp.push(tempFinalList[k])
              }
          }        
          for(let x of temp){
              for(let y of c.get("v.storeCheckedValues")){
                  if(x.Id == y.Id){
                      x.isChecked = y.isChecked;
                  }
              }
          } 
          c.set("v.storeCheckedValues", temp);
          c.set("v.userList", temp);
          c.set("v.countSelectedRecords", c.get("v.userList").length);
          c.set("v.showUnselectAndCount", c.get("v.countSelectedRecords") > 0 ? true : false);
          if(c.get("v.userList").length >0 ){
              c.set("v.isDisableSendTouchPointBtn", false);
          }else{
              c.set("v.isDisableSendTouchPointBtn", true);
          }
      } else {
         c.set("v.isDisableSendTouchPointBtn", true);
      }
      h.onOffSelectAll(c,e,h);
    },
    onOffSelectAll: function(c,e,h){
        let count = c.get("v.countSelectAll");
        let tempList = c.get("v.listData");
        let flag = 0;
        for(let x of tempList){
          x.isChecked? flag = 0 : flag =1;
        }
        try {
          if(flag == 0){
          c.set("v.selectAllList", true);
          }
          else{
          c.set("v.selectAllList", false);
          }
          c.set("v.countSelectAll", count);
        } catch (error) {
            console.log(error);
        }
    },
    updateCheckedData: function(c,e,h,mainList){
        if(mainList.length>0){
            for(let x of mainList){
                for(let y of c.get("v.storeCheckedValues")){
                    if(x.Id == y.Id){
                        x.isChecked = y.isChecked;
                    }
                }
            }
            c.set("v.data", mainList);
            c.set("v.selectAllDropDown", ("Select All "+c.get("v.data").length));
            c.set("v.totalRecords", c.get("v.data").length);
            let totPage = Math.ceil(c.get("v.data").length / c.get("v.recordPerPage"));
            c.set("v.totalPages", totPage);
            let pgno = 1;
            c.set("v.pageNo",pgno);
            if(c.get("v.pageNo") == 1){
                c.set("v.preDisable",true);
            }
            h.preparePaginationList(c,e,h);
            let flag = 0;
            if(c.get("v.listData").length >0){
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
            }else{
                c.set("v.selectAllList", false);
                c.set("v.disableSelectAllList", true);
                c.set("v.disableSelectAllDropDown", true);
            }
            
        }else{
            c.set("v.selectAllList", false);
            c.set("v.data", mainList);
            c.set("v.selectAllDropDown", ("Select All "+c.get("v.data").length));
            c.set("v.totalRecords", c.get("v.data").length);
            let totPage = Math.ceil(c.get("v.data").length / c.get("v.recordPerPage"));
            c.set("v.totalPages", totPage);
            if(c.get("v.pageNo") == 1){
                c.set("v.preDisable",true);
            }
            h.preparePaginationList(c,e,h);
        }
      },
      checkIsSyncCampaign: function(c,e,h){
        var action = c.get("c.isCampaignSyncEnabled");
        action.setCallback(this, function (response) {
            var state = response.getState();
            var rtnValue = response.getReturnValue();
            if (!$A.util.isEmpty(rtnValue) &&
                rtnValue != null &&
                state == "SUCCESS") {
                let resp = JSON.parse(rtnValue.value);
                c.set("v.showSyncCampaign", resp.TelosTouchSF__SF_Flag__c);
            }
        });
        $A.enqueueAction(action);
      }
});