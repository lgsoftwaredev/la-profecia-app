import 'package:flutter/material.dart';

import 'features/onboarding/presentation/pages/post_splash_page.dart';

void main() {
  runApp(const LaProfeciaApp());
}

class LaProfeciaApp extends StatelessWidget {
  const LaProfeciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'La Profecia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PostSplashPage(),
    );
  }
}
