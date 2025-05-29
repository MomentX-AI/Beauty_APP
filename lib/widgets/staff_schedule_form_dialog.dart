import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/staff_schedule.dart';
import '../models/staff.dart';
import '../models/branch.dart';

class StaffScheduleFormDialog extends StatefulWidget {
  final List<Staff> staff;
  final List<Branch> branches;
  final DateTime selectedDate;
  final StaffSchedule? schedule;
  final String? preSelectedStaffId;
  final Function(StaffSchedule) onSave;

  const StaffScheduleFormDialog({
    Key? key,
    required this.staff,
    required this.branches,
    required this.selectedDate,
    this.schedule,
    this.preSelectedStaffId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<StaffScheduleFormDialog> createState() => _StaffScheduleFormDialogState();
}

class _StaffScheduleFormDialogState extends State<StaffScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStaffId;
  String? _selectedBranchId;
  ShiftType _selectedShiftType = ShiftType.full_day;
  ScheduleStatus _selectedStatus = ScheduleStatus.scheduled;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    
    if (widget.schedule != null) {
      // 編輯模式
      _selectedStaffId = widget.schedule!.staffId;
      _selectedBranchId = widget.schedule!.branchId;
      _selectedShiftType = widget.schedule!.shiftType;
      _selectedStatus = widget.schedule!.status;
      _selectedDate = widget.schedule!.date;
      _notesController.text = widget.schedule!.notes ?? '';
      
      // 解析時間
      if (widget.schedule!.startTime != null) {
        final parts = widget.schedule!.startTime!.split(':');
        _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      if (widget.schedule!.endTime != null) {
        final parts = widget.schedule!.endTime!.split(':');
        _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } else {
      // 新增模式
      _selectedStaffId = widget.preSelectedStaffId ?? (widget.staff.isNotEmpty ? widget.staff.first.id : null);
      _selectedBranchId = widget.branches.isNotEmpty ? widget.branches.first.id : null;
      _setDefaultTimes();
    }
  }

  void _setDefaultTimes() {
    switch (_selectedShiftType) {
      case ShiftType.morning:
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 13, minute: 0);
        break;
      case ShiftType.afternoon:
        _startTime = const TimeOfDay(hour: 13, minute: 0);
        _endTime = const TimeOfDay(hour: 18, minute: 0);
        break;
      case ShiftType.evening:
        _startTime = const TimeOfDay(hour: 18, minute: 0);
        _endTime = const TimeOfDay(hour: 22, minute: 0);
        break;
      case ShiftType.full_day:
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 18, minute: 0);
        break;
      case ShiftType.off:
        _startTime = null;
        _endTime = null;
        break;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 18, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _timeToString(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate() || 
        _selectedStaffId == null || 
        _selectedBranchId == null ||
        _selectedDate == null) {
      return;
    }

    final schedule = StaffSchedule(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      staffId: _selectedStaffId!,
      branchId: _selectedBranchId!,
      date: _selectedDate!,
      shiftType: _selectedShiftType,
      startTime: _selectedShiftType != ShiftType.off ? _timeToString(_startTime) : null,
      endTime: _selectedShiftType != ShiftType.off ? _timeToString(_endTime) : null,
      status: _selectedStatus,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: widget.schedule?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      staffName: widget.staff.firstWhere((s) => s.id == _selectedStaffId).name,
      branchName: widget.branches.firstWhere((b) => b.id == _selectedBranchId).name,
    );

    widget.onSave(schedule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? '新增排班' : '編輯排班'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 日期選擇
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '日期',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('yyyy年MM月dd日 (E)', 'zh_TW').format(_selectedDate!)
                              : '請選擇日期',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 員工選擇
                DropdownButtonFormField<String>(
                  value: _selectedStaffId,
                  decoration: const InputDecoration(
                    labelText: '員工',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: widget.staff.map((staff) => DropdownMenuItem(
                    value: staff.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: staff.roleColor.withOpacity(0.2),
                          child: Text(
                            staff.name.isNotEmpty ? staff.name[0] : 'S',
                            style: TextStyle(
                              fontSize: 8,
                              color: staff.roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(staff.name),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: staff.roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            staff.roleText,
                            style: TextStyle(
                              fontSize: 8,
                              color: staff.roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStaffId = value;
                    });
                  },
                  validator: (value) => value == null ? '請選擇員工' : null,
                ),
                const SizedBox(height: 16),

                // 門店選擇
                DropdownButtonFormField<String>(
                  value: _selectedBranchId,
                  decoration: const InputDecoration(
                    labelText: '門店',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: widget.branches.map((branch) => DropdownMenuItem(
                    value: branch.id,
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
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '總店',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranchId = value;
                    });
                  },
                  validator: (value) => value == null ? '請選擇門店' : null,
                ),
                const SizedBox(height: 16),

                // 班次類型
                DropdownButtonFormField<ShiftType>(
                  value: _selectedShiftType,
                  decoration: const InputDecoration(
                    labelText: '班次類型',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ShiftType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getShiftTypeColor(type),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getShiftTypeText(type)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedShiftType = value!;
                      _setDefaultTimes();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 時間設定（非休假時顯示）
                if (_selectedShiftType != ShiftType.off) ...[
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: '開始時間',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_startTime?.format(context) ?? '09:00'),
                                const Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: '結束時間',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_endTime?.format(context) ?? '18:00'),
                                const Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 狀態選擇
                DropdownButtonFormField<ScheduleStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '狀態',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ScheduleStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusText(status)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 備註
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: '備註',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('儲存'),
        ),
      ],
    );
  }

  String _getShiftTypeText(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return '早班';
      case ShiftType.afternoon:
        return '午班';
      case ShiftType.evening:
        return '晚班';
      case ShiftType.full_day:
        return '全日班';
      case ShiftType.off:
        return '休假';
    }
  }

  Color _getShiftTypeColor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return Colors.orange;
      case ShiftType.afternoon:
        return Colors.blue;
      case ShiftType.evening:
        return Colors.indigo;
      case ShiftType.full_day:
        return Colors.green;
      case ShiftType.off:
        return Colors.grey;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return '已排班';
      case ScheduleStatus.confirmed:
        return '已確認';
      case ScheduleStatus.requested_off:
        return '申請休假';
      case ScheduleStatus.sick_leave:
        return '病假';
      case ScheduleStatus.personal_leave:
        return '事假';
    }
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return Colors.blue;
      case ScheduleStatus.confirmed:
        return Colors.green;
      case ScheduleStatus.requested_off:
        return Colors.orange;
      case ScheduleStatus.sick_leave:
        return Colors.red;
      case ScheduleStatus.personal_leave:
        return Colors.purple;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
} 