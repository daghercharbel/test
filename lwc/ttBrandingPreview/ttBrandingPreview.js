import { LightningElement, api } from 'lwc';

//Static Resources
import telosTouch from '@salesforce/resourceUrl/TelosTouch';
import { labelLibrary } from 'c/ttLabels';

export default class TtBrandingPreview extends LightningElement {

    label = labelLibrary;
    blankFieldsChecked = false;
    @api userBranding = {};
    facebookPng = telosTouch + "/images/facebook.png"
    linkedinPng = telosTouch + "/images/linkedin.png"
    twitterPng = telosTouch + "/images/twitter.png"

    get isCustom() {
        return this.userBranding.type == 'custom';
    }

    get isSystem() {
        return this.userBranding.type == 'system';
    }

    renderedCallback() {

        this.blankFieldsChecked = !this.blankFieldsChecked;

        if (this.blankFieldsChecked) {
            let userBranding = { ...this.userBranding }

            if (!userBranding.first_name) userBranding.first_name = "{" + this.label.first_name + "}";
            if (!userBranding.last_name) userBranding.last_name = "{" + this.label.last_name + "}";
            if (!userBranding.position) userBranding.position = "{" + this.label.position + "}";
            if (!userBranding.company) userBranding.company = "{" + this.label.company_name + "}";
            if (!userBranding.phone) userBranding.phone = "{" + this.label.phone_number + "}";
            if (!userBranding.email) userBranding.email = "{" + this.label.email + "}";
            if (!userBranding.address) userBranding.address = "{" + this.label.office_address + "}";

            this.userBranding = userBranding;
        }

    }

}