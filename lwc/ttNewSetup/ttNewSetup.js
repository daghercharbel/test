import { LightningElement, api, track } from 'lwc';

//Apex Methods
import checkSettings from "@salesforce/apex/TelosTouchUtility.checkSettings";
import Help_Section_Text_1 from "@salesforce/label/c.Help_Section_Text_1";
import Help_Section_Text_2 from "@salesforce/label/c.Help_Section_Text_2";
import getSyncData from "@salesforce/apex/TelosTouchDataSyncController.getSyncData";
import startRegistrationProcess from "@salesforce/apex/TtSalesforceOnboardingController.startRegistrationProcess";
import validateTokenAndFetchCredentials from '@salesforce/apex/TtSalesforceOnboardingController.validateTokenAndFetchCredentials';
import disconnectFromTelosTouchApex from "@salesforce/apex/TtSalesforceOnboardingController.disconnectFromTelosTouchApex";
import refreshTokenController from "@salesforce/apex/TelosTouchUtility.refreshTokenController";

//Custom Labels
import Config_Save_Toast from "@salesforce/label/c.Config_Save_Toast";
import Check_Cred_Toast from "@salesforce/label/c.Check_Cred_Toast";
import Record_Sync_Success_Text from "@salesforce/label/c.Record_Sync_Success_Text";
import Refresh_Token_Button_Label from "@salesforce/label/c.Refresh_Token_Button_Label";
import Refresh_Token_Save_Toast from "@salesforce/label/c.Refresh_Token_Save_Toast";
import One_Time_Token_Text from "@salesforce/label/c.One_Time_Token_Text";
import One_Time_Code_Message from "@salesforce/label/c.One_Time_Code_Message";
import Close from "@salesforce/label/c.Close";
import cancel from "@salesforce/label/c.cancel";
import Ok_Text from "@salesforce/label/c.Ok_Text";
import API_Status_Text from "@salesforce/label/c.API_Status_Text";
import Connected_Text from "@salesforce/label/c.Connected_Text";
import Missing_API_Token_Text from "@salesforce/label/c.Missing_API_Token_Text";
import Data_Sync_Tab_Label from "@salesforce/label/c.Data_Sync_Tab_Label";
import Last_Sync_Completed from "@salesforce/label/c.Last_Sync_Completed";
import Manual_Sync_All_Button from "@salesforce/label/c.Manual_Sync_All_Button";
import Show_Logs_Text from "@salesforce/label/c.Show_Logs_Text";
import User_Management_Text from "@salesforce/label/c.User_Management_Text";
import User_Management_Detail_Text from "@salesforce/label/c.User_Management_Detail_Text";
import Field_MappingTab_Label from "@salesforce/label/c.Field_MappingTab_Label";
import Field_Mapping_Detail_Text from "@salesforce/label/c.Field_Mapping_Detail_Text";
import Feature_Toggle from "@salesforce/label/c.Feature_Toggle";
import Feature_Toggle_Detail_Text from "@salesforce/label/c.Feature_Toggle_Detail_Text";
import Help_Tab_Label from "@salesforce/label/c.Help_Tab_Label";

export default class TtNewSetup extends LightningElement {
    label = {
        Help_Section_Text_1,
        Help_Section_Text_2,
        Config_Save_Toast,
        Check_Cred_Toast,
        Refresh_Token_Button_Label,
        Refresh_Token_Save_Toast,
        One_Time_Token_Text,
        Close,
        One_Time_Code_Message,
        cancel,
        Ok_Text,
        API_Status_Text,
        Connected_Text,
        Missing_API_Token_Text,
        Data_Sync_Tab_Label,
        Last_Sync_Completed,
        Manual_Sync_All_Button,
        Show_Logs_Text,
        User_Management_Text,
        User_Management_Detail_Text,
        Field_MappingTab_Label,
        Field_Mapping_Detail_Text,
        Feature_Toggle,
        Feature_Toggle_Detail_Text,
        Help_Tab_Label
    }
    showDiffData = false;
    modalLabel = '';
    @api isAdmin = false;
    @api showManualSync = false;
    @api showLogTable = false;
    @api enableUpdateAddUser = false;
    @api enableFieldMapping = false;
    @api enableFeatureManagement = false;
    @api enableKnowledgeBase = false;
    showManualSyncModal = false;
    approvalValue = false;
    @api isApiConnected = false;
    @track manualSyncTime;
    isShowSpinner = false;
    registrationTokenValue = '';
    showRegistrationModal = false;
    showToast = false;

    get connectLabel() {
        return (this.isApiConnected == true ? 'Disconnect' : 'Connect');
    }
    get isUserEdit() {
        return !this.isApiConnected;
    }

    connectedCallback() {
        this.isShowSpinner = true;
        getSyncData()
            .then(data => {
                var returnObj = JSON.parse(data);
                this.manualSyncTime = returnObj.lastUpdated;
                this.isApiConnected = returnObj.approval;
                this.isShowSpinner = false;
            }).catch(error => {
                console.log('error: ' + error);
            });
        this.handleCheckSettings();
    }
    handleConnect() {
        if (!this.isApiConnected) {
            this.isShowSpinner = true;
            startRegistrationProcess().then((data) => {
                if (data === true) {
                    //Open Modal
                    this.showRegistrationModal = true;
                } else {
                    //Show Error Toast
                    this.displayToast('error', 'Connection Failed');
                }
            }).catch((error) => {
                //Show Error Toast
                console.log(error);
                this.displayToast('error', error.body.message);
            }).finally(() => {
                this.isShowSpinner = false;
            });
        } else {
            this.disconnectToTelosTouch();
        }
    }
    closeRegistrationModal() {
        this.showRegistrationModal = false;
    }
    submitRegistrationDetails() {
        try {
            this.isShowSpinner = true;
            validateTokenAndFetchCredentials({
                oneTimeToken: this.registrationTokenValue.replace(/\s+/g, '')
            })
                .then((result) => {
                    this.isShowSpinner = false;
                    var storedResponse = JSON.parse(result);
                    if (storedResponse != null) {
                        if (storedResponse.errorMessage == 'Not Admin') {
                            this.isApiConnected = false;
                            this.displayToast('error', Cred_Not_Valid_As_Admin_Contact_Admin);
                            return;
                        }
                        if (storedResponse.errorMessage == 'This user is not validate with TT.') {
                            this.isApiConnected = false;
                            this.displayToast('error', User_Not_Valid_Cannot_Auth_App);
                            return;
                        }
                        if (storedResponse.adminCredentials != null) {
                            this.isApiConnected = true;
                            this.displayToast('success', Config_Save_Toast);
                            this.handleUserManagement();
                        } else {
                            this.isApiConnected = false;
                            this.abortScheduleJobs();
                            this.displayToast('error', Check_Cred_Toast);
                        }
                    } else {
                        this.isApiConnected = false;
                        this.displayToast('error', Check_Cred_Toast);
                    }
                })
                .catch((error) => {
                    console.log('error:: ' + error);
                    this.error = error.body.message;
                    this.isApiConnected = false;
                    this.displayToast('error', this.error);
                }).finally(() => {
                    this.isShowSpinner = false;
                    this.showRegistrationModal = false;
                });
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }
    // 'Refresh Token' button is clicked 
    refreshToken() {
        if (this.isApiConnected == true) {
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
    disconnectToTelosTouch() {
        this.isShowSpinner = true;
        disconnectFromTelosTouchApex().then((result) => {
            if (result) {
                this.displayToast('success', 'Disconnected from TelosTouch successfully');
                this.isApiConnected = false;
            }
        }).catch((error) => {
            this.error = error.body.message;
            this.displayToast('error', this.error);
        }).finally(() => {
            this.isShowSpinner = false;
        });;
    }

    handleCheckSettings(){
        checkSettings()
            .then(result => {
                if (result.status != 'success') {
                    console.error('ttNewSetup 68616e646c65436865636b53657474696e6773-1: ', result.error);
                }
            }).catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttNewSetup 68616e646c65436865636b53657474696e6773-2: ', errorStr);
            });
    }

    handleTokenTextAreaChange(event) {
        this.registrationTokenValue = event.target.value;
    }
    handleManualSync() {
        this.modalLabel = 'Manual Sync';
        this.showManualSync = true;
        this.showDiffData = true;
        this.showLogTable = false;
        this.enableUpdateAddUser = false;
        this.enableFeatureManagement = false;
        this.enableFieldMapping = false;
        this.enableKnowledgeBase = false;
    }
    handleLogTable() {
        this.modalLabel = 'Log Table';
        this.showDiffData = true;
        this.showLogTable = true;
        this.showManualSync = false;
        this.enableUpdateAddUser = false;
        this.enableFieldMapping = false;
        this.enableFeatureManagement = false;
        this.enableKnowledgeBase = false;
    }
    handleUserManagement() {
        try {
            this.showDiffData = true;
            this.enableUpdateAddUser = true;
            this.showLogTable = false;
            this.showManualSync = false;
            this.enableFeatureManagement = false;
            this.enableFieldMapping = false;
            this.enableKnowledgeBase = false;
            this.isShowSpinner = true;
            setTimeout(() => {
                this.template.querySelector('c-telostouch-setup-configuration').updateAndAddUsers();
                this.isShowSpinner = false;
            }, 5000);
        } catch (error) {
            console.log('error: ' + error);
        }
    }
    handleDataMapping() {
        this.modalLabel = 'Field Mapping';
        this.enableFieldMapping = true;
        this.showDiffData = true;
        this.showLogTable = false;
        this.showManualSync = false;
        this.enableUpdateAddUser = false;
        this.enableFeatureManagement = false;
        this.enableKnowledgeBase = false;

    }
    handleFeatureManagement() {
        this.modalLabel = 'Features Management';
        this.enableFeatureManagement = true;
        this.showDiffData = true;
        this.showLogTable = false;
        this.showManualSync = false;
        this.enableUpdateAddUser = false;
        this.enableFieldMapping = false;
        this.enableKnowledgeBase = false;
    }
    handleKnowledgeBase() {
        this.modalLabel = 'Knowledge Base';
        this.showDiffData = true;
        this.enableKnowledgeBase = true;
        this.enableFeatureManagement = false;
        this.showLogTable = false;
        this.showManualSync = false;
        this.enableUpdateAddUser = false;
        this.enableFieldMapping = false;
    }
    handleModalClose() {
        try {
            this.showDiffData = false;
            this.showManualSync = false;
            this.showLogTable = false;
            this.enableUpdateAddUser = false;
            this.enableFeatureManagement = false;
            this.enableFieldMapping = false;
            this.enableKnowledgeBase = false;
        } catch (error) {
        }
    }
    handleSuccessfulSync(event) {
        this.handleModalClose();
        this.displayToast('success', Record_Sync_Success_Text);
    }
    handleFailedSync(event) {
        this.handleModalClose();
        this.displayToast('error', 'Record Sync Failed');
    }
    closeUserManagementPopUp(event) {
        this.enableUpdateAddUser = event.detail;
        this.handleModalClose();
    }
    handleApprovalValue(event) {
        this.approvalValue = event.detail;
    }
    openMail() {
        var a = document.createElement("a");
        a.href = "mailto:support@telostouch.com";
        a.click();
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

    //hide the toast
    handleToastVisibilityChange() {
        this.showToast = false;
    }
}