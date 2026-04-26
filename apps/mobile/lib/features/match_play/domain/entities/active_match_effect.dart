class ActiveMatchEffect {
  const ActiveMatchEffect({
    required this.id,
    required this.participantId,
    required this.playerName,
    required this.text,
    required this.turnNumber,
    required this.roundNumber,
    required this.createdAt,
  });

  final String id;
  final int participantId;
  final String playerName;
  final String text;
  final int turnNumber;
  final int roundNumber;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'participantId': participantId,
    'playerName': playerName,
    'text': text,
    'turnNumber': turnNumber,
    'roundNumber': roundNumber,
    'createdAt': createdAt.toIso8601String(),
  };

  static ActiveMatchEffect fromJson(Map<String, dynamic> json) {
    return ActiveMatchEffect(
      id: json['id'] as String,
      participantId: json['participantId'] as int,
      playerName: json['playerName'] as String? ?? 'Jugador',
      text: json['text'] as String? ?? '',
      turnNumber: json['turnNumber'] as int? ?? 0,
      roundNumber: json['roundNumber'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
