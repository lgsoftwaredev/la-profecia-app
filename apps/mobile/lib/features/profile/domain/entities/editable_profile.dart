enum ProfileIdentity {
  man('hombre'),
  woman('mujer'),
  both('ambos');

  const ProfileIdentity(this.storageValue);

  final String storageValue;

  String get label => switch (this) {
    ProfileIdentity.man => 'Hombre',
    ProfileIdentity.woman => 'Mujer',
    ProfileIdentity.both => 'Ambos',
  };

  String get iconAssetPath => switch (this) {
    ProfileIdentity.man => 'assets/logo-icon-genderidentity-men.png',
    ProfileIdentity.woman => 'assets/logo-icon-genderidentity-woman.png',
    ProfileIdentity.both => 'assets/logo-icon-genderidentity-both.png',
  };

  static ProfileIdentity? fromStorage(String? value) {
    return ProfileIdentity.values.cast<ProfileIdentity?>().firstWhere(
      (item) => item?.storageValue == value,
      orElse: () => null,
    );
  }
}

enum ProfileAttraction {
  men('hombres'),
  women('mujeres'),
  both('ambos');

  const ProfileAttraction(this.storageValue);

  final String storageValue;

  String get label => switch (this) {
    ProfileAttraction.men => 'Hombres',
    ProfileAttraction.women => 'Mujeres',
    ProfileAttraction.both => 'Ambos',
  };

  String get iconAssetPath => switch (this) {
    ProfileAttraction.men => 'assets/logo-icon-attraction-men.png',
    ProfileAttraction.women => 'assets/logo-icon-attraction-woman.png',
    ProfileAttraction.both => 'assets/logo-icon-attraction-both.png',
  };

  static ProfileAttraction? fromStorage(String? value) {
    return ProfileAttraction.values.cast<ProfileAttraction?>().firstWhere(
      (item) => item?.storageValue == value,
      orElse: () => null,
    );
  }
}

class EditableProfile {
  const EditableProfile({
    required this.displayName,
    required this.identity,
    required this.attraction,
  });

  final String displayName;
  final ProfileIdentity? identity;
  final ProfileAttraction? attraction;

  EditableProfile copyWith({
    String? displayName,
    ProfileIdentity? identity,
    bool clearIdentity = false,
    ProfileAttraction? attraction,
    bool clearAttraction = false,
  }) {
    return EditableProfile(
      displayName: displayName ?? this.displayName,
      identity: clearIdentity ? null : (identity ?? this.identity),
      attraction: clearAttraction ? null : (attraction ?? this.attraction),
    );
  }
}
