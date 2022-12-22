import { LightningElement, track } from 'lwc';

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


export default class TtFeatureSettings extends LightningElement {

    label = {
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

    isLoading = true;
    featureMetadata = {};
    @track inviteFlag = true;
    @track msg;
    @track Profile = {};
    @track showToast = false;
    @track variant;

    connectedCallback() {

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

        getFeatureMetadata()
            .then(result => {
                if (result.status == 'success') {
                    let response = JSON.parse(result.value);
                    this.featureMetadata = response;
                } else {
                    console.error(result.error);
                    this.displayToast('error', result.error);
                }
            })
            .catch(error => {
                console.error(error);
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
        }, 3000);
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

    handleUpdate(event) {

        this.isLoading = true;
        let field = event.target.name;
        let value = event.target.checked;
        this.featureMetadata[field] = value;

        setFeatureMetadata({ stringMdt: JSON.stringify(this.featureMetadata) })
            .then(result => {
                switch (field) {
                    case 'TelosTouchSF__SF_Flag__c':
                        if (value) {
                            this.displayToast('success', this.label.CLIENT_PORTAL_ENABLED);
                        } else {
                            this.displayToast('success', this.label.CLIENT_PORTAL_DISABLED);
                        }
                        break;
                    case 'TelosTouchSF__ShowFinestLogs__c':
                        if (value) {
                            this.displayToast('success', this.label.DETAILED_LOGGING_ENABLED);
                        } else {
                            this.displayToast('success', this.label.DETAILED_LOGGING_DISABLED);
                        }
                        break;
                    case 'TelosTouchSF__ShowClientTagging__c':
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
                console.error(error);
                this.displayToast('error', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}