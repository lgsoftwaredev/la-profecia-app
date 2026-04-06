import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/supabase_auth_datasource.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/match_play/data/datasources/supabase_content_datasource.dart';
import '../../features/match_play/data/datasources/supabase_history_datasource.dart';
import '../../features/match_play/data/datasources/supabase_match_datasource.dart';
import '../../features/match_play/data/repositories/hybrid_active_match_repository.dart';
import '../../features/match_play/data/repositories/hybrid_game_history_repository.dart';
import '../../features/match_play/data/repositories/local_active_match_repository.dart';
import '../../features/match_play/data/repositories/mock_game_history_repository.dart';
import '../../features/match_play/data/repositories/supabase_couples_content_repository.dart';
import '../../features/match_play/data/repositories/supabase_friends_content_repository.dart';
import '../../features/match_play/domain/services/game_engine.dart';
import '../../features/match_play/presentation/controllers/match_controller.dart';
import '../../features/premium/data/services/mock_entitlement_service.dart';
import '../../features/premium/data/services/supabase_entitlement_service.dart';
import '../../features/premium/domain/services/entitlement_service.dart';

class AppScope {
  AppScope._({
    required this.authController,
    required this.matchController,
    required this.entitlementService,
  });

  static late final AppScope I;

  final AuthController authController;
  final MatchController matchController;
  final EntitlementService entitlementService;

  static Future<AppScope> bootstrap() async {
    final url = _resolveSupabaseUrl();
    final anonKey = _resolveSupabaseAnonKey();

    SupabaseClient? client;
    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: anonKey);
      client = Supabase.instance.client;
    }

    final preferences = await SharedPreferences.getInstance();

    final authDataSource = SupabaseAuthDataSource(
      client: client,
      googleServerClientId: _resolveGoogleServerClientId(),
      googleIosClientId: _resolveGoogleIosClientId(),
    );

    final authController = AuthController(
      SupabaseAuthRepository(authDataSource),
    );

    final localActiveRepository = LocalActiveMatchRepository(preferences);
    final localHistoryRepository = MockGameHistoryRepository(preferences);
    final remoteMatchDataSource = SupabaseMatchDataSource(client: client);
    final remoteHistoryDataSource = SupabaseHistoryDataSource(client: client);
    final remoteContentDataSource = SupabaseContentDataSource(client: client);

    final entitlementService = client == null
        ? MockEntitlementService(
            initialPremium:
                const String.fromEnvironment('MOCK_PREMIUM') == 'true',
          )
        : SupabaseEntitlementService(client: client);

    final matchController = MatchController(
      engine: GameEngine(),
      activeMatchRepository: HybridActiveMatchRepository(
        localRepository: localActiveRepository,
        remoteDataSource: remoteMatchDataSource,
        client: client,
      ),
      friendsContentRepository: SupabaseFriendsContentRepository(
        remoteContentDataSource,
      ),
      couplesContentRepository: SupabaseCouplesContentRepository(
        remoteContentDataSource,
      ),
      historyRepository: HybridGameHistoryRepository(
        localRepository: localHistoryRepository,
        remoteDataSource: remoteHistoryDataSource,
        client: client,
      ),
      entitlementService: entitlementService,
    );

    final scope = AppScope._(
      authController: authController,
      matchController: matchController,
      entitlementService: entitlementService,
    );

    I = scope;
    await scope.authController.initialize();
    try {
      await scope.entitlementService.refreshPremiumAccess();
    } catch (_) {}
    scope.authController.addListener(() {
      Future<void>(() async {
        try {
          await scope.entitlementService.refreshPremiumAccess();
        } catch (_) {}
      });
    });
    await scope.matchController.restoreActiveMatch();

    return scope;
  }

  static String _resolveSupabaseUrl() {
    final fromDefine = const String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String _resolveSupabaseAnonKey() {
    final fromDefine = const String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String _resolveGoogleServerClientId() {
    final fromDefine = const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
  }

  static String _resolveGoogleIosClientId() {
    final fromDefine = const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
  }
}
