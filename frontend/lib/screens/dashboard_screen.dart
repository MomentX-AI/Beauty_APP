import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'owner_profile_screen.dart';
import 'goal_management_screen.dart';
import 'customer_screen.dart';
import 'service_screen.dart';
import 'appointment_screen.dart';
import 'ai_assistant_screen.dart';
import 'dashboard_home_screen.dart';
import 'staff_screen.dart';
import 'subscription_management_screen.dart';
import 'billing_management_screen.dart';
import 'staff_performance_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String businessId;
  
  const DashboardScreen({super.key, required this.businessId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSidebarCollapsed = false;
  List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.chat, 'title': 'AI 助理', 'isSelected': false},
    {'icon': Icons.dashboard, 'title': '門店績效分析', 'isSelected': true},
    {'icon': Icons.leaderboard, 'title': '員工績效分析', 'isSelected': false},
    {'icon': Icons.flag, 'title': '業務目標管理', 'isSelected': false},
    {'icon': Icons.calendar_today, 'title': '預約管理', 'isSelected': false},
    {'icon': Icons.people, 'title': '客戶管理', 'isSelected': false},
    {'icon': Icons.room_service, 'title': '服務管理', 'isSelected': false},
    {'icon': Icons.person, 'title': '員工管理', 'isSelected': false},
    {'icon': Icons.card_membership, 'title': '方案管理', 'isSelected': false},
    {'icon': Icons.receipt, 'title': '帳單管理', 'isSelected': false},
    {'icon': Icons.account_circle, 'title': '帳號管理', 'isSelected': false},
  ];

  void _selectMenuItem(int index) {
    setState(() {
      for (var i = 0; i < _menuItems.length; i++) {
        _menuItems[i]['isSelected'] = i == index;
      }
    });
  }

  Widget _getCurrentPage() {
    final selectedIndex = _menuItems.indexWhere((item) => item['isSelected']);
    if (selectedIndex == -1) {
      return const DashboardHomeScreen();
    }
    
    switch (selectedIndex) {
      case 0:
        return const AIAssistantScreen();
      case 1:
        return const DashboardHomeScreen();
      case 2:
        return const StaffPerformanceAnalysisScreen();
      case 3:
        return GoalManagementScreen(businessId: widget.businessId);
      case 4:
        return AppointmentScreen(businessId: widget.businessId);
      case 5:
        return const CustomerScreen();
      case 6:
        return ServiceScreen(businessId: widget.businessId);
      case 7:
        return StaffScreen(businessId: widget.businessId);
      case 8:
        return SubscriptionManagementScreen(businessId: widget.businessId);
      case 9:
        return BillingManagementScreen(businessId: widget.businessId);
      case 10:
        return const OwnerProfileScreen();
      default:
        return const DashboardHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 側邊欄
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 250,
            color: const Color(0xFF373A40),
            child: Column(
              children: [
                // 頂部應用名稱
                Container(
                  height: 50,
                  color: const Color(0xFF2C2E33),
                  child: Row(
                    mainAxisAlignment: _isSidebarCollapsed 
                        ? MainAxisAlignment.center 
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSidebarCollapsed)
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              '美業管理系統',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarCollapsed = !_isSidebarCollapsed;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // 用戶信息
                if (!_isSidebarCollapsed)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Color(0xFF6C5CE7)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthService.userName ?? '用戶',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              '主理人',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // 選單項目
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item['isSelected']
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['isSelected']
                                ? Colors.white
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        title: !_isSidebarCollapsed
                            ? Text(
                                item['title'],
                                style: TextStyle(
                                  color: item['isSelected']
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                        selected: item['isSelected'],
                        selectedTileColor: const Color(0xFF6C5CE7),
                        onTap: () => _selectMenuItem(index),
                      );
                    },
                  ),
                ),
                // 版本號
                if (!_isSidebarCollapsed)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.1',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // 主要內容區域
          Expanded(
            child: _getCurrentPage(),
          ),
        ],
      ),
    );
  }
} 