import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/editable_profile.dart';

final editableProfileProvider = FutureProvider<EditableProfile>((ref) async {
  final session = ref.watch(authSessionProvider);
  final fallbackName = session?.displayName?.trim();
  return ref
      .read(profileServiceProvider)
      .readCurrentProfile(
        fallbackDisplayName: fallbackName != null && fallbackName.isNotEmpty
            ? fallbackName
            : 'Jugador',
      );
});
