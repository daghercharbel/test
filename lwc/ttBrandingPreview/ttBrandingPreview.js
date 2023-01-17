import { LightningElement, api } from 'lwc';

//Static Resources
import telosTouch from '@salesforce/resourceUrl/TelosTouch';

//Custom Label
import company_name from "@salesforce/label/c.Company_Name";
import email from "@salesforce/label/c.Email_Text";
import first_name from "@salesforce/label/c.first_name";
import last_name from "@salesforce/label/c.last_name";
import meeting_link_preview from "@salesforce/label/c.Meeting_Link_Preview";
import office_address from "@salesforce/label/c.Office_Address";
import phone_number from "@salesforce/label/c.Phone_Number";
import position from "@salesforce/label/c.Position";
import schedule_a_meeting from "@salesforce/label/c.Schedule_a_Meeting";
import unsubscribe_text from "@salesforce/label/c.Email_Signature_Unsubscribe_Text";


export default class TtBrandingPreview extends LightningElement {

    label = {
        company_name,
        email,
        first_name,
        last_name,
        meeting_link_preview,
        office_address,
        phone_number,
        position,
        schedule_a_meeting,
        unsubscribe_text
    }

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