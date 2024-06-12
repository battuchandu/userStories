public class CancelPurchaseOrder {
    @AuraEnabled
    public static void cancelOrderItem(Id orderItemId) {
        // Fetch the order item and related inventory stock
        Purchase_Order_Item__c orderItem = [
            SELECT Id, Product_Name__c, Quantity__c, Order_Status__c 
            FROM Purchase_Order_Item__c 
            WHERE Id = :orderItemId 
            LIMIT 1
        ];

        if (orderItem == null) {
            throw new AuraHandledException('Order Item not found');
        }

        if (orderItem.Order_Status__c == 'Order Cancelled') {
            throw new AuraHandledException('The order item is already cancelled.');
        }

        // Fetch the related product
        Product2 product = [
            SELECT Id, Quantity__c
            FROM Product2
            WHERE Id = :orderItem.Product_Name__c
            LIMIT 1
        ];

        if (product == null) {
            throw new AuraHandledException('Related Product not found');
        }

        // Update the order item status
        orderItem.Order_Status__c = 'Order Cancelled';

        // Update the inventory quantity
        product.Quantity__c += orderItem.Quantity__c;

        // Perform DML operations
        update orderItem;
        update product;
    }

    @AuraEnabled(cacheable=true)
    public static List<Purchase_Order_Item__c> getPurchaseOrderItems(){
        
        return [select id,Name,Purchase_Order__c,Product_Name__c,Quantity__c,Price__c,Order_Status__c from Purchase_Order_Item__c];
        
    }
}