import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_card.dart';
import '../widgets/line_chart.dart';
import '../widgets/progress_bar.dart';
import '../widgets/goal_form_dialog.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = '本月';

  final List<Map<String, dynamic>> _statCards = [
    {
      'title': '總營收',
      'value': 'NT\$ 158,600',
      'trend': '+12%',
      'trendUp': true,
      'subtitle': '相比上月',
    },
    {
      'title': '服務數量',
      'value': '78 次',
      'trend': '+8%',
      'trendUp': true,
      'subtitle': '相比上月',
    },
    {
      'title': '客戶回訪率',
      'value': '65%',
      'trend': '-5%',
      'trendUp': false,
      'subtitle': '相比上月',
    },
    {
      'title': '平均利潤率',
      'value': '68%',
      'trend': '+3%',
      'trendUp': true,
      'subtitle': '相比上月',
    },
  ];

  final List<Map<String, dynamic>> _goals = [
    {
      'id': '1',
      'title': '營收目標',
      'type': '營收',
      'target': 'NT\$ 200,000',
      'current': 'NT\$ 158,600',
      'percentage': 79,
      'deadline': DateTime.now().add(const Duration(days: 30)),
    },
    {
      'id': '2',
      'title': '回訪率目標',
      'type': '回訪率',
      'target': '75%',
      'current': '65%',
      'percentage': 86,
      'deadline': DateTime.now().add(const Duration(days: 60)),
    },
  ];

  void _updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case '今天':
          _startDate = now;
          _endDate = now;
          break;
        case '本月':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case '本季':
          final quarter = (now.month - 1) ~/ 3;
          _startDate = DateTime(now.year, quarter * 3 + 1, 1);
          _endDate = DateTime(now.year, (quarter + 1) * 3 + 1, 0);
          break;
        case '本年':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
  }

  void _showGoalFormDialog({Map<String, dynamic>? goal}) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        goal: goal,
        onSave: (newGoal) {
          setState(() {
            if (goal != null) {
              // 編輯現有目標
              final index = _goals.indexWhere((g) => g['id'] == goal['id']);
              if (index != -1) {
                _goals[index] = newGoal;
              }
            } else {
              // 新增目標
              _goals.add(newGoal);
            }
          });
        },
      ),
    );
  }

  void _deleteGoal(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除此經營目標嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                _goals.removeWhere((goal) => goal['id'] == id);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '經營報表',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 20),
            _buildStatCards(),
            const SizedBox(height: 20),
            _buildRevenueChart(),
            const SizedBox(height: 20),
            _buildGoalsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalFormDialog(),
        backgroundColor: const Color(0xFF6C5CE7),
        tooltip: '新增經營目標',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '日期範圍',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: '開始日期',
                  value: _startDate,
                  onChanged: (date) {
                    setState(() => _startDate = date);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: '結束日期',
                  value: _endDate,
                  onChanged: (date) {
                    setState(() => _endDate = date);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodButton('今天', 'today'),
                _buildPeriodButton('本月', 'month'),
                _buildPeriodButton('本季', 'quarter'),
                _buildPeriodButton('本年', 'year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              DateFormat('yyyy/MM/dd').format(value),
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => _updateDateRange(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _statCards.length,
      itemBuilder: (context, index) {
        final card = _statCards[index];
        return StatCard(
          title: card['title'],
          value: card['value'],
          trend: card['trend'],
          trendUp: card['trendUp'],
          subtitle: card['subtitle'],
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '營收趨勢',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: RevenueLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '經營目標達成率',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showGoalFormDialog(),
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF6C5CE7),
                  size: 16,
                ),
                label: const Text(
                  '新增目標',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_goals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '尚未設定任何經營目標',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _goals.length,
              (index) => _buildGoalItem(_goals[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    final deadline = goal['deadline'] as DateTime;
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${goal['title']}: ${goal['target']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: Colors.blue,
                          onPressed: () => _showGoalFormDialog(goal: goal),
                          tooltip: '編輯目標',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          onPressed: () => _deleteGoal(goal['id']),
                          tooltip: '刪除目標',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '當前值: ${goal['current']}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ProgressBar(
                        percentage: goal['percentage'],
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${goal['percentage']}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isExpired ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '截止日期: ${DateFormat('yyyy/MM/dd').format(deadline)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.red : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: daysLeft <= 7 ? Colors.orange.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '剩餘 $daysLeft 天',
                          style: TextStyle(
                            fontSize: 10,
                            color: daysLeft <= 7 ? Colors.deepOrange : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '已過期',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 