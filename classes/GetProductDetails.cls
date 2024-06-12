public class GetProductDetails {
    @AuraEnabled
    public static Decimal getProductStandardPrice(id selectedProductId){
        Decimal unitPriceSelectedProduct;
        List<PricebookEntry> pricebokkEntryList = [SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntry where Product2Id=: selectedProductId];
        for(PricebookEntry entriesList : pricebokkEntryList){
            unitPriceSelectedProduct = entriesList.UnitPrice;
        }
        if(unitPriceSelectedProduct !=null){
            system.debug('unitPriceSelectedProduct---> ' + unitPriceSelectedProduct);
            return unitPriceSelectedProduct;
        }else {
            return null;
        }
    }
}