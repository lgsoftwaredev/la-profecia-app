import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../controllers/suggestions_controller.dart';

final suggestionsControllerProvider =
    ChangeNotifierProvider.autoDispose<SuggestionsController>((ref) {
      final userId = ref.watch(authSessionProvider)?.userId;
      final controller = SuggestionsController(
        service: ref.watch(suggestionsServiceProvider),
        currentUserId: userId,
      );
      ref.onDispose(controller.dispose);
      return controller;
    });
