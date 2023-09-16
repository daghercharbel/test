import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LANG from '@salesforce/i18n/lang';
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { loadStyle } from "lightning/platformResourceLoader";
import { makeRequest } from 'c/ttCallout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import copyTemplate from '@salesforce/apex/TouchPointPreviewController.copyTemplate';
import deleteTemplate from '@salesforce/apex/TouchPointPreviewController.deleteTemplate';
import getIFrameDetails from '@salesforce/apex/TouchPointPreviewController.getIFrameDetails';
import editTemplate from '@salesforce/apex/TouchPointPreviewController.editTemplate';
import createTemplate from '@salesforce/apex/TouchPointPreviewController.createTemplate';
import getSharableUsers from '@salesforce/apex/TouchPointPreviewController.getSharableUsers';
import getSystemInfo from '@salesforce/apex/TouchPointPreviewController.getSystemInfo';
import getTemplateDetails from '@salesforce/apex/TouchPointPreviewController.getTemplateDetails';
import updateTemplatePermission from '@salesforce/apex/TouchPointPreviewController.updateTemplatePermission';
import checkIfUserHaveCreationAcess from '@salesforce/apex/TouchPointPreviewController.checkIfUserHaveCreationAcess';
import getCalloutInfo from '@salesforce/apex/TelosTouchUtility.getCalloutInfo';

//Custom Labels
import All_Label from '@salesforce/label/c.All_Label';
import Cancel_Button_Label from "@salesforce/label/c.Cancel_Button_Label";
import create_new_text from '@salesforce/label/c.Create_New_Text';
import CreatedDateText from "@salesforce/label/c.CreatedDateText";
import Draft_Status_Description from "@salesforce/label/c.Draft_Status_Description";
import Drafted_Label from "@salesforce/label/c.Drafted_Label";
import Duplicate_Button_Description from "@salesforce/label/c.Duplicate_Button_Description";
import LastModifiedDate from "@salesforce/label/c.LastModifiedDate";
import My_Touchpoints from "@salesforce/label/c.My_Touchpoints";
import My_Emails from "@salesforce/label/c.My_Emails";
import Email_Text from "@salesforce/label/c.Email_Text";
import Touchpoint_Label from "@salesforce/label/c.Touchpoint_Label";
import NO_DATA_TEXT from '@salesforce/label/c.TouchpointPreview_NoData_Text';
import Order_by_Label from '@salesforce/label/c.Order_by_Label';
import Private_Permission from '@salesforce/label/c.Private_Permission';
import Private_Permission_Description from '@salesforce/label/c.Private_Permission_Description';
import Public_Permission from '@salesforce/label/c.Public_Permission';
import Public_Permission_Description from '@salesforce/label/c.Public_Permission_Description';
import Public_Text from '@salesforce/label/c.Public_Text';
import Ready_Label from "@salesforce/label/c.Ready_Label";
import Ready_Status_Description from "@salesforce/label/c.Ready_Status_Description";
import Remove_Text from "@salesforce/label/c.Remove_Text";
import Restricted_Permission from '@salesforce/label/c.Restricted_Permission';
import Restricted_Permission_Description from '@salesforce/label/c.Restricted_Permission_Description';
import Sent_Label from '@salesforce/label/c.Sent_Label';
import Sent_Status_Description from "@salesforce/label/c.Sent_Status_Description";
import Shared_With_Me from '@salesforce/label/c.Shared_With_Me';
import Sort_By_Text from "@salesforce/label/c.Sort_By_Text";
import Status_Text from "@salesforce/label/c.Status_Text";
import TitleDesc from "@salesforce/label/c.TitleDesc";
import TitleText from "@salesforce/label/c.TitleText";
import TOUCHPOINTPREVIEW_BACKTOLISTVIEW from '@salesforce/label/c.TouchpointPreview_BackToListView';
import TOUCHPOINTPREVIEW_BACKTOTEMPLATES from '@salesforce/label/c.TouchpointPreview_BackToTemplates';

export default class NativeTouchPointPreviewLV extends NavigationMixin(LightningElement) {

    label = {
        All_Label,
        Cancel_Button_Label,
        create_new_text,
        CreatedDateText,
        Draft_Status_Description,
        Drafted_Label,
        Duplicate_Button_Description,
        LastModifiedDate,
        My_Touchpoints,
        My_Emails,
        Email_Text,
        Touchpoint_Label,
        NO_DATA_TEXT,
        Order_by_Label,
        Private_Permission,
        Private_Permission_Description,
        Public_Permission,
        Public_Permission_Description,
        Public_Text,
        Ready_Label,
        Ready_Status_Description,
        Remove_Text,
        Restricted_Permission,
        Restricted_Permission_Description,
        Sent_Label,
        Sent_Status_Description,
        Shared_With_Me,
        Sort_By_Text,
        Status_Text,
        TitleDesc,
        TitleText,
        TOUCHPOINTPREVIEW_BACKTOLISTVIEW,
        TOUCHPOINTPREVIEW_BACKTOTEMPLATES
    };

    cardClass = '';
    createNewCardClass = '';
    builderTemplateId;
    creationEnabled = false;
    @track currentPage = 1;
    currentDiv = 'gallery';
    filterName = '';
    instanceUrl = '';
    fr = false;
    iframeURL = '';
    isAdmin = false;
    lang = LANG;
    listViewId = '';
    listViewValue = 'private';
    mapTemplates = {};
    @api navigateToList;
    @api libraryType = '';
    @track nextBtnClass = 'btnBorderInActive';
    @track nextPage = 2;
    @track NoData = false;
    @track prevBtnClass = 'btnBorderActive';
    @track previewBody = true;
    @track prevPage = 1;
    @track privateTemplateList = [];
    @track recordSize = 10;
    searchInput = '';
    @track secondPageDisabled = true;
    selectedPermission = 'private';
    selectedShareableUsers = [];
    selectedSort = 'updated_at';
    selectedStatus = 'all';
    selectedType = 'all';
    shareableUsersOptions = [];
    @track showPagination = false;
    showPermission = false;
    showSpinner = false;
    showImageSpinner = false;
    @track showTopBackButton = true;
    @track templateId = '';
    @track templateList = [];
    @track topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
    @track topButtonStyle = 'slds-var-p-bottom_small';
    @track totalPage = 0;
    @track totalRecords;
    @track visibleRecords = [];
    @track showEmailBuilder = false;
    @track emailName = '';
    @track emailSubject = '';
    @track emailLanguage = 'en_US';
    calloutInfo;

    @wire(getCalloutInfo)
    getCalloutInfoWire({ error, data }) {
        if (data) {
            if (data.status == 'success') {
                this.getTemplates();
                this.calloutInfo = JSON.parse(data.value);
            } else {
                this.dispatchEvent(new ShowToastEvent(
                    {
                        title: 'Authentication Error',
                        message: 'User not authenticated with TelosTouch 1',
                        variant: 'error',
                        mode: 'dismissable'
                    }
                ));
            }
            this.showSpinner = false;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent(
                {
                    title: 'Authentication Error',
                    message: 'User not authenticated with TelosTouch 2',
                    variant: 'error',
                    mode: 'dismissable'
                }
            ));
            this.showSpinner = false;
        }
    }

    get disablePrevious() {
        return this.currentPage <= 1
    }
    get disableNext() {
        return this.currentPage >= this.totalPage
    }

    get isBuilder() {
        return (this.currentDiv == 'builder');
    }

    get isEmailLibrary() {
        return this.libraryType.toLowerCase() === 'email';
    }

    get isRestrictedEmpty() {
        return (this.selectedPermission == 'restricted'
            && (!this.selectedShareableUsers || this.selectedShareableUsers.length == 0));
    }

    get isGallery() {
        return (this.currentDiv == 'gallery');
    }

    get isPreview() {
        return (this.currentDiv == 'preview');
    }

    get isRestrictedPermission() {
        return (this.selectedPermission == 'restricted');
    }

    get listViewOptions() {
        return [
            { label: this.libraryType.toLowerCase() === 'email' ? this.label.My_Emails : this.label.My_Touchpoints, value: 'private' },
            { label: this.label.Shared_With_Me, value: 'shared' },
            { label: this.label.Public_Text, value: 'public' }
        ];
    }

    get permissionOptions() {
        return [
            { label: this.label.Public_Permission, value: 'public', title: 'TEST TITLE' },
            { label: this.label.Private_Permission, value: 'private' }
            // { label: this.label.Restricted_Permission, value: 'restricted' },
        ];
    }

    get sortingOptions() {
        return [
            { label: this.label.LastModifiedDate, value: "updated_at" },
            { label: this.label.CreatedDateText, value: "created_at" },
            { label: this.label.TitleText, value: "title" },
            { label: this.label.TitleDesc, value: "titleDesc" }
        ];
    }

    get statusOptions() {
        return [
            { label: this.label.All_Label, value: "all" },
            { label: this.label.Drafted_Label, value: "drafted" },
            { label: this.label.Ready_Label, value: "published" },
            { label: this.label.Sent_Label, value: "sent" }
        ];
    }

    get typeOptions() {
        return [
            { label: this.label.All_Label, value: "all" },
            { label: this.label.Email_Text, value: "email" },
            { label: this.label.Touchpoint_Label, value: "touchpoint" }
        ];
    }

    get emailLanguageOptions() {
        return [
            { label: 'English', value: 'en_US' },
            { label: 'French', value: 'fr_FR' }
        ];
    }

    connectedCallback() {
        if (this.libraryType.toLowerCase() == 'email') {
            this.cardClass = 'imgStyleCardEmail';
            this.createNewCardClass = 'createNewCardEmail slds-align_absolute-center';
        } else {
            this.cardClass = 'imgStyleCard';
            this.createNewCardClass = 'createNewCard slds-align_absolute-center';
        }
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

        getSystemInfo()
            .then(result => {
                let returnVal = JSON.parse(result);
                this.listViewId = returnVal.listViewId;
                this.isAdmin = returnVal.isAdmin;
            })
            .catch(error => {
                console.error('getSystemInfo error:: ', error);
            })

        checkIfUserHaveCreationAcess()
            .then((data) => {
                this.creationEnabled = data;
            })
            .catch((error) => {
                this.creationEnabled = false;
            })
            .finally(() => {
                if (this.creationEnabled) {
                    this.recordSize = (this.recordSize - 1);
                }
            });
    }
    setTpReadyBadge(template) {
        if (template.status.toLowerCase() == 'drafted' && (template.is_tp_ready)) {
            template.showTpReady = 'false';
        } else if (template.status.toLowerCase() == 'published' && (template.is_tp_ready)) {
            template.showTpReady = 'true';
        } else if (template.status.toLowerCase() == 'sent' && (template.is_tp_ready)) {
            template.showTpReady = 'true';
        }
    }

    getTemplates() {
        getTemplateDetails({ libraryType: this.libraryType })
            .then(result => {
                let mapTemplates = JSON.parse(result);
                Object.keys(mapTemplates).forEach(key => {
                    mapTemplates[key].forEach(ele => {
                        if (this.libraryType.toLowerCase() == 'touchpoint') {
                            ele.ImgStyle = "background-image: url(" + ele.imageURL + ")";
                        } else if (this.libraryType.toLowerCase() == 'email') {
                            ele.ImgStyle = "background-image: url(" + TelosTouch + "/loadingAnimation/Ellipsis-1.1s-200px.svg" + "); background-size: 15%;";
                            let method = 'GET';
                            let endpoint = this.calloutInfo.domain + '/api/v1/template/email/thumbnail/' + ele.id;
                            let headers = {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer ' + this.calloutInfo.token
                            };
                            let invoker = {
                                'className': 'nativeTouchPointPreviewLV',
                                'classMethod': 'getTemplates',
                                'recordId': ''
                            };
                            let eleObj = ele;
                            makeRequest(endpoint, null, headers, method, invoker)
                                .then(result => {
                                    if (result.status) {
                                        eleObj.ImgStyle = `background-image: url(${eleObj.url}/api/v1/attachments/${result.body})`;
                                        this.showImageSpinner = true;
                                        this.showImageSpinner = false;
                                    } else {
                                        console.error('nativeTouchPointPreviewLV 1: ', result.status_code + ': ' + result.body);
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
                                    console.error('nativeTouchPointPreviewLV 2: ', errorStr);
                                });
                        }
                        if (key == 'private' && ele.status.toLowerCase() == 'published' && this.isAdmin) {
                            ele.showPermissionBtn = true;
                            ele = this.setTemplatePermission(ele);
                        } else {
                            ele.showPermissionBtn = false;
                        }
                        ele = this.setTemplateBagdeColor(ele);

                        if ((key == 'private' || this.isAdmin) && ele.status.toLowerCase() != 'sent') {
                            ele.showDeleteBtn = true;
                        } else {
                            ele.showDeleteBtn = false;
                        }
                        if (this.libraryType.toLowerCase() == 'email') {
                            ele = this.setTpReadyBadge(ele);
                        }
                    })
                });
                let returnVal = mapTemplates[this.listViewValue];
                this.mapTemplates = mapTemplates;

                this.templateList = returnVal;
                this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
                this.updateRecords();
            })
            .catch(error => {
                console.error("getTemplateDetails error: " + error.message);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    filterBasedOnType(templateList) {
        let newTemplateList = [];
        if (this.selectedType === 'all') {
            newTemplateList = templateList;
        } else if (this.selectedType === 'email') {
            templateList.forEach(function (template, index, object) {
                if (template.is_tp_ready === false) {
                    newTemplateList.push(template);
                }
            });
        } else if (this.selectedType === 'touchpoint') {
            templateList.forEach(function (template, index, object) {
                if (template.is_tp_ready === true) {
                    newTemplateList.push(template);
                }
            });
        }

        return newTemplateList;
    }

    filterTemplatesList(templateList) {

        let selectedStatus = this.selectedStatus;
        let newTemplateList = [];

        if (selectedStatus == 'all') {
            newTemplateList = templateList;
        } else {
            templateList.forEach(function (template, index, object) {
                if (template.status.toLowerCase() == selectedStatus) {
                    newTemplateList.push(template);
                }
            });
        }

        return newTemplateList;
    }

    goBackToMainPage() {
        this.currentDiv = 'gallery';
        this.getTemplates();
    }

    handleBackbuttonAction(event) {
        try {
            this.navigateToListView(this.listViewId);
        } catch (error) {
            console.error('handleBackbuttonAction error:: ', error);
        }
    }

    handleCopyTemplate(event) {

        this.showSpinner = true;
        let templateOrEmailId = event.currentTarget.dataset.id;

        if (this.libraryType.toLowerCase() == 'touchpoint') {
            this.copyTemplateOrEmail(templateOrEmailId, '');
        } else {
            this.copyTemplateOrEmail('', templateOrEmailId);
        }

    }

    copyTemplateOrEmail(templateId, emailId) {

        copyTemplate({ templateId: templateId, emailId: emailId, libraryType: this.libraryType })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.getTemplates();
                } else if (result && result.status == 'error') {
                    console.error('copyTemplateOrEmail Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleCopyTemplate Error: ', error);
                this.showSpinner = false;
            })
    }

    handleCreateTemplate() {
        this.showSpinner = true;
        if (this.libraryType.toLowerCase() == 'email') {
            this.showEmailBuilder = true;
            this.showSpinner = false;
        } else {
            this.createNewTemplate();
        }
    }

    createNewTemplate() {
        createTemplate({ libraryType: this.libraryType, lang: this.emailLanguage, emailName: this.emailName, emailSub: this.emailSubject })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.iframeURL = result.value;
                    this.previewBody = false;
                    this.currentDiv = 'builder';
                    this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOTEMPLATES;
                } else if (result && result.status == 'error') {
                    console.error('createNewTemplate Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleOpenNewBuilder Error: ', error);
            })
            .finally(() => {
                this.showSpinner = false;
                this.closeEmailBuilder();
            });
    }

    handleEmailBuilder(event) {
        if (event.currentTarget.dataset.id == 'emailName') {
            this.emailName = event.target.value;
        } else if (event.currentTarget.dataset.id == 'emailSub') {
            this.emailSubject = event.target.value;
        } else if (event.currentTarget.dataset.id == 'emailLang') {
            this.emailLanguage = event.target.value;
        }
    }

    saveEmailTemplate() {
        this.showSpinner = true;
        //have to update backend for both touchpoint template and email template 
        this.createNewTemplate();
    }

    closeEmailBuilder() {
        this.showEmailBuilder = false;
    }

    //WILL BE DELETE IF CONFIRMED THE PREVIEW DIV WON'T BE USED ANYMORE - VINICIUS DUARTE
    /*handleDivClick(event) {
        this.showSpinner = true;
        this.topButtonLabel = this.label.TOUCHPOINTPREVIEW_BACKTOLISTVIEW;
        this.templateId = event.currentTarget.dataset.id;
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
                this.showSpinner = false;
            });
    }*/

    handleDeleteTemplate(event) {

        this.showSpinner = true;
        let templateOrEmailId = event.currentTarget.dataset.id;
        if (this.libraryType.toLowerCase() == 'touchpoint') {
            this.deleteTemplateOrEmail(templateOrEmailId, '');
        } else {
            this.deleteTemplateOrEmail('', templateOrEmailId);
        }

    }
    deleteTemplateOrEmail(templateId, emailId) {
        deleteTemplate({ templateId: templateId, emailId: emailId, libraryType: this.libraryType })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.getTemplates();
                } else if (result && result.status == 'error') {
                    console.error('deleteTemplateOrEmail Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleDeleteTemplate Error: ', error);
                this.showSpinner = false;
            })
    }

    handleEditTemplate(event) {
        this.showSpinner = true;
        let templateEmailId = event.currentTarget.dataset.id;
        this.editTemplateOrEmail(templateEmailId, '');
    }

    editTemplateOrEmail(templateId, emailId) {
        console.log('templateId: ', templateId);
        editTemplate({ templateId: templateId, libraryType: this.libraryType })
            .then((result) => {
                if (result && result.status == 'success') {
                    this.iframeURL = result.value;
                    this.previewBody = false;
                    this.currentDiv = 'builder';
                } else if (result && result.status == 'error') {
                    console.error('editTemplateOrEmail Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch handleEditTemplate Error: ', error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleFilterChange(event) {
        this.selectedStatus = event.detail.value;
        this.prepareTemplateList();
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.prepareTemplateList();
    }

    handleRadioChange(event) {

        let mapTemplates = this.mapTemplates;
        this.listViewValue = event.detail.value;
        this.templateList = mapTemplates[this.listViewValue];
        this.prepareTemplateList();

    }

    handleSearchInput(event) {
        this.searchInput = event.target.value;
        this.prepareTemplateList();
    }

    handleShareableChange(event) {
        this.selectedShareableUsers = event.detail.value;
    }

    handleSortChange(event) {
        this.selectedSort = event.detail.value;
        this.prepareTemplateList();
    }

    handleTemplatePermissionChange(event) {
        let permissionType = event.detail.value;
        let selectedTemplate = this.selectedTemplate;
        selectedTemplate.permissionType = permissionType;
        if (permissionType == 'public') {
            selectedTemplate.permissionBtnIcon = 'utility:world';
            selectedTemplate.permissionBtnDescr = this.label.Public_Permission_Description;
        } else if (permissionType == 'private') {
            selectedTemplate.permissionBtnIcon = 'utility:lock';
            selectedTemplate.permissionBtnDescr = this.label.Private_Permission_Description;

        } else if (permissionType == 'restricted') {
            selectedTemplate.permissionBtnIcon = 'utility:people';
            selectedTemplate.permissionBtnDescr = this.label.Restricted_Permission_Description;
        }
        this.selectedTemplate = { ...selectedTemplate };
        this.selectedPermission = permissionType;
    }

    handleToogleCustomization() {
        this.previewBody = !this.previewBody;
    }

    navigateToListView(listViewId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Campaign',
                actionName: 'list'
            },
            state: {
                filterName: listViewId
            }
        });
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

    openTemplatePermission(event) {

        this.showSpinner = true;
        let templateId = event.currentTarget.dataset.id;
        this.templateList.forEach((ele) => {
            if (ele.id == templateId) {
                this.selectedTemplate = { ...ele };
                this.selectedShareableUsers = JSON.parse(ele.users_list);
                this.selectedPermission = ele.permissionType;
            }
        });

        getSharableUsers()
            .then((result) => {
                if (result && result.status == 'success') {
                    let lstUser = JSON.parse(result.value);
                    let shareableUsersOptions = [];
                    lstUser.forEach(user => {
                        shareableUsersOptions.push({ label: user.Name, value: user.TelosTouchSF__TT_UserId__c });
                    });
                    this.shareableUsersOptions = shareableUsersOptions;

                } else if (result && result.status == 'error') {
                    console.error('getSharableUsers Error: ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch getSharableUsers Error: ', error);
            })
            .finally(() => {
                this.toogleTemplatePermission();
                this.showSpinner = false;
            });

    }

    prepareTemplateList() {

        let templateList = this.mapTemplates[this.listViewValue];

        if (this.libraryType.toLowerCase() === 'email') {
            templateList = this.filterBasedOnType(templateList);
        }
        templateList = this.filterTemplatesList(templateList);
        templateList = this.searchTemplateList(templateList);
        templateList = this.sortTemplatesList(templateList);

        this.templateList = templateList;

        this.currentPage = 1;
        this.prevPage = 1;
        this.nextPage = 2;
        this.totalPage = Math.ceil(this.templateList.length / this.recordSize);
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

    searchTemplateList(templateList) {

        let searchKey = this.searchInput.toLowerCase().trim();

        if (searchKey.length == 0) {
            return templateList;
        }

        let filteredTemplates = [];
        if (!this.fr) {
            templateList.forEach((ele) => {
                if (ele.name.toLowerCase().includes(searchKey)) {
                    filteredTemplates.push(ele);
                }
            });
        } else {
            templateList.forEach((ele) => {
                if (ele.name_fr.toLowerCase().includes(searchKey)) {
                    filteredTemplates.push(ele);
                }
            });
        }

        templateList = filteredTemplates;
        return templateList;
    }

    setTemplateBagdeColor(template) {
        let defaultCSS = 'slds-float_left slds-var-m-top_xx-small slds-var-m-left_xx-small';
        if (template.status.toLowerCase() == 'drafted') {
            template.statusLabel = this.label.Drafted_Label;
            template.statusDescription = this.label.Draft_Status_Description;
            template.statusCSS = 'slds-theme_warning ';
        } else if (template.status.toLowerCase() == 'published') {
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

    setTemplatePermission(template) {

        if (!template.is_private) {
            template.permissionBtnIcon = 'utility:world';
            template.permissionBtnDescr = this.label.Public_Permission_Description;
            template.permissionType = 'public';
        } else if (template.is_private && !template.users_list) {
            template.permissionBtnIcon = 'utility:lock';
            template.permissionBtnDescr = this.label.Private_Permission_Description;
            template.permissionType = 'private';
        } else if (template.is_private && template.users_list) {
            template.permissionBtnIcon = 'utility:people';
            template.permissionBtnDescr = this.label.Restricted_Permission_Description;
            template.permissionType = 'restricted';
        } else {
            template.permissionBtnIcon = 'utility:warning';
        }

        return template;

    }

    sortTemplatesList(templateList) {
        let list = templateList;
        let sortBy = this.selectedSort;
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
        return list;
    }

    toogleTemplatePermission() {
        this.showPermission = !this.showPermission;
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
        console.log('this.visibleRecords: ', JSON.parse(JSON.stringify(this.visibleRecords)));
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

    saveTemplatePermission() {

        this.showSpinner = true;
        if (this.libraryType.toLowerCase() == 'touchpoint') {
            this.updatePermissions(this.selectedTemplate.id, '');
        } else {
            this.updatePermissions('', this.selectedTemplate.id);
        }

    }
    updatePermissions(templateId, emailId) {

        let templateList = this.templateList
        let requestBody = {
            permission: this.selectedTemplate.permissionType,
            users_list: this.selectedShareableUsers
        }

        updateTemplatePermission({ templateId: templateId, requestBody: JSON.stringify(requestBody), libraryType: this.libraryType, emailTempId: emailId })
            .then((result) => {
                if (result && result.status == 'success') {

                    if (this.selectedTemplate.permissionType == 'restricted') {
                        this.selectedTemplate.users_list = JSON.stringify(this.selectedShareableUsers);
                    } else {
                        this.selectedTemplate.users_list = "[]";
                    }
                    for (let i = 0; i < this.templateList.length; i++) {
                        if (this.templateList[i].id == this.selectedTemplate.id) {
                            this.templateList[i] = this.selectedTemplate;
                            break;
                        }
                    }
                    this.mapTemplates[this.listViewValue] = templateList;
                    this.updateRecords();

                } else if (result && result.status == 'error') {
                    console.error('TelosTouch updateTemplatePermission Error .then:  ', result.error);
                }
            })
            .catch((error) => {
                console.error('TelosTouch updateTemplatePermission Error: ', error);
            })
            .finally(() => {
                this.toogleTemplatePermission();
                this.showSpinner = false;
            });
    }

}