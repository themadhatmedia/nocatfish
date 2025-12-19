import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/upload_controller.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';
import 'services/storage_service.dart';
import 'services/stripe_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService().init();

  await StripeService().initialize();

  await Firebase.initializeApp();

  await Get.putAsync(() => AnalyticsService().init());

  Get.put(AuthController());
  Get.put(ThemeController());
  Get.put(DashboardController());
  Get.put(UploadController());

  final analytics = Get.find<AnalyticsService>();
  await analytics.logAppOpened();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  //  Stripe.publishableKey = 'pk_test_51SSxQD9qN5HYH1xBXj5l9eGm71p0KSubfmfu5yyHF1cHH6Rt1tUkRnS7u0geQWoQoNQeP7VNkjGLwDkvq13hlkpP00zSZHmcWY';

  runApp(const NoCatfishApp());
}

class NoCatfishApp extends StatelessWidget {
  const NoCatfishApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Catfish Scan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const SplashScreen(),
        ));
  }
}
