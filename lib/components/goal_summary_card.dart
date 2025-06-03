import 'package:flutter/material.dart';
import '../models/business_goal.dart';

class GoalSummaryCard extends StatelessWidget {
  final List<BusinessGoal> goals;
  final String? selectedBranchId;

  const GoalSummaryCard({
    super.key,
    required this.goals,
    this.selectedBranchId,
  });

  @override
  Widget build(BuildContext context) {
    final businessGoals = goals.where((g) => g.level == GoalLevel.business).toList();
    final branchGoals = goals.where((g) => g.level == GoalLevel.branch).toList();
    final staffGoals = goals.where((g) => g.level == GoalLevel.staff).toList();

    // 如果选择了特定门店，过滤相关目标
    List<BusinessGoal> filteredBranchGoals = branchGoals;
    List<BusinessGoal> filteredStaffGoals = staffGoals;
    
    if (selectedBranchId != null) {
      filteredBranchGoals = branchGoals.where((g) => g.branchId == selectedBranchId).toList();
      // 员工目标的过滤需要根据实际的员工数据，这里暂时显示所有员工目标
    }

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.purple[50]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.track_changes,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedBranchId == null ? '整體目標達成概覽' : '門店目標達成概覽',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '即時追蹤各層級目標進度',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildGoalSummaryItem(
                    '企業目標',
                    businessGoals,
                    Icons.business,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGoalSummaryItem(
                    selectedBranchId == null ? '門店目標' : '當前門店目標',
                    filteredBranchGoals,
                    Icons.store,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGoalSummaryItem(
                    '員工目標',
                    filteredStaffGoals,
                    Icons.person,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummaryItem(
    String title,
    List<BusinessGoal> goals,
    IconData icon,
    Color color,
  ) {
    final achievementRate = _calculateAchievementRate(goals);
    final completedGoals = goals.where((g) => g.currentValue >= g.targetValue).length;
    final totalGoals = goals.length;

    Color achievementColor;
    if (achievementRate >= 90) {
      achievementColor = Colors.green;
    } else if (achievementRate >= 70) {
      achievementColor = Colors.orange;
    } else {
      achievementColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (totalGoals > 0) ...[
            Row(
              children: [
                Text(
                  '${achievementRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: achievementColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: achievementColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedGoals/$totalGoals',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: achievementColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievementRate / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(achievementColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalGoals == 1 ? '1 個目標' : '$totalGoals 個目標',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ] else ...[
            Text(
              '無目標',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '尚未設定',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateAchievementRate(List<BusinessGoal> goals) {
    if (goals.isEmpty) return 0.0;
    
    final totalAchievement = goals.fold<double>(0, (sum, goal) {
      final rate = goal.targetValue > 0 ? (goal.currentValue / goal.targetValue) * 100 : 0;
      return sum + rate.clamp(0, 100);
    });
    
    return totalAchievement / goals.length;
  }
} 