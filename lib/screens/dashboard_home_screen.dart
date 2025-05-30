import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mock_api_service.dart';
import '../models/business_goal.dart';
import '../models/branch_performance.dart';
import '../models/staff_performance.dart';
import '../models/branch.dart';
import '../services/auth_service.dart';
import '../components/branch_performance_card.dart';
import '../components/staff_performance_card.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final MockApiService _apiService = MockApiService();
  List<BusinessGoal> _goals = [];
  List<BranchPerformance> _branchPerformances = [];
  List<StaffPerformance> _staffPerformances = [];
  List<StaffPerformance> _filteredStaffPerformancesData = [];
  List<Branch> _branches = [];
  bool _isLoading = true;
  String? _selectedBranchId; // null 表示"全部"

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final goals = await _apiService.getBusinessGoals('business_001');
      final branchPerformances = await _apiService.getBranchPerformances('business_001');
      final staffPerformances = await _apiService.getStaffPerformances('business_001');
      final branches = await _apiService.getBranches('business_001');
      
      // 按營收排序，最高的在前面
      branchPerformances.sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));
      staffPerformances.sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));
      
      setState(() {
        _goals = goals;
        _branchPerformances = branchPerformances;
        _staffPerformances = staffPerformances;
        _filteredStaffPerformancesData = staffPerformances; // 初始狀態顯示所有員工
        _branches = branches;
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

  Future<void> _loadStaffPerformancesByBranch(String branchId) async {
    try {
      final branchStaffPerformances = await _apiService.getStaffPerformancesByBranch('business_001', branchId);
      branchStaffPerformances.sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));
      
      setState(() {
        _filteredStaffPerformancesData = branchStaffPerformances;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入員工數據失敗：$e')),
        );
      }
    }
  }

  List<BranchPerformance> get _filteredBranchPerformances {
    if (_selectedBranchId == null) {
      return _branchPerformances;
    }
    return _branchPerformances.where((bp) => bp.branchId == _selectedBranchId).toList();
  }

  List<StaffPerformance> get _filteredStaffPerformances {
    return _filteredStaffPerformancesData;
  }

  String _getTotalRevenue() {
    if (_selectedBranchId == null) {
      // 全部門店的合併營收
      final total = _branchPerformances.fold<double>(0, (sum, bp) => sum + bp.monthlyRevenue);
      return total.toInt().toString();
    } else {
      // 選擇門店的營收
      final selectedBranch = _branchPerformances.firstWhere(
        (bp) => bp.branchId == _selectedBranchId,
        orElse: () => BranchPerformance(
          branchId: '',
          branchName: '',
          monthlyRevenue: 0,
          appointmentCount: 0,
          customerCount: 0,
          averageServicePrice: 0,
          occupancyRate: 0,
          staffCount: 0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        ),
      );
      return selectedBranch.monthlyRevenue.toInt().toString();
    }
  }

  String _getTotalAppointments() {
    if (_selectedBranchId == null) {
      // 全部門店的合併預約數
      final total = _branchPerformances.fold<int>(0, (sum, bp) => sum + bp.appointmentCount);
      return total.toString();
    } else {
      // 選擇門店的預約數
      final selectedBranch = _branchPerformances.firstWhere(
        (bp) => bp.branchId == _selectedBranchId,
        orElse: () => BranchPerformance(
          branchId: '',
          branchName: '',
          monthlyRevenue: 0,
          appointmentCount: 0,
          customerCount: 0,
          averageServicePrice: 0,
          occupancyRate: 0,
          staffCount: 0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        ),
      );
      return selectedBranch.appointmentCount.toString();
    }
  }

  String _getActiveBranches() {
    if (_selectedBranchId == null) {
      return _branchPerformances.length.toString();
    } else {
      return '1'; // 單一門店
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('儀表板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 門店選擇器
                  Row(
                    children: [
                      const Text(
                        '門店篩選：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedBranchId,
                              hint: const Text('選擇門店'),
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedBranchId = newValue;
                                });
                                
                                // 根據選擇的門店重新加載員工績效數據
                                if (newValue == null) {
                                  // 顯示全部員工
                                  setState(() {
                                    _filteredStaffPerformancesData = _staffPerformances;
                                  });
                                } else {
                                  // 載入該門店的員工績效
                                  _loadStaffPerformancesByBranch(newValue);
                                }
                              },
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.store_mall_directory, size: 20, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('全部門店'),
                                    ],
                                  ),
                                ),
                                ..._branches.map<DropdownMenuItem<String?>>((Branch branch) {
                                  return DropdownMenuItem<String?>(
                                    value: branch.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          branch.isDefault ? Icons.home : Icons.store,
                                          size: 20,
                                          color: branch.isDefault ? Colors.orange : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            branch.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // KPI 卡片區域
                  Text(
                    _selectedBranchId == null ? '業務概覽 - 全部門店' : '業務概覽 - ${_branches.firstWhere((b) => b.id == _selectedBranchId).name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildKPICard(
                        '本月營收',
                        'NT\$ ${_getTotalRevenue()}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildKPICard(
                        '本月預約',
                        '${_getTotalAppointments()}',
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                      _buildKPICard(
                        _selectedBranchId == null ? '活躍門店' : '員工數',
                        _selectedBranchId == null ? '${_getActiveBranches()}' : '${_filteredBranchPerformances.isNotEmpty ? _filteredBranchPerformances.first.staffCount : 0}',
                        _selectedBranchId == null ? Icons.store : Icons.person,
                        Colors.purple,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 門店表現排行榜（僅在顯示全部門店時顯示）
                  if (_selectedBranchId == null) ...[
                    const Text(
                      '門店表現排行榜',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filteredBranchPerformances.length,
                        itemBuilder: (context, index) {
                          final performance = _filteredBranchPerformances[index];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 16),
                            child: BranchPerformanceCard(
                              performance: performance,
                              isTopPerformer: index == 0, // 第一名
                              rank: index + 1, // 排名從1開始
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    // 單一門店詳細信息
                    const Text(
                      '門店詳細資訊',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_filteredBranchPerformances.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child: BranchPerformanceCard(
                          performance: _filteredBranchPerformances.first,
                          isTopPerformer: false,
                          rank: null,
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                  
                  // 員工表現排行榜
                  const Text(
                    '員工表現排行榜',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredStaffPerformances.length,
                      itemBuilder: (context, index) {
                        final performance = _filteredStaffPerformances[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 16),
                          child: StaffPerformanceCard(
                            performance: performance,
                            isTopPerformer: index == 0, // 第一名
                            rank: index + 1, // 排名從1開始
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 業務目標進度
                  const Text(
                    '業務目標進度',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._goals.map((goal) => _buildGoalCard(goal)).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // 快速統計
                  _buildQuickStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BusinessGoal goal) {
    final progress = goal.currentValue / goal.targetValue;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
              style: TextStyle(
                color: progress >= 1 ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final branchesToShow = _filteredBranchPerformances.isNotEmpty ? _filteredBranchPerformances : _branchPerformances;
    final staffToShow = _filteredStaffPerformances.isNotEmpty ? _filteredStaffPerformances : _staffPerformances;
    
    if (branchesToShow.isEmpty || staffToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    final topBranch = branchesToShow.first;
    final topStaff = staffToShow.first;
    final avgOccupancyRate = branchesToShow
        .map((b) => b.occupancyRate)
        .reduce((a, b) => a + b) / branchesToShow.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedBranchId == null ? '本月亮點' : '門店亮點',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedBranchId == null) ...[
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '最佳門店：${topBranch.branchName} (NT\$ ${(topBranch.monthlyRevenue / 1000).toInt()}K)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.store, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '門店：${topBranch.branchName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '最佳員工：${topStaff.staffName} (NT\$ ${(topStaff.monthlyRevenue / 1000).toInt()}K)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedBranchId == null 
                        ? '平均預約率：${(avgOccupancyRate * 100).toInt()}%'
                        : '門店預約率：${(avgOccupancyRate * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_selectedBranchId != null && branchesToShow.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '服務客戶：${topBranch.customerCount} 人',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '平均服務價格：NT\$ ${topBranch.averageServicePrice.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 