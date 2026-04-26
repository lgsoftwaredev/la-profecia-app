import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/active_match_effect.dart';

class CurrentEffectsSlideButton extends StatelessWidget {
  const CurrentEffectsSlideButton({
    required this.expanded,
    required this.hasEffects,
    required this.onTap,
    super.key,
  });

  final bool expanded;
  final bool hasEffects;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: expanded ? 154 : 56,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            border: Border.all(
              color: hasEffects
                  ? const Color(0xFF95C6FF)
                  : const Color(0x6695C6FF),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E2739), Color(0xFF101724)],
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/logo-icon-current-effects.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              if (expanded) ...[
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    hasEffects ? 'Efectos vigentes' : 'Sin efectos',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 13.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentEffectsDialog extends StatelessWidget {
  const CurrentEffectsDialog({required this.effects, super.key});

  final List<ActiveMatchEffect> effects;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 470, maxHeight: 610),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xEE151A25), Color(0xEE090B10)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.54),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo-icon-current-effects.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Efectos vigentes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontWeight: FontWeight.w700,
                        fontSize: 30 * 0.62,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Image.asset(
                      'assets/logo-icon-cancel.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
            Expanded(
              child: effects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          'Todavia no hay efectos activos en esta partida.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.74),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      itemCount: effects.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: Colors.white.withValues(alpha: 0.08)),
                      itemBuilder: (context, index) {
                        final effect = effects[index];
                        final color = _effectColor(index);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 10),
                              child: Image.asset(
                                'assets/logo-icon-turn-checked.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.90,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 22 * 0.62,
                                        height: 1.24,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: effect.playerName,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(text: ' '),
                                    TextSpan(text: effect.text),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _effectColor(int index) {
    const colors = <Color>[
      Color(0xFF42AAFF),
      Color(0xFF3ED45F),
      Color(0xFFE8A241),
      Color(0xFFE76F55),
      Color(0xFF8DDC4D),
    ];
    return colors[index % colors.length];
  }
}
