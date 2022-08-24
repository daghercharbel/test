import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getListId from '@salesforce/apex/TouchPointPreviewController.getListId';
import getTemplateDetails from '@salesforce/apex/TouchPointPreviewController.getTemplateDetails';
import getIFrameDetails from '@salesforce/apex/TouchPointPreviewController.getIFrameDetails';
import NO_DATA_TEXT from '@salesforce/label/c.TouchpointPreview_NoData_Text';
import ALL_TEMP_TEXT from '@salesforce/label/c.TouchpointPreview_All_Templates';
import PRIVATE_TEMP_TEXT from '@salesforce/label/c.TouchpointPreview_Private_Template';
import TOUCHPOINTPREVIEW_BACKTOTEMPLATES from '@salesforce/label/c.TouchpointPreview_BackToTemplates';
import TOUCHPOINTPREVIEW_BACKTOLISTVIEW from '@salesforce/label/c.TouchpointPreview_BackToListView';
import LANG from '@salesforce/i18n/lang';
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

export default class NativeTouchPointPreviewLV extends NavigationMixin(LightningElement) {
  label = {
    NO_DATA_TEXT,
    ALL_TEMP_TEXT,
    PRIVATE_TEMP_TEXT,
    TOUCHPOINTPREVIEW_BACKTOLISTVIEW,
    TOUCHPOINTPREVIEW_BACKTOTEMPLATES
  };
  lang = LANG;
  fr = false;
  listViewId = '';
  filterName = '';
  @api navigateToList;
  @track topButtonStyle = 'slds-var-p-bottom_small';
  @track showTopBackButton = true;
  @track mainBodyFlag = true;
  @track topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
  @track alltemplateList = [];
  @track templateList = [];
  @track privateTemplateList = [];
  @track templateId = '';
  @track currentPage = 1;
  @track totalRecords;
  @track recordSize = 10;
  @track totalPage = 0;
  @track nextPage = 2;
  @track prevPage = 1;
  @track visibleRecords = [];
  @track secondPageDisabled = true;
  @track privateFlag = false;
  @track showPagination = false;
  @track prevBtnClass = 'btnBorderActive';
  @track nextBtnClass = 'btnBorderInActive';
  @track NoData = false;
  @track previewBody = true;
  iframeURL = '';
  connectedCallback() {
    loadStyle(this, TelosTouch + "/NativeTPPreview_LV.css");
    window.addEventListener('resize', this.updateRecordSize);
    if (window.screen.availWidth < 900) {
      this.topButtonStyle = 'slds-var-p-bottom_small slds-var-p-top_small slds-var-p-left_small';
      this.recordSize = 6;
      this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
      this.updateRecords();
    } else {
      this.topButtonStyle = 'slds-var-p-bottom_small';
    }
    if (this.lang === 'fr') {
      this.fr = true;
    }
    getListId()
      .then(result => {
        let returnVal = JSON.parse(result);
        this.listViewId = returnVal.listId;
      })
      .catch(error => {
        console.log(error);
      })
    getTemplateDetails()
      .then(result => {
        let returnVal = JSON.parse(result);
        returnVal.forEach(ele => {
          ele.ImgStyle = "background-image: url(" + ele.imageURL
        })
        this.privateTemplateList = [];
        this.templateList = returnVal;
        this.alltemplateList = returnVal;
        this.alltemplateList.forEach(ele => {
          if (ele.is_private == true) {
            this.privateTemplateList.push(ele);
          }
        })
        this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
        this.updateRecords();
      })
      .catch(error => {
        console.log(error);
      })
  }


  updateRecordSize = () => {
    if (window.screen.availWidth < 900) {
      this.topButtonStyle = 'slds-var-p-bottom_small slds-var-p-top_small slds-var-p-left_small';
      this.recordSize = 6;
      this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
      this.updateRecords();
    } else {
      this.topButtonStyle = 'slds-var-p-bottom_small';
    }
  }

  handleBackbuttonAction(event) {
    if (this.previewBody == false && this.mainBodyFlag == false) {
      this.mainBodyFlag = true;
      this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
      this.connectedCallback();
    } else {
      try {
        this.navigateToList(this.listViewId);
      } catch (error) {
        console.log(error);
      }
    }
  }

  handleSearchInput(event) {
    let searchKey = event.target.value.toLowerCase();
    let filteredTemplates = [];
    if(!this.fr){
      if(this.privateFlag){
        this.privateTemplateList.forEach((ele) => {
          if (ele.name.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      }else{
        this.alltemplateList.forEach((ele) => {
          if (ele.name.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      }
    }else{
      if(this.privateFlag){
        this.privateTemplateList.forEach((ele) => {
          if (ele.name_fr.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      }else{
        this.alltemplateList.forEach((ele) => {
          if (ele.name_fr.toLowerCase().includes(searchKey.trim())) {
            filteredTemplates.push(ele);
          }
        });
      }
    }
    // this.templateList.forEach(ele => {
    //   if (ele.name.toLowerCase().includes(searchKey)) {
    //     filteredTemplates.push(ele);
    //   }
    // })
    if (event.target.value.trim().length > 0) {
      this.templateList = filteredTemplates;
    } else {
      if (this.privateFlag) {
        this.templateList = this.privateTemplateList;
      } else {
        this.templateList = this.alltemplateList;
      }
    }
    this.currentPage = 1;
    this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
    this.updateRecords();
  }

  handleToggleChange(event) {
    this.privateFlag = event.target.checked;
    if (event.target.checked) {
      this.currentPage = 1;
      this.templateList = this.privateTemplateList;
    } else {
      this.templateList = this.alltemplateList;
    }
    this.currentPage = 1;
    this.prevPage = 1;
    this.nextPage = 2;
    this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
    this.updateRecords();
  }

  handleDivClick(event) {
    this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
    this.templateId = event.currentTarget.dataset.id;
    this.mainBodyFlag = false;
    this.previewBody = true;
    getIFrameDetails()
      .then(result => {
        let returnVal = result;
        if (this.fr) {
          this.iframeURL = returnVal.instanceURL + "/app/v1/#/touchpoint/" + this.templateId + "/customize?fullscreen=true&access_token=" + returnVal.accessToken + "&lang=fr_FR";
        } else {
          this.iframeURL = returnVal.instanceURL + "/app/v1/#/touchpoint/" + this.templateId + "/customize?fullscreen=true&access_token=" + returnVal.accessToken + "&lang=en_US";
        }
      })
      .catch(error => {
        console.log(error);
      })
  }

  goBackToMainPage() {
    this.mainBodyFlag = true;
  }

  get disablePrevious() {
    return this.currentPage <= 1
  }
  get disableNext() {
    return this.currentPage >= this.totalPage
  }
  previousHandler() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
      this.prevPage = this.currentPage;
      this.nextPage = this.prevPage + 1;
      this.updateRecords()
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
    if (this.templateList.length < 1) {
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
      this.prevBtnClass = 'btnBorderActive';
      this.nextBtnClass = 'btnBorderInActive';
    } else {
      this.prevBtnClass = 'btnBorderInActive';
      this.nextBtnClass = 'btnBorderActive';
    }
    const start = (this.currentPage - 1) * this.recordSize;
    const end = this.recordSize * this.currentPage;
    this.visibleRecords = this.templateList.slice(start, end);
    if (this.visibleRecords <= this.recordSize) {
      this.secondPageDisabled = true;
    } else {
      this.secondPageDisabled = false;
    }
  }

  handleCustomization() {
    this.previewBody = false;
    this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOTEMPLATES;
  }
}