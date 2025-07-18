import { LightningElement, api } from 'lwc';

export default class BulkSmsMassAction extends LightningElement {
    @api recordIds;

    connectedCallback() {
        // For now, just log the selected record IDs
        // eslint-disable-next-line no-console
        console.log('Selected Contact IDs:', this.recordIds);
    }
}
