/* eslint-disable eqeqeq */
import { api, LightningElement, track, wire } from "lwc";
import { makeRequest } from 'c/ttCallout';
import { labelLibrary } from 'c/ttLabels';
import LANG from "@salesforce/i18n/lang";
import { loadStyle } from "lightning/platformResourceLoader";
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex Methods
import generatePreviewIFrameUrl from "@salesforce/apex/TemplateGalleryCompHandler.generatePreviewIFrameUrl";
import getCalloutInfo from '@salesforce/apex/TelosTouchUtility.getCalloutInfo';
import getTouchPointTemplates from "@salesforce/apex/TemplateGalleryCompHandler.getTouchPointTemplates";
import SaveTouchPointTemplate from "@salesforce/apex/TemplateGalleryCompHandler.SaveTouchPointTemplate";

export default class TemplateGalleryComp extends LightningElement {
    
    @api campaignType = 'touchpoint';
    @api campSfId;
    currentPage = 1;
    fr = false;
    hideLastButton = false;
    iframeURL;
    isImageSpinner = false;
    @api isOpenTouchPoints = false;
    @track isPrivateToggle = false;
    isSpinner = false;
    isTemplatePage = false;
    isTemplatePresent = false;
    label = labelLibrary;
    lang = LANG;
    langValue = "ALL";
    listViewValue = 'public';
    mainTemplateList = [];
    mapTemplates = {};
    nextBtnClass = "btnBorderInActive";
    nextPage = 2;
    paginationList = [];
    prevBtnClass = "btnBorderActive";
    @track previewSaveDisabled = false;
    previewBody = false;
    prevPage = 1;
    privateTemplatesList = [];
    publicTemplatesList = [];
    recordSize = 10;
    searchValue = '';
    showCompliance = false;
    showPagination = false;
    sortingType = 'modifiedAt';
    statusValue = 'ALL';
    @api templateId;
    templatesList = [];
    @api templateLang;
    @api templateType;
    totalPage = 0;
    totalRecords;
    @track urls = {};
    

    get langOptions() {
        return [
            { label: this.label.All_Label, value: "ALL" },
            { label: this.label.English_Text, value: "en_US" },
            { label: this.label.French_Text, value: "fr_FR" }
        ];
    }

    get listViewOptions() {
        let options = [
            { label: this.label.Public_Text, value: 'public' },
																  
        ];
        if (this.campaignType == 'touchpoint') {
            options.push({ label: this.label.My_Touchpoints, value: 'private' });
        } else {
            options.push({ label: this.label.My_Templates, value: 'private' });
        }
        options.push({ label: this.label.Shared_With_Me, value: 'shared' });
        return options;
    }

    get statusOptions() {
        return [
            { label: this.label.All_Label, value: "ALL" },
            { label: this.label.Ready_Label, value: "PUBLISHED" },
            { label: this.label.Sent_Label, value: "SENT" }
        ];
    }

    get sortingOptions() {
        return [
            { label: this.label.LastModifiedDate, value: "modifiedAt" },
            { label: this.label.CreatedDateText, value: "created_at" },
            { label: this.label.TitleText, value: "title" },
            { label: this.label.TitleDesc, value: "titleDesc" }
        ];
    }

    @wire(getCalloutInfo)
    calloutInfo;

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
        this.labelSelection();
    }

    labelSelection() {
        if (this.campaignType == 'touchpoint') {
            this.label.Compliance_Label = this.label.Compliance_Message;
            this.label.Template_Gallery_Save_Label = this.label.Template_Gallery_Save_Text;
            this.label.TemplateNotSaved_Label = this.label.TouchPointTemplateNotSaved_Text;
            this.label.TemplateSaved_Label = this.label.TouchPointTemplateSaved_Text;
        } else if (this.campaignType == 'email') {
            this.label.Compliance_Label = this.label.Compliance_Message_Email;
            this.label.Template_Gallery_Save_Label = this.label.Template_Gallery_Save;
            this.label.TemplateNotSaved_Label = this.label.Template_Not_Saved;
            this.label.TemplateSaved_Label = this.label.Template_Saved;
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
        getTouchPointTemplates({ campId: this.campSfId, campaignType: this.campaignType })
            .then((data) => {
                if (data) {

                    let mapTemplates = JSON.parse(data);

                    Object.keys(mapTemplates).forEach(key => {
                        for (let x of mapTemplates[key]) {

                            if (x.Description) {
                                x.isDescriptionNull = false;
                            } else {
                                x.isDescriptionNull = true;
                            }
                            x = this.setTemplateBagdeColor(x);

                            if(this.campaignType == 'email'){
                                x.cardStyle = 'imgStyleCard_Email';
                            } else {
                                x.cardStyle = 'imgStyleCard';
                            }

                            //GETTING LANGUAGES
                            let templateLangs = [];
                            let templateLangCodes = [];
                            if(this.campaignType == 'touchpoint'){
                                let tpContent = JSON.parse(x.content);
                                for (let i=0; i < tpContent.languages.length; i++){
                                    templateLangCodes.push(tpContent.languages[i].code);
                                    if(tpContent.languages[i].code == "en_US"){
                                        templateLangs.push(this.label.English_Text);
                                    } else if(tpContent.languages[i].code == "fr_FR"){
                                        templateLangs.push(this.label.French_Text);
                                    }
                                }
                            } else if(this.campaignType == 'email'){
                                templateLangCodes.push(x.language);
                                if(x.language == "en_US"){
                                    templateLangs.push(this.label.English_Text);
                                } else if(x.language == "fr_FR"){
                                    templateLangs.push(this.label.French_Text);
                                }
                            }

                            x.langDescription = this.label.Language_Text+': '+templateLangs.join(', ');
                            x.lstLangCode = templateLangCodes;

                            //GETTING EMAIL THUMBNAIL
                            if(this.campaignType != 'email'){ continue; }

                            x.imageURL = "background-image: url(" + TelosTouch + "/loadingAnimation/Ellipsis-1.1s-200px.svg" + "); background-size: 15%;";

                            let calloutInfo = JSON.parse(this.calloutInfo.data.value);

                            let method = 'GET';
                            let endpoint = calloutInfo.domain+'/api/v1/template/email/thumbnail/' + x.id;

                            let header = {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer '+calloutInfo.token
                            };

                            let invoker = {
                                'className': 'templateGalleryComp',
                                'classMethod': 'getTemplates',
                                'recordId': ''
                            };
                            let eleObj = x;
                            makeRequest(endpoint, null, header, method, invoker)
                                .then(result => {
                                    console.log('result: ', JSON.stringify(result));
                                    console.log('result.status: ', result.status);
                                    if (result.status) {
                                        eleObj.imageURL = "background-image: url("+calloutInfo.domain+"/api/v1/attachments/"+result.body+");";
                                        this.isImageSpinner = true;
                                        this.isImageSpinner = false;
                                    } else {
                                        console.error('templateGalleryComp 1: ', result.status_code + ': ' + result.body);
                                    }
                                })
                                .catch(error => {
                                    let errorStr = '';
                                    if (typeof error == 'object' && error.message) {
                                        if (error.lineNumber) { errorStr = error.lineNumber + ' - '; }
                                        errorStr += error.message
                                    } else {
                                        errorStr = error;
                                    }
                                    console.error('templateGalleryComp 2: ', errorStr);
                                });
                            
                        }
                    });

                    this.templatesList = mapTemplates[this.listViewValue];
                    this.mapTemplates = mapTemplates;

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

    handleChange(event){

        if (event.target.dataset.id == 'langFilter') {
            this.langValue = event.detail.value;
        } else if (event.target.dataset.id == 'searchInput') {
            this.searchValue = event.target.value.toLowerCase();
        } else if (event.target.dataset.id == 'sortBy') {
            this.sortingType = event.detail.value;
        } else if (event.target.dataset.id == 'statusFilter') {
            this.statusValue = event.detail.value;
        } else if (event.target.dataset.id == 'tabFilter') {
            this.listViewValue = event.detail.value;
        }

        let lstTemplate = this.handleSearchInput();
        this.handleFilterChange(lstTemplate);

    }

    handleFilterChange(lstTemplate) {

        if (this.showPagination) {
            this.hideLastButton = false;
        }

        let lstTemplateFiltered = []

        for(let i=0; i < lstTemplate.length; i++){
            let ignoreRecord = false;
            //STATUS FILTER
            ignoreRecord |= (this.statusValue != 'ALL' && lstTemplate[i].status != this.statusValue);
            //LANGUAGE FILTER
            ignoreRecord |= (this.langValue != 'ALL' && !lstTemplate[i].lstLangCode.includes(this.langValue));

            if(!ignoreRecord){ lstTemplateFiltered.push(lstTemplate[i]); }
        }
        
        this.templatesList = lstTemplateFiltered;

        if (this.sortingType == 'title') { this.sortTemplatesList('title'); }
        else if (this.sortingType == 'created_at') { this.sortTemplatesList('created_at'); }
        else if (this.sortingType == 'modifiedAt') { this.sortTemplatesList('modifiedAt'); }
        else if (this.sortingType == 'titleDesc') { this.sortTemplatesList('titleDesc'); }
        
        this.currentPage = 1;
        this.prevPage = 1;
        this.nextPage = 2;
        this.totalPage = Math.ceil(this.templatesList.length / this.recordSize);

        this.updateRecords();
    }

    handleSearchInput() {
        try {

            let lstTemplate = []
            if (this.showPagination) {
                this.hideLastButton = false;
            }
            let searchKey = this.searchValue;
            let filteredTemplates = [];
            let currentTemplates = this.mapTemplates[this.listViewValue];
            
            currentTemplates.forEach((ele) => {
                if (ele.name.toLowerCase().includes(searchKey.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
                    filteredTemplates.push(ele);
                }
            });

            if (searchKey.trim().length > 0) {
                lstTemplate = filteredTemplates;
            } else {
                lstTemplate = currentTemplates;
            }
            return lstTemplate;
        } catch (error) {
        }
    }

    setTemplateBagdeColor(template){
        let defaultCSS = 'slds-float_left slds-var-m-top_xx-small slds-var-m-left_xx-small';
        if (template.status.toLowerCase() == 'published') {
            template.statusLabel = this.label.Ready_Label;
            template.statusDescription = this.label.Ready_Status_Description;
            template.statusCSS = '';
        } else if (template.status.toLowerCase() == 'sent') {
            template.statusLabel = this.label.Sent_Label;
            template.statusDescription = this.label.Sent_Status_Description;
            template.statusCSS = 'slds-theme_success ';
        }
        template.statusCSS += defaultCSS;
        return template;
    }

    sortTemplatesList(sortBy) {
        let list = this.templatesList;
        if (sortBy !== 'title' && sortBy !== 'titleDesc') {
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
        } else if (sortBy === 'title' || sortBy === 'titleDesc') {
            let sort = 'name';
            if (sortBy === 'title') {
                let temp = 0;
                for (let x = 0; x < list.length - 1; x++) {
                    for (let y = 0; y < list.length - x - 1; y++) {
                        if (list[y][sort].toLowerCase() > list[y + 1][sort].toLowerCase()) {
                            temp = list[y];
                            list[y] = list[y + 1];
                            list[y + 1] = temp;
                        }
                    }
                }
            } else {
                let temp = 0;
                for (let x = 0; x < list.length - 1; x++) {
                    for (let y = 0; y < list.length - x - 1; y++) {
                        if (list[y][sort].toLowerCase() < list[y + 1][sort].toLowerCase()) {
                            temp = list[y];
                            list[y] = list[y + 1];
                            list[y + 1] = temp;
                        }
                    }
                }
            }
        }
        this.templatesList = list;
        try {
            if (this.searchValue) {
                let tempList = [];
                list.forEach((ele) => {
                    if (ele.name.toLowerCase().includes(this.searchValue.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
                        tempList.push(ele);
                    }
                });
                this.templatesList = tempList;
            }
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
            this.hideLastButton = false;
            this.updateRecords();
        }
    }

    nextHandler() {
        if (this.currentPage < this.totalPage) {
            this.currentPage = this.currentPage + 1;
            this.prevPage = this.currentPage;
            this.nextPage = this.prevPage + 1;
            this.hideLastButton = false;
            this.updateRecords();
        }
        if (this.currentPage === this.totalPage) {
            this.prevPage = this.currentPage;
            this.hideLastButton = true;
            this.updateRecords();
        }
    }

    nextPageAction() {
        this.currentPage = this.nextPage;
        if (this.currentPage === this.totalPage) {
            this.prevPage = this.currentPage;
            this.hideLastButton = true;
        }
        this.updateRecords();
    }

    prevPageAction() {
        this.currentPage = this.prevPage;
        this.hideLastButton = this.currentPage === this.totalPage ? true : false;
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

        this.templatesList = this.mapTemplates[this.listViewValue];
        this.sortTemplatesList(this.sortingType);

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
        SaveTouchPointTemplate({ 
            campId: this.campSfId, 
            templateGraphId: this.templateId, 
            templateType: this.campaignType,
            lang: this.templateLang
        })
            .then((data) => {
                if (data.status == 'success') {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: this.label.TemplateSaved_Label,
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
                            message: this.label.TemplateNotSaved_Label,
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
        generatePreviewIFrameUrl({ templateId: this.templateId, language: 'en_US', campId: this.campSfId})
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
}