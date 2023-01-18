import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LANG from '@salesforce/i18n/lang';
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

//Apex Methods
import getIFrameDetails from '@salesforce/apex/TouchPointPreviewController.getIFrameDetails';
import getListId from '@salesforce/apex/TouchPointPreviewController.getListId';
import getNewTemplateBuilder from '@salesforce/apex/TouchPointPreviewController.getNewTemplateBuilder';
import getTemplateDetails from '@salesforce/apex/TouchPointPreviewController.getTemplateDetails';

//Custom Labels
import ALL_TEMP_TEXT from '@salesforce/label/c.TouchpointPreview_All_Templates';
import create_new_text from '@salesforce/label/c.Create_New_Text';
import NO_DATA_TEXT from '@salesforce/label/c.TouchpointPreview_NoData_Text';
import PRIVATE_TEMP_TEXT from '@salesforce/label/c.TouchpointPreview_Private_Template';
import TOUCHPOINTPREVIEW_BACKTOLISTVIEW from '@salesforce/label/c.TouchpointPreview_BackToListView';
import TOUCHPOINTPREVIEW_BACKTOTEMPLATES from '@salesforce/label/c.TouchpointPreview_BackToTemplates';

export default class NativeTouchPointPreviewLV extends NavigationMixin(LightningElement) {

    label = {
        ALL_TEMP_TEXT,
        create_new_text,
        NO_DATA_TEXT,
        PRIVATE_TEMP_TEXT,
        TOUCHPOINTPREVIEW_BACKTOLISTVIEW,
        TOUCHPOINTPREVIEW_BACKTOTEMPLATES
    };

    @track alltemplateList = [];
    builderTemplateId;
    creationEnabled = true;
    @track currentPage = 1;
    currentDiv = 'gallery';
    filterName = '';
    fr = false;
    iframeURL = '';
    lang = LANG;
    listViewId = '';
    @track mainBodyFlag = true;
    @api navigateToList;
    @track nextBtnClass = 'btnBorderInActive';
    @track nextPage = 2;
    @track NoData = false;
    @track prevBtnClass = 'btnBorderActive';
    @track previewBody = true;
    @track prevPage = 1;
    @track privateFlag = false;
    @track privateTemplateList = [];
    @track recordSize = 10;
    @track secondPageDisabled = true;
    @track showPagination = false;
    showSpinner = false;
    @track showTopBackButton = true;
    @track templateId = '';
    @track templateList = [];
    @track topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
    @track topButtonStyle = 'slds-var-p-bottom_small';
    @track totalPage = 0;
    @track totalRecords;
    @track visibleRecords = [];

    get disablePrevious() {
        return this.currentPage <= 1
    }
    get disableNext() {
        return this.currentPage >= this.totalPage
    }

    get isBuilder() {
        return (this.currentDiv == 'builder');
    }

    get isGallery() {
        return (this.currentDiv == 'gallery');
    }

    get isPreview() {
        return (this.currentDiv == 'preview');
    }

    connectedCallback() {

        this.showSpinner = true;

        loadStyle(this, TelosTouch + "/NativeTPPreview_LV.css");
        window.addEventListener('resize', this.updateRecordSize);
        if (window.screen.availWidth < 900) {
            this.topButtonStyle = 'slds-var-p-bottom_small slds-var-p-top_small slds-var-p-left_small';
            this.recordSize = 6;
            this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
            this.updateRecords();
        } else {
            this.recordSize = 10;
            this.topButtonStyle = 'slds-var-p-bottom_small';
        }
        if (this.lang === 'fr') {
            this.fr = true;
        }

        if (this.creationEnabled) {
            this.recordSize = (this.recordSize - 1);
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
            .finally(() => {
                this.showSpinner = false;
            });

    }

    goBackToMainPage() {
        this.mainBodyFlag = true;
        this.currentDiv = 'gallery';
    }

    handleBackbuttonAction(event) {
        if (this.previewBody == false && this.currentDiv != 'gallery') {
            this.mainBodyFlag = true;
            this.currentDiv = 'gallery';
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

    handleOpenNewBuilder() {
        this.isShowSpinner = true;
        getNewTemplateBuilder()
            .then((result) => {
                if (result && result.status == 'success') {
                    this.iframeURL = result.value;
                    this.previewBody = false;
                    this.currentDiv = 'builder';
                    this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOTEMPLATES;
                } else if (result && result.status == 'error') {
                    console.error('Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleConfirmRevoke Error: ', error);
            })
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    handleCustomization() {
        this.previewBody = false;
        this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOTEMPLATES;
    }

    handleDivClick(event) {
        this.isShowSpinner = true;
        this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
        this.templateId = event.currentTarget.dataset.id;
        this.mainBodyFlag = false;
        this.currentDiv = 'preview';
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
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    handleSearchInput(event) {
        let searchKey = event.target.value.toLowerCase();
        let filteredTemplates = [];
        if (!this.fr) {
            if (this.privateFlag) {
                this.privateTemplateList.forEach((ele) => {
                    if (ele.name.toLowerCase().includes(searchKey.trim())) {
                        filteredTemplates.push(ele);
                    }
                });
            } else {
                this.alltemplateList.forEach((ele) => {
                    if (ele.name.toLowerCase().includes(searchKey.trim())) {
                        filteredTemplates.push(ele);
                    }
                });
            }
        } else {
            if (this.privateFlag) {
                this.privateTemplateList.forEach((ele) => {
                    if (ele.name_fr.toLowerCase().includes(searchKey.trim())) {
                        filteredTemplates.push(ele);
                    }
                });
            } else {
                this.alltemplateList.forEach((ele) => {
                    if (ele.name_fr.toLowerCase().includes(searchKey.trim())) {
                        filteredTemplates.push(ele);
                    }
                });
            }
        }
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

    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.prevPage = this.currentPage;
            this.nextPage = this.prevPage + 1;
            this.updateRecords()
        }
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

}