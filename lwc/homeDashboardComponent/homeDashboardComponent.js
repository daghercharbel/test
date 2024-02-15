import { LightningElement, track } from 'lwc';
import getSettingAPI from '@salesforce/apex/TelosTouchUtility.getSettingAPI';
import { labelLibrary } from 'c/ttLabels';
import LANG from '@salesforce/i18n/lang';

export default class HomeDashboardComponent extends LightningElement {
    label = labelLibrary;
    @track isShowSpinner = false;
    @track showIframe = false;
    @track isNotAuthenticate = false;
    lang = LANG;
    connectedCallback() {
        this.isShowSpinner = true;
        getSettingAPI({ isCallingFrom: 'TTDeshboard' })
            .then(result => {
                let storedResponse = result;
                if (storedResponse != null && storedResponse && storedResponse.adminCredentials.Instance_URL && storedResponse.authToken != undefined && storedResponse.authToken != null && storedResponse.authToken) {
                    this.isShowSpinner = false;
                    this.showIframe = true;
                } else {
                    this.isNotAuthenticate = true;
                    this.isShowSpinner = false;
                }
            })
            .catch(error => {
                console.log(error);
                this.isShowSpinner = false;
                this.isNotAuthenticate = true;
            })
    }
}