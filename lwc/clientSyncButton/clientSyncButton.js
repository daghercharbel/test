import { LightningElement, api, track } from 'lwc';
import getFeatureMetadataBasedOnId from '@salesforce/apex/ClientSyncButtonHandler.getFeatureMetadataBasedOnId';
import getRecordInfo from '@salesforce/apex/ClientSyncButtonHandler.getRecordInfo';
import syncRecordBasedOnRecId from '@salesforce/apex/ClientSyncButtonHandler.syncRecordBasedOnRecId';
import { updateRecord } from 'lightning/uiRecordApi';
import Contact_Label from '@salesforce/label/c.Contact_Label';
import Lead_Label from '@salesforce/label/c.Lead_Label';
import Sync_Label from '@salesforce/label/c.Sync_Label';

export default class ClientSyncButton extends LightningElement {
    label = {
        Contact_Label,
        Sync_Label,
        Lead_Label
    }
    showButton = false;
    isDisable = true;
    @api recordId;
    @api objectApiName;
    labelName = this.label.Sync_Label;
    minTime = '';
    @track seconds = 0;
    formattedTime = '00:00';
    showSpinner = false;

    connectedCallback() {
        this.labelName = this.labelName + ' ' + (this.objectApiName === 'Contact' ? this.label.Contact_Label : this.label.Lead_Label);
        this.fetchMetadata();
        this.getRecordInformation();
    }
    fetchMetadata() {
        getFeatureMetadataBasedOnId({ recordId: this.recordId })
            .then(result => {
                if (result.status == 'success') {
                    let response = JSON.parse(result.value);
                    this.showButton = response.TelosTouchSF__SF_Flag__c;
                    this.minTime = response.TelosTouchSF__Additional_Parameter__c;
                    this.initializeTimer();
                }
            })
            .catch(error => {
            });
    }
    getRecordInformation() {
        getRecordInfo({ recordId: this.recordId })
            .then(result => {
                let resp = JSON.parse(result)[0];
                this.isDisable = !resp.TelosTouchSF__TT_Conflict__c && resp.Email && resp.CreatedBy.TelosTouchSF__TT_UserId__c ? false : true;
            })
            .catch(error => {
            });
    }
    initializeTimer() {
        this.seconds = parseInt(this.minTime) * 60;
    }
    handleClick() {
        this.showSpinner = true;
        syncRecordBasedOnRecId({ recordId: this.recordId })
            .then(result => {
                this.isDisable = result;
            })
            .catch(error => {
            })
            .finally(() => {
                updateRecord({ fields: { Id: this.recordId } });
                this.isDisable = true;
                this.startTimer();
            });
    }

    startTimer() {
        this.intervalId = setInterval(() => {
            this.seconds--;
            this.updateTime();
        }, 1000);
    }
    updateTime() {
        const hours = Math.floor(this.seconds / 3600);
        const minutes = Math.floor((this.seconds % 3600) / 60);
        const seconds = this.seconds % 60;
        if (this.seconds <= 0) {
            clearInterval(this.intervalId);
            this.formattedTime = '00:00';
            this.isDisable = false;
            this.labelName = this.label.Sync_Label + ' ' + (this.objectApiName === 'Contact' ? this.label.Contact_Label : this.label.Lead_Label);
        } else {
            this.formattedTime = `${this.formatNumber(minutes)}:${this.formatNumber(seconds)}`;
            this.labelName = this.formattedTime;
            this.showSpinner = false;
        }
    }

    formatNumber(number) {
        return number < 10 ? `0${number}` : `${number}`;
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

};