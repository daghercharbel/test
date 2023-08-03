import { LightningElement, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

//Apex Methods
import getFeatureMetadata from '@salesforce/apex/TT_FeatureSettingsController.getFeatureMetadata';
import IsUserSystemAdmin from '@salesforce/apex/TT_FeatureSettingsController.IsUserSystemAdmin';
import setFeatureMetadata from '@salesforce/apex/TT_FeatureSettingsController.setFeatureMetadata';

//Custom Labels
import add_remove_topic from '@salesforce/label/c.Add_Remove_Topic';
import CLIENT_PORTAL_DISABLED from '@salesforce/label/c.Client_Portal_Disabled';
import CLIENT_PORTAL_ENABLED from '@salesforce/label/c.Client_Portal_Enabled';
import DETIALED_LOGGING from '@salesforce/label/c.Detialed_Logging';
import DETAILED_LOGGING_DISABLED from '@salesforce/label/c.Detailed_Logging_Disabled';
import DETAILED_LOGGING_ENABLED from '@salesforce/label/c.Detailed_Logging_Enabled';
import INVITE from '@salesforce/label/c.Invite';
import more_information from '@salesforce/label/c.More_Information';
import topic_warning from '@salesforce/label/c.Topic_Warning';
import Save_Button_Label from '@salesforce/label/c.Save_Button_Label';
import Contact_Syncing_Label from '@salesforce/label/c.Contact_Syncing_Label';
import In_Min_Label from '@salesforce/label/c.In_Min_Label';
import Greater_than_Cool_Down from '@salesforce/label/c.Greater_than_Cool_Down';
import Less_than_Cool_Down from '@salesforce/label/c.Less_than_Cool_Down';
import Lead_Syncing_Label from '@salesforce/label/c.Lead_Syncing_Label';
import Campaign_Syncing_Label from '@salesforce/label/c.Campaign_Syncing_Label';
import Contact_Syncing_enabled from '@salesforce/label/c.Contact_Syncing_enabled';
import Contact_Syncing_disabled from '@salesforce/label/c.Contact_Syncing_disabled';
import Updated_Contact_Cool_Down from '@salesforce/label/c.Updated_Contact_Cool_Down';
import Updated_Lead_Cool_Down from '@salesforce/label/c.Updated_Lead_Cool_Down';
import Lead_Syncing_disabled from '@salesforce/label/c.Lead_Syncing_disabled';
import Lead_Syncing_enabled from '@salesforce/label/c.Lead_Syncing_enabled';
import Updated_Campaign_Cool_Down from '@salesforce/label/c.Updated_Campaign_Cool_Down';
import Campaign_Syncing_disabled from '@salesforce/label/c.Campaign_Syncing_disabled';
import Campaign_Syncing_enabled from '@salesforce/label/c.Campaign_Syncing_enabled';


export default class TtFeatureSettings extends LightningElement {

    label = {
        Campaign_Syncing_enabled,
        Campaign_Syncing_disabled,
        Updated_Campaign_Cool_Down,
        Lead_Syncing_enabled,
        Lead_Syncing_disabled,
        Updated_Lead_Cool_Down,
        Updated_Contact_Cool_Down,
        Contact_Syncing_disabled,
        Contact_Syncing_enabled,
        Campaign_Syncing_Label,
        Lead_Syncing_Label,
        Greater_than_Cool_Down,
        Less_than_Cool_Down,
        In_Min_Label,
        Save_Button_Label,
        Contact_Syncing_Label,
        add_remove_topic,
        CLIENT_PORTAL_DISABLED,
        CLIENT_PORTAL_ENABLED,
        DETIALED_LOGGING,
        DETAILED_LOGGING_DISABLED,
        DETAILED_LOGGING_ENABLED,
        INVITE,
        more_information,
        topic_warning
    };

    @track isLoading = true;
    @track featureMetadata = {};
    @track showMainDiv = false;
    @track coolDownLead = false;
    @track coolDownContact = false;
    @track coolDownCampaign = false;
    @track showContactMessage = false;
    @track showLeadMessage = false;
    @track showCampaignMessage = false;
    @track inviteFlag = true;
    @track msg;
    @track Profile = {};
    @track showToast = false;
    @track variant;
    @track showCampaignSave = false;
    @track showLeadSave = false;
    @track showContactSave = false;
    campaignCooldownValue = 0; 
    leadCooldownValue = 0; 
    contactCooldownValue = 0; 
    showCampaignMaxTime = false;
    showLeadMaxTime = false;
    showContactMaxTime = false;
    // @track isSmallDevice = false;
    @track isTablet = false;
    @track isPhone = false;

    connectedCallback() {
        if (FORM_FACTOR === 'Medium' || FORM_FACTOR === 'Small') {
            this.isSmallDevice = true;
        }
        if (FORM_FACTOR === 'Medium') {
            this.isTablet = true;
        }
        if (FORM_FACTOR === 'Small') {
            this.isPhone = true;
        }
        IsUserSystemAdmin()
            .then(result => {
                if (result == false) {
                    this.inviteFlag = true;
                }
            })
            .catch(error => {
                console.error(error);
                this.displayToast('error', error);
            })
            this.getFeatureMetadataMethod('Contact_Syncing','');
            this.getFeatureMetadataMethod('Finest_Logging','');
            this.getFeatureMetadataMethod('Client_Tagging','');
            this.getFeatureMetadataMethod('Camapign_Syncing','');
            this.getFeatureMetadataMethod('Lead_Syncing','');
    }

    getFeatureMetadataMethod(recName, calledFrom){
        getFeatureMetadata({recName: recName})
        .then(result => {
            if (result.status == 'success') {
                let response = JSON.parse(result.value);
                response['TelosTouchSF__Additional_Parameter__c'] = response.TelosTouchSF__Additional_Parameter__c ? response.TelosTouchSF__Additional_Parameter__c : 0;
                 if(recName == 'Finest_Logging'){
                    this.featureMetadata['Finest_Logging'] = response;

                }else if(recName == 'Client_Tagging'){
                    this.featureMetadata['Client_Tagging'] = response;

                }else if(recName == 'Lead_Syncing'){
                    this.featureMetadata['Lead_Syncing'] = response;
                    this.leadCooldownValue = this.featureMetadata.Lead_Syncing.TelosTouchSF__Additional_Parameter__c;
                    this.coolDownLead = !this.featureMetadata.Lead_Syncing.TelosTouchSF__SF_Flag__c;
                }else if(recName == 'Contact_Syncing'){
                    this.featureMetadata['Contact_Syncing'] = response;
                    this.contactCooldownValue = this.featureMetadata.Contact_Syncing.TelosTouchSF__Additional_Parameter__c;
                    this.coolDownContact = !this.featureMetadata.Contact_Syncing.TelosTouchSF__SF_Flag__c;
                    this.showContactMessage = this.featureMetadata.Contact_Syncing.TelosTouchSF__Additional_Parameter__c >=2 ? false : true;
                }else if(recName == 'Camapign_Syncing'){
                    this.featureMetadata['Camapign_Syncing'] = response;
                    this.campaignCooldownValue = this.featureMetadata.Camapign_Syncing.TelosTouchSF__Additional_Parameter__c;
                    this.coolDownCampaign = !this.featureMetadata.Camapign_Syncing.TelosTouchSF__SF_Flag__c;
                    this.showCampaignMessage = this.featureMetadata.Camapign_Syncing.TelosTouchSF__Additional_Parameter__c >=2 ? false : true;
                }
                this.showMainDiv = true; 
            } else {
                this.showMainDiv = true;
                this.displayToast('error', result.error);
            }
        })
        .catch(error => {
            this.showMainDiv = true;
            this.displayToast('error', error);
        })
        .finally(() => {
            this.isLoading = false;
        });

    }

    displayToast(variant, msg) {
        this.variant = variant;
        this.msg = msg;
        this.showToast = true;
        setTimeout(() => {
            this.showToast = false;
        }, 2000);
    }

    callRedirect(event) {

        let name = event.target.name;
        const redirectEvt = new CustomEvent('redirectEvent', {
            detail: { value: name },
        });

        this.dispatchEvent(redirectEvt);
    }

    handleToastVisibilityChange() {
        this.showToast = false;
    }
    handleAdditionalParam(event){
        if(event.target.dataset.id == 'campaignSyncing'){
            this.showCampaignMessage = parseInt(event.target.value) >= 2  ? false : true;
            this.showCampaignMaxTime = parseInt(event.target.value) > 59 && parseInt(event.target.value) <= 2 ? true : false;
            this.showCampaignSave = !this.showCampaignMessage && !this.showCampaignMaxTime && parseInt(event.target.value) !== parseInt(this.featureMetadata.Camapign_Syncing.TelosTouchSF__Additional_Parameter__c) ? true : false;
            this.campaignCooldownValue = event.target.value;
        }else if(event.target.dataset.id == 'leadSyncing'){
            this.showLeadMessage = parseInt(event.target.value) >=2 && parseInt(event.target.value) <= 60 ? false : true;
            this.showLeadMaxTime = parseInt(event.target.value) > 59 && parseInt(event.target.value) <= 2 ? true : false;
            this.showLeadSave = !this.showLeadMessage && !this.showLeadMaxTime && parseInt(event.target.value) != parseInt(this.featureMetadata.Lead_Syncing.TelosTouchSF__Additional_Parameter__c) ? true : false;
            this.leadCooldownValue = event.target.value;
        }else if(event.target.dataset.id == 'contactSyncing'){
            this.showContactMessage = parseInt(event.target.value) >=2  ? false : true;
            this.showContactMaxTime = parseInt(event.target.value) > 59 ? true : false;

            this.showContactSave = !this.showContactMessage && !this.showContactMaxTime && parseInt(event.target.value) != parseInt(this.featureMetadata.Contact_Syncing.TelosTouchSF__Additional_Parameter__c) ? true : false;
            this.contactCooldownValue = event.target.value;
        }
    }

    handleSaveCooldown(event){
        let recName = '';
        let mdtValue = {};
        if(event.target.dataset.id == 'campaignSyncing'){
            recName = 'Camapign_Syncing';
            mdtValue.TelosTouchSF__Additional_Parameter__c = this.campaignCooldownValue;
            mdtValue.TelosTouchSF__SF_Flag__c = this.featureMetadata.Camapign_Syncing.TelosTouchSF__SF_Flag__c;
            this.showCampaignSave = false;
        }else if(event.target.dataset.id == 'leadSyncing'){
            recName = 'Lead_Syncing';
            mdtValue.TelosTouchSF__Additional_Parameter__c = this.leadCooldownValue;
            mdtValue.TelosTouchSF__SF_Flag__c = this.featureMetadata.Lead_Syncing.TelosTouchSF__SF_Flag__c;
            this.showLeadSave = false;
        }else if(event.target.dataset.id == 'contactSyncing'){
            recName = 'Contact_Syncing';
            mdtValue.TelosTouchSF__Additional_Parameter__c = this.contactCooldownValue;
            mdtValue.TelosTouchSF__SF_Flag__c = this.featureMetadata.Contact_Syncing.TelosTouchSF__SF_Flag__c;
            this.showContactSave = false;
        }
        this.isLoading = true;
        this.updateMetadata(mdtValue, recName, true, 'additionalParameter');
    }
    handleUpdate(event) {

        this.isLoading = true;
        let field = event.target.name;
        let value = event.target.checked;
        let storeMdtValue = {};
        storeMdtValue.TelosTouchSF__SF_Flag__c = value;
        if(field == 'Lead_Syncing'){
            storeMdtValue.TelosTouchSF__Additional_Parameter__c = this.featureMetadata.Lead_Syncing.TelosTouchSF__Additional_Parameter__c;
            this.coolDownLead = !value;
        }else if(field == 'Camapign_Syncing'){
            storeMdtValue.TelosTouchSF__Additional_Parameter__c = this.featureMetadata.Camapign_Syncing.TelosTouchSF__Additional_Parameter__c;
            this.coolDownCampaign = !value;
        }else if(field == 'Contact_Syncing'){
            storeMdtValue.TelosTouchSF__Additional_Parameter__c = this.featureMetadata.Contact_Syncing.TelosTouchSF__Additional_Parameter__c;
            this.coolDownContact = !value;
        }
        this.updateMetadata(storeMdtValue, field, value, 'checkboxUpdate');
    }

    updateMetadata(storeMdtValue, field, value, calledFrom){
        setFeatureMetadata({ stringMdt: JSON.stringify(storeMdtValue), recName: field })
        .then(result => {
            switch (field) {
                case 'Finest_Logging':
                    if (value) {
                        this.displayToast('success', this.label.DETAILED_LOGGING_ENABLED);
                    } else {
                        this.displayToast('success', this.label.DETAILED_LOGGING_DISABLED);
                    }
                    break;
                case 'Lead_Syncing':
                    if(calledFrom == 'checkboxUpdate'){
                        if (value) {
                            this.displayToast('success', this.label.Lead_Syncing_enabled);
                        } else {
                            this.displayToast('success', this.label.Lead_Syncing_disabled);
                        }
                    }else{
                        this.displayToast('success', this.label.Updated_Lead_Cool_Down);
                    }
                    break;
                case 'Camapign_Syncing':
                    if(calledFrom == 'checkboxUpdate'){
                        if (value) {
                            this.displayToast('success', this.label.Campaign_Syncing_enabled);
                        } else {
                            this.displayToast('success', this.label.Campaign_Syncing_disabled);
                        }
                    }else{
                        this.displayToast('success', this.label.Updated_Campaign_Cool_Down);
                    }
                    break;
                case 'Contact_Syncing':
                    if(calledFrom == 'checkboxUpdate'){
                        if (value) {
                            this.displayToast('success', this.label.Contact_Syncing_enabled);
                        } else {
                            this.displayToast('success', this.label.Contact_Syncing_disabled);
                        }
                    }else{
                        this.displayToast('success', this.label.Updated_Contact_Cool_Down);
                    }
                    break;
                    // we are not using client tagging functionality now
                case 'Client_Tagging':
                    if (value) {
                        this.displayToast('success', 'Client Tagging enabled');
                    } else {
                        this.displayToast('success', 'Client Tagging disabled');            
                    }
                    break;
                default:
                    break;
            }
        })
        .catch(error => {
            this.displayToast('error', error);
        })
        .finally(() => {
            this.getFeatureMetadataMethod(field, calledFrom);
        });
        
    }
}