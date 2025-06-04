import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../models/branch.dart';
import '../models/service.dart';
import '../services/mock_api_service.dart';
import '../widgets/staff_form_dialog.dart';

class StaffScreen extends StatefulWidget {
  final String businessId;

  const StaffScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<Staff> _staff = [];
  List<Branch> _branches = [];
  List<Service> _services = [];
  bool _isLoading = true;
  String _searchQuery = '';
  StaffStatus? _filterStatus;
  StaffRole? _filterRole;
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final staff = await _apiService.getStaff(widget.businessId);
      final branches = await _apiService.getBranches(widget.businessId);
      final services = await _apiService.getBusinessServices(widget.businessId);

      setState(() {
        _staff = staff;
        _branches = branches;
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入資料失敗：$e')),
        );
      }
    }
  }

  List<Staff> get _filteredStaff {
    return _staff.where((staff) {
      // 名稱搜尋
      final matchesSearch = _searchQuery.isEmpty ||
          staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (staff.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (staff.phone?.contains(_searchQuery) ?? false);

      // 狀態篩選
      final matchesStatus = _filterStatus == null || staff.status == _filterStatus;

      // 職位篩選
      final matchesRole = _filterRole == null || staff.role == _filterRole;

      return matchesSearch && matchesStatus && matchesRole;
    }).toList();
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => StaffFormDialog(
        businessId: widget.businessId,
        branches: _branches,
        services: _services,
        onSave: (staff) async {
          try {
            await _apiService.createStaff(staff);
            _loadData();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('新增員工失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditStaffDialog(Staff staff) {
    showDialog(
      context: context,
      builder: (context) => StaffFormDialog(
        businessId: widget.businessId,
        staff: staff,
        branches: _branches,
        services: _services,
        onSave: (updatedStaff) async {
          try {
            await _apiService.updateStaff(staff.id, updatedStaff);
            _loadData();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('更新員工失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除員工「${staff.name}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteStaff(staff.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刪除員工失敗：$e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        // 狀態篩選
        FilterChip(
          label: Text(_filterStatus?.name ?? '全部狀態'),
          selected: _filterStatus != null,
          onSelected: (selected) {
            setState(() {
              _filterStatus = selected ? StaffStatus.active : null;
            });
          },
        ),
        // 職位篩選
        FilterChip(
          label: Text(_filterRole?.name ?? '全部職位'),
          selected: _filterRole != null,
          onSelected: (selected) {
            setState(() {
              _filterRole = selected ? StaffRole.stylist : null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStaffCard(Staff staff) {
    final staffBranches = _branches.where((branch) => staff.branchIds.contains(branch.id)).toList();
    final staffServices = _services.where((service) => staff.serviceIds.contains(service.id)).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 員工基本信息
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: staff.roleColor.withOpacity(0.2),
                  backgroundImage: staff.avatarUrl != null ? NetworkImage(staff.avatarUrl!) : null,
                  child: staff.avatarUrl == null
                      ? Text(
                          staff.name.isNotEmpty ? staff.name[0] : 'S',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: staff.roleColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            staff.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: staff.roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.roleText,
                              style: TextStyle(
                                fontSize: 12,
                                color: staff.roleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: staff.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: staff.statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (staff.email != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.email, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(staff.email!, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (staff.phone != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(staff.phone!, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 服務分店
            if (staffBranches.isNotEmpty) ...[
              const Text(
                '服務分店：',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: staffBranches.map((branch) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: branch.isDefault ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.store,
                          size: 14,
                          color: branch.isDefault ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          branch.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: branch.isDefault ? Colors.blue : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // 可提供服務
            if (staffServices.isNotEmpty) ...[
              const Text(
                '可提供服務：',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: staffServices.take(5).map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  );
                }).toList()
                  ..addAll(staffServices.length > 5
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${staffServices.length - 5}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ]
                      : []),
              ),
              const SizedBox(height: 12),
            ],

            // 操作按鈕
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditStaffDialog(staff),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('編輯'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(staff),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('刪除'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('員工管理'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 搜尋和篩選工具列
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: '搜尋員工姓名、電話或信箱...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddStaffDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('新增員工'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFilterChips(),
                    ],
                  ),
                ),

                // 員工統計
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_staff.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('總員工數', style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_staff.where((s) => s.status == StaffStatus.active).length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('在職員工', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_staff.where((s) => s.status == StaffStatus.on_leave).length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text('請假中', style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 員工列表
                Expanded(
                  child: _filteredStaff.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                '沒有找到員工資料',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredStaff.length,
                          itemBuilder: (context, index) {
                            final staff = _filteredStaff[index];
                            return _buildStaffCard(staff);
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 