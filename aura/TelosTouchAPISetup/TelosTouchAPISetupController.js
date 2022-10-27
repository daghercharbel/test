({
    doInit: function (c, e, h) {
        c.set("v.selectedUserList", []);
        c.set("v.columns", [
            {
                label: $A.get("$Label.c.User_Name_Text"),
                fieldName: "Username",
                type: "text"
            },
            {
                label: $A.get("$Label.c.Profile_Text"),
                fieldName: "Profile",
                type: "text"
            },
            {
                label: $A.get("$Label.c.Email_Text"),
                fieldName: "Email",
                type: "text"
            },
            {
                label: $A.get("$Label.c.TT_user_Text"),
                fieldName: "TTUser",
                type: "text",
                disabled: { fieldName: "isDisable" }
            }
        ]);
        var setting = {};
        setting.Access_Token = null;
        setting.Approval = null;
        setting.Client_ID = null;
        setting.Client_Secret = null;
        setting.Instance_URL = null;
        setting.Refresh_Token = null;
        setting.Admin_Username = null;
        setting.Admin_Password = null;
        setting.Authentication_URL = null;
        
        c.set("v.setting", setting);
        
        h.doInit_Helper(c, e, h, "false");
        h.checkEnterpriseClient(c, e, h);
    },
    scriptLoaded: function (c, e, h) {
        h.checkPostIntallBatch(c, e, h);
    },
    updateAndAddUsers: function (c, e, h) {
        c.set("v.afterSaveCredentials", true);
        if (c.get("v.setting.Approval")) {
            h.getUsersListHelper(c, e, h);
        }
    },
    //The Refresh Token is clicked 
    refreshToken: function (c, e, h) {
        if (c.get("v.setting.Approval")) {
            h.refreshTokenHelper(c, e, h);
        }
    },
    saveSettings: function (c, e, h) {
        var settingsObj = c.get("v.setting");
        if (settingsObj.Client_Secret != undefined) {
            settingsObj.Client_Secret = settingsObj.Client_Secret.trim();
        }
        if (settingsObj.Client_ID != undefined) {
            settingsObj.Client_ID = settingsObj.Client_ID.trim();
        }
        if (settingsObj.Instance_URL != undefined) {
            settingsObj.Instance_URL = settingsObj.Instance_URL.trim();
        }
        c.set("v.setting", settingsObj);
        var allValid = c.find("formId").reduce(function (validFields, inputCmp) {
            var result = inputCmp.get("v.value");
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get("v.validity").valid;
        }, true);
        if (allValid) {
            h.saveCredSettings_Helper(c, e, h);
        }
    },
    cancelSettings: function (c, e, h) {
        h.doInit_Helper(c, e, h, "true");
        c.set("v.isEdit", false);
    },
    cancelUserModal: function (c, e, h) {
        c.set("v.selectedUserList", []);
        c.set("v.afterSaveCredentials", false);
        c.set("v.showSearchBar", false);
        c.set("v.fromEntries", "1");
    },
    editSettings: function (c, e, h) {
        c.set("v.isEdit", true);
    },
    
    updateSelectedText: function (c, e) {
        var selectedRows = e.getParam("selectedRows");
        c.set("v.selectedUserList", selectedRows);
    },
    SendSFUserToTT: function (c, e, h) {
        var selectedRows = c.get("v.selectedUserList");
        var listofUserId = [];
        for (var i = 0; i < selectedRows.length; i++) {
            delete selectedRows[i].TTUser;
            delete selectedRows[i].isDisable;
            selectedRows[i].sobjectType = "User";
            listofUserId.push(selectedRows[i].Id);
        }
        h.SendSFUserToTT_Helper(c, e, h, selectedRows, listofUserId);
    },
    goToPreviousPage: function (c, e, h) {
        h.changePage(c, e, h, (parseInt(c.get("v.currentPage")) - 1).toString());
    },
    goToNextPage: function (c, e, h) {
        h.changePage(c, e, h, (parseInt(c.get("v.currentPage")) + 1).toString());
    },
    checkboxSelect: function (component, event, helper) {
        // on each checkbox selection update the selected record count
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
        var allRecords = component.get("v.filteredRecords");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].selected == true) {
                selectedRecords.push(allRecords[i]);
            }
        }
        component.set("v.selectedUserList", selectedRecords);
    },
    displaySearch: function (c, e, h) {
        c.set("v.showSearchBar", true);
    },
    hideSearch: function (c, e, h) {
        c.set("v.showSearchBar", false);
        if (c.get("v.setting.Approval")) {
            h.getUsersListHelper(c, e, h);
        }
    },
    searchUsers: function (c, e, h) {
        var searchFilter = c.get("v.searchKey");
        var isEnterKey = e.keyCode === 13;
        if (
            isEnterKey ||
            $A.util.isEmpty(document.getElementById("search").value) ||
            document.getElementById("search").value.length > 2
        ) {
            h.searchUsersHelper(c, e, h);
        }
    },
    toggleAdvancedOptions: function (c, e, h) {
        c.set("v.showAdvancedOptions", !c.get("v.showAdvancedOptions"));
    },
    resendRegistrationRequest: function(c, e, h) {
        c.set("v.resendBtnDisabled", true);
        c.set("v.isShowSpinner",true);
        h.resendRegistrationRequest_helper(c, e, h);
    }
})