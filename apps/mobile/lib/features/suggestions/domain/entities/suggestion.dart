enum SuggestionType { question, challenge }

extension SuggestionTypeX on SuggestionType {
  String get label => switch (this) {
    SuggestionType.question => 'Pregunta',
    SuggestionType.challenge => 'Reto',
  };

  String get dbValue => switch (this) {
    SuggestionType.question => 'QUESTION',
    SuggestionType.challenge => 'CHALLENGE',
  };
}

class SuggestionDraft {
  const SuggestionDraft({required this.type, required this.content});

  final SuggestionType type;
  final String content;
}
