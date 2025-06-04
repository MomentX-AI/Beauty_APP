import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/service.dart';

class ServiceFormDialog extends StatefulWidget {
  final Service? service;
  final Function(Service) onSave;
  final String businessId;

  const ServiceFormDialog({
    super.key,
    this.service,
    required this.onSave,
    required this.businessId,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _revisitPeriodController;
  late final TextEditingController _priceController;
  late final TextEditingController _profitController;
  late final TextEditingController _descriptionController;
  late ServiceCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _durationController = TextEditingController(
      text: widget.service?.duration.toString(),
    );
    _revisitPeriodController = TextEditingController(
      text: widget.service?.revisitPeriod.toString(),
    );
    _priceController = TextEditingController(
      text: widget.service?.price.toString(),
    );
    _profitController = TextEditingController(
      text: widget.service?.profit.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.service?.description,
    );
    _selectedCategory = widget.service?.category ?? ServiceCategory.hair;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _revisitPeriodController.dispose();
    _priceController.dispose();
    _profitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final service = Service(
        id: widget.service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        name: _nameController.text,
        category: _selectedCategory,
        duration: int.parse(_durationController.text),
        revisitPeriod: int.parse(_revisitPeriodController.text),
        price: double.parse(_priceController.text),
        profit: double.parse(_profitController.text),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        isArchived: widget.service?.isArchived ?? false,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 標題
              Text(
                widget.service == null ? '新增服務項目' : '編輯服務項目',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 服務名稱
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '服務名稱',
                  hintText: '請輸入服務名稱',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入服務名稱';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 服務類別
              DropdownButtonFormField<ServiceCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '服務類別',
                ),
                items: ServiceCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 所需時間
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: '所需時間（分鐘）',
                  hintText: '例如：30',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入所需時間';
                  }
                  if (int.tryParse(value) == null) {
                    return '請輸入有效數字';
                  }
                  if (int.parse(value) < 10 || int.parse(value) > 480) {
                    return '時間必須在10至480分鐘之間';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 建議回訪週期
              TextFormField(
                controller: _revisitPeriodController,
                decoration: const InputDecoration(
                  labelText: '建議回訪週期（天）',
                  hintText: '例如：45',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入回訪週期';
                  }
                  if (int.tryParse(value) == null) {
                    return '請輸入有效數字';
                  }
                  if (int.parse(value) < 0 || int.parse(value) > 365) {
                    return '週期必須在0至365天之間';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 價格
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '價格（NT\$）',
                  hintText: '例如：600',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入價格';
                  }
                  if (double.tryParse(value) == null) {
                    return '請輸入有效數字';
                  }
                  if (double.parse(value) < 0) {
                    return '價格不能為負數';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 利潤
              TextFormField(
                controller: _profitController,
                decoration: const InputDecoration(
                  labelText: '利潤（NT\$）',
                  hintText: '例如：400',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入利潤';
                  }
                  if (double.tryParse(value) == null) {
                    return '請輸入有效數字';
                  }
                  if (double.parse(value) < 0) {
                    return '利潤不能為負數';
                  }
                  if (_priceController.text.isNotEmpty && 
                      double.parse(value) > double.parse(_priceController.text)) {
                    return '利潤不能高於價格';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（選填）',
                  hintText: '請輸入服務描述',
                ),
                maxLines: 3,
              ),
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
                    child: const Text('儲存'),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 