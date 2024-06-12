import { LightningElement, track, api } from 'lwc';
import insertPurchaseOrderWithItems from '@salesforce/apex/ProductController.insertPurchaseOrderWithItems';
import getProductStock from '@salesforce/apex/ProductController.getProductStock';
import getUnitPrice from '@salesforce/apex/GetProductDetails.getProductStandardPrice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ManagePurchaseOrders extends LightningElement {
    @track mainComponent = false;
    @track addRowFlag = false;
    @track items = [];
    @track isLoading = false;
    @track accountId;
    @track purchaseOrderId;
    @track productDataDefaultValue = false;
    @track quantityDefaultValue = false;

    @api recordId;

    handleClickToOpen() {
        this.mainComponent = true;
    }

    addRow() {
        this.addRowFlag = true;
        const newRow = this.createNewRow();
        this.items = [...this.items, newRow];
    }

    createNewRow() {
        return {
            Purchase_Order__c: this.recordId,
            Vendor_Account_Name__c: this.accountId,
            Product_Name__c: "",
            Quantity__c: "",
            AvailableStock: 0,
            UnitPrice: '',
            subTotalAmount: ''
        };
    }
    grandTotal = 0;
    grandTotalValue = false;

    handleQuantityChange(event) {
        const index = event.target.dataset.id;
        const quantity = event.target.value;
        const availableStock = this.items[index].AvailableStock;
        console.log('availableStock' + availableStock);
        console.log('quantity' + quantity);
        this.quantityDefaultValue = true;

        if (quantity > availableStock) {
            this.showToast('Error', `Quantity exceeds available stock of ${availableStock}`, 'error');
            //this.items[index].Quantity__c = availableStock;
        } else if (quantity == 0) {
            this.showToast('Error', `Quantity cannot be zero. Please enter at least one item available stock of ${availableStock}`, 'error');
        }
        this.items[index].Quantity__c = quantity;
        this.items[index].subTotalAmount = quantity * this.items[index].UnitPrice;
        console.log('this.items[index].Quantity__c:', this.items[index].Quantity__c);
        console.log('this.items[index].subTotalAmount:', this.items[index].subTotalAmount);
        this.calculateGrandTotal();


    }


    handleProductChange(event) {
        const index = event.target.dataset.id;
        const productId = event.target.value;
        this.items[index].Product_Name__c = productId;
        this.productDataDefaultValue = true;

        // Fetch both stock and unit price in parallel
        Promise.all([
            getProductStock({ productId }),
            getUnitPrice({ selectedProductId: productId })
        ])
            .then(([stock, price]) => {
                this.items[index].AvailableStock = stock;
                this.items[index].UnitPrice = price;
                this.items[index].stockClass = stock < 50 ? 'low-stock' : 'normal-stock';



                // Show a toast message with both the available stock and unit price
                if (stock < 50) {
                this.showToast('Warning', `Available stocks are low: ${stock}. Unit Price is ${price}`, 'warning');
            } else {
                this.showToast('Success', `Available stocks are ${stock} and Unit Price is ${price}`, 'success');
            }
            })
            .catch(error => {
                console.error('Error fetching product data', error);
            });

        this.items = [...this.items];  // Trigger reactivity
        this.calculateGrandTotal();

    }


    handleDeleteAction(event) {
        const recordId = event.target.dataset.id;
        const index = this.items.findIndex(item => item.Id === recordId);
        if (index !== -1) {
            this.items = [...this.items.slice(0, index), ...this.items.slice(index + 1)];
        }
        this.calculateGrandTotal();

    }

    handleInsertAction() {
        if (this.validateFields()) {
            let itemsToInsert = this.items.map(item => {
                return {
                    Vendor_Account_Name__c: this.accountId,
                    Purchase_Order__c: this.recordId,
                    Product_Name__c: item.Product_Name__c,
                    Quantity__c: item.Quantity__c,
                    Price__c: item.subTotalAmount
                };
            });

            insertPurchaseOrderWithItems({ items: itemsToInsert })
                .then(result => {
                    const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Purchase Order Items created successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    console.log('Inserted Records Successfully:', result);
                    this.items = [];
                    this.mainComponent = false;
                })
                .catch(error => {
                    console.error('Error Inserting Records:', error);
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to save Purchase Order and Items',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                });
        }

        else {

            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to save Purchase Order and Items',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    validateFields() {
        let isValid = true;
        console.log('isValid' + isValid);
        this.items.forEach((item) => {
            console.log('item.Quantity__c' + item.Quantity__c);
            console.log('item.AvailableStock' + item.AvailableStock);
            if (!item.Product_Name__c || !item.Quantity__c || item.Quantity__c > item.AvailableStock) {
                isValid = false;
            }
        });
        console.log('isValid' + isValid);
        return isValid;
    }

    closeAction() {
        this.items = [];
        this.mainComponent = false;
    }

    calculateGrandTotal() {
        this.grandTotal = this.items.reduce((total, item) => total + parseFloat(item.subTotalAmount || 0), 0);
        this.grandTotalValue = this.grandTotal > 0;
    }

    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Purchase Order created successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        this.mainComponent = false;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvent);
    }
}