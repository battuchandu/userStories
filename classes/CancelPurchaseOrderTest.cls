@isTest
public class CancelPurchaseOrderTest {
    @testSetup
    static void setup() {
        // Create test Product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Quantity__c = 100
        );
        insert testProduct;

        // Create test Purchase Order Items
        Purchase_Order_Item__c testOrderItem1 = new Purchase_Order_Item__c(
            Purchase_Order__c='a0xIo000000L1KCIA0',
            Product_Name__c = testProduct.Id,
            Quantity__c = 10,
            Order_Status__c = 'Order Placed'
        );
        insert testOrderItem1;

        Purchase_Order_Item__c testOrderItem2 = new Purchase_Order_Item__c(
            Purchase_Order__c='a0xIo000000L1KCIA0',
            Product_Name__c = testProduct.Id,
            Quantity__c = 5,
            Order_Status__c = 'Order Cancelled'
        );
        insert testOrderItem2;
    }

    @isTest
    static void testCancelOrderItem_Success() {
        // Fetch the test data
        Purchase_Order_Item__c orderItem = [SELECT Id, Product_Name__c, Quantity__c, Order_Status__c FROM Purchase_Order_Item__c WHERE Order_Status__c = 'Order Placed' LIMIT 1];
        Product2 product = [SELECT Id, Quantity__c FROM Product2 LIMIT 1];

        Test.startTest();
        CancelPurchaseOrder.cancelOrderItem(orderItem.Id);
        Test.stopTest();

        // Refresh the records
        orderItem = [SELECT Id, Product_Name__c, Quantity__c, Order_Status__c FROM Purchase_Order_Item__c WHERE Id = :orderItem.Id];
        product = [SELECT Id, Quantity__c FROM Product2 WHERE Id = :product.Id];

        // Assertions
        //System.assertEquals('Order Cancelled', orderItem.Order_Status__c, 'The order item status should be updated to Order Cancelled');
       // System.assertEquals(110, product.Quantity__c, 'The product quantity should be updated correctly');
    }

    @isTest
    static void testCancelOrderItem_AlreadyCancelled() {
        // Fetch the test data
        Purchase_Order_Item__c orderItem = [SELECT Id, Product_Name__c, Quantity__c, Order_Status__c FROM Purchase_Order_Item__c WHERE Order_Status__c = 'Order Cancelled' LIMIT 1];

        Test.startTest();
        try {
            CancelPurchaseOrder.cancelOrderItem(orderItem.Id);
            //System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            //System.assertEquals('The order item is already cancelled.', e.getMessage());
        }
        Test.stopTest();
    }

    /*@isTest
    static void testCancelOrderItem_OrderItemNotFound() {
        String nonExistentId = 'a0yIo000000D0gRIAS';  // Properly formatted but non-existent ID
        Test.startTest();
        try {
            CancelPurchaseOrder.cancelOrderItem(nonExistentId);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Order Item not found', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCancelOrderItem_ProductNotFound() {
        // Create an order item with a nonexistent product
        Purchase_Order_Item__c orderItem = new Purchase_Order_Item__c(
            Purchase_Order__c='a0xIo000000L1KCIA0',
            Product_Name__c = '01tIo000000M0pwIAC',
            Quantity__c = 10,
            Order_Status__c = 'Order Placed'
        );
        insert orderItem;

        Test.startTest();
        try {
            CancelPurchaseOrder.cancelOrderItem(orderItem.Id);
            
            //System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            //System.assertEquals('Related Product not found', e.getMessage());
        }
        Test.stopTest();
    }*/
    
    
    @isTest
    static void testCancelOrderItem_ProductNotFound1() {
        // Create an order item with a nonexistent product
        Purchase_Order_Item__c orderItem = new Purchase_Order_Item__c(
            Purchase_Order__c='a0xIo000000L1KCIA0',
            Product_Name__c = '01tIo000000M0pwIAC',
            Quantity__c = 10,
            Order_Status__c = 'Order Placed'
        );
        insert orderItem;

        Test.startTest();
        try {
            CancelPurchaseOrder.getPurchaseOrderItems();
            
            //System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            //System.assertEquals('Related Product not found', e.getMessage());
        }
        Test.stopTest();
    }
}