import '../entities/purchase_models.dart';

abstract class PurchaseService {
  Future<void> initialize();
  List<PurchaseCatalogItem> get catalog;
  String get monthlyProductId;
  Future<void> refreshCatalog();
  Future<PurchaseActionResult> purchaseMonthly();
  Future<PurchaseActionResult> restorePurchases();
}
