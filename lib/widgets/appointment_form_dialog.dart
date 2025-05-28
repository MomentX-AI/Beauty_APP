import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../models/branch.dart';
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
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _noteController = TextEditingController();
  List<Customer> _customers = [];
  List<Service> _services = [];
  List<Branch> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load customers, services, and branches
      final customers = await MockDataService.getMockCustomers();
      final services = await MockDataService.getMockServices();
      final branches = MockDataService.getMockBranches(widget.businessId);
      
      if (!mounted) return;
      
      setState(() {
        _customers = customers;
        _services = services;
        _branches = branches;
        
        // If editing an existing appointment, set the selected values
        if (widget.appointment != null) {
          _selectedCustomerId = widget.appointment!.customerId;
          _selectedServiceId = widget.appointment!.serviceId;
          _selectedBranchId = widget.appointment!.branchId;
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
                              }
                            },
                            hint: const Text('請選擇服務項目'),
                          ),
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