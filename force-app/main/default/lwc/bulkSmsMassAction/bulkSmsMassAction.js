import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class BulkSmsMassAction extends LightningElement {
    @api recordIds;

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSend() {
        // TODO: Implement SMS sending logic
        console.log('Sending SMS to contacts:', this.recordIds);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
