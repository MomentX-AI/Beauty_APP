import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/mock_api_service.dart';

class BranchInfoScreen extends StatefulWidget {
  final String businessId;

  const BranchInfoScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<BranchInfoScreen> createState() => _BranchInfoScreenState();
}

class _BranchInfoScreenState extends State<BranchInfoScreen> {
  final MockApiService _apiService = MockApiService();
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isLoading = true;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _apiService.getBranches(widget.businessId);
      if (mounted) {
        setState(() {
          _branches = branches;
          _isLoading = false;
          if (branches.isNotEmpty) {
            _selectedBranch = branches.first;
            _loadBranchInfo();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入門店資料失敗: $e')),
        );
      }
    }
  }

  void _loadBranchInfo() {
    if (_selectedBranch == null) return;
    
    _nameController.text = _selectedBranch!.name;
    _phoneController.text = _selectedBranch!.contactPhone ?? '';
    _addressController.text = _selectedBranch!.address ?? '';
  }

  Future<void> _saveBranchInfo() async {
    if (_selectedBranch == null || !_formKey.currentState!.validate()) return;

    try {
      final updatedBranch = _selectedBranch!.copyWith(
        name: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      await _apiService.updateBranch(_selectedBranch!.id, updatedBranch);
      
      if (mounted) {
        setState(() {
          final index = _branches.indexWhere((b) => b.id == _selectedBranch!.id);
          if (index != -1) {
            _branches[index] = updatedBranch;
            _selectedBranch = updatedBranch;
          }
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('門店信息已更新')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新門店信息失敗: $e')),
        );
      }
    }
  }

  void _showAddBranchDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddBranchDialog(
        businessId: widget.businessId,
        onSaved: (branch) async {
          try {
            await _apiService.createBranch(branch);
            _loadBranches();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('門店已新增')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('新增門店失敗: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    if (_selectedBranch == null || _selectedBranch!.isDefault) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除門店「${_selectedBranch!.name}」嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteBranch(_selectedBranch!.id);
                Navigator.of(context).pop();
                _loadBranches();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('門店已刪除')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刪除門店失敗: $e')),
                  );
                }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('門店設置'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBranchDialog,
            tooltip: '新增門店',
          ),
        ],
      ),
      body: Column(
        children: [
          // Branch selector
          Container(
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
                    onChanged: (branch) {
                      if (mounted) {
                        setState(() {
                          _selectedBranch = branch;
                          _loadBranchInfo();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Branch info form
          Expanded(
            child: _selectedBranch == null
                ? const Center(
                    child: Text(
                      '請先選擇門店',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '門店基本信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Branch name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '門店名稱',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.store),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '請輸入門店名稱';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Contact phone
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: '聯絡電話',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          
                          // Address
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: '門店地址',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                          
                          // Status info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '門店狀態',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _selectedBranch!.status == 'active' 
                                          ? Icons.check_circle 
                                          : Icons.cancel,
                                      color: _selectedBranch!.status == 'active' 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedBranch!.status == 'active' ? '營業中' : '暫停營業',
                                      style: TextStyle(
                                        color: _selectedBranch!.status == 'active' 
                                            ? Colors.green 
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_selectedBranch!.isDefault) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '總店',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveBranchInfo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C5CE7),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    '儲存變更',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              if (!_selectedBranch!.isDefault) ...[
                                const SizedBox(width: 16),
                                OutlinedButton(
                                  onPressed: _showDeleteConfirmationDialog,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  ),
                                  child: const Text('刪除門店'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddBranchDialog extends StatefulWidget {
  final String businessId;
  final Function(Branch) onSaved;

  const _AddBranchDialog({
    required this.businessId,
    required this.onSaved,
  });

  @override
  State<_AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends State<_AddBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final branch = Branch(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        name: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        isDefault: false,
        status: 'active',
        operatingHoursStart: '10:00',
        operatingHoursEnd: '20:00',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      widget.onSaved(branch);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增門店'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '門店名稱',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入門店名稱';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '聯絡電話',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '門店地址',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
          ),
          child: const Text(
            '新增',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 