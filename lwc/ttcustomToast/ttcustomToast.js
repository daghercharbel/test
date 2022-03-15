import { LightningElement, track, api } from 'lwc';
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ttcustomToast extends LightningElement {
    @api variant = 'error';
    @api message = 'Record submitted successfully';
    @track iconName = 'utility:error';
    @track themeClass = 'slds-notify slds-notify_toast ';
    @track LeftLeftIconClass;
    @track RightIconClass;

    connectedCallback(){
    loadStyle(this, TelosTouch + '/TT_Custom_Toast.css');
      switch(this.variant) {
        case 'success':
          this.themeClass = this.themeClass + 'slds-theme_success';
          this.iconName = 'utility:success';
          this.LeftIconClass = 'myLeftSuccessIcon';
          this.RightIconClass = 'mySuccessIcon';
          break;
        case 'error':
          this.themeClass = this.themeClass + 'slds-theme_error';
          this.iconName = 'utility:error';
          this.LeftIconClass = 'myLeftErrorIcon';
          this.RightIconClass = 'myErrorIcon';
          break;
        default:
          this.themeClass = this.themeClass + 'slds-theme_warning';
          this.iconName = 'utility:warning';
          this.LeftIconClass = 'myLeftWarningIcon';
          this.RightIconClass = 'myWarningIcon';
      }
    }

    closeToast(){
      const selectedEvent = new CustomEvent("toastvisibilitychange", {});
      this.dispatchEvent(selectedEvent);
    }

}