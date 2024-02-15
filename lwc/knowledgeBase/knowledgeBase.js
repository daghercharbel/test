/**
* FileName     : KnowledgeBase.cls
* Author       : CD
*  Date        : 26/08/2022
* Description  : Under TT Setup Tab, this lwc contains all the doccuments of User Guide, Installation, Unistallation and Onboarding.
* Controller   : KnowledgeBaseCompController.cls
*/
import { LightningElement, api, track } from "lwc";
import { labelLibrary } from 'c/ttLabels';
import GetImagesLinksKnowledgebase from "@salesforce/apex/KnowledgeBaseCompController.GetImagesLinksKnowledgebase";
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class KnowledgeBase extends LightningElement {
    label = labelLibrary;
    @track isSmallDevice = false;
    @track mapData2 = {};
    @track showBackButton = false;
    @api showCarousel = false;
    @track showInstallation = false;
    @track showOnboard = false;
    @track showUninstallation = false;
    @track showUserGuide = false;

    connectedCallback() {
        if (FORM_FACTOR === 'Medium' || FORM_FACTOR === 'Small') {
            isSmallDevice = true;
        }
        this.showCarousel = true;
        //Get all the custom medta data links
        GetImagesLinksKnowledgebase()
            .then((data) => {
                this.mapData2 = JSON.parse(data);

            })
            .catch((error) => {
                console.log(error);
                this.error = error;
                this.mapData2 = undefined;
            });

    }

    // When the Back Button is Clicked
    handleBack() {
        this.showOnboard = false;
        this.showInstallation = false;
        this.showUserGuide = false;
        this.showUninstallation = false;
        this.showBackButton = false;
        this.showCarousel = true;
    }

    // When the somethins on the Carousel is Clicked
    handleCarouselClick(event) {
        this.showCarousel = false;
        this.showBackButton = true;
        console.log('event.currentTarget.id' + event.currentTarget.id);
        if (event.currentTarget.id.includes('onboard')) {
            this.showOnboard = true;
        } else if (event.currentTarget.id.includes('install') && !event.currentTarget.id.includes('uninstall')) {
            this.showInstallation = true;
        } else if (event.currentTarget.id.includes('userGuide')) {
            this.showUserGuide = true;
        } else if (event.currentTarget.id.includes('uninstall') || event.currentTarget.id.includes('uninstallsmallDevice')) {
            this.showUninstallation = true;
        }
    }

    @api handleRedirect(value) {
        this.showCarousel = false;
        this.showBackButton = true;
        if (value == 'userGuide') { this.showUserGuide = true; }
    }
}