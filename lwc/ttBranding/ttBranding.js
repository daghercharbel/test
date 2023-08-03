import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import getSignature from '@salesforce/apex/TTBrandingController.getSignature';
import putSignature from '@salesforce/apex/TTBrandingController.putSignature';

//Custom Labels
import create_french_signature from "@salesforce/label/c.Create_French_Signature";
import custom from "@salesforce/label/c.Custom_Dashboard_Text";
import email_signature from "@salesforce/label/c.Email_Signature";
import english from "@salesforce/label/c.English_Translation";
import french from "@salesforce/label/c.French_Translation";
import multi_language_support from "@salesforce/label/c.Multi_language_Support";
import select_signature_type from "@salesforce/label/c.Select_Signature_Type";
import system_generated from "@salesforce/label/c.System_Generated";

export default class TtUserBranding extends LightningElement {

    label = {
        create_french_signature,
        custom,
        email_signature,
        english,
        french,
        multi_language_support,
        select_signature_type,
        system_generated
    }

    lstTranslations = {
        en: english,
        fr: french
    }
    
    isLoading = true;
    lstLanguages = {};
    lstUserBranding = [];
    userBranding_en = {};
    @api recordId;
    signatureType = 'system';

    get signatureOptions() {
        return [
            { label: this.label.system_generated, value: 'system' },
            { label: this.label.custom, value: 'custom' },
        ];
    }

    connectedCallback() {
        getSignature({
            recordId: this.recordId
        })
            .then(result => {
                if (result.status == 'success') {
                    let response = JSON.parse(result.value);

                    if(response.length > 0){
                        for (let i = 0; i < response.length; i++) {
                            if (response[i].language == 'en') {
                                this.userBranding_en = response[i];
                                this.userBranding_en.full_language = this.lstTranslations.en
                                this.signatureType = response[i].type;
                            } else {
                                response[i].full_language = this.lstTranslations[response[i].language];
                                this.lstUserBranding.push(response[i]);
                                this.lstLanguages[response[i].language] = response[i].status;
                            }
                        }
                    } else {
                        let event = {detail : {value : 'system'}}
                        this.userBranding_en = {language: 'en'};
                        this.handleSignatureType(event);
                    }
                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }

            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.showToast('Error', error, 'error');
            })
            .finally(final => {
                this.isLoading = false;
            });
    }

    handleDataUpdate(event) {
        let language = event.detail.language;
        if (language == 'en') {
            this.userBranding_en = event.detail;
        } else {
            for (let i = 0; i < this.lstUserBranding.length; i++) {
                if (this.lstUserBranding[i].language == language) {
                    this.lstUserBranding[i] = event.detail;
                    this.lstUserBranding = [...this.lstUserBranding];
                }
            }
        }
    }

    handleMultiLanguage(event) {

        let language = event.target.name.replace("signature_", "");
        let languageFound = false;
        for (let i = 0; i < this.lstUserBranding.length; i++) {
            if (this.lstUserBranding[i].language == language) {
                languageFound = true;
                this.lstUserBranding[i].status = event.detail.checked;
            }
        }

        if(!languageFound){
            let userBrandingLang = {};
            userBrandingLang.status = event.detail.checked;
            userBrandingLang.language = language
            userBrandingLang.full_language = this.lstTranslations[language];
            userBrandingLang.type = this.signatureType;
            this.lstUserBranding.push(userBrandingLang);
        } 

        this.lstUserBranding = [...this.lstUserBranding];
        this.lstLanguages[language] = event.detail.checked;

    }

    handleSignatureType(event) {
        this.signatureType = event.detail.value;
        this.userBranding_en.type = event.detail.value;
        this.userBranding_en = { ...this.userBranding_en };
        for (let i = 0; i < this.lstUserBranding.length; i++) {
            this.lstUserBranding[i].type = event.detail.value;
            this.lstUserBranding[i] = { ...this.lstUserBranding[i] };

        }
    }

    saveSettings() {

        this.isLoading = true;

        let updateJson = {
            "type": this.userBranding_en.type,
            "french": this.lstLanguages.fr,
            "data": [this.userBranding_en, ...this.lstUserBranding]
        };

        putSignature({
            body: JSON.stringify(updateJson),
            recordId: this.recordId
        })
            .then(result => {
                if (result.status == 'success') {
                    this.showToast('', 'Signature update successfully', 'success');
                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            })
            .finally(final => {
                this.isLoading = false;
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