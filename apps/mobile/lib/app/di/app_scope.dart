import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_environment.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/push_notification_service.dart';
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
import '../../features/premium/data/services/store_purchase_service.dart';
import '../../features/premium/data/services/supabase_entitlement_service.dart';
import '../../features/premium/domain/services/entitlement_service.dart';
import '../../features/premium/domain/services/purchase_service.dart';
import '../../features/suggestions/data/repositories/supabase_suggestions_repository.dart';
import '../../features/suggestions/domain/services/suggestions_service.dart';

class AppScope {
  AppScope._({
    required this.authController,
    required this.matchController,
    required this.entitlementService,
    required this.purchaseService,
    required this.analyticsService,
    required this.pushNotificationService,
    required this.adService,
    required this.suggestionsService,
  });

  static late final AppScope I;

  final AuthController authController;
  final MatchController matchController;
  final EntitlementService entitlementService;
  final PurchaseService purchaseService;
  final AnalyticsService analyticsService;
  final PushNotificationService pushNotificationService;
  final AdService adService;
  final SuggestionsService suggestionsService;

  static Future<AppScope> bootstrap() async {
    final url = AppEnvironment.supabaseUrl;
    final anonKey = AppEnvironment.supabaseAnonKey;

    SupabaseClient? client;
    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: anonKey);
      client = Supabase.instance.client;
    }

    final preferences = await SharedPreferences.getInstance();

    final authDataSource = SupabaseAuthDataSource(
      client: client,
      googleServerClientId: AppEnvironment.googleServerClientId,
      googleIosClientId: AppEnvironment.googleIosClientId,
    );

    final authController = AuthController(
      SupabaseAuthRepository(authDataSource),
    );

    final localActiveRepository = LocalActiveMatchRepository(preferences);
    final localHistoryRepository = MockGameHistoryRepository(preferences);
    final remoteMatchDataSource = SupabaseMatchDataSource(client: client);
    final remoteHistoryDataSource = SupabaseHistoryDataSource(client: client);
    final remoteContentDataSource = SupabaseContentDataSource(client: client);

    final analyticsService = AnalyticsService();
    await analyticsService.initialize();

    final entitlementService = client == null
        ? MockEntitlementService(
            initialPremium:
                const String.fromEnvironment('MOCK_PREMIUM') == 'true',
          )
        : SupabaseEntitlementService(client: client);
    final purchaseService = StorePurchaseService(
      entitlementService: entitlementService,
      client: client,
      analyticsService: analyticsService,
    );
    final suggestionsService = SuggestionsService(
      repository: SupabaseSuggestionsRepository(client: client),
      analyticsService: analyticsService,
    );
    final pushNotificationService = PushNotificationService(
      preferences: preferences,
      client: client,
    );
    final adService = AdService(entitlementService: entitlementService);

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
      analyticsService: analyticsService,
    );

    final scope = AppScope._(
      authController: authController,
      matchController: matchController,
      entitlementService: entitlementService,
      purchaseService: purchaseService,
      analyticsService: analyticsService,
      pushNotificationService: pushNotificationService,
      adService: adService,
      suggestionsService: suggestionsService,
    );

    I = scope;
    await scope.authController.initialize();
    await scope.purchaseService.initialize();
    try {
      await scope.entitlementService.refreshPremiumAccess();
    } catch (_) {}
    await scope.pushNotificationService.initialize(
      currentUserId: scope.authController.session?.userId,
    );
    await scope.adService.initialize();
    await scope.analyticsService.syncUserContext(
      isAuthenticated: scope.authController.isAuthenticated,
      isPremium: scope.entitlementService.hasPremiumAccess(),
      userId: scope.authController.session?.userId,
    );
    await scope.analyticsService.logAppOpen();
    scope.authController.addListener(() {
      Future<void>(() async {
        try {
          await scope.entitlementService.refreshPremiumAccess();
        } catch (_) {}
        await scope.pushNotificationService.syncForCurrentUser(
          scope.authController.session?.userId,
        );
        await scope.analyticsService.syncUserContext(
          isAuthenticated: scope.authController.isAuthenticated,
          isPremium: scope.entitlementService.hasPremiumAccess(),
          userId: scope.authController.session?.userId,
        );
      });
    });
    await scope.matchController.restoreActiveMatch();

    return scope;
  }
}
