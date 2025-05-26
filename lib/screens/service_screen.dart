import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/mock_api_service.dart';
import '../widgets/service_list_tile.dart';
import '../widgets/service_form_dialog.dart';
import '../models/business.dart';
import 'business_list_screen.dart';

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
  ServiceCategory _selectedCategory = ServiceCategory.hair;
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
      final services = await _apiService.getBusinessServices(widget.businessId);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
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
            setState(() {
              final index = _services.indexWhere((s) => s.id == service.id);
              if (index != -1) {
                _services[index] = result;
              }
            });
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
                setState(() {
                  _services.removeWhere((s) => s.id == service.id);
                });
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
    setState(() {
      _includeArchived = !_includeArchived;
    });
    _loadServices();
  }

  List<Service> get _filteredServices {
    return _services.where((service) {
      final matchesCategory = service.category == _selectedCategory;
      final matchesSearch = service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           (service.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服務管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '服務項目'),
            Tab(text: '商家設定'),
            Tab(text: '分店設定'),
            Tab(text: '特殊營業日'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 服務項目
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return ListTile(
                      title: Text(service.name),
                      subtitle: Text(service.description ?? ''),
                      trailing: Text('¥${service.price}'),
                    );
                  },
                ),
          // 商家設定
          const BusinessListScreen(),
          // 分店設定
          const Center(child: Text('分店設定（待實現）')),
          // 特殊營業日
          const Center(child: Text('特殊營業日（待實現）')),
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