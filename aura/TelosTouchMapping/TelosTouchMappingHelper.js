({
    doInit_Helper: function (c, e, h) {
        try{
            c.set("v.isSpin",true);
            var action = c.get("c.getTelosTouchFields");
            action.setParams({
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.TTFieldsList",storedResponse);
                        c.set("v.clientsTelosTouchFields",storedResponse);
                        h.getObjectFields_Helper(c, e, h, 'Contact');
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    } 
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    addCustomFields: function (c, e, h) {
        //Remove all the Object Fields which are already created in Telostouch
        var AllOptionList = c.get("v.listOptions");
        var alreadyMappedList = c.get("v.mappingList");
        for (var j = 0; j < alreadyMappedList.length; j++) {
            for (var i = 0; i < AllOptionList.length; i++) {
                var obj1 = alreadyMappedList[j];//For storing Already Mapped Object
                var obj2 = AllOptionList[i];
                if((obj2.value == obj1.TelosTouchSF__Salesforce_Field__c) || (obj2.value == 'TelosTouchSF__TT_Client_Id__c') ){
                    AllOptionList.splice(i,1);
                }
            }
        }
        if(AllOptionList != undefined && AllOptionList !='' && AllOptionList.length >0){
            c.set("v.listOptions",AllOptionList);
            c.set("v.isModalOpen",true);
        }else{
            h.showToast_Helper(c, 'error', $A.get("$Label.c.No_Custom_Field_Toast"));
        }
        
    },
    addDeletedFields: function(c, e, h){
        h.populateDeletedFields(c, e, h);
    },
    getTaskFieds_Helper: function (c, e, h) {
        try{
            var action = c.get("c.getTelosTouchTaskFields");
            action.setParams({
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.TTFieldsList",storedResponse);
                        h.getObjectFields_Helper(c, e, h, 'Task');
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    } 
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    
    getObjectFields_Helper: function (c, e, h, selectedObjectName) {
        c.set('v.isSpin', true);
        c.set("v.objectFieldsList","");
        if (selectedObjectName === undefined) {
            c.set("v.objectFieldsList", undefined);
        } else {
            var action = c.get("c.getObjectAllFields");
            action.setParams({
                "selectedObjectName": selectedObjectName
            });
            action.setCallback(this, function (r) {
                c.set('v.isSpin', false);
                if (r.getState() === 'SUCCESS') {
                    var storedResponse = r.getReturnValue();
                    if(storedResponse != null && !$A.util.isEmpty(storedResponse)){
                        var fieldsList = c.get("v.objectFieldsList");
                        c.set("v.objectFieldsList", storedResponse.sort());
                        var resultArray = r.getReturnValue();
                        var options = [];
                        resultArray.forEach(function(result)  { 
                            options.push({ value: result.fieldAPIName, label: result.fieldName});
                        });
                        c.set("v.listOptions", options);
                        if(selectedObjectName === 'Contact')
                            h.refreshTTFieldsContact(c,e,h);
                        else if(selectedObjectName === 'Lead')
                            h.refreshTTFieldsLead(c,e,h);
                        h.getExistingMapping_Helper(c, e, h);  
                    }
                } 
            });
            $A.enqueueAction(action);
        }
    },
    populateDeletedFields : function(c, e, h){
        try{
            var action = c.get('c.populateDeletedFieldsApex');
            action.setParams({
                'objectName' : c.get('v.selectedObject')
            });
            action.setCallback(this, (res)=>{
                if(res.getState() === 'SUCCESS'){
                    var response = res.getReturnValue();
                	var mappingList = c.get('v.mappingList');
                    if(response != null && !$A.util.isEmpty(response)){
                		var newResponse = [];
                		for(var i in response){
                			var flag = false;
                			for(var j in mappingList){
                                if(response.length > 0 && response[i].sfField != undefined && response[i].sfField != null &&
                					mappingList[j].TelosTouchSF__Salesforce_Field__c != undefined && mappingList[j].TelosTouchSF__Salesforce_Field__c != null){
                                	if(response[i].sfField === mappingList[j].TelosTouchSF__Salesforce_Field__c){
                                        flag=true;
                						break;
                            		}
                            	}
            				}
                			if(flag === false){
                				newResponse.push(response[i]);
            				}
            			}
                    }
                    if(newResponse != null && !$A.util.isEmpty(newResponse)){
                        c.set('v.deletedFieldsList', newResponse);
                        c.set("v.isSpin",false);
                        c.set("v.showDeletedFieldsTable", true);
            		}
                    else{
                        c.set("v.isSpin",false);
                        h.showToast_Helper(c, 'error', $A.get("$Label.c.No_Standard_Field_Toast"));
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(e){
        }
    },
        addFieldsToMapping_helper : function(c, e, h){
            try{
                var selectedObject = c.get('v.selectedObject');
                var action = c.get('c.addDeletedFieldsToMappingApex');
                action.setParams({
                    'mappingIdStr' : JSON.stringify(c.get('v.fieldsToAdd'))
                });
                action.setCallback(this, (res)=>{
                    if(res.getState() === 'SUCCESS'){
                    var response = res.getReturnValue();
                    if(response != null && !$A.util.isEmpty(response) && response != false){
                    if(selectedObject === 'Contact')
                    h.refreshTTFieldsContact(c,e,h);
                    else if(selectedObject === 'Lead')
                    h.refreshTTFieldsLead(c,e,h);
                    else if(selectedObject === 'Task')
                    h.getTaskFieds_Helper(c,e,h);
                    h.getExistingMapping_Helper(c,e,h);
                    c.set('v.showDeletedFieldsTable', false);
                    h.showToast_Helper(c, 'success', $A.get("$Label.c.Mapped_SF_field_Toast"));
                }
                                   }
                                   });
                $A.enqueueAction(action);
            }
            catch(e){
            }
        },
    refreshTTFieldsContact : function(c, e, h){
        try{
            var action = c.get("c.getTelosTouchFields");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.TTFieldsList",storedResponse);
                        c.set("v.clientsTelosTouchFields",storedResponse);
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    }
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    refreshTTFieldsLead : function(c, e, h){
        try{
            var action = c.get("c.getTelosTouchLeadFields");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storedResponse = response.getReturnValue();
                    if(!$A.util.isEmpty(storedResponse) && storedResponse != undefined && storedResponse != null){
                        c.set("v.TTFieldsList",storedResponse);
                        c.set("v.clientsTelosTouchFields",storedResponse);
                    }
                }
                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    }
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                }
            });
            $A.enqueueAction(action);
        } catch (ex) {
        }
    },
    
    getExistingMapping_Helper: function (c, e, h) {
        c.set('v.isSpin', true);
        var selectedObject = c.get("v.selectedObject");
        var action = c.get("c.getExistingMappingApex");
        action.setParams({
            "selectedObject" : selectedObject,
        });
        action.setCallback(this, function (r) {
            c.set('v.isSpin', false);
            if (r.getState() === 'SUCCESS') {
                var mappingList = [];
                c.set("v.mappingList", mappingList);
                var storedResponse = r.getReturnValue();
                c.set("v.ExistingTT_FF_Field", storedResponse);
                var TTFieldsList = c.get("v.TTFieldsList");
                var customfieldlist = [];
                var objectFieldsList = c.get("v.objectFieldsList");
                if (storedResponse !== null && !$A.util.isEmpty(storedResponse)) {
                    var objectFieldsList = [];
                    for (var j = 0; j < storedResponse.length; j++) {
                        var obj1 = storedResponse[j];
                        if(obj1.TelosTouchSF__TT_Field__c =='Custom Fields'){
                            var mappingObj1 = {};
                            mappingObj1.isRequired = 'false'; 
                            mappingObj1.TelosTouchSF__TT_Field__c = 'Custom Fields';
                            mappingObj1.fieldNameTT = 'Custom Field';
                            mappingObj1.TelosTouchSF__Salesforce_Field__c = obj1.TelosTouchSF__Salesforce_Field__c;
                            mappingObj1.TelosTouchSF__Is_Sync_Empty_Field__c = obj1.TelosTouchSF__Is_Sync_Empty_Field__c;
                            customfieldlist.push(mappingObj1);
                            
                        }
                    }
                    for (var i = 0; i < TTFieldsList.length; i++) {
                        var obj = TTFieldsList[i];
                        var isFound = false;
                        for (var j = 0; j < storedResponse.length; j++) {
                            var obj1 = storedResponse[j];
                            
                            if (obj1.TelosTouchSF__TT_Field__c == obj.fieldAPINameTT) {
                                isFound = true;
                                var mappingObj = {};
                                var selectedObject = c.find('select').get('v.value');
                                mappingObj.isRequired = 'false';
                                if((obj1.TelosTouchSF__TT_Field__c =='first_name') || (obj1.TelosTouchSF__TT_Field__c =='last_name') || (obj1.TelosTouchSF__TT_Field__c =='email') ){
                                    mappingObj.isRequired = 'true'; 
                                }
                                else{
                                    mappingObj.isRequired = 'false'; 
                                }
                                if(obj1.TelosTouchSF__isDuplicateCreated__c === true){
                                    mappingObj.isDuplicateCreated = true;
                                }else{
                                    mappingObj.isDuplicateCreated = false;
                                }
                                if((selectedObject == 'Task') && ((obj1.TelosTouchSF__TT_Field__c =='name')
                                                                  || (obj1.TelosTouchSF__TT_Field__c =='client_id') || (obj1.TelosTouchSF__TT_Field__c =='date_due') || (obj1.TelosTouchSF__TT_Field__c=='client_name')|| (obj1.TelosTouchSF__TT_Field__c=='shared') || (obj1.TelosTouchSF__TT_Field__c =='status') )){
                                    mappingObj.isRequired = 'true'; 
                                }   
                                mappingObj.sobjectType = 'TelosTouchSF__TT_Salesforce_Mapping__c';
                                mappingObj.TelosTouchSF__TT_Field__c = obj1.TelosTouchSF__TT_Field__c;
                                mappingObj.fieldNameTT = obj.fieldNameTT;
                                mappingObj.TelosTouchSF__Salesforce_Field__c = obj1.TelosTouchSF__Salesforce_Field__c;
                                mappingObj.TelosTouchSF__Is_Sync_Empty_Field__c = obj1.TelosTouchSF__Is_Sync_Empty_Field__c;
                                mappingList.push(mappingObj);
                            }
                        }
                        if (!isFound) {
                            var mappingObjNotFound = {};
                            mappingObjNotFound.isRequired = 'false'; 
                            var selectedObject = c.find('select').get('v.value');
                            if((obj.fieldAPINameTT =='first_name') || (obj.fieldAPINameTT =='last_name') || (obj.fieldAPINameTT =='email')){
                                mappingObjNotFound.isRequired = 'true'; 
                            }
                            if((selectedObject == 'Task') && ((obj.fieldAPINameTT =='name') || (obj.fieldAPINameTT =='client_id') || (obj.fieldAPINameTT == 'client_name') || (obj.fieldAPINameTT =='date_due') || (obj.fieldAPINameTT=='shared') || (obj.fieldAPINameTT=='status'))){
                                mappingObjNotFound.isRequired = 'true'; 
                            }   
                            mappingObjNotFound.TelosTouchSF__Is_Sync_Empty_Field__c = obj.TelosTouchSF__Is_Sync_Empty_Field__c;
                            mappingObjNotFound.TelosTouchSF__TT_Field__c = obj.fieldAPINameTT;
                            mappingObjNotFound.fieldNameTT = obj.fieldNameTT;
                            mappingObjNotFound.sobjectType = 'TelosTouchSF__TT_Salesforce_Mapping__c';
                            mappingList.push(mappingObjNotFound);
                        }
                    }
                }else{
                    for (var i = 0; i < TTFieldsList.length; i++) {
                        var mappingObjNotFound = {};
                        if((TTFieldsList[i].fieldAPINameTT =='first_name') || (TTFieldsList[i].fieldAPINameTT =='last_name')  || (TTFieldsList[i].fieldAPINameTT =='email') || (TTFieldsList[i].fieldAPINameTT =='phone') || (TTFieldsList[i].fieldAPINameTT =='language') || (TTFieldsList[i] =='subscribed')){
                            mappingObjNotFound.isRequired = 'true'; 
                        }
                        if((selectedObject == 'Task') && ((TTFieldsList[i].fieldAPINameTT =='name') || (TTFieldsList[i].fieldAPINameTT =='date_due')
                                                          || (TTFieldsList[i].fieldAPINameTT =='client_id') || (TTFieldsList[i].fieldAPINameTT == 'client_name')  || (TTFieldsList[i].fieldAPINameTT == 'description')  || (TTFieldsList[i].fieldAPINameTT == 'shared') || (TTFieldsList[i].fieldAPINameTT == 'status'))){
                            mappingObj.isRequired = 'true'; 
                        }   
                        mappingObjNotFound.TelosTouchSF__Is_Sync_Empty_Field__c = obj.TelosTouchSF__Is_Sync_Empty_Field__c;
                        mappingObjNotFound.TelosTouchSF__TT_Field__c = TTFieldsList[i].fieldAPINameTT;
                        mappingObjNotFound.fieldNameTT = TTFieldsList[i].fieldNameTT;
                        mappingObjNotFound.sobjectType = 'TelosTouchSF__TT_Salesforce_Mapping__c';
                        mappingList.push(mappingObjNotFound);
                    }
                }
                c.set("v.mappingList", mappingList.concat(customfieldlist));
                var objectFieldsList = c.get("v.objectFieldsList");
                for (var i = 0; i < objectFieldsList.length; i++) {
                    var obj2 = objectFieldsList[i];
                    var isFound = false;
                    for (var j = 0; j < mappingList.length; j++) {
                        var obj3 = mappingList[j];
                        if (obj3.TelosTouchSF__Salesforce_Field__c === obj2.field) {
                            isFound = true;
                        }
                    }
                    if (!isFound) {
                    }
                }
                c.set("v.objectFieldsList", objectFieldsList);
            } 
        });
        $A.enqueueAction(action);
    },
    FieldSelected_Helper: function (c, e, h) {
        try{
            var ExistingTT_FF_Field = c.get("v.ExistingTT_FF_Field");
            var mappingList = c.get("v.mappingList");
            var saveTTandSF_Field = [];
            var count = 0;
            c.set("v.duplicateFields",false);
            for (var i = 0; i < mappingList.length; i++) {
                var selectedObject = e.getSource().get("v.value");
                if(selectedObject == mappingList[i].TelosTouchSF__Salesforce_Field__c){
                    count++;
                    if( count > 1){
                        for (var i = 0; i < ExistingTT_FF_Field.length; i++) {
                            if(mappingList[i].TelosTouchSF__TT_Field__c == ExistingTT_FF_Field[i].TelosTouchSF__TT_Field__c ){
                                mappingList[i].TelosTouchSF__Salesforce_Field__c =  ExistingTT_FF_Field[i].TelosTouchSF__Salesforce_Field__c;
                                h.showToast_Helper(c,'error',$A.get("$Label.c.Cannot_Add_Duplicate_Field_Toast"));
                                c.set("v.duplicateFields",true);
                            }
                        } if(mappingList[i].TelosTouchSF__Salesforce_Field__c != ""){
                            saveTTandSF_Field.push(mappingList[i]);
                        }
                    }else if(mappingList[i].TelosTouchSF__Salesforce_Field__c != ""){
                        saveTTandSF_Field.push(mappingList[i]);
                    }
                }
                else if(mappingList[i].TelosTouchSF__Salesforce_Field__c != ""){
                    saveTTandSF_Field.push(mappingList[i]);
                }
            }
            c.set("v.saveTTandSF_Field", saveTTandSF_Field);
           
        }catch(ex){
        }
    },
    
    saveFieldsMapping_Helper: function (c, e, h) {
        try{
            c.set('v.isSpin', true);
            var selectedObject = c.get("v.selectedObject");
            var saveTTandSF_Field = c.get("v.saveTTandSF_Field");
            if(saveTTandSF_Field != null){
                for(var i=0;i<saveTTandSF_Field.length;i++){
                    delete saveTTandSF_Field[i].fieldNameTT;
                }
                var action = c.get("c.saveFieldsMappingApex");
                action.setParams({
                    "mappingList": saveTTandSF_Field,
                    "selectedObject" : selectedObject,
                });
                action.setCallback(this, function (r) {
                    c.set('v.isSpin', false);
                    if (r.getState() === 'SUCCESS') {
                        var storedResponse = r.getReturnValue();
                        if(storedResponse == true){
                            c.set("v.isDisabled",true);
                            c.set("v.isChangeField",true);
                            c.set("v.isEditField",false);
                            h.getExistingMapping_Helper(c,e,h);
                            h.showToast_Helper(c,'success',$A.get("$Label.c.Field_Mapping_Saved_Toast"));
                        }else{
                            h.showToast_Helper(c,'error',$A.get("$Label.c.Something_Went_Wrong"));
                        }
                    } else {
                        h.showToast_Helper(c,'error',r.getError());
                    }
                });
                $A.enqueueAction(action);
            }
        }catch(ex){
        }
    },    
    
    AddCustomFields_Helper: function (c, e, h, listofSelectedFields) {
        try{
            var selectedObject = c.find('select').get('v.value');
            var action = c.get("c.sendCustomFieldsSFToTT");
            action.setParams({
                "Selectedfieldslist": listofSelectedFields,
                "objectName": selectedObject
            });
            action.setCallback(this, function(response) {
                c.set("v.isModalOpen",false); 
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();
                    if(allValues != null && allValues != undefined && allValues != false){
                        if(selectedObject === 'Contact'){
                            h.refreshTTFieldsContact(c,e,h);
                        }
                        else if(selectedObject === 'Lead')
                            h.refreshTTFieldsLead(c,e,h);
                        h.getExistingMapping_Helper(c,e,h);
                        var customfieldList = c.get("v.selectedArray");
                        customfieldList.splice(0, customfieldList.length);
                        c.set("v.selectedArray", customfieldList);
                        h.showToast_Helper(c,'success',$A.get("$Label.c.SF_Field_Create_Toast"));
                    }
                    else{
                        h.showToast_Helper(c,'error',$A.get("$Label.c.Tech_Error_Toast"));
                    }
                    
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Tech_Error_Toast"));
                }
            });
            $A.enqueueAction(action);
        }
        catch(ex){
        }
    },
   
    deleteSelectedCustomField_Helper: function (c, e, h, listofSelectedFields) {
        try{
            var selectedObject = c.find('select').get('v.value');
            var action = c.get("c.deleteCustomFields");
            action.setParams({
                "selectedfieldslist": listofSelectedFields,
                "objectName": selectedObject
            });
            action.setCallback(this, function(response) {
                c.set("v.deleteCustomField",false); 
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();
                    if(allValues != null && allValues != undefined && allValues != false){
                        var getMappings = c.get("v.saveTTandSF_Field");
                        var saveTTandSF_Field = [];
                        if(getMappings != undefined && getMappings != ''){
                            for (var i = 0; i < getMappings.length; i++) {
                                c.set("v.saveTTandSF_Field", []);
                                if(getMappings[i].TelosTouchSF__TT_Field__c != listofSelectedFields[0]){
                                    saveTTandSF_Field.push(getMappings[i]);
                                }
                            }
                            c.set("v.saveTTandSF_Field", saveTTandSF_Field);  
                        }
                        if(selectedObject === 'Contact'){
                            h.refreshTTFieldsContact(c,e,h);
                        }else if(selectedObject === 'Lead'){
                            h.refreshTTFieldsLead(c,e,h);
                        }else if(selectedObject === 'Task'){
                                h.getTaskFieds_Helper(c,e,h);
                            }
                        h.getExistingMapping_Helper(c,e,h);
                        h.getObjectFields_Helper(c,e,h,selectedObject);
                        var customfieldList = c.get("v.customFieldsTobeDeleted");
                        customfieldList.splice(0, customfieldList.length);
                        c.set("v.customFieldsTobeDeleted", customfieldList);
                        h.showToast_Helper(c,'success',$A.get("$Label.c.Field_Deleted_Toast"));
                    }
                }else{
                    h.showToast_Helper(c,'error',$A.get("$Label.c.Tech_Error_Toast"));
                }
            });
            $A.enqueueAction(action);
        }
        catch(ex){
        }
    },
        showToast: function (c, e, h, type, message,time) {
            c.set("v.isShowTost",true);
            c.set("v.messageHeader",type);
            c.set("v.message",message);
            window.setTimeout(
                $A.getCallback(function() {
                    c.set("v.isShowTost",false);
                }), time);
        },
            showToast_Helper: function (c, variant, message) {
                c.set('v.variant', variant);
                c.set('v.message', message);
                c.set('v.showToast', true);
            },
    setRecordOwnerFlagHelper: function(c, e, h, useCreatedByIdFlag){
        try{
            var action = c.get("c.setUseCreatedByIdFlag");
            action.setParams({
                "flag": useCreatedByIdFlag
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    if(response.getReturnValue() === true){
                        if(useCreatedByIdFlag === true){
                            h.showToast_Helper(c,'success',$A.get("$Label.c.Record_Creator_Assigned_Label"));
                        }else{
                            h.showToast_Helper(c,'success',$A.get("$Label.c.Record_Owner_Assigned_Label"));
                        }
                    }
                }else{
                    h.showToast_Helper(c,'error','Please Try Again!');
                }
            });
            $A.enqueueAction(action);
        }catch(e){

        }
    },
    addDuplicateMappingHelper: function(c, e, h, TTFieldName){
        try{
            var action = c.get("c.addDuplicateMappingApex");
            action.setParams({
                "TTFieldName": TTFieldName,
                "SelectedObject": c.get("v.selectedObject")
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    if(response.getReturnValue() === true){
                        h.showToast_Helper(c,'success','Duplicate Mapping Created');
                        h.getObjectFields_Helper(c, e, h, 'Contact');
                    }else{
                        h.showToast_Helper(c,'error','Duplicate Mapping Creation Failed');
                    }
                }else{
                    h.showToast_Helper(c,'error','Duplicate Mapping Creation Failed');
                }
            });
            $A.enqueueAction(action);
        }catch(e){
        }
    },
    getUseCreatedByIdFlag: function(c, e, h){
        var action = c.get("c.getUseCreatedByIdFlag");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                c.set('v.useCreatedByIdFlag', response.getReturnValue());
            }else{
                c.set('v.useCreatedByIdFlag', true);
            }
        });
        $A.enqueueAction(action);
    }
})