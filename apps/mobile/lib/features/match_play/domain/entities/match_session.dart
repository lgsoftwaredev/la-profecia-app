import '../../../game_mode_selection/domain/entities/game_mode.dart';
import 'match_participant.dart';
import 'match_turn.dart';

enum MatchSessionStatus { active, finished }

class MatchSession {
  const MatchSession({
    required this.id,
    required this.mode,
    required this.participants,
    required this.currentParticipantId,
    required this.roundNumber,
    required this.completedRounds,
    required this.remainingTurnsInRound,
    required this.turnsPlayed,
    required this.status,
    required this.startedAt,
    required this.pendingTurn,
    this.remoteSessionId,
    this.remoteRoundId,
    this.remotePlayerIdsByParticipantId = const <int, String>{},
    this.endedAt,
  });

  final String id;
  final GameMode mode;
  final List<MatchParticipant> participants;
  final int currentParticipantId;
  final int roundNumber;
  final int completedRounds;
  final int remainingTurnsInRound;
  final int turnsPlayed;
  final MatchSessionStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final MatchTurn? pendingTurn;
  final String? remoteSessionId;
  final String? remoteRoundId;
  final Map<int, String> remotePlayerIdsByParticipantId;

  bool get isFinished => status == MatchSessionStatus.finished;

  List<MatchParticipant> get activeParticipants => participants
      .where((participant) => !participant.isEliminated)
      .toList(growable: false);

  MatchParticipant? get authenticatedParticipant {
    for (final participant in participants) {
      if (participant.isAuthenticatedUser) {
        return participant;
      }
    }
    return null;
  }

  int? get authenticatedParticipantId => authenticatedParticipant?.id;

  Map<int, int> get scoresByParticipantId => <int, int>{
    for (final participant in participants) participant.id: participant.score,
  };

  MatchSession copyWith({
    String? id,
    GameMode? mode,
    List<MatchParticipant>? participants,
    int? currentParticipantId,
    int? roundNumber,
    int? completedRounds,
    int? remainingTurnsInRound,
    int? turnsPlayed,
    MatchSessionStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    MatchTurn? pendingTurn,
    String? remoteSessionId,
    String? remoteRoundId,
    Map<int, String>? remotePlayerIdsByParticipantId,
    bool clearPendingTurn = false,
  }) {
    return MatchSession(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      participants: participants ?? this.participants,
      currentParticipantId: currentParticipantId ?? this.currentParticipantId,
      roundNumber: roundNumber ?? this.roundNumber,
      completedRounds: completedRounds ?? this.completedRounds,
      remainingTurnsInRound:
          remainingTurnsInRound ?? this.remainingTurnsInRound,
      turnsPlayed: turnsPlayed ?? this.turnsPlayed,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pendingTurn: clearPendingTurn ? null : (pendingTurn ?? this.pendingTurn),
      remoteSessionId: remoteSessionId ?? this.remoteSessionId,
      remoteRoundId: remoteRoundId ?? this.remoteRoundId,
      remotePlayerIdsByParticipantId:
          remotePlayerIdsByParticipantId ?? this.remotePlayerIdsByParticipantId,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'mode': mode.name,
    'participants': participants.map((item) => item.toJson()).toList(),
    'currentParticipantId': currentParticipantId,
    'roundNumber': roundNumber,
    'completedRounds': completedRounds,
    'remainingTurnsInRound': remainingTurnsInRound,
    'turnsPlayed': turnsPlayed,
    'status': status.name,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'pendingTurn': pendingTurn?.toJson(),
    'remoteSessionId': remoteSessionId,
    'remoteRoundId': remoteRoundId,
    'remotePlayerIdsByParticipantId': remotePlayerIdsByParticipantId.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
  };

  static MatchSession fromJson(Map<String, dynamic> json) {
    return MatchSession(
      id: json['id'] as String,
      mode: GameMode.values.byName(json['mode'] as String),
      participants: (json['participants'] as List<dynamic>)
          .map(
            (item) => MatchParticipant.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      currentParticipantId: json['currentParticipantId'] as int,
      roundNumber: json['roundNumber'] as int,
      completedRounds: json['completedRounds'] as int,
      remainingTurnsInRound: json['remainingTurnsInRound'] as int,
      turnsPlayed: json['turnsPlayed'] as int,
      status: MatchSessionStatus.values.byName(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      pendingTurn: json['pendingTurn'] == null
          ? null
          : MatchTurn.fromJson(json['pendingTurn'] as Map<String, dynamic>),
      remoteSessionId: json['remoteSessionId'] as String?,
      remoteRoundId: json['remoteRoundId'] as String?,
      remotePlayerIdsByParticipantId:
          (json['remotePlayerIdsByParticipantId'] as Map<String, dynamic>?)
              ?.map(
                (key, value) => MapEntry(int.parse(key), value as String),
              ) ??
          const <int, String>{},
    );
  }
}
