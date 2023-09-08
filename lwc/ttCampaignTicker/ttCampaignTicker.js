import { LightningElement, api, wire } from 'lwc';
import { handleRequest } from 'c/ttCallout';
import { labelLibrary } from 'c/ttLabels';
import { subscribe } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import LOCALE from '@salesforce/i18n/locale';

//Apex Methods
import getCalloutInfo from '@salesforce/apex/TelosTouchUtility.getCalloutInfo';
import AddMissingClient from '@salesforce/apex/TTCampaignTickerController.AddMissingClient';
import getCampaignData from '@salesforce/apex/TTCampaignTickerController.getCampaignData';
import getCustomizeUrl from '@salesforce/apex/TTCampaignTickerController.getCustomizeUrl';
import removeExtraClient from '@salesforce/apex/TTCampaignTickerController.removeExtraClient';
import updateSentInsight from '@salesforce/apex/TTCampaignTickerController.updateSentInsight';

//Campaign Fields
import CAMP_ID_FIELD from '@salesforce/schema/Campaign.Id';
import CAMP_QUESTION_FIELD from '@salesforce/schema/Campaign.Questions__c';
import CAMP_TT_ID from '@salesforce/schema/Campaign.TT_Campaign_Id__c';
import CAMP_TOUCHPOINT_ID from '@salesforce/schema/Campaign.TouchPoint_Template_Id__c';
import CAMP_EMAIL_ID from '@salesforce/schema/Campaign.Email_Template_Id__c';

//User Fields
import USER_ID_FIELD from '@salesforce/user/Id';

export default class TtCampaignTicker extends LightningElement {

    campaignDataSF = {};
    campaignDataTT = {};
    campInfo = {};
    cardLabel = ' ';
    customizeUrl;
    enableEditing = true;
    hasTemplateError = false;
    hasMembersNotSent = false;
    isLoading = false;
    label = labelLibrary;
    showEdit = false;
    showGallery = false;
    showSendTest = false;
    showSendTestButton = false;
    @api recordId;
    status = {};
    selectedTemplate = {};

    @wire(getRecord, { recordId: USER_ID_FIELD, fields: ['User.TelosTouchSF__TT_UserId__c'] })
    userData;

    get isTouchpointType() {
        return (this.campaignDataSF.TelosTouchSF__Type__c == 'touchpoint');
    }

    get showSendButton() {
        return (this.showSendTestButton && this.hasMembersNotSent && !this.hasTemplateError);
    }

    addClient() {
        AddMissingClient({ campId: this.recordId })
            .then(result => {
                if (result.status == 'success') {
                    this.sendCampaign();
                } else {
                    console.error('ttCampaignTicker 1: ', result.error);
                }
            })
            .catch(error => {
                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 2: ', errorStr);
            })
    }

    closeSendTest() {
        this.showSendTest = false;
    }

    closeTemplateEdit() {
        this.selectedTemplate = {};
        this.showEdit = false;
        this.getCampaignData();
    }

    closeTemplateGallery() {
        this.selectedTemplate = {};
        this.showGallery = false;
    }

    connectedCallback() {

        this.subscribePlatformEvents();
        this.getCampaignData();

    }

    createTTCampId() {

        let method = 'POST';
        let endpoint = '/api/v2/campaign2/create';
        let body = {
            'name': this.campaignDataSF.Name,
            'type': this.campaignDataSF.TelosTouchSF__Type__c,
            'delivery': 'email',
            'recipients': [],
            'all_recipients': false,
            'where': {}
        };
        let invoker = {
            'className': 'ttCampaignTicker',
            'classMethod': 'createTTCampId',
            'recordId': this.recordId
        };
        
        handleRequest(method, endpoint, JSON.stringify(body), invoker)
            .then(result => {
                if (result.status) {

                    let response = result.body;
                    this.campaignDataSF.TelosTouchSF__TT_Campaign_Id__c = response.id;

                    const fields = {};
                    fields[CAMP_ID_FIELD.fieldApiName] = this.recordId;
                    fields[CAMP_TT_ID.fieldApiName] = response.id;

                    const campRecord = { fields };
                    this.updateCampaign(campRecord);
                    this.getTTCampaignData();

                } else {
                    console.error('ttCampaignTicker 3: ', result.status_code + ': ' + result.body);
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
                console.error('ttCampaignTicker 4: ', errorStr);
                this.isLoading = false;
            })
    }

    getCampaignData() {
        this.isLoading = true;

        getCampaignData({ campId: this.recordId })
            .then(result => {
                if (result.status == 'success') {

                    let response = JSON.parse(result.value);
                    this.campaignDataSF = response;

                    //CREATE TT CAMPAIGN ID
                    if (response.TelosTouchSF__TT_Campaign_Id__c == null) {
                        this.createTTCampId();
                    } else {
                        this.getTTCampaignData();
                    }

                    //COUNT CAMPAIGN MEMBERS
                    if (response.TelosTouchSF__Insights__r) {
                        this.campInfo.membersCount = response.TelosTouchSF__Insights__r.totalSize;
                    } else {
                        this.campInfo.membersCount = 0;
                    }

                    //FORMAT CREATED DATE
                    let createdDate = Date.parse(response.CreatedDate);
                    let formattedDate = new Intl.DateTimeFormat(LOCALE, { day: 'numeric', month: 'short', year: 'numeric' }).format(createdDate);
                    this.campInfo.createdDate = formattedDate;

                    //CHECK IF CAMPAIGN IS SENT
                    if (response.TelosTouchSF__Questions__c) {
                        this.enableEditing = false;
                    }

                    //CHECKING MEMBERS NOT SENT
                    let hasMembersNotSent = false;
                    if (response.TelosTouchSF__Insights__r) {
                        response.TelosTouchSF__Insights__r.records.forEach(insight => {
                            if (insight.TelosTouchSF__Sent_Status__c == 'initial') {
                                hasMembersNotSent = true;
                            }
                        });
                    }
                    this.hasMembersNotSent = hasMembersNotSent;

                    this.setLabels();

                } else {
                    console.error('ttCampaignTicker 5: ', result.error);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 6: ', errorStr);
                this.isLoading = false;
            })
            .finally(final => {
            });
    }

    getCustomizeUrl() {

        let templateId;
        if (this.selectedTemplate.type == 'touchpoint') {
            templateId = this.campaignDataTT.touchpoint_graph.id;
        } else {
            this.campaignDataTT.emails.forEach(email => {
                if (email.link_language == this.selectedTemplate.lang) { templateId = email.id; }
            });
        }

        getCustomizeUrl({
            templateType: this.selectedTemplate.type,
            campTTId: this.campaignDataSF.TelosTouchSF__TT_Campaign_Id__c,
            templateId: templateId
        })
            .then(result => {
                if (result.status == 'success') {

                    this.customizeUrl = result.value;

                } else {
                    console.error('ttCampaignTicker 7: ', result.error);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 8: ', errorStr);
            })
            .finally(final => {
                this.isLoading = false;
            });
    }

    getTTCampaignData() {

        let method = 'GET';
        let endpoint = '/api/v2/campaign2/details?id=' + this.campaignDataSF.TelosTouchSF__TT_Campaign_Id__c + '&language=en_US';
        let body = null;
        let invoker = {
            'className': 'ttCampaignTicker',
            'classMethod': 'getTTCampaignData',
            'recordId': this.recordId
        };

        handleRequest(method, endpoint, body, invoker)
            .then(result => {
                if (result.status) {

                    let response = result.body;
                    let campInfo = this.campInfo;
                    let hasTemplateError = false;
                    let campaignNeedsUpdate = false;
                    const fields = {};
                    this.campaignDataTT = response;

                    if (response.touchpoint) {

                        campInfo.touchpoint = {
                            'name': response.touchpoint.name,
                            'id': response.touchpoint_graph.id
                        }
                        campInfo.touchpointName = response.touchpoint.name;

                        if (response.touchpoint_graph.id != this.campaignDataSF.TelosTouchSF__TouchPoint_Template_Id__c) {
                            campaignNeedsUpdate = true;
                            fields[CAMP_TOUCHPOINT_ID.fieldApiName] = response.touchpoint_graph.id;
                            fields[CAMP_EMAIL_ID.fieldApiName] = '{}';
                            this.campaignDataSF.TelosTouchSF__Email_Template_Id__c = '{}';
                        }

                        if (response.touchpoint_graph && response.touchpoint_graph.content
                            && response.touchpoint_graph.content.languages) {
                            campInfo.emails = [];
                            response.touchpoint_graph.content.languages.forEach(language => {
                                campInfo.emails.push({ 'lang': language.code });
                            });
                        }

                        if (response.touchpoint_graph && response.touchpoint_graph.deleted) {
                            campInfo.touchpoint.warning = this.label.Deleted_Template_Warning;
                            campInfo.touchpoint.warningVariant = 'error';
                            hasTemplateError = true;
                        } else if (response.touchpoint_graph && response.touchpoint_graph.status == 'DRAFTED') {
                            campInfo.touchpoint.warning = this.label.Drafted_Template_Warning;
                            campInfo.touchpoint.warningVariant = 'error';
                            hasTemplateError = true;
                        }

                    } else if (this.campaignDataSF.TelosTouchSF__Type__c == 'email') {
                        campInfo.emails = [];
                        campInfo.emails.push({ 'lang': 'en_US' });
                        campInfo.emails.push({ 'lang': 'fr_FR' });
                    }

                    if (response.emails && response.emails.length > 0) {

                        this.showSendTestButton = true;
                        let mapEmails = {};

                        response.emails.forEach(email => {
                            mapEmails[email.language] = email.id;
                            campInfo.emails.forEach(campEmail => {
                                if (campEmail.lang == email.link_language) {
                                    campEmail.name = email.name;
                                    campEmail.id = email.id;
                                    if (email.link_language != email.language) {
                                        if (email.language == 'en_US') {
                                            campEmail.warning = this.label.Mismatch_Email_Language_en_US;
                                            campEmail.warningVariant = 'warning';
                                        } else if (email.language == 'fr_FR') {
                                            campEmail.warning = this.label.Mismatch_Email_Language_fr_FR;
                                            campEmail.warningVariant = 'warning';
                                        }
                                    }

                                    if (email.deleted) {
                                        campEmail.warning = this.label.Deleted_Template_Warning;
                                        campEmail.warningVariant = 'error';
                                        hasTemplateError = true;
                                    } else if (email.status == 'DRAFTED') {
                                        campEmail.warning = this.label.Drafted_Template_Warning;
                                        campEmail.warningVariant = 'error';
                                        hasTemplateError = true;
                                    }

                                }
                            });
                        });

                        if (this.campaignDataSF.TelosTouchSF__Email_Template_Id__c != JSON.stringify(mapEmails)) {
                            campaignNeedsUpdate = true;
                            fields[CAMP_EMAIL_ID.fieldApiName] = JSON.stringify(mapEmails);
                            this.campaignDataSF.TelosTouchSF__Email_Template_Id__c = JSON.stringify(mapEmails);
                        }

                    } else {
                        this.showSendTestButton = false;
                    }

                    if (campaignNeedsUpdate) {
                        fields[CAMP_ID_FIELD.fieldApiName] = this.recordId;
                        const campRecord = { fields };
                        this.updateCampaign(campRecord);
                    }

                    if (campInfo.emails) {
                        campInfo.emails.forEach(email => {
                            if (email.lang == 'en_US') email.langLabel = this.label.English_Translation;
                            if (email.lang == 'fr_FR') email.langLabel = this.label.French_Translation;
                        });
                    }
                    this.hasTemplateError = hasTemplateError;
                    this.campInfo = { ...campInfo };

                } else {
                    console.error('ttCampaignTicker 9: ', result.status_code + ': ' + result.body);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 10: ', errorStr);
            })
            .finally(final => {
                this.isLoading = false;
            });
    }

    handleClickSend() {

        let SFClientsCount = this.campaignDataSF.TelosTouchSF__Insights__r.totalSize;
        let TTClientsCount = this.campaignDataTT.chart.recipientsCount;

        if (SFClientsCount < TTClientsCount) {
            this.removeClient();
        } else if (SFClientsCount > TTClientsCount) {
            this.addClient();
        } else {
            this.sendCampaign();
        }

    }

    openSendTest() {
        this.showSendTest = true;
    }

    openTemplateEdit(event) {

        let language = 'en_US';
        if (event.target.dataset.lang) {
            language = event.target.dataset.lang;
        }
        let selectedTemplate = {
            'id': event.target.dataset.id,
            'lang': language,
            'type': event.target.dataset.type
        }
        this.selectedTemplate = selectedTemplate;
        this.showEdit = true;

    }

    openTemplateGallery(event) {

        let language = 'en_US';
        if (event.target.dataset.lang) {
            language = event.target.dataset.lang;
        }
        let selectedTemplate = {
            'id': event.target.dataset.id,
            'lang': language,
            'type': event.target.dataset.type
        }
        this.selectedTemplate = selectedTemplate;
        this.showGallery = true;

    }

    removeClient() {

        removeExtraClient({ campId: this.recordId })
            .then(result => {
                if (result.status == 'success') {
                    this.sendCampaign();
                } else {
                    console.error('ttCampaignTicker 11: ', result.error);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 12: ', errorStr);
            })

    }

    sendCampaign() {
        this.isLoading = true;

        let method = 'POST';
        let endpoint;
        if (this.campaignDataSF.TelosTouchSF__Type__c == 'email') {
            endpoint = '/api/v2/campaign/' + this.campaignDataSF.TelosTouchSF__TT_Campaign_Id__c + '/email/send';
        } else {
            endpoint = '/api/v2/campaign/' + this.campaignDataSF.TelosTouchSF__TT_Campaign_Id__c + '/tp/send';
        }
        let body = null;
        let invoker = {
            'className': 'ttCampaignTicker',
            'classMethod': 'sendCampaign',
            'recordId': this.recordId
        };

        handleRequest(method, endpoint, body, invoker)
            .then(result => {
                if (result.status) {

                    let questions = '';
                    if (!this.campaignDataSF.TelosTouchSF__Questions__c) {
                        questions = JSON.stringify(this.campaignDataTT.campaign.questions);

                        const fields = {};
                        fields[CAMP_ID_FIELD.fieldApiName] = this.recordId;
                        fields[CAMP_QUESTION_FIELD.fieldApiName] = questions;

                        const campRecord = { fields };
                        this.updateCampaign(campRecord);
                    }
                    this.updateInsights();

                    let isEmail = (this.campaignDataSF.TelosTouchSF__Type__c == 'email')
                    let message = (isEmail) ? this.label.Email_Background : this.label.Recipient_Background;
                    this.showToast('Success', message, 'success');

                } else {
                    console.error('ttCampaignTicker 13: ', result.status_code + ': ' + result.body);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 14: ', errorStr);
                this.showToast('Failure', 'Failed to Send Touchpoint', 'error');
            })
            .finally(final => {
                this.isLoading = false;
            });
    }

    setLabels() {

        let camp = this.campaignDataSF;
        let isEmail = (camp.TelosTouchSF__Type__c == 'email')

        //SETTING TITLE
        if (isEmail) {
            this.cardLabel = this.label.TT_Email_Status;
        } else {
            this.cardLabel = this.label.TT_Touchpoint_Status_Text;
        }

        //SETTING MESSAGE
        if (camp.TelosTouchSF__TouchPoint_Template_Id__c == null) {
            this.status.css = 'slds-text-color_error';
            this.status.message = (isEmail) ? this.label.Start_By_Choosing_Email : this.label.StartByChoosingTP;
        } else if (!camp.TelosTouchSF__Insights__r) {
            this.status.css = 'slds-text-color_error';
            this.status.message = (isEmail) ? this.label.Customize_AddClient : this.label.Customize_AddClientText;
        } else if (this.hasMembersNotSent) {
            this.status.css = 'slds-text-color_error';
            this.status.message = (isEmail) ? this.label.Customize_Preview_Email_Label : this.label.Customize_PreviewLabel;
        } else {
            this.status.css = 'slds-text-color_success';
            this.status.message = (isEmail) ? this.label.Email_Sent : this.label.TPSentText;
        }

        if (camp.TelosTouchSF__TT_Campaign_Id__c) {

        }

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    subscribePlatformEvents() {

        let channelName = '/event/TelosTouchSF__Insight_Creation_Event__e';

        const messageCallback = function (response) {
            if (this.recordId == response.data.payload.TelosTouchSF__Campaign__c) {
                this.getCampaignData();
            }
        };

        subscribe(channelName, -1, messageCallback.bind(this)).then((response) => { });

    }

    updateCampaign(recordInput) {
        updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => {
                ;

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 15: ', errorStr);
                this.showToast('Failure', error.body.message, 'error');
            });
    }

    updateInsights() {

        updateSentInsight({ campId: this.recordId })
            .then(result => {
                if (result.status != 'success') {
                    console.error('ttCampaignTicker 16: ', result.error);
                }
            })
            .catch(error => {

                let errorStr;
                if (typeof error == 'object' && error.message) {
                    errorStr = error.message
                } else {
                    errorStr = error;
                }
                console.error('ttCampaignTicker 17: ', errorStr);
                this.isLoading = false;
            })
            .finally(final => {
            });
    }

}