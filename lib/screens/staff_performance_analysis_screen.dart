import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/staff_performance_analysis.dart';
import '../services/mock_api_service.dart';

class StaffPerformanceAnalysisScreen extends StatefulWidget {
  const StaffPerformanceAnalysisScreen({super.key});

  @override
  State<StaffPerformanceAnalysisScreen> createState() => _StaffPerformanceAnalysisScreenState();
}

class _StaffPerformanceAnalysisScreenState extends State<StaffPerformanceAnalysisScreen> {
  final MockApiService _apiService = MockApiService();
  List<StaffPerformanceAnalysis> _allAnalyses = [];
  StaffPerformanceAnalysis? _selectedAnalysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final analyses = await _apiService.getAllStaffPerformanceAnalyses('business_001');
      
      setState(() {
        _allAnalyses = analyses;
        _selectedAnalysis = analyses.isNotEmpty ? analyses.first : null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('員工績效分析'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allAnalyses.isEmpty
              ? const Center(
                  child: Text(
                    '暫無員工績效數據',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Row(
                  children: [
                    // 左側員工列表
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: const Text(
                              '員工列表',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _allAnalyses.length,
                              itemBuilder: (context, index) {
                                final analysis = _allAnalyses[index];
                                final isSelected = _selectedAnalysis?.staffId == analysis.staffId;
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue[100] : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected ? Colors.blue : Colors.grey[400],
                                      child: Text(
                                        analysis.staffName[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      analysis.staffName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue[800] : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(analysis.roleDisplayName),
                                        const SizedBox(height: 4),
                                        Text(
                                          'NT\$ ${_formatMoney(analysis.totalRevenue)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: isSelected ? Colors.blue : Colors.grey,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedAnalysis = analysis;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 右側詳細分析
                    Expanded(
                      child: _selectedAnalysis == null
                          ? const Center(
                              child: Text(
                                '請選擇員工查看詳細分析',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : _buildAnalysisDetail(_selectedAnalysis!),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAnalysisDetail(StaffPerformanceAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 員工基本信息
          _buildStaffHeader(analysis),
          
          const SizedBox(height: 24),
          
          // 總體績效概覽
          _buildOverviewCards(analysis),
          
          const SizedBox(height: 24),
          
          // 門店收益分布
          const Text(
            '門店收益分布',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBranchRevenueChart(analysis),
          
          const SizedBox(height: 24),
          
          // 門店績效詳情
          const Text(
            '各門店績效詳情',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildBranchPerformanceCards(analysis),
          
          const SizedBox(height: 24),
          
          // 服務收益分析
          const Text(
            '服務收益分析',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceRevenueChart(analysis),
          
          const SizedBox(height: 16),
          
          _buildServicePerformanceTable(analysis),
        ],
      ),
    );
  }

  Widget _buildStaffHeader(StaffPerformanceAnalysis analysis) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Text(
                analysis.staffName[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.staffName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    analysis.roleDisplayName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '本月總營收：NT\$ ${_formatMoney(analysis.totalRevenue)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 主要收入來源
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '主要門店',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  analysis.topRevenueBranch?.branchName ?? '無',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '主要服務',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  analysis.topRevenueService?.serviceName ?? '無',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(StaffPerformanceAnalysis analysis) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            '總預約數',
            '${analysis.totalAppointmentCount}',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            '服務客戶',
            '${analysis.totalCustomerCount}',
            Icons.people,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            '平均單價',
            'NT\$ ${analysis.averageServicePrice.toInt()}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            '工作門店',
            '${analysis.branchPerformances.length}',
            Icons.store,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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

  Widget _buildBranchRevenueChart(StaffPerformanceAnalysis analysis) {
    final distributions = analysis.branchRevenueDistribution;
    
    if (distributions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('暫無門店收益數據'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: distributions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dist = entry.value;
                    final colors = [
                      Colors.blue,
                      Colors.orange,
                      Colors.green,
                      Colors.purple,
                      Colors.red,
                      Colors.teal,
                    ];
                    
                    return PieChartSectionData(
                      value: dist.percentage,
                      title: '${dist.percentage.toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: distributions.asMap().entries.map((entry) {
                final index = entry.key;
                final dist = entry.value;
                final colors = [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                  Colors.red,
                  Colors.teal,
                ];
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dist.branchName} (NT\$ ${_formatMoney(dist.revenue)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBranchPerformanceCards(StaffPerformanceAnalysis analysis) {
    return analysis.branchPerformances.map((branchPerf) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    branchPerf.branchName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'NT\$ ${_formatMoney(branchPerf.revenue)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBranchStatItem(
                      '預約數',
                      '${branchPerf.appointmentCount}',
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildBranchStatItem(
                      '客戶數',
                      '${branchPerf.customerCount}',
                      Icons.people,
                    ),
                  ),
                  Expanded(
                    child: _buildBranchStatItem(
                      '平均單價',
                      'NT\$ ${branchPerf.averageServicePrice.toInt()}',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '主要服務項目',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...branchPerf.servicePerformances.map((service) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(service.serviceName),
                      ),
                      Text(
                        '${service.appointmentCount} 次',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'NT\$ ${_formatMoney(service.revenue)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBranchStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceRevenueChart(StaffPerformanceAnalysis analysis) {
    final services = analysis.overallServicePerformances;
    
    if (services.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('暫無服務收益數據'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '服務收益占比',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: services.map((s) => s.revenuePercentage).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final service = services[group.x.toInt()];
                        return BarTooltipItem(
                          '${service.serviceName}\n${service.revenuePercentage.toStringAsFixed(1)}%\nNT\$ ${_formatMoney(service.revenue)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < services.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                services[value.toInt()].serviceName,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: service.revenuePercentage,
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePerformanceTable(StaffPerformanceAnalysis analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服務績效詳情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '服務項目',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '次數',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '平均價格',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '總收益',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '占比',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...analysis.overallServicePerformances.map((service) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(service.serviceName),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('${service.appointmentCount}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('NT\$ ${service.averagePrice.toInt()}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'NT\$ ${_formatMoney(service.revenue)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${service.revenuePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
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