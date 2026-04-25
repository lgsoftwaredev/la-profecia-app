import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class PremiumSlideButton extends StatelessWidget {
  const PremiumSlideButton({
    required this.expanded,
    required this.onTap,
    this.isPremium = true,
    super.key,
  });

  final bool expanded;
  final VoidCallback onTap;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final labelColor = isPremium
        ? const Color(0xFFF6A117)
        : Colors.white.withValues(alpha: 0.92);
    final labelText = isPremium ? 'Premium' : 'Hazte premium';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: expanded ? 132 : 56,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            border: Border.all(color: const Color(0xCCBB7605), width: 1.1),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1C22), Color(0xFF1A1016)],
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/premium-icon-logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              if (expanded) ...[
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    labelText,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: labelColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
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
