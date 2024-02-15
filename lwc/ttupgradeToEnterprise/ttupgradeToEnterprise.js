import { LightningElement, track } from 'lwc';
import sendEmail from "@salesforce/apex/TT_UpgradeToEnterpriseController.sendEmail";
import { labelLibrary } from 'c/ttLabels';

export default class ttupgradeToEnterprise extends LightningElement {

    label = labelLibrary;
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