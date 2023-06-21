({
    doInitHelper: function (c, e, h) {
        try {
            var action = c.get('c.getCampaignDetails');
            action.setParams({
                'campSfId': c.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if ($A.util.isEmpty(response.getReturnValue())) {
                        return;
                    }
                    var responseObj = JSON.parse(response.getReturnValue());
                    c.set('v.CampaignDetails',responseObj);
                    if (responseObj.hasOwnProperty('synced')) {
                        c.set('v.CampaignSynced', responseObj.synced);
                    }
                    if (responseObj.hasOwnProperty('actionRequired')) {
                        c.set('v.ActionRequired', responseObj.actionRequired);
                    }
                    if (responseObj.hasOwnProperty('campMemberPresent')) {
                        c.set('v.CampMemberPresent', responseObj.campMemberPresent);
                    }
                    if (responseObj.hasOwnProperty('openTouchPointModal')) {
                        c.set('v.OpenTouchPointModal', responseObj.openTouchPointModal);
                    }
                    if (responseObj.hasOwnProperty('templateId')) {
                        c.set("v.templateValue", responseObj.templateId);
                    }
                    if (responseObj.hasOwnProperty('campMemList')) {
                        c.set("v.campMemList", responseObj.campMemList);
                    }
                    if (responseObj.hasOwnProperty('campMemberAmount')) {
                        c.set("v.campMemberAmount", responseObj.campMemberAmount);
                    }
                    if (responseObj.hasOwnProperty('CreatedDate')) {
                        var output = $A.localizationService.formatDate(responseObj.CreatedDate,"DD/MMM/YYYY");
                        c.set("v.CreatedDate", output);
                    }
                    if (!$A.util.isEmpty(c.get('v.templateValue'))) {
                        c.set('v.previewDisabled', false);
                        c.set("v.customizeDisabled", false);
                    } else {
                        c.set('v.previewDisabled', true);
                        c.set("v.customizeDisabled", true);
                    }
                    h.checkSendButton(c);
                    if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && c.get("v.CampaignSynced")) {
                        c.set("v.customizeDisabled", true);
                        c.set("v.templateDisabled", true);
                    } else if ($A.util.isEmpty(c.get('v.templateValue'))
                        && !c.get("v.CampaignSynced")) {
                        c.set("v.templateDisabled", false);
                    } else if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && !c.get("v.CampaignSynced")) {
                        c.set("v.templateDisabled", false);
                    }
                }
            });
            $A.enqueueAction(action);
            h.showTemplateName(c, e, h);
        } catch (error) {
        }
    },
    labelSelection: function (c) {
        try {
            var action = c.get('c.getCampaignData');
            action.setParams({
                recordId: c.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var camp = response.getReturnValue();
                    c.set('v.campaignType', camp.TelosTouchSF__Type__c);
                    if(camp.TelosTouchSF__Type__c == 'touchpoint'){
                        c.set('v.chooseLabel', $A.get("$Label.c.Choose_a_TouchPoint_Text"));
                        c.set('v.customizeAddClientLabel', $A.get("$Label.c.Customize_AddClientText"));
                        c.set('v.customizePreviewLabel', $A.get("$Label.c.Customize_PreviewLabel"));
                        c.set('v.newClientAddedLabel', $A.get("$Label.c.New_Client_Added_Text"));
                        c.set('v.selectedTouchPointLabel', $A.get("$Label.c.Selected_TouchPoint"));
                        c.set('v.sendTemplateCustomizeLabel', $A.get("$Label.c.SendTP_CustomizeText"));
                        c.set('v.startByChoosingLabel', $A.get("$Label.c.StartByChoosingTP"));
                        c.set('v.processRunningLabel', $A.get("$Label.c.TouchPoint_Process_Running_Text"));
                        c.set('v.sendLabel', $A.get("$Label.c.TPSentText"));
                        c.set('v.TTCampaignStatusLabel', $A.get("$Label.c.TT_Touchpoint_Status_Text"));
                    } else if(camp.TelosTouchSF__Type__c == 'email') {
                        c.set('v.chooseLabel', $A.get("$Label.c.Choose_a_Template"));
                        c.set('v.customizeAddClientLabel', $A.get("$Label.c.Customize_AddClient"));
                        c.set('v.customizePreviewLabel', $A.get("$Label.c.Customize_Preview_Email_Label"));
                        c.set('v.newClientAddedLabel', $A.get("$Label.c.New_Email_Client_Added_Text"));
                        c.set('v.selectedTouchPointLabel', $A.get("$Label.c.Selected_Template"));
                        c.set('v.sendTemplateCustomizeLabel', $A.get("$Label.c.SendTP_CustomizeText"));
                        c.set('v.startByChoosingLabel', $A.get("$Label.c.Start_By_Choosing_Email"));
                        c.set('v.processRunningLabel', $A.get("$Label.c.Email_Process_Running"));
                        c.set('v.sendLabel', $A.get("$Label.c.Email_Sent"));
                        c.set('v.TTCampaignStatusLabel', $A.get("$Label.c.TT_Email_Status"));
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },
    openSendTouchpointModal: function (c, e, h) {
        try {
            var action = c.get('c.getCampaignDetails');
            action.setParams({
                'campSfId': c.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var responseObj = JSON.parse(response.getReturnValue());
                    if (responseObj.synced && responseObj.openTouchPointModal) {
                        $A.createComponent("c:ModalBodyComponent", { sendTouchpoint: true },
                            function (content, status) {
                                if (status === "SUCCESS") {
                                    c.set('v.disableValue', true);
                                    c.find('overlayLib').showCustomModal({
                                        header: $A.get("$Label.c.Send_Touchpoint_Text"),
                                        body: content,
                                        showCloseButton: true,
                                        cssClass: "padding-initial"
                                    })
                                }
                            });
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.error(error);
        }
    },
    sendTouchpointHelper: function (c, e, h) {
        try {
            var action = c.get('c.getCampaignDetails');
            action.setParams({
                'campSfId': c.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var responseObj = JSON.parse(response.getReturnValue());
                    if (responseObj.synced && responseObj.actionRequired) {
                        if (responseObj.accessTokenPresent) {
                            h.addClientsToTouchpoint(c, e, h, responseObj.campMemList);
                        } else {
                            
                            h.showInfoToast(c, e, h, "Failure", 'error', $A.get("$Label.c.Failed_to_Send_Touchpoint"));
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },
    addClientsToTouchpoint: function (c, e, h, campMemList) {
        try {
            var action = c.get('c.addClientsToTouchpoint');
            action.setParams({
                'campMemListStr': JSON.stringify(campMemList)
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if (response.getReturnValue()) {
                        var message;
                        if(c.get('v.campaignType') == 'touchpoint'){
                            message = $A.get("$Label.c.Recipients_are_being_added_in_background");
                        } else if(c.get('v.campaignType') == 'email') {
                            message = $A.get("$Label.c.Email_Recipients_are_being_added_in_background");
                        }
                        h.showInfoToast(c, e, h, "Success", 'success', message);
                        h.doInitHelper(c, e, h);
                    } else {
                        h.showInfoToast(c, e, h, "Failure", 'error', $A.get("$Label.c.Failed_to_Send_Touchpoint"));
                    }
                } else {
                    h.showInfoToast(c, e, h, "Failure", 'error', $A.get("$Label.c.Failed_to_Send_Touchpoint"));
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }

    },
    showInfoToast: function (c, e, h, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    },
    fetchTouchPointTemplates: function (c, e, h) {
        try {
            var action = c.get('c.getTouchPointTemplates');
            action.setParams({
                campId: c.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    c.set('v.templateOptions', JSON.parse(response.getReturnValue()));
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },

    getCurrentTemplateId: function (c, e, h) {
        try {
            var action = c.get('c.getCurrentTemplateId');
            action.setParams({
                campaignRecordId: c.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() !== null && response.getReturnValue() !== undefined) {
                        c.set("v.templateValue", response.getReturnValue());
                        h.fetchTouchPointTemplates(c, e, h);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },
    checkSendButton: function (c) {

        let CampaignDetails = c.get('v.CampaignDetails');
        let templateInfo = c.get("v.templateInfo")

        if (!$A.util.isEmpty(c.get('v.templateValue'))
            && c.get("v.CampaignSynced")
            && CampaignDetails.hasOwnProperty('actionRequired')
            && !CampaignDetails.actionRequired) {
            c.set("v.sendDisabled", true);
        } else if (!$A.util.isEmpty(c.get('v.templateValue'))
            && c.get("v.CampaignSynced")
            && CampaignDetails.hasOwnProperty('actionRequired')
            && CampaignDetails.actionRequired
            && CampaignDetails.hasOwnProperty('openTouchPointModal')
            && !CampaignDetails.openTouchPointModal) {
            c.set("v.sendDisabled", true);
        } else if (!$A.util.isEmpty(c.get('v.templateValue'))
            && c.get("v.CampaignSynced")
            && CampaignDetails.hasOwnProperty('actionRequired')
            && CampaignDetails.actionRequired
            && CampaignDetails.hasOwnProperty('openTouchPointModal')
            && CampaignDetails.openTouchPointModal) {
            c.set("v.sendDisabled", false);
        } else if ($A.util.isEmpty(c.get('v.templateValue'))
            && !c.get("v.CampaignSynced")) {
            c.set("v.sendDisabled", true);
        } else if(templateInfo && templateInfo.status == 'DRAFTED'){
            c.set("v.sendDisabled", true);
        } else if (!$A.util.isEmpty(c.get('v.templateValue'))
            && !c.get("v.CampaignSynced")
            && CampaignDetails.hasOwnProperty('actionRequired')
            && !CampaignDetails.actionRequired
            && CampaignDetails.hasOwnProperty('campMemberPresent')
            && CampaignDetails.campMemberPresent) {
            c.set("v.sendDisabled", false);
        }
    },
    createTouchPointinTT_helper: function (c, e, h) {
        try {
            var action = c.get('c.sendTouchPointFromSF');
            action.setParams({
                campaignSFId: c.get('v.recordId'),
                touchPointTemplateId: c.get("v.templateValue"),
                isSynced: c.get("v.CampaignSynced")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() !== null && response.getReturnValue() !== undefined && response.getReturnValue() === 'success') {
                    }else{
                        h.showInfoToast(c, e, h, "Failure", 'error', $A.get("$Label.c.Failed_to_Send_Touchpoint"));
                        c.set("v.sendDisabled", false);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },
    getUserAccessToken: function (c, e, h) {
        try {

            var action = c.get("c.generateCustomizeIFrame");
            action.setParams({
                templateId: c.get("v.templateValue"),
                campaignId: c.get("v.recordId"),
                templateInfo: JSON.stringify(c.get("v.templateInfo"))
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if (!$A.util.isEmpty(storedResponse)) {

                        c.set("v.iFrameURL", storedResponse);
                        this.setInitialTemplateAmount(c);
                        $A.createComponent(
                            "c:ModalBodyComponent",
                            {
                                openCustomize: true,
                                iFrameURL: storedResponse,
                                isShowSpinner: true
                            },
                            function (content, status) {
                                if (status === "SUCCESS") {
                                    var title;
                                    if(c.get('v.campaignType') == 'touchpoint'){
                                        title = $A.get("$Label.c.Customize_Template_Text");
                                    } else if(c.get('v.campaignType') == 'email') {
                                        title = $A.get("$Label.c.Customize_Template");
                                    }
                                    c.find("overlayLib").showCustomModal({
                                        header: title,
                                        body: content,
                                        showCloseButton: true,
                                        cssClass: "customize-modal",
                                        closeCallback: function () {

                                            h.showTemplateName(c, e, h);

                                        }
                                    });
                                }
                            }
                        );
                    } else {
                    }
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },

    getTemplateAmount: function (c) {

        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = c.get('c.getTouchPointTemplates');
            action.setParams({
                recordId: c.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state == 'SUCCESS') {
                    if (!$A.util.isEmpty(result)) {
                        let lstTemplate = JSON.parse(result);
                        resolve(lstTemplate);
                    } else {
                        resolve(null);
                    }
                } else {
                    resolve(null);
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },

    setInitialTemplateAmount: function (c) {

        this.getTemplateAmount(c).then(function (result) {
            let initialAmount = result.length;
            c.set('v.initialTemplateAmount', initialAmount);
        })

    },

    replaceTemplateId: function (c, lstTemplates) {
        try {

            let lastestDate, templateId;
            for (let i = 0; i < lstTemplates.length; i++) {
                if (lstTemplates[i].isPrivate === 'true' && (!lastestDate || lastestDate.localeCompare(lstTemplates[i].createdDate) == -1)) {
                    lastestDate = lstTemplates[i].createdDate;
                    templateId = lstTemplates[i].value;
                }
            }

            c.set("v.templateNamePresent", true);
            c.set('v.recordFields.TelosTouchSF__TouchPoint_Template_Id__c', templateId);
            c.find("recordHandler").saveRecord($A.getCallback(function (saveResult) {
            }));
            c.set('v.templateValue', templateId);
            $A.get('e.force:refreshView').fire();
        } catch (error) {

        }
    },

    showTemplateName: function (c, e, h) {
        try {
            var action = c.get('c.fetchSelectedTouchPointTemplate');
            action.setParams({
                'recordId': c.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if($A.util.isEmpty(response.getReturnValue())){ 
                        c.set("v.templateNamePresent", false);
                        c.set("v.templateName", undefined);
                        return null; 
                    }
                    let result = JSON.parse(response.getReturnValue());
                    let templateInfo = {
                        created_by : result.created_by,
                        status : result.status
                    };
                    if($A.get("$Locale.language") == 'en'){
                        if(result.type){
                            c.set("v.templateName", result.name);
                        } else {
                            c.set("v.templateName", result.content.name);
                        }
                    } else if($A.get("$Locale.language") == 'fr'){
                        if(result.type){
                            c.set("v.templateName", result.name_fr);
                        } else {
                            c.set("v.templateName", result.content.name_fr);
                        }
                    }
                    c.set("v.templateInfo", templateInfo);
                    c.set("v.templateNamePresent", true);
                    h.checkSendButton(c);
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    },

    checkAllCM: function(c,e,h){
        try {
            var action = c.get('c.syncClientsBeforeTouchpoint');
            action.setParams({
                'campaignId': c.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    // console.log('ran');
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            // console.log('error is:'+ error.message);
        }
    } 
})