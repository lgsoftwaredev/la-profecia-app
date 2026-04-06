import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';

final premiumAccessProvider = NotifierProvider<PremiumAccessNotifier, bool>(
  PremiumAccessNotifier.new,
);

class PremiumAccessNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future<void>(() async {
      await refresh();
    });
    return ref.read(entitlementServiceProvider).hasPremiumAccess();
  }

  Future<void> setEnabled(bool enabled) async {
    final service = ref.read(entitlementServiceProvider);
    await service.setPremiumAccess(enabled);
    state = service.hasPremiumAccess();
  }

  Future<void> refresh() async {
    final service = ref.read(entitlementServiceProvider);
    final value = await service.refreshPremiumAccess();
    state = value;
  }
}
