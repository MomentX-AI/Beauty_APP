import 'package:flutter/material.dart';
import '../models/staff_performance_analysis.dart';

class StaffPerformanceSummaryCard extends StatelessWidget {
  final List<StaffPerformanceAnalysis> analyses;

  const StaffPerformanceSummaryCard({
    super.key,
    required this.analyses,
  });

  @override
  Widget build(BuildContext context) {
    if (analyses.isEmpty) {
      return const SizedBox.shrink();
    }

    // 找出前三名员工
    final topPerformers = analyses.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue))
      ..take(3).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '員工績效排行榜',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // 导航到详细分析页面
                    Navigator.pushNamed(context, '/staff-performance-analysis');
                  },
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('查看詳情'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topPerformers.asMap().entries.map((entry) {
              final index = entry.key;
              final analysis = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRankColor(index).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRankColor(index).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // 排名
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getRankColor(index),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 员工信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.staffName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            analysis.roleDisplayName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 收益信息
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'NT\$ ${_formatMoney(analysis.totalRevenue)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${analysis.branchPerformances.length} 門店',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            if (analyses.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    '還有 ${analyses.length - 3} 位員工',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // 金色
      case 1:
        return Colors.grey[600]!; // 银色
      case 2:
        return Colors.orange[800]!; // 铜色
      default:
        return Colors.blue;
    }
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
} 