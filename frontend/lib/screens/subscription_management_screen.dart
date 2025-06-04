import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';
import '../models/subscription.dart';
import '../services/mock_subscription_service.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  final String businessId;

  const SubscriptionManagementScreen({super.key, required this.businessId});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final MockSubscriptionService _subscriptionService = MockSubscriptionService();
  Subscription? currentSubscription;
  List<SubscriptionPlan> availablePlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final subscription = await _subscriptionService.getCurrentSubscription(widget.businessId);
      final plans = SubscriptionPlan.getAvailablePlans();
      
      setState(() {
        currentSubscription = subscription;
        availablePlans = plans;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入失敗: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('方案管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentSubscriptionCard(),
                    const SizedBox(height: 24),
                    _buildPlanComparisonSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    if (currentSubscription == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '尚未訂閱任何方案',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('請選擇適合您的方案'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showPlanSelectionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('選擇方案'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '當前方案',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentSubscription!.statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentSubscription!.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentSubscription!.plan.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentSubscription!.plan.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '員工數量',
                    '${currentSubscription!.staffCount} 位',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '月費金額',
                    '${currentSubscription!.monthlyAmount.toInt()} 元',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '門店限制',
                    currentSubscription!.plan.branchLimitDescription,
                    Icons.store,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '到期日',
                    currentSubscription!.formattedEndDate,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            if (currentSubscription!.isExpiringSoon) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '您的方案將於 ${currentSubscription!.daysUntilExpiry} 天後到期',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showPlanSelectionDialog,
                    child: const Text('變更方案'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/billing');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('查看帳單'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '方案比較',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...availablePlans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = currentSubscription?.planId == plan.id;
    final currentPlanType = currentSubscription?.plan.type;
    
    // 判斷是升級還是降級
    String getActionText() {
      if (currentSubscription == null) return '選擇此方案';
      if (isCurrentPlan) return '當前方案';
      
      if (currentPlanType == PlanType.basic && plan.type == PlanType.business) {
        return '升級至此方案';
      } else if (currentPlanType == PlanType.business && plan.type == PlanType.basic) {
        return '降級至此方案';
      } else {
        return '變更至此方案';
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '當前方案',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  plan.formattedPrice,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                const Text(
                  ' / 員工 / 月',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.branchLimitDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '功能特色:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (!isCurrentPlan) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectPlan(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(getActionText()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlanSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('方案管理'),
        content: const Text('您可以在下方比較不同方案並選擇適合的方案'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _selectPlan(SubscriptionPlan plan) {
    final currentPlanType = currentSubscription?.plan.type;
    
    // 判斷動作類型
    String actionType = '選擇';
    if (currentSubscription != null) {
      if (currentPlanType == PlanType.basic && plan.type == PlanType.business) {
        actionType = '升級至';
      } else if (currentPlanType == PlanType.business && plan.type == PlanType.basic) {
        actionType = '降級至';
      } else {
        actionType = '變更至';
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionType ${plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('您確定要$actionType ${plan.name} 嗎？'),
            const SizedBox(height: 8),
            Text(
              '費用: ${plan.formattedPrice} / 員工 / 月',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('門店限制: ${plan.branchLimitDescription}'),
            if (currentSubscription != null && actionType == '降級至') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '注意：降級可能會限制部分功能的使用',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmPlanSelection(plan, actionType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  void _confirmPlanSelection(SubscriptionPlan plan, String actionType) {
    // 這裡應該調用 API 來更新訂閱
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已$actionType ${plan.name}，請前往帳單頁面完成付款'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    
    // 重新載入數據
    _loadData();
  }
} 