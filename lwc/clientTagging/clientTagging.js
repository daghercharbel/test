import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import deleteAssignments from '@salesforce/apex/ClientTaggingController.deleteAssignments';
import getTopics from '@salesforce/apex/ClientTaggingController.getTopics';
import upsertTopics from '@salesforce/apex/ClientTaggingController.upsertTopics';

//Custom Labels
import add_topic from '@salesforce/label/c.Add_Topic';
import available from '@salesforce/label/c.Available';
import cancel from '@salesforce/label/c.Cancel_Button_Label';
import remove_topic from '@salesforce/label/c.Remove_Topic';
import save from '@salesforce/label/c.Save_Button_Label';
import selected from '@salesforce/label/c.Selected';
import topic_added from '@salesforce/label/c.Topic_Added';
import topic_removed from '@salesforce/label/c.Topic_Removed';

export default class ClientTagging extends LightningElement {

    label = {
        add_topic,
        available,
        cancel,
        remove_topic,
        save,
        selected,
        topic_added,
        topic_removed
    };

    isLoading = true;
    lstOptions;
    lstRecordId;
    lstTags = [];
    @api lstUser;
    @api taggingType;
    title;

    get hasTag() {
        return (!this.lstTags || this.lstTags.length == 0);
    }

    get isAdd() {
        return this.taggingType == 'add';
    }

    get isRemove() {
        return this.taggingType == 'remove';
    }

    connectedCallback() {

        let lstRecordId = [];
        this.lstUser.forEach(user => {
            lstRecordId.push(user.ContactOrLeadSFId);
        });
        this.lstRecordId = lstRecordId;

        if (this.taggingType == 'add') {
            this.title = this.label.add_topic;
            this.isLoading = false;
        } else if (this.taggingType == 'remove') {
            this.title = this.label.remove_topic;
            this.getTags();
        }
    }

    getTags() {

        getTopics({
            lstRecordId: this.lstRecordId
        })
            .then(result => {
                if (result.status == 'success') {
                    if (result.value) {

                        let response = JSON.parse(result.value);
                        let lstOptions = [];

                        response.forEach(tag => {
                            lstOptions.push({ label: tag.Name, value: tag.Id })
                        });
                        this.lstOptions = lstOptions;
                    }
                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });

    }

    handleClose() {
        const clientTagEvent = new CustomEvent('clientTagUpd', {
            detail: { action: 'close' },
        });
        this.dispatchEvent(clientTagEvent);
    }

    handleChange(event) {
        this.lstTags = (event.target.value) ? [event.target.value] : [];
    }

    handleDelete() {

        deleteAssignments({
            lstTopic: this.lstTags,
            lstRecordId: this.lstRecordId
        })
            .then(result => {
                if (result.status == 'success') {
                    this.showToast('', this.label.topic_removed, 'success');
                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.handleClose();
            });

    }

    handleSave() {

        this.isLoading = true;
        if (this.taggingType == 'add') {
            this.handleUpsert();
        } else if (this.taggingType == 'remove') {
            this.handleDelete();
        }

    }

    handleSelect(event) {
        this.lstTags = event.detail.value;
    }

    handleUpsert() {
        upsertTopics({
            topicName: this.lstTags[0],
            lstRecordId: this.lstRecordId
        })
            .then(result => {
                if (result.status == 'success') {
                    this.showToast('', this.label.topic_added, 'success');
                } else {
                    console.error(result.error);
                    this.showToast('Error', result.error, 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.handleClose();
            });

    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

}