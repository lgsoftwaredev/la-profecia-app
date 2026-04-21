import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../domain/entities/purchase_models.dart';
import 'premium_providers.dart';

class PurchaseUiState {
  const PurchaseUiState({
    required this.loading,
    required this.catalog,
    this.message,
  });

  factory PurchaseUiState.initial() =>
      const PurchaseUiState(loading: false, catalog: <PurchaseCatalogItem>[]);

  final bool loading;
  final List<PurchaseCatalogItem> catalog;
  final String? message;

  PurchaseUiState copyWith({
    bool? loading,
    List<PurchaseCatalogItem>? catalog,
    String? message,
  }) {
    return PurchaseUiState(
      loading: loading ?? this.loading,
      catalog: catalog ?? this.catalog,
      message: message,
    );
  }
}

final purchaseControllerProvider =
    NotifierProvider<PurchaseController, PurchaseUiState>(
      PurchaseController.new,
    );

class PurchaseController extends Notifier<PurchaseUiState> {
  @override
  PurchaseUiState build() {
    Future<void>(() async {
      await refreshCatalog();
    });
    return PurchaseUiState.initial();
  }

  Future<void> refreshCatalog() async {
    final service = ref.read(purchaseServiceProvider);
    await service.refreshCatalog();
    state = state.copyWith(catalog: service.catalog, message: null);
  }

  Future<void> purchaseMonthly() async {
    final service = ref.read(purchaseServiceProvider);
    state = state.copyWith(loading: true, message: null);
    final result = await service.purchaseMonthly();
    if (result.success) {
      await _refreshPremiumWithRetries();
    } else {
      await ref.read(premiumAccessProvider.notifier).refresh();
    }
    await refreshCatalog();
    state = state.copyWith(loading: false, message: result.message);
  }

  Future<void> restore() async {
    final service = ref.read(purchaseServiceProvider);
    state = state.copyWith(loading: true, message: null);
    final result = await service.restorePurchases();
    if (result.success) {
      await _refreshPremiumWithRetries();
    } else {
      await ref.read(premiumAccessProvider.notifier).refresh();
    }
    await refreshCatalog();
    state = state.copyWith(loading: false, message: result.message);
  }

  Future<void> _refreshPremiumWithRetries() async {
    final notifier = ref.read(premiumAccessProvider.notifier);
    await notifier.refresh();
    if (ref.read(premiumAccessProvider)) {
      return;
    }

    for (var attempt = 0; attempt < 10; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await notifier.refresh();
      if (ref.read(premiumAccessProvider)) {
        return;
      }
    }
  }
}
