import 'package:shared_preferences/shared_preferences.dart';

class TutorialPreferences {
  const TutorialPreferences._();

  static const seenKey = 'tutorial_seen_v1';

  static Future<bool> isTutorialSeen() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(seenKey) ?? false;
  }

  static Future<void> markTutorialSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(seenKey, true);
  }
}
