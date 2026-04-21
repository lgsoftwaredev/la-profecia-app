import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/purchase_models.dart';
import '../../domain/services/entitlement_service.dart';
import '../../domain/services/purchase_service.dart';

class StorePurchaseService implements PurchaseService {
  StorePurchaseService({
    required EntitlementService entitlementService,
    required SupabaseClient? client,
    required AnalyticsService analyticsService,
    InAppPurchase? inAppPurchase,
  }) : _entitlementService = entitlementService,
       _client = client,
       _analyticsService = analyticsService,
       _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final EntitlementService _entitlementService;
  final SupabaseClient? _client;
  final AnalyticsService _analyticsService;
  final InAppPurchase _inAppPurchase;

  final List<PurchaseCatalogItem> _catalog = <PurchaseCatalogItem>[];
  final Map<String, ProductDetails> _detailsById = <String, ProductDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;

  @override
  String get monthlyProductId =>
      AppEnvironment.resolveMonthlyProductIdForCurrentPlatform();

  @override
  List<PurchaseCatalogItem> get catalog =>
      List<PurchaseCatalogItem>.unmodifiable(_catalog);

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (_) {},
    );
    await refreshCatalog();
  }

  @override
  Future<void> refreshCatalog() async {
    _catalog.clear();
    _detailsById.clear();
    final productId = monthlyProductId;
    if (productId.isEmpty) {
      return;
    }
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      return;
    }
    final response = await _inAppPurchase.queryProductDetails(<String>{
      productId,
    });
    if (response.error != null) {
      return;
    }
    for (final detail in response.productDetails) {
      _detailsById[detail.id] = detail;
      _catalog.add(
        PurchaseCatalogItem(
          productId: detail.id,
          title: detail.title,
          description: detail.description,
          price: detail.price,
        ),
      );
    }
  }

  @override
  Future<PurchaseActionResult> purchaseMonthly() async {
    final client = _client;
    if (client?.auth.currentUser == null) {
      return const PurchaseActionResult(
        success: false,
        message: 'Debes iniciar sesion para comprar Premium.',
      );
    }

    final productId = monthlyProductId;
    if (productId.isEmpty) {
      return const PurchaseActionResult(
        success: false,
        message: 'Falta configurar el product ID mensual para esta plataforma.',
      );
    }

    ProductDetails? details = _detailsById[productId];
    if (details == null) {
      await refreshCatalog();
      details = _detailsById[productId];
    }
    if (details == null) {
      return const PurchaseActionResult(
        success: false,
        message: 'No se pudo obtener la suscripcion desde la tienda.',
      );
    }

    await _analyticsService.logPremiumPurchaseStarted(
      productId: productId,
      store: _platformCode(),
      displayPrice: details.price,
    );
    final started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    if (!started) {
      await _analyticsService.logPremiumPurchaseFailed(
        productId: productId,
        reason: 'purchase_not_started',
        store: _platformCode(),
      );
      return const PurchaseActionResult(
        success: false,
        message: 'No se pudo iniciar la compra.',
      );
    }

    return const PurchaseActionResult(
      success: true,
      message: 'Compra iniciada. Confirma en la tienda para continuar.',
    );
  }

  @override
  Future<PurchaseActionResult> restorePurchases() async {
    final client = _client;
    if (client?.auth.currentUser == null) {
      return const PurchaseActionResult(
        success: false,
        message: 'Debes iniciar sesion para restaurar compras.',
      );
    }

    await _analyticsService.logPremiumRestoreStarted(store: _platformCode());
    try {
      await _inAppPurchase.restorePurchases();
      await _entitlementService.refreshPremiumAccess();
      await _syncAnalyticsUserContext();
      await _analyticsService.logPremiumRestoreSuccess(store: _platformCode());
      return const PurchaseActionResult(
        success: true,
        message: 'Restauracion solicitada. Actualizando estado premium...',
      );
    } catch (_) {
      await _analyticsService.logPremiumRestoreFailed(
        store: _platformCode(),
        reason: 'restore_failed',
      );
      return const PurchaseActionResult(
        success: false,
        message: 'No se pudo restaurar la compra en este momento.',
      );
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      try {
        if (purchase.status == PurchaseStatus.pending) {
          continue;
        }

        if (purchase.status == PurchaseStatus.error) {
          await _analyticsService.logPremiumPurchaseFailed(
            productId: purchase.productID,
            reason: purchase.error?.message ?? 'unknown_store_error',
            store: _platformCode(),
          );
        }

        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          final validated = await _validatePurchaseWithBackend(purchase);
          if (validated) {
            await _entitlementService.refreshPremiumAccess();
            await _syncAnalyticsUserContext();
            await _analyticsService.logPremiumPurchaseSuccess(
              productId: purchase.productID,
              store: _platformCode(),
            );
          } else {
            await _analyticsService.logPremiumPurchaseFailed(
              productId: purchase.productID,
              reason: 'backend_validation_failed',
              store: _platformCode(),
            );
          }
        }
      } catch (_) {
        await _analyticsService.logPremiumPurchaseFailed(
          productId: purchase.productID,
          reason: 'purchase_update_processing_failed',
          store: _platformCode(),
        );
      } finally {
        if (purchase.pendingCompletePurchase) {
          try {
            await _inAppPurchase.completePurchase(purchase);
          } catch (_) {}
        }
      }
    }
  }

  Future<bool> _validatePurchaseWithBackend(PurchaseDetails purchase) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      return false;
    }

    try {
      return await _invokePurchaseValidation(purchase);
    } catch (error) {
      if (!_isUnauthorizedFunctionError(error)) {
        return false;
      }

      try {
        await client.auth.refreshSession();
      } catch (_) {
        return false;
      }

      try {
        return await _invokePurchaseValidation(purchase);
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> _invokePurchaseValidation(PurchaseDetails purchase) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return false;
    }
    final verificationData = await _resolveVerificationData(purchase);
    if (verificationData.isEmpty) {
      return false;
    }

    final response = await client.functions.invoke(
      'validate-store-purchase',
      body: <String, dynamic>{
        'userId': user.id,
        'platform': _platformCode(),
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'transactionDate': purchase.transactionDate,
        'verificationData': verificationData,
        'source': purchase.status == PurchaseStatus.restored
            ? 'RESTORE'
            : 'PURCHASE',
      },
    );

    final data = response.data;
    return response.status >= 200 &&
        response.status < 300 &&
        data is Map &&
        data['success'] == true;
  }

  Future<String> _resolveVerificationData(PurchaseDetails purchase) async {
    final verification = purchase.verificationData;
    final serverData = verification.serverVerificationData.trim();

    if (Platform.isIOS && (_looksLikeJws(serverData) || serverData.isEmpty)) {
      try {
        final addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        final refreshed = await addition.refreshPurchaseVerificationData();
        final refreshedData = refreshed?.serverVerificationData.trim() ?? '';
        if (refreshedData.isNotEmpty) {
          return refreshedData;
        }
      } catch (_) {
        // Fallback to purchase-provided verification data.
      }
    }

    if (serverData.isNotEmpty) {
      return serverData;
    }
    return verification.localVerificationData.trim();
  }

  bool _looksLikeJws(String value) {
    if (value.isEmpty) {
      return false;
    }
    final parts = value.split('.');
    return parts.length == 3 && parts.every((part) => part.isNotEmpty);
  }

  bool _isUnauthorizedFunctionError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('status: 401') ||
        text.contains('invalid jwt') ||
        text.contains('unauthorized');
  }

  String _platformCode() {
    if (Platform.isAndroid) {
      return 'PLAY_STORE';
    }
    if (Platform.isIOS) {
      return 'APP_STORE';
    }
    return 'MANUAL';
  }

  Future<void> _syncAnalyticsUserContext() {
    final userId = _client?.auth.currentUser?.id;
    return _analyticsService.syncUserContext(
      isAuthenticated: userId != null,
      isPremium: _entitlementService.hasPremiumAccess(),
      userId: userId,
    );
  }
}
