import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/staff.dart';
import '../models/branch.dart';
import '../models/service.dart';

class StaffFormDialog extends StatefulWidget {
  final String businessId;
  final Staff? staff;
  final List<Branch> branches;
  final List<Service> services;
  final Function(Staff) onSave;

  const StaffFormDialog({
    Key? key,
    required this.businessId,
    this.staff,
    required this.branches,
    required this.services,
    required this.onSave,
  }) : super(key: key);

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  StaffRole _selectedRole = StaffRole.stylist;
  StaffStatus _selectedStatus = StaffStatus.active;
  DateTime? _birthDate;
  DateTime _hireDate = DateTime.now();
  List<String> _selectedBranchIds = [];
  List<String> _selectedServiceIds = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.staff != null) {
      final staff = widget.staff!;
      _nameController.text = staff.name;
      _emailController.text = staff.email ?? '';
      _phoneController.text = staff.phone ?? '';
      _addressController.text = staff.address ?? '';
      _emergencyContactController.text = staff.emergencyContact ?? '';
      _emergencyPhoneController.text = staff.emergencyPhone ?? '';
      _notesController.text = staff.notes ?? '';
      _selectedRole = staff.role;
      _selectedStatus = staff.status;
      _birthDate = staff.birthDate;
      _hireDate = staff.hireDate;
      _selectedBranchIds = List.from(staff.branchIds);
      _selectedServiceIds = List.from(staff.serviceIds);
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _selectHireDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _hireDate) {
      setState(() => _hireDate = picked);
    }
  }

  void _showBranchSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇服務分店'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.branches.map((branch) {
              final isSelected = _selectedBranchIds.contains(branch.id);
              return CheckboxListTile(
                title: Text(branch.name),
                subtitle: branch.isDefault ? const Text('總店') : null,
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedBranchIds.add(branch.id);
                    } else {
                      _selectedBranchIds.remove(branch.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showServiceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇可提供服務'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.services.map((service) {
                final isSelected = _selectedServiceIds.contains(service.id);
                return CheckboxListTile(
                  title: Text(service.name),
                  subtitle: Text('${service.category.displayName} • ${service.duration}分鐘'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedServiceIds.add(service.id);
                      } else {
                        _selectedServiceIds.remove(service.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _saveStaff() {
    if (_formKey.currentState!.validate()) {
      final staff = Staff(
        id: widget.staff?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        role: _selectedRole,
        status: _selectedStatus,
        birthDate: _birthDate,
        hireDate: _hireDate,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        branchIds: _selectedBranchIds,
        serviceIds: _selectedServiceIds,
        createdAt: widget.staff?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(staff);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staff == null ? '新增員工' : '編輯員工'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 基本信息
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入員工姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<StaffRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: '職位',
                          border: OutlineInputBorder(),
                        ),
                        items: StaffRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(_getRoleText(role)),
                          );
                        }).toList(),
                        onChanged: (StaffRole? value) {
                          if (value != null) {
                            setState(() => _selectedRole = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<StaffStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '狀態',
                          border: OutlineInputBorder(),
                        ),
                        items: StaffStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (StaffStatus? value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 聯絡信息
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '電子郵件',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return '請輸入有效的電子郵件地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '電話號碼',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // 日期
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectBirthDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '生日',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _birthDate != null
                                ? DateFormat('yyyy/MM/dd').format(_birthDate!)
                                : '點擊選擇',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectHireDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '到職日期 *',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('yyyy/MM/dd').format(_hireDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 服務分店
                InkWell(
                  onTap: _showBranchSelectionDialog,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '服務分店',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedBranchIds.isEmpty
                          ? '點擊選擇分店'
                          : '已選擇 ${_selectedBranchIds.length} 個分店',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 可提供服務
                InkWell(
                  onTap: _showServiceSelectionDialog,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '可提供服務',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedServiceIds.isEmpty
                          ? '點擊選擇服務項目'
                          : '已選擇 ${_selectedServiceIds.length} 項服務',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 地址
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: '地址',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // 緊急聯絡人
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: '緊急聯絡人',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: const InputDecoration(
                          labelText: '緊急聯絡電話',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
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
          onPressed: _saveStaff,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
          ),
          child: const Text('儲存'),
        ),
      ],
    );
  }

  String _getRoleText(StaffRole role) {
    switch (role) {
      case StaffRole.owner:
        return '店主';
      case StaffRole.manager:
        return '經理';
      case StaffRole.senior_stylist:
        return '資深設計師';
      case StaffRole.stylist:
        return '設計師';
      case StaffRole.assistant:
        return '助理';
      case StaffRole.receptionist:
        return '接待員';
    }
  }

  String _getStatusText(StaffStatus status) {
    switch (status) {
      case StaffStatus.active:
        return '在職';
      case StaffStatus.inactive:
        return '離職';
      case StaffStatus.on_leave:
        return '請假';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 