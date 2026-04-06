class MatchParticipant {
  const MatchParticipant({
    required this.id,
    required this.name,
    this.pairIndex,
    this.authUserId,
    this.isAuthenticatedUser = false,
    this.score = 0,
    this.isEliminated = false,
  });

  final int id;
  final String name;
  final int? pairIndex;
  final String? authUserId;
  final bool isAuthenticatedUser;
  final int score;
  final bool isEliminated;

  MatchParticipant copyWith({
    int? id,
    String? name,
    int? pairIndex,
    String? authUserId,
    bool? isAuthenticatedUser,
    int? score,
    bool? isEliminated,
  }) {
    return MatchParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      pairIndex: pairIndex ?? this.pairIndex,
      authUserId: authUserId ?? this.authUserId,
      isAuthenticatedUser: isAuthenticatedUser ?? this.isAuthenticatedUser,
      score: score ?? this.score,
      isEliminated: isEliminated ?? this.isEliminated,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'pairIndex': pairIndex,
    'authUserId': authUserId,
    'isAuthenticatedUser': isAuthenticatedUser,
    'score': score,
    'isEliminated': isEliminated,
  };

  static MatchParticipant fromJson(Map<String, dynamic> json) {
    return MatchParticipant(
      id: json['id'] as int,
      name: json['name'] as String,
      pairIndex: json['pairIndex'] as int?,
      authUserId: json['authUserId'] as String?,
      isAuthenticatedUser: json['isAuthenticatedUser'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      isEliminated: json['isEliminated'] as bool? ?? false,
    );
  }
}
