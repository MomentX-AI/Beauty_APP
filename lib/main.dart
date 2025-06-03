import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/billing_management_screen.dart';
import 'screens/staff_performance_analysis_screen.dart';
import 'services/auth_service.dart';
import 'services/mock_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用默認的商業 ID 作為測試
    const String defaultBusinessId = '1';
    
    return MaterialApp(
      title: '美容管理系統',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: AuthService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(businessId: defaultBusinessId),
        '/subscription': (context) => const SubscriptionManagementScreen(businessId: defaultBusinessId),
        '/billing': (context) => const BillingManagementScreen(businessId: defaultBusinessId),
        '/staff-performance-analysis': (context) => const StaffPerformanceAnalysisScreen(),
      },
    );
  }
}
