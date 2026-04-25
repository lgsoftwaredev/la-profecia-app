import '../entities/editable_profile.dart';

abstract class ProfileService {
  Future<EditableProfile> readCurrentProfile({
    required String fallbackDisplayName,
  });

  Future<EditableProfile> updateCurrentProfile({
    required String displayName,
    required ProfileIdentity identity,
    required ProfileAttraction attraction,
  });
}
