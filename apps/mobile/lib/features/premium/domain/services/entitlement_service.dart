abstract class EntitlementService {
  bool hasPremiumAccess();
  Future<void> setPremiumAccess(bool enabled);
  Future<bool> refreshPremiumAccess();
}
