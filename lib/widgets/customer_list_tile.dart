import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomerListTile({
    super.key,
    required this.customer,
    required this.isSelected,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                child: Text(
                  customer.name.characters.first,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (customer.isSpecialCustomer) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                        if (customer.needsMerge) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ],
                        if (customer.isArchived) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.archive,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (customer.phone != null)
                      Text(
                        customer.phone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (customer.email != null)
                      Text(
                        customer.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(customer.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (customer.gender != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        customer.gender!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
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