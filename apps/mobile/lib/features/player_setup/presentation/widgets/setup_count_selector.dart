import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'stepper_action_button.dart';

class SetupCountSelector extends StatelessWidget {
  const SetupCountSelector({
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required this.canIncrement,
    required this.canDecrement,
    super.key,
  });

  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    final countTextStyle = Theme.of(
      context,
    ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepperActionButton(
          icon: Icons.remove_rounded,
          enabled: canDecrement,
          onTap: onDecrement,
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 56,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: countTextStyle,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        StepperActionButton(
          icon: Icons.add_rounded,
          enabled: canIncrement,
          onTap: onIncrement,
        ),
      ],
    );
  }
}
