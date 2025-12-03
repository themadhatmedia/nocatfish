class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'XXXX',
  );

  static const String merchantDisplayName = 'No Catfish AI';
  static const String merchantCountryCode = 'US';
  static const String currencyCode = 'usd';
  static const String secretKey = 'XXXX';

  static bool get isConfigured => publishableKey.isNotEmpty;
}
