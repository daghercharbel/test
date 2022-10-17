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
                    //console.log(responseObj);
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
                    //console.log(c.get('v.templateValue'));
                    //console.log($A.util.isEmpty(c.get('v.templateValue')));
                    if (!$A.util.isEmpty(c.get('v.templateValue'))) {
                        //console.log('if');
                        c.set('v.previewDisabled', false);
                        c.set("v.customizeDisabled", false);
                    } else {
                        //console.log('else');
                        c.set('v.previewDisabled', true);
                        c.set("v.customizeDisabled", true);
                    }
                    if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && c.get("v.CampaignSynced")
                        && responseObj.hasOwnProperty('actionRequired')
                        && !responseObj.actionRequired) {
                        c.set("v.sendDisabled", true);
                    } else if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && c.get("v.CampaignSynced")
                        && responseObj.hasOwnProperty('actionRequired')
                        && responseObj.actionRequired
                        && responseObj.hasOwnProperty('openTouchPointModal')
                        && !responseObj.openTouchPointModal) {
                        c.set("v.sendDisabled", true);
                    } else if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && c.get("v.CampaignSynced")
                        && responseObj.hasOwnProperty('actionRequired')
                        && responseObj.actionRequired
                        && responseObj.hasOwnProperty('openTouchPointModal')
                        && responseObj.openTouchPointModal) {
                        c.set("v.sendDisabled", false);
                    } else if ($A.util.isEmpty(c.get('v.templateValue'))
                        && !c.get("v.CampaignSynced")) {
                        c.set("v.sendDisabled", true);
                    } else if (!$A.util.isEmpty(c.get('v.templateValue'))
                        && !c.get("v.CampaignSynced")
                        && responseObj.hasOwnProperty('actionRequired')
                        && !responseObj.actionRequired
                        && responseObj.hasOwnProperty('campMemberPresent')
                        && responseObj.campMemberPresent) {
                        c.set("v.sendDisabled", false);
                    }
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
            // h.getCurrentTemplateId(c, e, h);
            h.showTemplateName(c, e, h);
            // h.getUserAccessToken(c, e, h);
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
            // console.log(error);
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
                            h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
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
                        h.showInfoToast(c, e, h, "Success", 'success', $A.get("$Label.c.Recipients_are_being_added_in_background"));
                        h.doInitHelper(c, e, h);
                    } else {
                        h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
                    }
                } else {
                    h.showInfoToast(c, e, h, "Failure", 'error', 'Failed to Send Touchpoint');
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
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if (!$A.util.isEmpty(storedResponse)){
                       
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
                                    // console.log('success');
                                    c.find("overlayLib").showCustomModal({
                                        header: $A.get("$Label.c.Customize_Template_Text"),
                                        body: content,
                                        showCloseButton: true,
                                        cssClass: "customize-modal",
                                        closeCallback: function () {

                                            let initialAmount = c.get('v.initialTemplateAmount');

                                            h.getTemplateAmount(c).then(function (result) {

                                                let currentAmount = result.length;

                                                if (!isNaN(initialAmount) && !isNaN(currentAmount) && initialAmount < currentAmount) {
                                                    h.replaceTemplateId(c, result);
                                                }

                                            });

                                        }
                                    });
                                }
                            }
                        );
                    } else {
                        //show error toast for not having the template Id
                        // console.log('no template Id');
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
                    //console.log('response: '+ response.getReturnValue());
                    c.set("v.templateName", response.getReturnValue());
                    if (!$A.util.isEmpty(response.getReturnValue())) {
                        c.set("v.templateNamePresent", true);
                    } else {
                        c.set("v.templateNamePresent", false);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
        }
    }
})