import 'package:flutter/material.dart';

import '../controllers/splash_message_rotator_controller.dart';

class PostSplashPage extends StatefulWidget {
  const PostSplashPage({super.key});

  @override
  State<PostSplashPage> createState() => _PostSplashPageState();
}

class _PostSplashPageState extends State<PostSplashPage> {
  static const _messages = [
    'Aquí nadie se salva. Algunos retos no son para cobardes.',
    'Prepárate… las preguntas que vienen pueden cambiar tu noche.',
    'Las cartas más virales de Internet están a punto de aparecer.',
    'Elige bien tus respuestas porque puedes perder tu relación o amistad.',
    'Lo que pase en La Profecía… difícilmente se olvida.',
  ];

  late final SplashMessageRotatorController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = SplashMessageRotatorController(messages: _messages)
      ..start();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-splash.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ValueListenableBuilder<String>(
                  valueListenable: _messageController,
                  builder: (context, message, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Text(
                        message,
                        key: ValueKey(message),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
