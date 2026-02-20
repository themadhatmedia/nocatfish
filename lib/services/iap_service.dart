import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../config/api_config.dart';
import '../models/plan_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  bool _isInitialized = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final Set<String> _pendingPurchases = {};
  final Map<String, String> _productToPlanId = {}; // Maps productId to planId

  // 🔧 DEV MODE: Controlled from ApiConfig
  bool get _devMockMode => ApiConfig.enableMockIAP;

  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(String)? onPurchaseError;

  bool get isAvailable => _devMockMode || _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        debugPrint('⚠️ In-App Purchase not available on this device');
        return;
      }

      if (Platform.isIOS) {
        final iosPlatform = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatform.setDelegate(ExamplePaymentQueueDelegate());
      }

      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription.cancel(),
        onError: (error) => debugPrint('❌ IAP Stream error: $error'),
      );

      _isInitialized = true;
      debugPrint('✅ IAP Service initialized successfully');
    } catch (e) {
      debugPrint('❌ IAP initialization failed: $e');
    }
  }

  Future<void> loadProducts(List<PlanModel> plans) async {
    // 🔧 DEV MODE: Skip actual IAP product loading
    if (_devMockMode) {
      debugPrint('🧪 DEV MODE: Skipping IAP product loading');
      return;
    }

    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available');
      return;
    }

    try {
      final productIds = plans.where((plan) => plan.price > 0 && plan.productId != null).map((plan) => plan.productId!).toSet();

      if (productIds.isEmpty) {
        debugPrint('⚠️ No product IDs to load');
        return;
      }

      debugPrint('🔍 Loading products: $productIds');

      final response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('❌ Failed to load products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('✅ Loaded ${_products.length} products');

      for (var product in _products) {
        debugPrint('  - ${product.id}: ${product.title} (${product.price})');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Products not found: ${response.notFoundIDs}');
      }
    } catch (e) {
      debugPrint('❌ Failed to load products: $e');
    }
  }

  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> purchaseProduct(String productId, {String? planId}) async {
    // 🔧 DEV MODE: Mock successful purchase
    if (_devMockMode) {
      debugPrint('🧪 DEV MODE: Simulating purchase for $productId');

      // Simulate async purchase flow
      await Future.delayed(const Duration(seconds: 1));

      // Call success callback directly (bypass verification)
      debugPrint('✅ DEV MODE: Mock purchase successful');
      onPurchaseSuccess?.call(_createMockPurchaseDetails(productId));

      return true;
    }

    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available');
      onPurchaseError?.call('In-App Purchase is not available on this device');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      debugPrint('❌ Product not found: $productId');
      onPurchaseError?.call('Product not found');
      return false;
    }

    try {
      debugPrint('🛒 Initiating purchase for: ${product.id}');
      _pendingPurchases.add(productId);

      // Store planId mapping for later retrieval
      if (planId != null) {
        _productToPlanId[productId] = planId;
        debugPrint('📝 Stored planId mapping: $productId -> $planId');
      }

      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: planId,
      );

      final success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!success) {
        debugPrint('❌ Failed to initiate purchase');
        _pendingPurchases.remove(productId);
        _productToPlanId.remove(productId);
        onPurchaseError?.call('Failed to initiate purchase');
        return false;
      }

      debugPrint('✅ Purchase initiated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      _pendingPurchases.remove(productId);
      onPurchaseError?.call('Purchase failed: $e');
      return false;
    }
  }

  // Mock purchase details for dev mode
  PurchaseDetails _createMockPurchaseDetails(String productId) {
    return PurchaseDetails(
      productID: productId,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'mock_local_data',
        serverVerificationData: 'mock_server_data',
        source: 'mock',
      ),
      transactionDate: DateTime.now().toIso8601String(),
      status: PurchaseStatus.purchased,
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      debugPrint('📦 Purchase update: ${purchase.productID} - ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('⏳ Purchase pending: ${purchase.productID}');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint('✅ Purchase successful: ${purchase.productID}');
          await _verifyAndCompletePurchase(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('❌ Purchase error: ${purchase.error}');
          _pendingPurchases.remove(purchase.productID);
          _productToPlanId.remove(purchase.productID);
          onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          debugPrint('🚫 Purchase canceled: ${purchase.productID}');
          _pendingPurchases.remove(purchase.productID);
          _productToPlanId.remove(purchase.productID);
          onPurchaseError?.call('Purchase was canceled');

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  Future<void> _verifyAndCompletePurchase(PurchaseDetails purchase) async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        debugPrint('❌ No auth token found');
        onPurchaseError?.call('Authentication required');
        return;
      }

      // final receiptData = purchase.verificationData.serverVerificationData;
      final productId = purchase.productID;
      final planIdString = purchase.purchaseID;

      debugPrint('📤 Verifying purchase with backend...');
      debugPrint('  Product ID: $productId');
      debugPrint('  Plan ID: $planIdString');
      debugPrint('  Transaction ID: ${purchase.purchaseID}');

      final response = await _apiService.purchasePlan(
        token: token,
        planId: productId == 'com.nocatfishscan.app.standard_plan'
            ? 1
            : productId == 'com.nocatfishscan.app.bronze'
                ? 2
                : productId == 'com.nocatfishscan.app.silver'
                    ? 3
                    : productId == 'com.nocatfishscan.app.gold'
                        ? 4
                        : productId == 'com.nocatfishscan.app.platinum'
                            ? 5
                            : 0,
      );

      if (response.success) {
        debugPrint('✅ Purchase verified and scans added successfully');

        // CRITICAL: Complete the purchase to mark it as consumed
        // This is required for both iOS and Android consumables
        // For Android, this calls consumeAsync on Google Play Billing
        // For iOS, this finishes the transaction
        debugPrint('🔄 Completing purchase to enable repeat purchases...');
        debugPrint('pendingCompletePurchase: ${purchase.pendingCompletePurchase}');

        try {
          await _iap.completePurchase(purchase);
          debugPrint('✅ Purchase completed successfully - can be purchased again');
        } catch (e) {
          debugPrint('⚠️ Error completing purchase: $e');
          debugPrint('   This might prevent repeat purchases!');
        }

        // Clean up
        _pendingPurchases.remove(productId);
        _productToPlanId.remove(productId);
        onPurchaseSuccess?.call(purchase);
      } else {
        debugPrint('❌ Purchase verification failed: ${response.errorMessage}');
        _pendingPurchases.remove(productId);
        _productToPlanId.remove(productId);
        onPurchaseError?.call(response.errorMessage);
      }

      // final response = await _apiService.verifyIAPReceipt(
      //   token: token,
      //   productId: productId,
      //   receiptData: receiptData,
      //   transactionId: purchase.purchaseID ?? '',
      //   platform: Platform.isIOS ? 'ios' : 'android',
      // );

      // if (response.success) {
      //   debugPrint('✅ Purchase verified and scans added successfully');
      //   if (response.data != null) {
      //     debugPrint('   Scans remaining: ${response.data!.scansRemaining}');
      //     debugPrint('   Current plan: ${response.data!.currentPlan?.name}');
      //   }

      //   // CRITICAL: Complete the purchase to mark it as consumed
      //   // This is required for both iOS and Android consumables
      //   // For Android, this calls consumeAsync on Google Play Billing
      //   // For iOS, this finishes the transaction
      //   debugPrint('🔄 Completing purchase to enable repeat purchases...');
      //   debugPrint('   pendingCompletePurchase: ${purchase.pendingCompletePurchase}');

      //   try {
      //     await _iap.completePurchase(purchase);
      //     debugPrint('✅ Purchase completed successfully - can be purchased again');
      //   } catch (e) {
      //     debugPrint('⚠️ Error completing purchase: $e');
      //     debugPrint('   This might prevent repeat purchases!');
      //   }

      //   // Clean up
      //   _pendingPurchases.remove(productId);
      //   _productToPlanId.remove(productId);
      //   onPurchaseSuccess?.call(purchase);
      // } else {
      //   debugPrint('❌ Purchase verification failed: ${response.errorMessage}');
      //   _pendingPurchases.remove(productId);
      //   _productToPlanId.remove(productId);
      //   onPurchaseError?.call(response.errorMessage);
      // }
    } catch (e) {
      debugPrint('❌ Purchase verification error: $e');
      _pendingPurchases.remove(purchase.productID);
      _productToPlanId.remove(purchase.productID);
      onPurchaseError?.call('Failed to verify purchase: $e');
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available');
      return;
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      await _iap.restorePurchases();
      debugPrint('✅ Restore purchases initiated');
    } catch (e) {
      debugPrint('❌ Failed to restore purchases: $e');
      onPurchaseError?.call('Failed to restore purchases: $e');
    }
  }

  bool isPurchasePending(String productId) {
    return _pendingPurchases.contains(productId);
  }

  void dispose() {
    _subscription.cancel();
    _isInitialized = false;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
