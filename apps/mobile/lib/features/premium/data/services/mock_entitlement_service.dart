import '../../domain/services/entitlement_service.dart';

class MockEntitlementService implements EntitlementService {
  MockEntitlementService({bool initialPremium = false})
    : _isPremium = initialPremium;

  bool _isPremium;

  @override
  bool hasPremiumAccess() => _isPremium;

  @override
  Future<void> setPremiumAccess(bool enabled) async {
    _isPremium = enabled;
  }

  @override
  Future<bool> refreshPremiumAccess() async => _isPremium;
}
