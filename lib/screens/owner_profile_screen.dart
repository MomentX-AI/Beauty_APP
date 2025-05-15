import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _businessHoursFormKey = GlobalKey<FormState>();
  final _socialLinksFormKey = GlobalKey<FormState>();
  
  // 表單控制器
  final _businessNameController = TextEditingController(text: '王小美髮廊');
  final _phoneController = TextEditingController(text: '02-2345-6789');
  final _mobileController = TextEditingController(text: '0912-345-678');
  final _addressController = TextEditingController(text: '台北市中山區美髮路123號');
  final _taxIdController = TextEditingController(text: '12345678');
  final _emailController = TextEditingController(text: 'wanghairsalon@example.com');
  
  // 營業時間控制器
  final List<TimeOfDay?> _openTimes = List.filled(7, null);
  final List<TimeOfDay?> _closeTimes = List.filled(7, null);
  final List<bool> _isClosed = List.filled(7, false);
  
  // 社群連結控制器
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _lineController = TextEditingController();
  
  // 頭像相關
  File? _avatarImage;
  String? _avatarBase64;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 設置預設營業時間
    _openTimes[0] = const TimeOfDay(hour: 10, minute: 0); // 週一
    _closeTimes[0] = const TimeOfDay(hour: 20, minute: 0);
    _openTimes[1] = const TimeOfDay(hour: 10, minute: 0); // 週二
    _closeTimes[1] = const TimeOfDay(hour: 20, minute: 0);
    _openTimes[2] = const TimeOfDay(hour: 10, minute: 0); // 週三
    _closeTimes[2] = const TimeOfDay(hour: 20, minute: 0);
    _openTimes[3] = const TimeOfDay(hour: 10, minute: 0); // 週四
    _closeTimes[3] = const TimeOfDay(hour: 20, minute: 0);
    _openTimes[4] = const TimeOfDay(hour: 10, minute: 0); // 週五
    _closeTimes[4] = const TimeOfDay(hour: 20, minute: 0);
    _openTimes[5] = const TimeOfDay(hour: 10, minute: 0); // 週六
    _closeTimes[5] = const TimeOfDay(hour: 18, minute: 0);
    _isClosed[6] = true; // 週日休息
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        if (kIsWeb) {
          // For web platform, we need to handle the image differently
          final bytes = await image.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _avatarImage = null; // Clear the File object
            _avatarBase64 = base64String; // Store the base64 string
          });
        } else {
          setState(() {
            _avatarImage = File(image.path);
            _avatarBase64 = null; // Clear the base64 string
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('選擇圖片時發生錯誤：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '請輸入$fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入 Email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '請輸入有效的 Email 地址';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電話號碼';
    }
    if (!RegExp(r'^\d{2,3}-\d{3,4}-\d{4}$').hasMatch(value)) {
      return '請輸入有效的電話號碼格式（例如：02-2345-6789）';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入手機號碼';
    }
    if (!RegExp(r'^\d{4}-\d{3}-\d{3}$').hasMatch(value)) {
      return '請輸入有效的手機號碼格式（例如：0912-345-678）';
    }
    return null;
  }

  String? _validateTaxId(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入統一編號';
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return '統一編號必須為 8 位數字';
    }
    return null;
  }

  Future<void> _selectTime(BuildContext context, int index, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTimes[index] ?? const TimeOfDay(hour: 10, minute: 0)
                             : _closeTimes[index] ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTimes[index] = picked;
        } else {
          _closeTimes[index] = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 頁籤區域
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF6C5CE7),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade700,
            indicator: BoxDecoration(
              color: const Color(0xFF6C5CE7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
            ),
            tabs: const [
              Tab(text: '基本資料'),
              Tab(text: '營業時間'),
              Tab(text: '社群連結'),
            ],
          ),
        ),
        // 頁籤內容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildBusinessHoursTab(),
              _buildSocialLinksTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頭像區域
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : _avatarBase64 != null
                              ? MemoryImage(base64Decode(_avatarBase64!)) as ImageProvider
                              : null,
                      child: _avatarImage == null && _avatarBase64 == null
                          ? Text(
                              AuthService.userName?[0] ?? 'U',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        '更換頭像',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                // 店家資訊表單
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '店家基本資料',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: '店家名稱',
                        controller: _businessNameController,
                        validator: (value) => _validateRequired(value, '店家名稱'),
                      ),
                      _buildFormField(
                        label: '連絡電話',
                        controller: _phoneController,
                        validator: _validatePhone,
                      ),
                      _buildFormField(
                        label: '行動電話',
                        controller: _mobileController,
                        validator: _validateMobile,
                      ),
                      _buildFormField(
                        label: '地址',
                        controller: _addressController,
                        validator: (value) => _validateRequired(value, '地址'),
                      ),
                      // 地圖預覽
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            '地圖預覽',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      _buildFormField(
                        label: '統一編號',
                        controller: _taxIdController,
                        validator: _validateTaxId,
                      ),
                      _buildFormField(
                        label: 'Email',
                        controller: _emailController,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 24),
                      // 按鈕區域
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              // TODO: 實現取消功能
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // TODO: 實現儲存功能
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('基本資料已儲存')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              '儲存變更',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _businessHoursFormKey,
        child: Column(
          children: [
            const Text(
              '營業時間設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(7, (index) {
              final weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(weekdays[index]),
                    ),
                    Checkbox(
                      value: !_isClosed[index],
                      onChanged: (value) {
                        setState(() {
                          _isClosed[index] = !(value ?? true);
                        });
                      },
                    ),
                    if (!_isClosed[index]) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => _selectTime(context, index, true),
                                child: Text(
                                  _openTimes[index]?.format(context) ?? '選擇時間',
                                ),
                              ),
                            ),
                            const Text('至'),
                            Expanded(
                              child: TextButton(
                                onPressed: () => _selectTime(context, index, false),
                                child: Text(
                                  _closeTimes[index]?.format(context) ?? '選擇時間',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const Expanded(
                        child: Text('休息'),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: 實現取消功能
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_businessHoursFormKey.currentState!.validate()) {
                      // TODO: 實現儲存功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('營業時間已儲存')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '儲存變更',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _socialLinksFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '社群連結設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: 'Facebook',
              controller: _facebookController,
              prefixIcon: Icons.facebook,
              hintText: '請輸入 Facebook 粉絲專頁網址',
            ),
            _buildFormField(
              label: 'Instagram',
              controller: _instagramController,
              prefixIcon: Icons.camera_alt,
              hintText: '請輸入 Instagram 帳號',
            ),
            _buildFormField(
              label: 'Line',
              controller: _lineController,
              prefixIcon: Icons.message,
              hintText: '請輸入 Line 官方帳號 ID',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: 實現取消功能
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_socialLinksFormKey.currentState!.validate()) {
                      // TODO: 實現儲存功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('社群連結已儲存')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '儲存變更',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 