import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  const AppRouter._();

  static Future<void> openProfileGuarded(BuildContext context) async {
    await openGuarded(context, builder: (_) => const ProfilePage());
  }

  static Future<void> openGuarded(
    BuildContext context, {
    required WidgetBuilder builder,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);
    if (!container.read(isAuthenticatedProvider)) {
      final didLogin = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));

      if (didLogin != true ||
          !container.read(isAuthenticatedProvider) ||
          !context.mounted) {
        return;
      }
    }

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }
}
