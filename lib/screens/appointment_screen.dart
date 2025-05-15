import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../services/mock_data_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form_dialog.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await MockDataService.getMockAppointments();
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
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppointmentFormDialog(
        selectedDate: _selectedDay,
        onSave: (appointment) {
          setState(() {
            _appointments = [..._appointments, appointment];
          });
          Navigator.of(context).pop();
          _showSuccessMessage('新增預約成功');
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
        onSave: (updatedAppointment) {
          setState(() {
            final index = _appointments.indexWhere((a) => a.id == appointment.id);
            if (index != -1) {
              _appointments[index] = updatedAppointment;
            }
          });
          Navigator.of(context).pop();
          _showSuccessMessage('更新預約成功');
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除預約「${appointment.customerName}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _appointments.removeWhere((a) => a.id == appointment.id);
              });
              Navigator.of(context).pop();
              _showSuccessMessage('刪除預約成功');
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

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
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
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
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
                ),
        ),
      ],
    );
  }
} 