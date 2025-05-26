import '../models/business.dart';
import '../models/service.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service_history.dart';
import '../models/business_goal.dart';
import '../models/business_analysis.dart';

class MockDataService {
  // Mock business data
  static List<Business> getMockBusinesses() {
    return [
      Business(
        id: '1',
        name: '美髮沙龍',
        description: '專業的美髮服務，提供剪髮、染髮、燙髮等服務',
        address: '台北市信義區松高路123號',
        phone: '02-2345-6789',
        email: 'salon@example.com',
        logoUrl: 'https://picsum.photos/200',
        socialLinks: '{"facebook": "https://facebook.com/salon", "instagram": "https://instagram.com/salon"}',
        taxId: '12345678',
      ),
      Business(
        id: '2',
        name: '美容SPA',
        description: '提供專業的美容護理和SPA服務',
        address: '台北市大安區忠孝東路456號',
        phone: '02-3456-7890',
        email: 'spa@example.com',
        logoUrl: 'https://picsum.photos/201',
        socialLinks: '{"facebook": "https://facebook.com/spa", "instagram": "https://instagram.com/spa"}',
        taxId: '87654321',
      ),
    ];
  }

  // Mock services data
  static List<Service> getMockServices() {
    return [
      Service(
        id: '1',
        businessId: '1',
        name: '男士剪髮',
        category: ServiceCategory.hair,
        duration: 30,
        revisitPeriod: 45,
        price: 600,
        profit: 400,
        description: '適合男士的基礎剪髮服務',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '2',
        businessId: '1',
        name: '女士剪髮',
        category: ServiceCategory.hair,
        duration: 45,
        revisitPeriod: 45,
        price: 800,
        profit: 600,
        description: '適合女士的基礎剪髮服務',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '3',
        businessId: '1',
        name: '兒童剪髮',
        category: ServiceCategory.hair,
        duration: 20,
        revisitPeriod: 30,
        price: 400,
        profit: 300,
        description: '適合兒童的基礎剪髮服務',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '4',
        businessId: '1',
        name: '瀏海修剪',
        category: ServiceCategory.hair,
        duration: 15,
        revisitPeriod: 20,
        price: 200,
        profit: 150,
        description: '快速瀏海修剪服務',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '5',
        businessId: '1',
        name: '造型剪髮',
        category: ServiceCategory.hair,
        duration: 60,
        revisitPeriod: 60,
        price: 1200,
        profit: 800,
        description: '專業造型剪髮服務',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  // Mock customers data
  static Future<List<Customer>> getMockCustomers() async {
    return [
      Customer(
        id: '1',
        businessId: '1',
        name: '王小明',
        gender: 'male',
        phone: '+886912345678',
        email: 'wang@example.com',
        source: '朋友推薦',
        isSpecialCustomer: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Customer(
        id: '2',
        businessId: '1',
        name: '李小花',
        gender: 'female',
        phone: '+886923456789',
        email: 'lee@example.com',
        source: '網路搜尋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock appointments data
  static Future<List<Appointment>> getMockAppointments() async {
    final customers = await getMockCustomers();
    final services = await getMockServices();
    
    return [
      Appointment(
        id: '1',
        businessId: '1',
        customerId: customers[0].id,
        serviceId: services[0].id,
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        status: AppointmentStatus.booked,
        customer: customers[0],
        service: services[0],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '2',
        businessId: '1',
        customerId: customers[1].id,
        serviceId: services[1].id,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.confirmed,
        customer: customers[1],
        service: services[1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '3',
        businessId: '1',
        customerId: customers[0].id,
        serviceId: services[2].id,
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        status: AppointmentStatus.checked_in,
        customer: customers[0],
        service: services[2],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock service history data
  static List<ServiceHistory> getMockServiceHistory() {
    return [
      ServiceHistory(
        id: '1',
        customerId: '1',
        serviceId: '1',
        businessId: '1',
        serviceDate: DateTime.now().subtract(const Duration(days: 7)),
        price: 800,
        photos: '["https://picsum.photos/202"]',
        feedback: '服務很好，很滿意',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServiceHistory(
        id: '2',
        customerId: '2',
        serviceId: '2',
        businessId: '1',
        serviceDate: DateTime.now().subtract(const Duration(days: 14)),
        price: 2000,
        photos: '["https://picsum.photos/203"]',
        feedback: '染髮效果很好，會再來',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock business goals data
  static List<BusinessGoal> getMockBusinessGoals(String? businessId) {
    final goals = [
      BusinessGoal(
        id: '1',
        businessId: businessId ?? '1',
        title: '本月營收目標',
        currentValue: 128500,
        targetValue: 150000,
        unit: '元',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.revenue,
      ),
      BusinessGoal(
        id: '2',
        businessId: businessId ?? '1',
        title: '本月預約目標',
        currentValue: 156,
        targetValue: 200,
        unit: '次',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.service_count,
      ),
      BusinessGoal(
        id: '3',
        businessId: businessId ?? '1',
        title: '本月新增客戶目標',
        currentValue: 28,
        targetValue: 40,
        unit: '人',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.customer_count,
      ),
    ];

    if (businessId == null) {
      return goals;
    }

    return goals.where((goal) => goal.businessId == businessId).toList();
  }

  // Mock business analysis data
  static List<BusinessAnalysis> getMockBusinessAnalyses(String? businessId) {
    final analyses = [
      BusinessAnalysis(
        id: '1',
        businessId: '1',
        analysisType: AnalysisType.revenue,
        period: AnalysisPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        data: {
          'total': 75000,
          'byService': [
            {'name': '男士剪髮', 'value': 25000},
            {'name': '女士剪髮', 'value': 35000},
            {'name': '兒童剪髮', 'value': 15000},
          ],
        },
        status: AnalysisStatus.completed,
      ),
      BusinessAnalysis(
        id: '2',
        businessId: '1',
        analysisType: AnalysisType.customer,
        period: AnalysisPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        data: {
          'total': 32,
          'new': 10,
          'returning': 22,
          'byGender': [
            {'gender': 'male', 'count': 15},
            {'gender': 'female', 'count': 17},
          ],
        },
        status: AnalysisStatus.completed,
      ),
      BusinessAnalysis(
        id: '3',
        businessId: '2',
        analysisType: AnalysisType.service,
        period: AnalysisPeriod.monthly,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        data: {
          'total': 45,
          'byType': [
            {'type': 'hair', 'count': 30},
            {'type': 'nail', 'count': 15},
          ],
        },
        status: AnalysisStatus.in_progress,
      ),
    ];

    if (businessId == null) {
      return analyses;
    }

    return analyses.where((analysis) => analysis.businessId == businessId).toList();
  }
} 