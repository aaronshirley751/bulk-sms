import { LightningElement, api, track } from 'lwc';
import getTemplateOptions from '@salesforce/apex/BulkSMSController.getTemplateOptions';
import sendBulkSMS from '@salesforce/apex/BulkSMSController.sendBulkSMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ListViewBulkSms extends LightningElement {
  @api recordIds;
  @track templateOptions = [];
  @track selectedTemplate = '';
  @track messageText = '';
  @track isSending = false;

  connectedCallback() {
    getTemplateOptions()
      .then(options => {
        this.templateOptions = options;
      })
      .catch(error => {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error loading templates',
          message: error.body?.message || error,
          variant: 'error'
        }));
      });
  }

  handleTemplateChange(evt) {
    this.selectedTemplate = evt.detail.value;
  }
  handleTextChange(evt) {
    this.messageText = evt.detail.value;
  }

  handleSend() {
    if (!this.messageText && !this.selectedTemplate) {
      return;
    }
    this.isSending = true;
    sendBulkSMS({
      recordIds: this.recordIds,
      messageText: this.messageText || this.selectedTemplate,
      fromAddress: 'DefaultSender'
    })
      .then(result => {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Success',
          message: result,
          variant: 'success'
        }));
      })
      .catch(error => {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error sending SMS',
          message: error.body?.message || error,
          variant: 'error'
        }));
      })
      .finally(() => {
        this.isSending = false;
      });
  }
}
