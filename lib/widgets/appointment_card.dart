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
      case 'scheduled':
        cardColor = const Color(0xFFD0EBFF);
        borderColor = const Color(0xFF1C7ED6);
        break;
      case 'completed':
        cardColor = const Color(0xFFD3F9D8);
        borderColor = const Color(0xFF37B24D);
        break;
      case 'cancelled':
        cardColor = const Color(0xFFFFE3E3);
        borderColor = const Color(0xFFFA5252);
        break;
      default:
        cardColor = const Color(0xFFD0EBFF);
        borderColor = const Color(0xFF1C7ED6);
    }

    return Card(
      margin: const EdgeInsets.all(2),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 時間
              Text(
                '${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
                style: TextStyle(
                  fontSize: 12,
                  color: borderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              // 客戶名稱
              Text(
                appointment.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 服務項目
              Text(
                appointment.serviceName,
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 特殊客戶標記
              if (appointment.isSpecialCustomer)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '特殊客戶',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFFA5252),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 