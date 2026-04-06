import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/services/entitlement_service.dart';

class SupabaseEntitlementService implements EntitlementService {
  SupabaseEntitlementService({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;
  bool _hasPremium = false;

  @override
  bool hasPremiumAccess() => _hasPremium;

  @override
  Future<void> setPremiumAccess(bool enabled) async {
    _hasPremium = enabled;
  }

  @override
  Future<bool> refreshPremiumAccess() async {
    final client = _client;
    if (client == null) {
      _hasPremium = false;
      return _hasPremium;
    }

    final user = client.auth.currentUser;
    if (user == null) {
      _hasPremium = false;
      return _hasPremium;
    }

    final rows = await client
        .from('PremiumAccess')
        .select('status,expiresAt')
        .eq('userId', user.id)
        .inFilter('status', <String>['ACTIVE', 'TRIAL']);

    final now = DateTime.now().toUtc();
    var enabled = false;
    for (final row in rows) {
      final item = row;
      final expiresAtRaw = item['expiresAt'] as String?;
      if (expiresAtRaw == null || expiresAtRaw.isEmpty) {
        enabled = true;
        break;
      }

      final expiresAt = DateTime.tryParse(expiresAtRaw)?.toUtc();
      if (expiresAt == null || expiresAt.isAfter(now)) {
        enabled = true;
        break;
      }
    }

    _hasPremium = enabled;
    return _hasPremium;
  }
}
