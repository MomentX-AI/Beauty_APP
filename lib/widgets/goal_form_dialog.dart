import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoalFormDialog extends StatefulWidget {
  final Map<String, dynamic>? goal;
  final Function(Map<String, dynamic>) onSave;

  const GoalFormDialog({
    Key? key,
    this.goal,
    required this.onSave,
  }) : super(key: key);

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  String _selectedType = '營收';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  final List<String> _goalTypes = ['營收', '回訪率', '客戶數', '服務數量', '利潤率', '其他'];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!['title'] ?? '';
      String targetValue = widget.goal!['target'] ?? '';
      String currentValue = widget.goal!['current'] ?? '';
      
      if (widget.goal!['type'] == '營收') {
        targetValue = targetValue.replaceAll('NT\$ ', '');
        currentValue = currentValue.replaceAll('NT\$ ', '');
      } else if (widget.goal!['type'] == '回訪率' || widget.goal!['type'] == '利潤率') {
        targetValue = targetValue.replaceAll('%', '');
        currentValue = currentValue.replaceAll('%', '');
      } else if (widget.goal!['type'] == '客戶數' || widget.goal!['type'] == '服務數量') {
        targetValue = targetValue.replaceAll(' 次', '').replaceAll(' 人', '');
        currentValue = currentValue.replaceAll(' 次', '').replaceAll(' 人', '');
      }
      
      _targetController.text = targetValue;
      _currentController.text = currentValue;
      _selectedType = widget.goal!['type'] ?? '營收';
      _deadline = widget.goal!['deadline'] ?? DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  String _formatTargetValue(String value) {
    if (_selectedType == '營收') {
      return value.startsWith('NT\$') ? value : 'NT\$ $value';
    } else if (_selectedType == '回訪率' || _selectedType == '利潤率') {
      return value.endsWith('%') ? value : '$value%';
    } else if (_selectedType == '客戶數' || _selectedType == '服務數量') {
      return value.endsWith('次') || value.endsWith('人') ? value : '$value 次';
    }
    return value;
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final target = _formatTargetValue(_targetController.text.trim());
      final current = _formatTargetValue(_currentController.text.trim());

      // 計算完成百分比
      double percentage = 0;
      try {
        if (_selectedType == '營收') {
          final targetValue = double.parse(_targetController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          final currentValue = double.parse(_currentController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          percentage = (currentValue / targetValue * 100).clamp(0, 100).round().toDouble();
        } else if (_selectedType == '回訪率' || _selectedType == '利潤率') {
          final targetValue = double.parse(_targetController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          final currentValue = double.parse(_currentController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          percentage = (currentValue / targetValue * 100).clamp(0, 100).round().toDouble();
        } else {
          final targetValue = double.parse(_targetController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          final currentValue = double.parse(_currentController.text.replaceAll(RegExp(r'[^0-9\.]'), ''));
          percentage = (currentValue / targetValue * 100).clamp(0, 100).round().toDouble();
        }
      } catch (e) {
        percentage = 0;
      }

      widget.onSave({
        'id': widget.goal != null ? widget.goal!['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
        'title': '$_selectedType目標',
        'type': _selectedType,
        'target': target,
        'current': current,
        'percentage': percentage.round(),
        'deadline': _deadline,
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? '新增經營目標' : '編輯經營目標'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 目標類型選擇
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '目標類型',
                  border: OutlineInputBorder(),
                ),
                value: _selectedType,
                items: _goalTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請選擇目標類型';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 目標值
              TextFormField(
                controller: _targetController,
                decoration: InputDecoration(
                  labelText: '目標值',
                  border: const OutlineInputBorder(),
                  hintText: _selectedType == '營收' ? 'NT\$ 200,000' : 
                           _selectedType == '回訪率' || _selectedType == '利潤率' ? '80%' : '100 次',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.\%NT\$\s]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入目標值';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 當前值
              TextFormField(
                controller: _currentController,
                decoration: InputDecoration(
                  labelText: '當前值',
                  border: const OutlineInputBorder(),
                  hintText: _selectedType == '營收' ? 'NT\$ 150,000' : 
                           _selectedType == '回訪率' || _selectedType == '利潤率' ? '65%' : '75 次',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.\%NT\$\s]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入當前值';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 截止日期
              InkWell(
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() {
                      _deadline = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '目標截止日期',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_deadline.year}/${_deadline.month}/${_deadline.day}',
                  ),
                ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
          ),
          onPressed: _saveGoal,
          child: const Text('儲存'),
        ),
      ],
    );
  }
} 