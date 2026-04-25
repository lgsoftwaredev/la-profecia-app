import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/editable_profile.dart';
import '../../domain/services/profile_service.dart';

class UnavailableProfileService implements ProfileService {
  const UnavailableProfileService();

  @override
  Future<EditableProfile> readCurrentProfile({
    required String fallbackDisplayName,
  }) async {
    throw const AppFailure('Servicio de perfil no disponible.');
  }

  @override
  Future<EditableProfile> updateCurrentProfile({
    required String displayName,
    required ProfileIdentity identity,
    required ProfileAttraction attraction,
  }) async {
    throw const AppFailure('Servicio de perfil no disponible.');
  }
}
