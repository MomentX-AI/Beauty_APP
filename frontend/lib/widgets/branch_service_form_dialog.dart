import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/service.dart';
import '../models/branch_service.dart';

class BranchServiceFormDialog extends StatefulWidget {
  final String branchId;
  final BranchService? branchService;
  final Service? service;
  final List<Service>? availableServices;
  final Function(BranchService) onSave;

  const BranchServiceFormDialog({
    super.key,
    required this.branchId,
    this.branchService,
    this.service,
    this.availableServices,
    required this.onSave,
  });

  @override
  State<BranchServiceFormDialog> createState() => _BranchServiceFormDialogState();
}

class _BranchServiceFormDialogState extends State<BranchServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customPriceController;
  late final TextEditingController _customProfitController;
  Service? _selectedService;
  bool _isAvailable = true;
  bool _useCustomPrice = false;

  @override
  void initState() {
    super.initState();
    
    _selectedService = widget.service ?? 
        (widget.availableServices?.isNotEmpty == true ? widget.availableServices!.first : null);
    
    _isAvailable = widget.branchService?.isAvailable ?? true;
    _useCustomPrice = widget.branchService?.customPrice != null;
    
    _customPriceController = TextEditingController(
      text: widget.branchService?.customPrice?.toString() ?? '',
    );
    _customProfitController = TextEditingController(
      text: widget.branchService?.customProfit?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _customPriceController.dispose();
    _customProfitController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && _selectedService != null) {
      final branchService = BranchService(
        id: widget.branchService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        branchId: widget.branchId,
        serviceId: _selectedService!.id,
        isAvailable: _isAvailable,
        customPrice: _useCustomPrice && _customPriceController.text.isNotEmpty
            ? double.parse(_customPriceController.text)
            : null,
        customProfit: _useCustomPrice && _customProfitController.text.isNotEmpty
            ? double.parse(_customProfitController.text)
            : null,
        createdAt: widget.branchService?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(branchService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.branchService != null;
    
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 標題
              Text(
                isEditing ? '編輯門店服務' : '新增門店服務',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // 服務選擇（僅在新增時顯示）
              if (!isEditing && widget.availableServices != null) ...[
                DropdownButtonFormField<Service>(
                  value: _selectedService,
                  decoration: const InputDecoration(
                    labelText: '選擇服務項目',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.availableServices!.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.name),
                          Text(
                            '${service.category.displayName} • ${service.duration}分鐘 • NT\$${service.price.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '請選擇服務項目';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // 如果是編輯模式，顯示服務信息
              if (isEditing && _selectedService != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedService!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedService!.category.displayName} • ${_selectedService!.duration}分鐘',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '預設價格: NT\$${_selectedService!.price.toInt()} • 預設利潤: NT\$${_selectedService!.profit.toInt()}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 服務狀態
              SwitchListTile(
                title: const Text('啟用此服務'),
                subtitle: Text(_isAvailable ? '客戶可以預約此服務' : '客戶無法預約此服務'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 自訂價格選項
              SwitchListTile(
                title: const Text('使用自訂價格'),
                subtitle: Text(_useCustomPrice ? '為此門店設定特殊價格' : '使用服務的預設價格'),
                value: _useCustomPrice,
                onChanged: (value) {
                  setState(() {
                    _useCustomPrice = value;
                    if (!value) {
                      _customPriceController.clear();
                      _customProfitController.clear();
                    } else if (_selectedService != null) {
                      _customPriceController.text = _selectedService!.price.toString();
                      _customProfitController.text = _selectedService!.profit.toString();
                    }
                  });
                },
              ),
              
              // 自訂價格輸入欄位
              if (_useCustomPrice) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customPriceController,
                        decoration: const InputDecoration(
                          labelText: '自訂價格（NT\$）',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (_useCustomPrice && (value == null || value.isEmpty)) {
                            return '請輸入價格';
                          }
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return '請輸入有效數字';
                            }
                            if (double.parse(value) < 0) {
                              return '價格不能為負數';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _customProfitController,
                        decoration: const InputDecoration(
                          labelText: '自訂利潤（NT\$）',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (_useCustomPrice && (value == null || value.isEmpty)) {
                            return '請輸入利潤';
                          }
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return '請輸入有效數字';
                            }
                            if (double.parse(value) < 0) {
                              return '利潤不能為負數';
                            }
                            if (_customPriceController.text.isNotEmpty && 
                                double.parse(value) > double.parse(_customPriceController.text)) {
                              return '利潤不能高於價格';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // 按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? '更新' : '新增'),
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