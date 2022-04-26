import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getTaskFieldsWrapper from "@salesforce/apex/MassCreateTaskCompController.getTaskFieldsWrapper";
import getFieldVsPicklistMap from "@salesforce/apex/MassCreateTaskCompController.getFieldVsPicklistMap";
import getSectionNameVsFieldsMap from "@salesforce/apex/MassCreateTaskCompController.getSectionNameVsFieldsMap";
import getReferenceObjectstAPIvsLabelMap from "@salesforce/apex/MassCreateTaskCompController.getReferenceObjectstAPIvsLabelMap";
import getfieldVsReferenceObjects from "@salesforce/apex/MassCreateTaskCompController.getfieldVsReferenceObjects";
import getReferenceObjectstAPIvsIconMap from "@salesforce/apex/MassCreateTaskCompController.getReferenceObjectstAPIvsIconMap";
import createTasks from "@salesforce/apex/MassCreateTaskCompController.createTasks";
import checkNamedCredentials from "@salesforce/apex/MassCreateTaskCompController.checkNamedCredentials";
import hasActiveRecordType from "@salesforce/apex/MassCreateTaskCompController.hasActiveRecordType";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import REQUIRED_FIELD_MISSING from "@salesforce/label/c.Required_Field_Missing";
import CREATE_RECURRING_TASK from "@salesforce/label/c.Create_Recurring_Task";
import FREQUENCY_TEXT from "@salesforce/label/c.Frequency_Text";
import DAILY_TEXT from "@salesforce/label/c.Daily_Text";
import WEEKLY_TEXT from "@salesforce/label/c.Weekly_Text";
import MONTHLY_TEXT from "@salesforce/label/c.Monthly_Text";
import YEARLY from "@salesforce/label/c.Yearly";
import REPEAT_TEXT from "@salesforce/label/c.Repeat_Text";
import START_DATE from "@salesforce/label/c.Start_Date";
import END_DATE from "@salesforce/label/c.End_Date";
import REPEAT_ON from "@salesforce/label/c.Repeat_On";
import WHEN_TEXT from "@salesforce/label/c.When_Text";
import DAY from "@salesforce/label/c.Day";
import NAMED_CREDENTIAL_ERROR from "@salesforce/label/c.Named_Credential_Error";

export default class MassCreateTaskComp extends NavigationMixin(
  LightningElement
) {
  label = {
    REQUIRED_FIELD_MISSING,
    CREATE_RECURRING_TASK,
    FREQUENCY_TEXT,
    DAILY_TEXT,
    WEEKLY_TEXT,
    MONTHLY_TEXT,
    YEARLY,
    REPEAT_TEXT,
    START_DATE,
    END_DATE,
    REPEAT_ON,
    WHEN_TEXT,
    DAY,
    NAMED_CREDENTIAL_ERROR
  };
  @api recordId;
  @track dailyRepeat = true;
  @track namedCredentialPresent = false;
  @track dailyRepeatCustom = false;
  @track weeklyRepeat = false;
  @track weeklyRepeatCustom = false;
  @track monthlyRepeat = false;
  @track monthlyRepeatCustom = false;
  @track monthlySpecificDays = true;
  @track monthlyRelativeDays = false;
  @track yearlyRepeat = false;
  @track yearlyRelativeDate = false;
  @track disableActivityDate = false;
  @track defaultActivityDate = "";
  recurringEnabled = false;
  recurringEndDateValidation = false;
  RecurrenceTypeValue = "RecursDaily";
  // repeatValue = '1';
  defaultStartDate = "";
  defaultEndDate = "";
  get RecurrenceTypeOptions() {
    //RecurrenceType
    return [
      { label: "Daily", value: "RecursDaily" },
      { label: "Weekly", value: "RecursWeekly" },
      { label: "Monthly", value: "RecursMonthly" },
      { label: "Yearly", value: "RecursYearly" }
    ];
  }
  get dailyRepeatOptions() {
    //RecurrenceInterval
    return [
      { label: "Every Day", value: "1" },
      { label: "Every Other Day", value: "2" },
      { label: "Custom", value: "customOptions" }
    ];
  }
  get weeklyRepeatOptions() {
    //RecurrenceInterval
    return [
      { label: "Every Week", value: "1" },
      { label: "Every Other Week", value: "2" },
      { label: "Custom", value: "customOptions" }
    ];
  }
  get monthlyRepeatOptions() {
    //RecurrenceInterval
    return [
      { label: "Every Month", value: "1" },
      { label: "Every Other Month", value: "2" },
      { label: "Custom", value: "customOptions" }
    ];
  }
  get yearlyRepeatOptions() {
    //RecurrenceType
    return [
      { label: "Specific Date", value: "RecursYearly" },
      { label: "Relative Date", value: "RecursYearlyNth" }
    ];
  }
  get customOptions() {
    //RecurrenceInterval(custom) RecurrenceDayOfMonth
    return [
      { label: "1", value: "1" },
      { label: "2", value: "2" },
      { label: "3", value: "3" },
      { label: "4", value: "4" },
      { label: "5", value: "5" },
      { label: "6", value: "6" },
      { label: "7", value: "7" },
      { label: "8", value: "8" },
      { label: "9", value: "9" },
      { label: "10", value: "10" },
      { label: "11", value: "11" },
      { label: "12", value: "12" },
      { label: "13", value: "13" },
      { label: "14", value: "14" },
      { label: "15", value: "15" },
      { label: "16", value: "16" },
      { label: "17", value: "17" },
      { label: "18", value: "18" },
      { label: "19", value: "19" },
      { label: "20", value: "20" },
      { label: "21", value: "21" },
      { label: "22", value: "22" },
      { label: "23", value: "23" },
      { label: "24", value: "24" },
      { label: "25", value: "25" },
      { label: "26", value: "26" },
      { label: "27", value: "27" },
      { label: "28", value: "28" },
      { label: "29", value: "29" },
      { label: "30", value: "30" }
    ];
  }

  get monthlyWhenOptions() {
    //RecurrenceType(only for Relative Days)
    return [
      { label: "Specific Days", value: "RecursMonthly" },
      { label: "Relative Days", value: "RecursMonthlyNth" }
    ];
  }
  get RecurrenceInstanceOptions() {
    //RecurrenceInstance
    return [
      { label: "First", value: "First" },
      { label: "Second", value: "Second" },
      { label: "Third", value: "Third" },
      { label: "Fourth", value: "Fourth" },
      { label: "Last", value: "Last" }
    ];
  }
  get relativeDaysRepeatOnOptions() {
    return [
      //RecurrenceDayOfWeekMask
      { label: "Sunday", value: "1" },
      { label: "Monday", value: "2" },
      { label: "Tuesday", value: "4" },
      { label: "Wednesday", value: "8" },
      { label: "Thursday", value: "16" },
      { label: "Friday", value: "32" },
      { label: "Saturday", value: "64" },
      { label: "Day", value: "1" }
    ];
  }
  get yearlyRelativeDateMonthOptions() {
    return [
      //RecurrenceMonthOfYear
      { label: "January", value: "January" },
      { label: "February", value: "February" },
      { label: "March", value: "March" },
      { label: "April", value: "April" },
      { label: "May", value: "May" },
      { label: "June", value: "June" },
      { label: "July", value: "July" },
      { label: "August", value: "August" },
      { label: "September", value: "September" },
      { label: "October", value: "October" },
      { label: "November", value: "November" },
      { label: "December", value: "December" }
    ];
  }

  @track radioGroupClassForDesktop = "slds-grid";
  @track radioGroupClassForMobile = "slds-grid slds-grid_vertical";
  @track radioGroup = [
    //RecurrenceDayOfWeekMask
    {
      isActive: true,
      label: "Su",
      classList: "radioGroupClass slds-button slds-button_brand",
      value: 1
    },
    {
      isActive: false,
      label: "M",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 2
    },
    {
      isActive: false,
      label: "Tu",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 4
    },
    {
      isActive: false,
      label: "W",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 8
    },
    {
      isActive: false,
      label: "Th",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 16
    },
    {
      isActive: false,
      label: "F",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 32
    },
    {
      isActive: false,
      label: "Sa",
      classList: "radioGroupClass slds-button slds-button_neutral",
      value: 64
    }
  ];
  @track sum = 1;
  @track recordTypePresent = false;
  @track noOfSelectedDays = 1;
  @track showSpinner = true;
  @track objectlist = [];
  @track requiredFields = [];
  @track Task = {};
  @track sections = [];
  @track taskWrapper = [];
  @track MapSectionNameVsFields = new Map();
  @track MapSectionNameVsFieldObjects = new Map();
  @track MapfieldVsSectionName = new Map();
  @track MapFieldVsPicklist = new Map();
  @track MapReferenceObjectstAPIvsLabel = new Map();
  @track MapfieldVsReferenceObjects = new Map();
  @track MapReferenceObjectstAPIvsIcon = new Map();
  @api userList = [];
  @api recordTypeId = "";
  @api recordTypeName = "";
  @track value = "";
  comboboxValues = [];
  userId = "";
  userName = "";
  @wire(CurrentPageReference) pageRef;
  connectedCallback() {
    this.getNameCredentialsInfo();
    this.Task = {};
    this.createTaskWrapper();
    this.createFieldVsPicklistMap();
    this.createfieldVsReferenceObjects();
    this.createReferenceObjectstLabelVsAPIMap();
    this.createReferenceObjectsVsIconName();
    setTimeout(() => {
      this.showSpinner = false;
    }, 3000);
    registerListener("saveClicked", this.handleSave, this);
    hasActiveRecordType()
      .then((result) => {
        this.recordTypePresent = result;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  getNameCredentialsInfo() {
    checkNamedCredentials()
      .then((result) => {
        if (result) {
          this.namedCredentialPresent = true;
        } else {
          this.showSpinner = false;
          this.namedCredentialPresent = false;
        }
      })
      .catch((error) => {
        this.namedCredentialPresent = false;
        this.error = error.message;
      });
  }

  createTaskWrapper() {
    getTaskFieldsWrapper()
      .then((result) => {
        this.taskWrapper = result;
        this.createMapSectionNameVsFields();
      })
      .catch((error) => {
        this.error = error.message;
      });
  }

  createMapSectionNameVsFields() {
    getSectionNameVsFieldsMap({ recordTypeId: this.recordTypeId })
      .then((result) => {
        for (let key in result) {
          let fieldList = [];
          result[key].forEach((ele) => {
            fieldList.push(ele.field);
            if (ele.isRequired) {
              this.requiredFields.push(ele.field);
            }
          });
          this.MapSectionNameVsFields.set(key, fieldList);
        }
        setTimeout(() => {
          this.createMapSectionNameVsFieldObjects();
        }, 1000);
      })
      .catch((error) => {
        this.error = error.message;
      });
  }

  getSectionNameByField() {
    for (let [key, value] of this.MapSectionNameVsFields.entries()) {
      value.forEach((ele) => {
        this.MapfieldVsSectionName.set(ele, key);
      });
    }
  }

  createFieldVsPicklistMap() {
    getFieldVsPicklistMap()
      .then((result) => {
        for (let key in result) {
          this.MapFieldVsPicklist.set(key, result[key]);
        }
      })
      .catch((error) => {
        this.error = error.message;
      });
  }
  createReferenceObjectstLabelVsAPIMap() {
    getReferenceObjectstAPIvsLabelMap()
      .then((result) => {
        for (let key in result) {
          this.MapReferenceObjectstAPIvsLabel.set(key, result[key]);
        }
      })
      .catch((error) => {
        this.error = error.message;
      });
  }

  createfieldVsReferenceObjects() {
    getfieldVsReferenceObjects()
      .then((result) => {
        for (let key in result) {
          this.MapfieldVsReferenceObjects.set(key, result[key]);
        }
      })
      .catch((error) => {
        this.error = error.message;
      });
  }
  createReferenceObjectsVsIconName() {
    getReferenceObjectstAPIvsIconMap()
      .then((result) => {
        for (let key in result) {
          this.MapReferenceObjectstAPIvsIcon.set(key, result[key]);
        }
      })
      .catch((error) => {
        this.error = error.message;
      });
  }

  createMapSectionNameVsFieldObjects() {
    this.getSectionNameByField();
    let allSectionFields = [];
    for (let [key, value] of this.MapSectionNameVsFields.entries()) {
      value.forEach((ele) => {
        allSectionFields.push(ele);
      });
    }
    this.taskWrapper.forEach((wrap) => {
      if (allSectionFields.includes(wrap.apiName)) {
        let sectionName = this.MapfieldVsSectionName.get(wrap.apiName);
        let objectlist = [];
        let obj = {};
        this.userName = wrap.userName;
        this.userId = wrap.userId;
        obj.Name = wrap.apiName;
        obj.Label = wrap.fieldLabel;
        obj.pickListValues = [];
        obj.refList = [];
        if (this.requiredFields.includes(obj.Name)) {
          obj.required = true;
        } else {
          obj.required = false;
        }
        obj.isRecordType = false;
        obj.isSubject = false;
        obj.isTextArea = false;
        obj.isWhoID = false;
        obj.isActivityDate = false;
        obj.placeHolder = "";
        obj.isAssignedToID = false;
        obj.hasRelation = wrap.hasRelation;
        obj.isPicklist = wrap.isPicklist;
        obj.isString = wrap.isString;
        obj.isRecurrence = wrap.isRecurrence;
        obj.RelationshipName = wrap.relationshipName;
        if (wrap.fieldType === "BOOLEAN") {
          obj.Type = "checkbox";
        } else if (wrap.fieldType === "DATE") {
          obj.Type = "date";
        } else if (wrap.fieldType === "REFERENCE") {
          if (obj.Name == "recordtypeid") {
            obj.isRecordType = true;
            obj.hasRelation = false;
          } else if (obj.Name == "whoid") {
            obj.isWhoID = true;
            obj.hasRelation = false;
          } else if (obj.Name == "ownerid") {
            obj.isWhoID = false;
            obj.hasRelation = false;
            obj.isAssignedToID = true;
          } else {
            let refObjects = this.MapfieldVsReferenceObjects.get(wrap.apiName);
            refObjects.forEach((ele) => {
              let labelForObject = this.MapReferenceObjectstAPIvsLabel.get(ele);
              let iconForObject = this.MapReferenceObjectstAPIvsIcon.get(ele);
              obj.refList.push({
                label: labelForObject,
                APIName: ele,
                fieldName: "name",
                iconName: iconForObject
              });
            });
          }
        } else if (wrap.fieldType === "TEXTAREA") {
          obj.isTextArea = true;
          obj.isString = false;
          obj.Type = "string";
        } else if (wrap.fieldType === "DATETIME") {
          obj.Type = "datetime";
        } else if (wrap.fieldType === "INTEGER") {
          obj.Type = "number";
        } else if (wrap.fieldType === "STRING") {
          obj.Type = "text";
        } else if (wrap.fieldType === "COMBOBOX") {
          if (obj.Name == "subject") {
            obj.isSubject = true;
            obj.isString = false;
            let mapValues = [];
            mapValues = this.MapFieldVsPicklist.get(wrap.apiName);
            mapValues.forEach((ele) => {
              let comboboxObj = {};
              comboboxObj.label = ele.label;
              comboboxObj.value = ele.value;
              this.comboboxValues.push(comboboxObj);
            });
          }
        } else if (wrap.fieldType === "PICKLIST") {
          let mapValues = [];
          mapValues = this.MapFieldVsPicklist.get(wrap.apiName);
          let pickListObjects = [];
          mapValues.forEach((ele) => {
            let pickListobj = {};
            pickListobj.label = ele.label;
            pickListobj.value = ele.value;
            pickListObjects.push(pickListobj);
          });
          obj.pickListValues = pickListObjects;
          obj.placeHolder = obj.pickListValues[0].label;
          this.Task[wrap.apiName] = obj.pickListValues[0].value;
        } else {
          obj.Type = "text";
        }

        if (obj.Name == "activitydate") {
          obj.isString = false;
          obj.isActivityDate = true;
        }
        if (this.MapSectionNameVsFieldObjects.has(sectionName)) {
          this.MapSectionNameVsFieldObjects.get(sectionName).push(obj);
        } else {
          objectlist.push(obj);
          this.MapSectionNameVsFieldObjects.set(sectionName, objectlist);
        }
      }
    });
    for (let [key, value] of this.MapSectionNameVsFieldObjects.entries()) {
      let obj = {};
      obj.Name = key;
      obj.fieldObjects = value;
      this.sections.push(obj);
    }
  }

  handleSave(objPayload) {
    if (this.recurringEnabled) {
      this.Task.activitydate = null;
    }
    if (this.recordTypePresent && this.recordTypeId != "") {
      this.Task.RecordTypeId = this.recordTypeId;
    }
    let requiredFieldError = false;
    this.requiredFields.forEach((ele) => {
      if (
        (this.Task[ele] == undefined ||
          this.Task[ele] == null ||
          this.Task[ele] == "") &&
        ele != "ownerid"
      ) {
        if (this.recurringEnabled) {
          if (ele.toLowerCase() != "activitydate") {
            console.log("field", ele);
            requiredFieldError = true;
          }
        } else {
          requiredFieldError = true;
          console.log("field", ele);
        }
      }
    });
    if (requiredFieldError) {
      const event = new ShowToastEvent({
        variant: "error",
        title: "Error",
        message: this.label.REQUIRED_FIELD_MISSING
      });
      this.dispatchEvent(event);
    } else if (this.recurringEndDateValidation) {
      const event = new ShowToastEvent({
        variant: "error",
        title: "Error",
        message: "Select an end date that’s after the start date."
      });
      this.dispatchEvent(event);
    } else {
      createTasks({
        taskObjStr: JSON.stringify(this.Task),
        userListStr: JSON.stringify(this.userList)
      })
        .then((result) => {
          //window.location.reload();
          this.Task = {};
          this.userList = [];
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: this.recordId,
              objectApiName: "Campaign",
              actionName: "view"
            }
          });
        })
        .catch((error) => {
          this.error = error.message;
        });
    }
  }

  handleChange(event) {
    this.Task[event.target.dataset.field] = event.target.value;
  }

  onSelection(event) {
    this.Task[event.target.dataset.field] = event.detail;
  }

  handleComoboboxValue(event) {
    this.Task[event.target.dataset.field] = event.detail.value;
  }

  handleRecurringRadioGroupValue(event) {
    let selectedValue = event.detail.value;
    let fieldLabel = event.target.dataset.field;
    console.log("selectedValue:::" + selectedValue);
    console.log("field:::" + fieldLabel);
    if (fieldLabel == "RecurrenceType") {
      if (selectedValue == "RecursDaily") {
        this.dailyRepeat = true;
        this.weeklyRepeat = false;
        this.monthlyRepeat = false;
        this.yearlyRepeat = false;
        this.Task[fieldLabel] = "RecursDaily";
        this.Task.RecurrenceInterval = 1;
        this.Task.RecurrenceDayOfWeekMask = null;
        this.Task.RecurrenceDayOfMonth = null;
        this.Task.RecurrenceInstance = null;
        this.Task.RecurrenceMonthOfYear = null;
        this.radioGroup.forEach((ele) => {
          if (ele.label == "Su") {
            ele.classList = "radioGroupClass slds-button slds-button_brand";
            ele.isActive = true;
          } else {
            ele.classList = "radioGroupClass slds-button slds-button_neutral";
            ele.isActive = false;
          }
        });
        this.sum = 1;
      } else if (selectedValue == "RecursWeekly") {
        this.dailyRepeat = false;
        this.weeklyRepeat = true;
        this.monthlyRepeat = false;
        this.yearlyRepeat = false;
        this.Task[fieldLabel] = "RecursWeekly";
        this.Task.RecurrenceInterval = 1;
        this.Task.RecurrenceDayOfWeekMask = 1;
        this.Task.RecurrenceDayOfMonth = null;
        this.Task.RecurrenceInstance = null;
        this.Task.RecurrenceMonthOfYear = null;
      } else if (selectedValue == "RecursMonthly") {
        this.dailyRepeat = false;
        this.weeklyRepeat = false;
        this.monthlyRepeat = true;
        this.yearlyRepeat = false;
        this.Task[fieldLabel] = "RecursMonthly";
        this.Task.RecurrenceInterval = 1;
        this.Task.RecurrenceDayOfMonth = 1;
        this.Task.RecurrenceDayOfWeekMask = null;
        this.Task.RecurrenceInstance = null;
        this.Task.RecurrenceMonthOfYear = null;
        this.radioGroup.forEach((ele) => {
          if (ele.label == "Su") {
            ele.classList = "radioGroupClass slds-button slds-button_brand";
            ele.isActive = true;
          } else {
            ele.classList = "radioGroupClass slds-button slds-button_neutral";
            ele.isActive = false;
          }
        });
        this.sum = 1;
      } else {
        this.dailyRepeat = false;
        this.weeklyRepeat = false;
        this.monthlyRepeat = false;
        this.yearlyRepeat = true;
        this.Task[fieldLabel] = "RecursYearly";
        this.Task.RecurrenceInterval = null;
        this.Task.RecurrenceDayOfWeekMask = null;
        this.Task.RecurrenceInstance = null;
        let dateValues = this.Task.RecurrenceStartDateOnly.split("-");
        this.Task.RecurrenceDayOfMonth = parseInt(dateValues[2]);
        let month = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        this.Task.RecurrenceMonthOfYear = month[parseInt(dateValues[1]) - 1];
        this.radioGroup.forEach((ele) => {
          if (ele.label == "Su") {
            ele.classList = "radioGroupClass slds-button slds-button_brand";
            ele.isActive = true;
          } else {
            ele.classList = "radioGroupClass slds-button slds-button_neutral";
            ele.isActive = false;
          }
        });
        this.sum = 1;
      }
    }
  }
  handleMultiSelectClick(event) {
    let index = event.target.dataset.index;
    if (this.radioGroup[index].isActive) {
      if (this.noOfSelectedDays > 1) {
        this.radioGroup[index].isActive = false;
        this.radioGroup[index].classList =
          "radioGroupClass slds-button slds-button_neutral";
        this.sum = this.sum - this.radioGroup[index].value;
        this.noOfSelectedDays--;
      }
    } else {
      this.radioGroup[index].isActive = true;
      this.radioGroup[index].classList =
        "radioGroupClass slds-button slds-button_brand";
      this.sum = this.sum + this.radioGroup[index].value;
      this.noOfSelectedDays++;
    }
    this.Task.RecurrenceDayOfWeekMask = this.sum;
  }
  handleRecurringComboboxValue(event) {
    let selectedValue = event.detail.value;
    let dataId = event.target.dataset.id;
    let dataField = event.target.dataset.field;
    console.log("selectedValue: " + selectedValue);
    console.log("dataId: " + dataId);
    console.log("Field:" + dataField);
    if (
      dataField == "RecurrenceInterval" ||
      dataField == "RecurrenceDayOfMonth"
    ) {
      this.Task[dataField] = parseInt(selectedValue);
    }
    this.Task[dataField] = selectedValue;
    if (dataId == "dailyRepeat") {
      if (selectedValue == "customOptions") {
        this.dailyRepeatCustom = true;
        this.Task[dataField] = 1;
      } else {
        this.dailyRepeatCustom = false;
      }
    } else if (dataId == "weeklyRepeat") {
      if (selectedValue == "customOptions") {
        this.weeklyRepeatCustom = true;
        this.Task[dataField] = 1;
      } else {
        this.weeklyRepeatCustom = false;
      }
    } else if (dataId == "monthlyRepeat") {
      if (selectedValue == "customOptions") {
        this.monthlyRepeatCustom = true;
        this.Task[dataField] = 1;
      } else {
        this.monthlyRepeatCustom = false;
      }
    } else if (dataId == "monthlyWhen") {
      if (selectedValue == "RecursMonthly") {
        this.monthlySpecificDays = true;
        this.monthlyRelativeDays = false;
        this.Task.RecurrenceDayOfMonth = 1;
        this.Task.RecurrenceInstance = null;
        this.Task.RecurrenceDayOfWeekMask = null;
      } else {
        this.monthlySpecificDays = false;
        this.monthlyRelativeDays = true;
        this.Task.RecurrenceDayOfMonth = null;
        this.Task.RecurrenceInstance = "First";
        this.Task.RecurrenceDayOfWeekMask = 1;
      }
    } else if (dataId == "yearlyRepeat") {
      if (selectedValue == "RecursYearly") {
        this.yearlyRelativeDate = false;
        this.Task.RecurrenceInstance = null;
        this.Task.RecurrenceDayOfWeekMask = null;
        this.Task.RecurrenceMonthOfYear = null;
      } else {
        this.yearlyRelativeDate = true;
        this.Task.RecurrenceInstance = "First";
        this.Task.RecurrenceDayOfWeekMask = 1;
        this.Task.RecurrenceMonthOfYear = "January";
        this.Task.RecurrenceDayOfMonth = null;
      }
    }
  }

  createRecurringTask(event) {
    this.recurringEnabled = event.detail.checked;
    let today = new Date();
    let dd = String(today.getDate()).padStart(2, "0");
    let mm = String(today.getMonth() + 1).padStart(2, "0");
    let yyyy = today.getFullYear();
    this.defaultStartDate = yyyy + "-" + mm + "-" + dd;
    // this.defaultActivityDate = yyyy + '-' + mm + '-' + dd;
    mm = String(today.getMonth() + 2).padStart(2, "0");
    this.defaultEndDate = yyyy + "-" + mm + "-" + dd;
    this.template.querySelector(".activityDate").value = "";
    this.template.querySelector(".activityDate").focus();
    this.template.querySelector(".activityDate").blur();
    if (this.recurringEnabled) {
      this.dailyRepeat = true;
      this.Task.IsRecurrence = true;
      this.Task.RecurrenceType = "RecursDaily";
      this.Task.RecurrenceInterval = 1;
      this.Task.RecurrenceStartDateOnly = this.defaultStartDate;
      this.Task.RecurrenceEndDateOnly = this.defaultEndDate;
      this.disableActivityDate = true;
      // this.defaultActivityDate ='';
      this.sections.forEach((ele) => {
        ele.fieldObjects.forEach((obj) => {
          if (obj.Name == "activitydate") {
            obj.required = false;
          }
        });
      });
    } else {
      this.sections.forEach((ele) => {
        ele.fieldObjects.forEach((obj) => {
          if (
            obj.Name == "activitydate" &&
            this.requiredFields.includes("activitydate")
          ) {
            obj.required = true;
          }
        });
      });
      this.disableActivityDate = false;
      this.dailyRepeat = false;
      this.weeklyRepeat = false;
      this.monthlyRepeat = false;
      this.yearlyRepeat = false;
      this.Task.IsRecurrence = false;
      this.Task.RecurrenceType = null;
      this.Task.RecurrenceInterval = null;
      this.Task.RecurrenceInstance = null;
      this.Task.RecurrenceDayOfWeekMask = null;
      this.Task.RecurrenceDayOfMonth = null;
      this.Task.RecurrenceMonthOfYear = null;
      this.Task.RecurrenceStartDateOnly = null;
      this.Task.RecurrenceEndDateOnly = null;
      this.radioGroup.forEach((ele) => {
        if (ele.label == "Su") {
          ele.classList = "radioGroupClass slds-button slds-button_brand";
          ele.isActive = true;
        } else {
          ele.classList = "radioGroupClass slds-button slds-button_neutral";
          ele.isActive = false;
        }
      });
      this.sum = 1;
    }
  }
  handleRecurringDate(event) {
    this.Task[event.target.dataset.field] = event.target.value;
    if (this.Task.RecurrenceType == "RecursYearly") {
      let dateValues = this.Task.RecurrenceStartDateOnly.split("-");
      this.Task.RecurrenceDayOfMonth = parseInt(dateValues[2]);
      let month = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ];
      this.Task.RecurrenceMonthOfYear = month[parseInt(dateValues[1]) - 1];
    }
    if (event.target.dataset.field == "RecurrenceEndDateOnly") {
      if (
        this.Task.RecurrenceEndDateOnly <= this.Task.RecurrenceStartDateOnly
      ) {
        event.target.setCustomValidity(
          "Select an end date that’s after the start date."
        );
        this.recurringEndDateValidation = true;
      } else {
        event.target.setCustomValidity("");
        this.recurringEndDateValidation = false;
      }
      event.target.reportValidity();
    }
  }
}