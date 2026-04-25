import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../match_play/presentation/widgets/final_group_challenge_mode_page.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../domain/entities/suggestion.dart';

class SuggestionComposeFinalGroupPage extends ConsumerWidget {
  const SuggestionComposeFinalGroupPage({required this.type, super.key});

  final SuggestionType type;

  static const _submission = GameSetupSubmission(
    mode: GameMode.friends,
    players: <PlayerConfig>[],
    pairs: <List<PlayerConfig>>[],
    enabledThemes: <GameStyleTheme>[GameStyleTheme.cielo],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FinalGroupChallengeModePage(
      submission: _submission,
      punishedLabel: 'Moderación',
      titleText: 'Proponer contenido',
      subtitleText:
          'Tu ${type.label.toLowerCase()} quedará pendiente\nde revisión.',
      actorLabelText: 'Moderación',
      inputHintText: type == SuggestionType.question
          ? 'Escribe tu pregunta'
          : 'Escribe tu reto',
      showReplayActions: false,
      showDefaultFailureMessage: false,
      onSuccessTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      onSendTap: (text) async {
        final session = ref.read(authSessionProvider);
        final userId = session?.userId;
        if (userId == null || userId.isEmpty) {
          return false;
        }
        try {
          await ref
              .read(suggestionsServiceProvider)
              .submit(
                userId: userId,
                draft: SuggestionDraft(type: type, content: text),
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sugerencia enviada. Quedó en revisión.'),
              ),
            );
          }
          return true;
        } catch (error) {
          if (context.mounted) {
            final message = _cleanErrorMessage(error);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          return false;
        }
      },
    );
  }

  String _cleanErrorMessage(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('StateError: ')) {
      return raw.replaceFirst('StateError: ', '').trim();
    }
    if (raw.startsWith('Bad state: ')) {
      return raw.replaceFirst('Bad state: ', '').trim();
    }
    return raw;
  }
}
