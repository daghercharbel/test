import { LightningElement, track, api } from 'lwc';
import Assigned_User_Label from '@salesforce/label/c.Assigned_User_Label';
import Salesforce_Fields from '@salesforce/label/c.Salesforce_Fields';
import TelosTouch_Fields from '@salesforce/label/c.TelosTouch_Fields';
import Sync_Empty_Field from '@salesforce/label/c.Sync_Empty_Field';
import Record_Creator_Assigned_Label from '@salesforce/label/c.Record_Creator_Assigned_Label';
import Record_Owner_Assigned_Label from '@salesforce/label/c.Record_Owner_Assigned_Label';
import Cannot_Add_Duplicate_Field_Toast from '@salesforce/label/c.Cannot_Add_Duplicate_Field_Toast';
import Standard_Fields_Text from '@salesforce/label/c.Standard_Fields_Text';
import Custom_Fields_Text from '@salesforce/label/c.Custom_Fields_Text';
import Next_Button_Label from '@salesforce/label/c.Next_Button_Label';
import Cancel_Button_Label from '@salesforce/label/c.Cancel_Button_Label';
import Task_Label from '@salesforce/label/c.Task_Label';
import Lead_Label from '@salesforce/label/c.Lead_Label';
import Contact_Label from '@salesforce/label/c.Contact_Label';
import Save_Button_Label from '@salesforce/label/c.Save_Button_Label';
import Edit_Button_Label from '@salesforce/label/c.Edit_Button_Label';
import Back_Button_Label from '@salesforce/label/c.Back_Button_Label';
import Add_Fields_Button_Label from '@salesforce/label/c.Add_Fields_Button_Label';
import Confirmation_Text from '@salesforce/label/c.Confirmation_Text';
import Sure_To_Remove from '@salesforce/label/c.Sure_To_Remove';
import Yes_Text from '@salesforce/label/c.Yes_Text';
import No_Text from '@salesforce/label/c.No_Text';
import Field_Deleted_Toast from '@salesforce/label/c.Field_Deleted_Toast';
import Add_Custom_Fields_Text from '@salesforce/label/c.Add_Custom_Fields_Text';
import SF_Field_Create_Toast from '@salesforce/label/c.SF_Field_Create_Toast';
import Select_Some_Field_To_Sync_Toast from '@salesforce/label/c.Select_Some_Field_To_Sync_Toast';
import No_Standard_Field_Toast from '@salesforce/label/c.No_Standard_Field_Toast';
import Add_Standard_Fields_Text from '@salesforce/label/c.Add_Standard_Fields_Text';
import Select_Add_At_Least_One_Field_Toast from '@salesforce/label/c.Select_Add_At_Least_One_Field_Toast';
import Mapped_SF_field_Toast from '@salesforce/label/c.Mapped_SF_field_Toast';
import Field_Mapping_Saved_Toast from '@salesforce/label/c.Field_Mapping_Saved_Toast';
import Something_Went_Wrong from '@salesforce/label/c.Something_Went_Wrong';
import No_Custom_Field_Toast from '@salesforce/label/c.No_Custom_Field_Toast';
import CreatedByHelpText from '@salesforce/label/c.CreatedByHelpText';
import getExistingMappingApex from "@salesforce/apex/TelosTouchMapping.getExistingMappingApex";
import getObjectAllFields from "@salesforce/apex/TelosTouchMapping.getObjectAllFields";
import getTelosTouchLeadFields from "@salesforce/apex/TelosTouchMapping.getTelosTouchLeadFields";
import getTelosTouchFields from "@salesforce/apex/TelosTouchMapping.getTelosTouchFields";
import getTelosTouchTaskFields from "@salesforce/apex/TelosTouchMapping.getTelosTouchTaskFields";
import setUseCreatedByIdFlag from '@salesforce/apex/TelosTouchMapping.setUseCreatedByIdFlag';
import deleteCustomFields from '@salesforce/apex/TelosTouchMapping.deleteCustomFields';
import sendCustomFieldsSFToTT from '@salesforce/apex/TelosTouchMapping.sendCustomFieldsSFToTT';
import populateDeletedFieldsApex from '@salesforce/apex/TelosTouchMapping.populateDeletedFieldsApex';
import addDeletedFieldsToMappingApex from '@salesforce/apex/TelosTouchMapping.addDeletedFieldsToMappingApex';
import saveFieldsMappingApex from '@salesforce/apex/TelosTouchMapping.saveFieldsMappingApex';
import getUseCreatedByIdFlag from '@salesforce/apex/TelosTouchMapping.getUseCreatedByIdFlag';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class FieldMappingComp extends LightningElement {
    @api showFieldMapping = false;
    objectValue = 'Contact';
    isSpin = false;
    @track initTableData;
    // @track fieldValue;
    @track initDataList = [];
    @track dataListFiltered = [];
    @track ttFieldsList = [];
    @track customfieldlist = [];
    @track tempFinalList = [];
    saveButtonDisabled = true;
    editButtonDisabled = false;
    backButtonDisabled = true;
    addButtonDisabled = false;
    comboBoxDisabled = true;
    deleteOff = false;
    @track showToast = false;
    @track variant;
    @track msg;
    userCreatedByIdFlag = false;
    getFieldName;
    openConfirmationModal = false;
    modalAddFields = false;
    addCustomFieldsModal = false;
    selectedValue = [];
    buttonValue = 'Custom';
    standardFieldList = [];
    ifStandardFields = false;
    fieldBoxEnabled = true;
    isDesktop = true;
    get objectOptions() {
        return [
            { Name: this.label.Contact_Label, Id: 'Contact' },
            { Name: this.label.Lead_Label, Id: 'Lead' },
            { Name: this.label.Task_Label, Id: 'Task' },
        ];
    }

    get getRadioOptions() {
        return [
            { label: this.label.Custom_Fields_Text, value: 'Custom' },
            { label: this.label.Standard_Fields_Text, value: 'Standard' },
        ];
    }

    connectedCallback() {

        this.isSpin = true;
        getExistingMappingApex({ selectedObject: this.objectValue })
            .then((result) => {
                this.initTableData = result;
            }).catch((error) => {
                // console.log('error::' + error);
            });
        this.getContactDetails();
        getUseCreatedByIdFlag({})
            .then((result) => {
                if (result === true) {
                    this.userCreatedByIdFlag = true;
                }
            }).catch((error) => {
                // console.log('error::'+error);
            })
    }
    renderedCallback() {
        if (FORM_FACTOR == 'Large' || FORM_FACTOR == 'Medium') {
            this.isDesktop = true;
        }
        else {
            this.isDesktop = false;
        }
    }
    label = {
        Assigned_User_Label,
        Salesforce_Fields,
        TelosTouch_Fields,
        Sync_Empty_Field,
        Record_Owner_Assigned_Label,
        Record_Creator_Assigned_Label,
        Save_Button_Label,
        Edit_Button_Label,
        Back_Button_Label,
        Add_Fields_Button_Label,
        Confirmation_Text,
        Sure_To_Remove,
        Yes_Text,
        No_Text,
        Cannot_Add_Duplicate_Field_Toast,
        Field_Deleted_Toast,
        Add_Fields_Button_Label,
        Custom_Fields_Text,
        Standard_Fields_Text,
        Cancel_Button_Label,
        Next_Button_Label,
        Add_Custom_Fields_Text,
        SF_Field_Create_Toast,
        Select_Some_Field_To_Sync_Toast,
        No_Standard_Field_Toast,
        Add_Standard_Fields_Text,
        Select_Add_At_Least_One_Field_Toast,
        Mapped_SF_field_Toast,
        Field_Mapping_Saved_Toast,
        Something_Went_Wrong,
        No_Custom_Field_Toast,
        Contact_Label,
        Lead_Label,
        Task_Label,
        CreatedByHelpText
    };


    getContactDetails() {
        this.isSpin = true;
        getTelosTouchFields({})
            .then((result) => {
                this.ttFieldsList = result;
                if (this.ttFieldsList.length > 0) {
                    this.setFieldData();
                }
            })
            .catch((error) => {
                // console.log('error::' + error);
            });
    }
    getLeadDetails() {
        this.isSpin = true;
        getTelosTouchLeadFields({})
            .then((result) => {
                if (result) {
                    this.ttFieldsList = result;
                    if (this.ttFieldsList.length > 0) {
                        this.setFieldData();
                    }
                }
            }).catch((error) => {
                // console.log('error::' + error);
            });

    }
    getTaskDetails() {
        this.isSpin = true;
        getTelosTouchTaskFields({})
            .then((result) => {
                this.ttFieldsList = result;
                if (this.ttFieldsList.length > 0) {
                    this.setFieldData();
                }
            }).catch((error) => {
                // console.log('error::' + error + '' + error.message);
            })
    }

    setFieldData() {
        getObjectAllFields({ selectedObjectName: this.objectValue })
            .then((result) => {
                this.initDataList = result;
                if (this.initDataList) {
                    this.customMapToSetData();
                    this.isSpin = false;
                }
            }).catch((error) => {
                // console.log('error::' + error);
                this.isSpin = false;
            });
    }
    handleObjectChange(event) {
        if (event) {
            this.objectValue = event.target.value;
        }
        this.isSpin = true;
        this.customfieldlist = [];
        if (this.objectValue) {
            getExistingMappingApex({ selectedObject: this.objectValue })
                .then((result) => {
                    this.initTableData = result;
                    if (this.objectValue === 'Contact') {
                        this.getContactDetails();
                    }
                    else if (this.objectValue === 'Lead') {
                        this.getLeadDetails();
                    }
                    else {
                        this.getTaskDetails();
                    }
                })
                .catch((error) => {
                    // console.log('error::' + error);
                });
        }
    }
    // handleFieldValue(event) {
    //     this.fieldValue = event.detail.value;

    // }
    customMapToSetData() {
        try {
            this.renderComboBox = true;
            this.customfieldlist = [];
            var fieldsList = [];
            var mappingObj = {};
            var count = 0;
            if (this.ttFieldsList.length > 0 && this.initDataList.length > 0 && this.initTableData.length > 0) {
                for (let i = 0; i < this.ttFieldsList.length; i++) {
                    for (let j = 0; j < this.initTableData.length; j++) {
                        if (this.ttFieldsList[i].fieldAPINameTT == this.initTableData[j].TelosTouchSF__TT_Field__c) {
                            mappingObj = {};
                            fieldsList = [];
                            mappingObj.isRequired = false;
                            mappingObj.isDisabled = false;
                            mappingObj.ifItemCustom = false;
                            mappingObj.TelosTouchSF__TT_Field__c = this.initTableData[j].TelosTouchSF__TT_Field__c;
                            mappingObj.fieldNameTT = this.ttFieldsList[i].fieldNameTT;
                            mappingObj.TelosTouchSF__Salesforce_Field__c = this.initTableData[j].TelosTouchSF__Salesforce_Field__c;
                            mappingObj.TelosTouchSF__Is_Sync_Empty_Field__c = this.initTableData[j].TelosTouchSF__Is_Sync_Empty_Field__c;
                            var fieldsObj = {};
                            for (let k = 0; k < this.initDataList.length; k++) {
                                fieldsObj = {};
                                if (this.initDataList[k].fieldAPIName === mappingObj.TelosTouchSF__Salesforce_Field__c) {
                                    fieldsObj.fieldAPIName = this.initDataList[k].fieldAPIName;
                                    fieldsObj.fieldName = this.initDataList[k].fieldName;
                                    fieldsObj.isSelected = true;
                                } else {
                                    fieldsObj.fieldAPIName = this.initDataList[k].fieldAPIName;
                                    fieldsObj.fieldName = this.initDataList[k].fieldName;
                                    fieldsObj.isSelected = false;
                                }
                                if (this.ttFieldsList[i].fieldAPINameTT === 'created_by') {
                                    if (fieldsObj.fieldAPIName === 'CreatedById' || fieldsObj.fieldAPIName === 'OwnerId') {
                                        fieldsList.push(fieldsObj);
                                    }
                                } else {
                                    fieldsList.push(fieldsObj);
                                }
                            }
                            if ((this.objectValue === 'Contact' || this.objectValue === 'Lead') && this.initTableData[j].TelosTouchSF__TT_Field__c === 'first_name' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'email' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'last_name' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'created_by') {
                                mappingObj.isRequired = true;
                                mappingObj.isDisabled = true;
                                mappingObj.showHint = false;
                                if (this.initTableData[j].TelosTouchSF__TT_Field__c === 'created_by') {
                                    mappingObj.showHint = true;
                                }
                            }
                            else if (this.objectValue === 'Task' && this.initTableData[j].TelosTouchSF__TT_Field__c === 'client_name' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'date_due' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'name' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'shared' || this.initTableData[j].TelosTouchSF__TT_Field__c === 'status') {
                                mappingObj.isRequired = true;
                                mappingObj.isDisabled = true;
                                mappingObj.showHint = false;
                            }
                            mappingObj.initDataList = fieldsList;
                            this.customfieldlist.push(mappingObj);
                        }
                    }
                }
            }
            if (this.initTableData.length > 0 && this.initDataList.length > 0) {
                for (let x of this.initTableData) {
                    var fieldsObj = {};
                    fieldsList = [];
                    if (x.TelosTouchSF__TT_Field__c == 'Custom Fields') {
                        mappingObj = {};
                        mappingObj.isRequired = false;
                        mappingObj.isDisabled = true;
                        mappingObj.ifItemCustom = true;
                        mappingObj.TelosTouchSF__TT_Field__c = 'Custom Fields';
                        mappingObj.fieldNameTT = 'Custom Field';
                        mappingObj.fieldDisabled = true;
                        mappingObj.TelosTouchSF__Salesforce_Field__c = x.TelosTouchSF__Salesforce_Field__c;

                        for (let y of this.initDataList) {
                            fieldsObj = {};
                            if (y.fieldAPIName === mappingObj.TelosTouchSF__Salesforce_Field__c) {
                                fieldsObj.fieldAPIName = y.fieldAPIName;
                                fieldsObj.fieldName = y.fieldName;
                                fieldsObj.isSelected = true;
                            }
                            else {
                                fieldsObj.fieldAPIName = y.fieldAPIName;
                                fieldsObj.fieldName = y.fieldName;
                                fieldsObj.isSelected = false;
                            }
                            fieldsList.push(fieldsObj);
                        }
                        mappingObj.initDataList = fieldsList;
                        this.customfieldlist.push(mappingObj);
                    }
                }
            }
        } catch (error) {
            // console.log(error);
        }
    }
    handleEditClick(event) {
        this.saveButtonDisabled = false;
        this.editButtonDisabled = true;
        this.backButtonDisabled = false;
        this.comboBoxDisabled = false;
        this.deleteOff = true;
        this.fieldBoxEnabled = false;
    }
    handleBackClick() {
        this.isSpin = true;
        this.saveButtonDisabled = true;
        this.editButtonDisabled = false;
        this.backButtonDisabled = true;
        this.fieldBoxEnabled = true;
        this.comboBoxDisabled = true;
        this.deleteOff = false;
        this.openConfirmationModal = false;
        this.addCustomFieldsModal = false;
        this.modalAddFields = false;
        this.ifStandardFields = false;
        this.handleObjectChange();

    }
    displayToast(variant, msg) {
        this.variant = variant;
        this.msg = msg;
        this.showToast = true;
        setTimeout(() => {
            this.showToast = false;
        }, 3000);
    }
    setRecordOwnerFlag(event) {
        this.isSpin = true;
        this.userCreatedByIdFlag = event.target.checked;
        setUseCreatedByIdFlag({ flag: this.userCreatedByIdFlag })
            .then((result) => {
                if (result == true) {
                    this.displayToast('success', this.label.Record_Creator_Assigned_Label);
                    this.isSpin = false;
                }
                else {
                    this.displayToast('success', this.label.Record_Owner_Assigned_Label);
                    this.isSpin = false;
                }
            }).catch((error) => {
                // console.log('error::' + error);
            });
    }
    handleToastVisibilityChange() {
        this.showToast = false;
    }
    handleDelete(event) {
        this.getFieldName = event.target.value;
        this.openConfirmationModal = true;
    }
    closeModal() {
        this.openConfirmationModal = false;
    }
    fieldSelected(event) {
        try {
            var selectedField = event.target.value;
            for (let i = 0; i < this.customfieldlist.length; i++) {
                if (selectedField != null && selectedField == this.customfieldlist[i].TelosTouchSF__Salesforce_Field__c) {
                    this.displayToast('error', this.label.Cannot_Add_Duplicate_Field_Toast);
                }
                else {
                    if (i == event.target.id.slice(0, -3)) {
                        this.customfieldlist[i].TelosTouchSF__Salesforce_Field__c = selectedField;
                    }
                }
            }
        } catch (error) {
            // console.log('error::' + error);
        }
    }
    deleteCustomField() {
        this.isSpin = true;
        deleteCustomFields({ selectedfieldslist: this.getFieldName, objectName: this.objectValue })
            .then((result) => {
                this.displayToast('success', this.label.Field_Deleted_Toast);
                this.handleBackClick();
            }).catch((error) => {
                // console.log('error::' + error);
            })
    }
    handleAddFieldsClick() {
        this.modalAddFields = true;
    }
    closeFieldsModal() {
        this.modalAddFields = false;
    }
    addCustomFieldButton() {
        this.modalAddFields = false;
        this.selectedValue = [];
        if (this.buttonValue == 'Custom' && this.customfieldlist.length > 0) {
            this.addCustomFieldsModal = true;
            this.dataListFiltered = [];
            var fieldsListCustom = this.initDataList;
            for (let i = 0; i < this.customfieldlist.length; i++) {
                for (let j = 0; j < fieldsListCustom.length; j++) {
                    let mappedObj = this.initDataList[j];
                    let alreadyMappedObj = this.customfieldlist[i];
                    if (mappedObj.fieldAPIName == alreadyMappedObj.TelosTouchSF__Salesforce_Field__c) {
                        fieldsListCustom.splice(j, 1);
                    }
                }
            }
            for (let x of fieldsListCustom) {
                this.dataListFiltered.push({ value: x.fieldAPIName, label: x.fieldName });
            }
            if (this.dataListFiltered.length == 0) {
                this.addCustomFieldsModal = false;
                this.displayToast('error', this.label.No_Custom_Field_Toast);
            }
        }
        else if (this.buttonValue == 'Standard') {
            this.isSpin = true;
            this.dataListFiltered = [];
            populateDeletedFieldsApex({ objectName: this.objectValue })
                .then((result) => {
                    if (result) {
                        this.isSpin = false;
                        this.ifStandardFields = true;
                        this.standardFieldList = result;
                        for (let x of result) {
                            this.dataListFiltered.push({ value: x.value, label: x.label });
                        }
                    }
                    else {
                        this.displayToast('error', this.label.No_Standard_Field_Toast);
                        this.isSpin = false;
                        this.modalAddFields = false;
                    }
                }).catch((error) => {
                    // console.log('error::' + error);
                })
        }
    }
    closeCustomFieldsModal() {
        this.addCustomFieldsModal = false;
        this.modalAddFields = false;
    }
    handleListBoxChange(event) {
        this.selectedValue = event.detail.value;
    }
    getRadioValue(event) {
        this.buttonValue = event.target.value;
    }
    submitDetails() {
        if (this.selectedValue.length > 0) {
            this.isSpin = true;
            sendCustomFieldsSFToTT({ Selectedfieldslist: this.selectedValue, objectName: this.objectValue })
                .then((result) => {
                    if (result == true) {
                        this.isSpin = false;
                        this.displayToast('success', this.label.SF_Field_Create_Toast);
                        this.handleBackClick();
                    }
                    else {
                        this.isSpin = false;
                    }
                }).catch((error) => {
                    // console.log('error::' + error.message);
                })
        }
        else {
            this.displayToast('error', this.label.Select_Some_Field_To_Sync_Toast);
        }
    }
    submitStandardDetails() {
        if (this.selectedValue.length > 0) {
            this.isSpin = true;
            addDeletedFieldsToMappingApex({ mappingIdStr: ((this.selectedValue).toString()) })
                .then((result) => {
                    this.displayToast('success', this.label.Mapped_SF_field_Toast);
                    this.handleBackClick();
                }).catch((error) => {
                    // console.log('error::' + JSON.stringify(error));
                })
        }
        else {
            this.displayToast('error', this.label.Select_Add_At_Least_One_Field_Toast)
        }
    }
    closeStandardFieldsModal() {
        this.ifStandardFields = false;
    }
    handleToggleButtons(event) {
        var saveTTandSF_Field = [];
        for (let x of this.customfieldlist) {
            if (event.target.value == x.TelosTouchSF__TT_Field__c) {
                x.TelosTouchSF__Is_Sync_Empty_Field__c = event.target.checked;
            }
            saveTTandSF_Field.push(x.TelosTouchSF__Is_Sync_Empty_Field__c);
        }
    }
    handleSaveClick() {
        let tempArray = [];
        for (let x of this.customfieldlist) {
            tempArray.push(x.TelosTouchSF__Salesforce_Field__c);
        }
        let findDuplicates = arr => arr.filter((item, index) => arr.indexOf(item) != index)
        if (findDuplicates(tempArray).length > 0) {
            this.displayToast('error', this.label.Cannot_Add_Duplicate_Field_Toast);
        }
        else {
            if (tempArray.includes('')) {
                this.displayToast('error', this.label.Cannot_Add_Duplicate_Field_Toast);
            }
            else {
                this.isSpin = true;
                saveFieldsMappingApex({ mappingList: this.customfieldlist, selectedObject: this.objectValue })
                    .then((result) => {
                        if (result) {
                            this.displayToast('success', this.label.Field_Mapping_Saved_Toast);
                            this.handleBackClick();
                        }
                        else {
                            this.displayToast('error', this.label.Something_Went_Wrong);
                            this.isSpin = false;
                        }
                    }).catch((error) => {
                        // console.log('error::' + error);
                        this.displayToast('error', this.label.Something_Went_Wrong);
                        this.isSpin = false;
                    })
            }
        }
    }
    backToRadio() {
        this.modalAddFields = true;
        this.addCustomFieldsModal = false;
        this.ifStandardFields = false;
    }
}