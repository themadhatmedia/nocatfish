class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'XX',
  );

  static const String merchantDisplayName = 'No Catfish AI';
  static const String merchantCountryCode = 'US';
  static const String currencyCode = 'usd';
  static const String secretKey = 'XX';

  static bool get isConfigured => publishableKey.isNotEmpty;
}
