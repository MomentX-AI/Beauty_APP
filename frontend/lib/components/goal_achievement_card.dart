import 'package:flutter/material.dart';
import '../models/business_goal.dart';
import '../models/branch.dart';
import '../models/staff.dart';

class GoalAchievementCard extends StatelessWidget {
  final List<BusinessGoal> goals;
  final GoalLevel level;
  final List<Branch>? branches;
  final List<Staff>? staff;
  final String? selectedBranchId;

  const GoalAchievementCard({
    super.key,
    required this.goals,
    required this.level,
    this.branches,
    this.staff,
    this.selectedBranchId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredGoals = _getFilteredGoals();
    
    if (filteredGoals.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  _getLevelIcon(),
                  color: _getLevelColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  level.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getOverallAchievementColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '總達成率 ${_getOverallAchievementRate().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getOverallAchievementColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (level == GoalLevel.business) 
              _buildBusinessGoalsList(filteredGoals)
            else if (level == GoalLevel.branch)
              _buildBranchGoalsList(filteredGoals)
            else
              _buildStaffGoalsList(filteredGoals),
          ],
        ),
      ),
    );
  }

  List<BusinessGoal> _getFilteredGoals() {
    var filteredGoals = goals.where((goal) => goal.level == level).toList();
    
    // 如果选择了特定门店，过滤相关目标
    if (selectedBranchId != null) {
      if (level == GoalLevel.branch) {
        filteredGoals = filteredGoals.where((goal) => goal.branchId == selectedBranchId).toList();
      } else if (level == GoalLevel.staff) {
        // 获取选定门店的员工列表
        final branchStaffIds = staff?.where((s) => s.branchIds.contains(selectedBranchId)).map((s) => s.id).toList() ?? [];
        filteredGoals = filteredGoals.where((goal) => goal.staffId != null && branchStaffIds.contains(goal.staffId)).toList();
      }
    }
    
    return filteredGoals;
  }

  IconData _getLevelIcon() {
    switch (level) {
      case GoalLevel.business:
        return Icons.business;
      case GoalLevel.branch:
        return Icons.store;
      case GoalLevel.staff:
        return Icons.person;
    }
  }

  Color _getLevelColor() {
    switch (level) {
      case GoalLevel.business:
        return Colors.purple;
      case GoalLevel.branch:
        return Colors.blue;
      case GoalLevel.staff:
        return Colors.orange;
    }
  }

  double _getOverallAchievementRate() {
    final filteredGoals = _getFilteredGoals();
    if (filteredGoals.isEmpty) return 0.0;
    
    final totalAchievement = filteredGoals.fold<double>(0, (sum, goal) {
      final rate = goal.targetValue > 0 ? (goal.currentValue / goal.targetValue) * 100 : 0;
      return sum + rate.clamp(0, 100);
    });
    
    return totalAchievement / filteredGoals.length;
  }

  Color _getOverallAchievementColor() {
    final rate = _getOverallAchievementRate();
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBusinessGoalsList(List<BusinessGoal> goals) {
    return Column(
      children: goals.map((goal) => _buildGoalItem(goal)).toList(),
    );
  }

  Widget _buildBranchGoalsList(List<BusinessGoal> goals) {
    if (selectedBranchId != null) {
      // 显示选定门店的目标
      return Column(
        children: goals.map((goal) => _buildGoalItem(goal)).toList(),
      );
    }

    // 按门店分组显示
    final goalsByBranch = <String, List<BusinessGoal>>{};
    for (final goal in goals) {
      if (goal.branchId != null) {
        goalsByBranch.putIfAbsent(goal.branchId!, () => []).add(goal);
      }
    }

    return Column(
      children: goalsByBranch.entries.map((entry) {
        final branchId = entry.key;
        final branchGoals = entry.value;
        final branch = branches?.firstWhere((b) => b.id == branchId, orElse: () => Branch(
          id: branchId,
          businessId: '',
          name: '未知門店',
          address: '',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    branch?.isDefault == true ? Icons.home : Icons.store,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    branch?.name ?? '未知門店',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...branchGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildGoalItem(goal, compact: true),
              )).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStaffGoalsList(List<BusinessGoal> goals) {
    // 按员工分组显示
    final goalsByStaff = <String, List<BusinessGoal>>{};
    for (final goal in goals) {
      if (goal.staffId != null) {
        goalsByStaff.putIfAbsent(goal.staffId!, () => []).add(goal);
      }
    }

    return Column(
      children: goalsByStaff.entries.map((entry) {
        final staffId = entry.key;
        final staffGoals = entry.value;
        final staffMember = staff?.firstWhere((s) => s.id == staffId, orElse: () => Staff(
          id: staffId,
          businessId: '',
          name: '未知員工',
          role: StaffRole.assistant,
          branchIds: [],
          serviceIds: [],
          hireDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    staffMember?.name ?? '未知員工',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      staffMember?.roleText ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...staffGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildGoalItem(goal, compact: true),
              )).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalItem(BusinessGoal goal, {bool compact = false}) {
    final progress = goal.targetValue > 0 ? goal.currentValue / goal.targetValue : 0.0;
    final progressPercentage = (progress * 100).clamp(0, 100);
    
    Color progressColor;
    if (progressPercentage >= 100) {
      progressColor = Colors.green;
    } else if (progressPercentage >= 80) {
      progressColor = Colors.blue;
    } else if (progressPercentage >= 60) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: compact ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: compact ? 4 : 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatValue(goal.currentValue)} / ${_formatValue(goal.targetValue)} ${goal.unit}',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: Colors.grey[600],
                ),
              ),
              if (!compact)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    goal.type.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
} 