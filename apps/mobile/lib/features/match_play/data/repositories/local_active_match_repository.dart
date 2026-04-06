import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/repositories/active_match_repository.dart';

class LocalActiveMatchRepository implements ActiveMatchRepository {
  LocalActiveMatchRepository(this._preferences);

  static const String _storageKey = 'active_match_v1';

  final SharedPreferences _preferences;

  @override
  Future<MatchSession> save(MatchSession session) async {
    final payload = jsonEncode(session.toJson());
    await _preferences.setString(_storageKey, payload);
    return session;
  }

  @override
  Future<MatchSession?> loadActive() async {
    final payload = _preferences.getString(_storageKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }

    final json = jsonDecode(payload) as Map<String, dynamic>;
    return MatchSession.fromJson(json);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_storageKey);
  }

  @override
  Future<void> persistFinalResult({
    required MatchSession session,
    required MatchFinalResult result,
  }) async {}

  @override
  Future<void> persistFinalPenalty({
    required MatchSession session,
    required String penaltyText,
  }) async {}
}
