import { LightningElement, wire, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import TT_API_Setup_Title from "@salesforce/label/c.TT_API_Setup_Title";
import Fill_Details_Text from "@salesforce/label/c.Fill_Details_Text";
import Successful_Text from "@salesforce/label/c.Successful_Text";
import Rejected_Text from "@salesforce/label/c.Rejected_Text";
import Config_Client_ID from "@salesforce/label/c.Config_Client_ID";
import Config_Client_Secret from "@salesforce/label/c.Config_Client_Secret";
import Config_Instance_URL from "@salesforce/label/c.Config_Instance_URL";
import Config_Authentication_URL from "@salesforce/label/c.Config_Authentication_URL";
import Hide_Advanced_Options_Text from "@salesforce/label/c.Hide_Advanced_Options_Text";
import Show_Advanced_Options_Text from "@salesforce/label/c.Show_Advanced_Options_Text";
import User_Name_Text from "@salesforce/label/c.User_Name_Text";
import Profile_Text from "@salesforce/label/c.Profile_Text";
import Email_Text from "@salesforce/label/c.Email_Text";
import TT_user_Text from "@salesforce/label/c.TT_user_Text";
import Showing_Text from "@salesforce/label/c.Showing_Text";
import IfTwoUserHaveSameEmail from "@salesforce/label/c.IfTwoUserHaveSameEmail";
import Pages_Text from "@salesforce/label/c.Pages_Text";
import FORM_FACTOR from '@salesforce/client/formFactor';
import Config_Footer from "@salesforce/label/c.Config_Footer";
import Access_To_TT from "@salesforce/label/c.Access_To_TT";
import Enter_Valid_Cred_Toast from "@salesforce/label/c.Enter_Valid_Cred_Toast";
import Save_Button_Label from "@salesforce/label/c.Save_Button_Label";
import Edit_Button_Label from "@salesforce/label/c.Edit_Button_Label";
import Update_Add_Users_Button_Label from "@salesforce/label/c.Update_Add_Users_Button_Label";
import Refresh_Token_Button_Label from "@salesforce/label/c.Refresh_Token_Button_Label";
import Cancel_Button_Label from "@salesforce/label/c.Cancel_Button_Label";
import Refresh_Token_Save_Toast from "@salesforce/label/c.Refresh_Token_Save_Toast";
import User_Not_Valid_Cannot_Auth_App from "@salesforce/label/c.User_Not_Valid_Cannot_Auth_App";
import Cred_Not_Valid_As_Admin_Contact_Admin from "@salesforce/label/c.Cred_Not_Valid_As_Admin_Contact_Admin";
import Config_Save_Toast from "@salesforce/label/c.Config_Save_Toast";
import Check_Cred_Toast from "@salesforce/label/c.Check_Cred_Toast";
import Yes_Text from "@salesforce/label/c.Yes_Text";
import Unable_Create_Some_User_Toast from "@salesforce/label/c.Unable_Create_Some_User_Toast";
import Unable_Create_User_Toast from "@salesforce/label/c.Unable_Create_User_Toast";
import Sent_SuccessToast from "@salesforce/label/c.Sent_SuccessToast";
import Something_Wrong_Check_Admin_Toast from "@salesforce/label/c.Something_Wrong_Check_Admin_Toast";
import Previous_Button_Label from "@salesforce/label/c.Previous_Button_Label";
import Next_Button_Label from "@salesforce/label/c.Next_Button_Label";
import GIve_TT_Access from "@salesforce/label/c.GIve_TT_Access";
import getAdminAccessToken from "@salesforce/apex/TelosTouchUtility.getAdminAccessToken";
import abortScheduleJob from "@salesforce/apex/TelosTouchUtility.abortScheduleJob";
import getUserList from "@salesforce/apex/TelosTouchUtility.getUserList";
import refreshTokenController from "@salesforce/apex/TelosTouchUtility.refreshTokenController";
import checkIfEnterpriseClient from "@salesforce/apex/TelosTouchUtility.checkIfEnterpriseClient";
import getSettingAPI from "@salesforce/apex/TelosTouchUtility.getSettingAPI";
import sendSFUserToTT from "@salesforce/apex/TelosTouchUtility.sendSFUserToTT";
import ContactMobile from "@salesforce/schema/Case.ContactMobile";
export default class telosTouchSetupConfiguration extends LightningElement {
    label = {
        TT_API_Setup_Title,
        Fill_Details_Text,
        Successful_Text,
        Rejected_Text,
        Config_Client_ID,
        Config_Client_Secret,
        Config_Instance_URL,
        Config_Authentication_URL,
        Hide_Advanced_Options_Text,
        Show_Advanced_Options_Text,
        Config_Footer,
        Access_To_TT,
        User_Name_Text,
        Profile_Text,
        Email_Text,
        TT_user_Text,
        Showing_Text,
        IfTwoUserHaveSameEmail,
        Pages_Text,
        Enter_Valid_Cred_Toast,
        Save_Button_Label,
        Edit_Button_Label,
        Update_Add_Users_Button_Label,
        Refresh_Token_Button_Label,
        Cancel_Button_Label,
        Refresh_Token_Save_Toast,
        User_Not_Valid_Cannot_Auth_App,
        Cred_Not_Valid_As_Admin_Contact_Admin,
        Config_Save_Toast,
        Check_Cred_Toast,
        Yes_Text,
        Unable_Create_Some_User_Toast,
        Unable_Create_User_Toast,
        Sent_SuccessToast,
        Something_Wrong_Check_Admin_Toast,
        Previous_Button_Label,
        Next_Button_Label,
        GIve_TT_Access
    }; 
    @track isSmallDevice = false;
    @track isTablet = false;
    @track isPhone = false;
    @track showToast = false;
    @track setting;
    @track storedResponse;
    @track settingApproval;
    @track waitingTimeId = null;
    @track isEditAndnotsettingApproval = false;
    @track ListID = [];
    @track settingAPIList;
    @track isShowSpinner;
    @track showRegistrationMessage;
    @track resendBtnDisabled;
    @track showContactMessage;
    @track showAdvancedOptions;
    @track isEdit = false;
    @track isNotEdit = true;
    @track afterSaveCredentials;
    @api listdata;
    @track filteredRecords;
    @track filteredRecordsSize;
    @track fromEntries;
    @track showEntries = '100';
    @track currentPage;
    @track currentPageLessEqual1;
    @track currentPageEqualTtotalPages;
    @track toEntries;
    @track ltngTimer;
    @track notEnterpriseClient;
    @track allRecords;
    @track totalPages;
    @track showSearchBar;
    @track selectedUserList;
    @track isEmptySelectedUserList = true;
    @track selectedRows;
    @track listofUserId;
    @track isNotPhoneAndNotEntrepriseClient;
    @track isPhoneAndNotEntrepriseClient;
    @track conditionUpdateAndAddUsers;
    @track searchValue = '';
    @track setting_Client_ID;
    @track setting_Client_Secret;
    @track setting_Instance_URL;
    @track setting_Authentication_URL;

    // OnLoad
    connectedCallback() {
        if(FORM_FACTOR === 'Medium' || FORM_FACTOR === 'Small'){
            this.isSmallDevice = true;
        }    
        if(FORM_FACTOR === 'Medium'){
            this.isTablet = true;
        }    
        if(FORM_FACTOR === 'Small'){
            this.isPhone = true;
        }    
        this.doInit_Helper();
        this.callcheckIfEnterpriseClient();
    }

    // call getSettingAPI and fetch the setting parameters
    doInit_Helper() {
        getSettingAPI({ isCallingFrom: 'DoinitFromSetup' })
          .then((result) => {
            this.isShowSpinner = false;
            this.storedResponse = result;
            if(this.storedResponse != null && this.storedResponse.adminCredentials.Client_ID != null && this.storedResponse.adminCredentials.Client_Secret != null && this.storedResponse.adminCredentials.Instance_URL != null){
                if(this.storedResponse.adminCredentials != null ){
                   this.setting = this.storedResponse.adminCredentials;
                   if(this.setting.Approval == false || this.setting.Approval == null){
                    this.isEditAndnotsettingApproval = true;
                    this.settingApproval = false;
                   }else{
                    this.settingApproval = true;
                   }
                   this.setting_Client_ID = this.setting.Client_ID;
                   this.setting_Client_Secret = this.setting.Client_Secret;
                   this.setting_Instance_URL = this.setting.Instance_URL;
                   this.setting_Authentication_URL = this.setting.Authentication_URL;
                    this.isEveryInputValid();
                }
            }else{
                this.displayToast('warning', 'Please enter TelosTouch credentials to configure TelosTouch Package.');
                var settingVar= {};
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
                if(this.setting.Approval == false || this.setting.Approval == null){
                    this.settingApproval = false;
                    this.isEditAndnotsettingApproval = true;
                   }else{
                    this.settingApproval = true;
                   }
                this.setting_Client_ID = this.setting.Client_ID;
                this.setting_Client_Secret = this.setting.Client_Secret;
                this.setting_Instance_URL = this.setting.Instance_URL;
                this.setting_Authentication_URL = this.setting.Authentication_URL;
                if(this.storedResponse.adminCredentials.Registration_Successful != null && this.storedResponse.adminCredentials.Registration_Request_Expiry != null
                    && this.storedResponse.adminCredentials.Registration_Request_Expiry != null && this.storedResponse.adminCredentials.Registration_DateTime != null
                    && this.storedResponse.adminCredentials.Registration_DateTime != null){
                    if(this.storedResponse.adminCredentials.Registration_Request_Expiry == 0){
                        this.showContactMessage = true;
                        this.showRegistrationMessage = true;
                        return;
                    }
                    this.showRegistrationMessage = true;
                    var endTime = parseInt(this.storedResponse.adminCredentials.Registration_DateTime) + this.storedResponse.adminCredentials.Registration_Request_Expiry;
                    var remainingTimeInSecs = endTime - parseInt(Date.now()/1000);
                    if(remainingTimeInSecs > 0){
                        this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(11, 8);
                        this.startTimer();
                    }else if(remainingTimeInSecs <= 0){
                        remainingTimeInSecs = 0;
                        this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(11, 8);
                        this.resendBtnDisabled = false;
                    }
                }
            }
          })
          .catch((error) => {
            this.error = error.message;
            this.displayToast('error', this.error);
          });
    }

    // Generic function to display the custom 
    displayToast (variant, msg) {
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

            if(result == true){
                this.notEnterpriseClient = true;
            }else{
                this.notEnterpriseClient = false;
            }
            // for test
            this.notEnterpriseClient = true;
            if(this.notEnterpriseClient == true && this.isPhone == true){
                this.isPhoneAndNotEntrepriseClient = true;
            }
            if(this.notEnterpriseClient == true && this.isPhone == false){
                this.isNotPhoneAndNotEntrepriseClient = true;
            }
          }
            )
            .catch((error) => {
              this.error = error.message;
            });
    }

    //Check that all input are valid
    isEveryInputValid(){
        return [
            ...this.template.querySelectorAll("[data-id='formId']")
        ].reduce((previousValue,currentValue) => {
            currentValue.reportValidity();
            return previousValue && currentValue.checkValidity();
        },true);
        
    }

    //hide the toast
    handleToastVisibilityChange () {
        this.showToast = false;
    }

    //start timer
    startTimer(){
        try{
        var currTime = this.ltngTimer;
        var ss = currTime.split(":");
        var dt = new Date();
        dt.setHours(ss[0]);
        dt.setMinutes(ss[1]);
        dt.setSeconds(ss[2]);
        var dt2 = new Date(dt.valueOf() - 1000);
        var temp = dt2.toTimeString().split(" ");
        var ts = temp[0].split(":");
        this.ltngTimer = ts[0] + ":" + ts[1] + ":" + ts[2];
        //check
        setTimeout(() => { this.startTimer();
        },1000);
        if(ts[0]==0 && ts[1]==0 && ts[2]==0 ){
            window.clearTimeout(this.waitingTimeId);
            this.resendBtnDisabled = false;
        }
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // 'Update Add Users' button is clicked 
    updateAndAddUsers(){
        this.afterSaveCredentials = true;
        if(this.setting.Approval == true){
            this.settingApproval = true;
            this.isShowSpinner = true;
            this.getUsersListHelper();
        }else{
            this.settingApproval = false;
        }
    }

    // display records and pagination
    showRecords(){
        try {
        var records = this.filteredRecords;
        var from = this.fromEntries;
        var to = this.showEntries;
        this.currentPage = 1;
        this.currentPageLessEqual1 = true;
        if(records.length === 0){
            this.fromEntries = 0;
            this.currentPage = 0;
        }else{
            this.fromEntries = 1;
        }

          this.totalPages = Math.ceil(parseFloat(this.filteredRecords.length)/(parseFloat(this.showEntries))).toString();
          if(this.currentPage == this.totalPages){
            this.currentPageEqualTtotalPages = true;
        }else{
            this.currentPageEqualTtotalPages = true;
        }
        var newToEntry = to;
        if(parseInt(this.filteredRecords.length) < parseInt(this.showEntries)) {
            newToEntry = parseInt(this.filteredRecords.length);
        } else {
            newToEntry = parseInt(this.showEntries);
        } 
        this.toEntries = newToEntry;
        if(from == null && records.length>0){
            from = '1';
        }if(records.length === 0) {
            from = '0';
        }
        var finalRecords = [];
        for (var i = 1; i <= records.length; i++) {
            var record = records[i-1];
            if(i >= parseInt(from) && i <= parseInt(to)) {
                finalRecords.push(record);
            }
        }
        this.listdata = finalRecords;
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // 'Refresh Token' button is clicked 
    refreshTokenHelper(){
        if(this.setting.Approval == true){
            this.settingApproval = true;
            this.isShowSpinner = true;
            refreshTokenController()
            .then((result) => {
                this.isShowSpinner = false;
                if(result.getState() === 'SUCCESS'){
                    this.displayToast('success', Refresh_Token_Save_Toast);
                }

            })
            .catch((error) => {
              this.error = error.message;
              this.displayToast('error', this.error);
            });

        }else{
            this.settingApproval = false;
        }
    }

    // call getAdminAccessToken
    saveCredSettings_Helper(){
        try {
        this.isShowSpinner = true;
          //  var settingAPIList = this.settingAPIList;
            var settingsObj = this.setting;
            settingsObj = JSON.stringify(settingsObj)
            settingsObj = '[' + settingsObj + ']';
            getAdminAccessToken({ apiSetting: settingsObj,
                                 isCallingFrom: 'From Setup' })
            .then((result) => {

                this.isShowSpinner = false;
                var storedResponse = result;
                this.settingAPIList = [];
                if(storedResponse != null){
                    if(storedResponse.errorMessage == 'Not Admin'){
                        this.setting = storedResponse.adminCredentials;
                        if(this.setting.Approval == false || this.setting.Approval == null){
                            this.settingApproval = false;
                            this.isEditAndnotsettingApproval = true;
                           }else{
                            this.settingApproval = true;
                           }
                        this.setting_Client_ID = this.setting.Client_ID;
                        this.setting_Client_Secret = this.setting.Client_Secret;
                        this.setting_Instance_URL = this.setting.Instance_URL;
                        this.setting_Authentication_URL = this.setting.Authentication_URL;
                        this.displayToast('error', Cred_Not_Valid_As_Admin_Contact_Admin);
                        return;
                    }
                    if(storedResponse.errorMessage == 'This user is not validate with TT.'){
                        this.setting = storedResponse.adminCredentials;
                        if(this.setting.Approval == false || this.setting.Approval == null){
                            this.settingApproval = false;
                            this.isEditAndnotsettingApproval = true;
                           }else{
                            this.settingApproval = true;
                           }
                        this.setting_Client_ID = this.setting.Client_ID;
                        this.setting_Client_Secret = this.setting.Client_Secret;
                        this.setting_Instance_URL = this.setting.Instance_URL;
                        this.setting_Authentication_URL = this.setting.Authentication_URL;
                        this.displayToast('error', User_Not_Valid_Cannot_Auth_App);

                        return;
                    }
                    if(storedResponse.adminCredentials != null){
                        this.setting = storedResponse.adminCredentials;
                        if(this.setting.Approval == false || this.setting.Approval == null){
                            this.settingApproval = false;
                            this.isEditAndnotsettingApproval = true;
                           }else{
                            this.settingApproval = true;
                           }
                        this.setting_Client_ID = this.setting.Client_ID;
                        this.setting_Client_Secret = this.setting.Client_Secret;
                        this.setting_Instance_URL = this.setting.Instance_URL;
                        this.setting_Authentication_URL = this.setting.Authentication_URL;
                        this.isEdit = false;
                        this.isNotEdit = true;
                        this.afterSaveCredentials = true;
                        this.displayToast('success', Config_Save_Toast);
                    }else{
                        this.setting.TelosTouchSF__Approval__c = false;
                        this.abortScheduleJobs();
                        this.displayToast('error', Check_Cred_Toast);
                    }
                    if(storedResponse.activeUserWrapper != null){
                        var userArray = [];
                        for(var i=0;i<storedResponse.activeUserWrapper.length;i++){
                            storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                            storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                            if(storedResponse.activeUserWrapper[i].TTUser == Yes_Text){
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
                }else{
                    this.displayToast('error', Check_Cred_Toast);

                }
             })
          .catch((error) => {
            this.error = error.message;
            this.setting.TelosTouchSF__Approval__c = false;
            this.displayToast('error', this.error);
          });
        } catch (e) {
            throw new CustomException(e.getMessage());
        }
    }

    // call abortScheduleJob
    abortScheduleJobs(){
        var settingAPIList = this.settingAPIList;
        var settingsObj = this.setting;
        settingAPIList.push(settingsObj);
        abortScheduleJob({ apiSettingList: settingAPIList})
        .then((result) => { })
        .catch((error) => {
        this.error = error.message;
        });
    }

    // call getUserList
    getUsersListHelper(){
        getUserList()
        .then((result) => {
            this.isShowSpinner = false;
            var storedResponse = result;

            if(storedResponse.activeUserWrapper != null ){
                var userArray = [];
                for(var i=0;i<storedResponse.activeUserWrapper.length;i++){
                    storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                    storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                    if(storedResponse.activeUserWrapper[i].TTUser == Yes_Text){
                        storedResponse.activeUserWrapper[i].userObject.isDisable = true;
                    }
                    userArray.push(storedResponse.activeUserWrapper[i].userObject);
                }
                this.listdata = userArray;
                this.filteredRecords =this.listdata;
                this.filteredRecordsSize = this.filteredRecords.length;
                this.allRecords =this.listdata;
                this.showRecords();
            }
      })
      .catch((error) => {
        this.error = error.message;
  
      });
    }

    //'Cancel button' is clicked
    cancelSettings(){
        this.doInit_Helper();
        this.isEdit = false;
        this.isNotEdit = true;
    }

    //'Edit button' is clicked
    editSettings(){
        this.isEdit = true;
        this.isNotEdit = false;
        this.isEditAndnotsettingApproval = true;
    }

    //'Cancel button' is clicked
    cancelUserModal(){
    this.selectedUserList = [];
    this.isEmptySelectedUserList = true;
    this.afterSaveCredentials = false;
    this.showSearchBar = false;
    this.fromEntries = 1;
    }

    // show search bar
    displaySearch(){
        this.showSearchBar = true;
    }

    // hide search bar
    hideSearch(){
        this.showSearchBar =false;
        if(this.setting.Approval == true){
            this.settingApproval = true;
            this.getUsersListHelper();
        }else{
            this.settingApproval = false;
        }
    }

    //'Save button' is clicked
    saveSettings(){
        try{
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

        if (this.isEveryInputValid) {
           this.saveCredSettings_Helper();
        }

    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // call this.SendSFUserToTT_Helper
    SendSFUserToTT(){
        try{
    this.selectedRows = this.selectedUserList;
    this.listofUserId = [];
    for (var i = 0; i < this.selectedRows.length; i++) {
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
    SendSFUserToTT_Helper(){
            this.isShowSpinner = true;

            sendSFUserToTT({ sfUserList : this.selectedRows,
                listofUserId : this.listofUserId })
            .then((result) => {
                this.isShowSpinner = false;
                var storedResponse = result;
                if(storedResponse != null){
                    var res = storedResponse.split("+");
                    if(res[0] == 'error' && parseInt(res[1]) > 1 ){
                        this.displayToast('error',Unable_Create_Some_User_Toast);
                    }else if (res[0] == 'error' && parseInt(res[1]) == 1 ){
                        this.displayToast('error',Unable_Create_User_Toast);
                    }else if (res[0] == 'success'){
                        this.displayToast('success',Sent_SuccessToast);
                    }else{
                        this.displayToast('error',Something_Wrong_Check_Admin_Toast);
                   }
                   this.afterSaveCredentials = false;
                }
            })
            .catch((error) => {
              this.error = error.message;
              this.displayToast('error',this.error);

            });
    }

    // change page (Pagination)
    changePage() {
        try{
        this.currentPage = this.pageNumber;
        if(this.currentPage <= 1){
             this.currentPageLessEqual1 = true;
        }else{
            this.currentPageLessEqual1 = false;   
        }
        if(this.currentPage == this.totalPages){
            this.currentPageEqualTtotalPages = true;
        }else{
            this.currentPageEqualTtotalPages = true;
        }
        var numberOfRecords = this.showEntries;
        var recordToShowEnd = parseInt(this.pageNumber) * parseInt(numberOfRecords);
        var recordToShowStart = parseInt(recordToShowEnd) - parseInt(numberOfRecords);
        var filteredRecords = this.filteredRecords;
        var newRecordsToShow = [];
        for (var i = 0; i < filteredRecords.length; i++) {
            var filteredRecord = filteredRecords[i];
            if(parseInt(i) >= parseInt(recordToShowStart) && parseInt(i) < parseInt(recordToShowEnd)) {
                newRecordsToShow.push(filteredRecord);
            }
        }
        this.listdata = newRecordsToShow;
        this.fromEntries = parseInt(recordToShowStart) + 1;
        if(parseInt(recordToShowEnd) > parseInt(filteredRecords.length)) {
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
        if(this.showAdvancedOptions == true){
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
            if(storedResponse.adminCredentials == null){
                this.displayToast('error','Registration request sent');
            }
            if(storedResponse.adminCredentials.Registration_Successful ==  true && storedResponse.adminCredentials.Registration_Request_Expiry == null && storedResponse.adminCredentials.Registration_DateTime == null){
                if(storedResponse.adminCredentials.Registration_Request_Expiry == 0){
                    this.showContactMessage = true;
                    this.showRegistrationMessage = false;
                    return;
                }
                this.showRegistrationMessage = true;


                var endTime = parseInt(storedResponse.adminCredentials.Registration_DateTime) + storedResponse.adminCredentials.Registration_Request_Expiry;
                var remainingTimeInSecs = endTime - parseInt(Date.now()/1000);
                if(remainingTimeInSecs > 0){
                    this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(11, 8);
                    this.startTimer();
                }else if(remainingTimeInSecs <= 0){
                    remainingTimeInSecs = 0;
                    this.ltngTimer = new Date(remainingTimeInSecs * 1000).toISOString().substring(11, 8);
                    this.resendBtnDisabled = false;
                }
        }
        })
        .catch((error) => {
        this.error = error.message;
        this.displayToast('error','Registration request could not be sent');
        });
    }
    
    // checkbox is selected
    checkboxSelect(event) {
        try{
        // on each checkbox selection update the selected record count
        var getSelectedNumber;
        var selectedRec = event.target.checked;
        if(this.selectedCount != null){
            getSelectedNumber = this.selectedCount;
        }else{
            getSelectedNumber = 0;
        }
        if (selectedRec == true) {
            this.ListID.push(event.target.value);
            getSelectedNumber++;
        }else{
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
        if(this.selectedUserList.length == 0){
            this.isEmptySelectedUserList = true;
        }else{
            this.isEmptySelectedUserList = false;
        }
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }
    // onchange search bar
    searchKeyword(event) {
        this.searchValue = event.target.value;
        if((this.searchValue.length >2 && this.searchValue!= null)||(this.searchValue == '')){
            this.searchUsersHelper();
        }
    }

    // search for users
    searchUsersHelper(){
        try{
        if(this.searchValue == '' || this.searchValue == null){
            if(this.setting.Approval == true){
                this.settingApproval = true;
                this.getUsersListHelper();
            }else{
                this.settingApproval = false;
            }
        }else{
            var allRecords = this.filteredRecords;
            var tempArray =[];
            for(var i=0; i<allRecords.length; i++){
                if(allRecords[i].Email.toUpperCase().includes(this.searchValue.toUpperCase()) || allRecords[i].Username.toUpperCase().includes(this.searchValue.toUpperCase())){
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
    handleSetting_Client_IDChange(event){
        try{
        this.setting_Client_ID = event.target.value;
        this.setting_Client_ID = this.setting_Client_ID.trim();
        this.setting_Client_ID = this.setting_Client_ID.replaceAll(' ','');
        event.target.value = this.setting_Client_ID;
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // Onchange Client Secret
    handleSetting_Client_Secret(event){
        try{
        this.setting_Client_Secret = event.target.value;
        this.setting_Client_Secret = this.setting_Client_Secret.trim();
        this.setting_Client_Secret = this.setting_Client_Secret.replaceAll(' ','');
        event.target.value = this.setting_Client_Secret;
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // Onchange Instance_URL
    handleSetting_Instance_URL(event){
        try{
        this.setting_Instance_URL = event.target.value;
        var strTemp = this.setting_Instance_URL;
        strTemp = strTemp.trim();
        strTemp = strTemp.replaceAll(' ','');
        if(strTemp.includes('WWW.')){
            strTemp = strTemp.replace('WWW.','')
        }
        if(strTemp.includes('www.')){
            strTemp = strTemp.replace('www.','')
        }
        if(strTemp.slice(0, 4).toUpperCase() != 'HTTP' && strTemp.includes('://')){
            strTemp = 'https'+strTemp.substring(strTemp.indexOf('://'),strTemp.length);
        }
        if(strTemp.includes('://')){
            strTemp = strTemp.substring(0,strTemp.indexOf('.com')+4);
        }
        this.setting_Instance_URL = strTemp;
        event.target.value = strTemp;
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }

    // Onchange Authentication_URL
    handlesetting_Authentication_URL(event){
        try{
        this.setting_Authentication_URL = event.target.value;
        var strTemp = this.setting_Authentication_URL;
        strTemp = strTemp.trim();
        strTemp = strTemp.replaceAll(' ','');
        if(strTemp.includes('WWW.')){
            strTemp = strTemp.replace('WWW.','')
        }
        if(strTemp.includes('www.')){
            strTemp = strTemp.replace('www.','')
        }
        if(strTemp.slice(0, 4).toUpperCase() != 'HTTP' && strTemp.includes('://')){
            strTemp = 'https'+strTemp.substring(strTemp.indexOf('://'),strTemp.length);
        }
        if(strTemp.includes('://')){
            strTemp = strTemp.substring(0,strTemp.indexOf('.com')+4);
        }
        this.setting_Authentication_URL = strTemp;
        event.target.value = strTemp;
    } catch (e) {
        throw new CustomException(e.getMessage());
    }
    }
}