/* eslint-disable eqeqeq */
import { api, LightningElement, track } from "lwc";
import LANG from "@salesforce/i18n/lang";
import getTouchPointTemplates from "@salesforce/apex/TemplateGalleryCompHandler.getTouchPointTemplates";
import SaveTouchPointTemplate from "@salesforce/apex/TemplateGalleryCompHandler.SaveTouchPointTemplate";
import generatePreviewIFrameUrl from "@salesforce/apex/TemplateGalleryCompHandler.generatePreviewIFrameUrl";
import { loadStyle } from "lightning/platformResourceLoader";
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import Email_Text from "@salesforce/label/c.Email_Text";
import Language_Text from "@salesforce/label/c.Language_Text";
import All_Label from '@salesforce/label/c.All_Label';
import TouchPoint_Experience_Text from "@salesforce/label/c.TouchPoint_Experience_Text";
import English_Text from "@salesforce/label/c.English_Text";
import French_Text from "@salesforce/label/c.French_Text";
import TouchPointTemplateNotSaved_Text from "@salesforce/label/c.TouchPointTemplateNotSaved_Text";
import TouchPointTemplateSaved_Text from "@salesforce/label/c.TouchPointTemplateSaved_Text";
import Save_Button_Label from "@salesforce/label/c.Save_Button_Label";
import Cancel_Button_Label from "@salesforce/label/c.Cancel_Button_Label";
import Back_Button_Label from "@salesforce/label/c.Back_Button_Label";
import Compliance_Title from "@salesforce/label/c.Compliance_Title";
import Compliance_Message from "@salesforce/label/c.Compliance_Message";
import Private_Text from "@salesforce/label/c.Private_Text";
import Public_Text from "@salesforce/label/c.Public_Text";
import Search_Text from "@salesforce/label/c.Search_Text";
import No_Data_Text from "@salesforce/label/c.No_Data_Text";
import Sort_By_Text from "@salesforce/label/c.Sort_By_Text";
import None_Text from "@salesforce/label/c.None_Text";
import TitleText from "@salesforce/label/c.TitleText";
import CreatedDateText from "@salesforce/label/c.CreatedDateText";
import LastModifiedDate from "@salesforce/label/c.LastModifiedDate";
import Template_Gallery_Save_Text from '@salesforce/label/c.Template_Gallery_Save_Text';
import Compliance_Confirm_Text from '@salesforce/label/c.Compliance_Confirm_Text';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TemplateGalleryComp extends LightningElement {
  label = {
    LastModifiedDate,
    Sort_By_Text,
    TitleText,
    CreatedDateText,
    None_Text,
    Email_Text,
    Language_Text,
    TouchPoint_Experience_Text,
    English_Text,
    French_Text,
    All_Label,
    No_Data_Text,
    TouchPointTemplateSaved_Text,
    TouchPointTemplateNotSaved_Text,
    Back_Button_Label,
    Cancel_Button_Label,
    Save_Button_Label,
    Private_Text,
    Public_Text,
    Search_Text,
    Compliance_Title,
    Compliance_Message,
    Template_Gallery_Save_Text,
    Compliance_Confirm_Text
  };
  @api isOpenTouchPoints = false;
  @api campSfId;
  langValue = "en_US";
  @track isPrivateToggle = false;
  @track previewSaveDisabled = false;
  showPagination = false;
  privateTemplatesList = [];
  publicTemplatesList = [];
  @api templateId;
  isTemplatePage = false;
  lang = LANG;
  isSpinner = false;
  previewBody = false;
  isTemplatePresent = false;
  fr = false;
  showCompliance = false;
  iframeURL;
  @track urls = {};
  templatesList = [];
  templateType = 'All';
  sortingType = 'none';
  mainTemplateList = [];
  paginationList = [];
  currentPage = 1;
  totalRecords;
  recordSize = 10;
  prevBtnClass = "btnBorderActive";
  nextBtnClass = "btnBorderInActive";
  totalPage = 0;
  nextPage = 2;
  prevPage = 1;
  get langOptions() {
    return [
      { label: this.label.English_Text, value: "en_US" },
      { label: this.label.French_Text, value: "fr_FR" }
    ];
  }

  get templateOptions() {
    return [
      { label: this.label.All_Label, value: "All" },
      { label: this.label.Public_Text, value: "Public" },
      { label: this.label.Private_Text, value: "Private" }
    ];
  }
  get sortingOptions() {
    return [
      { label: this.label.None_Text, value: "none" },
      { label: this.label.TitleText, value: "title" },
      { label: this.label.CreatedDateText, value: "createdDate" },
      { label: this.label.LastModifiedDate, value: "modifiedDate" }
    ];
  }

  connectedCallback() {
    loadStyle(this, TelosTouch + "/NativeTPPreview_LV.css");
    this.previewSaveDisabled = false;
    if (window.screen.availWidth < 900) {
      this.recordSize = 6;
      this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
      this.updateRecords();
    }
    if (this.lang === "fr") {
      this.fr = true;
    }
    if (this.isOpenTouchPoints) {
      this.isSpinner = true;
      this.getTemplates();
    }
  }

  updateRecordSize = () => {
    if (window.screen.availWidth <= 900) {
      this.recordSize = 6;
      this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
      this.updateRecords();
    }
  };

  getTemplates() {
    getTouchPointTemplates()
      .then((data) => {
        if (data) {
          this.templatesList = JSON.parse(data);
          this.mainTemplateList = this.templatesList;
          for (let x of this.templatesList) {
            if (x.is_private) {
              this.privateTemplatesList.push(x);
            } else {
              this.publicTemplatesList.push(x);
            }
          }
          if (this.templatesList.length > 0) {
            this.isTemplatePage = true;
            this.isTemplatePresent = true;
          } else {
            this.isTemplatePage = true;
            this.isTemplatePresent = false;
          }
          this.isSpinner = false;
        } else {
          this.isSpinner = false;
          this.isTemplatePage = true;
          this.isTemplatePresent = false;
        }
        this.showDataBasedOnPrivate();
        this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
        this.updateRecords();
      })
      .catch((error) => {
        this.isSpinner = false;
        this.isTemplatePage = true;
        this.isTemplatePresent = false;
      });
  }

  handleFilterChange(event) {
    if (event.target.dataset.id == 'templateShow') {
      this.templateType = event.detail.value;
    } else if (event.target.dataset.id == 'templateFilter') {
      this.sortingType = event.detail.value;
    }
    if (this.templateType == 'All') {
      this.templatesList = this.mainTemplateList;
      if (this.sortingType == 'title') { this.sortTemplatesList('title'); }
      else if (this.sortingType == 'createdDate') { this.sortTemplatesList('created_at'); }
      else if (this.sortingType == 'modifiedDate') { this.sortTemplatesList('modifiedAt'); }
      else {
        this.isSpinner = true;
        this.mainTemplateList = [];
        this.publicTemplatesList = [];
        this.privateTemplatesList = [];
        this.templatesList = [];
        this.getTemplates();
      }
    } else if (this.templateType == 'Public') {
      this.templatesList = this.publicTemplatesList;
      if (this.sortingType == 'title') { this.sortTemplatesList('title'); }
      else if (this.sortingType == 'createdDate') { this.sortTemplatesList('created_at'); }
      else if (this.sortingType == 'modifiedDate') { this.sortTemplatesList('modifiedAt'); }
      else {
        this.isSpinner = true;
        this.mainTemplateList = [];
        this.publicTemplatesList = [];
        this.privateTemplatesList = [];
        this.templatesList = [];
        this.getTemplates();
      }
    } else if (this.templateType == 'Private') {
      this.templatesList = this.privateTemplatesList;
      if (this.sortingType == 'title') { this.sortTemplatesList('title'); }
      else if (this.sortingType == 'createdDate') { this.sortTemplatesList('created_at'); }
      else if (this.sortingType == 'modifiedDate') { this.sortTemplatesList('modifiedAt'); }
      else {
        this.isSpinner = true;
        this.mainTemplateList = [];
        this.publicTemplatesList = [];
        this.privateTemplatesList = [];
        this.templatesList = [];
        this.getTemplates();
      }
    }
    this.currentPage = 1;
    this.prevPage = 1;
    this.nextPage = 2;
    this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
    this.updateRecords();
  }

  sortTemplatesList(sortBy) {
    let list = this.templatesList;
    if (sortBy !== 'title') {
      let temp = 0;
      for (let x = 0; x < list.length - 1; x++) {
        for (let y = 0; y < list.length - x - 1; y++) {
          if (list[y][sortBy] < list[y + 1][sortBy]) {
            temp = list[y];
            list[y] = list[y + 1];
            list[y + 1] = temp;
          }
        }
      }
    } else if (sortBy === 'title') {
      sortBy = (this.fr) ? 'name_fr' : 'name';
      let temp = 0;
      for (let x = 0; x < list.length - 1; x++) {
        for (let y = 0; y < list.length - x - 1; y++) {
          if (list[y][sortBy].toLowerCase() > list[y + 1][sortBy].toLowerCase()) {
            temp = list[y];
            list[y] = list[y + 1];
            list[y + 1] = temp;
          }
        }
      }
    }
    this.templatesList = list;
    // console.log('sortedData: '+ JSON.stringify(this.templatesList));
  }

  handleSearchInput(event) {
    try {
      let searchKey = event.target.value.toLowerCase();
      let filteredTemplates = [];
      let currentTemplates = [];
      if (this.templateType == 'All') {
        currentTemplates = this.mainTemplateList;
      } else if (this.templateType == 'Public') {
        currentTemplates = this.publicTemplatesList;
      } else if (this.templateType == 'Private') {
        currentTemplates = this.privateTemplatesList;
      }
      if (!this.fr) {
        currentTemplates.forEach((ele) => {
          if (ele.name.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      } else {
        currentTemplates.forEach((ele) => {
          if (ele.name_fr.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      }
      if (searchKey.trim().length > 0) {
        this.templatesList = filteredTemplates;
      } else {
        this.templatesList = currentTemplates;
      }
      this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
      this.currentPage = 1;
      this.prevPage = 1;
      this.nextPage = 2;
      this.updateRecords();
    } catch (error) {
    }
  }

  goBackToMainPage() {
    this.isTemplatePage = true;
  }

  get disablePrevious() {
    return this.currentPage <= 1;
  }


  get disableNext() {
    return this.currentPage >= this.totalPage;
  }

  previousHandler() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
      this.prevPage = this.currentPage;
      this.nextPage = this.prevPage + 1;
      this.updateRecords();
    }
  }

  nextHandler() {
    if (this.currentPage < this.totalPage) {
      this.currentPage = this.currentPage + 1;
      this.nextPage = this.currentPage;
      this.prevPage = this.nextPage - 1;
      this.updateRecords();
    }
  }

  nextPageAction() {
    this.currentPage = this.nextPage;
    this.updateRecords();
  }

  prevPageAction() {
    this.currentPage = this.prevPage;
    this.updateRecords();
  }

  updateRecords() {
    try {
      if (this.templatesList.length < 1) {
        this.NoData = true;
      } else {
        this.NoData = false;
      }
      if (this.totalPage > 1) {
        this.showPagination = true;
      } else {
        this.showPagination = false;
      }
      if (this.currentPage == this.prevPage) {
        this.prevBtnClass = "btnBorderActive";
        this.nextBtnClass = "btnBorderInActive";
      } else {
        this.prevBtnClass = "btnBorderInActive";
        this.nextBtnClass = "btnBorderActive";
      }
      const start = (this.currentPage - 1) * this.recordSize;
      const end = this.recordSize * this.currentPage;
      this.paginationList = this.templatesList.slice(start, end);
      if (this.paginationList <= this.recordSize) {
        this.secondPageDisabled = true;
      } else {
        this.secondPageDisabled = false;
      }
      if (this.paginationList.length > 0) {
        this.isTemplatePresent = true;
      } else {
        this.isTemplatePresent = false;
      }
    } catch (error) {
    }
  }

  openSelectedTemplatePreview(event) {
    this.templateId = event.currentTarget.dataset.id;
    this.isTemplatePage = false;
    this.previewBody = true;
    this.generateIFrame();
  }

  showDataBasedOnPrivate() {
    if (this.templateType == 'All') {
      this.templatesList = this.mainTemplateList;
    } else if (this.templateType == 'Public') {
      this.templatesList = this.publicTemplatesList;
    } else if (this.templateType == 'Private') {
      this.templatesList = this.privateTemplatesList;
    }
    if (this.sortingType != 'none') {
      this.sortTemplatesList(this.sortingType);
    }
  }

  handleBackbuttonAction() {
    this.isTemplatePage = true;
    this.previewBody = false;
    this.mainTemplateList = [];
    this.publicTemplatesList = [];
    this.privateTemplatesList = [];
    this.templatesList = [];
    this.connectedCallback();
  }

  toggleCompliance() {
    this.showCompliance = !this.showCompliance;
    this.previewSaveDisabled = !this.previewSaveDisabled;
  }

  storeTemplate() {
    SaveTouchPointTemplate({ campaignRecordId: this.campSfId, touchPointTemplateId: this.templateId })
      .then((data) => {
        if (data) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success!',
              message: this.label.TouchPointTemplateSaved_Text,
              variant: 'success'
            }),
          );
          this.isTemplatePage = true;
          this.previewBody = false;
          this.closeModal();
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error!',
              message: this.label.TouchPointTemplateNotSaved_Text,
              variant: 'error'
            }),
          );
          this.isTemplatePage = true;
          this.previewBody = false;
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error!',
            message: error,
            variant: 'error'
          }),
        );
        this.isTemplatePage = true;
        this.previewBody = false;
      })
      .finally(() => {
        this.toggleCompliance();
      });
  }

  generateIFrame() {
    generatePreviewIFrameUrl({ templateId: this.templateId, language: this.langValue })
      .then((result) => {
        this.urls = (JSON.parse(result));
      })
      .catch((error) => {
      });
  }

  handleLangChange(event) {
    try {
      this.langValue = event.detail.value;
      this.generateIFrame();
    } catch (error) {
    }
  }

  closeModal() {
    const closeModalEvent = new CustomEvent('closemodalevent', {
    });
    this.dispatchEvent(closeModalEvent);
  }

  closeModal() {
    const closeModalEvent = new CustomEvent('closemodalevent', {
    });
    this.dispatchEvent(closeModalEvent);
  }
}