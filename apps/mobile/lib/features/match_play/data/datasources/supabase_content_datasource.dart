import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';

class SupabaseContentDataSource {
  SupabaseContentDataSource({required SupabaseClient? client, Random? random})
    : _client = client,
      _random = random ?? Random();

  final SupabaseClient? _client;
  final Random _random;

  Map<String, int>? _modeIdsByCode;
  Map<String, int>? _levelIdsByCode;

  Future<GamePrompt> pickPrompt({
    required GameMode mode,
    required MatchLevel level,
    required MatchPromptKind kind,
  }) async {
    final client = _requiredClient();
    await _warmLookups(client);

    final modeCode = _modeCode(mode);
    final levelCode = _levelCode(level);
    final modeId = _modeIdsByCode?[modeCode];
    final levelId = _levelIdsByCode?[levelCode];
    if (modeId == null || levelId == null) {
      throw const AppFailure('No se pudo resolver catalogo de contenido.');
    }

    final table = kind == MatchPromptKind.question ? 'Question' : 'Challenge';
    final rows = await client
        .from(table)
        .select('id,text,variables,timerSeconds,hasMatchEffect')
        .eq('modeId', modeId)
        .eq('levelId', levelId)
        .eq('isActive', true);
    if (rows.isEmpty) {
      throw const AppFailure(
        'No hay contenido disponible para el modo y nivel seleccionados.',
      );
    }

    final selected = rows[_random.nextInt(rows.length)];
    final remoteContentId = _asInt(selected['id']);
    final text = selected['text'] as String?;
    final timerSeconds = _asInt(selected['timerSeconds']);
    final hasMatchEffect = selected['hasMatchEffect'] == true;
    final templateTokens = _readTemplateTokens(selected['variables']);
    if (remoteContentId == null || text == null || text.trim().isEmpty) {
      throw const AppFailure(
        'Contenido con formato inválido. Verifica integridad de datos y permisos.',
      );
    }

    return GamePrompt(
      id: '$table-$remoteContentId',
      text: text,
      level: level,
      kind: kind,
      remoteContentId: remoteContentId,
      templateTokens: templateTokens,
      timerSeconds: timerSeconds,
      hasMatchEffect: hasMatchEffect,
    );
  }

  SupabaseClient _requiredClient() {
    final client = _client;
    if (client == null) {
      throw const AppFailure('Servicio de contenido no disponible.');
    }
    return client;
  }

  Future<void> _warmLookups(SupabaseClient client) async {
    if (_modeIdsByCode != null && _levelIdsByCode != null
        ? _modeIdsByCode!.isNotEmpty && _levelIdsByCode!.isNotEmpty
        : false) {
      return;
    }

    final modeRows = await client.from('GameMode').select('id,code');
    final levelRows = await client.from('Level').select('id,code');
    if (modeRows.isEmpty || levelRows.isEmpty) {
      throw const AppFailure(
        'Catalogo de contenido incompleto. Verifica integridad de datos y permisos.',
      );
    }

    final modeMap = <String, int>{};
    for (final row in modeRows as List<dynamic>) {
      final map = row as Map<String, dynamic>;
      final code = map['code'] as String?;
      final id = _asInt(map['id']);
      if (code != null && id != null) {
        modeMap[code] = id;
      }
    }

    final levelMap = <String, int>{};
    for (final row in levelRows as List<dynamic>) {
      final map = row as Map<String, dynamic>;
      final code = map['code'] as String?;
      final id = _asInt(map['id']);
      if (code != null && id != null) {
        levelMap[code] = id;
      }
    }

    const expectedModes = <String>{'FRIENDS', 'COUPLES'};
    const expectedLevels = <String>{
      'CIELO',
      'TIERRA',
      'INFIERNO',
      'INFRAMUNDO',
    };
    final missingModes = expectedModes.difference(modeMap.keys.toSet());
    final missingLevels = expectedLevels.difference(levelMap.keys.toSet());
    if (missingModes.isNotEmpty || missingLevels.isNotEmpty) {
      final modesLabel = missingModes.isEmpty ? '-' : missingModes.join(', ');
      final levelsLabel = missingLevels.isEmpty
          ? '-'
          : missingLevels.join(', ');
      throw AppFailure(
        'Catalogo incompleto. Modos faltantes: $modesLabel. Niveles faltantes: $levelsLabel.',
      );
    }

    _modeIdsByCode = modeMap;
    _levelIdsByCode = levelMap;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  List<String> _readTemplateTokens(Object? value) {
    if (value is! Map) {
      return const <String>[];
    }
    final tokensRaw = value['tokens'];
    if (tokensRaw is! List) {
      return const <String>[];
    }

    final tokens = <String>[];
    for (final item in tokensRaw) {
      if (item is String && item.trim().isNotEmpty) {
        tokens.add(item.trim());
      }
    }
    return tokens;
  }

  String _modeCode(GameMode mode) {
    return switch (mode) {
      GameMode.friends => 'FRIENDS',
      GameMode.couples => 'COUPLES',
    };
  }

  String _levelCode(MatchLevel level) {
    return switch (level) {
      MatchLevel.cielo => 'CIELO',
      MatchLevel.tierra => 'TIERRA',
      MatchLevel.infierno => 'INFIERNO',
      MatchLevel.inframundo => 'INFRAMUNDO',
    };
  }
}
