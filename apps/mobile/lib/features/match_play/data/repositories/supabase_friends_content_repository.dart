import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/repositories/friends_content_repository.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../datasources/supabase_content_datasource.dart';

class SupabaseFriendsContentRepository implements FriendsContentRepository {
  SupabaseFriendsContentRepository(this._dataSource);

  final SupabaseContentDataSource _dataSource;

  @override
  Future<GamePrompt> pickPrompt({
    required MatchLevel level,
    required MatchPromptKind kind,
  }) {
    return _dataSource.pickPrompt(
      mode: GameMode.friends,
      level: level,
      kind: kind,
    );
  }
}
