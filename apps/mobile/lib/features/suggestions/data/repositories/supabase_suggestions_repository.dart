import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/suggestions_repository.dart';

class SupabaseSuggestionsRepository implements SuggestionsRepository {
  const SupabaseSuggestionsRepository({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  @override
  Future<void> submitSuggestion({
    required String userId,
    required SuggestionDraft draft,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase no esta configurado.');
    }
    await client.from('UserSubmission').insert(<String, dynamic>{
      'userId': userId,
      'type': draft.type.dbValue,
      'contentText': draft.content.trim(),
      'status': 'PENDING',
    });
  }
}
