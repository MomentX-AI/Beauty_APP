import 'package:flutter/material.dart';
import '../models/billing.dart';
import '../services/mock_subscription_service.dart';

class BillingManagementScreen extends StatefulWidget {
  final String businessId;

  const BillingManagementScreen({super.key, required this.businessId});

  @override
  State<BillingManagementScreen> createState() => _BillingManagementScreenState();
}

class _BillingManagementScreenState extends State<BillingManagementScreen> {
  final MockSubscriptionService _subscriptionService = MockSubscriptionService();
  List<Billing> billings = [];
  Map<String, dynamic> stats = {};
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
      final [billingsResult, statsResult] = await Future.wait([
        _subscriptionService.getBillings(widget.businessId),
        _subscriptionService.getBillingStats(widget.businessId),
      ]);
      
      setState(() {
        billings = billingsResult as List<Billing>;
        stats = statsResult as Map<String, dynamic>;
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
        title: const Text('帳單管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
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
                    _buildStatsSection(),
                    const SizedBox(height: 24),
                    _buildBillingsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    if (stats.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '帳單統計',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '已付款',
                'NT\$ ${stats['totalPaid']?.toInt() ?? 0}',
                '${stats['paidBillings'] ?? 0} 筆',
                const Color(0xFF4CAF50),
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '待付款',
                'NT\$ ${stats['totalPending']?.toInt() ?? 0}',
                '${stats['pendingBillings'] ?? 0} 筆',
                const Color(0xFFFF9800),
                Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '逾期未付',
                'NT\$ ${stats['totalOverdue']?.toInt() ?? 0}',
                '${stats['overdueBillings'] ?? 0} 筆',
                const Color(0xFFF44336),
                Icons.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '總帳單',
                '${stats['totalBillings'] ?? 0} 筆',
                '',
                const Color(0xFF6C5CE7),
                Icons.receipt_long,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
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
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '帳單記錄',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _generateNewBilling,
              icon: const Icon(Icons.add),
              label: const Text('生成帳單'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (billings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暫無帳單記錄',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...billings.map((billing) => _buildBillingCard(billing)).toList(),
      ],
    );
  }

  Widget _buildBillingCard(Billing billing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        billing.planName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        billing.notes ?? '帳單',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: billing.statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    billing.statusDisplayName,
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
            Row(
              children: [
                Expanded(
                  child: _buildBillingInfo('帳單日期', billing.formattedBillingDate),
                ),
                Expanded(
                  child: _buildBillingInfo('到期日', billing.formattedDueDate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBillingInfo('員工數量', '${billing.staffCount} 位'),
                ),
                Expanded(
                  child: _buildBillingInfo('單價', billing.formattedAmount),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBillingInfo('稅額', billing.formattedTaxAmount),
                ),
                Expanded(
                  child: _buildBillingInfo(
                    '總金額',
                    billing.formattedTotalAmount,
                    isTotal: true,
                  ),
                ),
              ],
            ),
            if (billing.isPaid && billing.paidDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBillingInfo('付款日期', billing.formattedPaidDate),
                  ),
                  Expanded(
                    child: _buildBillingInfo('付款方式', billing.paymentMethodDisplayName),
                  ),
                ],
              ),
            ],
            if (billing.isOverdue) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已逾期 ${billing.daysOverdue} 天',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!billing.isPaid) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showBillingDetails(billing),
                      child: const Text('查看詳情'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPaymentDialog(billing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('立即付款'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showBillingDetails(billing),
                  child: const Text('查看詳情'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfo(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF6C5CE7) : null,
          ),
        ),
      ],
    );
  }

  void _showBillingDetails(Billing billing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('帳單詳情 - ${billing.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('方案名稱', billing.planName),
              _buildDetailRow('帳單日期', billing.formattedBillingDate),
              _buildDetailRow('到期日', billing.formattedDueDate),
              _buildDetailRow('員工數量', '${billing.staffCount} 位'),
              _buildDetailRow('每位員工單價', 'NT\$ ${billing.pricePerStaff.toInt()}'),
              _buildDetailRow('小計', billing.formattedAmount),
              _buildDetailRow('稅額 (5%)', billing.formattedTaxAmount),
              const Divider(),
              _buildDetailRow('總金額', billing.formattedTotalAmount, isTotal: true),
              if (billing.isPaid) ...[
                const Divider(),
                _buildDetailRow('付款日期', billing.formattedPaidDate),
                _buildDetailRow('付款方式', billing.paymentMethodDisplayName),
                if (billing.paymentReference != null)
                  _buildDetailRow('交易編號', billing.paymentReference!),
              ],
              if (billing.notes != null) ...[
                const Divider(),
                _buildDetailRow('備註', billing.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF6C5CE7) : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Billing billing) {
    PaymentMethod? selectedMethod;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('選擇付款方式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('帳單金額: ${billing.formattedTotalAmount}'),
              const SizedBox(height: 16),
              ...PaymentMethod.values.map((method) => RadioListTile<PaymentMethod>(
                title: Text(_getPaymentMethodName(method)),
                value: method,
                groupValue: selectedMethod,
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                },
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedMethod != null
                  ? () {
                      Navigator.pop(context);
                      _processBillingPayment(billing, selectedMethod!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
              ),
              child: const Text('確認付款'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return '信用卡';
      case PaymentMethod.bankTransfer:
        return '銀行轉帳';
      case PaymentMethod.cash:
        return '現金';
      case PaymentMethod.other:
        return '其他';
    }
  }

  void _processBillingPayment(Billing billing, PaymentMethod paymentMethod) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('處理付款中...'),
            ],
          ),
        ),
      );

      await _subscriptionService.payBilling(
        billingId: billing.id,
        paymentMethod: paymentMethod,
      );

      Navigator.pop(context); // 關閉載入對話框

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('付款成功！'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      _loadData(); // 重新載入數據
    } catch (e) {
      Navigator.pop(context); // 關閉載入對話框
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('付款失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateNewBilling() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('生成帳單中...'),
            ],
          ),
        ),
      );

      await _subscriptionService.generateBilling(
        businessId: widget.businessId,
        subscriptionId: 'sub_001', // 在實際應用中應該從當前訂閱取得
        billingDate: DateTime.now(),
      );

      Navigator.pop(context); // 關閉載入對話框

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('帳單生成成功！'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      _loadData(); // 重新載入數據
    } catch (e) {
      Navigator.pop(context); // 關閉載入對話框
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成帳單失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 