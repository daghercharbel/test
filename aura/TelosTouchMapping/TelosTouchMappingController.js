({
    doInit: function (c, e, h) {
        var fieldsList  = c.get('v.addFieldsOptions');
        fieldsList.push({'label': $A.get("$Label.c.Custom_Fields_Text"), 'value': 'custom'});
        fieldsList.push({'label': $A.get("$Label.c.Standard_Fields_Text"), 'value': 'standard'});
        h.doInit_Helper(c, e, h);
        h.getUseCreatedByIdFlag(c, e, h);
        c.set("v.isDisabled",true);
    },
    fieldSelected: function (c, e, h) {
        c.set("v.isChangeField",false);
        h.FieldSelected_Helper(c,e ,h);
    },
    saveMapping: function (c, e, h) {
        var allValid = c.find('select2').reduce(function (validFields, inputCmp) {  
            inputCmp.showHelpMessageIfInvalid(); 
            return validFields && inputCmp.get('v.validity').valid;  
        }, true); 
        if (allValid && (c.get("v.duplicateFields") == false)) {
            h.saveFieldsMapping_Helper(c, e, h);
        }else{
            h.showToast_Helper(c,'error',$A.get("$Label.c.Cannot_Add_Duplicate_Field_Toast"));
        }
    },
    editMapping: function (c, e, h) {
        c.set("v.isEditField",true);
        c.set("v.isDisabled",false);
    },
    addDeletedFieldsHide: function(c, e, h){
        c.set("v.showDeletedFieldsTable", false);
    },
    addFieldsToMapping : function(c, e, h){
        var fieldsList = c.get('v.fieldsToAdd');
        if(fieldsList === null || $A.util.isEmpty(fieldsList))
            h.showToast_Helper(c, 'error', $A.get("$Label.c.Select_Add_At_Least_One_Field_Toast"));
        else
        	h.addFieldsToMapping_helper(c, e, h);
    },
    populateFieldsToAdd : function(c, e, h){
        try{
            var selectedOptionValue = e.getParam("value");
            c.set('v.fieldsToAdd', selectedOptionValue.toString());
        }
        catch(e){
            //console.log(e);
        }
    },
    revertBackToMainPage: function (c, e, h) {
        c.set("v.isEditField",false);
        c.set("v.isDisabled",true);
        c.set("v.isChangeField",true);
        h.getExistingMapping_Helper(c,e,h);
    },
    selectObject: function (c,e,h) {
        var selectedObject = c.find('select').get('v.value');
        c.set("v.selectedObject", selectedObject);
        if(selectedObject =='Task'){
            h.getTaskFieds_Helper(c,e,h);
        }else{
            c.set("v.TTFieldsList",c.get("v.clientsTelosTouchFields"));
            h.getObjectFields_Helper(c, e, h, selectedObject); 
        }
        
    },
    /*clearAll: function (c,e,h) {
        var mappingList = [];
        c.set("v.mappingList", mappingList);
        h.showToast_Helper(c,'success','All mapping is clear');
        var TTFieldsList = c.get("v.TTFieldsList");
        for (var i = 0; i < TTFieldsList.length; i++) {
            var mappingObjNotFound = {};
            mappingObjNotFound.TT_Field__c = TTFieldsList[i].fieldAPINameTT;
            mappingObjNotFound.fieldNameTT = TTFieldsList[i].fieldNameTT;
            mappingObjNotFound.sobjectType = 'TT_Salesforce_Mapping__c';
            mappingList.push(mappingObjNotFound);
        }
        c.set("v.mappingList", mappingList);
    },*/
    closeToast: function (c, e, h) {
        if(c.get("v.isShowTost")){
            c.set("v.isShowTost",false); 
        }else{
            c.set("v.isShowTost",true); 
        }
    },
    addStandardFields: function (c, e, h) {
        c.set("v.isOpen",true);
        var AllOptionList = c.get("v.standardlistOptions");
        var action = c.get("c.addingStandardFields");
        action.setParams({
        });
        action.setCallback(this, function(r) {
            if (r.getState() === 'SUCCESS') {
                var storedResponse = r.getReturnValue();
                if(storedResponse != null && !$A.util.isEmpty(storedResponse)){
                    var fieldsList = c.get("v.objectFieldsList");
                    c.set("v.objectFieldsList", storedResponse.sort());
                    var resultArray = r.getReturnValue();
                    var options = [];
                    resultArray.forEach(function(result)  { 
                        options.push({ value: result.TelosTouchSF__TT_Field__c, label: result.TelosTouchSF__TT_Field__c});
                    });
                    c.set("v.standardlistOptions", options);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.deleteCustomField", false);
        component.set("v.isOpen", false);
        var customfieldList = component.get("v.customFieldsTobeDeleted");
        customfieldList.splice(0, customfieldList.length);
        component.set("v.customFieldsTobeDeleted", customfieldList);
    },
    submitDetails: function(c, e, h) {
        var selectedOptionsList =  c.get("v.selectedArray");
        if((selectedOptionsList != undefined) && (selectedOptionsList.length > 0)){
            h.AddCustomFields_Helper(c,e,h,selectedOptionsList);
        }
        else{
            h.showToast_Helper(c,'error',$A.get("$Label.c.Select_Some_Field_To_Sync_Toast"));
        }
    },
    handleChange: function (c, event,h) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionsList = event.getParam("value");
        //console.log(selectedOptionsList);
        c.set('v.selectedArray', selectedOptionsList);
    },
    // This is used to when someone clicks on delete button of custom fields 
    AddFieldsToDelete: function (c, event , h) {
        var fieldApiName = event.getSource().get("v.value");
        var customFieldsTobeDeleted =  c.get("v.customFieldsTobeDeleted");
        customFieldsTobeDeleted.push(fieldApiName);
        c.set('v.customFieldsTobeDeleted', customFieldsTobeDeleted);
        c.set('v.deleteCustomField', true);
    },
    addCustomFieldsToDelete: function (c, event , h) {
        var fieldApiName = event.getSource().get("v.value");
        var customFieldsTobeDeleted =  c.get("v.customFieldsTobeDeleted");
        customFieldsTobeDeleted.push(fieldApiName);
        c.set('v.customFieldsTobeDeleted', customFieldsTobeDeleted);
        c.set('v.deleteCustomField', true);
    },
    //When User Clicks on Confirm Delete Custom Fields
    deleteCustomField: function(c, e, h) {
        var selectedOptionsList =  c.get("v.customFieldsTobeDeleted");
        if((selectedOptionsList != undefined) && (selectedOptionsList.length >0)){
            h.deleteSelectedCustomField_Helper(c,e,h,selectedOptionsList);
        }
        else{
            h.showToast_Helper(c,'error',$A.get("$Label.c.Select_Some_Field_To_Sync_Toast"));
        }
    },
    // To sync blank value from TT to SF
    isAvoid: function(c, e, h) {
        c.set("v.isChangeField",false);
        h.FieldSelected_Helper(c,e ,h);
       /* var index = e.getSource().get("v.value");
        var mappingList =c.get('v.mappingList');
        var checked = e.getSource().get("v.checked");
        console.log('index::'+mappingList[index].TT_Field__c);
        console.log('checked::'+checked);
        var getMappings = c.get("v.saveTTandSF_Field");
         var mappingList = c.get("v.mappingList");
        var saveTTandSF_Field = [];
        if(getMappings != undefined && getMappings != ''){
            console.log('getMappings'+getMappings);
            for (var i = 0; i < getMappings.length; i++) {
                c.set("v.saveTTandSF_Field", []);
                if(getMappings[i].TT_Field__c == mappingList[index].TT_Field__c){
                    saveTTandSF_Field.push(getMappings[i]);
                }
            }
            
        }else if(mappingList != undefined && mappingList != ''){
             console.log('mappingList');
            for (var i = 0; i < mappingList.length; i++) {
                if(mappingList[i].Salesforce_Field__c != ""){
                    saveTTandSF_Field.push(mappingList[i]);
                }
            }
        }
        console.log(saveTTandSF_Field);
        c.set("v.saveTTandSF_Field", saveTTandSF_Field);  
        console.log(c.get("v.saveTTandSF_Field"));
        //
        if(mappingList[index].TT_Field__c == 'phoneNumber' || mappingList[index].TT_Field__c == 'language' || mappingList[index].TT_Field__c == 'subscribed' || mappingList[index].TT_Field__c == 'description' || mappingList[index].TT_Field__c == 'type'){
            //h.isAvoidHelper(c, e, h, checked, mappingList[index].TT_Field__c);
        }*/
    },
    addFieldsShow: function(c, e, h){
        c.set('v.showAddFields', true);
    },
    addFieldsHide: function(c, e, h){
        c.set('v.showAddFields', false);
        c.set('v.addFieldsValue', 'custom');
    },
    checkAddFieldsValue: function(c, e, h){
        if(!$A.util.isEmpty(c.get('v.addFieldsValue')))
            c.set('v.disableNextButton', false);
    },
    goToNextPage: function(c, e, h){
        var radioValue = c.get('v.addFieldsValue');
        if(radioValue === 'custom'){
            c.set('v.showAddFields', false);
            c.set('v.addFieldsValue', 'custom');
            h.addCustomFields(c, e, h);
        }
        else if(radioValue === 'standard'){
            c.set('v.showAddFields', false);
            c.set('v.addFieldsValue', 'custom');
            h.addDeletedFields(c, e, h);
        }
    },
    setRecordOwnerFlag: function(c, e, h){
        h.setRecordOwnerFlagHelper(c, e, h, c.get('v.useCreatedByIdFlag'));
    },
    addDuplicateMapping: function(c, e, h){
        var TTFieldName = e.getSource().get("v.value");
        h.addDuplicateMappingHelper(c, e, h, TTFieldName);
    }
})