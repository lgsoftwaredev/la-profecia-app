import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../domain/entities/match_participant.dart';
import '../../domain/entities/match_session.dart';

enum ActivePlayerNameFallback { selection, turn }

String resolveActivePlayerName({
  required MatchSession? session,
  required GameSetupSubmission submission,
  required int? activeParticipantId,
  required ActivePlayerNameFallback fallback,
}) {
  final fromSessionActive = _nameFromSessionById(session, activeParticipantId);
  if (fromSessionActive != null) {
    return fromSessionActive;
  }

  final fromSubmissionActive = _nameFromSubmissionById(
    submission,
    activeParticipantId,
  );
  if (fromSubmissionActive != null) {
    return fromSubmissionActive;
  }

  if (fallback == ActivePlayerNameFallback.selection) {
    final fromConfigured = _firstConfiguredSubmissionName(submission);
    if (fromConfigured != null) {
      return fromConfigured;
    }

    final fromSessionFirst = _firstSessionParticipantName(session);
    if (fromSessionFirst != null) {
      return fromSessionFirst;
    }
  } else {
    final fromSessionDerived = _sessionDerivedName(session);
    if (fromSessionDerived != null) {
      return fromSessionDerived;
    }

    final fromConfigured = _firstConfiguredSubmissionName(submission);
    if (fromConfigured != null) {
      return fromConfigured;
    }
  }

  return 'Jugador';
}

String? _nameFromSessionById(MatchSession? session, int? participantId) {
  if (session == null || participantId == null) {
    return null;
  }

  for (final participant in session.participants) {
    if (participant.id == participantId) {
      final name = participant.name.trim();
      if (name.isNotEmpty) {
        return name;
      }
      return null;
    }
  }
  return null;
}

String? _nameFromSubmissionById(
  GameSetupSubmission submission,
  int? participantId,
) {
  if (participantId == null) {
    return null;
  }

  for (final player in submission.players) {
    if (player.id == participantId) {
      final name = player.name.trim();
      if (name.isNotEmpty) {
        return name;
      }
      return null;
    }
  }
  return null;
}

String? _firstConfiguredSubmissionName(GameSetupSubmission submission) {
  if (submission.players.isEmpty) {
    return null;
  }

  for (final player in submission.players) {
    final name = player.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
  }

  final first = submission.players.first;
  return 'Jugador ${first.id}';
}

String? _firstSessionParticipantName(MatchSession? session) {
  final participants = session?.participants;
  if (participants == null || participants.isEmpty) {
    return null;
  }

  for (final participant in participants) {
    final name = participant.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
  }

  return _participantFallback(participants.first);
}

String? _sessionDerivedName(MatchSession? session) {
  if (session == null) {
    return null;
  }

  final participants = session.participants;
  if (participants.isEmpty) {
    return null;
  }

  final currentId = session.currentParticipantId;
  for (final participant in participants) {
    if (participant.id != currentId) {
      continue;
    }
    final name = participant.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return _participantFallback(participant);
  }

  return _firstSessionParticipantName(session);
}

String _participantFallback(MatchParticipant participant) {
  return 'Jugador ${participant.id}';
}
