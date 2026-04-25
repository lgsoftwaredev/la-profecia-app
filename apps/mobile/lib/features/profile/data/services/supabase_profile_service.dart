import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/editable_profile.dart';
import '../../domain/services/profile_service.dart';

class SupabaseProfileService implements ProfileService {
  const SupabaseProfileService({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  Future<EditableProfile> readCurrentProfile({
    required String fallbackDisplayName,
  }) async {
    final userId = _requireUserId();

    try {
      final profileRow = await _client
          .from('Profile')
          .select('displayName')
          .eq('id', userId)
          .maybeSingle();

      final preferenceRow = await _client
          .from('UserPreference')
          .select('genderIdentity,attractionTarget')
          .eq('userId', userId)
          .maybeSingle();

      final displayName = (profileRow?['displayName'] as String?)?.trim() ?? '';

      return EditableProfile(
        displayName: displayName.isNotEmpty ? displayName : fallbackDisplayName,
        identity: ProfileIdentity.fromStorage(
          preferenceRow?['genderIdentity'] as String?,
        ),
        attraction: ProfileAttraction.fromStorage(
          preferenceRow?['attractionTarget'] as String?,
        ),
      );
    } catch (_) {
      throw const AppFailure('No se pudo cargar tu perfil.');
    }
  }

  @override
  Future<EditableProfile> updateCurrentProfile({
    required String displayName,
    required ProfileIdentity identity,
    required ProfileAttraction attraction,
  }) async {
    final userId = _requireUserId();
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      throw const AppFailure('Ingresa un nombre valido.');
    }

    try {
      await _client.from('Profile').upsert(<String, dynamic>{
        'id': userId,
        'displayName': normalizedName,
      }, onConflict: 'id');

      await _client.from('UserPreference').upsert(<String, dynamic>{
        'userId': userId,
        'genderIdentity': identity.storageValue,
        'attractionTarget': attraction.storageValue,
      }, onConflict: 'userId');

      try {
        await _client.auth.updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'full_name': normalizedName,
              'name': normalizedName,
            },
          ),
        );
      } catch (_) {}

      return EditableProfile(
        displayName: normalizedName,
        identity: identity,
        attraction: attraction,
      );
    } catch (_) {
      throw const AppFailure('No se pudo actualizar tu perfil.');
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppFailure('Se requiere sesion autenticada.');
    }
    return userId;
  }
}
