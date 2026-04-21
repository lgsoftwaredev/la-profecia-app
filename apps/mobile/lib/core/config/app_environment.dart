import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static String _read(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env[key]?.trim() ?? '';
  }

  static bool _readBool(String key, {bool fallback = false}) {
    final value = _read(key).toLowerCase();
    if (value == 'true' || value == '1' || value == 'yes') {
      return true;
    }
    if (value == 'false' || value == '0' || value == 'no') {
      return false;
    }
    return fallback;
  }

  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');
  static String get googleServerClientId => _read('GOOGLE_SERVER_CLIENT_ID');
  static String get googleIosClientId => _read('GOOGLE_IOS_CLIENT_ID');

  static String get iapAndroidMonthlyProductId =>
      _read('IAP_ANDROID_MONTHLY_PRODUCT_ID');
  static String get iapIosMonthlyProductId =>
      _read('IAP_IOS_MONTHLY_PRODUCT_ID');

  static String get admobAndroidInterstitialId =>
      _read('ADMOB_ANDROID_INTERSTITIAL_ID');
  static String get admobIosInterstitialId =>
      _read('ADMOB_IOS_INTERSTITIAL_ID');

  static bool get enablePushAutoPermissionPrompt =>
      _readBool('ENABLE_PUSH_AUTO_PERMISSION_PROMPT', fallback: true);

  static String resolveMonthlyProductIdForCurrentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return iapAndroidMonthlyProductId;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iapIosMonthlyProductId;
    }
    return '';
  }
}
