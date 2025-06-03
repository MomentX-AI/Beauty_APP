import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../models/branch.dart';
import '../models/staff.dart';
import '../services/mock_data_service.dart';

class AppointmentFormDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Appointment) onSave;
  final Appointment? appointment;
  final String businessId;

  const AppointmentFormDialog({
    Key? key,
    required this.selectedDate,
    required this.onSave,
    this.appointment,
    required this.businessId,
  }) : super(key: key);

  @override
  State<AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  String? _selectedServiceId;
  String? _selectedBranchId;
  String? _selectedStaffId;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _noteController = TextEditingController();
  List<Customer> _customers = [];
  List<Service> _services = [];
  List<Branch> _branches = [];
  List<Staff> _staff = [];
  List<Staff> _availableStaff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load customers, services, branches, and staff
      final customers = await MockDataService.getMockCustomers();
      final services = MockDataService.getMockServices();
      final branches = MockDataService.getMockBranches(widget.businessId);
      final staff = MockDataService.getMockStaff(widget.businessId);
      
      if (!mounted) return;
      
      setState(() {
        _customers = customers;
        _services = services;
        _branches = branches;
        _staff = staff;
        
        // If editing an existing appointment, set the selected values
        if (widget.appointment != null) {
          _selectedCustomerId = widget.appointment!.customerId;
          _selectedServiceId = widget.appointment!.serviceId;
          _selectedBranchId = widget.appointment!.branchId;
          _selectedStaffId = widget.appointment!.staffId;
          _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.startTime);
          _noteController.text = widget.appointment!.note ?? '';
        } else {
          // Otherwise, set default values
          if (customers.isNotEmpty) {
            _selectedCustomerId = customers[0].id;
          }
          if (services.isNotEmpty) {
            _selectedServiceId = services[0].id;
          }
          if (branches.isNotEmpty) {
            _selectedBranchId = branches[0].id;
          }
        }
        
        // Update available staff based on selected branch and service
        _updateAvailableStaff();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入資料失敗: $e')),
      );
    }
  }

  void _updateAvailableStaff() {
    if (_selectedBranchId == null || _selectedServiceId == null) {
      setState(() {
        _availableStaff = [];
        _selectedStaffId = null;
      });
      return;
    }

    // Filter staff based on selected branch and service
    final availableStaff = _staff.where((staff) {
      // Check if staff works at the selected branch
      final worksAtBranch = staff.branchIds.contains(_selectedBranchId);
      
      // Check if staff can provide the selected service
      final canProvideService = staff.serviceIds.contains(_selectedServiceId);
      
      // Check if staff is active
      final isActive = staff.status == StaffStatus.active;
      
      return worksAtBranch && canProvideService && isActive;
    }).toList();

    setState(() {
      _availableStaff = availableStaff;
      
      // Reset selected staff if they're no longer available
      if (_selectedStaffId != null && 
          !availableStaff.any((staff) => staff.id == _selectedStaffId)) {
        _selectedStaffId = null;
      }
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate() && 
        _selectedCustomerId != null && 
        _selectedServiceId != null &&
        _selectedBranchId != null) {
      final startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final selectedService = _services.firstWhere(
        (service) => service.id == _selectedServiceId,
      );
      final endTime = startTime.add(Duration(minutes: selectedService.duration));

      final appointment = Appointment(
        id: widget.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        branchId: _selectedBranchId!,
        customerId: _selectedCustomerId!,
        serviceId: _selectedServiceId!,
        staffId: _selectedStaffId, // Add staff assignment
        startTime: startTime,
        endTime: endTime,
        status: widget.appointment?.status ?? AppointmentStatus.booked,
        note: _noteController.text,
        createdAt: widget.appointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(appointment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.appointment == null ? '新增預約' : '編輯預約'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 門店下拉選單
                    if (_branches.isEmpty)
                      const Text('沒有可用的門店資料')
                    else
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '門店',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedBranchId,
                            isExpanded: true,
                            underline: Container(),
                            items: _branches.map((Branch branch) {
                              return DropdownMenuItem<String>(
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
                            }).toList(),
                            onChanged: (String? newValueId) {
                              if (newValueId != null) {
                                setState(() {
                                  _selectedBranchId = newValueId;
                                });
                                _updateAvailableStaff();
                              }
                            },
                            hint: const Text('請選擇門店'),
                          ),
                        ),
                      ),

                    // 客戶下拉選單
                    if (_customers.isEmpty)
                      const Text('沒有可用的客戶資料')
                    else
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '客戶',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedCustomerId,
                            isExpanded: true,
                            underline: Container(), // 移除下底線
                            items: _customers.map((Customer customer) {
                              return DropdownMenuItem<String>(
                                value: customer.id,
                                child: Row(
                                  children: [
                                    Text(customer.name),
                                    if (customer.isArchived) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.archive,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                    if (customer.needsMerge) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.warning,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValueId) {
                              if (newValueId != null) {
                                setState(() {
                                  _selectedCustomerId = newValueId;
                                });
                              }
                            },
                            hint: const Text('請選擇客戶'),
                          ),
                        ),
                      ),
                    
                    // 服務項目下拉選單
                    if (_services.isEmpty)
                      const Text('沒有可用的服務項目')
                    else
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '服務項目',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedServiceId,
                            isExpanded: true,
                            underline: Container(), // 移除下底線
                            items: _services.map((Service service) {
                              return DropdownMenuItem<String>(
                                value: service.id,
                                child: Row(
                                  children: [
                                    Text(service.name),
                                    if (service.isArchived) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.archive,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValueId) {
                              if (newValueId != null) {
                                setState(() {
                                  _selectedServiceId = newValueId;
                                });
                                _updateAvailableStaff();
                              }
                            },
                            hint: const Text('請選擇服務項目'),
                          ),
                        ),
                      ),

                    // 指定員工下拉選單
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '指定員工（可選）',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStaffId,
                          isExpanded: true,
                          underline: Container(),
                          items: [
                            // 添加"不指定"選項
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.person_off, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('不指定員工'),
                                ],
                              ),
                            ),
                            ..._availableStaff.map((Staff staff) {
                              return DropdownMenuItem<String>(
                                value: staff.id,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor: staff.roleColor.withOpacity(0.2),
                                      child: Text(
                                        staff.name.isNotEmpty ? staff.name[0] : 'S',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: staff.roleColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            staff.name,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            staff.roleText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: staff.roleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (String? newValueId) {
                            setState(() {
                              _selectedStaffId = newValueId;
                            });
                          },
                          hint: const Text('請選擇員工'),
                        ),
                      ),
                    ),

                    // 顯示可用員工提示
                    if (_selectedBranchId != null && _selectedServiceId != null)
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: _availableStaff.isEmpty ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _availableStaff.isEmpty
                                    ? '此分店沒有可提供該服務的員工'
                                    : '找到 ${_availableStaff.length} 位可提供該服務的員工',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _availableStaff.isEmpty ? Colors.orange : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // 時間選擇
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '時間',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: InkWell(
                          onTap: _selectTime,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _selectedTime.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // 備註
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: '備註',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 500,
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
          onPressed: _saveAppointment,
          child: const Text('儲存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
} 