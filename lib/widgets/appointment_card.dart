import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 根據預約狀態決定卡片顏色
    Color cardColor;
    Color borderColor;
    
    switch (appointment.status) {
      case AppointmentStatus.booked:
        cardColor = const Color(0xFFD0EBFF);
        borderColor = const Color(0xFF1C7ED6);
        break;
      case AppointmentStatus.confirmed:
        cardColor = const Color(0xFFD3F9D8);
        borderColor = const Color(0xFF37B24D);
        break;
      case AppointmentStatus.completed:
        cardColor = const Color(0xFFE3FAFC);
        borderColor = const Color(0xFF0CA678);
        break;
      case AppointmentStatus.cancelled:
        cardColor = const Color(0xFFFFE3E3);
        borderColor = const Color(0xFFFA5252);
        break;
      case AppointmentStatus.checked_in:
        cardColor = const Color(0xFFFFF3CD);
        borderColor = const Color(0xFFFFC107);
        break;
      case AppointmentStatus.no_show:
        cardColor = const Color(0xFFFDECE6);
        borderColor = const Color(0xFFFF6B35);
        break;
      default:
        cardColor = const Color(0xFFD0EBFF);
        borderColor = const Color(0xFF1C7ED6);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：時間和狀態
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: borderColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(appointment.startTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: borderColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '- ${DateFormat('HH:mm').format(appointment.endTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: borderColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 第二行：客戶信息
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (appointment.isSpecialCustomer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 第三行：服務項目
              Row(
                children: [
                  const Icon(
                    Icons.content_cut,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.serviceName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 第四行：門店信息
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 16,
                    color: appointment.branch?.isDefault == true ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          appointment.branchName,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (appointment.branch?.isDefault == true) ...[
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
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 第五行：指定員工信息
              Row(
                children: [
                  Icon(
                    appointment.staffId != null ? Icons.person : Icons.person_off,
                    size: 16,
                    color: appointment.staffId != null 
                        ? (appointment.staff?.roleColor ?? Colors.green)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          appointment.staffId != null 
                              ? appointment.staffName 
                              : '未指定員工',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (appointment.staff != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: appointment.staff!.roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              appointment.staff!.roleText,
                              style: TextStyle(
                                fontSize: 10,
                                color: appointment.staff!.roleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              // 備註（如果有的話）
              if (appointment.note != null && appointment.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // 操作按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('編輯'),
                    style: TextButton.styleFrom(
                      foregroundColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('刪除'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 