import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/mock_api_service.dart';
import '../widgets/service_form_dialog.dart';
import '../widgets/service_overview_list_tile.dart';
import 'branch_info_screen.dart';
import 'branch_settings_screen.dart';
import 'branch_service_screen.dart';

class ServiceScreen extends StatefulWidget {
  final String businessId;
  
  const ServiceScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ServiceCategory? _selectedCategory; // 改為可為null，null代表顯示全部
  String _searchQuery = '';
  String _sortBy = '價格';
  bool _sortAscending = true;
  bool _includeArchived = false;
  List<Service> _services = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      print('Loading services for businessId: ${widget.businessId}');
      final services = await _apiService.getBusinessServices(widget.businessId);
      print('Loaded ${services.length} services');
      for (var service in services) {
        print('Service: ${service.name} (${service.category.displayName})');
      }
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入服務失敗：$e')),
        );
      }
    }
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        businessId: widget.businessId,
        onSave: (service) async {
          try {
            await _apiService.createService(service);
            if (mounted) {
              Navigator.pop(context);
              _loadServices();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('新增服務失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        service: service,
        businessId: widget.businessId,
        onSave: (updatedService) async {
          try {
            final result = await _apiService.updateService(service.id, updatedService);
            if (mounted) {
              setState(() {
                final index = _services.indexWhere((s) => s.id == service.id);
                if (index != -1) {
                  _services[index] = result;
                }
              });
            }
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessMessage('更新服務成功');
            }
          } catch (e) {
            _showErrorMessage('更新服務失敗: $e');
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除服務「${service.name}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteService(service.id);
                if (mounted) {
                  setState(() {
                    _services.removeWhere((s) => s.id == service.id);
                  });
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  _showSuccessMessage('刪除服務成功');
                }
              } catch (e) {
                _showErrorMessage('刪除服務失敗: $e');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('刪除'),
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

  void _toggleArchived() {
    if (mounted) {
      setState(() {
        _includeArchived = !_includeArchived;
      });
    }
    _loadServices();
  }

  List<Service> get _filteredServices {
    print('Filtering services: total=${_services.length}, category=$_selectedCategory, search="$_searchQuery"');
    final filtered = _services.where((service) {
      final matchesCategory = _selectedCategory == null || service.category == _selectedCategory;
      final matchesSearch = service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (service.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final result = matchesCategory && matchesSearch;
      if (!result) {
        print('Service ${service.name} filtered out: category=$matchesCategory, search=$matchesSearch');
      }
      return result;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == '價格') {
          return _sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
        } else if (_sortBy == '利潤') {
          return _sortAscending ? a.profit.compareTo(b.profit) : b.profit.compareTo(a.profit);
        } else if (_sortBy == '時間') {
          return _sortAscending ? a.duration.compareTo(b.duration) : b.duration.compareTo(a.duration);
        }
        return a.name.compareTo(b.name);
      });
    print('Filtered services count: ${filtered.length}');
    return filtered;
  }

  Widget _buildServicesTab() {
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
              // Title and description
              const Row(
                children: [
                  Icon(Icons.list_alt, color: Color(0xFF6C5CE7)),
                  SizedBox(width: 8),
                  Text(
                    '服務項目總覽',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '查看所有門店的服務項目，可以搜尋和篩選服務',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜尋服務名稱或描述...',
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
                  children: [
                    // 全部選項
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('全部'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          if (mounted) {
                            setState(() {
                              _selectedCategory = null;
                            });
                          }
                        },
                      ),
                    ),
                    // 各類別選項
                    ...ServiceCategory.values.map((category) {
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
                  ],
                ),
              ),
            ],
          ),
        ),
        // Services list
        Expanded(
          child: _filteredServices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '沒有找到符合條件的服務',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = _filteredServices[index];
                    return ServiceOverviewListTile(
                      service: service,
                      businessId: widget.businessId,
                      onEdit: () => _showEditServiceDialog(context, service),
                      onDelete: () => _showDeleteConfirmationDialog(context, service),
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
        title: const Text('服務管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '服務項目總覽'),
            Tab(text: '門店服務'),
            Tab(text: '門店設置'),
            Tab(text: '門店管理'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 服務項目總覽
          _buildServicesTab(),
          // 門店服務
          BranchServiceScreen(businessId: widget.businessId),
          // 門店設置（門店基本信息）
          BranchInfoScreen(businessId: widget.businessId),
          // 門店管理（營業時間和特殊營業日）
          BranchSettingsScreen(businessId: widget.businessId),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddServiceDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 