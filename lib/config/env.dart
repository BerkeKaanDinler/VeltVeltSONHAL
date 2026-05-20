// VELT — Build-time configuration.
//
// Pass these via `--dart-define=KEY=value` at run/build time. Defaults are
// empty so debug builds without secrets still launch (services fail open).
//
// Example:
//   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=eyJh... \
//               --dart-define=SENTRY_DSN=https://xxx@sentry.io/123 \
//               --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
//               --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxx

abstract class Env {
  Env._();

  // Supabase (auth + sync)
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static bool get supabaseEnabled =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Sentry (crash reporting)
  static const sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static bool get sentryEnabled => sentryDsn.isNotEmpty;

  // RevenueCat (subscriptions)
  static const revenueCatAppleKey =
      String.fromEnvironment('REVENUECAT_APPLE_KEY', defaultValue: '');
  static const revenueCatGoogleKey =
      String.fromEnvironment('REVENUECAT_GOOGLE_KEY', defaultValue: '');
  static bool get revenueCatEnabled =>
      revenueCatAppleKey.isNotEmpty || revenueCatGoogleKey.isNotEmpty;
}
