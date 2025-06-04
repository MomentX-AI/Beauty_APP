import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service.dart';

class AppointmentFormDialog extends StatefulWidget {
  final Appointment? appointment;
  final String businessId;
  final String? branchId;
  final List<Customer> customers;
  final List<Service> services;
  final Function(Appointment) onSave;

  const AppointmentFormDialog({
    Key? key,
    this.appointment,
    required this.businessId,
    this.branchId,
    required this.customers,
    required this.services,
    required this.onSave,
  }) : super(key: key);

  @override
  _AppointmentFormDialogState createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  late TextEditingController _noteController;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _selectedCustomerId;
  late String _selectedServiceId;
  late AppointmentStatus _status;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.appointment?.note ?? '');
    _startTime = widget.appointment?.startTime ?? DateTime.now();
    _endTime = widget.appointment?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedCustomerId = widget.appointment?.customerId ?? widget.customers.first.id;
    _selectedServiceId = widget.appointment?.serviceId ?? widget.services.first.id;
    _status = widget.appointment?.status ?? AppointmentStatus.booked;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final appointment = Appointment(
      id: widget.appointment?.id ?? const Uuid().v4(),
      businessId: widget.businessId,
      branchId: widget.branchId ?? widget.appointment?.branchId ?? '1',
      customerId: _selectedCustomerId,
      serviceId: _selectedServiceId,
      startTime: _startTime,
      endTime: _endTime,
      status: _status,
      note: _noteController.text,
      createdAt: widget.appointment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.onSave(appointment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.appointment == null ? '新增預約' : '編輯預約'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              decoration: const InputDecoration(labelText: '客戶'),
              items: widget.customers.map((customer) {
                return DropdownMenuItem(
                  value: customer.id,
                  child: Text(customer.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedServiceId,
              decoration: const InputDecoration(labelText: '服務'),
              items: widget.services.map((service) {
                return DropdownMenuItem(
                  value: service.id,
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedServiceId = value!;
                  final selectedService = widget.services.firstWhere(
                    (s) => s.id == value,
                  );
                  _endTime = _startTime.add(Duration(minutes: selectedService.duration));
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _startTime.hour,
                            _startTime.minute,
                          );
                          _endTime = _startTime.add(Duration(
                            minutes: widget.services
                                .firstWhere((s) => s.id == _selectedServiceId)
                                .duration,
                          ));
                        });
                      }
                    },
                    child: Text(
                      '${_startTime.year}/${_startTime.month}/${_startTime.day}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: _startTime.hour,
                          minute: _startTime.minute,
                        ),
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = DateTime(
                            _startTime.year,
                            _startTime.month,
                            _startTime.day,
                            time.hour,
                            time.minute,
                          );
                          _endTime = _startTime.add(Duration(
                            minutes: widget.services
                                .firstWhere((s) => s.id == _selectedServiceId)
                                .duration,
                          ));
                        });
                      }
                    },
                    child: Text(
                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppointmentStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: '狀態'),
              items: AppointmentStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '備註'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('儲存'),
        ),
      ],
    );
  }
} 