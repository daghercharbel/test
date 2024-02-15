import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { labelLibrary } from 'c/ttLabels';
import checkNamedCredentials from "@salesforce/apex/MassCreateTaskCompController.checkNamedCredentials";

import { fireEvent } from "c/pubsub";

export default class LwcModalFooter extends LightningElement {
  
  label = labelLibrary;
  @wire(CurrentPageReference) objpageReference;
  @track disableSaveButton = true;
  connectedCallback() {
    this.getNameCredentialsInfo();
  }
  SaveCreateMassAction() {
    fireEvent(this.objpageReference, "saveClicked", "saveClicked");
  }
  getNameCredentialsInfo() {
    checkNamedCredentials()
      .then((result) => {
        if (result) {
          this.disableSaveButton = false;
        } else {
          this.disableSaveButton = true;
        }
      })
      .catch((error) => {
        this.disableSaveButton = true;
        this.error = error.message;
      });
  }
}