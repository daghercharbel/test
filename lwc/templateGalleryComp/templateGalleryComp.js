/* eslint-disable eqeqeq */
import { api, LightningElement, track } from "lwc";
import LANG from "@salesforce/i18n/lang";
import { loadStyle } from "lightning/platformResourceLoader";
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex Methods
import generatePreviewIFrameUrl from "@salesforce/apex/TemplateGalleryCompHandler.generatePreviewIFrameUrl";
import getTouchPointTemplates from "@salesforce/apex/TemplateGalleryCompHandler.getTouchPointTemplates";
import SaveTouchPointTemplate from "@salesforce/apex/TemplateGalleryCompHandler.SaveTouchPointTemplate";

// Custom Labels
import All_Label from '@salesforce/label/c.All_Label';
import Back_Button_Label from "@salesforce/label/c.Back_Button_Label";
import Cancel_Button_Label from "@salesforce/label/c.Cancel_Button_Label";
import Compliance_Confirm_Text from '@salesforce/label/c.Compliance_Confirm_Text';
import Compliance_Message from "@salesforce/label/c.Compliance_Message";
import Compliance_Message_Email from "@salesforce/label/c.Compliance_Message_Email";
import Compliance_Title from "@salesforce/label/c.Compliance_Title";
import CreatedDateText from "@salesforce/label/c.CreatedDateText";
import Email_Text from "@salesforce/label/c.Email_Text";
import English_Text from "@salesforce/label/c.English_Text";
import French_Text from "@salesforce/label/c.French_Text";
import Language_Text from "@salesforce/label/c.Language_Text";
import LastModifiedDate from "@salesforce/label/c.LastModifiedDate";
import My_Touchpoints from "@salesforce/label/c.My_Touchpoints";
import No_Data_Text from "@salesforce/label/c.No_Data_Text";
import None_Text from "@salesforce/label/c.None_Text";
import Public_Text from "@salesforce/label/c.Public_Text";
import Ready_Label from "@salesforce/label/c.Ready_Label";
import Ready_Status_Description from "@salesforce/label/c.Ready_Status_Description";
import Save_Button_Label from "@salesforce/label/c.Save_Button_Label";
import Search_Text from "@salesforce/label/c.Search_Text";
import Sent_Label from '@salesforce/label/c.Sent_Label';
import Sent_Status_Description from "@salesforce/label/c.Sent_Status_Description";
import Shared_With_Me from '@salesforce/label/c.Shared_With_Me';
import showText from "@salesforce/label/c.showText";
import Sort_By_Text from "@salesforce/label/c.Sort_By_Text";
import Template_Gallery_Save from '@salesforce/label/c.Template_Gallery_Save';
import Template_Gallery_Save_Text from '@salesforce/label/c.Template_Gallery_Save_Text';
import Template_Not_Saved from '@salesforce/label/c.Template_Not_Saved';
import TitleDesc from "@salesforce/label/c.TitleDesc";
import TitleText from "@salesforce/label/c.TitleText";
import TouchPoint_Experience_Text from "@salesforce/label/c.TouchPoint_Experience_Text";
import TouchPointTemplateNotSaved_Text from "@salesforce/label/c.TouchPointTemplateNotSaved_Text";
import TouchPointTemplateSaved_Text from "@salesforce/label/c.TouchPointTemplateSaved_Text";
import Template_Saved from "@salesforce/label/c.Template_Saved";

export default class TemplateGalleryComp extends LightningElement {

    label = {
        All_Label,
        Back_Button_Label,
        Cancel_Button_Label,
        Compliance_Confirm_Text,
        Compliance_Title,
        CreatedDateText,
        Email_Text,
        English_Text,
        French_Text,
        Language_Text,
        LastModifiedDate,
        My_Touchpoints,
        No_Data_Text,
        None_Text,
        Public_Text,
        Ready_Label,
        Ready_Status_Description,
        Save_Button_Label,
        Search_Text,
        Sent_Label,
        Sent_Status_Description,
        Shared_With_Me,
        showText,
        Sort_By_Text,
        TitleDesc,
        TitleText,
        TouchPoint_Experience_Text,
        TouchPointTemplateSaved_Text
    };
    
    @api campaignType = 'touchpoint';
    @api campSfId;
    currentPage = 1;
    fr = false;
    hideLastButton = false;
    iframeURL;
    @api isOpenTouchPoints = false;
    @track isPrivateToggle = false;
    isSpinner = false;
    isTemplatePage = false;
    isTemplatePresent = false;
    lang = LANG;
    langValue = "en_US";
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
    @api templateId;
    templatesList = [];
    totalPage = 0;
    totalRecords;
    @track urls = {};

    get langOptions() {
        return [
            { label: this.label.English_Text, value: "en_US" },
            { label: this.label.French_Text, value: "fr_FR" }
        ];
    }

    get listViewOptions() {
        let options = [
            { label: this.label.Public_Text, value: 'public' },
            { label: this.label.My_Touchpoints, value: 'private' }
        ];
        if (this.campaignType == 'touchpoint') {
            options.push({ label: this.label.Shared_With_Me, value: 'shared' });
        }
        return options;
    }

    get sortingOptions() {
        return [
            { label: this.label.LastModifiedDate, value: "modifiedAt" },
            { label: this.label.CreatedDateText, value: "created_at" },
            { label: this.label.TitleText, value: "title" },
            { label: this.label.TitleDesc, value: "titleDesc" }
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
        this.labelSelection();
    }

    labelSelection() {
        if (this.campaignType == 'touchpoint') {
            this.label.Compliance_Label = Compliance_Message;
            this.label.Template_Gallery_Save_Label = Template_Gallery_Save_Text;
            this.label.TemplateNotSaved_Label = TouchPointTemplateNotSaved_Text;
            this.label.TemplateSaved_Label = TouchPointTemplateSaved_Text;
        } else if (this.campaignType == 'email') {
            this.label.Compliance_Label = Compliance_Message_Email;
            this.label.Template_Gallery_Save_Label = Template_Gallery_Save;
            this.label.TemplateNotSaved_Label = Template_Not_Saved;
            this.label.TemplateSaved_Label = Template_Saved;
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
        getTouchPointTemplates({ campId: this.campSfId })
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

    handleFilterChange(event) {

        if (this.showPagination) {
            this.hideLastButton = false;
        }

        if (event.target.dataset.id == 'templateShow') {
            this.listViewValue = event.detail.value;
        } else if (event.target.dataset.id == 'templateFilter') {
            this.sortingType = event.detail.value;
        }
        
        this.templatesList = this.mapTemplates[this.listViewValue];

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
            let sort = (this.fr) ? 'name_fr' : 'name';
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
                if (!this.fr) {
                    list.forEach((ele) => {
                        if (ele.name.toLowerCase().includes(this.searchValue.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
                            tempList.push(ele);
                        }
                    });
                } else {
                    list.forEach((ele) => {
                        if (ele.name_fr.toLowerCase().includes(this.searchValue.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
                            tempList.push(ele);
                        }
                    });
                }
                this.templatesList = tempList;
            }
        } catch (error) {
        }
    }

    handleSearchInput(event) {
        try {
            if (this.showPagination) {
                this.hideLastButton = false;
            }
            let searchKey = event.target.value.toLowerCase();
            this.searchValue = searchKey;
            let filteredTemplates = [];
            let currentTemplates = mapTemplates[this.listViewValue];

            if (!this.fr) {
                currentTemplates.forEach((ele) => {
                    if (ele.name.toLowerCase().includes(searchKey.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
                        filteredTemplates.push(ele);
                    }
                });
            } else {
                currentTemplates.forEach((ele) => {
                    if (ele.name_fr.toLowerCase().includes(searchKey.trim()) || (!ele.isDescriptionNull && ele.Description.toLowerCase().includes(this.searchValue.trim()))) {
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
        SaveTouchPointTemplate({ campaignRecordId: this.campSfId, touchPointTemplateId: this.templateId })
            .then((data) => {
                if (data) {
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
        generatePreviewIFrameUrl({ templateId: this.templateId, language: this.langValue, campId: this.campSfId})
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