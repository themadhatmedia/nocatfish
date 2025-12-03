// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import '../services/api_service.dart';
// import '../utils/app_theme.dart';
// import 'auth_controller.dart';
// import 'dashboard_controller.dart';

// class PaymentController extends GetxController {
//   final ApiService _apiService = ApiService();
//   final RxBool isProcessing = false.obs;

//   Future<void> purchasePackage(dynamic package) async {
//     final authController = Get.find<AuthController>();
//     final token = authController.token;

//     if (token == null) {
//       Get.snackbar(
//         'Error',
//         'Please login to purchase packages',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppTheme.darkOrange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     isProcessing.value = true;

//     try {
//       // Step 1: Create payment intent on backend
//       final paymentIntentResponse = await _apiService.createPaymentIntent(
//         token: token,
//         packageName: package.name,
//         amount: package.price,
//         coins: package.coins,
//       );

//       if (!paymentIntentResponse.success || paymentIntentResponse.data == null) {
//         throw Exception(paymentIntentResponse.errorMessage);
//       }

//       // final clientSecret = paymentIntentResponse.data!['client_secret'];
//       var clientSecret = '';
//       final paymentIntentId = paymentIntentResponse.data!['payment_intent_id'];

//       // Step 2: Initialize payment sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           merchantDisplayName: 'NoCatfish',
//           paymentIntentClientSecret: clientSecret,
//           customerEphemeralKeySecret: paymentIntentResponse.data!['ephemeral_key'],
//           customerId: paymentIntentResponse.data!['customer_id'],
//           style: ThemeMode.dark,
//           appearance: const PaymentSheetAppearance(
//             colors: PaymentSheetAppearanceColors(
//               primary: Color(0xFFfaa540),
//               background: Color(0xFF2a3342),
//               componentBackground: Color(0xFF1a2332),
//             ),
//           ),
//         ),
//       );

//       // Step 3: Present payment sheet
//       await Stripe.instance.presentPaymentSheet();

//       // Step 4: Confirm payment on backend
//       final confirmResponse = await _apiService.confirmPayment(
//         token: token,
//         paymentIntentId: paymentIntentId,
//       );

//       if (confirmResponse.success) {
//         // Refresh dashboard to show updated coins
//         final dashboardController = Get.find<DashboardController>();
//         await dashboardController.refresh();

//         Get.snackbar(
//           'Success!',
//           'Payment successful! ${package.coins} coins added to your account.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: AppTheme.brandOrange,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 4),
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//         );

//         Get.back(); // Return to previous screen
//       } else {
//         throw Exception(confirmResponse.errorMessage);
//       }
//     } on StripeException catch (e) {
//       String errorMessage = 'Payment failed';

//       switch (e.error.code) {
//         case FailureCode.Canceled:
//           errorMessage = 'Payment was cancelled';
//           break;
//         case FailureCode.Failed:
//           errorMessage = 'Payment failed. Please try again.';
//           break;
//         case FailureCode.Timeout:
//           errorMessage = 'Payment timed out. Please try again.';
//           break;
//         default:
//           errorMessage = e.error.message ?? 'Payment failed';
//       }

//       Get.snackbar(
//         'Payment Failed',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppTheme.darkOrange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An unexpected error occurred: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppTheme.darkOrange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isProcessing.value = false;
//     }
//   }
// }
