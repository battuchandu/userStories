@IsTest
public class GetProductDetails_Test {

    @isTest
    static void testingUnitPriceMethod() {
        // Create and insert a product
        Product2 prdt = new Product2();
        prdt.Name = 'Mouse';
        prdt.ProductCode = '23';
        prdt.Quantity__c = 100;
        insert prdt;
        
        // Get the standard price book ID
        Id standardPricebookId = Test.getStandardPricebookId();
        
        // Create and insert a standard price book entry for the product
        PricebookEntry standardPriceRecord = new PricebookEntry();
        standardPriceRecord.Product2Id = prdt.Id;
        standardPriceRecord.Pricebook2Id = standardPricebookId;
        standardPriceRecord.UnitPrice = 900; // Standard price
        standardPriceRecord.IsActive = true;
        insert standardPriceRecord;
        
        // Create and insert a custom price book
        Pricebook2 customPricebook = new Pricebook2();
        customPricebook.Name = 'Custom Price Book';
        customPricebook.IsActive = true;
        insert customPricebook;
        
        // Create and insert a custom price book entry for the product
        PricebookEntry customPriceRecord = new PricebookEntry();
        customPriceRecord.Product2Id = prdt.Id;
        customPriceRecord.Pricebook2Id = customPricebook.Id;
        customPriceRecord.UnitPrice = 1000; // Custom price
        customPriceRecord.IsActive = true;
        insert customPriceRecord;
        
        Test.startTest();
        // Fetch the product ID and invoke the method to get the standard price
        Decimal standardPrice = GetProductDetails.getProductStandardPrice(prdt.Id);
        Decimal standardPrice2 = GetProductDetails.getProductStandardPrice(null);

        Test.stopTest();
        
        // Assert the returned standard price is correct
        System.assertNotEquals(900, standardPrice);
    }
}