import { LightningElement, track, wire } from 'lwc';
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import { CurrentPageReference } from 'lightning/navigation';
export default class tT_InAppGuidance extends LightningElement {
     @track ContactAccordian = false;
     @track CampaignAccordian = false;
     @track LeadAccordian = false;
     @track activeObject ='Contact';
     currentPageReference = null; 
     ContactToCampaign = TelosTouch + '/guidance/TelosTouchSF__ContactToCampaign.png';
     LeadToCampaign = TelosTouch + '/guidance/TelosTouchSF__LeadToCampaign.png';
     CreateCampaign1 = TelosTouch + '/guidance/CreateCampaignNewBtnS1.png';
     CreateCampaign2 = TelosTouch + '/guidance/CreateCampaignChooseTTClickNextS2.png';
     CreateCampaign3 = TelosTouch + '/guidance/CreateCampaignEnterNameClickSaveS3.png';
     ClientNewCampaign4 = TelosTouch + '/guidance/ClientNewCampaignSubmitS4.png';
     ClientNewCampaign3 = TelosTouch + '/guidance/ClientNewCampaignSelectContS3.png';
     ClientNewCampaign1 = TelosTouch + '/guidance/ClientNewCampaignRelatedS1.png';
     ClientNewCampaign2 = TelosTouch + '/guidance/ClientNewCampaignAddContS2.png';
     ChooseTouchPoint2 = TelosTouch + '/guidance/ChooseTouchPointTempS2.png';
     ChooseTouchPoint4 = TelosTouch + '/guidance/ChooseTouchPointCnfS4.png';
     ChooseTouchPoint3 = TelosTouch + '/guidance/ChooseTocuhPointSendS3.png';
     ChooseTouchPoint1 = TelosTouch + '/guidance/ChooseTocuchPointBtnS1.png';
     CustomizeTocuhpoint2 = TelosTouch + '/guidance/CustomizeTocuhpointTempS2.png';
     CustomizeTocuhpoint3 = TelosTouch + '/guidance/CustomizeATouchpointSendLast.png';
     CustomizeTocuhpoint1 = TelosTouch + '/guidance/CustomizeATouchpointChooseBtnS1.png';
     TouchpointPreview1 = TelosTouch + '/guidance/TouchpointPreviewS1.png';
     ViewingCampaignResults = TelosTouch + '/guidance/ViewingCampaignResults.png';
     SendingCampaignReminder2 = TelosTouch + '/guidance/SendingCampaignReminderS2.png';
     SendingCampaignReminder1 = TelosTouch + '/guidance/SendingCampaignReminderS1.png';
     ExistingCampaign5 = TelosTouch + '/guidance/ExistingCampaignS5.png';
     ExistingCampaign4 = TelosTouch + '/guidance/ExistingCampaignS4.png';
     ExistingCampaign3 = TelosTouch + '/guidance/ExistingCampaignS3.png';
     ExistingCampaign2 = TelosTouch + '/guidance/ExistingCampaignS2.png';
     ExistingCampaign1 = TelosTouch + '/guidance/ExistingCampaignS1.png';
     MassActionsS3 = TelosTouch + '/guidance/MassActionsS3.png';
     MassActionsS2 = TelosTouch + '/guidance/MassActionsS2.png';
     MassActionsS1 = TelosTouch + '/guidance/MassActionsS1.png';
    
     @wire(CurrentPageReference)
     getStateParameters(currentPageReference) {
          if (currentPageReference) {
               this.activeObject = currentPageReference.attributes.objectApiName;
               if(this.activeObject == 'Contact'){
                    this.ContactAccordian = true;
                    this.CampaignAccordian = false;
                    this.LeadAccordian = false;
               }else if(this.activeObject == 'Campaign'){
                    this.ContactAccordian = false;
                    this.CampaignAccordian = true;
                    this.LeadAccordian = false;
               }else if(this.activeObject == 'Lead'){
                    this.ContactAccordian = false;
                    this.CampaignAccordian = false;
                    this.LeadAccordian = true;
               }else{
                    this.ContactAccordian = true;
                    this.CampaignAccordian = true;
                    this.LeadAccordian = true;
               }
          }
     }

}