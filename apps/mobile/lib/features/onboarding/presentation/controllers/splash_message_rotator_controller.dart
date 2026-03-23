import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class SplashMessageRotatorController extends ValueNotifier<String> {
  SplashMessageRotatorController({
    required List<String> messages,
    this.interval = const Duration(seconds: 4),
  }) : assert(messages.isNotEmpty, 'messages cannot be empty'),
       _messages = List.unmodifiable(messages),
       _random = Random(),
       _currentIndex = 0,
       super(messages.first) {
    _currentIndex = _random.nextInt(_messages.length);
    value = _messages[_currentIndex];
  }

  final List<String> _messages;
  final Random _random;
  final Duration interval;
  int _currentIndex;
  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => _rotateMessage());
  }

  void _rotateMessage() {
    if (_messages.length == 1) {
      value = _messages.first;
      return;
    }

    var nextIndex = _currentIndex;
    while (nextIndex == _currentIndex) {
      nextIndex = _random.nextInt(_messages.length);
    }

    _currentIndex = nextIndex;
    value = _messages[_currentIndex];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
