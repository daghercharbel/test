import { LightningElement, track, api } from 'lwc';
import logIssue from "@salesforce/apex/TT_ContactSupportController.logIssue";
import { labelLibrary } from 'c/ttLabels';

export default class ttcontactSupport extends LightningElement {
    label = labelLibrary;
    @track formActive = false;
    @api tabName;
    @track showToast = false;
    @track variant;
    @track msg;
  
    @track chatButtonActive = true;
    @track myMessage = '';
    @track requestBody = {
        'subject' : '',
        'description' : ''
    };

    displayToast (variant, msg) {
        this.variant = variant;
        this.msg = msg;
        this.showToast = true;
        setTimeout(() => { 
          this.showToast = false;
        }, 4000);
    }

    openForm(){
        this.formActive = true;
        this.chatButtonActive = false;
    }
    closeForm(){
        this.formActive = false;
        this.chatButtonActive = true;
    }

    sendMessage(){
        var subInputCmp = this.template.querySelector('.subInputCmp');
        var descInputCmp = this.template.querySelector('.descInputCmp');
        if(this.requestBody.subject.length < 1){
            subInputCmp.setCustomValidity(this.label.FIELD_VALIDATION);
        }else{
            subInputCmp.setCustomValidity('');
        }
        if(this.requestBody.description.length < 1){
            descInputCmp.setCustomValidity(this.label.FIELD_VALIDATION);
        }else{
            descInputCmp.setCustomValidity('');
        }
        subInputCmp.reportValidity();
        descInputCmp.reportValidity();

        if((this.requestBody.description.length > 0) && (this.requestBody.subject.length > 0)){
            logIssue({subject: this.requestBody.subject, description: this.requestBody.description }).then((result) => {
                this.requestBody.subject = '';
                this.requestBody.description = '';
                if (result === 'success') {
                  this.showModal = false;
                  this.displayToast('success', this.label.CASE_RAISED);
                  this.formActive = false;
                  this.chatButtonActive = true;
              }else{
                this.displayToast('error', result);
                this.formActive = false;
                this.chatButtonActive = true;
              }
            });
           
        }
    }

    handleChange (event) {
        this.requestBody[event.target.dataset.field] = event.target.value;
    }
    handleToastVisibilityChange () {
      this.showToast = false;
    }
}