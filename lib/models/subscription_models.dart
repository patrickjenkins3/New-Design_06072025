class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? monthlyPrice;
  final double? annualPrice;
  final String billingInterval;
  final bool isActive;
  final bool isFree;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.monthlyPrice,
    this.annualPrice,
    required this.billingInterval,
    this.isActive = true,
    this.isFree = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPremium => !isFree;

  // Get the effective price based on billing period
  double getPrice(bool isAnnualBilling) {
    if (isAnnualBilling && annualPrice != null) {
      return annualPrice!;
    } else if (!isAnnualBilling && monthlyPrice != null) {
      return monthlyPrice!;
    }
    return price; // Fallback to default price
  }

  // Calculate savings percentage for annual billing
  double get annualSavingsPercentage {
    if (annualPrice != null && monthlyPrice != null && monthlyPrice! > 0) {
      return ((1 - (annualPrice! / 12) / monthlyPrice!) * 100);
    }
    return 0.0;
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      monthlyPrice: json['monthly_price'] != null
          ? (json['monthly_price'] as num).toDouble()
          : json['billing_interval'] == 'month'
              ? (json['price'] as num?)?.toDouble()
              : null,
      annualPrice: json['annual_price'] != null
          ? (json['annual_price'] as num).toDouble()
          : json['billing_interval'] == 'year'
              ? (json['price'] as num?)?.toDouble()
              : null,
      billingInterval: json['billing_interval'] as String? ?? 'month',
      isActive: json['is_active'] as bool? ?? true,
      isFree: (json['price'] as num?)?.toDouble() == 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'monthly_price': monthlyPrice,
      'annual_price': annualPrice,
      'billing_interval': billingInterval,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
