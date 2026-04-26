import 'package:flutter/material.dart';

class MatchTimerChip extends StatelessWidget {
  const MatchTimerChip({
    required this.seconds,
    required this.accent,
    this.onTap,
    super.key,
  });

  final int seconds;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = _formatDuration(seconds);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(
                  accent,
                  const Color(0xFF315B7E),
                  0.72,
                )!.withValues(alpha: 0.94),
                const Color(0xFF14263A).withValues(alpha: 0.94),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.78),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.30),
                blurRadius: 18,
                spreadRadius: 0.8,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(-2, 0),
                child: Image.asset(
                  'assets/logo-icon-timer.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withValues(alpha: 0.96),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '00:${seconds.toString().padLeft(2, '0')}';
    }
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
