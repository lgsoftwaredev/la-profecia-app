import 'package:flutter/foundation.dart';

import '../../domain/entities/suggestion.dart';
import '../../domain/services/suggestions_service.dart';

class SuggestionsController extends ChangeNotifier {
  SuggestionsController({
    required SuggestionsService service,
    required String? currentUserId,
  }) : _service = service,
       _currentUserId = currentUserId;

  final SuggestionsService _service;
  final String? _currentUserId;

  bool _loading = false;
  String? _message;

  bool get isLoading => _loading;
  String? get message => _message;

  Future<bool> submit({
    required SuggestionType type,
    required String content,
  }) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _message = 'Debes iniciar sesion para enviar sugerencias.';
      notifyListeners();
      return false;
    }
    _loading = true;
    _message = null;
    notifyListeners();
    try {
      await _service.submit(
        userId: userId,
        draft: SuggestionDraft(type: type, content: content),
      );
      _loading = false;
      _message = 'Sugerencia enviada. Quedo en revision.';
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _message = error.toString().replaceFirst('StateError: ', '');
      notifyListeners();
      return false;
    }
  }
}
