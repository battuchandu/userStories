trigger PurchaseItemTrigger on Purchase_Order_Item__c (after insert) {
   if(trigger.isAfter){
        if(trigger.isInsert){
            ProductController.updatingTotalPriceInPurchaseOrderMethod(trigger.new);
        }
    } 
}