import { LightningElement, track, api } from "lwc";
import fetchRecords from "@salesforce/apex/MultiObjectLookupController.fetchRecords";

export default class LwcMultilookup extends LightningElement {
  @api objectlist = [];
  @track value = "";
  @track recordCount = "5";
  @track label = "";
  @track placeholder = "Search..";
  @track searchString = "";
  @track selectedObject = {};
  @track selectedRecord = {};
  @track recordsList = [];
  @track showObjectList = false;
  @track message = "";
  @track resultsDivClass =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
  @track objectDataDiv =
    "slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
  @track spinnerClass = "slds-hide";
  @track showPill = false;
  @track showLookupField = true;
  @track MsgCondition = true;
  @track selectedIconName = "standard:account";
  connectedCallback() {
    if (this.resultsDivClass.includes("slds-is-open")) {
      this.resultsDivClass = this.resultsDivClass.replace("slds-is-open", "");
    } else {
      this.resultsDivClass = this.resultsDivClass + "slds-is-open";
    }
    this.objectDataDiv = this.objectDataDiv.replace("slds-is-open", "");
    this.selectedObject = this.objectlist[0];
  }

  showObjects() {
    this.showObjectList = true;
    if (this.objectDataDiv.includes("slds-is-open")) {
      this.objectDataDiv = this.objectDataDiv.replace("slds-is-open", "");
    } else {
      this.objectDataDiv = this.objectDataDiv + "slds-is-open";
    }
  }

  selectObject(event) {
    this.showObjectList = false;
    this.selectedObject = this.objectlist[event.currentTarget.dataset.index];
    this.searchString = "";
    this.selectedIconName = this.selectedObject.iconName;
  }

  searchRecords(event) {
    this.searchString = event.target.value;
    this.objectDataDiv = this.objectDataDiv.replace("slds-is-open", "");

    if (this.searchString.length > 0) {
      this.spinnerClass = this.spinnerClass.replace("slds-hide", "");
      this.message = "";
      this.MsgCondition = true;
      this.recordsList = [];
      var selectedObject = this.selectedObject;
      fetchRecords({
        objectName: selectedObject.APIName,
        filterField: selectedObject.fieldName,
        searchString: this.searchString
      })
        .then((result) => {
          if (result.length > 0) {
            this.recordsList = result;
            this.message == "";
            this.MsgCondition = true;
          } else {
            this.message = "No Records Found";
            this.MsgCondition = false;
          }
          this.resultsDivClass =
            "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
          this.spinnerClass = "slds-hide";
          this.template.querySelector(`[data-id="listbox-id-1"]`).style =
            "max-height:" + (8 + this.recordCount * 40) + "px";
        })
        .catch((error) => {
          this.error = error.message;
        });
    } else {
      this.spinnerClass = "slds-hide";
      this.resultsDivClass = this.resultsDivClass.replace("slds-is-open", "");
    }
  }

  selectItem(event) {
    this.selectedRecord = this.recordsList[event.currentTarget.dataset.index];
    this.value = this.selectedRecord.value;
    this.resultsDivClass = this.resultsDivClass.replace("slds-is-open", "");
    this.showPill = true;
    this.showLookupField = false;
    const passEventr = new CustomEvent("recordselection", {
      detail: this.value
    });
    this.dispatchEvent(passEventr);
  }

  removeItem() {
    this.selectedRecord = "";
    this.value = "";
    this.searchString = "";
    this.showPill = false;
    this.showLookupField = true;
    setTimeout(function () {
      this.template.querySelector(`[data-id="inputLookup"]`).focus();
    }, 250);
  }

  blurRecordList() {
    this.resultsDivClass = this.resultsDivClass.replace("slds-is-open", "");
  }

  blurObjectList() {
    this.objectDataDiv = this.objectDataDiv.replace("slds-is-open", "");
    this.showObjectList = false;
  }

  get geLabelPresence() {
    if (this.label.length > 0) {
      return true;
    }
    return false;
  }
}