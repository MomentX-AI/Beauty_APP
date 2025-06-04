import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/staff_schedule.dart';
import '../models/staff.dart';
import '../models/branch.dart';
import '../services/mock_data_service.dart';
import '../widgets/staff_schedule_form_dialog.dart';

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({Key? key}) : super(key: key);

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  List<StaffSchedule> _schedules = [];
  List<Staff> _staff = [];
  List<Branch> _branches = [];
  bool _isLoading = true;
  String _selectedView = 'week'; // 'week' or 'month'
  DateTime _selectedDate = DateTime.now();
  String? _selectedStaffId;
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final staff = MockDataService.getMockStaff('1');
      final branches = MockDataService.getMockBranches('1');
      final schedules = MockDataService.getMockStaffSchedules('1');
      
      setState(() {
        _staff = staff;
        _branches = branches;
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入資料失敗: $e')),
      );
    }
  }

  List<StaffSchedule> get _filteredSchedules {
    var filtered = _schedules;
    
    if (_selectedStaffId != null) {
      filtered = filtered.where((s) => s.staffId == _selectedStaffId).toList();
    }
    
    if (_selectedBranchId != null) {
      filtered = filtered.where((s) => s.branchId == _selectedBranchId).toList();
    }
    
    // 根據視圖類型過濾日期範圍
    if (_selectedView == 'week') {
      final weekStart = _getWeekStart(_selectedDate);
      final weekEnd = weekStart.add(const Duration(days: 6));
      filtered = filtered.where((s) => 
        s.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        s.date.isBefore(weekEnd.add(const Duration(days: 1)))
      ).toList();
    } else {
      final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      filtered = filtered.where((s) => 
        s.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        s.date.isBefore(monthEnd.add(const Duration(days: 1)))
      ).toList();
    }
    
    return filtered;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  void _addSchedule() {
    showDialog(
      context: context,
      builder: (context) => StaffScheduleFormDialog(
        staff: _staff,
        branches: _branches,
        selectedDate: _selectedDate,
        onSave: (schedule) {
          setState(() {
            _schedules.add(schedule);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('排班已新增')),
          );
        },
      ),
    );
  }

  void _editSchedule(StaffSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => StaffScheduleFormDialog(
        staff: _staff,
        branches: _branches,
        selectedDate: schedule.date,
        schedule: schedule,
        onSave: (updatedSchedule) {
          setState(() {
            final index = _schedules.indexWhere((s) => s.id == schedule.id);
            if (index != -1) {
              _schedules[index] = updatedSchedule;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('排班已更新')),
          );
        },
      ),
    );
  }

  void _deleteSchedule(StaffSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除 ${schedule.staffName} 在 ${DateFormat('MM/dd').format(schedule.date)} 的排班嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _schedules.removeWhere((s) => s.id == schedule.id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('排班已刪除')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('員工班表'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          // 視圖切換
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'week', label: Text('週視圖')),
              ButtonSegment(value: 'month', label: Text('月視圖')),
            ],
            selected: {_selectedView},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedView = selection.first;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 過濾器和導航
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      // 日期導航
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedView == 'week') {
                                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                                } else {
                                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                                }
                              });
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            _selectedView == 'week'
                                ? '${DateFormat('yyyy/MM/dd').format(_getWeekStart(_selectedDate))} - ${DateFormat('MM/dd').format(_getWeekStart(_selectedDate).add(const Duration(days: 6)))}'
                                : DateFormat('yyyy年 MM月').format(_selectedDate),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedView == 'week') {
                                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                                } else {
                                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                                }
                              });
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 過濾器
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStaffId,
                              decoration: const InputDecoration(
                                labelText: '員工',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('全部員工')),
                                ..._staff.map((staff) => DropdownMenuItem(
                                  value: staff.id,
                                  child: Text(staff.name),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStaffId = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBranchId,
                              decoration: const InputDecoration(
                                labelText: '門店',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('全部門店')),
                                ..._branches.map((branch) => DropdownMenuItem(
                                  value: branch.id,
                                  child: Text(branch.name),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedBranchId = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 班表內容
                Expanded(
                  child: _selectedView == 'week' 
                      ? _buildWeekView() 
                      : _buildMonthView(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekView() {
    final weekStart = _getWeekStart(_selectedDate);
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // 星期標題
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: weekDays.map((day) => Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        ['一', '二', '三', '四', '五', '六', '日'][day.weekday - 1],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('MM/dd').format(day),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          
          // 員工排班
          ..._staff.where((staff) => 
            _selectedStaffId == null || staff.id == _selectedStaffId
          ).map((staff) => _buildStaffWeekRow(staff, weekDays)),
        ],
      ),
    );
  }

  Widget _buildStaffWeekRow(Staff staff, List<DateTime> weekDays) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 員工名稱
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: staff.roleColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: staff.roleColor.withOpacity(0.2),
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0] : 'S',
                    style: TextStyle(
                      fontSize: 12,
                      color: staff.roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  staff.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: staff.roleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    staff.roleText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 每日班表
          Row(
            children: weekDays.map((day) {
              final daySchedules = _filteredSchedules.where((s) => 
                s.staffId == staff.id && 
                s.date.year == day.year &&
                s.date.month == day.month &&
                s.date.day == day.day
              ).toList();
              
              return Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: daySchedules.isEmpty
                      ? GestureDetector(
                          onTap: () => _addScheduleForStaffAndDate(staff, day),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: daySchedules.map((schedule) => 
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _editSchedule(schedule),
                                onLongPress: () => _deleteSchedule(schedule),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: schedule.shiftTypeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: schedule.shiftTypeColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        schedule.shiftTypeText,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: schedule.shiftTypeColor,
                                        ),
                                      ),
                                      if (schedule.timeRange != '休假')
                                        Text(
                                          schedule.timeRange,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: schedule.shiftTypeColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    // 簡化的月視圖，顯示每天的排班統計
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = monthEnd.day;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = DateTime(monthStart.year, monthStart.month, index + 1);
        final daySchedules = _filteredSchedules.where((s) => 
          s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day
        ).toList();
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
              _selectedView = 'week';
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: daySchedules.isEmpty ? Colors.grey.shade100 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: day.day == DateTime.now().day &&
                       day.month == DateTime.now().month &&
                       day.year == DateTime.now().year
                    ? Colors.blue
                    : Colors.grey.shade300,
                width: day.day == DateTime.now().day &&
                       day.month == DateTime.now().month &&
                       day.year == DateTime.now().year
                    ? 2
                    : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (daySchedules.isNotEmpty)
                  Text(
                    '${daySchedules.length}班',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade600,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addScheduleForStaffAndDate(Staff staff, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => StaffScheduleFormDialog(
        staff: _staff,
        branches: _branches,
        selectedDate: date,
        preSelectedStaffId: staff.id,
        onSave: (schedule) {
          setState(() {
            _schedules.add(schedule);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('排班已新增')),
          );
        },
      ),
    );
  }
} 