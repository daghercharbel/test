import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import Save_Button_Label from "@salesforce/label/c.Save_Button_Label";
import checkNamedCredentials from "@salesforce/apex/MassCreateTaskCompController.checkNamedCredentials";

import { fireEvent } from "c/pubsub";
export default class LwcModalFooter extends LightningElement {
  label = {
    Save_Button_Label
  };
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