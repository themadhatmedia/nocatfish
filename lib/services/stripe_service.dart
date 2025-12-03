import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!StripeConfig.isConfigured) {
      debugPrint('⚠️ Stripe not configured - missing publishable key');
      return;
    }

    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      Stripe.merchantIdentifier = StripeConfig.merchantDisplayName;

      await Stripe.instance.applySettings();

      _isInitialized = true;
      debugPrint('✅ Stripe initialized successfully');
    } catch (e) {
      debugPrint('❌ Stripe initialization failed: $e');
      rethrow;
    }
  }

  Future<bool> collectPayment({
    required double amount,
    required String currency,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Stripe not initialized');
      return false;
    }

    try {
      String? paymentInitialClientSecret = await createPaymentIntent(
        amount,
        currency,
      );
      print('paymentInitialClientSecret: $paymentInitialClientSecret');

      final billingDetails = BillingDetails(
        name: 'Jay Tarpara',
        email: 'tarparajay00@gmail.com',
        phone: '+919106141050',
        address: Address(
          city: 'Surat',
          country: 'India',
          line1: 'Address 1',
          line2: 'Address 2',
          postalCode: '395004',
          state: 'GJ',
        ),
      );

      final paymentSheetParams = SetupPaymentSheetParameters(
        customFlow: false,
        merchantDisplayName: 'Catfish Scan',
        billingDetails: billingDetails,
        paymentIntentClientSecret: paymentInitialClientSecret,
        setupIntentClientSecret: paymentInitialClientSecret,
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFFfaa540),
            background: Color(0xFF1a2332),
            componentBackground: Color(0xFF2a3342),
            componentBorder: Color(0xFF3a4352),
            componentDivider: Color(0xFF4a5362),
            primaryText: Color(0xFFFFFFFF),
            secondaryText: Color(0xFFAAAAAA),
            componentText: Color(0xFFFFFFFF),
            placeholderText: Color(0xFF666666),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 16,
            borderWidth: 1,
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFFfaa540),
                text: Color(0xFFFFFFFF),
                border: Color(0xFFfaa540),
              ),
              dark: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFFfaa540),
                text: Color(0xFFFFFFFF),
                border: Color(0xFFfaa540),
              ),
            ),
          ),
        ),
      );

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: paymentSheetParams);

      await Stripe.instance.presentPaymentSheet();

      // await Stripe.instance.confirmPaymentSheetPayment();
      print('🟢 Payment completed successfully');

      // debugPrint('✅ Payment method created: $stripePaymentIntent');
      // debugPrint('💰 Amount: \$${amount.toStringAsFixed(2)} $currency');
      return true;
    } on StripeException catch (e) {
      debugPrint('payment here 1');
      debugPrint('❌ Stripe error: ${e.error.localizedMessage}');

      if (e.error.code == FailureCode.Canceled) {
        debugPrint('ℹ️ Payment canceled by user');
      }

      return false;
    } catch (e) {
      debugPrint('payment here 2');
      debugPrint('❌ Payment error: $e');
      return false;
    }
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final Dio dio = Dio();
      var data = {
        "amount": (amount * 100).toInt(), //cents
        "currency": currency,
        'automatic_payment_methods[enabled]': true,
      };
      var headers = {
        "Authorization": "Bearer ${StripeConfig.secretKey}",
        "Content-Type": "application/x-www-form-urlencoded",
      };
      print('createPaymentIntent data: $data');
      print('createPaymentIntent headers: $headers');
      final response = await dio.request(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          method: 'POST',
          // contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );
      print('createPaymentIntent response: ${response.data}');
      print('createPaymentIntent response: ${dio.options}');
      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }
}
