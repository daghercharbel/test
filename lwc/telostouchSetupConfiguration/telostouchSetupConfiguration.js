import { LightningElement, wire, track, api } from "lwc";
import FORM_FACTOR from '@salesforce/client/formFactor';
import currentUserId from '@salesforce/user/Id';
import { handleRequest } from 'c/ttCallout';
import { labelLibrary } from 'c/ttLabels';
//Apex Methods
import abortScheduleJob from "@salesforce/apex/TelosTouchUtility.abortScheduleJob";
import checkIfEnterpriseClient from "@salesforce/apex/TelosTouchUtility.checkIfEnterpriseClient";
import getAdminAccessToken from "@salesforce/apex/TelosTouchUtility.getAdminAccessToken";
import getSettingAPI from "@salesforce/apex/TelosTouchUtility.getSettingAPI";
import getUserList from "@salesforce/apex/TelosTouchUtility.getUserList";
import refreshTokenController from "@salesforce/apex/TelosTouchUtility.refreshTokenController";
import revokeUserAccess from "@salesforce/apex/TelosTouchUtility.revokeUserAccess";
import sendRegistrationRequest from '@salesforce/apex/TelosTouchUtility.sendRegistrationRequest';
import sendSFUserToTT from "@salesforce/apex/TelosTouchUtility.sendSFUserToTT";
import updateTTUser from "@salesforce/apex/TelosTouchUtility.updateTTUser";

export default class telosTouchSetupConfiguration extends LightningElement {

    label = labelLibrary;
    @api afterSaveCredentials = false;
    @api isApproved = false;
    @track allRecords;
    @track conditionUpdateAndAddUsers;
    @track currentPage;
    @track currentPageEqualTtotalPages;
    @track currentPageLessEqual1;
    currentUserId = currentUserId;
    @track filteredRecords;
    @track filteredRecordsSize;
    @track fromEntries;
    @track isAuthURLNotValid = false;
    @track isDisSave = true;
    @track isEdit = false;
    @track isEditAndnotsettingApproval = true;
    @track isEmptySelectedUserList = true;
    @track isInsURLNotValid = false;
    @track isNotEdit = true;
    @track isNotPhoneAndNotEntrepriseClient;
    @track isPhone = false;
    @track isPhoneAndNotEntrepriseClient;
    isShowSpinner = true;
    @track isSmallDevice = false;
    @track isTablet = false;
    @track ListID = [];
    @track listofUserId = [];
    @track ltngTimer;
    modalCloseTimeout;
    @track notEnterpriseClient;
    @track resendBtnDisabled = true;
    revokeCurrentUser = false;
    @track searchValue = '';
    selectedRole = 'professional';
    @track selectedRows;
    @track selectedUserList;
    @track setting;
    @track settingAPIList;
    @track settingApproval;
    @track setting_Authentication_URL;
    @track setting_Client_ID;
    @track setting_Client_Secret;
    @track setting_Instance_URL;
    @track showAdvancedOptions;
    @track showContactMessage = false;
    @track showEntries = '100';
    @track showRegistrationMessage;
    showRoleModal = false;
    @track showSearchBar;
    @track showToast = false;
    @track storedResponse;
    @track toEntries;
    @track totalPages;
    @track roleOptions = [];
    userGrantAccessModal = false;
    userIdForGrantAccess
    userIdForRestriction;
    userRevokeAccessModal = false;
    @track waitingTimeId = null;
    isEditDisabled = false;
    @api listdata;

    // OnLoad
    connectedCallback() {
        if (FORM_FACTOR === 'Medium' || FORM_FACTOR === 'Small') {
            this.isSmallDevice = true;
        }
        if (FORM_FACTOR === 'Medium') {
            this.isTablet = true;
        }
        if (FORM_FACTOR === 'Small') {
            this.isPhone = true;
        }
        // this.doInit_Helper();
        this.callcheckIfEnterpriseClient();
        this.getAllRoles();
    }

    // call getSettingAPI and fetch the setting parameters
    doInit_Helper() {
        getSettingAPI({ isCallingFrom: 'DoinitFromSetup' })
            .then((result) => {
                this.storedResponse = result;
                if (this.storedResponse != null && this.storedResponse.adminCredentials.Client_ID != null && this.storedResponse.adminCredentials.Client_Secret != null && this.storedResponse.adminCredentials.Instance_URL != null) {
                    if (this.storedResponse.adminCredentials != null) {
                        this.setting = this.storedResponse.adminCredentials;
                        if (this.setting.Approval) {
                            const approvalEvt = new CustomEvent('approvalevent', { detail: this.setting.Approval });
                            this.dispatchEvent(approvalEvt);
                        }
                        if (this.setting.Approval == false || this.setting.Approval == null) {
                            this.isEditAndnotsettingApproval = true;
                            this.settingApproval = false;
                        } else {
                            this.isEditAndnotsettingApproval = false;
                            this.settingApproval = true;
                        }
                        this.setting_Client_ID = this.setting.Client_ID;
                        this.setting_Client_Secret = this.setting.Client_Secret;
                        this.setting_Instance_URL = this.setting.Instance_URL;
                        this.setting_Authentication_URL = this.setting.Authentication_URL;
                        this.isEveryInputValid();
                    }
                } else {
                    this.displayToast('warning', 'Please enter TelosTouch credentials to configure TelosTouch Package.');
                    var settingVar = {};
                    settingVar.Access_Token = null;
                    settingVar.Approval = null;
                    settingVar.Client_ID = null;
                    settingVar.Client_Secret = null;
                    settingVar.Instance_URL = this.storedResponse.adminCredentials.Instance_URL;
                    settingVar.Refresh_Token = null;
                    settingVar.Admin_Username = null;
                    settingVar.Admin_Password = null;
                    settingVar.Authentication_URL = this.storedResponse.adminCredentials.Authentication_URL;

                    this.setting = settingVar;
                    if (this.setting.Approval == false || this.setting.Approval == null) {
                        this.settingApproval = false;
                        this.isEditAndnotsettingApproval = true;
                    } else {
                        this.isEditAndnotsettingApproval = false;
                        this.settingApproval = true;
                    }
                    this.setting_Client_ID = this.setting.Client_ID;
                    this.setting_Client_Secret = this.setting.Client_Secret;
                    this.setting_Instance_URL = this.setting.Instance_URL;
                    this.setting_Authentication_URL = this.setting.Authentication_URL;
                    if (this.storedResponse.adminCredentials.Registration_Successful != null && this.storedResponse.adminCredentials.Registration_Request_Expiry != null
                        && this.storedResponse.adminCredentials.Registration_Request_Expiry != null && this.storedResponse.adminCredentials.Registration_DateTime != null
                        && this.storedResponse.adminCredentials.Registration_DateTime != null) {
                        if (this.storedResponse.adminCredentials.Registration_Request_Expiry == 0) {
                            this.showContactMessage = true;
                            this.showRegistrationMessage = false;
                            return;
                        }
                        this.showRegistrationMessage = true;
                        var endTime = parseInt(this.storedResponse.adminCredentials.Registration_DateTime) + this.storedResponse.adminCredentials.Registration_Request_Expiry;
                        var remainingTimeInSecs = endTime - parseInt(Date.now() / 1000);
                        if (remainingTimeInSecs > 0) {
                            this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(19, 11);
                            this.startTimer();
                        } else if (remainingTimeInSecs <= 0) {
                            remainingTimeInSecs = 0;
                            this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(19, 11);
                            this.resendBtnDisabled = false;
                        }
                    }
                }
            })
            .catch((error) => {
                this.error = error.message;
                this.displayToast('error', this.error);
            }).finally(() => {
                this.isShowSpinner = false;
            });
    }

    // Generic function to display the custom 
    displayToast(variant, msg) {
        this.variant = variant;
        this.msg = msg;
        this.showToast = true;
        setTimeout(() => {
            this.showToast = false;
        }, 3000);
    }

    //Check if enterprise client
    callcheckIfEnterpriseClient() {
        checkIfEnterpriseClient()
            .then((result) => {

                if (result == true) {
                    this.notEnterpriseClient = true;
                } else {
                    this.notEnterpriseClient = false;
                }
                // for test
                this.notEnterpriseClient = true;
                if (this.notEnterpriseClient == true && this.isPhone == true) {
                    this.isPhoneAndNotEntrepriseClient = true;
                }
                if (this.notEnterpriseClient == true && this.isPhone == false) {
                    this.isNotPhoneAndNotEntrepriseClient = true;
                }
            }
            )
            .catch((error) => {
                this.error = error.message;
            });
    }

    // Get the list of all roles from the webapp
    getAllRoles() {
        let method = 'GET';
        let endpoint = '/api/v1/roles';
        let invoker = {
            'className': 'telosTouchSetupConfiguration',
            'classMethod': 'getAllRoles'
        };
        handleRequest(method, endpoint, null, invoker)
            .then(result => {
                if (result.status) {
                    this.roleOptions = result.body.map(record => ({
                        label: record.name,
                        value: record.id
                    }));
                } else {
                    console.error('telosTouchSetupConfiguration 676574416c6c526f6c6573-1: ', result.status_code + ': ' + result.body);
                }
            })
            .catch(error => {
                let errorStr = '';
                if (typeof error == 'object' && error.message) {
                    if (error.lineNumber) { errorStr = error.lineNumber + ' - '; }
                    errorStr += error.message
                } else {
                    errorStr = error;
                }
                console.error('telosTouchSetupConfiguration 676574416c6c526f6c6573-2: ', errorStr);
                this.isLoading = false;
            })
    }

    //Check that all input are valid
    isEveryInputValid() {
        if (this.setting_Instance_URL != '' && this.setting_Authentication_URL != '' && this.setting_Client_ID != '' && this.setting_Client_Secret != '' && this.setting_Instance_URL.includes('https') && this.setting_Authentication_URL.includes('https')) {
            return true;
        } else {
            return false;
        }
    }

    //hide the toast
    handleToastVisibilityChange() {
        this.showToast = false;
        this.cancelUserModalBtn();
    }

    //start timer
    startTimer() {
        try {
            var ss = this.ltngTimer.split(":");
            var dt = new Date();
            dt.setHours(ss[0]);
            dt.setMinutes(ss[1]);
            dt.setSeconds(ss[2]);
            var dt2 = new Date(dt.valueOf() - 1000);
            var temp = dt2.toTimeString().split(" ");
            var ts = temp[0].split(":");
            this.ltngTimer = ts[0] + ":" + ts[1] + ":" + ts[2];
            //check
            this.waitingTimeId = setTimeout(() => {
                this.startTimer();
            }, 1000);
            if (ts[0] == 0 && ts[1] == 0 && ts[2] == 0) {
                window.clearTimeout(this.waitingTimeId);
                this.resendBtnDisabled = false;
            }
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // 'Update Add Users' button is clicked
    @api
    updateAndAddUsers() {
        try {
            this.afterSaveCredentials = true;
            if (this.isApproved) {
                this.settingApproval = true;
                this.isShowSpinner = true;
                this.getUsersListHelper();
            } else {
                this.settingApproval = false;
            }
        } catch (error) {
            this.error = error.message;
            this.displayToast('error', this.error);
        }
    }

    // display records and pagination
    showRecords() {
        try {
            var records = this.filteredRecords;
            var from = this.fromEntries;
            var to = this.showEntries;
            this.currentPage = 1;
            this.currentPageLessEqual1 = true;
            if (records.length === 0) {
                this.fromEntries = 0;
                this.currentPage = 0;
            } else {
                this.fromEntries = 1;
            }

            this.totalPages = Math.ceil(parseFloat(this.filteredRecords.length) / (parseFloat(this.showEntries))).toString();
            if (this.currentPage == this.totalPages) {
                this.currentPageEqualTtotalPages = true;
            } else {
                this.currentPageEqualTtotalPages = false;
            }
            var newToEntry = to;
            if (parseInt(this.filteredRecords.length) < parseInt(this.showEntries)) {
                newToEntry = parseInt(this.filteredRecords.length);
            } else {
                newToEntry = parseInt(this.showEntries);
            }
            this.toEntries = newToEntry;
            if (from == null && records.length > 0) {
                from = '1';
            } if (records.length === 0) {
                from = '0';
            }
            var finalRecords = [];
            for (var i = 1; i <= records.length; i++) {
                var record = records[i - 1];
                if (i >= parseInt(from) && i <= parseInt(to)) {
                    finalRecords.push(record);
                }
            }
            this.listdata = finalRecords;
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // 'Refresh Token' button is clicked 
    refreshToken() {
        if (this.setting.Approval == true) {
            this.settingApproval = true;
            this.isShowSpinner = true;
            refreshTokenController()
                .then((result) => {
                    this.isShowSpinner = false;
                    if (result == 'success') {
                        this.displayToast('success', Refresh_Token_Save_Toast);
                    }
                })
                .catch((error) => {
                    this.error = error.message;
                    this.displayToast('error', this.error);
                });

        } else {
            this.settingApproval = false;
        }
    }

    // call getAdminAccessToken
    saveCredSettings_Helper() {
        try {
            this.isShowSpinner = true;
            //  var settingAPIList = this.settingAPIList;
            var settingsObj = this.setting;
            settingsObj = JSON.stringify(settingsObj)
            settingsObj = '[' + settingsObj + ']';
            getAdminAccessToken({
                apiSetting: settingsObj,
                isCallingFrom: 'From Setup'
            })
                .then((result) => {

                    this.isShowSpinner = false;
                    var storedResponse = result;
                    this.settingAPIList = [];
                    if (storedResponse != null) {
                        if (storedResponse.errorMessage == 'Not Admin') {
                            this.setting = storedResponse.adminCredentials;
                            if (this.setting.Approval == false || this.setting.Approval == null) {
                                this.settingApproval = false;
                                this.isEditAndnotsettingApproval = true;
                            } else {
                                this.settingApproval = true;
                            }
                            this.setting_Client_ID = this.setting.Client_ID;
                            this.setting_Client_Secret = this.setting.Client_Secret;
                            this.setting_Instance_URL = this.setting.Instance_URL;
                            this.setting_Authentication_URL = this.setting.Authentication_URL;
                            this.displayToast('error', Cred_Not_Valid_As_Admin_Contact_Admin);
                            return;
                        }
                        if (storedResponse.errorMessage == 'This user is not validate with TT.') {
                            this.setting = storedResponse.adminCredentials;
                            if (this.setting.Approval == false || this.setting.Approval == null) {
                                this.settingApproval = false;
                                this.isEditAndnotsettingApproval = true;
                            } else {
                                this.settingApproval = true;
                            }
                            this.setting_Client_ID = this.setting.Client_ID;
                            this.setting_Client_Secret = this.setting.Client_Secret;
                            this.setting_Instance_URL = this.setting.Instance_URL;
                            this.setting_Authentication_URL = this.setting.Authentication_URL;
                            this.displayToast('error', User_Not_Valid_Cannot_Auth_App);

                            return;
                        }
                        if (storedResponse.adminCredentials != null) {
                            this.setting = storedResponse.adminCredentials;
                            if (this.setting.Approval == false || this.setting.Approval == null) {
                                this.settingApproval = false;
                                this.isEditAndnotsettingApproval = true;
                            } else {
                                this.settingApproval = true;
                            }
                            this.setting_Client_ID = this.setting.Client_ID;
                            this.setting_Client_Secret = this.setting.Client_Secret;
                            this.setting_Instance_URL = this.setting.Instance_URL;
                            this.setting_Authentication_URL = this.setting.Authentication_URL;
                            this.isEdit = false;
                            this.isNotEdit = true;
                            this.isDisSave = true;
                            this.afterSaveCredentials = true;
                            this.isEditAndnotsettingApproval = false;
                            this.isEditDisabled = false;
                            this.displayToast('success', Config_Save_Toast);
                        } else {
                            this.setting.TelosTouchSF__Approval__c = false;
                            this.abortScheduleJobs();
                            this.displayToast('error', Check_Cred_Toast);
                        }
                        if (storedResponse.activeUserWrapper != null) {
                            var userArray = [];
                            for (var i = 0; i < storedResponse.activeUserWrapper.length; i++) {
                                storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                                storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                                if (storedResponse.activeUserWrapper[i].TTUser == Yes_Text) {
                                    storedResponse.activeUserWrapper[i].userObject.isDisable = true;
                                }
                                userArray.push(storedResponse.activeUserWrapper[i].userObject);
                            }
                            this.listdata = userArray;
                            this.filteredRecords = this.listdata;
                            this.filteredRecordsSize = this.filteredRecords.length;
                            this.allRecords = this.listdata;
                        }
                        this.showRecords();
                    } else {
                        this.displayToast('error', Check_Cred_Toast);

                    }
                })
                .catch((error) => {
                    this.isShowSpinner = false;
                    this.error = error.body.message;
                    this.setting.TelosTouchSF__Approval__c = false;
                    this.displayToast('error', this.error);
                });
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // call abortScheduleJob
    abortScheduleJobs() {
        var settingAPIList = this.settingAPIList;
        var settingsObj = this.setting;
        settingAPIList.push(settingsObj);
        abortScheduleJob({ apiSettingList: settingAPIList })
            .then((result) => { })
            .catch((error) => {
                this.error = error.message;
            });
    }

    // call getUserList
    @api
    getUsersListHelper() {
        getUserList()
            .then((result) => {
                this.isShowSpinner = false;
                var storedResponse = result;
                if (storedResponse.activeUserWrapper != null) {
                    var userArray = [];

                    let lstRole = this.roleOptions;

                    for (var i = 0; i < storedResponse.activeUserWrapper.length; i++) {
                        storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                        storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                        storedResponse.activeUserWrapper[i].userObject.TTRole = storedResponse.activeUserWrapper[i].TTRole;
                        lstRole.forEach(role => {
                            if (role.value == storedResponse.activeUserWrapper[i].TTRole) {
                                storedResponse.activeUserWrapper[i].userObject.TTRoleLabel = role.label;
                            }
                        });
                        if (storedResponse.activeUserWrapper[i].TTUser == Yes_Text) {
                            storedResponse.activeUserWrapper[i].userObject.isDisable = true;
                        }
                        userArray.push(storedResponse.activeUserWrapper[i].userObject);
                    }
                    this.listdata = userArray;
                    this.filteredRecords = this.listdata;
                    this.filteredRecordsSize = this.filteredRecords.length;
                    this.allRecords = this.listdata;
                    this.showRecords();
                }
            })
            .catch((error) => {
                this.error = error.message;
            });
    }

    switchRoleModal() {
        this.showRoleModal = !this.showRoleModal;
        if (!this.showRoleModal) {
            this.selectedRole = 'professional';
        }
    }

    changeRole(event) {
        let value = event.detail.value;
        this.selectedRole = value;
    }

    handleMassSaveRole() {

        this.isShowSpinner = true;
        let lstUser = []
        let selectedRows = this.selectedUserList;
        for (var i = 0; i < selectedRows.length; i++) {
            if (!selectedRows[i].TelosTouchSF__TT_UserId__c) { continue; }
            let aUser = {
                Id: selectedRows[i].Id,
                Email: selectedRows[i].Email,
                FirstName: selectedRows[i].FirstName,
                LastName: selectedRows[i].LastName,
                TelosTouchSF__TT_Role__c: this.selectedRole,
                TelosTouchSF__TT_UserId__c: selectedRows[i].TelosTouchSF__TT_UserId__c
            }
            lstUser.push(aUser);
        }

        updateTTUser({
            lstUser: lstUser
        })
            .then((result) => {
                if (result.status == 'success') {
                    this.displayToast('success', Update_User_SuccessToast);
                    this.cancelUserModal();
                } else {
                    console.error(result.error);
                    this.displayToast('error', result.error);
                }
            })
            .catch((error) => {
                this.error = error.message;
                this.displayToast('error', this.error);

            })
            .finally(() => {
                this.switchRoleModal();
                this.isShowSpinner = false;
            });

    }

    //'Cancel button' is clicked
    cancelSettings() {
        this.doInit_Helper();
        this.isEdit = false;
        this.isNotEdit = true;
        this.isDisSave = true;
        this.isEditAndnotsettingApproval = false;
        this.isEditDisabled = false;
    }

    //'Edit button' is clicked
    editSettings() {
        this.isEdit = true;
        this.isNotEdit = false;
        this.isDisSave = false;
        this.isEditAndnotsettingApproval = true;
        this.isEditDisabled = true;
    }

    //Used to close modal when toast disappears
    cancelUserModal() {
        this.modalCloseTimeout = setTimeout(() => {
            this.selectedUserList = [];
            this.listofUserId = [];
            this.ListID = [];
            this.isEmptySelectedUserList = true;
            this.afterSaveCredentials = false;
            this.showSearchBar = false;
            this.fromEntries = 1;
            this.searchValue = '';
            const closeUserPopUp = new CustomEvent('closeusermanagement', { detail: false });
            this.dispatchEvent(closeUserPopUp);
        }, 3000);
    }

    //'Cancel button' is clicked
    cancelUserModalBtn() {
        clearTimeout(this.modalCloseTimeout);
        this.selectedUserList = [];
        this.listofUserId = [];
        this.ListID = [];
        this.isEmptySelectedUserList = true;
        this.afterSaveCredentials = false;
        this.showSearchBar = false;
        this.fromEntries = 1;
        this.searchValue = '';
        const closeUserPopUp = new CustomEvent('closeusermanagement', { detail: false });
        this.dispatchEvent(closeUserPopUp);
    }

    // show search bar
    displaySearch() {
        this.showSearchBar = true;
    }

    // hide search bar
    hideSearch() {
        this.showSearchBar = false;
        this.searchValue = '';
        if (this.setting.Approval == true) {
            this.settingApproval = true;
            this.getUsersListHelper();
        } else {
            this.settingApproval = false;
        }
    }

    //'Save button' is clicked
    saveSettings() {
        try {
            if (this.setting_Client_ID != null) {
                this.setting_Client_ID = this.setting_Client_ID.trim()
            }
            if (this.setting_Client_Secret != null) {
                this.setting_Client_Secret = this.setting_Client_Secret.trim()
            }
            if (this.setting_Instance_URL != null) {
                this.setting_Instance_URL = this.setting_Instance_URL.trim()
            }
            if (this.setting_Authentication_URL != null) {
                this.setting_Authentication_URL = this.setting_Authentication_URL.trim()
            }

            this.setting.Client_ID = this.setting_Client_ID
            this.setting.Client_Secret = this.setting_Client_Secret
            this.setting.Instance_URL = this.setting_Instance_URL
            this.setting.Authentication_URL = this.setting_Authentication_URL

            if (this.isEveryInputValid()) {
                this.saveCredSettings_Helper();
            }

        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // call this.SendSFUserToTT_Helper
    SendSFUserToTT() {
        try {
            this.selectedRows = this.selectedUserList;
            this.listofUserId = [];
            for (var i = 0; i < this.selectedRows.length; i++) {
                delete this.selectedRows[i].TTRole;
                delete this.selectedRows[i].TTUser;
                delete this.selectedRows[i].isDisable;
                this.selectedRows[i].sobjectType = "User";
                this.listofUserId.push(this.selectedRows[i].Id);
            }
            this.SendSFUserToTT_Helper();
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // call sendSFUserToTT
    SendSFUserToTT_Helper() {
        this.isShowSpinner = true;

        sendSFUserToTT({
            sfUserList: this.selectedRows,
            listofUserId: this.listofUserId
        })
            .then((result) => {
                this.isShowSpinner = false;
                var storedResponse = result;
                if (storedResponse != null) {
                    var res = storedResponse.split("+");
                    if (res[0] == 'error' && parseInt(res[1]) > 1) {
                        this.displayToast('error', Unable_Create_Some_User_Toast);
                    } else if (res[0] == 'error' && parseInt(res[1]) == 1) {
                        this.displayToast('error', Unable_Create_User_Toast);
                    } else if (res[0] == 'success') {
                        this.displayToast('success', Sent_SuccessToast);
                    } else {
                        this.displayToast('error', Something_Wrong_Check_Admin_Toast);
                    }
                    this.cancelUserModal();
                }
            })
            .catch((error) => {
                this.error = error.message;
                this.displayToast('error', this.error);

            });
    }

    // change page (Pagination)
    changePage() {
        try {
            this.currentPage = this.pageNumber;
            if (this.currentPage <= 1) {
                this.currentPageLessEqual1 = true;
            } else {
                this.currentPageLessEqual1 = false;
            }
            if (this.currentPage == this.totalPages) {
                this.currentPageEqualTtotalPages = true;
            } else {
                this.currentPageEqualTtotalPages = false;
            }
            var numberOfRecords = this.showEntries;
            var recordToShowEnd = parseInt(this.pageNumber) * parseInt(numberOfRecords);
            var recordToShowStart = parseInt(recordToShowEnd) - parseInt(numberOfRecords);
            var filteredRecords = this.filteredRecords;
            var newRecordsToShow = [];
            for (var i = 0; i < filteredRecords.length; i++) {
                var filteredRecord = filteredRecords[i];
                if (parseInt(i) >= parseInt(recordToShowStart) && parseInt(i) < parseInt(recordToShowEnd)) {
                    newRecordsToShow.push(filteredRecord);
                }
            }
            let tempSelected = this.selectedUserList;
            for (let y of newRecordsToShow) {
                let isChecked = false;
                for (let x of tempSelected) {
                    if (x.Id === y.Id) {
                        isChecked = true;
                        break;
                    }
                }
                y.isChecked = isChecked;
            }
            this.listdata = newRecordsToShow;
            this.fromEntries = parseInt(recordToShowStart) + 1;
            if (parseInt(recordToShowEnd) > parseInt(filteredRecords.length)) {
                this.toEntries = filteredRecords.length;
            } else {
                this.toEntries = recordToShowEnd;
            }
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // click previous page (Pagination)
    goToPreviousPage() {
        this.pageNumber = (parseInt(this.currentPage) - 1).toString();
        this.changePage();
    }

    // click next page (Pagination)
    goToNextPage() {
        this.pageNumber = (parseInt(this.currentPage) + 1).toString();
        this.changePage();
    }

    // click the show or hide advanced settings link
    toggleAdvancedOptions() {
        if (this.showAdvancedOptions == true) {
            this.showAdvancedOptions = false;
        } else {
            this.showAdvancedOptions = true;
        }
    }

    // call this.resendRegistrationRequest_helper();
    resendRegistrationRequest() {
        this.resendBtnDisabled = true;
        this.isShowSpinner = true;
        this.resendRegistrationRequest_helper();
    }

    // call sendRegistrationRequest
    resendRegistrationRequest_helper() {
        sendRegistrationRequest()
            .then((result) => {
                this.isShowSpinner = false;
                var storedResponse = {};
                storedResponse.adminCredentials = result;
                if (storedResponse.adminCredentials == null) {
                    this.displayToast('error', 'Registration request sent');
                }
                if (storedResponse.adminCredentials.Registration_Successful == true && storedResponse.adminCredentials.Registration_Request_Expiry == null && storedResponse.adminCredentials.Registration_DateTime == null) {
                    if (storedResponse.adminCredentials.Registration_Request_Expiry == 0) {
                        this.showContactMessage = true;
                        this.showRegistrationMessage = false;
                        return;
                    }
                    this.showRegistrationMessage = true;


                    var endTime = parseInt(storedResponse.adminCredentials.Registration_DateTime) + storedResponse.adminCredentials.Registration_Request_Expiry;
                    var remainingTimeInSecs = endTime - parseInt(Date.now() / 1000);
                    if (remainingTimeInSecs > 0) {
                        this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(19, 11);
                        this.startTimer();
                    } else if (remainingTimeInSecs <= 0) {
                        remainingTimeInSecs = 0;
                        this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(19, 11);
                        this.resendBtnDisabled = false;
                    }
                }
            })
            .catch((error) => {
                this.error = error.message;
                this.displayToast('error', 'Registration request could not be sent');
            });
    }

    // checkbox is selected
    checkboxSelect(event) {
        try {
            // on each checkbox selection update the selected record count
            var getSelectedNumber;
            var selectedRec = event.target.checked;
            if (this.selectedCount != null) {
                getSelectedNumber = this.selectedCount;
            } else {
                getSelectedNumber = 0;
            }
            if (selectedRec == true) {
                this.ListID.push(event.target.value);
                getSelectedNumber++;
            } else {
                var index = this.ListID.indexOf(event.target.value);
                if (index > -1) { // only splice array when item is found
                    this.ListID.splice(index, 1); // 2nd parameter means remove one item only
                }
                getSelectedNumber--;
            }
            this.selectedCount = getSelectedNumber;
            var allRecords = this.filteredRecords;
            var selectedRecords = [];
            for (var i = 0; i < allRecords.length; i++) {
                if (this.ListID.includes(allRecords[i].Id)) {
                    selectedRecords.push(allRecords[i]);
                }
            }
            this.selectedUserList = selectedRecords;
            if (this.selectedUserList.length == 0) {
                this.isEmptySelectedUserList = true;
            } else {
                this.isEmptySelectedUserList = false;
            }
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }
    // onchange search bar
    searchKeyword(event) {
        this.searchValue = event.target.value;
        if ((this.searchValue.length > 2 && this.searchValue != null) || (this.searchValue == '')) {
            this.searchUsersHelper();
        }
    }

    // search for users
    searchUsersHelper() {
        try {
            if (this.searchValue == '' || this.searchValue == null) {
                if (this.setting.Approval == true) {
                    this.settingApproval = true;
                    this.getUsersListHelper();
                } else {
                    this.settingApproval = false;
                }
            } else {
                var allRecords = this.filteredRecords;
                var tempArray = [];
                for (var i = 0; i < allRecords.length; i++) {
                    if (allRecords[i].Email.toUpperCase().includes(this.searchValue.toUpperCase()) || allRecords[i].Username.toUpperCase().includes(this.searchValue.toUpperCase())) {
                        tempArray.push(allRecords[i]);
                    }
                }
                this.listdata = tempArray;
            }
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // Onchange Client ID
    handleSetting_Client_IDChange(event) {
        try {
            this.setting_Client_ID = event.target.value;
            this.setting_Client_ID = this.setting_Client_ID.trim();
            this.setting_Client_ID = this.setting_Client_ID.replaceAll(' ', '');
            event.target.value = this.setting_Client_ID;
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // Onchange Client Secret
    handleSetting_Client_Secret(event) {
        try {
            this.setting_Client_Secret = event.target.value;
            this.setting_Client_Secret = this.setting_Client_Secret.trim();
            this.setting_Client_Secret = this.setting_Client_Secret.replaceAll(' ', '');
            event.target.value = this.setting_Client_Secret;
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // Onchange Instance_URL
    handleSetting_Instance_URL(event) {
        try {
            this.setting_Instance_URL = event.target.value;
            var strTemp = this.setting_Instance_URL;
            strTemp = strTemp.trim();
            strTemp = strTemp.replaceAll(' ', '');
            var inputCmp = this.template.querySelector("[data-id='formIdInstance']");
            if (!strTemp.includes('HTTPS') && !strTemp.includes('https')) {
                this.isInsURLNotValid = true;
                this.isDisSave = true;
                inputCmp.setCustomValidity(Instance_URL_Error);
            } else {
                this.isInsURLNotValid = false;
                this.isDisSave = false;
                inputCmp.setCustomValidity('');
            }
            inputCmp.reportValidity();
            this.setting_Instance_URL = strTemp;
            event.target.value = strTemp;
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // Onchange Authentication_URL
    handlesetting_Authentication_URL(event) {
        try {
            this.setting_Authentication_URL = event.target.value;
            var strTemp = this.setting_Authentication_URL;
            strTemp = strTemp.trim();
            strTemp = strTemp.replaceAll(' ', '');
            var inputCmp = this.template.querySelector("[data-id='formIdAuthent']");
            if (!strTemp.includes('HTTPS') && !strTemp.includes('https')) {
                this.isAuthURLNotValid = true;
                this.isDisSave = true;
                inputCmp.setCustomValidity(Authentication_URL_Error);
            } else {
                this.isAuthURLNotValid = false;
                this.isDisSave = false;
                inputCmp.setCustomValidity('');
            }
            inputCmp.reportValidity();
            this.setting_Authentication_URL = strTemp;
            event.target.value = strTemp;
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    checkRevokeUsers() {
        this.isShowSpinner = true;

        this.listofUserId = [];
        for (var i = 0; i < this.selectedUserList.length; i++) {
            this.listofUserId.push(this.selectedUserList[i].Id);
        }
        this.revokeCurrentUser = this.listofUserId.includes(this.currentUserId);
        if (this.revokeCurrentUser) {
            this.userRevokeAccessModal = true;
            this.isShowSpinner = false;
        } else {
            this.handleMassRevoke()
        }
    }

    handleRevokeAccess(event) {
        this.userRevokeAccessModal = true;
        this.userIdForRestriction = event.currentTarget.dataset.id;
        this.revokeCurrentUser = this.currentUserId == this.userIdForRestriction;
    }

    handleGrantAccess(event) {
        this.userGrantAccessModal = true;
        this.userIdForGrantAccess = event.currentTarget.dataset.id;
    }

    handleCancelRevoke() {
        this.userRevokeAccessModal = false;
        this.userIdForRestriction = undefined;
    }

    handleCancelGrant() {
        this.userGrantAccessModal = false;
    }

    handleConfirmRevoke() {
        if (this.userIdForRestriction) {
            this.handleSingleRevoke();
        } else if (this.listofUserId.length > 0) {
            this.handleMassRevoke();
        }
        this.userRevokeAccessModal = false;
    }

    handleSingleRevoke() {
        if (!this.userIdForRestriction) return;
        this.isShowSpinner = true;

        revokeUserAccess({
            userId: this.userIdForRestriction
        })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.afterSaveCredentials = false;
                    this.displayToast('success', this.label.Remove_permissions_single_toast);
                    this.doInit_Helper();
                    this.userIdForRestriction = undefined;
                } else if (result && result.status == 'error') {
                    this.displayToast('error', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleConfirmRevoke Error: ', error);
                this.displayToast('error', error);
            })
            .finally(() => {
                this.userRevokeAccessModal = false;
                this.isShowSpinner = false;
            });
    }

    handleConfirmGrant() {
        for (let x of this.filteredRecords) {
            if (x.Id == this.userIdForGrantAccess) {
                this.selectedRows = [x];
                this.listofUserId = [x.Id];
            }
        }
        this.SendSFUserToTT_Helper();
        this.userGrantAccessModal = false;
    }

    handleMassRevoke() {

        this.isShowSpinner = true;

        this.selectedRows = this.selectedUserList;
        this.listofUserId = [];
        for (var i = 0; i < this.selectedRows.length; i++) {
            delete this.selectedRows[i].TTRole;
            delete this.selectedRows[i].TTUser;
            delete this.selectedRows[i].isDisable;
            this.selectedRows[i].sobjectType = "User";
            this.listofUserId.push(this.selectedRows[i].Id);
        }

        revokeUserAccess({
            listOfTTUser: this.listofUserId
        })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.afterSaveCredentials = false;
                    this.displayToast('success', this.label.Remove_permissions_toast);
                } else if (result && result.status == 'error') {
                    this.displayToast('error', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleMassRevoke Error: ', error);
                this.displayToast('error', error);
            })
            .finally(() => {
                this.cancelUserModal();
                this.isShowSpinner = false;
            });

    }


}