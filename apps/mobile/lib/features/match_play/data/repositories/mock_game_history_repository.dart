import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../profile/domain/entities/user_stats_summary.dart';
import '../../domain/repositories/game_history_repository.dart';

class MockGameHistoryRepository implements GameHistoryRepository {
  MockGameHistoryRepository(this._preferences);

  static const String _storageKey = 'game_history_v1';

  final SharedPreferences _preferences;

  @override
  Future<void> registerFinishedMatch({
    required String sessionId,
    required DateTime playedAt,
    required String resultLabel,
    required int scoreDelta,
    required bool won,
    String? headline,
  }) async {
    final items = _loadItems();
    items.add(<String, dynamic>{
      'sessionId': sessionId,
      'playedAt': playedAt.toIso8601String(),
      'resultLabel': resultLabel,
      'scoreDelta': scoreDelta,
      'won': won,
      'headline': headline,
    });

    await _preferences.setString(_storageKey, jsonEncode(items));
  }

  @override
  Future<UserStatsSummary> readSummary() async {
    final items = _loadItems();
    var accumulatedScore = 0;
    var wins = 0;
    var losses = 0;
    final history = <GameHistoryItem>[];

    for (final item in items) {
      final scoreDelta = item['scoreDelta'] as int? ?? 0;
      accumulatedScore += scoreDelta;
      final won = item['won'] as bool? ?? false;
      if (won) {
        wins += 1;
      } else {
        losses += 1;
      }

      history.add(
        GameHistoryItem(
          sessionId: item['sessionId'] as String,
          playedAt: DateTime.parse(item['playedAt'] as String),
          resultLabel: item['resultLabel'] as String,
          scoreDelta: scoreDelta,
          headline: item['headline'] as String?,
        ),
      );
    }

    history.sort((a, b) => b.playedAt.compareTo(a.playedAt));

    return UserStatsSummary(
      matchesPlayed: items.length,
      accumulatedScore: accumulatedScore,
      wins: wins,
      losses: losses,
      history: history,
    );
  }

  List<Map<String, dynamic>> _loadItems() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: true);
  }
}
