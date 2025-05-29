import 'package:flutter/material.dart';
import '../models/branch_performance.dart';
import 'package:intl/intl.dart';

class BranchPerformanceCard extends StatelessWidget {
  final BranchPerformance performance;
  final bool isTopPerformer;
  final int? rank;

  const BranchPerformanceCard({
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (rank != null)
                          Container(
                            width: 24,
                            height: 24,
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
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        if (rank != null) const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            performance.branchName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTopPerformer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⭐ 最佳',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
              
              const SizedBox(height: 4),
              
              // 關鍵指標網格
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
              
              const SizedBox(height: 2),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      '預約率',
                      '${(performance.occupancyRate * 100).toInt()}%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      '員工數',
                      '${performance.staffCount}',
                      Icons.person,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // 效率指標
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '每員工營收',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'NT\$ ${formatter.format(performance.revenuePerStaff.toInt())}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
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
                        Expanded(
                          child: Text(
                            'NT\$ ${formatter.format(performance.averageServicePrice.toInt())}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
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