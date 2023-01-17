import { LightningElement, api } from 'lwc';
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

//Apex Class
import createAttachment from '@salesforce/apex/TTBrandingController.createAttachment';

//Custom Labels
import company_name from "@salesforce/label/c.Company_Name";
import email from "@salesforce/label/c.Email_Text";
import enable_meeting_link from "@salesforce/label/c.Enable_Meeting_Link";
import enable_signature_badge from "@salesforce/label/c.Enable_Signature_Badge";
import enable_social_link from "@salesforce/label/c.Enable_Social_Link";
import first_name from "@salesforce/label/c.First_Name";
import last_name from "@salesforce/label/c.Last_Name";
import meeting_link from "@salesforce/label/c.Meeting_Link";
import office_address from "@salesforce/label/c.Office_Address";
import phone_number from "@salesforce/label/c.Phone_Number";
import position from "@salesforce/label/c.Position";

export default class TtBrandingForm extends LightningElement {

    label = {
        company_name,
        email,
        enable_meeting_link,
        enable_signature_badge,
        enable_social_link,
        first_name,
        last_name,
        meeting_link,
        office_address,
        phone_number,
        position
    }

    badge = {};
    crop = {};
    cropper;
    isLoading = false;
    @api userBranding = {};
    telosTouchLoaded = false;

    get isCustom() {
        return this.userBranding.type == 'custom';
    }

    get isSystem() {
        return this.userBranding.type == 'system';
    }

    cancelCropper() {
        this.cropper.destroy();
        this.crop = {};
    }

    generateAttachment(base64data) {

        let attach = {
            "file": {
                "filename": this.crop.file.name,
                "size": this.crop.file.size,
                "type": this.crop.file.name,
                "data": base64data
            }
        };

        createAttachment({
            body: JSON.stringify(attach)
        })
            .then(result => {
                if (result.status == 'success') {

                    let response = JSON.parse(result.value);
                    let userBranding = { ...this.userBranding };
                    userBranding[this.crop.field] = response[0].url;
                    this.userBranding = userBranding;
                    this.crop = {};
                    this.handleChange();

                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            })
    }

    handleChange() {
        let changeEvent = new CustomEvent('infoupdated', {
            detail: this.userBranding
        });
        this.dispatchEvent(changeEvent);
    }

    handleCheckChange(event) {
        let userBranding = { ...this.userBranding };
        userBranding[event.target.name] = event.target.checked;
        this.userBranding = userBranding;
        this.handleChange();
    }

    handleFileChange(event) {
        this.crop = { loaded: true };
        let imageField = event.target.name;
        let aFile = event.detail.files[0];
        var reader = new FileReader();
        reader.onloadend = (() => {
            var base64data = reader.result;
            this.crop = { loaded: true, file: aFile, field: imageField, preview: base64data };
            this.loadImageCropper();
        });
        reader.readAsDataURL(aFile);
    }

    handleFileCrop() {

        let cropper = this.cropper;
        let that = this;
        cropper.result('base64').then(function (base64data) {
            that.generateAttachment(base64data);
        });
    }

    handleInputChange(event) {
        let userBranding = { ...this.userBranding };
        userBranding[event.target.name] = event.target.value;
        this.userBranding = userBranding;
        this.handleChange();
    }

    loadImageCropper() {
        var el = this.template.querySelector('.cropper-container');
        var cropper = new Croppie(el, {
            viewport: { width: 200, height: 133.333 },
            boundary: { width: '100%', height: "40vh" },
        });
        cropper.bind({
            url: this.crop.preview
        });
        this.cropper = cropper;
    }

    renderedCallback() {
        if (this.telosTouchLoaded) { return; }

        loadStyle(this, TelosTouch + '/croppieJs/croppie.css');
        loadScript(this, TelosTouch + '/croppieJs/croppie.js').then(() => {
            this.telosTouchLoaded = true;
        });

    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

}