class PlanModel {
  final int id;
  final String name;
  final int tokens;
  final double price;
  final double costPerScan;
  // final String interval;
  // final int maxDailyUploads;
  // final bool isPremium;
  // final List<String> features;
  final bool isActive;
  // final bool isPopular;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.tokens,
    required this.costPerScan,
    // required this.interval,
    // required this.maxDailyUploads,
    // required this.isPremium,
    // required this.features,
    this.isActive = false,
    // this.isPopular = false,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
      tokens: int.parse(json['tokens'].toString()),
      costPerScan: double.parse(json['cost_per_scan'].toString()),
      // interval: json['interval'] ?? 'month',
      // maxDailyUploads: json['max_daily_uploads'] ?? 50,
      // isPremium: json['is_premium'] ?? false,
      // features: json['features'] != null ? List<String>.from(json['features']) : [],
      isActive: json['is_active'] ?? false,
      // isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tokens': tokens,
      'price': price,
      'cost_per_scan': costPerScan,
      // 'interval': interval,
      // 'max_daily_uploads': maxDailyUploads,
      // 'is_premium': isPremium,
      // 'features': features,
      'is_active': isActive,
      // 'is_popular': isPopular,
    };
  }

  String get priceDisplay {
    if (price == 0) return 'Free';
    return '\$${price.toStringAsFixed(2)}';
  }

  String get costDisplay {
    if (price == 0) return 'Free';
    return '\$${costPerScan.toStringAsFixed(2)}';
  }

  // String get intervalDisplay {
  //   switch (interval.toLowerCase()) {
  //     case 'month':
  //       return 'per month';
  //     case 'year':
  //       return 'per year';
  //     case 'week':
  //       return 'per week';
  //     default:
  //       return interval;
  //   }
  // }
}

class UserPlanData {
  final PlanModel? currentPlan;
  final String? subscribedAt;
  final bool isActive;

  UserPlanData({
    this.currentPlan,
    this.subscribedAt,
    this.isActive = false,
  });

  factory UserPlanData.fromJson(Map<String, dynamic> json) {
    return UserPlanData(
      currentPlan: json['current_plan'] != null ? PlanModel.fromJson(json['current_plan']) : null,
      subscribedAt: json['created_at'],
      isActive: json['is_active'] ?? false,
    );
  }
}

class PlansListData {
  final List<PlanModel> plans;
  final PlanModel? currentPlan;

  PlansListData({
    required this.plans,
    this.currentPlan,
  });

  factory PlansListData.fromJson(Map<String, dynamic> json) {
    print('json: $json');
    return PlansListData(
      plans: (json['plans'] as List).map((e) => PlanModel.fromJson(e)).toList(),
      currentPlan: json['current_plan'] != null ? PlanModel.fromJson(json['current_plan']) : null,
    );
  }
}
