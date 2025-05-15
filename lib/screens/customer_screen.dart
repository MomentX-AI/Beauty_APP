import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../widgets/customer_list_tile.dart';
import '../widgets/customer_detail_card.dart';
import '../services/mock_data_service.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = true;
  bool _showArchived = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await MockDataService.getMockCustomers();
      if (!mounted) return;
      
      setState(() {
        _customers = customers;
        if (customers.isNotEmpty && _selectedCustomer == null) {
          _selectedCustomer = customers.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入客戶資料失敗: $e')),
      );
    }
  }

  List<Customer> _getFilteredCustomers() {
    return _customers.where((customer) {
      final matchesSearch = _searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (customer.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesArchiveFilter = _showArchived || !customer.isArchived;
      
      return matchesSearch && matchesArchiveFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _getFilteredCustomers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('客戶管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add new customer
            },
          ),
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.unarchive),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            tooltip: _showArchived ? '顯示未歸檔客戶' : '顯示已歸檔客戶',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: '搜尋客戶',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('需要合併的客戶：'),
                                const SizedBox(width: 8),
                                Text(
                                  _customers.where((c) => c.needsMerge).length.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return CustomerListTile(
                              customer: customer,
                              isSelected: customer.id == _selectedCustomer?.id,
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                if (_selectedCustomer != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: CustomerDetailCard(
                        customer: _selectedCustomer!,
                        onUpdate: () {
                          _loadCustomers();
                        },
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('請選擇客戶以查看詳細資料'),
                    ),
                  ),
              ],
            ),
    );
  }
} 