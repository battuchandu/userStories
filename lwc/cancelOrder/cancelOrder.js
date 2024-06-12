import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelOrderItem from '@salesforce/apex/CancelPurchaseOrder.cancelOrderItem';

export default class CancelOrder extends LightningElement {

@api recordId;

    handleCancelOrder() {
        cancelOrderItem({ orderItemId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Order item cancelled successfully and inventory updated',
                        variant: 'success'
                    })
                );
                // Optionally, you can refresh the view or do other actions here
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}