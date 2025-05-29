import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../models/branch.dart';
import '../services/mock_api_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form_dialog.dart';
import 'staff_schedule_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final String businessId;
  
  const AppointmentScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<Appointment> _appointments = [];
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isLoading = true;
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 載入門店列表
      final branches = await _apiService.getBranches(widget.businessId);
      setState(() {
        _branches = branches;
        // 預設選擇第一個門店（通常是總店）
        if (branches.isNotEmpty) {
          _selectedBranch = branches.first;
        }
      });
      
      // 載入預約資料
      await _loadAppointments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗：$e')),
        );
      }
    }
  }

  Future<void> _loadAppointments() async {
    if (_selectedBranch == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await _apiService.getBusinessAppointments(widget.businessId);
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入預約失敗：$e')),
        );
      }
    }
  }

  void _onBranchChanged(Branch? branch) {
    if (branch != null && branch != _selectedBranch) {
      setState(() {
        _selectedBranch = branch;
      });
      _loadAppointments();
    }
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppointmentFormDialog(
        businessId: widget.businessId,
        selectedDate: _selectedDay,
        onSave: (appointment) async {
          try {
            await _apiService.createAppointment(appointment);
            if (mounted) {
              Navigator.pop(context);
              _loadAppointments();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('新增預約失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditAppointmentDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentFormDialog(
        businessId: widget.businessId,
        appointment: appointment,
        selectedDate: _selectedDay,
        onSave: (updatedAppointment) async {
          try {
            await _apiService.updateAppointment(appointment.id, updatedAppointment);
            if (mounted) {
              Navigator.pop(context);
              _loadAppointments();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('更新預約失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除預約「${appointment.customer?.name ?? '未知客戶'}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteAppointment(appointment.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadAppointments();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刪除預約失敗：$e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  List<Appointment> get _filteredAppointments {
    return _appointments.where((appointment) {
      final appointmentDate = appointment.startTime;
      final isSameDay = appointmentDate.year == _selectedDay.year &&
          appointmentDate.month == _selectedDay.month &&
          appointmentDate.day == _selectedDay.day;
      
      // 如果選擇了特定門店，只顯示該門店的預約
      final isSameBranch = _selectedBranch == null || appointment.branchId == _selectedBranch!.id;
      
      return isSameDay && isSameBranch;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Widget _buildBranchSelector() {
    if (_branches.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Color(0xFF6C5CE7)),
          const SizedBox(width: 12),
          const Text(
            '門店篩選：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<Branch>(
              value: _selectedBranch,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                // 添加"全部門店"選項
                const DropdownMenuItem<Branch>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('全部門店'),
                    ],
                  ),
                ),
                ..._branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: branch.isDefault ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(branch.name),
                        if (branch.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '總店',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
              onChanged: _onBranchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        // 門店選擇器
        _buildBranchSelector(),
        
        // 行事曆工具列
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 視圖切換
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                selectedBorderColor: const Color(0xFF6C5CE7),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF6C5CE7),
                color: Colors.black,
                constraints: const BoxConstraints(
                  minWidth: 60,
                  minHeight: 30,
                ),
                isSelected: [
                  _calendarFormat == CalendarFormat.week,
                  _calendarFormat == CalendarFormat.month,
                ],
                onPressed: (index) {
                  setState(() {
                    _calendarFormat = [
                      CalendarFormat.week,
                      CalendarFormat.month,
                    ][index];
                  });
                },
                children: const [
                  Text('週'),
                  Text('月'),
                ],
              ),
              const Spacer(),
              // 新增預約按鈕
              ElevatedButton.icon(
                onPressed: () => _showAddAppointmentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('新增預約'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 日曆視圖
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          availableCalendarFormats: const {
            CalendarFormat.week: '週',
            CalendarFormat.month: '月',
          },
          eventLoader: (day) {
            return _appointments.where((appointment) {
              final appointmentDate = appointment.startTime;
              final isSameDay = appointmentDate.year == day.year &&
                  appointmentDate.month == day.month &&
                  appointmentDate.day == day.day;
              
              // 如果選擇了特定門店，只顯示該門店的預約
              final isSameBranch = _selectedBranch == null || appointment.branchId == _selectedBranch!.id;
              
              return isSameDay && isSameBranch;
            }).toList();
          },
        ),
        const Divider(),
        // 預約列表
        Expanded(
          child: _filteredAppointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${DateFormat('yyyy年MM月dd日').format(_selectedDay)}\n${_selectedBranch?.name ?? '全部門店'}沒有預約',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _filteredAppointments[index];
                    return AppointmentCard(
                      appointment: appointment,
                      onEdit: () => _showEditAppointmentDialog(context, appointment),
                      onDelete: () => _showDeleteConfirmationDialog(context, appointment),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStaffScheduleView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            '員工班表管理',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '查看和編輯員工的工作班表\n支持週視圖和月視圖，輕鬆管理排班',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StaffScheduleScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_view_week),
            label: const Text('進入班表管理'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預約管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '預約日曆'),
            Tab(text: '員工班表'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(),
                _buildStaffScheduleView(),
              ],
            ),
    );
  }
} 