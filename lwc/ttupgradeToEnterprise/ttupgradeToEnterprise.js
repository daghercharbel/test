import { LightningElement, track } from 'lwc';
import sendEmail from "@salesforce/apex/TT_UpgradeToEnterpriseController.sendEmail";
import EnterpriseRequest from '@salesforce/label/c.EnterpriseRequest';
import EnterpriseUpgrade from '@salesforce/label/c.EnterpriseUpgrade';
import Submit from '@salesforce/label/c.Submit';
import cancel from '@salesforce/label/c.cancel';
import Close from '@salesforce/label/c.Close';
import Description from '@salesforce/label/c.Additional_Information';
import RequestSentSuccessfully from '@salesforce/label/c.RequestSentSuccessfully';

export default class ttupgradeToEnterprise extends LightningElement {
  label = {
    EnterpriseRequest,
    EnterpriseUpgrade,
    Submit,
    cancel,
    Close,
    Description,
    RequestSentSuccessfully,
};

    @track showModal = false;
    @track requestBody = {
      'description' : ''
    };
    @track showToast = false;
    @track variant;
    @track msg;
  
    handleChange (event) {
      this.requestBody[event.target.dataset.field] = event.target.value;
    }
  
    displayToast (variant, msg) {
      this.variant = variant;
      this.msg = msg;
      this.showToast = true;
      setTimeout(() => { 
        this.showToast = false;
      }, 4000);
    }
  
    openModal () {
      this.showModal = true;
    }

    closeModal () {
      this.showModal = false;
    }

    submitRequest () {
      sendEmail({description: this.requestBody.description }).then((result) => {
          if (result === 'success') {
            this.showModal = false;
            this.displayToast('success', this.label.RequestSentSuccessfully);
        }else{
          this.displayToast('error', result);
        }
      });

    }

    handleToastVisibilityChange () {
      this.showToast = false;
    }
}