import 'package:flutter/material.dart';
import '../models/staff_performance.dart';
import 'package:intl/intl.dart';

class StaffPerformanceCard extends StatelessWidget {
  final StaffPerformance performance;
  final bool isTopPerformer;
  final int? rank;

  const StaffPerformanceCard({
    super.key,
    required this.performance,
    this.isTopPerformer = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0');
    
    return Card(
      elevation: isTopPerformer ? 8 : 4,
      shadowColor: isTopPerformer ? Colors.amber.withOpacity(0.5) : null,
      child: Container(
        decoration: isTopPerformer
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 排名指示器
                  if (rank != null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank!),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  if (rank != null) const SizedBox(width: 6),
                  
                  // 頭像
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: performance.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              performance.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 24),
                            ),
                          )
                        : const Icon(Icons.person, size: 24),
                  ),
                  const SizedBox(width: 8),
                  
                  // 姓名和職位
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                performance.staffName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isTopPerformer)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '⭐ MVP',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          performance.roleDisplayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 營收指標
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green, size: 14),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      'NT\$ ${formatter.format(performance.monthlyRevenue)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Text(
                '本月營收',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // 關鍵指標
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      '預約數',
                      '${performance.appointmentCount}',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      '客戶數',
                      '${performance.customerCount}',
                      Icons.people,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      '完成率',
                      '${(performance.completionRate * 100).toInt()}%',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      '滿意度',
                      '${performance.customerSatisfactionScore.toStringAsFixed(1)}',
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // 額外指標
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '出勤率',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(performance.attendanceRate * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: performance.attendanceRate >= 0.95 
                                ? Colors.green 
                                : performance.attendanceRate >= 0.90 
                                    ? Colors.orange 
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '平均服務價格',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'NT\$ ${formatter.format(performance.averageServicePrice.toInt())}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
} 