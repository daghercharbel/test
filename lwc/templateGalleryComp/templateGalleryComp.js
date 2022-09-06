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
import Search_Text from "@salesforce/label/c.Search_Text";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class TemplateGalleryComp extends LightningElement {
  label = {
    Email_Text,
    Language_Text,
    TouchPoint_Experience_Text,
    English_Text,
    French_Text,
    All_Label,
    TouchPointTemplateSaved_Text,
    TouchPointTemplateNotSaved_Text,
    Back_Button_Label,
    Cancel_Button_Label,
    Save_Button_Label,
    Private_Text,
    Search_Text,
    Compliance_Title,
    Compliance_Message
  };
  @api isOpenTouchPoints = false;
  @api campSfId;
  langValue = "en_US";
  // topButtonLabel = 'Back';
  @track isPrivateToggle = false;
  showPagination = false;
  privateTemplatesList = [];
  @api templateId;
  isTemplatePage = false;
  lang = LANG;
  isSpinner = false;
  previewBody = false;
  isTemplatePresent = false;
  fr = false;
  showCompliance = false;
  iframeURL;
  @track urls={};
  templatesList = [];
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

  connectedCallback() {
    loadStyle(this, TelosTouch + "/NativeTPPreview_LV.css");
    // window.addEventListener('resize', this.updateRecordSize);
   // console.log(window.screen.availWidth);
    if (window.screen.availWidth < 900) {
      this.recordSize = 6;
      this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
      this.updateRecords();
    } else {
      // this.topButtonStyle = "slds-var-p-bottom_small";
    }
    if (this.lang === "fr") {
      this.fr = true;
    }
    // console.log("fr: " + this.fr);
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
    } else {
      // this.topButtonStyle = "slds-var-p-bottom_small";
    }
  };

  getTemplates() {
    getTouchPointTemplates()
      .then((data) => {
        if (data) {
          // console.log(
          //   " response templates: " + JSON.stringify(JSON.parse(data))
          // );
          this.templatesList = JSON.parse(data);
          this.mainTemplateList = this.templatesList;
          for (let x of this.templatesList) {
            if (x.is_private) {
              this.privateTemplatesList.push(x);
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
          // console.log("no data");
          this.isSpinner = false;
          this.isTemplatePage = true;
          this.isTemplatePresent = false;
      }
        this.showDataBasedOnPrivate();
        this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
        this.updateRecords();
      })
      .catch((error) => {
        // console.log(error);
        this.isSpinner = false;
        this.isTemplatePage = true;
        this.isTemplatePresent = false;
      });
  }


  handleToggleChange(event) {
    if (event.target.checked) {
      this.isPrivateToggle = true;
      this.templatesList = this.privateTemplatesList;
    } else {
      this.isPrivateToggle = false;
      this.templatesList = this.mainTemplateList;
    }
    this.currentPage = 1;
    this.prevPage = 1;
    this.nextPage = 2;
    this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
    this.updateRecords();
  }

  handleSearchInput(event) {
    try {
      let searchKey = event.target.value.toLowerCase();
      // console.log('searchKey : '+ searchKey);
      let filteredTemplates = [];
      if(!this.fr){
        // console.log('english');
        if (this.isPrivateToggle) {
          //console.log('private');
          this.privateTemplatesList.forEach((ele) => {
            if (ele.name.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
              filteredTemplates.push(ele);
            }
          });
          //console.log('filtered in private list: '+ JSON.stringify(filteredTemplates));
        } else {
          // console.log('templateList size:: '+ this.templatesList.length);
          this.mainTemplateList.forEach((ele) => {
            if (ele.name.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
              filteredTemplates.push(ele);
            }
          });
          // console.log('filtered in all list: '+ JSON.stringify(filteredTemplates));
        }
      }else{
        //console.log('french');
        if (this.isPrivateToggle) {
          this.privateTemplatesList.forEach((ele) => {
            if (ele.name_fr.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
              filteredTemplates.push(ele);
            }
          });
        } else {
          this.mainTemplateList.forEach((ele) => {
            if (ele.name_fr.toLowerCase().includes(searchKey.trim()) || ele.Description.toLowerCase().includes(searchKey.trim())) {
              filteredTemplates.push(ele);
            }
          });
        }
      }
      if (searchKey.trim().length > 0) {
        this.templatesList = filteredTemplates;
      } else {
        if (this.isPrivateToggle) {
          this.templatesList = this.privateTemplatesList;
        } else {
          this.templatesList = this.mainTemplateList;
        }
      }
      this.currentPage = 1;
      this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);
      this.updateRecords();
    } catch (error) {
      // console.log(error);
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
        //this.isTemplatePresent = true;
      } else {
        //this.isTemplatePresent = false;
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
      //console.log(error);
    }
  }

  openSelectedTemplatePreview(event) {
    this.templateId = event.currentTarget.dataset.id;
    this.isTemplatePage = false;
    this.previewBody = true;
    this.generateIFrame();         

  }
  showDataBasedOnPrivate(){
    // console.log('private toogle on? '+ this.isPrivateToggle);
    if(this.isPrivateToggle){
      this.templatesList = this.privateTemplatesList;
    }else{
      this.templatesList = this.mainTemplateList;
    }
  }

  handleBackbuttonAction() {
    this.isTemplatePage = true;
    this.previewBody = false;
    this.privateTemplatesList = [];
    this.templatesList = [];
    this.mainTemplateList = [];
    this.isPrivateToggle = this.isPrivateToggle? this.isPrivateToggle:this.isPrivateToggle;
    // this.topButtonLabel = "Back";
    this.connectedCallback();
  }

  toggleCompliance(){
    this.showCompliance = !this.showCompliance;
  }

  storeTemplate() {
    SaveTouchPointTemplate({campaignRecordId: this.campSfId, touchPointTemplateId: this.templateId})
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
        this.previewBody = false;;
        }else{
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
        // console.log("show error toast");
        this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error!',
              message: error,
              variant: 'error'
          }),
      );
      this.isTemplatePage = true;
      this.previewBody = false;
      // console.log(error);
      })
      .finally(() => {
          this.toggleCompliance();
      });
  }

  generateIFrame(){
    generatePreviewIFrameUrl({ templateId: this.templateId, language: this.langValue })
      .then((result) => {
        this.urls = (JSON.parse(result));
        //console.log(JSON.stringify(this.urls));
      })
      .catch((error) => {
        // console.log(error);
      }); 
  }

  handleLangChange(event) {
    try {
      this.langValue = event.detail.value;
      // console.log(this.langValue);
      this.generateIFrame();         
  } catch (error) {
      // console.error(error);
    }
  }
}