import '../entities/suggestion.dart';

abstract class SuggestionsRepository {
  Future<void> submitSuggestion({
    required String userId,
    required SuggestionDraft draft,
  });
}
