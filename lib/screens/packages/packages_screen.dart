import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nocatfish_app/controllers/dashboard_controller.dart';

import '../../controllers/plans_controller.dart';
import '../../models/plan_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final controller = Get.put(PlansController());
  final dbcontroller = Get.put(DashboardController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPlans();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (controller.errorplans.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.error,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GradientButton(
                    text: 'Retry',
                    onPressed: () => controller.loadPlans(),
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.plans.isEmpty) {
          return const Center(
            child: Text(
              'No plans available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.currentPlan != null) ...[
                _buildCurrentPlanBanner(controller),
                const SizedBox(height: 24),
              ],
              const Text(
                'Available Plans',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the perfect plan for your needs',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ...controller.plans.map(
                (plan) => _buildPlanCard(
                  plan,
                  controller,
                  dbcontroller,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentPlanBanner(PlansController controller) {
    final plan = controller.currentPlan!;
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${plan.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
                // SizedBox(height: 4),
                // Text(
                //   plan.name,
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                SizedBox(height: 4),
                Text(
                  'Balance: ${plan.tokensBalance.toString()} Coins',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // if (controller.canUpgrade())
          //   TextButton(
          //     onPressed: () {},
          //     child: const Text(
          //       'Upgrade',
          //       style: TextStyle(
          //         color: AppTheme.primaryColor,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan, PlansController controller, DashboardController dbcontroller) {
    final isActive = controller.isPlanActive(plan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              plan.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Divider(
              color: Colors.white24,
            ),
            const SizedBox(height: 10.0),
            Text(
              '${plan.tokens} coins',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '${plan.costDisplay} per scan',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12.0),
            const Divider(
              color: Colors.white24,
            ),
            const SizedBox(height: 12.0),
            Obx(() {
              if (isActive) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Current Plan',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              return GradientButton(
                text: plan.price > 0 ? 'Buy Plan' : 'Select Plan',
                onPressed: controller.isPurchasing ? null : () => _handlePurchase(plan, controller, dbcontroller),
                gradient: AppTheme.primaryGradient,
                isLoading: controller.isPurchasing,
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    PlanModel plan,
    PlansController controller,
    DashboardController dbcontroller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Confirm Purchase',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          plan.price > 0 ? 'Are you sure you want to buy ${plan.name} Plan for ${plan.priceDisplay} with ${plan.tokens} tokens?' : 'Are you sure you want to select the ${plan.name} plan?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool success;

      if (plan.price > 0) {
        success = await controller.purchasePlanWithStripe(
          plan.id,
          plan.price,
        );
      } else {
        success = await controller.purchasePlan(plan.id);
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Successfully purchased ${plan.name} plan!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        Future.delayed(Duration(seconds: 2));
        controller.loadPlans();
        Future.delayed(Duration(seconds: 2));
        dbcontroller.loadDashboard();
      } else {
        Get.snackbar(
          'Error',
          controller.error.isNotEmpty ? controller.error : 'Failed to subscribe',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }
}
