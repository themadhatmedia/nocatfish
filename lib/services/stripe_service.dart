import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import '../config/stripe_config.dart';
import '../utils/app_theme.dart';
import '../widgets/payment_buttons.dart';
import 'storage_service.dart';

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

      var user = StorageService().getUser()!;
      print('id: ${user['id']}');
      print('name: ${user['name']}');
      print('email: ${user['email']}');

      final billingDetails = BillingDetails(
        name: '${user['name']}',
        email: '${user['email']}',
        // phone: '+919106141050',
        // address: Address(
        //   city: 'Surat',
        //   country: 'India',
        //   line1: 'Address 1',
        //   line2: 'Address 2',
        //   postalCode: '395004',
        //   state: 'GJ',
        // ),
      );

      final paymentSheetParams = SetupPaymentSheetParameters(
        customFlow: false,
        merchantDisplayName: 'Catfish Scan',
        billingDetails: billingDetails,
        customerId: user['id'].toString(),
        paymentIntentClientSecret: paymentInitialClientSecret,
        setupIntentClientSecret: paymentInitialClientSecret,
        style: ThemeMode.dark,
        googlePay: PaymentSheetGooglePay(
          merchantCountryCode: 'US', // Or your country code
          testEnv: true, // Set to false for production
        ),
        applePay: PaymentSheetApplePay(
          merchantCountryCode: 'US',
        ),
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

      String payWith = '';

      // show payment option
      await showModalBottomSheet<PaymentMethod>(
        context: Get.context!,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: \$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Platform.isAndroid
                            ? PaymentOptionButton(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google Pay',
                                subtitle: 'Pay with your google pay',
                                onTap: () {
                                  payWith = 'google';
                                  Navigator.pop(context);
                                },
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4285F4),
                                    Color(0xFF34A853),
                                  ],
                                ),
                              )
                            : Container(),
                        Platform.isAndroid ? SizedBox(height: 16) : Container(),
                        Platform.isIOS
                            ? PaymentOptionButton(
                                icon: Icons.apple,
                                label: 'Apple Pay',
                                subtitle: 'Pay with your apple pay',
                                onTap: () {
                                  payWith = 'apple';
                                  Navigator.pop(context);
                                },
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF000000),
                                    Color(0xFF434343),
                                  ],
                                ),
                              )
                            : Container(),
                        Platform.isIOS ? SizedBox(height: 16) : Container(),
                        PaymentOptionButton(
                          icon: Icons.credit_card,
                          label: 'Other',
                          subtitle: 'Credit/Debit card',
                          onTap: () {
                            payWith = 'other';
                            Navigator.pop(context);
                          },
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              Color(0xFFff8c42),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextButton(
                      onPressed: () {
                        payWith == 'cancel';
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );

      if (payWith == 'cancel') {
        return false;
      } else if (payWith == 'google') {
        var gPay = await payWithGoogle(Get.context!, paymentInitialClientSecret!);
        print('gPay: $gPay');
        if (gPay != null) {
          print('🟢 Payment completed successfully with gpay');
          return true;
        } else {
          print('❌ Payment not completed with gpay');
          return false;
        }
      } else if (payWith == 'apple') {
        var applePay = await payWithApple(Get.context!, paymentInitialClientSecret!, amount);
        print('applePay: $applePay');
        if (applePay != null) {
          print('🟢 Payment completed successfully with apple pay');
          return true;
        } else {
          print('❌ Payment not completed with apple pay');
          return false;
        }
      } else if (payWith == 'other') {
        await Stripe.instance.presentPaymentSheet();
        await Stripe.instance.confirmPaymentSheetPayment();
        print('🟢 Payment completed successfully');
        return true;
      } else {
        return false;
      }

      // return false;
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

  Future<dynamic> payWithGoogle(BuildContext context, String clientSecret) async {
    final googlePaySupported = await Stripe.instance.isPlatformPaySupported(googlePay: IsGooglePaySupportedParams());

    if (googlePaySupported) {
      try {
        final paymentMethod = await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: clientSecret,
          confirmParams: const PlatformPayConfirmParams.googlePay(
            googlePay: GooglePayParams(
              testEnv: true,
              merchantName: 'Catfish Scan',
              merchantCountryCode: 'US',
              currencyCode: 'USD',
              billingAddressConfig: GooglePayBillingAddressConfig(
                isRequired: true,
              ),
            ),
          ),
        );

        final paymentIntentJson = {
          'id': paymentMethod.id,
          'amount': paymentMethod.amount,
          'created': paymentMethod.created,
          'currency': paymentMethod.currency,
          'status': paymentMethod.status.name, // Convert enum to string
          'clientSecret': paymentMethod.clientSecret,
          'livemode': paymentMethod.livemode,
          'captureMethod': paymentMethod.captureMethod.name,
          'confirmationMethod': paymentMethod.confirmationMethod.name,
          'paymentMethodId': paymentMethod.paymentMethodId,
          'description': paymentMethod.description,
          'receiptEmail': paymentMethod.receiptEmail,
          'canceledAt': paymentMethod.canceledAt,
          'nextAction': paymentMethod.nextAction,
          'shipping': paymentMethod.shipping,
          'mandateData': paymentMethod.mandateData,
          'latestCharge': paymentMethod.latestCharge,
        };

        return paymentIntentJson;
      } catch (e) {
        if (e is StripeException) {
          final errorMessage = e.error.localizedMessage ?? "An unknown error occurred.Please try again.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.darkOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment was cancelled by the user.'),
              backgroundColor: AppTheme.darkOrange,
            ),
          );
        }
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Pay is not supported on this device.'),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
      return null;
    }
  }

  Future<dynamic> payWithApple(BuildContext context, String clientSecret, double amount) async {
    final applePaySupported = await Stripe.instance.isPlatformPaySupported();
    if (applePaySupported) {
      try {
        final paymentMethod = await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: clientSecret,
          confirmParams: PlatformPayConfirmParams.applePay(
            applePay: ApplePayParams(
              merchantCountryCode: 'US',
              currencyCode: 'usd',
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: "Total Payable Amount",
                  amount: amount.toString(),
                ),
              ],
            ),
          ),
        );

        final paymentIntentJson = {
          'id': paymentMethod.id,
          'amount': paymentMethod.amount,
          'created': paymentMethod.created,
          'currency': paymentMethod.currency,
          'status': paymentMethod.status.name, // Convert enum to string
          'clientSecret': paymentMethod.clientSecret,
          'livemode': paymentMethod.livemode,
          'captureMethod': paymentMethod.captureMethod.name,
          'confirmationMethod': paymentMethod.confirmationMethod.name,
          'paymentMethodId': paymentMethod.paymentMethodId,
          'description': paymentMethod.description,
          'receiptEmail': paymentMethod.receiptEmail,
          'canceledAt': paymentMethod.canceledAt,
          'nextAction': paymentMethod.nextAction,
          'shipping': paymentMethod.shipping,
          'mandateData': paymentMethod.mandateData,
          'latestCharge': paymentMethod.latestCharge,
        };

        return paymentIntentJson;
      } catch (e) {
        if (e is StripeException) {
          final errorMessage = e.error.localizedMessage ?? "An unknown error occurred.Please try again.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.darkOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment was cancelled by the user.'),
              backgroundColor: AppTheme.darkOrange,
            ),
          );
        }
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apple Pay is not supported on this device.'),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
      return null;
    }
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      var user = StorageService().getUser()!;
      print('id: ${user['id']}');
      print('name: ${user['name']}');
      print('email: ${user['email']}');
      final Dio dio = Dio();
      var data = {
        "amount": (amount * 100).toInt(), //cents
        "currency": currency,
        'automatic_payment_methods[enabled]': true,
        'metadata[Customer ID]': user['id'].toString(),
        'metadata[Customer Name]': user['name'].toString(),
        'metadata[Customer Email]': user['email'].toString(),
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
