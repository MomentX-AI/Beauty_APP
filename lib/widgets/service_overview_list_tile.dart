import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/branch.dart';
import '../models/branch_service.dart';
import '../services/mock_api_service.dart';

class ServiceOverviewListTile extends StatefulWidget {
  final Service service;
  final String businessId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceOverviewListTile({
    super.key,
    required this.service,
    required this.businessId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ServiceOverviewListTile> createState() => _ServiceOverviewListTileState();
}

class _ServiceOverviewListTileState extends State<ServiceOverviewListTile> {
  final MockApiService _apiService = MockApiService();
  List<Branch> _branches = [];
  List<BranchService> _branchServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranchData();
  }

  Future<void> _loadBranchData() async {
    try {
      final branches = await _apiService.getBranches(widget.businessId);
      List<BranchService> allBranchServices = [];
      
      for (final branch in branches) {
        final branchServices = await _apiService.getBranchServices(branch.id);
        allBranchServices.addAll(branchServices.where((bs) => bs.serviceId == widget.service.id));
      }
      
      if (mounted) {
        setState(() {
          _branches = branches;
          _branchServices = allBranchServices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Branch> get _availableBranches {
    final availableBranchIds = _branchServices
        .where((bs) => bs.isAvailable)
        .map((bs) => bs.branchId)
        .toSet();
    
    return _branches.where((branch) => availableBranchIds.contains(branch.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: widget.service.category == ServiceCategory.hair
              ? Colors.blue.withOpacity(0.1)
              : widget.service.category == ServiceCategory.nail
                  ? Colors.pink.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
          child: Icon(
            widget.service.category == ServiceCategory.hair
                ? Icons.content_cut
                : widget.service.category == ServiceCategory.nail
                    ? Icons.colorize
                    : Icons.spa,
            color: widget.service.category == ServiceCategory.hair
                ? Colors.blue
                : widget.service.category == ServiceCategory.nail
                    ? Colors.pink
                    : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.service.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_availableBranches.length}/${_branches.length} 門店',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.service.duration} 分鐘 • ${widget.service.category.displayName}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('基本價格: NT\$${widget.service.price.toInt()}'),
                const SizedBox(width: 16),
                Text('基本利潤: NT\$${widget.service.profit.toInt()}'),
              ],
            ),
            if (widget.service.description != null && widget.service.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.service.description!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                widget.onEdit();
                break;
              case 'delete':
                widget.onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('編輯'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('刪除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_branches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '沒有門店資料',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '門店使用情況：',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._branches.map((branch) {
                    final branchService = _branchServices.firstWhere(
                      (bs) => bs.branchId == branch.id,
                      orElse: () => BranchService(
                        id: '',
                        branchId: branch.id,
                        serviceId: widget.service.id,
                        isAvailable: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    
                    final isAvailable = branchService.id.isNotEmpty && branchService.isAvailable;
                    final hasCustomPrice = branchService.customPrice != null;
                    final displayPrice = branchService.customPrice ?? widget.service.price;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAvailable 
                            ? Colors.green.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.05),
                        border: Border.all(
                          color: isAvailable 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAvailable ? Icons.check_circle : Icons.cancel,
                            color: isAvailable ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      branch.name,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    if (branch.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '總店',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (isAvailable) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'NT\$${displayPrice.toInt()}',
                                        style: TextStyle(
                                          color: hasCustomPrice ? Colors.orange : Colors.grey,
                                          fontWeight: hasCustomPrice ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      if (hasCustomPrice) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '自訂',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ] else
                                  const Text(
                                    '未提供',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 