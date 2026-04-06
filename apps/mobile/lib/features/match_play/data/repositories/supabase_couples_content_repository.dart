import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/repositories/couples_content_repository.dart';
import '../datasources/supabase_content_datasource.dart';

class SupabaseCouplesContentRepository implements CouplesContentRepository {
  SupabaseCouplesContentRepository(this._dataSource);

  final SupabaseContentDataSource _dataSource;

  @override
  Future<GamePrompt> pickPrompt({
    required MatchLevel level,
    required MatchPromptKind kind,
  }) {
    return _dataSource.pickPrompt(
      mode: GameMode.couples,
      level: level,
      kind: kind,
    );
  }
}
