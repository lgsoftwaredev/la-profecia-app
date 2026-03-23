import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:la_profecia_app/features/onboarding/presentation/pages/post_splash_page.dart';
import 'package:la_profecia_app/main.dart';

void main() {
  testWidgets('Post splash screen rotates one random loading message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LaProfeciaApp());

    expect(find.byType(PostSplashPage), findsOneWidget);

    final messageFinder = find.descendant(
      of: find.byType(PostSplashPage),
      matching: find.byType(Text),
    );

    expect(messageFinder, findsOneWidget);

    final firstMessage = tester.widget<Text>(messageFinder).data;
    expect(firstMessage, isNotNull);
    expect(firstMessage, isNotEmpty);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final secondMessage = tester.widget<Text>(messageFinder).data;
    expect(secondMessage, isNotNull);
    expect(secondMessage, isNotEmpty);
    expect(secondMessage, isNot(equals(firstMessage)));
  });
}
