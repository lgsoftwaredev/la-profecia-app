import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  const AppRouter._();

  static Future<void> openProfileGuarded(
    BuildContext context, {
    bool replace = false,
  }) async {
    await openGuarded(
      context,
      builder: (_) => const ProfilePage(),
      replace: replace,
    );
  }

  static Future<void> openGuarded(
    BuildContext context, {
    required WidgetBuilder builder,
    bool replace = false,
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

    final route = MaterialPageRoute<void>(builder: builder);
    if (replace) {
      await Navigator.of(context).pushReplacement(route);
      return;
    }
    await Navigator.of(context).push(route);
  }
}
