import 'package:flutter/material.dart';
import '../models/service.dart';
import 'package:intl/intl.dart';

class ServiceListTile extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceListTile({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // 服務名稱
            Expanded(
              flex: 2,
              child: Text(
                service.name,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            // 所需時間
            Expanded(
              child: Text(
                '${service.duration} 分鐘',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            // 回訪週期
            Expanded(
              child: Text(
                '${service.revisitPeriod} 天',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            // 價格
            Expanded(
              child: Text(
                'NT\$ ${NumberFormat('#,###').format(service.price)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            // 利潤
            Expanded(
              child: Text(
                'NT\$ ${NumberFormat('#,###').format(service.profit)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 操作按鈕
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 編輯按鈕
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C5CE7),
                    side: const BorderSide(color: Color(0xFF6C5CE7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('編輯'),
                ),
                const SizedBox(width: 10),
                // 更多選項按鈕
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else if (value == 'archive') {
                        // 這裡應該添加存檔功能的處理邏輯
                      }
                    },
                    itemBuilder: (context) => [
                      if (!service.isArchived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('存檔', style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('刪除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hair:
        return Colors.blue;
      case ServiceCategory.nail:
        return Colors.pink;
      case ServiceCategory.skin:
        return Colors.teal;
      case ServiceCategory.lash:
        return Colors.purple;
      case ServiceCategory.pmu:
        return Colors.deepOrange;
      case ServiceCategory.other:
        return Colors.grey;
    }
  }
} 