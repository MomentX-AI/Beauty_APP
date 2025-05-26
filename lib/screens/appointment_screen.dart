import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../services/mock_api_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form_dialog.dart';

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
  bool _isLoading = true;
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
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

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppointmentFormDialog(
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
      return appointmentDate.year == _selectedDay.year &&
          appointmentDate.month == _selectedDay.month &&
          appointmentDate.day == _selectedDay.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
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
              return appointmentDate.year == day.year &&
                  appointmentDate.month == day.month &&
                  appointmentDate.day == day.day;
            }).toList();
          },
        ),
        const Divider(),
        // 預約列表
        Expanded(
          child: ListView.builder(
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
    return const Center(
      child: Text('員工排程視圖（待實現）'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預約管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '預約日曆'),
            Tab(text: '員工排程'),
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