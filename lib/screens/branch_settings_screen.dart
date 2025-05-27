import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/branch.dart';
import '../models/branch_special_day.dart';
import '../services/mock_api_service.dart';

class BranchSettingsScreen extends StatefulWidget {
  final String businessId;

  const BranchSettingsScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<BranchSettingsScreen> createState() => _BranchSettingsScreenState();
}

class _BranchSettingsScreenState extends State<BranchSettingsScreen> {
  final MockApiService _apiService = MockApiService();
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isLoading = true;
  
  // Operating hours for each day of the week
  final List<TimeOfDay?> _openTimes = List.filled(7, null);
  final List<TimeOfDay?> _closeTimes = List.filled(7, null);
  final List<bool> _isClosed = List.filled(7, false);
  
  // Special days
  List<BranchSpecialDay> _specialDays = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _apiService.getBranches(widget.businessId);
      if (mounted) {
        setState(() {
          _branches = branches;
          _isLoading = false;
          if (branches.isNotEmpty) {
            _selectedBranch = branches.first;
            _loadBranchOperatingHours();
            _loadSpecialDays();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入門店資料失敗: $e')),
        );
      }
    }
  }

  void _loadBranchOperatingHours() {
    if (_selectedBranch == null) return;
    
    // Parse operating hours from branch data
    // For now, set default hours for all days based on branch operating hours
    final startTime = _parseTimeString(_selectedBranch!.operatingHoursStart);
    final endTime = _parseTimeString(_selectedBranch!.operatingHoursEnd);
    
    for (int i = 0; i < 7; i++) {
      if (i == 6) { // Sunday closed by default
        _isClosed[i] = true;
        _openTimes[i] = null;
        _closeTimes[i] = null;
      } else {
        _isClosed[i] = false;
        _openTimes[i] = startTime ?? const TimeOfDay(hour: 10, minute: 0);
        _closeTimes[i] = endTime ?? const TimeOfDay(hour: 20, minute: 0);
      }
    }
  }

  TimeOfDay? _parseTimeString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadSpecialDays() async {
    if (_selectedBranch == null) return;
    
    try {
      final specialDays = await _apiService.getBranchSpecialDays(_selectedBranch!.id);
      if (mounted) {
        setState(() {
          _specialDays = specialDays;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入特殊營業日失敗: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, int dayIndex, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime 
          ? _openTimes[dayIndex] ?? const TimeOfDay(hour: 10, minute: 0)
          : _closeTimes[dayIndex] ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isOpenTime) {
          _openTimes[dayIndex] = picked;
        } else {
          _closeTimes[dayIndex] = picked;
        }
      });
    }
  }

  Future<void> _saveOperatingHours() async {
    if (_selectedBranch == null) return;

    try {
      // For simplicity, use the first non-closed day's hours as the branch default
      TimeOfDay? defaultStart;
      TimeOfDay? defaultEnd;
      
      for (int i = 0; i < 7; i++) {
        if (!_isClosed[i] && _openTimes[i] != null && _closeTimes[i] != null) {
          defaultStart = _openTimes[i];
          defaultEnd = _closeTimes[i];
          break;
        }
      }

      final updatedBranch = _selectedBranch!.copyWith(
        operatingHoursStart: defaultStart != null ? _formatTimeOfDay(defaultStart) : null,
        operatingHoursEnd: defaultEnd != null ? _formatTimeOfDay(defaultEnd) : null,
      );

      await _apiService.updateBranch(_selectedBranch!.id, updatedBranch);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('營業時間已儲存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存營業時間失敗: $e')),
        );
      }
    }
  }

  void _showAddSpecialDayDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddSpecialDayDialog(
        branchId: _selectedBranch!.id,
        onSaved: (specialDay) async {
          try {
            await _apiService.createBranchSpecialDay(specialDay);
            _loadSpecialDays();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('特殊營業日已新增')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('新增特殊營業日失敗: $e')),
              );
            }
          }
        },
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
      appBar: AppBar(
        title: const Text('門店管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Branch selector
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<Branch>(
              value: _selectedBranch,
              decoration: const InputDecoration(
                labelText: '選擇門店',
                border: OutlineInputBorder(),
              ),
              items: _branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch.name),
                );
              }).toList(),
              onChanged: (branch) {
                if (mounted) {
                  setState(() {
                    _selectedBranch = branch;
                    _loadBranchOperatingHours();
                    _loadSpecialDays();
                  });
                }
              },
            ),
          ),
          
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFF6C5CE7),
                    tabs: [
                      Tab(text: '營業時間'),
                      Tab(text: '特殊營業日'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOperatingHoursTab(),
                        _buildSpecialDaysTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '每週營業時間',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        weekdays[index],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Checkbox(
                      value: !_isClosed[index],
                      onChanged: (value) {
                        setState(() {
                          _isClosed[index] = !(value ?? true);
                        });
                      },
                    ),
                    const Text('營業'),
                    const SizedBox(width: 16),
                    if (!_isClosed[index]) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _selectTime(context, index, true),
                                child: Text(
                                  _openTimes[index]?.format(context) ?? '選擇時間',
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('至'),
                            ),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _selectTime(context, index, false),
                                child: Text(
                                  _closeTimes[index]?.format(context) ?? '選擇時間',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const Expanded(
                        child: Text(
                          '休息',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveOperatingHours,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '儲存營業時間',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialDaysTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '特殊營業日',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _selectedBranch != null ? _showAddSpecialDayDialog : null,
                icon: const Icon(Icons.add),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _specialDays.isEmpty
              ? const Center(
                  child: Text(
                    '尚無特殊營業日設定',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _specialDays.length,
                  itemBuilder: (context, index) {
                    final specialDay = _specialDays[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          specialDay.isOpen ? Icons.access_time : Icons.close,
                          color: specialDay.isOpen ? Colors.green : Colors.red,
                        ),
                        title: Text(DateFormat('yyyy/MM/dd').format(specialDay.date)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(specialDay.reason ?? ''),
                            if (specialDay.isOpen && 
                                specialDay.operatingHoursStart != null && 
                                specialDay.operatingHoursEnd != null)
                              Text(
                                '營業時間: ${specialDay.operatingHoursStart} - ${specialDay.operatingHoursEnd}',
                                style: const TextStyle(fontSize: 12),
                              )
                            else if (!specialDay.isOpen)
                              const Text(
                                '休息',
                                style: TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _apiService.deleteBranchSpecialDay(specialDay.id);
                              _loadSpecialDays();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('特殊營業日已刪除')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('刪除失敗: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AddSpecialDayDialog extends StatefulWidget {
  final String branchId;
  final Function(BranchSpecialDay) onSaved;

  const _AddSpecialDayDialog({
    required this.branchId,
    required this.onSaved,
  });

  @override
  State<_AddSpecialDayDialog> createState() => _AddSpecialDayDialogState();
}

class _AddSpecialDayDialogState extends State<_AddSpecialDayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isOpen = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? _startTime ?? const TimeOfDay(hour: 10, minute: 0)
          : _endTime ?? const TimeOfDay(hour: 18, minute: 0),
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

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final specialDay = BranchSpecialDay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        branchId: widget.branchId,
        date: _selectedDate,
        isOpen: _isOpen,
        operatingHoursStart: _isOpen && _startTime != null ? _formatTimeOfDay(_startTime!) : null,
        operatingHoursEnd: _isOpen && _endTime != null ? _formatTimeOfDay(_endTime!) : null,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      widget.onSaved(specialDay);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增特殊營業日'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker
              ListTile(
                title: const Text('日期'),
                subtitle: Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              
              // Open/Closed toggle
              SwitchListTile(
                title: const Text('營業狀態'),
                subtitle: Text(_isOpen ? '營業' : '休息'),
                value: _isOpen,
                onChanged: (value) {
                  setState(() {
                    _isOpen = value;
                  });
                },
              ),
              
              // Operating hours (only if open)
              if (_isOpen) ...[
                ListTile(
                  title: const Text('開始時間'),
                  subtitle: Text(_startTime?.format(context) ?? '選擇時間'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(true),
                ),
                ListTile(
                  title: const Text('結束時間'),
                  subtitle: Text(_endTime?.format(context) ?? '選擇時間'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(false),
                ),
              ],
              
              // Reason
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: '原因說明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
          ),
          child: const Text(
            '儲存',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 