class PurchaseCatalogItem {
  const PurchaseCatalogItem({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
  });

  final String productId;
  final String title;
  final String description;
  final String price;
}

class PurchaseActionResult {
  const PurchaseActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}
