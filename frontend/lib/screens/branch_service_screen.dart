import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/branch.dart';
import '../models/branch_service.dart';
import '../services/mock_api_service.dart';

import '../widgets/branch_service_form_dialog.dart';

class BranchServiceScreen extends StatefulWidget {
  final String businessId;
  
  const BranchServiceScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<BranchServiceScreen> createState() => _BranchServiceScreenState();
}

class _BranchServiceScreenState extends State<BranchServiceScreen> {
  ServiceCategory _selectedCategory = ServiceCategory.hair;
  String _searchQuery = '';
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  List<Service> _allServices = [];
  List<BranchService> _branchServices = [];
  List<Service> _availableServices = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // 載入分店列表
      final branches = await _apiService.getBranches(widget.businessId);
      final allServices = await _apiService.getBusinessServices(widget.businessId);
      
      if (mounted) {
        setState(() {
          _branches = branches;
          _allServices = allServices;
          if (branches.isNotEmpty) {
            _selectedBranch = branches.first;
          }
        });
      }

      if (_selectedBranch != null) {
        await _loadBranchServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadBranchServices() async {
    if (_selectedBranch == null) return;

    try {
      final branchServices = await _apiService.getBranchServices(_selectedBranch!.id);
      final availableServices = await _apiService.getBranchAvailableServices(_selectedBranch!.id);
      
      if (mounted) {
        setState(() {
          _branchServices = branchServices;
          _availableServices = availableServices;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入分店服務失敗：$e')),
        );
      }
    }
  }

  void _onBranchChanged(Branch? branch) {
    if (branch != null && branch != _selectedBranch) {
      if (mounted) {
        setState(() {
          _selectedBranch = branch;
        });
      }
      _loadBranchServices();
    }
  }

  void _showAddServiceDialog() {
    if (_selectedBranch == null) return;

    // 找出還沒有添加到門店的服務
    final addedServiceIds = _branchServices.map((bs) => bs.serviceId).toSet();
    final availableToAdd = _allServices.where((s) => !addedServiceIds.contains(s.id)).toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有服務項目都已添加到此門店')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => BranchServiceFormDialog(
        branchId: _selectedBranch!.id,
        availableServices: availableToAdd,
        onSave: (branchService) async {
          try {
            await _apiService.createBranchService(branchService);
            if (mounted) {
              Navigator.pop(context);
              _loadBranchServices();
              _showSuccessMessage('新增服務成功');
            }
          } catch (e) {
            _showErrorMessage('新增服務失敗: $e');
          }
        },
      ),
    );
  }

  void _showEditServiceDialog(BranchService branchService) {
    final service = _allServices.firstWhere(
      (s) => s.id == branchService.serviceId,
      orElse: () => Service(
        id: branchService.serviceId,
        businessId: widget.businessId,
        name: '未知服務',
        category: ServiceCategory.hair,
        duration: 30,
        revisitPeriod: 30,
        price: 0,
        profit: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => BranchServiceFormDialog(
        branchId: _selectedBranch!.id,
        branchService: branchService,
        service: service,
        onSave: (updatedBranchService) async {
          try {
            await _apiService.updateBranchService(branchService.id, updatedBranchService);
            if (mounted) {
              Navigator.pop(context);
              _loadBranchServices();
              _showSuccessMessage('更新服務成功');
            }
          } catch (e) {
            _showErrorMessage('更新服務失敗: $e');
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BranchService branchService) {
    final service = _allServices.firstWhere(
      (s) => s.id == branchService.serviceId,
      orElse: () => Service(
        id: branchService.serviceId,
        businessId: widget.businessId,
        name: '未知服務',
        category: ServiceCategory.hair,
        duration: 30,
        revisitPeriod: 30,
        price: 0,
        profit: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認移除'),
        content: Text('確定要從門店「${_selectedBranch!.name}」移除服務「${service.name}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteBranchService(branchService.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadBranchServices();
                  _showSuccessMessage('移除服務成功');
                }
              } catch (e) {
                _showErrorMessage('移除服務失敗: $e');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Service> get _filteredServices {
    return _availableServices.where((service) {
      final matchesCategory = service.category == _selectedCategory;
      final matchesSearch = service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (service.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Color(0xFF6C5CE7)),
          const SizedBox(width: 12),
          const Text(
            '選擇門店：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<Branch>(
              value: _selectedBranch,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Row(
                    children: [
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
              onChanged: _onBranchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    if (_selectedBranch == null) {
      return const Center(
        child: Text(
          '請先選擇門店',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Search and filter controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜尋服務...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _searchQuery = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Category filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ServiceCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.displayName),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          if (mounted) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Services list
        Expanded(
          child: _filteredServices.isEmpty
              ? const Center(
                  child: Text(
                    '沒有找到符合條件的服務',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = _filteredServices[index];
                    final branchService = _branchServices.firstWhere(
                      (bs) => bs.serviceId == service.id,
                      orElse: () => BranchService(
                        id: '',
                        branchId: _selectedBranch!.id,
                        serviceId: service.id,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    
                    return BranchServiceListTile(
                      service: service,
                      branchService: branchService,
                      onEdit: () => _showEditServiceDialog(branchService),
                      onDelete: () => _showDeleteConfirmationDialog(branchService),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('門店服務管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildBranchSelector(),
          Expanded(child: _buildServicesContent()),
        ],
      ),
      floatingActionButton: _selectedBranch != null
          ? FloatingActionButton(
              onPressed: _showAddServiceDialog,
              backgroundColor: const Color(0xFF6C5CE7),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class BranchServiceListTile extends StatelessWidget {
  final Service service;
  final BranchService branchService;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BranchServiceListTile({
    super.key,
    required this.service,
    required this.branchService,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayPrice = branchService.customPrice ?? service.price;
    final displayProfit = branchService.customProfit ?? service.profit;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: service.category == ServiceCategory.hair
              ? Colors.blue.withOpacity(0.1)
              : service.category == ServiceCategory.nail
                  ? Colors.pink.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
          child: Icon(
            service.category == ServiceCategory.hair
                ? Icons.content_cut
                : service.category == ServiceCategory.nail
                    ? Icons.colorize
                    : Icons.spa,
            color: service.category == ServiceCategory.hair
                ? Colors.blue
                : service.category == ServiceCategory.nail
                    ? Colors.pink
                    : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                service.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (!branchService.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '停用',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            if (branchService.customPrice != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '自訂價格',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${service.duration} 分鐘 • ${service.category.displayName}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('價格: NT\$${displayPrice.toInt()}'),
                const SizedBox(width: 16),
                Text('利潤: NT\$${displayProfit.toInt()}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
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
                  Text('移除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 