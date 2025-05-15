import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
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
    const String defaultBusinessId = 'business_001';
    
    return MaterialApp(
      title: '美容管理系統',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: AuthService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => DashboardScreen(businessId: defaultBusinessId),
      },
    );
  }
}
