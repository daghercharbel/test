({
    doInit_Helper: function (c, e, h,flag) {
        try{
            c.set("v.isShowSpinner",true);
            var settingsObj = c.get("v.setting");
            var action = c.get("c.getSettingAPI");
            action.setParams({
                isCallingFrom : 'DoinitFromSetup'
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    //console.log(storedResponse);
                    if(!$A.util.isEmpty(storedResponse) && !$A.util.isEmpty(storedResponse.adminCredentials.Client_ID)
                        && !$A.util.isEmpty(storedResponse.adminCredentials.Client_Secret) && !$A.util.isEmpty(storedResponse.adminCredentials.Instance_URL)
                        && storedResponse != undefined && storedResponse != null){
                        if(!$A.util.isEmpty(storedResponse.adminCredentials) && storedResponse.adminCredentials != undefined && storedResponse.adminCredentials != null){
                            c.set("v.setting",storedResponse.adminCredentials);
                            var allValid = c.find('formId').reduce(function (validFields, inputCmp) {
                                var result = inputCmp.get("v.value");
                                inputCmp.showHelpMessageIfInvalid();
                                return validFields && inputCmp.get('v.validity').valid;
                            }, true);
                        }
                    }else{
                        h.showToast(c,e,h,'error',$A.get("$Label.c.Enter_Valid_Cred_Toast"),4000);
                        var setting = {};
                        setting.Access_Token = null;
                        setting.Approval = null;
                        setting.Client_ID = null;
                        setting.Client_Secret = null;
                        setting.Instance_URL = storedResponse.adminCredentials.Instance_URL;
                        setting.Refresh_Token = null;
                        setting.Admin_Username = null;
                        setting.Admin_Password = null;
                        setting.Authentication_URL = storedResponse.adminCredentials.Authentication_URL;

                        c.set('v.setting', setting);

                        if(storedResponse.adminCredentials.Registration_Successful && !$A.util.isUndefinedOrNull(storedResponse.adminCredentials.Registration_Request_Expiry)
                            && !$A.util.isEmpty(storedResponse.adminCredentials.Registration_Request_Expiry) && !$A.util.isUndefinedOrNull(storedResponse.adminCredentials.Registration_DateTime)
                            && !$A.util.isEmpty(storedResponse.adminCredentials.Registration_DateTime)){
                            if(storedResponse.adminCredentials.Registration_Request_Expiry == 0){
                                c.set("v.showContactMessage", true);
                                c.set("v.showRegistrationMessage", false);
                                return;
                            }
                            c.set("v.showRegistrationMessage", true);
                            var endTime = parseInt(storedResponse.adminCredentials.Registration_DateTime) + storedResponse.adminCredentials.Registration_Request_Expiry;
                            var remainingTimeInSecs = endTime - parseInt(Date.now()/1000);
                            if(remainingTimeInSecs > 0){
                                c.set("v.ltngTimer", new Date(remainingTimeInSecs * 1000).toISOString().substr(11, 8));
                                h.startTimer(c,e,h);
                            }else if(remainingTimeInSecs <= 0){
                                remainingTimeInSecs = 0;
                                c.set("v.ltngTimer", new Date(remainingTimeInSecs * 1000).toISOString().substr(11, 8));
                                c.set("v.resendBtnDisabled", false);
                            }
                        }
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast(c,e,h,'error',response.getError(),4000);
                        }
                    }
                }else{
                    h.showToast(c,e,h,'error',response.getError(),4000);
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            //console.log(ex);
        }
    },
    waitingTimeId: null,
    startTimer : function(c, e, h) {
        var currTime =c.get("v.ltngTimer");
        var ss = currTime.split(":");
        var dt = new Date();
        dt.setHours(ss[0]);
        dt.setMinutes(ss[1]);
        dt.setSeconds(ss[2]);

        var dt2 = new Date(dt.valueOf() - 1000);
        var temp = dt2.toTimeString().split(" ");
        var ts = temp[0].split(":");

        c.set("v.ltngTimer",ts[0] + ":" + ts[1] + ":" + ts[2]);
        this.waitingTimeId =setTimeout($A.getCallback(() => this.startTimer(c, e, h)), 1000);
        if(ts[0]==0 && ts[1]==0 && ts[2]==0 ){
            window.clearTimeout(this.waitingTimeId);
            c.set("v.resendBtnDisabled", false);
        }
    },
    saveCredSettings_Helper: function (c, e, h) {
        try{
            c.set("v.isShowSpinner",true);
            var settingAPIList = c.get("v.settingAPIList");
            var settingsObj = c.get("v.setting");
            settingAPIList.push(settingsObj);
            //console.log(JSON.stringify(settingsObj));
            var action = c.get("c.getAdminAccessToken");
            action.setParams({
                apiSetting : JSON.stringify(settingAPIList),
                isCallingFrom : 'From Setup'
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    c.set("v.settingAPIList",[]);
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        if(storedResponse.errorMessage == 'Not Admin'){
                            c.set("v.setting",storedResponse.adminCredentials);
                            h.showToast(c,e,h,'error',$A.get("$Label.c.Cred_Not_Valid_As_Admin_Contact_Admin"),4000);
                            return;
                        }
                        if(storedResponse.errorMessage == 'This user is not validate with TT.'){
                            c.set("v.setting",storedResponse.adminCredentials);
                            h.showToast(c,e,h,'error',$A.get("$Label.c.User_Not_Valid_Cannot_Auth_App"),4000);
                            return;
                        }
                        if(!$A.util.isEmpty(storedResponse.adminCredentials) && storedResponse.adminCredentials != undefined && storedResponse.adminCredentials != null){
                            c.set("v.setting",storedResponse.adminCredentials);
                            c.set("v.isEdit",false);
                            //h.scheduleAllJobs(c,e,h);
                            c.set("v.afterSaveCredentials",true);
                            h.showToast(c,e,h,'success',$A.get("$Label.c.Config_Save_Toast"),3000);

                        }else{
                            c.set("v.setting.TelosTouchSF__Approval__c",false);
                            h.abortScheduleJobs(c,e,h);
                            h.showToast(c,e,h,'error',$A.get("$Label.c.Check_Cred_Toast"),3000);
                        }
                        if(!$A.util.isEmpty(storedResponse.activeUserWrapper) && storedResponse.activeUserWrapper != undefined && storedResponse.activeUserWrapper != null){
                            var userArray = [];
                            for(var i=0;i<storedResponse.activeUserWrapper.length;i++){
                                storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                                storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                                if(storedResponse.activeUserWrapper[i].TTUser == $A.get("$Label.c.Yes_Text")){
                                    storedResponse.activeUserWrapper[i].userObject.isDisable = true;
                                }
                                userArray.push(storedResponse.activeUserWrapper[i].userObject);
                            }
                            c.set("v.data",userArray);
                            c.set('v.filteredRecords', c.get('v.data'));
                            c.set('v.allRecords', c.get('v.data'));
                        }
                        h.showRecords(c,e,h);
                    }else{
                        h.showToast(c,e,h,'error',$A.get("$Label.c.Check_Cred_Toast"),3000);
                    }
                }
                else if (state === 'ERROR'){
                    c.set("v.setting.TelosTouchSF__Approval__c",false);
                    //h.abortScheduleJobs(c,e,h);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast(c,e,h,'error',response.getError(),4000);
                        }
                    }
                }else{
                    h.showToast(c,e,h,'error',response.getError(),4000);
                }
            });
            $A.enqueueAction(action);

        } catch (ex) {
            //console.log(ex);
        }

    },
    getUsersListHelper: function (c, e, h) {
        c.set("v.isShowSpinner",true);
        var action = c.get("c.getUserList");
        action.setCallback(this, function (response) {
            c.set("v.isShowSpinner",false);
            if (response.getState() === 'SUCCESS') {
                var storedResponse = response.getReturnValue();
                if(!$A.util.isEmpty(storedResponse.activeUserWrapper) && storedResponse.activeUserWrapper != undefined && storedResponse.activeUserWrapper != null){
                    var userArray = [];
                    for(var i=0;i<storedResponse.activeUserWrapper.length;i++){
                        storedResponse.activeUserWrapper[i].userObject.Profile = storedResponse.activeUserWrapper[i].userProfile;
                        storedResponse.activeUserWrapper[i].userObject.TTUser = storedResponse.activeUserWrapper[i].TTUser;
                        if(storedResponse.activeUserWrapper[i].TTUser == $A.get("$Label.c.Yes_Text")){
                            storedResponse.activeUserWrapper[i].userObject.isDisable = true;
                        }
                        userArray.push(storedResponse.activeUserWrapper[i].userObject);
                    }
                    c.set("v.data",userArray);
                    c.set('v.filteredRecords', c.get('v.data'));
                    c.set('v.allRecords', c.get('v.data'));
                    h.showRecords(c,e,h);
                }
            }
        });
        $A.enqueueAction(action);
    },

    scheduleAllJobs: function (c, e, h) {
        var action = c.get("c.scheduleAllJobsFromHere");
        action.setCallback(this, function (r) {
            if (r.getState() === 'SUCCESS') {
                if( r.getReturnValue() =='success'){
                }
            }
        });
        $A.enqueueAction(action);
    },
    abortScheduleJobs: function (c, e, h) {
        var settingAPIList = c.get("v.settingAPIList");
        var settingsObj = c.get("v.setting");
        settingAPIList.push(settingsObj);
        var action = c.get("c.abortScheduleJob");
        action.setParams({
            apiSettingList : settingAPIList
        });
        action.setCallback(this, function (r) {
            if (r.getState() === 'SUCCESS') {
            }
        });
        $A.enqueueAction(action);
    },
    checkPostIntallBatch: function (c, e, h) {
        var action = c.get("c.checkIfPostInstallScriptRunning_APEX");
        action.setCallback(this, function (r) {
            if (r.getState() === 'SUCCESS') {
                if(r.getReturnValue() != null){
                    c.set("v.isPostInstallBatchRunning", r.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    },
    SendSFUserToTT_Helper: function (c, e, h,selectedSFUser,listofUserId) {
        try{
            c.set("v.isShowSpinner",true);
            var action = c.get("c.sendSFUserToTT");
            action.setParams({
                sfUserList : selectedSFUser,
                listofUserId : listofUserId
            });
            action.setCallback(this, function (response) {
                c.set("v.isShowSpinner",false);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse !=null){
                        var res = storedResponse.split("+");
                        if(res[0] == 'error' && parseInt(res[1]) > 1 ){
                            h.showToast(c,e,h,'error',$A.get("$Label.c.Unable_Create_Some_User_Toast"),3000);
                        }else if (res[0] == 'error' && parseInt(res[1]) == 1 ){
                            h.showToast(c,e,h,'error',$A.get("$Label.c.Unable_Create_User_Toast"),3000);
                        }else if (res[0] == 'success'){
                            h.showToast(c,e,h,'success',$A.get("$Label.c.Sent_SuccessToast"),4000);
                        }else{
                            h.showToast(c,e,h,'error',$A.get("$Label.c.Something_Wrong_Check_Admin_Toast"),3000);
                        }
                        c.set("v.afterSaveCredentials",false);
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " +errors[0].message);
                            h.showToast(c,e,h,'error',response.getError(),4000);
                            //    c.set('v.errorMessage',errors[0].message);
                        }
                    }
                }else{
                    h.showToast(c,e,h,'error',response.getError(),4000);
                    //console.log('Something went wrong, Please check with your admin');
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
            //console.log(ex);
        }
    },
    showRecords: function(c, e, h) {
        var records = c.get('v.filteredRecords');
        var from = c.get('v.fromEntries');
        var to = c.get('v.showEntries');

        c.set('v.currentPage', '1');
        if(records.length === 0) {
            c.set('v.fromEntries', '0');
            c.set('v.currentPage', '0');
        } else {
            c.set('v.fromEntries', '1');
        }
        c.set('v.totalPages', (Math.ceil(parseFloat(c.get('v.filteredRecords').length)/(parseFloat(c.get('v.showEntries')))).toString()));
        var newToEntry = to;
        if(parseInt(c.get('v.filteredRecords').length) < parseInt(c.get('v.showEntries'))) {
            newToEntry = parseInt(c.get('v.filteredRecords').length);
        } else {
            newToEntry = parseInt(c.get('v.showEntries'));
        }
        c.set('v.toEntries', newToEntry);

        if($A.util.isUndefinedOrNull(from) && records.length > 0) {
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
        c.set('v.data', finalRecords);
    },
    changePage: function (c, e, h, pageNumber) {
        c.set('v.currentPage', pageNumber);
        var numberOfRecords = c.get('v.showEntries');
        var recordToShowEnd = parseInt(pageNumber) * parseInt(numberOfRecords);
        var recordToShowStart = parseInt(recordToShowEnd) - parseInt(numberOfRecords);
        var filteredRecords = c.get('v.filteredRecords');
        var newRecordsToShow = [];
        for (var i = 0; i < filteredRecords.length; i++) {
            var filteredRecord = filteredRecords[i];
            if(parseInt(i) >= parseInt(recordToShowStart) && parseInt(i) < parseInt(recordToShowEnd)) {
                newRecordsToShow.push(filteredRecord);
            }
        }
        c.set('v.data', newRecordsToShow);
        c.set('v.fromEntries', parseInt(recordToShowStart) + 1);
        if(parseInt(recordToShowEnd) > parseInt(filteredRecords.length)) {
            c.set('v.toEntries', filteredRecords.length);
        } else {
            c.set('v.toEntries', recordToShowEnd);
        }
    },
    showToast: function (c, e, h, type, message,time) {
        c.set("v.isShowTost",true);
        c.set("v.messageType",type);
        c.set("v.message",message);
        window.setTimeout(
            $A.getCallback(function() {
                c.set("v.isShowTost",false);
            }), time);
    },
    searchUsersHelper: function(c, e, h){
        //console.log('value : '+document.getElementById("search").value);
        var searchFilter = document.getElementById("search").value;
        if($A.util.isEmpty(searchFilter)){
            if(c.get("v.setting.Approval")){
                h.getUsersListHelper(c, e, h);
            }
        }else{
            var allRecords = c.get("v.filteredRecords");
            var tempArray =[];
            for(var i=0; i<allRecords.length; i++){
                if(allRecords[i].Email.toUpperCase().includes(searchFilter.toUpperCase()) || allRecords[i].Username.toUpperCase().includes(searchFilter.toUpperCase())){
                    //console.log('allRecords[i].Username : '+allRecords[i].Username);
                    //console.log('searchFilter : '+searchFilter);
                    tempArray.push(allRecords[i]);
                }
            }
            c.set("v.data",tempArray);
        }
    },
    resendRegistrationRequest_helper : function(c ,e, h) {
        var action = c.get("c.sendRegistrationRequest");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                c.set("v.isShowSpinner",false);
                var storedResponse = {};
                storedResponse.adminCredentials = response.getReturnValue();
                if(!$A.util.isEmpty(storedResponse.adminCredentials) && !$A.util.isUndefinedOrNull(storedResponse.adminCredentials)){
                    h.showToast(c,e,h,'success','Registration request sent',4000);
                    if(storedResponse.adminCredentials.Registration_Successful && !$A.util.isUndefinedOrNull(storedResponse.adminCredentials.Registration_Request_Expiry)
                        && !$A.util.isEmpty(storedResponse.adminCredentials.Registration_Request_Expiry) && !$A.util.isUndefinedOrNull(storedResponse.adminCredentials.Registration_DateTime)
                        && !$A.util.isEmpty(storedResponse.adminCredentials.Registration_DateTime)){
                        if(storedResponse.adminCredentials.Registration_Request_Expiry == 0){
                            c.set("v.showContactMessage", true);
                            c.set("v.showRegistrationMessage", false);
                            return;
                        }
                        c.set("v.showRegistrationMessage", true);
                        var endTime = parseInt(storedResponse.adminCredentials.Registration_DateTime) + storedResponse.adminCredentials.Registration_Request_Expiry;
                        var remainingTimeInSecs = endTime - parseInt(Date.now()/1000);
                        if(remainingTimeInSecs > 0){
                            c.set("v.ltngTimer", new Date(remainingTimeInSecs * 1000).toISOString().substr(11, 8));
                            h.startTimer(c,e,h);
                        }else if(remainingTimeInSecs <= 0){
                            remainingTimeInSecs = 0;
                            c.set("v.ltngTimer", new Date(remainingTimeInSecs * 1000).toISOString().substr(11, 8));
                            c.set("v.resendBtnDisabled", false);
                        }
                    }
                }else{
                    h.showToast(c,e,h,'error','Registration request could not be sent',4000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    checkEnterpriseClient: function(c, e, h){
        var action = c.get("c.checkIfEnterpriseClient");
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                if(response.getReturnValue()){
                    c.set('v.notEnterpriseClient', false);
                }else{
                    c.set('v.notEnterpriseClient', true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})