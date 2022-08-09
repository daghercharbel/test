import { LightningElement, track } from 'lwc';
import getSettingAPI from '@salesforce/apex/TelosTouchUtility.getSettingAPI';
import Dashboard_Non_TT_User_Text from '@salesforce/label/c.Dashboard_Non_TT_User_Text';
import LANG from '@salesforce/i18n/lang';

export default class HomeDashboardComponent extends LightningElement {
    label = {
        Dashboard_Non_TT_User_Text
    }
    @track IframeUrl = '';
    @track scrolling = 'none';
    @track frameBorder = 'none';
    @track isShowTost = false;
    @track isShowSpinner = false;
    @track showIframe = false;
    @track isNotAuthenticate = false;
    lang = LANG;
    connectedCallback() {
        this.isShowSpinner = true;
        window.addEventListener('resize', this.windowResize);
        getSettingAPI({isCallingFrom : 'TTDeshboard'})
        .then(result => {
            let storedResponse = result;
            if(storedResponse != null && storedResponse && storedResponse.adminCredentials.Instance_URL && storedResponse.authToken != undefined && storedResponse.authToken != null && storedResponse.authToken){
                let iframURL;
                if(this.lang === 'en-US'){
                    iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/dashboard?fullscreen=true&lang=en_US&access_token="+storedResponse.authToken;
                }else if(this.lang === 'fr'){
                    iframURL = storedResponse.adminCredentials.Instance_URL+"/app/v1/#/dashboard?fullscreen=true&lang=fr_FR&access_token="+storedResponse.authToken;
                }
                this.IframeUrl = iframURL;
                this.isShowSpinner = false;
                this.showIframe = true;
            }else{
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
    setHeight(){
        console.log('resize screen.availHeight',screen.availHeight);
        console.log('resize screen.availWidth',screen.availWidth);
        if(window.screen.availWidth < 900){
            //Mobile or Tablet
            console.log('Mobile or Tablet');
            let Height = screen.availHeight - 305;
            this.template.querySelector(".iframe-style").style.height = Height + "px";
        }else if(window.screen.availWidth > 1600){
            //large screen
            console.log('large screen');
            let Height = screen.availHeight - 261;
            this.template.querySelector(".iframe-style").style.height = Height + "px";
        }else if(window.screen.availWidth > 900 && window.screen.availWidth < 1600){
            //laptop
            console.log('laptop');
            let Height = screen.availHeight - 261;
            this.template.querySelector(".iframe-style").style.height = Height + "px";
        }
        console.log('style.height',this.template.querySelector(".iframe-style").style.height);
    }

    windowResize = () => {
        console.log('resize');
        if(this.showIframe){
            this.setHeight();
        }
    }
}