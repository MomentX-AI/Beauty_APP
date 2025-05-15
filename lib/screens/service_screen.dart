import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/mock_api_service.dart';
import '../widgets/service_list_tile.dart';
import '../widgets/service_form_dialog.dart';

class ServiceScreen extends StatefulWidget {
  final String businessId;
  
  const ServiceScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
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
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _apiService.getBusinessServices(
        widget.businessId,
        includeArchived: _includeArchived
      );
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
          SnackBar(content: Text('Error loading services: $e')),
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
            final createdService = await _apiService.createService(service);
            setState(() {
              _services = [..._services, createdService];
            });
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessMessage('新增服務成功');
            }
          } catch (e) {
            _showErrorMessage('新增服務失敗: $e');
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
        title: const Text('服務內容設定'),
        actions: [
          // 包含已存檔選項
          Switch(
            value: _includeArchived,
            onChanged: (value) {
              _toggleArchived();
            },
          ),
          const Text('顯示已存檔'),
          const SizedBox(width: 16),
          
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 服務類別頁籤
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...ServiceCategory.values.map((category) {
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // 新增類別按鈕
                Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 工具列
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // 搜尋框
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '搜尋服務項目...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // 排序
                const Text('排序:'),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: '價格', child: Text('價格')),
                      DropdownMenuItem(value: '利潤', child: Text('利潤')),
                      DropdownMenuItem(value: '時間', child: Text('所需時間')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
                const SizedBox(width: 20),
                // 新增服務按鈕
                ElevatedButton(
                  onPressed: () => _showAddServiceDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('+ 新增服務'),
                ),
              ],
            ),
          ),
          // 服務列表
          Expanded(
            child: _filteredServices.isEmpty
                ? const Center(child: Text('沒有符合條件的服務項目'))
                : ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return ServiceListTile(
                  service: service,
                  onEdit: () => _showEditServiceDialog(context, service),
                  onDelete: () => _showDeleteConfirmationDialog(context, service),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 