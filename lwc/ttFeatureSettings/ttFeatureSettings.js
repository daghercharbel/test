import { LightningElement , track} from 'lwc';
import getTTFlagValue from '@salesforce/apex/TT_FeatureSettingsController.getTTFlagValue';
import getSFFlagValue from '@salesforce/apex/TT_FeatureSettingsController.getSFFlagValue';
import IsUserSystemAdmin from '@salesforce/apex/TT_FeatureSettingsController.IsUserSystemAdmin';
import createUpdateMetadata from '@salesforce/apex/TelosTouchUtility.createUpdateMetadata';
import getFinestLogValue from '@salesforce/apex/TT_FeatureSettingsController.getFinestLogValue';
import updateFinestLogging from '@salesforce/apex/TelosTouchUtility.updateFinestLogging';
import INVITE from '@salesforce/label/c.Invite';
import DETIALED_LOGGING from '@salesforce/label/c.Detialed_Logging';
import CLIENT_PORTAL_ENABLED from '@salesforce/label/c.Client_Portal_Enabled';
import CLIENT_PORTAL_DISABLED from '@salesforce/label/c.Client_Portal_Disabled';
import DETAILED_LOGGING_ENABLED from '@salesforce/label/c.Detailed_Logging_Enabled';
import DETAILED_LOGGING_DISABLED from '@salesforce/label/c.Detailed_Logging_Disabled';

export default class TtFeatureSettings extends LightningElement {
    @track isTTActive = false;
    @track inviteFlag = true;
    @track showToast = false;
    @track variant;
    @track msg;
    @track enableInvite = true;
    @track enableLogs = false;
    @track Profile = {};
    label = {
        INVITE,
        DETIALED_LOGGING,
        CLIENT_PORTAL_ENABLED,
        CLIENT_PORTAL_DISABLED,
        DETAILED_LOGGING_ENABLED,
        DETAILED_LOGGING_DISABLED
    };

    connectedCallback(){
        getTTFlagValue()
        .then(result => {
            this.isTTActive = result;
            if(result == false){
                this.inviteFlag = true;
            }else{
                this.inviteFlag = false;
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.isTTActive = false;
        })

        IsUserSystemAdmin()
		.then(result => {
            if(result == false){
                this.inviteFlag = true;
            }
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
		})

       
        getSFFlagValue()
		.then(result => {
            if(result == true){
			    this.enableInvite = true;
            }else{
                this.enableInvite = false;
            }
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
		})

        getFinestLogValue()
        .then(result => {
            if(result == false){
                this.enableLogs = false;
            }else{
                this.enableLogs = true;
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.isTTActive = false;
        })

    }

    displayToast (variant, msg) {
        this.variant = variant;
        this.msg = msg;
        this.showToast = true;
        setTimeout(() => { 
          this.showToast = false;
        }, 3000);
    }

    handleInviteToggle(event){        
        let isClientPortal = event.target.checked;
        createUpdateMetadata({ isTTActive: this.isTTActive, isSFActive: event.target.checked , MasterLabel: 'Invite'})
		.then(result => {
			this.error = undefined;
            if(isClientPortal){
                this.displayToast('success', this.label.CLIENT_PORTAL_ENABLED);
            }else{
                this.displayToast('success', this.label.CLIENT_PORTAL_DISABLED);
            }
		})
		.catch(error => {
			this.error = error;
            this.displayToast('error', this.error);
		})
    }
    handleLogsToggle(event){        
        let enableFinestLogs = event.target.checked;
        updateFinestLogging({ enableFinestLogs: enableFinestLogs, MasterLabel: 'Invite'})
		.then(result => {
			this.error = undefined;
            if(enableFinestLogs){
                this.displayToast('success', this.label.DETAILED_LOGGING_ENABLED);
            }else{
                this.displayToast('success', this.label.DETAILED_LOGGING_DISABLED);
            }
		})
		.catch(error => {
			this.error = error;
            this.displayToast('error', this.error);
		})
    }
    
    handleToastVisibilityChange () {
        this.showToast = false;
    }
}