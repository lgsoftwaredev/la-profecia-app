import '../../../../core/services/analytics_service.dart';
import '../entities/suggestion.dart';
import '../repositories/suggestions_repository.dart';

class SuggestionsService {
  SuggestionsService({
    required SuggestionsRepository repository,
    required AnalyticsService analyticsService,
  }) : _repository = repository,
       _analyticsService = analyticsService;

  final SuggestionsRepository _repository;
  final AnalyticsService _analyticsService;

  Future<void> submit({
    required String userId,
    required SuggestionDraft draft,
  }) async {
    final content = draft.content.trim();
    if (content.length < 8) {
      throw StateError('Escribe una propuesta un poco mas detallada.');
    }
    if (content.length > 500) {
      throw StateError('La propuesta no puede superar 500 caracteres.');
    }

    await _repository.submitSuggestion(userId: userId, draft: draft);
    await _analyticsService.logSuggestionSubmitted(
      type: draft.type.dbValue,
      contentLength: content.length,
    );
  }
}
