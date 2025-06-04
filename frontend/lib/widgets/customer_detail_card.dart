import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'package:intl/intl.dart';

class CustomerDetailCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onUpdate;

  const CustomerDetailCard({
    super.key,
    required this.customer,
    this.onUpdate,
  });

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 24),
            _buildSectionTitle('消費統計'),
            const SizedBox(height: 16),
            _buildInfoRow('總消費金額', 'NT\$ 12,500'),
            _buildInfoRow('平均單次消費', 'NT\$ 2,500'),
            _buildInfoRow('累計服務次數', '5 次'),
            const SizedBox(height: 24),
            _buildSectionTitle('服務記錄'),
            const SizedBox(height: 16),
            _buildServiceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement edit customer
          },
          icon: const Icon(Icons.edit),
          label: const Text('編輯'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement archive/unarchive customer
          },
          icon: Icon(customer.isArchived ? Icons.unarchive : Icons.archive),
          label: Text(customer.isArchived ? '取消歸檔' : '歸檔'),
          style: ElevatedButton.styleFrom(
            backgroundColor: customer.isArchived ? Colors.green : Colors.orange,
          ),
        ),
        if (customer.needsMerge) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement merge customer
            },
            icon: const Icon(Icons.merge),
            label: const Text('合併客戶'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '基本資料',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (customer.isArchived)
                  const Chip(
                    label: Text('已歸檔'),
                    backgroundColor: Colors.grey,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('姓名', customer.name),
            _buildInfoRow('性別', customer.gender ?? '未設定'),
            _buildInfoRow('電話', customer.phone ?? '未設定'),
            _buildInfoRow('Email', customer.email ?? '未設定'),
            _buildInfoRow('建立時間', _formatDate(customer.createdAt)),
            _buildInfoRow('最後更新', _formatDate(customer.updatedAt)),
            if (customer.isSpecialCustomer)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '特殊客戶',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (customer.needsMerge)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      '需要合併',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label：',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServiceHistory() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '排序',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '最新',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildServiceHistoryItem(
          date: '2025/04/10',
          service: '剪髮染髮',
          price: 'NT\$ 2,600',
          stylist: '王小美',
          note: '客戶對剪髮效果非常滿意',
        ),
        const SizedBox(height: 8),
        _buildServiceHistoryItem(
          date: '2025/03/15',
          service: '護髮',
          price: 'NT\$ 1,800',
          stylist: '王小美',
          note: '使用高級護髮產品',
        ),
      ],
    );
  }

  Widget _buildServiceHistoryItem({
    required String date,
    required String service,
    required String price,
    required String stylist,
    required String note,
  }) {
    return Card(
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              '美髮師：$stylist',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '備註：$note',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_library, size: 16),
                label: const Text('查看照片'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 