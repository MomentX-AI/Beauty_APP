import '../models/subscription_plan.dart';
import '../models/subscription.dart';
import '../models/billing.dart';

class MockSubscriptionService {
  // 模擬當前訂閱數據
  static final Map<String, Subscription> _subscriptions = {
    '1': Subscription(
      id: 'sub_001',
      businessId: '1',
      planId: 'business',
      plan: SubscriptionPlan.getAvailablePlans().firstWhere((p) => p.id == 'business'),
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 335)),
      staffCount: 5,
      monthlyAmount: 2250.0, // 5 staff * 450
      autoRenewal: true,
    ),
  };

  // 模擬帳單數據
  static final List<Billing> _billings = [
    Billing(
      id: 'bill_001',
      businessId: '1',
      subscriptionId: 'sub_001',
      billingDate: DateTime.now().subtract(const Duration(days: 30)),
      dueDate: DateTime.now().subtract(const Duration(days: 23)),
      paidDate: DateTime.now().subtract(const Duration(days: 25)),
      status: BillingStatus.paid,
      amount: 2250.0,
      taxAmount: 112.5,
      totalAmount: 2362.5,
      paymentMethod: PaymentMethod.creditCard,
      paymentReference: 'TXN123456789',
      staffCount: 5,
      planName: 'Business 商業版',
      pricePerStaff: 450.0,
      notes: '2024年3月帳單',
    ),
    Billing(
      id: 'bill_002',
      businessId: '1',
      subscriptionId: 'sub_001',
      billingDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      status: BillingStatus.pending,
      amount: 2250.0,
      taxAmount: 112.5,
      totalAmount: 2362.5,
      staffCount: 5,
      planName: 'Business 商業版',
      pricePerStaff: 450.0,
      notes: '2024年4月帳單',
    ),
    Billing(
      id: 'bill_003',
      businessId: '1',
      subscriptionId: 'sub_001',
      billingDate: DateTime.now().add(const Duration(days: 30)),
      dueDate: DateTime.now().add(const Duration(days: 37)),
      status: BillingStatus.pending,
      amount: 2250.0,
      taxAmount: 112.5,
      totalAmount: 2362.5,
      staffCount: 5,
      planName: 'Business 商業版',
      pricePerStaff: 450.0,
      notes: '2024年5月帳單',
    ),
  ];

  // 獲取當前訂閱
  Future<Subscription?> getCurrentSubscription(String businessId) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(milliseconds: 500));
    return _subscriptions[businessId];
  }

  // 獲取帳單列表
  Future<List<Billing>> getBillings(String businessId) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(milliseconds: 500));
    return _billings.where((billing) => billing.businessId == businessId).toList();
  }

  // 獲取特定帳單
  Future<Billing?> getBilling(String billingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _billings.firstWhere(
      (billing) => billing.id == billingId,
      orElse: () => throw Exception('帳單不存在'),
    );
  }

  // 創建新訂閱
  Future<Subscription> createSubscription({
    required String businessId,
    required String planId,
    required int staffCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final plan = SubscriptionPlan.getAvailablePlans().firstWhere(
      (p) => p.id == planId,
      orElse: () => throw Exception('方案不存在'),
    );

    final subscription = Subscription(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      businessId: businessId,
      planId: planId,
      plan: plan,
      status: SubscriptionStatus.active,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
      staffCount: staffCount,
      monthlyAmount: plan.pricePerStaffPerMonth * staffCount,
      autoRenewal: true,
    );

    _subscriptions[businessId] = subscription;
    return subscription;
  }

  // 更新訂閱
  Future<Subscription> updateSubscription({
    required String businessId,
    required String planId,
    required int staffCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final currentSubscription = _subscriptions[businessId];
    if (currentSubscription == null) {
      throw Exception('訂閱不存在');
    }

    final plan = SubscriptionPlan.getAvailablePlans().firstWhere(
      (p) => p.id == planId,
      orElse: () => throw Exception('方案不存在'),
    );

    final updatedSubscription = currentSubscription.copyWith(
      planId: planId,
      plan: plan,
      staffCount: staffCount,
      monthlyAmount: plan.pricePerStaffPerMonth * staffCount,
    );

    _subscriptions[businessId] = updatedSubscription;
    return updatedSubscription;
  }

  // 取消訂閱
  Future<Subscription> cancelSubscription(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final currentSubscription = _subscriptions[businessId];
    if (currentSubscription == null) {
      throw Exception('訂閱不存在');
    }

    final cancelledSubscription = currentSubscription.copyWith(
      status: SubscriptionStatus.cancelled,
      cancelledDate: DateTime.now(),
      autoRenewal: false,
    );

    _subscriptions[businessId] = cancelledSubscription;
    return cancelledSubscription;
  }

  // 付款
  Future<Billing> payBilling({
    required String billingId,
    required PaymentMethod paymentMethod,
    String? paymentReference,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final billingIndex = _billings.indexWhere((b) => b.id == billingId);
    if (billingIndex == -1) {
      throw Exception('帳單不存在');
    }

    final billing = _billings[billingIndex];
    if (billing.isPaid) {
      throw Exception('帳單已付款');
    }

    final paidBilling = billing.copyWith(
      status: BillingStatus.paid,
      paidDate: DateTime.now(),
      paymentMethod: paymentMethod,
      paymentReference: paymentReference ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );

    _billings[billingIndex] = paidBilling;
    return paidBilling;
  }

  // 生成新帳單
  Future<Billing> generateBilling({
    required String businessId,
    required String subscriptionId,
    required DateTime billingDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final subscription = _subscriptions[businessId];
    if (subscription == null) {
      throw Exception('訂閱不存在');
    }

    final billing = Billing(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      businessId: businessId,
      subscriptionId: subscriptionId,
      billingDate: billingDate,
      dueDate: billingDate.add(const Duration(days: 7)),
      status: BillingStatus.pending,
      amount: subscription.monthlyAmount,
      taxAmount: subscription.monthlyAmount * 0.05, // 5% 稅
      totalAmount: subscription.monthlyAmount * 1.05,
      staffCount: subscription.staffCount,
      planName: subscription.plan.name,
      pricePerStaff: subscription.plan.pricePerStaffPerMonth,
      notes: '${billingDate.year}年${billingDate.month}月帳單',
    );

    _billings.add(billing);
    return billing;
  }

  // 獲取帳單統計
  Future<Map<String, dynamic>> getBillingStats(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final businessBillings = _billings.where((b) => b.businessId == businessId).toList();
    
    final totalPaid = businessBillings
        .where((b) => b.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
    
    final totalPending = businessBillings
        .where((b) => b.isPending)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
    
    final totalOverdue = businessBillings
        .where((b) => b.isOverdue)
        .fold(0.0, (sum, b) => sum + b.totalAmount);

    return {
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'totalOverdue': totalOverdue,
      'totalBillings': businessBillings.length,
      'paidBillings': businessBillings.where((b) => b.isPaid).length,
      'pendingBillings': businessBillings.where((b) => b.isPending).length,
      'overdueBillings': businessBillings.where((b) => b.isOverdue).length,
    };
  }
} 