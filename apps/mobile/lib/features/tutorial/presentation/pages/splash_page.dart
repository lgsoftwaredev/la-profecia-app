import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'tutorial_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _messages = [
    'Prepárate… las preguntas que vienen pueden cambiar tu noche.',
    'Las cartas más virales de Internet están a punto de aparecer.',
    'Elige bien tus respuestas porque puedes perder tu relación o amistad.',
    'Lo que pase en La Profecía… difícilmente se olvida.',
    'Aquí nadie se salva. Algunos retos no son para cobardes.',
  ];

  final Random _random = Random();
  Timer? _navigationTimer;
  Timer? _messageTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(_messages.length);
    _navigationTimer = Timer(const Duration(seconds: 2), _goToTutorial);
    _messageTimer = Timer.periodic(
      const Duration(milliseconds: 3000),
      (_) => _rotateMessage(),
    );
  }

  void _goToTutorial() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TutorialPage()),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _rotateMessage() {
    if (!mounted || _messages.length < 2) {
      return;
    }

    var nextIndex = _currentIndex;
    while (nextIndex == _currentIndex) {
      nextIndex = _random.nextInt(_messages.length);
    }

    setState(() {
      _currentIndex = nextIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-splash.png', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), AppColors.backgroundOverlayBottom],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                36,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    _messages[_currentIndex],
                    key: ValueKey(_messages[_currentIndex]),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
