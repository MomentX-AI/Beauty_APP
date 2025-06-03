import '../models/business.dart';
import '../models/service.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/service_history.dart';
import '../models/business_goal.dart';
import '../models/business_analysis.dart';
import '../models/branch.dart';
import '../models/branch_special_day.dart';
import '../models/branch_service.dart';
import '../models/staff.dart';
import '../models/staff_schedule.dart';

class MockDataService {
  // Mock businesses data
  static List<Business> getMockBusinesses() {
    return [
      Business(
        id: '1',
        name: '王小美髮廊',
        description: '專業美髮服務',
        address: '台北市中山區美髮路123號',
        phone: '02-2345-6789',
        email: 'wanghairsalon@example.com',
        logoUrl: 'https://picsum.photos/200',
        socialLinks: '{"facebook": "wanghairsalon", "instagram": "wanghairsalon"}',
        taxId: '12345678',
        timezone: 'Asia/Taipei',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Mock branches data
  static List<Branch> getMockBranches(String? businessId) {
    return [
      Branch(
        id: '1',
        businessId: businessId ?? '1',
        name: '總店',
        contactPhone: '02-2345-6789',
        address: '台北市中山區美髮路123號',
        isDefault: true,
        status: 'active',
        operatingHoursStart: '10:00',
        operatingHoursEnd: '20:00',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Branch(
        id: '2',
        businessId: businessId ?? '1',
        name: '信義門店',
        contactPhone: '02-2765-4321',
        address: '台北市信義區信義路456號',
        isDefault: false,
        status: 'active',
        operatingHoursStart: '11:00',
        operatingHoursEnd: '21:00',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Branch(
        id: '3',
        businessId: businessId ?? '1',
        name: '西門門店',
        contactPhone: '02-2388-9999',
        address: '台北市萬華區西門路789號',
        isDefault: false,
        status: 'active',
        operatingHoursStart: '12:00',
        operatingHoursEnd: '22:00',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Branch(
        id: '4',
        businessId: businessId ?? '1',
        name: '板橋門店',
        contactPhone: '02-2960-1234',
        address: '新北市板橋區文化路321號',
        isDefault: false,
        status: 'active',
        operatingHoursStart: '10:30',
        operatingHoursEnd: '20:30',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Branch(
        id: '5',
        businessId: businessId ?? '1',
        name: '天母門店',
        contactPhone: '02-2871-5678',
        address: '台北市士林區天母東路567號',
        isDefault: false,
        status: 'active',
        operatingHoursStart: '11:00',
        operatingHoursEnd: '21:00',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Branch(
        id: '6',
        businessId: businessId ?? '1',
        name: '內湖門店',
        contactPhone: '02-2627-8901',
        address: '台北市內湖區成功路四段890號',
        isDefault: false,
        status: 'active',
        operatingHoursStart: '10:00',
        operatingHoursEnd: '20:00',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Mock branch special days data
  static List<BranchSpecialDay> getMockBranchSpecialDays(String branchId, {DateTime? date}) {
    final now = DateTime.now();
    final allSpecialDays = [
      BranchSpecialDay(
        id: '1',
        branchId: '1',
        date: DateTime(now.year, now.month + 1, 1), // 下個月1號
        isOpen: false,
        operatingHoursStart: null,
        operatingHoursEnd: null,
        reason: '元旦假期',
        createdAt: now,
        updatedAt: now,
      ),
      BranchSpecialDay(
        id: '2',
        branchId: '1',
        date: DateTime(now.year, now.month, 25), // 本月25號
        isOpen: true,
        operatingHoursStart: '14:00',
        operatingHoursEnd: '18:00',
        reason: '聖誕節特別營業',
        createdAt: now,
        updatedAt: now,
      ),
      BranchSpecialDay(
        id: '3',
        branchId: '2',
        date: DateTime(now.year, now.month + 1, 15), // 下個月15號
        isOpen: false,
        operatingHoursStart: null,
        operatingHoursEnd: null,
        reason: '員工培訓日',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Filter by branch ID and date if provided
    var filtered = allSpecialDays.where((day) => day.branchId == branchId);
    if (date != null) {
      filtered = filtered.where((day) => 
        day.date.year == date.year &&
        day.date.month == date.month &&
        day.date.day == date.day
      );
    }
    return filtered.toList();
  }

  // Mock services data
  static List<Service> getMockServices() {
    return [
      // 美髮服務
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
      Service(
        id: '6',
        businessId: '1',
        name: '洗剪吹',
        category: ServiceCategory.hair,
        duration: 90,
        revisitPeriod: 45,
        price: 1500,
        profit: 1000,
        description: '包含洗髮、剪髮、吹整的完整服務',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '7',
        businessId: '1',
        name: '染髮',
        category: ServiceCategory.hair,
        duration: 120,
        revisitPeriod: 90,
        price: 2500,
        profit: 1500,
        description: '專業染髮服務，包含護髮',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '8',
        businessId: '1',
        name: '燙髮',
        category: ServiceCategory.hair,
        duration: 180,
        revisitPeriod: 120,
        price: 3500,
        profit: 2200,
        description: '專業燙髮服務，包含護髮',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '9',
        businessId: '1',
        name: '深層護髮',
        category: ServiceCategory.hair,
        duration: 60,
        revisitPeriod: 30,
        price: 800,
        profit: 500,
        description: '深層滋養護髮療程',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),

      // 美甲服務
      Service(
        id: '10',
        businessId: '1',
        name: '基礎美甲',
        category: ServiceCategory.nail,
        duration: 60,
        revisitPeriod: 21,
        price: 800,
        profit: 500,
        description: '基礎指甲修護與上色',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Service(
        id: '11',
        businessId: '1',
        name: '凝膠美甲',
        category: ServiceCategory.nail,
        duration: 90,
        revisitPeriod: 28,
        price: 1200,
        profit: 800,
        description: '持久凝膠美甲，可維持3-4週',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Service(
        id: '12',
        businessId: '1',
        name: '光療美甲',
        category: ServiceCategory.nail,
        duration: 120,
        revisitPeriod: 35,
        price: 1800,
        profit: 1200,
        description: '專業光療美甲，持久亮麗',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      Service(
        id: '13',
        businessId: '1',
        name: '手部護理',
        category: ServiceCategory.nail,
        duration: 45,
        revisitPeriod: 14,
        price: 600,
        profit: 400,
        description: '手部深層護理與保養',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),

      // 睫毛服務
      Service(
        id: '14',
        businessId: '1',
        name: '睫毛嫁接',
        category: ServiceCategory.lash,
        duration: 120,
        revisitPeriod: 21,
        price: 2000,
        profit: 1300,
        description: '專業睫毛嫁接，自然濃密',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Service(
        id: '15',
        businessId: '1',
        name: '睫毛補接',
        category: ServiceCategory.lash,
        duration: 60,
        revisitPeriod: 14,
        price: 800,
        profit: 500,
        description: '睫毛補接維護服務',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Service(
        id: '16',
        businessId: '1',
        name: '睫毛燙翹',
        category: ServiceCategory.lash,
        duration: 90,
        revisitPeriod: 45,
        price: 1200,
        profit: 800,
        description: '自然睫毛燙翹服務',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),

      // 美容護膚服務
      Service(
        id: '17',
        businessId: '1',
        name: '基礎清潔護膚',
        category: ServiceCategory.skin,
        duration: 60,
        revisitPeriod: 14,
        price: 1000,
        profit: 650,
        description: '深層清潔與基礎護膚',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Service(
        id: '18',
        businessId: '1',
        name: '保濕補水護膚',
        category: ServiceCategory.skin,
        duration: 90,
        revisitPeriod: 21,
        price: 1500,
        profit: 1000,
        description: '深層保濕補水護膚療程',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Service(
        id: '19',
        businessId: '1',
        name: '抗老緊緻護膚',
        category: ServiceCategory.skin,
        duration: 120,
        revisitPeriod: 28,
        price: 2500,
        profit: 1600,
        description: '抗老緊緻專業護膚療程',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Service(
        id: '20',
        businessId: '1',
        name: '痘痘肌護理',
        category: ServiceCategory.skin,
        duration: 75,
        revisitPeriod: 14,
        price: 1200,
        profit: 800,
        description: '專門針對痘痘肌的護理療程',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),

      // 半永久化妝服務
      Service(
        id: '21',
        businessId: '1',
        name: '霧眉',
        category: ServiceCategory.pmu,
        duration: 180,
        revisitPeriod: 365,
        price: 8000,
        profit: 5500,
        description: '自然霧眉半永久化妝',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Service(
        id: '22',
        businessId: '1',
        name: '線條眉',
        category: ServiceCategory.pmu,
        duration: 180,
        revisitPeriod: 365,
        price: 8500,
        profit: 6000,
        description: '仿真線條眉半永久化妝',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Service(
        id: '23',
        businessId: '1',
        name: '美瞳線',
        category: ServiceCategory.pmu,
        duration: 120,
        revisitPeriod: 365,
        price: 6000,
        profit: 4200,
        description: '自然美瞳線半永久化妝',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Service(
        id: '24',
        businessId: '1',
        name: '漂唇',
        category: ServiceCategory.pmu,
        duration: 150,
        revisitPeriod: 365,
        price: 7000,
        profit: 4900,
        description: '自然漂唇半永久化妝',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // 其他服務
      Service(
        id: '25',
        businessId: '1',
        name: '頭皮護理',
        category: ServiceCategory.other,
        duration: 60,
        revisitPeriod: 21,
        price: 1000,
        profit: 700,
        description: '專業頭皮深層護理',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Service(
        id: '26',
        businessId: '1',
        name: '肩頸按摩',
        category: ServiceCategory.other,
        duration: 30,
        revisitPeriod: 7,
        price: 500,
        profit: 350,
        description: '放鬆肩頸按摩服務',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock branch services data
  static List<BranchService> getMockBranchServices(String branchId) {
    final now = DateTime.now();
    
    // 為每個門店創建不同的服務配置
    if (branchId == '1') { // 總店 - 提供所有服務
      return [
        // 美髮服務
        BranchService(id: '1', branchId: '1', serviceId: '1', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '2', branchId: '1', serviceId: '2', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '3', branchId: '1', serviceId: '3', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '4', branchId: '1', serviceId: '4', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '5', branchId: '1', serviceId: '5', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '6', branchId: '1', serviceId: '6', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '7', branchId: '1', serviceId: '7', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '8', branchId: '1', serviceId: '8', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '9', branchId: '1', serviceId: '9', isAvailable: true, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '10', branchId: '1', serviceId: '10', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '11', branchId: '1', serviceId: '11', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '12', branchId: '1', serviceId: '12', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '13', branchId: '1', serviceId: '13', isAvailable: true, createdAt: now, updatedAt: now),
        // 睫毛服務
        BranchService(id: '14', branchId: '1', serviceId: '14', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '15', branchId: '1', serviceId: '15', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '16', branchId: '1', serviceId: '16', isAvailable: true, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '17', branchId: '1', serviceId: '17', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '18', branchId: '1', serviceId: '18', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '19', branchId: '1', serviceId: '19', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '20', branchId: '1', serviceId: '20', isAvailable: true, createdAt: now, updatedAt: now),
        // 半永久化妝服務
        BranchService(id: '21', branchId: '1', serviceId: '21', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '22', branchId: '1', serviceId: '22', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '23', branchId: '1', serviceId: '23', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '24', branchId: '1', serviceId: '24', isAvailable: true, createdAt: now, updatedAt: now),
        // 其他服務
        BranchService(id: '25', branchId: '1', serviceId: '25', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '26', branchId: '1', serviceId: '26', isAvailable: true, createdAt: now, updatedAt: now),
      ];
    } else if (branchId == '2') { // 信義門店 - 高端服務為主，價格較高
      return [
        // 美髮服務 - 自定義價格
        BranchService(id: '27', branchId: '2', serviceId: '1', isAvailable: true, customPrice: 650, customProfit: 450, createdAt: now, updatedAt: now),
        BranchService(id: '28', branchId: '2', serviceId: '2', isAvailable: true, customPrice: 850, customProfit: 650, createdAt: now, updatedAt: now),
        BranchService(id: '29', branchId: '2', serviceId: '5', isAvailable: true, customPrice: 1300, customProfit: 900, createdAt: now, updatedAt: now),
        BranchService(id: '30', branchId: '2', serviceId: '6', isAvailable: true, customPrice: 1600, customProfit: 1100, createdAt: now, updatedAt: now),
        BranchService(id: '31', branchId: '2', serviceId: '7', isAvailable: true, customPrice: 2800, customProfit: 1700, createdAt: now, updatedAt: now),
        BranchService(id: '32', branchId: '2', serviceId: '8', isAvailable: true, customPrice: 3800, customProfit: 2500, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '33', branchId: '2', serviceId: '11', isAvailable: true, customPrice: 1300, customProfit: 900, createdAt: now, updatedAt: now),
        BranchService(id: '34', branchId: '2', serviceId: '12', isAvailable: true, customPrice: 2000, customProfit: 1400, createdAt: now, updatedAt: now),
        // 睫毛服務
        BranchService(id: '35', branchId: '2', serviceId: '14', isAvailable: true, customPrice: 2200, customProfit: 1500, createdAt: now, updatedAt: now),
        BranchService(id: '36', branchId: '2', serviceId: '15', isAvailable: true, customPrice: 900, customProfit: 600, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '37', branchId: '2', serviceId: '18', isAvailable: true, customPrice: 1700, customProfit: 1200, createdAt: now, updatedAt: now),
        BranchService(id: '38', branchId: '2', serviceId: '19', isAvailable: true, customPrice: 2800, customProfit: 1900, createdAt: now, updatedAt: now),
        // 半永久化妝服務
        BranchService(id: '39', branchId: '2', serviceId: '21', isAvailable: true, customPrice: 8500, customProfit: 6000, createdAt: now, updatedAt: now),
        BranchService(id: '40', branchId: '2', serviceId: '22', isAvailable: true, customPrice: 9000, customProfit: 6500, createdAt: now, updatedAt: now),
      ];
    } else if (branchId == '3') { // 西門門店 - 年輕族群，基礎服務為主
      return [
        // 美髮服務 - 部分優惠價格
        BranchService(id: '41', branchId: '3', serviceId: '1', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '42', branchId: '3', serviceId: '2', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '43', branchId: '3', serviceId: '3', isAvailable: true, customPrice: 350, customProfit: 250, createdAt: now, updatedAt: now),
        BranchService(id: '44', branchId: '3', serviceId: '4', isAvailable: true, createdAt: now, updatedAt: now),
        BranchService(id: '45', branchId: '3', serviceId: '6', isAvailable: true, customPrice: 1400, customProfit: 950, createdAt: now, updatedAt: now),
        BranchService(id: '46', branchId: '3', serviceId: '7', isAvailable: true, customPrice: 2300, customProfit: 1400, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '47', branchId: '3', serviceId: '10', isAvailable: true, customPrice: 750, customProfit: 450, createdAt: now, updatedAt: now),
        BranchService(id: '48', branchId: '3', serviceId: '11', isAvailable: true, customPrice: 1100, customProfit: 750, createdAt: now, updatedAt: now),
        // 睫毛服務
        BranchService(id: '49', branchId: '3', serviceId: '14', isAvailable: true, customPrice: 1800, customProfit: 1200, createdAt: now, updatedAt: now),
        BranchService(id: '50', branchId: '3', serviceId: '16', isAvailable: true, customPrice: 1100, customProfit: 750, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '51', branchId: '3', serviceId: '17', isAvailable: true, customPrice: 900, customProfit: 600, createdAt: now, updatedAt: now),
        BranchService(id: '52', branchId: '3', serviceId: '20', isAvailable: true, customPrice: 1100, customProfit: 750, createdAt: now, updatedAt: now),
      ];
    } else if (branchId == '4') { // 板橋門店 - 家庭客群，全面服務
      return [
        // 美髮服務
        BranchService(id: '53', branchId: '4', serviceId: '1', isAvailable: true, customPrice: 580, customProfit: 380, createdAt: now, updatedAt: now),
        BranchService(id: '54', branchId: '4', serviceId: '2', isAvailable: true, customPrice: 750, customProfit: 550, createdAt: now, updatedAt: now),
        BranchService(id: '55', branchId: '4', serviceId: '3', isAvailable: true, customPrice: 380, customProfit: 280, createdAt: now, updatedAt: now),
        BranchService(id: '56', branchId: '4', serviceId: '4', isAvailable: true, customPrice: 180, customProfit: 130, createdAt: now, updatedAt: now),
        BranchService(id: '57', branchId: '4', serviceId: '5', isAvailable: true, customPrice: 1150, customProfit: 750, createdAt: now, updatedAt: now),
        BranchService(id: '58', branchId: '4', serviceId: '6', isAvailable: true, customPrice: 1450, customProfit: 950, createdAt: now, updatedAt: now),
        BranchService(id: '59', branchId: '4', serviceId: '9', isAvailable: true, customPrice: 750, customProfit: 450, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '60', branchId: '4', serviceId: '10', isAvailable: true, customPrice: 750, customProfit: 450, createdAt: now, updatedAt: now),
        BranchService(id: '61', branchId: '4', serviceId: '11', isAvailable: true, customPrice: 1150, customProfit: 750, createdAt: now, updatedAt: now),
        BranchService(id: '62', branchId: '4', serviceId: '13', isAvailable: true, customPrice: 550, customProfit: 350, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '63', branchId: '4', serviceId: '17', isAvailable: true, customPrice: 950, customProfit: 600, createdAt: now, updatedAt: now),
        BranchService(id: '64', branchId: '4', serviceId: '18', isAvailable: true, customPrice: 1400, customProfit: 950, createdAt: now, updatedAt: now),
        // 其他服務
        BranchService(id: '65', branchId: '4', serviceId: '25', isAvailable: true, customPrice: 950, customProfit: 650, createdAt: now, updatedAt: now),
        BranchService(id: '66', branchId: '4', serviceId: '26', isAvailable: true, customPrice: 450, customProfit: 300, createdAt: now, updatedAt: now),
      ];
    } else if (branchId == '5') { // 天母門店 - 高端客群，專業服務
      return [
        // 美髮服務 - 高端定價
        BranchService(id: '67', branchId: '5', serviceId: '2', isAvailable: true, customPrice: 900, customProfit: 700, createdAt: now, updatedAt: now),
        BranchService(id: '68', branchId: '5', serviceId: '5', isAvailable: true, customPrice: 1350, customProfit: 950, createdAt: now, updatedAt: now),
        BranchService(id: '69', branchId: '5', serviceId: '6', isAvailable: true, customPrice: 1650, customProfit: 1150, createdAt: now, updatedAt: now),
        BranchService(id: '70', branchId: '5', serviceId: '7', isAvailable: true, customPrice: 2800, customProfit: 1700, createdAt: now, updatedAt: now),
        BranchService(id: '71', branchId: '5', serviceId: '8', isAvailable: true, customPrice: 3800, customProfit: 2500, createdAt: now, updatedAt: now),
        BranchService(id: '72', branchId: '5', serviceId: '9', isAvailable: true, customPrice: 850, customProfit: 550, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '73', branchId: '5', serviceId: '11', isAvailable: true, customPrice: 1350, customProfit: 950, createdAt: now, updatedAt: now),
        BranchService(id: '74', branchId: '5', serviceId: '12', isAvailable: true, customPrice: 2000, customProfit: 1400, createdAt: now, updatedAt: now),
        BranchService(id: '75', branchId: '5', serviceId: '13', isAvailable: true, customPrice: 650, customProfit: 450, createdAt: now, updatedAt: now),
        // 睫毛服務
        BranchService(id: '76', branchId: '5', serviceId: '14', isAvailable: true, customPrice: 2300, customProfit: 1600, createdAt: now, updatedAt: now),
        BranchService(id: '77', branchId: '5', serviceId: '15', isAvailable: true, customPrice: 900, customProfit: 600, createdAt: now, updatedAt: now),
        BranchService(id: '78', branchId: '5', serviceId: '16', isAvailable: true, customPrice: 1350, customProfit: 950, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '79', branchId: '5', serviceId: '18', isAvailable: true, customPrice: 1650, customProfit: 1150, createdAt: now, updatedAt: now),
        BranchService(id: '80', branchId: '5', serviceId: '19', isAvailable: true, customPrice: 2800, customProfit: 1900, createdAt: now, updatedAt: now),
        // 半永久化妝服務
        BranchService(id: '81', branchId: '5', serviceId: '21', isAvailable: true, customPrice: 8800, customProfit: 6300, createdAt: now, updatedAt: now),
        BranchService(id: '82', branchId: '5', serviceId: '22', isAvailable: true, customPrice: 9300, customProfit: 6800, createdAt: now, updatedAt: now),
        BranchService(id: '83', branchId: '5', serviceId: '23', isAvailable: true, customPrice: 6500, customProfit: 4700, createdAt: now, updatedAt: now),
        BranchService(id: '84', branchId: '5', serviceId: '24', isAvailable: true, customPrice: 7500, customProfit: 5300, createdAt: now, updatedAt: now),
      ];
    } else if (branchId == '6') { // 內湖門店 - 上班族客群，快速服務
      return [
        // 美髮服務 - 快速服務為主
        BranchService(id: '85', branchId: '6', serviceId: '1', isAvailable: true, customPrice: 580, customProfit: 380, createdAt: now, updatedAt: now),
        BranchService(id: '86', branchId: '6', serviceId: '2', isAvailable: true, customPrice: 780, customProfit: 580, createdAt: now, updatedAt: now),
        BranchService(id: '87', branchId: '6', serviceId: '4', isAvailable: true, customPrice: 180, customProfit: 130, createdAt: now, updatedAt: now),
        BranchService(id: '88', branchId: '6', serviceId: '5', isAvailable: true, customPrice: 1180, customProfit: 780, createdAt: now, updatedAt: now),
        BranchService(id: '89', branchId: '6', serviceId: '6', isAvailable: true, customPrice: 1480, customProfit: 980, createdAt: now, updatedAt: now),
        BranchService(id: '90', branchId: '6', serviceId: '9', isAvailable: true, customPrice: 780, customProfit: 480, createdAt: now, updatedAt: now),
        // 美甲服務
        BranchService(id: '91', branchId: '6', serviceId: '10', isAvailable: true, customPrice: 780, customProfit: 480, createdAt: now, updatedAt: now),
        BranchService(id: '92', branchId: '6', serviceId: '11', isAvailable: true, customPrice: 1180, customProfit: 780, createdAt: now, updatedAt: now),
        BranchService(id: '93', branchId: '6', serviceId: '13', isAvailable: true, customPrice: 580, customProfit: 380, createdAt: now, updatedAt: now),
        // 睫毛服務
        BranchService(id: '94', branchId: '6', serviceId: '15', isAvailable: true, customPrice: 780, customProfit: 480, createdAt: now, updatedAt: now),
        BranchService(id: '95', branchId: '6', serviceId: '16', isAvailable: true, customPrice: 1180, customProfit: 780, createdAt: now, updatedAt: now),
        // 美容護膚服務
        BranchService(id: '96', branchId: '6', serviceId: '17', isAvailable: true, customPrice: 980, customProfit: 630, createdAt: now, updatedAt: now),
        BranchService(id: '97', branchId: '6', serviceId: '20', isAvailable: true, customPrice: 1180, customProfit: 780, createdAt: now, updatedAt: now),
        // 其他服務
        BranchService(id: '98', branchId: '6', serviceId: '25', isAvailable: true, customPrice: 980, customProfit: 680, createdAt: now, updatedAt: now),
        BranchService(id: '99', branchId: '6', serviceId: '26', isAvailable: true, customPrice: 480, customProfit: 330, createdAt: now, updatedAt: now),
      ];
    }
    
    return [];
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
    final services = getMockServices();
    final branches = getMockBranches('1');
    final staff = getMockStaff('1');
    
    return [
      Appointment(
        id: '1',
        businessId: '1',
        branchId: '1', // 總店
        customerId: customers[0].id,
        serviceId: services[0].id, // 男士剪髮
        staffId: '2', // 李經理
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        status: AppointmentStatus.booked,
        customer: customers[0],
        service: services[0],
        branch: branches.firstWhere((b) => b.id == '1'),
        staff: staff.firstWhere((s) => s.id == '2'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '2',
        businessId: '1',
        branchId: '2', // 信義門店
        customerId: customers[1].id,
        serviceId: services[1].id, // 女士剪髮
        staffId: '3', // 張資深
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.confirmed,
        customer: customers[1],
        service: services[1],
        branch: branches.firstWhere((b) => b.id == '2'),
        staff: staff.firstWhere((s) => s.id == '3'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '3',
        businessId: '1',
        branchId: '1', // 總店
        customerId: customers[0].id,
        serviceId: services[2].id, // 兒童剪髮
        staffId: null, // 未指定員工
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        status: AppointmentStatus.checked_in,
        customer: customers[0],
        service: services[2],
        branch: branches.firstWhere((b) => b.id == '1'),
        staff: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '4',
        businessId: '1',
        branchId: '3', // 西門門店
        customerId: customers[1].id,
        serviceId: services[3].id, // 瀏海修剪
        staffId: '5', // 林造型
        startTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        status: AppointmentStatus.booked,
        customer: customers[1],
        service: services[3],
        branch: branches.firstWhere((b) => b.id == '3'),
        staff: staff.firstWhere((s) => s.id == '5'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '5',
        businessId: '1',
        branchId: '4', // 板橋門店
        customerId: customers[0].id,
        serviceId: services[4].id, // 造型剪髮
        staffId: '5', // 林造型
        startTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        status: AppointmentStatus.confirmed,
        customer: customers[0],
        service: services[4],
        branch: branches.firstWhere((b) => b.id == '4'),
        staff: staff.firstWhere((s) => s.id == '5'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '6',
        businessId: '1',
        branchId: '5', // 天母門店
        customerId: customers[1].id,
        serviceId: services[5].id, // 洗剪吹
        staffId: '3', // 張資深
        startTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
        status: AppointmentStatus.completed,
        customer: customers[1],
        service: services[5],
        branch: branches.firstWhere((b) => b.id == '5'),
        staff: staff.firstWhere((s) => s.id == '3'),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '7',
        businessId: '1',
        branchId: '6', // 內湖門店
        customerId: customers[0].id,
        serviceId: services[6].id, // 染髮
        staffId: null, // 未指定員工
        startTime: DateTime.now().add(const Duration(days: 3, hours: 1)),
        endTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
        status: AppointmentStatus.booked,
        customer: customers[0],
        service: services[6],
        branch: branches.firstWhere((b) => b.id == '6'),
        staff: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // 今天的預約
      Appointment(
        id: '8',
        businessId: '1',
        branchId: '1', // 總店
        customerId: customers[1].id,
        serviceId: services[7].id, // 燙髮
        staffId: '3', // 張資深
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 30),
        status: AppointmentStatus.confirmed,
        customer: customers[1],
        service: services[7],
        branch: branches.firstWhere((b) => b.id == '1'),
        staff: staff.firstWhere((s) => s.id == '3'),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: '9',
        businessId: '1',
        branchId: '2', // 信義門店
        customerId: customers[0].id,
        serviceId: services[8].id, // 深層護髮
        staffId: '3', // 張資深
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 0),
        status: AppointmentStatus.booked,
        customer: customers[0],
        service: services[8],
        branch: branches.firstWhere((b) => b.id == '2'),
        staff: staff.firstWhere((s) => s.id == '3'),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '10',
        businessId: '1',
        branchId: '3', // 西門門店
        customerId: customers[1].id,
        serviceId: services[9].id, // 基礎美甲
        staffId: '4', // 陳設計
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30),
        status: AppointmentStatus.checked_in,
        customer: customers[1],
        service: services[9],
        branch: branches.firstWhere((b) => b.id == '3'),
        staff: staff.firstWhere((s) => s.id == '4'),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      // 新增更多預約以展示不同的員工分配
      Appointment(
        id: '11',
        businessId: '1',
        branchId: '1', // 總店
        customerId: customers[0].id,
        serviceId: services[20].id, // 霧眉
        staffId: '6', // 周紋藝（半永久化妝師）
        startTime: DateTime.now().add(const Duration(days: 5, hours: 2)),
        endTime: DateTime.now().add(const Duration(days: 5, hours: 5)),
        status: AppointmentStatus.booked,
        customer: customers[0],
        service: services[20],
        branch: branches.firstWhere((b) => b.id == '1'),
        staff: staff.firstWhere((s) => s.id == '6'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '12',
        businessId: '1',
        branchId: '2', // 信義門店
        customerId: customers[1].id,
        serviceId: services[13].id, // 睫毛嫁接
        staffId: null, // 未指定員工
        startTime: DateTime.now().add(const Duration(days: 7, hours: 3)),
        endTime: DateTime.now().add(const Duration(days: 7, hours: 5)),
        status: AppointmentStatus.booked,
        customer: customers[1],
        service: services[13],
        branch: branches.firstWhere((b) => b.id == '2'),
        staff: null,
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
      // 企業整體目標
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
        level: GoalLevel.business,
        description: '達成全公司的月度營收目標',
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
        level: GoalLevel.business,
        description: '提升整體服務量，增加客戶滿意度',
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
        level: GoalLevel.business,
        description: '拓展新客戶群，提升品牌知名度',
      ),
      
      // 門店目標
      BusinessGoal(
        id: '4',
        businessId: businessId ?? '1',
        title: '總店營收目標',
        currentValue: 42000,
        targetValue: 50000,
        unit: '元',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.revenue,
        level: GoalLevel.branch,
        branchId: '1',
        description: '總店本月營收目標',
      ),
      BusinessGoal(
        id: '5',
        businessId: businessId ?? '1',
        title: '信義門店營收目標',
        currentValue: 35000,
        targetValue: 40000,
        unit: '元',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.revenue,
        level: GoalLevel.branch,
        branchId: '2',
        description: '信義門店本月營收目標',
      ),
      BusinessGoal(
        id: '6',
        businessId: businessId ?? '1',
        title: '西門門店客戶回訪率',
        currentValue: 68,
        targetValue: 75,
        unit: '%',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.revisit_rate,
        level: GoalLevel.branch,
        branchId: '3',
        description: '提升西門門店客戶回訪率',
      ),
      
      // 員工目標
      BusinessGoal(
        id: '7',
        businessId: businessId ?? '1',
        title: '陳美麗個人營收目標',
        currentValue: 15000,
        targetValue: 20000,
        unit: '元',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.revenue,
        level: GoalLevel.staff,
        staffId: '1',
        description: '陳美麗本月個人營收目標',
      ),
      BusinessGoal(
        id: '8',
        businessId: businessId ?? '1',
        title: '王小明服務數量目標',
        currentValue: 45,
        targetValue: 60,
        unit: '次',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.service_count,
        level: GoalLevel.staff,
        staffId: '2',
        description: '王小明本月服務數量目標',
      ),
      BusinessGoal(
        id: '9',
        businessId: businessId ?? '1',
        title: '李大華客戶滿意度',
        currentValue: 88,
        targetValue: 95,
        unit: '%',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.custom,
        level: GoalLevel.staff,
        staffId: '3',
        description: '李大華客戶滿意度評分目標',
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

  // Mock staff data
  static List<Staff> getMockStaff(String businessId) {
    final now = DateTime.now();
    
    return [
      // 店主
      Staff(
        id: '1',
        businessId: businessId,
        name: '王小美',
        email: 'owner@beauty.com',
        phone: '+886912345678',
        role: StaffRole.owner,
        status: StaffStatus.active,
        hireDate: DateTime(2020, 1, 1),
        birthDate: DateTime(1985, 5, 15),
        address: '台北市中山區民生東路一段100號',
        emergencyContact: '王大美',
        emergencyPhone: '+886987654321',
        notes: '創辦人兼主理人，擁有15年美髮經驗',
        branchIds: ['1', '2', '3', '4', '5', '6'], // 可管理所有分店
        serviceIds: ['1', '2', '5', '6', '7', '8', '9'], // 擅長美髮服務
        createdAt: DateTime(2020, 1, 1),
        updatedAt: now,
      ),
      
      // 經理
      Staff(
        id: '2',
        businessId: businessId,
        name: '李經理',
        email: 'manager@beauty.com',
        phone: '+886923456789',
        role: StaffRole.manager,
        status: StaffStatus.active,
        hireDate: DateTime(2021, 3, 15),
        birthDate: DateTime(1988, 8, 20),
        address: '台北市信義區松仁路88號',
        emergencyContact: '李太太',
        emergencyPhone: '+886987123456',
        notes: '負責總店營運管理',
        branchIds: ['1'], // 主要在總店
        serviceIds: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13'], // 多項服務
        createdAt: DateTime(2021, 3, 15),
        updatedAt: now,
      ),
      
      // 資深設計師
      Staff(
        id: '3',
        businessId: businessId,
        name: '張資深',
        email: 'senior@beauty.com',
        phone: '+886934567890',
        role: StaffRole.senior_stylist,
        status: StaffStatus.active,
        hireDate: DateTime(2019, 6, 1),
        birthDate: DateTime(1990, 2, 10),
        address: '台北市大安區敦化南路二段200號',
        emergencyContact: '張先生',
        emergencyPhone: '+886912987654',
        notes: '專精染燙技術，客戶指名率高',
        branchIds: ['1', '2'], // 總店和信義門店
        serviceIds: ['2', '5', '6', '7', '8', '9', '17', '18', '19'], // 美髮和護膚
        createdAt: DateTime(2019, 6, 1),
        updatedAt: now,
      ),
      
      // 設計師1
      Staff(
        id: '4',
        businessId: businessId,
        name: '陳設計',
        email: 'stylist1@beauty.com',
        phone: '+886945678901',
        role: StaffRole.stylist,
        status: StaffStatus.active,
        hireDate: DateTime(2022, 8, 20),
        birthDate: DateTime(1995, 11, 5),
        address: '台北市松山區南京東路四段150號',
        emergencyContact: '陳媽媽',
        emergencyPhone: '+886976543210',
        notes: '專精美甲服務，手藝精湛',
        branchIds: ['1', '3'], // 總店和西門門店
        serviceIds: ['10', '11', '12', '13', '14', '15', '16'], // 美甲和睫毛
        createdAt: DateTime(2022, 8, 20),
        updatedAt: now,
      ),
      
      // 設計師2
      Staff(
        id: '5',
        businessId: businessId,
        name: '林造型',
        email: 'stylist2@beauty.com',
        phone: '+886956789012',
        role: StaffRole.stylist,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 2, 10),
        birthDate: DateTime(1993, 7, 25),
        address: '新北市板橋區中山路一段300號',
        emergencyContact: '林爸爸',
        emergencyPhone: '+886965432109',
        notes: '年輕有活力，深受年輕客群喜愛',
        branchIds: ['3', '4'], // 西門和板橋門店
        serviceIds: ['1', '2', '3', '4', '6', '10', '11', '17', '20'], // 基礎美髮美甲
        createdAt: DateTime(2023, 2, 10),
        updatedAt: now,
      ),
      
      // 半永久化妝師
      Staff(
        id: '6',
        businessId: businessId,
        name: '周紋藝',
        email: 'pmu@beauty.com',
        phone: '+886967890123',
        role: StaffRole.senior_stylist,
        status: StaffStatus.active,
        hireDate: DateTime(2021, 11, 5),
        birthDate: DateTime(1987, 4, 12),
        address: '台北市士林區天母東路500號',
        emergencyContact: '周先生',
        emergencyPhone: '+886954321098',
        notes: '半永久化妝專家，技術獲得多項認證',
        branchIds: ['1', '2', '5'], // 總店、信義和天母門店
        serviceIds: ['21', '22', '23', '24'], // 半永久化妝服務
        createdAt: DateTime(2021, 11, 5),
        updatedAt: now,
      ),
      
      // 助理1
      Staff(
        id: '7',
        businessId: businessId,
        name: '吳助理',
        email: 'assistant1@beauty.com',
        phone: '+886978901234',
        role: StaffRole.assistant,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 9, 1),
        birthDate: DateTime(1998, 12, 8),
        address: '台北市內湖區成功路四段800號',
        emergencyContact: '吳媽媽',
        emergencyPhone: '+886943210987',
        notes: '新人，學習態度積極',
        branchIds: ['1', '6'], // 總店和內湖門店
        serviceIds: ['4', '9', '13', '25', '26'], // 基礎服務和護理
        createdAt: DateTime(2023, 9, 1),
        updatedAt: now,
      ),
      
      // 接待員1
      Staff(
        id: '8',
        businessId: businessId,
        name: '劉接待',
        email: 'reception1@beauty.com',
        phone: '+886989012345',
        role: StaffRole.receptionist,
        status: StaffStatus.active,
        hireDate: DateTime(2022, 5, 15),
        birthDate: DateTime(1996, 9, 30),
        address: '台北市萬華區西門路700號',
        emergencyContact: '劉姊姊',
        emergencyPhone: '+886932109876',
        notes: '親切有禮，客戶服務優秀',
        branchIds: ['1', '2', '3'], // 總店、信義和西門門店
        serviceIds: [], // 不提供技術服務
        createdAt: DateTime(2022, 5, 15),
        updatedAt: now,
      ),
      
      // 接待員2
      Staff(
        id: '9',
        businessId: businessId,
        name: '黃接待',
        email: 'reception2@beauty.com',
        phone: '+886990123456',
        role: StaffRole.receptionist,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 7, 8),
        birthDate: DateTime(1997, 6, 18),
        address: '新北市板橋區文化路250號',
        emergencyContact: '黃媽媽',
        emergencyPhone: '+886921098765',
        notes: '多語言能力，適合接待外國客戶',
        branchIds: ['4', '5', '6'], // 板橋、天母和內湖門店
        serviceIds: ['26'], // 僅提供按摩服務
        createdAt: DateTime(2023, 7, 8),
        updatedAt: now,
      ),
      
      // 請假員工
      Staff(
        id: '10',
        businessId: businessId,
        name: '趙請假',
        email: 'leave@beauty.com',
        phone: '+886901234567',
        role: StaffRole.stylist,
        status: StaffStatus.on_leave,
        hireDate: DateTime(2022, 1, 10),
        birthDate: DateTime(1991, 3, 22),
        address: '台北市中正區忠孝東路一段50號',
        emergencyContact: '趙老公',
        emergencyPhone: '+886910987654',
        notes: '產假中，預計明年復職',
        branchIds: ['2'], // 信義門店
        serviceIds: ['2', '7', '8', '18', '19'], // 美髮和護膚
        createdAt: DateTime(2022, 1, 10),
        updatedAt: now,
      ),
    ];
  }

  // Mock staff schedules data
  static List<StaffSchedule> getMockStaffSchedules(String businessId) {
    final now = DateTime.now();
    final staff = getMockStaff(businessId);
    final branches = getMockBranches(businessId);
    
    List<StaffSchedule> schedules = [];
    
    // 生成本週和下週的班表
    for (int weekOffset = 0; weekOffset < 2; weekOffset++) {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = now.add(Duration(days: weekOffset * 7 + dayOffset - now.weekday + 1));
        
        for (int staffIndex = 0; staffIndex < staff.length && staffIndex < 8; staffIndex++) {
          final currentStaff = staff[staffIndex];
          
          // 跳過請假員工
          if (currentStaff.status != StaffStatus.active) continue;
          
          // 根據員工角色和日期生成不同的排班
          StaffSchedule? schedule;
          
          switch (currentStaff.role) {
            case StaffRole.owner:
              // 店主：每天全日班
              schedule = StaffSchedule(
                id: '${weekOffset}_${dayOffset}_$staffIndex',
                staffId: currentStaff.id,
                branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1',
                date: date,
                shiftType: ShiftType.full_day,
                startTime: '09:00',
                endTime: '19:00',
                status: ScheduleStatus.confirmed,
                createdAt: now,
                updatedAt: now,
                staffName: currentStaff.name,
                branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1')).name,
              );
              break;
              
            case StaffRole.manager:
              // 經理：平日全日班，週末早班
              if (date.weekday <= 5) {
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1',
                  date: date,
                  shiftType: ShiftType.full_day,
                  startTime: '10:00',
                  endTime: '18:00',
                  status: ScheduleStatus.confirmed,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1')).name,
                );
              } else if (date.weekday == 6) {
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1',
                  date: date,
                  shiftType: ShiftType.morning,
                  startTime: '09:00',
                  endTime: '13:00',
                  status: ScheduleStatus.scheduled,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1')).name,
                );
              }
              // 週日休假
              break;
              
            case StaffRole.senior_stylist:
              // 資深設計師：輪班制
              final shiftIndex = (dayOffset + staffIndex) % 3;
              ShiftType shiftType;
              String startTime, endTime;
              
              switch (shiftIndex) {
                case 0:
                  shiftType = ShiftType.morning;
                  startTime = '09:00';
                  endTime = '13:00';
                  break;
                case 1:
                  shiftType = ShiftType.afternoon;
                  startTime = '13:00';
                  endTime = '18:00';
                  break;
                case 2:
                  shiftType = ShiftType.evening;
                  startTime = '18:00';
                  endTime = '22:00';
                  break;
                default:
                  shiftType = ShiftType.off;
                  startTime = '';
                  endTime = '';
              }
              
              if (date.weekday == 7 && shiftIndex == 2) {
                // 週日晚班改為休假
                shiftType = ShiftType.off;
                startTime = '';
                endTime = '';
              }
              
              schedule = StaffSchedule(
                id: '${weekOffset}_${dayOffset}_$staffIndex',
                staffId: currentStaff.id,
                branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1',
                date: date,
                shiftType: shiftType,
                startTime: startTime.isNotEmpty ? startTime : null,
                endTime: endTime.isNotEmpty ? endTime : null,
                status: shiftType == ShiftType.off ? ScheduleStatus.scheduled : ScheduleStatus.confirmed,
                createdAt: now,
                updatedAt: now,
                staffName: currentStaff.name,
                branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1')).name,
              );
              break;
              
            case StaffRole.stylist:
              // 設計師：平日午班或晚班，週末早班
              if (date.weekday <= 5) {
                final isAfternoon = (dayOffset + staffIndex) % 2 == 0;
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1',
                  date: date,
                  shiftType: isAfternoon ? ShiftType.afternoon : ShiftType.evening,
                  startTime: isAfternoon ? '13:00' : '18:00',
                  endTime: isAfternoon ? '18:00' : '22:00',
                  status: ScheduleStatus.scheduled,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1')).name,
                );
              } else if (date.weekday == 6) {
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1',
                  date: date,
                  shiftType: ShiftType.morning,
                  startTime: '09:00',
                  endTime: '13:00',
                  status: ScheduleStatus.scheduled,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1')).name,
                );
              }
              break;
              
            case StaffRole.assistant:
              // 助理：早班或午班
              if (date.weekday <= 6) {
                final isMorning = (dayOffset + staffIndex) % 2 == 0;
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1',
                  date: date,
                  shiftType: isMorning ? ShiftType.morning : ShiftType.afternoon,
                  startTime: isMorning ? '09:00' : '13:00',
                  endTime: isMorning ? '13:00' : '18:00',
                  status: ScheduleStatus.scheduled,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[0] : '1')).name,
                );
              }
              break;
              
            case StaffRole.receptionist:
              // 接待員：全日班
              if (date.weekday <= 6) {
                schedule = StaffSchedule(
                  id: '${weekOffset}_${dayOffset}_$staffIndex',
                  staffId: currentStaff.id,
                  branchId: currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1',
                  date: date,
                  shiftType: ShiftType.full_day,
                  startTime: '10:00',
                  endTime: '19:00',
                  status: ScheduleStatus.confirmed,
                  createdAt: now,
                  updatedAt: now,
                  staffName: currentStaff.name,
                  branchName: branches.firstWhere((b) => b.id == (currentStaff.branchIds.isNotEmpty ? currentStaff.branchIds[dayOffset % currentStaff.branchIds.length] : '1')).name,
                );
              }
              break;
          }
          
          if (schedule != null) {
            schedules.add(schedule);
          }
        }
      }
    }
    
    // 添加一些請假記錄
    schedules.add(StaffSchedule(
      id: 'leave_1',
      staffId: staff.length > 3 ? staff[3].id : '4',
      branchId: '1',
      date: now.add(const Duration(days: 3)),
      shiftType: ShiftType.off,
      status: ScheduleStatus.requested_off,
      notes: '個人事務',
      createdAt: now,
      updatedAt: now,
      staffName: staff.length > 3 ? staff[3].name : '陳設計',
      branchName: '總店',
    ));
    
    schedules.add(StaffSchedule(
      id: 'leave_2',
      staffId: staff.length > 4 ? staff[4].id : '5',
      branchId: '3',
      date: now.add(const Duration(days: 5)),
      shiftType: ShiftType.off,
      status: ScheduleStatus.sick_leave,
      notes: '感冒就醫',
      createdAt: now,
      updatedAt: now,
      staffName: staff.length > 4 ? staff[4].name : '林造型',
      branchName: '西門門店',
    ));
    
    return schedules;
  }
} 