import 'package:flutter/material.dart';
import '../models/business_goal.dart';
import '../models/branch.dart';
import '../models/staff.dart';
import '../services/mock_api_service.dart';
import '../widgets/goal_management_form_dialog.dart';

class GoalManagementScreen extends StatefulWidget {
  final String businessId;
  
  const GoalManagementScreen({super.key, required this.businessId});

  @override
  State<GoalManagementScreen> createState() => _GoalManagementScreenState();
}

class _GoalManagementScreenState extends State<GoalManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockApiService _apiService = MockApiService();
  
  List<BusinessGoal> _businessGoals = [];
  List<BusinessGoal> _branchGoals = [];
  List<BusinessGoal> _staffGoals = [];
  List<Branch> _branches = [];
  List<Staff> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final goals = await _apiService.getBusinessGoals(widget.businessId);
      final branches = await _apiService.getBranches(widget.businessId);
      final staff = await _apiService.getStaff(widget.businessId);
      
      setState(() {
        _businessGoals = goals.where((g) => g.level == GoalLevel.business).toList();
        _branchGoals = goals.where((g) => g.level == GoalLevel.branch).toList();
        _staffGoals = goals.where((g) => g.level == GoalLevel.staff).toList();
        _branches = branches;
        _staff = staff;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入數據失敗：$e')),
        );
      }
    }
  }

  void _showGoalFormDialog({
    BusinessGoal? goal,
    required GoalLevel level,
    String? branchId,
    String? staffId,
  }) {
    showDialog(
      context: context,
      builder: (context) => GoalManagementFormDialog(
        businessId: widget.businessId,
        goal: goal,
        level: level,
        branchId: branchId,
        staffId: staffId,
        branches: _branches,
        staff: _staff,
        onSave: (newGoal) {
          setState(() {
            if (goal != null) {
              // 編輯現有目標
              switch (level) {
                case GoalLevel.business:
                  final index = _businessGoals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) _businessGoals[index] = newGoal;
                  break;
                case GoalLevel.branch:
                  final index = _branchGoals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) _branchGoals[index] = newGoal;
                  break;
                case GoalLevel.staff:
                  final index = _staffGoals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) _staffGoals[index] = newGoal;
                  break;
              }
            } else {
              // 新增目標
              switch (level) {
                case GoalLevel.business:
                  _businessGoals.add(newGoal);
                  break;
                case GoalLevel.branch:
                  _branchGoals.add(newGoal);
                  break;
                case GoalLevel.staff:
                  _staffGoals.add(newGoal);
                  break;
              }
            }
          });
        },
      ),
    );
  }

  void _deleteGoal(BusinessGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除目標「${goal.title}」嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                switch (goal.level) {
                  case GoalLevel.business:
                    _businessGoals.removeWhere((g) => g.id == goal.id);
                    break;
                  case GoalLevel.branch:
                    _branchGoals.removeWhere((g) => g.id == goal.id);
                    break;
                  case GoalLevel.staff:
                    _staffGoals.removeWhere((g) => g.id == goal.id);
                    break;
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '業務目標管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '企業目標'),
            Tab(text: '門店目標'),
            Tab(text: '員工目標'),
          ],
          labelColor: const Color(0xFF6C5CE7),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6C5CE7),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusinessGoalsTab(),
          _buildBranchGoalsTab(),
          _buildStaffGoalsTab(),
        ],
      ),
    );
  }

  Widget _buildBusinessGoalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '企業整體目標',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showGoalFormDialog(level: GoalLevel.business),
                icon: const Icon(Icons.add),
                label: const Text('新增企業目標'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildGoalsList(_businessGoals, '尚未設定任何企業目標'),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchGoalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '門店目標',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showGoalFormDialog(level: GoalLevel.branch),
                icon: const Icon(Icons.add),
                label: const Text('新增門店目標'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBranchGoalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffGoalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '員工目標',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showGoalFormDialog(level: GoalLevel.staff),
                icon: const Icon(Icons.add),
                label: const Text('新增員工目標'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildStaffGoalsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<BusinessGoal> goals, String emptyMessage) {
    if (goals.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) => _buildGoalCard(goals[index]),
    );
  }

  Widget _buildBranchGoalsList() {
    if (_branchGoals.isEmpty) {
      return const Center(
        child: Text(
          '尚未設定任何門店目標',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // 按門店分組
    Map<String, List<BusinessGoal>> goalsByBranch = {};
    for (var goal in _branchGoals) {
      if (goal.branchId != null) {
        goalsByBranch.putIfAbsent(goal.branchId!, () => []).add(goal);
      }
    }

    return ListView.builder(
      itemCount: goalsByBranch.keys.length,
      itemBuilder: (context, index) {
        final branchId = goalsByBranch.keys.elementAt(index);
        final branchGoals = goalsByBranch[branchId]!;
        final branch = _branches.firstWhere((b) => b.id == branchId);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              branch.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${branchGoals.length} 個目標'),
            children: branchGoals.map((goal) => _buildGoalCard(goal, showBranchInfo: false)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStaffGoalsList() {
    if (_staffGoals.isEmpty) {
      return const Center(
        child: Text(
          '尚未設定任何員工目標',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // 按員工分組
    Map<String, List<BusinessGoal>> goalsByStaff = {};
    for (var goal in _staffGoals) {
      if (goal.staffId != null) {
        goalsByStaff.putIfAbsent(goal.staffId!, () => []).add(goal);
      }
    }

    return ListView.builder(
      itemCount: goalsByStaff.keys.length,
      itemBuilder: (context, index) {
        final staffId = goalsByStaff.keys.elementAt(index);
        final staffGoals = goalsByStaff[staffId]!;
        final staff = _staff.firstWhere((s) => s.id == staffId);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              staff.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${staff.roleText} • ${staffGoals.length} 個目標'),
            children: staffGoals.map((goal) => _buildGoalCard(goal, showStaffInfo: false)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(BusinessGoal goal, {bool showBranchInfo = true, bool showStaffInfo = true}) {
    final progress = goal.targetValue > 0 ? goal.currentValue / goal.targetValue : 0.0;
    final progressPercentage = (progress * 100).clamp(0, 100);
    
    String subtitle = goal.type.displayName;
    if (showBranchInfo && goal.branchId != null) {
      final branch = _branches.firstWhere((b) => b.id == goal.branchId);
      subtitle += ' • ${branch.name}';
    }
    if (showStaffInfo && goal.staffId != null) {
      final staff = _staff.firstWhere((s) => s.id == goal.staffId);
      subtitle += ' • ${staff.name}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showGoalFormDialog(
                        goal: goal,
                        level: goal.level,
                        branchId: goal.branchId,
                        staffId: goal.staffId,
                      ),
                      tooltip: '編輯目標',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _deleteGoal(goal),
                      tooltip: '刪除目標',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1 ? Colors.green : const Color(0xFF6C5CE7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progress >= 1 ? Colors.green : const Color(0xFF6C5CE7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${goal.currentValue.toStringAsFixed(0)} / ${goal.targetValue.toStringAsFixed(0)} ${goal.unit}',
              style: const TextStyle(fontSize: 14),
            ),
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.description!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 