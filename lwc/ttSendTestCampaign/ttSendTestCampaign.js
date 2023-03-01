import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import sendTestTemplate from '@salesforce/apex/SendTestCampaignController.sendTestTemplate';

// Custom Labels
import Cancel_Button_Label from "@salesforce/label/c.Cancel_Button_Label";
import Send_Test_Message from "@salesforce/label/c.Send_Test_Message";
import Send_Test_Title from "@salesforce/label/c.Send_Test_Title";
import Send_Text from "@salesforce/label/c.Send_Text";
import Test_Template_Success from "@salesforce/label/c.Test_Template_Success";

export default class SendTestCampaign extends LightningElement {

    label = {
        Cancel_Button_Label,
        Send_Test_Message,
        Send_Test_Title,
        Send_Text,
        Test_Template_Success
    };

    email;
    lstEmail = [];
    lstEmailDraft = [];
    @api campaignId;

    get hasNoEmails() {
        return !(this.lstEmail.length > 0);
    }

    closeModal() {
        const closeModalEvent = new CustomEvent('closemodalevent', {
        });
        this.dispatchEvent(closeModalEvent);
    }

    fireTestSending() {

        let lstEmail = this.lstEmail;
        lstEmail = lstEmail.filter(n => n);
        lstEmail = lstEmail.slice(0, 5);

        sendTestTemplate({
            emails: JSON.stringify(lstEmail),
            campaignId: this.campaignId
        })
            .then(result => {
                if (result.status == 'success') {
                    this.showToast('', this.label.Test_Template_Success, 'success');
                    this.closeModal();
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
            });

    }

    handleChange(event) {

        let email = event.detail.value;
        this.email = email;
        this.lstEmailDraft = email.toLowerCase().split(",");

    }

    handleEmailChange() {

        let lstEmail = this.lstEmail;
        let lstEmailDraft = this.lstEmailDraft;
        let validRegex = /[\w\-\._]+@[\w\-\._]+\.\w{2,10}/;

        //REMOVING INVALID EMAILS
        for (let i = 0; i < lstEmailDraft.length; i++) {
            if (!validRegex.test(lstEmailDraft[i])) { lstEmailDraft.splice(i, 1); }
        }

        //MERGING WITH EXISTING LIST
        lstEmail = lstEmail.concat(lstEmailDraft);
        //REMOVING EMPTY STRINGS FROM THE LIST
        lstEmail = lstEmail.filter(n => n);
        //REMOVING DUPLICATE EMAILS
        lstEmail = [...new Set(lstEmail)];
        //LIMITING THE LIST TO 5 EMAILS
        lstEmail = lstEmail.slice(0, 5);
        this.lstEmail = lstEmail;
        this.email = undefined;

    }

    handleKeyPress(event) {

        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.handleEmailChange();
        }

    }

    removeEmail(event) {
        let index = event.currentTarget.dataset.index;
        this.lstEmail.splice(index, 1);
        this.lstEmail = [...this.lstEmail];
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