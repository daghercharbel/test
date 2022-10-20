/**
* FileName     : KnowledgeBase.cls
* Author       : CD
*  Date        : 26/08/2022
* Description  : Under TT Setup Tab, this lwc contains all the doccuments of User Guide, Installation, Unistallation and Onboarding.
* Controller   : KnowledgeBaseCompController.cls
*/
import { LightningElement, wire, track } from "lwc";

import GetImagesLinksKnowledgebase from "@salesforce/apex/KnowledgeBaseCompController.GetImagesLinksKnowledgebase";

import Knowledge_Base_Image_Error from "@salesforce/label/c.Knowledge_Base_Image_Error";
import FORM_FACTOR from '@salesforce/client/formFactor';
import Welcome_to_Knowledge_base from "@salesforce/label/c.Welcome_to_Knowledge_base";
import Showing_docs_Knowledge_base from "@salesforce/label/c.Showing_docs_Knowledge_base";
import Onboarding_Checklist_Text from "@salesforce/label/c.Onboarding_Checklist_Text";
import Onboarding_Related from "@salesforce/label/c.Onboarding_Related";
import Installation_Guide_Text from "@salesforce/label/c.Installation_Guide_Text";
import Installation_Guide_Related from "@salesforce/label/c.Installation_Guide_Related";
import User_Guide_Text from "@salesforce/label/c.User_Guide_Text";
import User_Guide_Related from "@salesforce/label/c.User_Guide_Related";
import Uninstallation_Guide_Text from "@salesforce/label/c.Uninstallation_Guide_Text";
import Uninstallation_Guide_Related from "@salesforce/label/c.Uninstallation_Guide_Related";
import Looking_for_help_text from "@salesforce/label/c.Looking_for_help_text";
export default class KnowledgeBase extends LightningElement {
    label = {
        Welcome_to_Knowledge_base,
        Showing_docs_Knowledge_base,
        Onboarding_Checklist_Text,
        Onboarding_Related,
        Installation_Guide_Text,
        Installation_Guide_Related,
        User_Guide_Text,
        User_Guide_Related,
        Uninstallation_Guide_Text,
        Uninstallation_Guide_Related,
        Looking_for_help_text,
        Knowledge_Base_Image_Error
    };
    @track showCarousel = true;
    @track showBackButton = false;
    @track isSmallDevice = false;

    @track showOnboard = false;
    @track showInstallation = false;
    @track showUserGuide = false;
    @track showUninstallation = false;


    @track mapData2 = {};
    connectedCallback() {
        if (FORM_FACTOR === 'Medium' || FORM_FACTOR === 'Small') {
            isSmallDevice = true;
        }
        //Get all the custom medta data links
        GetImagesLinksKnowledgebase()
            .then((data) => {
                console.log(JSON.parse(data));
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
}