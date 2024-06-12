public class ProductController {
   @AuraEnabled
    public static void insertPurchaseOrderWithItems(List<Purchase_Order_Item__c> items) {
        Map<Id,Decimal> prodMap = new Map<Id,Decimal>();
        // Perform DML operation to insert the records
        for(Purchase_Order_Item__c prod : items){
            prodMap.put(prod.Product_Name__c, prod.Quantity__c);
        }
        
        List<Product2> productlst = [SELECT Quantity__c FROM Product2 WHERE Id = :prodMap.keySet()];
        
        for(Product2 prodnew : productlst){
            Decimal ItemQuantity = prodMap.get(prodnew.Id);
            Decimal availableQuantity = prodnew.Quantity__c - ItemQuantity;
            prodnew.Quantity__c = availableQuantity;
            
        }
        
        Update productlst;
        
        System.debug('Data from lwc...'+ items);
        insert items;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getProductStock(Id productId) {
        // Replace with your logic to get the available stock for the product
        Product2 product = [SELECT Quantity__c FROM Product2 WHERE Id = :productId LIMIT 1];
        
        // Check if the product is not null and Quantity__c is not null
        if (product != null && product.Quantity__c != null) {
            // Convert Decimal to Integer
            return Integer.valueOf(product.Quantity__c);
        } else {
            return null; 
        }
    }
    
    public static void updatingTotalPriceInPurchaseOrderMethod(List<Purchase_Order_Item__c> items){
        set<Id> purchaseOrderId = new Set<Id>();
        for(Purchase_Order_Item__c pItem : items){
            purchaseOrderId.add(pItem.Purchase_Order__c);
            system.debug('purchaseOrderId' + purchaseOrderId);
        }
        
        List<AggregateResult> agResult = [SELECT SUM(Price__c) totalPrice, Purchase_Order__c FROM Purchase_Order_Item__c Where Purchase_Order__c =:purchaseOrderId GROUP BY Purchase_Order__c];
        Map<Id, Decimal> totalPriceMap = new Map<Id, Decimal>();
        for(AggregateResult agr : agResult){
            Decimal totalPrice = (Decimal)agr.get('totalPrice');
            Id purOrdId = (Id)agr.get('Purchase_Order__c');
            totalPriceMap.put(purOrdId, totalPrice);
        }
        system.debug('totalPriceMap' + totalPriceMap);
        List<Purchase_Order__c> purchaseOrdersToUpdate = new List<Purchase_Order__c>();
        for(Id pIds : totalPriceMap.keySet()){
            if(totalPriceMap.ContainsKey(pIds)){
                Purchase_Order__c newOrder = new Purchase_Order__c();
                newOrder.Id = pIds;
                newOrder.Total_Price__c = String.ValueOf(totalPriceMap.get(pIds));
                purchaseOrdersToUpdate.add(newOrder);
            }
            
        }
        system.debug('purchaseOrdersToUpdate' + purchaseOrdersToUpdate);
        if(!purchaseOrdersToUpdate.isEmpty()) {
            update purchaseOrdersToUpdate;
        }
    }

    

}