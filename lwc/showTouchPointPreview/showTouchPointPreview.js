import { api, LightningElement } from "lwc";
import TelosTouch from "@salesforce/resourceUrl/TelosTouch";
import { loadStyle } from "lightning/platformResourceLoader";
import getIFrameUrls from "@salesforce/apex/ShowTouchPointPreviewController.getIFrameUrls";
import getIFrameUrlsFromTemplateId from "@salesforce/apex/ShowTouchPointPreviewController.getIFrameUrlsFromTemplateId";
import Email_Text from "@salesforce/label/c.Email_Text";
import Language_Text from "@salesforce/label/c.Language_Text";
import TouchPoint_Experience_Text from "@salesforce/label/c.TouchPoint_Experience_Text";
import English_Text from "@salesforce/label/c.English_Text";
import French_Text from "@salesforce/label/c.French_Text";

export default class ShowTouchPointPreview extends LightningElement {
  langValue = "en_US";
  urls = {};
  @api recordId;
  @api templateId;
  @api touchpointSelectionPreview = false;
  label = {
    Email_Text,
    Language_Text,
    TouchPoint_Experience_Text,
    English_Text,
    French_Text
  };

  get langOptions() {
    return [
      { label: this.label.English_Text, value: "en_US" },
      { label: this.label.French_Text, value: "fr_FR" }
    ];
  }

  handleLangChange(event) {
    this.urls.email = "about:blank";
    this.urls.touchpoint = "about:blank";
    this.langValue = event.detail.value;
    // console.log(this.langValue);
    if (this.templateId) {
      this.getUrlfromTemplate();
    }
    else{
      this.getUrls();
    }
  }

  connectedCallback() {
    loadStyle(this, TelosTouch + "/PreviewTouchPoint.css");
    if (this.templateId) {
      this.getUrlfromTemplate();
    }
    else{
      this.getUrls();
    }
  }

  getUrls() {
    getIFrameUrls({ recordId: this.recordId, language: this.langValue })
      .then((result) => {
        this.urls = JSON.parse(result);
        // console.log(this.urls);
      })
      .catch((error) => {
        this.error = error.message;
      });
  }

  getUrlfromTemplate() {
    getIFrameUrlsFromTemplateId({ templateId: this.templateId, language: this.langValue })
      .then((result) => {
        this.urls = JSON.parse(result);
        // console.log(this.urls);
      })
      .catch((error) => {
        this.error = error.message;
      });
  }
}