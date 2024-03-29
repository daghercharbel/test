import { api, LightningElement } from 'lwc';

import getSyncData from "@salesforce/apex/TelosTouchDataSyncController.getSyncData";
import getAllLogs from "@salesforce/apex/TelosTouchDataSyncController.getAllLogs";
import syncAllRecordsApex from "@salesforce/apex/TelosTouchDataSyncController.syncAllRecordsApex";
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import LANG from '@salesforce/i18n/lang';
import { labelLibrary } from 'c/ttLabels';

export default class TelostouchDataSync extends LightningElement {
  label = labelLibrary;
  @api showManualSync = false;
  @api enableLogTable = false;
  @api enableSync = false;
  approval = false;
  asyncJobStatus = false;
  @api lastUpdated = '';
  logsList = [];

  paginationList = [];
  startRecord;
  endRecord;
  currentPage = 1;
  recordPerPage = 5;
  preDisable = true;
  nextDisable = true;
  totalPages = 1;
  end = false;
  pageNo = 1;

  syncTypeOptions = [
    { value: 'Soft', label: this.label.Soft_Sync_Text },
    { value: 'Hard', label: this.label.Hard_Sync_Text }
  ];
  syncObjectOptions = [
    { value: 'All', label: this.label.All_Label },
    { value: 'Contact', label: this.label.Clients_Text },
    { value: 'Task', label: this.label.Tasks_Text },
    { value: 'Campaign', label: this.label.Campaigns_Text }
  ];
  syncTypeValue = '';
  syncObjectValue = '';
  manualSyncDisabled = true;
  showSpinner = false;
  @api isModalOpen = false;
  warningModalisOpen = false;

  connectedCallback() {
    if (window.screen.availHeight < 820 && window.screen.availWidth > 900 && window.screen.availWidth < 1540) {
      this.recordPerPage = 6;
      // this.totalPages = Math.ceil(this.logsList.length / this.recordPerPage);
      // this.preparePaginationList();
    } else if (window.screen.availWidth < 900) {
      this.recordPerPage = 8;
    } else if (window.screen.availHeight > 820 && window.screen.availWidth > 1540) {
      this.recordPerPage = 10;
    }
    this.showSpinner = true;
    //GETTING INITIAL SYNC DATA FOR COMPONENT INITIALIZATION
    getSyncData().then(data => {
      var returnObj = JSON.parse(data);
      this.approval = returnObj.approval;
      this.asyncJobStatus = returnObj.asyncJobstatus;
      this.lastUpdated = returnObj.lastUpdated;
    }).catch(error => {
      this.error = error;
    });
    this.getLogsFromApex();
  }

  //FUNCTION TO REFRESH LOGS ON BUTTON CLICK
  refreshLogs() {
    this.connectedCallback();
  }

  //FUNCTION TO GET LOGS FROM APEX AND PREPARE ITERATION LIST
  getLogsFromApex() {
    getAllLogs().then(data => {
      this.showSpinner = true;
      if (data) {
        var logs = JSON.parse(data);
        logs.forEach(element => {
          if (element.TelosTouchSF__Result__c === 'Success') {
            element.result = TelosTouch + '/images/RightCheckbox.webp';
          } else {
            element.result = TelosTouch + '/images/CrossCheckbox1.png';
          }
        });
        this.logsList = logs;
        this.totalPages = Math.ceil(this.logsList.length / this.recordPerPage);
        this.preparePaginationList();
        this.showSpinner = false;
      } else {
        this.logsList = [];
      }
    }).catch(error => { });
  }

  //FUNCTION TO CLOSE MODAL ON BUTTON CLICK
  closeModal() {
    this.isModalOpen = false;
    this.syncTypeValue = '';
    this.syncObjectValue = '';
    this.manualSyncDisabled = true;
  }

  //FUNCTION TO INITIATE SYNC THROUGH APEX ON BUTTON CLICK
  syncAllRecords() {
    this.showSpinner = true;
    syncAllRecordsApex({ syncType: this.syncTypeValue, syncObject: this.syncObjectValue })
      .then(data => {
        this.showSpinner = false;
        const successEvt = new CustomEvent('syncsuccess', {});
        this.dispatchEvent(successEvt);
      }).catch(error => {
        this.error = error;
        this.showSpinner = false;
        const failedEvt = new CustomEvent('syncfailure', {});
        this.dispatchEvent(failedEvt);
      });
  }

  //ON CHANGE EVENT HANDLER FOR SYNC TYPE COMBOBOX
  onSyncTypeChange(event) {
    this.syncTypeValue = event.detail.value;
    if (this.syncTypeValue && this.syncObjectValue) {
      this.manualSyncDisabled = false;
    }
  }

  //ON CHANGE EVENT HANDLER FOR SYNC OBJECT COMBOBOX
  onSyncObjectChange(event) {
    this.syncObjectValue = event.detail.value;
    if (this.syncTypeValue && this.syncObjectValue) {
      this.manualSyncDisabled = false;
    }
  }

  //GETTER FOR MANUAL SYNC BUTTON DISABLE FLAG
  get manualSyncButtonDisabled() {
    return (this.manualSyncDisabled || !this.approval || !this.asyncJobStatus);
  }

  //GETTTER FOR WHEN LOGS LIST IS EMPTY
  get isLogsListEmpty() {
    return this.logsList.length === 0 ? true : false;
  }

  //GETTER FOR IF LANGUAGE IS ENGLISH
  get userLanguageEn() {
    return LANG.includes('en') ? true : false;
  }

  //FUNCTION TO HANDLE NEXT OR PREVIOUS BUTTON CLICK FOR PAGINATION CONTROLS
  handleClick(event) {
    let label = event.target.label;
    if (label === "Previous" || label === "Précédent") {
      this.handlePrevious();
    } else if (label === "Next" || label === "Suivant") {
      this.handleNext();
    }
  }

  //FUNCTION TO HANDLE NEXT FOR PAGINATION
  handleNext() {
    this.pageNo += 1;
    this.currentPage = this.pageNo;
    this.preparePaginationList();
  }

  //FUNCTION TO HANDLE PREVIOUS FOR PAGINATION
  handlePrevious() {
    if (this.pageNo > 1) {
      this.pageNo -= 1;
    }
    this.currentPage = this.pageNo;
    this.preparePaginationList();
  }

  //FUNCTION TO PREPARE THE PAGINATION LIST BASED ON SET RECORD COUNT
  preparePaginationList() {
    try {
      if (this.pageNo <= this.totalPages && this.pageNo != 1) {
        this.preDisable = false;
      }
      if (this.pageNo == 1) {
        this.preDisable = true;
      }
      if (this.totalPages == this.pageNo) {
        this.nextDisable = true;
      } else {
        this.nextDisable = false;
      }
      let begin = (this.pageNo - 1) * parseInt(this.recordPerPage);
      let end = parseInt(begin) + parseInt(this.recordPerPage);
      this.paginationList = this.logsList.slice(begin, end);
      if (this.paginationList.length == 0) {
        this.preDisable = true;
        this.nextDisable = true;
        this.totalPages = 1;
        this.pageNo = 1;
      }
      this.startRecord = begin + parseInt(1);
      this.endRecord = end > this.returnedData.length ? this.returnedData.length : end;
      this.end = end > this.returnedData.length ? true : false;
    } catch (error) {

    }
  }
}