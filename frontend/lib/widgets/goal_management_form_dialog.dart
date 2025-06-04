import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_goal.dart';
import '../models/branch.dart';
import '../models/staff.dart';

class GoalManagementFormDialog extends StatefulWidget {
  final String businessId;
  final BusinessGoal? goal;
  final GoalLevel level;
  final String? branchId;
  final String? staffId;
  final List<Branch> branches;
  final List<Staff> staff;
  final Function(BusinessGoal) onSave;

  const GoalManagementFormDialog({
    super.key,
    required this.businessId,
    this.goal,
    required this.level,
    this.branchId,
    this.staffId,
    required this.branches,
    required this.staff,
    required this.onSave,
  });

  @override
  State<GoalManagementFormDialog> createState() => _GoalManagementFormDialogState();
}

class _GoalManagementFormDialogState extends State<GoalManagementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GoalType _selectedType = GoalType.revenue;
  String? _selectedBranchId;
  String? _selectedStaffId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _initializeFromGoal(widget.goal!);
    } else {
      _selectedBranchId = widget.branchId;
      _selectedStaffId = widget.staffId;
      _initializeDefaults();
    }
  }

  void _initializeFromGoal(BusinessGoal goal) {
    _titleController.text = goal.title;
    _targetValueController.text = goal.targetValue.toString();
    _currentValueController.text = goal.currentValue.toString();
    _unitController.text = goal.unit;
    _descriptionController.text = goal.description ?? '';
    _selectedType = goal.type;
    _selectedBranchId = goal.branchId;
    _selectedStaffId = goal.staffId;
    _startDate = goal.startDate;
    _endDate = goal.endDate;
  }

  void _initializeDefaults() {
    switch (_selectedType) {
      case GoalType.revenue:
        _unitController.text = '元';
        break;
      case GoalType.revisit_rate:
      case GoalType.profit_margin:
        _unitController.text = '%';
        break;
      case GoalType.customer_count:
        _unitController.text = '人';
        break;
      case GoalType.service_count:
        _unitController.text = '次';
        break;
      default:
        _unitController.text = '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = BusinessGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        title: _titleController.text.trim(),
        currentValue: double.tryParse(_currentValueController.text) ?? 0,
        targetValue: double.tryParse(_targetValueController.text) ?? 0,
        unit: _unitController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        type: _selectedType,
        level: widget.level,
        branchId: _selectedBranchId,
        staffId: _selectedStaffId,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      widget.onSave(goal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? '新增${widget.level.displayName}' : '編輯${widget.level.displayName}'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 目標類型選擇
                DropdownButtonFormField<GoalType>(
                  decoration: const InputDecoration(
                    labelText: '目標類型',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem<GoalType>(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        _initializeDefaults();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return '請選擇目標類型';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 門店選擇（僅門店目標顯示）
                if (widget.level == GoalLevel.branch)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '門店',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedBranchId,
                    items: widget.branches.map((branch) {
                      return DropdownMenuItem<String>(
                        value: branch.id,
                        child: Text(branch.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請選擇門店';
                      }
                      return null;
                    },
                  ),

                // 員工選擇（僅員工目標顯示）
                if (widget.level == GoalLevel.staff)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '員工',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStaffId,
                    items: widget.staff.map((staff) {
                      return DropdownMenuItem<String>(
                        value: staff.id,
                        child: Text('${staff.name} (${staff.roleText})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStaffId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請選擇員工';
                      }
                      return null;
                    },
                  ),

                if (widget.level != GoalLevel.business) const SizedBox(height: 16),

                // 目標標題
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '目標標題',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入目標標題';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 目標值和當前值
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetValueController,
                        decoration: const InputDecoration(
                          labelText: '目標值',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入目標值';
                          }
                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return '請輸入有效的數值';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _currentValueController,
                        decoration: const InputDecoration(
                          labelText: '當前值',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入當前值';
                          }
                          final number = double.tryParse(value);
                          if (number == null || number < 0) {
                            return '請輸入有效的數值';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 單位
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: '單位',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入單位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 開始和結束日期
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '開始日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_startDate.year}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '結束日期',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_endDate.year}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 描述
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述（選填）',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
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
          onPressed: _saveGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
} 