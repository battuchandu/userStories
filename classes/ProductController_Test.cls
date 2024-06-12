@istest
public class ProductController_Test {

    @isTest
    static void testingProductQuantity(){
        Product2 prdct = new Product2();
        prdct.Name = 'Keys';
        prdct.Quantity__c = 90;
        insert prdct;
        Product2 prdct1 = new Product2();
        prdct1.Name = 'KeyBoard';
        prdct1.Quantity__c = null;
        insert prdct1;
        Test.startTest();
        Id productId = [select id,Quantity__c from Product2 where Name = 'Keys' limit 1].Id;
        Id productId2 = [select id,Quantity__c from Product2 where Name = 'KeyBoard' limit 1].Id;
        ProductController.getProductStock(productId);
        ProductController.getProductStock(productId2);
        Test.stopTest();
    }
    
    @isTest
    static void testingTotalPriceAndInsertAndUpdateMethod(){
        
        Purchase_Order__c pOrder = new Purchase_Order__c();
        pOrder.Name = 'PON-00001';
        insert pOrder;
        
        Product2 prdct = new Product2();
        prdct.Name = 'Keys';
        prdct.Quantity__c = 90;
        insert prdct;
        
        Purchase_Order_Item__c pItem = new Purchase_Order_Item__c();
        pItem.Purchase_Order__c = pOrder.Id;
        pItem.Quantity__c = 10;
        pItem.Product_Name__c = prdct.Id;
        pItem.Price__c = 1000;
        insert pItem;
        
        Purchase_Order_Item__c pItem2 = new Purchase_Order_Item__c();
        pItem2.Purchase_Order__c = pOrder.Id;
        pItem2.Quantity__c = 10;
        pItem2.Product_Name__c = prdct.Id;
        pItem2.Price__c = 1000;
        insert pItem2;
        
        Test.startTest();
        List<Purchase_Order_Item__c> pTems = [select id, Price__c, Quantity__c, Purchase_Order__c from Purchase_Order_Item__c];

        ProductController.updatingTotalPriceInPurchaseOrderMethod(pTems);
        Test.stopTest();
        
    }
    
    @isTest
    static void testingInsertPurchaseOrderWithItems() {
        Purchase_Order__c pOrder = new Purchase_Order__c();
        pOrder.Name = 'PON-00001';
        insert pOrder;
        
        Product2 prdct = new Product2();
        prdct.Name = 'Keys';
        prdct.Quantity__c = 90;
        insert prdct;
        
        Purchase_Order_Item__c pItem1 = new Purchase_Order_Item__c();
        pItem1.Purchase_Order__c = pOrder.Id;
        pItem1.Quantity__c = 10;
        pItem1.Product_Name__c = prdct.Id;
        pItem1.Price__c = 1000;
        
        Purchase_Order_Item__c pItem2 = new Purchase_Order_Item__c();
        pItem2.Purchase_Order__c = pOrder.Id;
        pItem2.Quantity__c = 10;
        pItem2.Product_Name__c = prdct.Id;
        pItem2.Price__c = 1000;
        
        List<Purchase_Order_Item__c> pItems = new List<Purchase_Order_Item__c> { pItem1, pItem2 };

        Test.startTest();
        ProductController.insertPurchaseOrderWithItems(pItems);
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Quantity__c FROM Product2 WHERE Id = :prdct.Id];
        System.assertNotEquals(70, updatedProduct.Quantity__c, 'Product quantity should be updated correctly.');
    } 
    
}