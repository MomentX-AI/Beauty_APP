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
import 'mock_data_service.dart';

class MockApiService {
  // Business API
  Future<List<Business>> getBusinesses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockBusinesses();
  }
  
  Future<Business> createBusiness(Business business) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return business;
  }
  
  Future<Business> getBusiness(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final businesses = MockDataService.getMockBusinesses();
    return businesses.firstWhere((b) => b.id == id);
  }
  
  Future<Business> updateBusiness(String id, Business business) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return business;
  }
  
  Future<void> deleteBusiness(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  Future<Business> restoreBusiness(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final businesses = MockDataService.getMockBusinesses();
    return businesses.firstWhere((b) => b.id == id);
  }
  
  // Branch API
  Future<List<Branch>> getBranches(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockBranches(businessId);
  }
  
  Future<Branch> createBranch(Branch branch) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return branch;
  }
  
  Future<Branch> getBranch(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final branches = MockDataService.getMockBranches(null);
    return branches.firstWhere((b) => b.id == id);
  }
  
  Future<Branch> updateBranch(String id, Branch branch) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return branch;
  }
  
  Future<void> deleteBranch(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Branch Special Days API
  Future<List<BranchSpecialDay>> getBranchSpecialDays(String branchId, {DateTime? date}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockBranchSpecialDays(branchId, date: date);
  }
  
  Future<BranchSpecialDay> createBranchSpecialDay(BranchSpecialDay specialDay) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return specialDay;
  }
  
  Future<BranchSpecialDay> updateBranchSpecialDay(String id, BranchSpecialDay specialDay) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return specialDay;
  }
  
  Future<void> deleteBranchSpecialDay(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Service API
  Future<List<Service>> getServices({bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final services = MockDataService.getMockServices();
    if (includeArchived) {
      return services;
    }
    return services.where((s) => !s.isArchived).toList();
  }
  
  Future<Service> createService(Service service) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return service;
  }
  
  Future<Service> getService(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final services = MockDataService.getMockServices();
    return services.firstWhere((s) => s.id == id);
  }
  
  Future<List<Service>> getBusinessServices(String businessId, {bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final services = MockDataService.getMockServices();
    var filteredServices = services.where((s) => s.businessId == businessId);
    
    if (!includeArchived) {
      filteredServices = filteredServices.where((s) => !s.isArchived);
    }
    
    return filteredServices.toList();
  }
  
  Future<Service> updateService(String id, Service service) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return service;
  }
  
    Future<void> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Branch Service API
  Future<List<BranchService>> getBranchServices(String branchId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockBranchServices(branchId);
  }

  Future<List<Service>> getBranchAvailableServices(String branchId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final branchServices = await getBranchServices(branchId);
    final allServices = MockDataService.getMockServices();
    
    final availableServiceIds = branchServices
        .where((bs) => bs.isAvailable)
        .map((bs) => bs.serviceId)
        .toSet();
    
    return allServices.where((s) => availableServiceIds.contains(s.id)).toList();
  }

  Future<BranchService> createBranchService(BranchService branchService) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return branchService;
  }

  Future<BranchService> updateBranchService(String id, BranchService branchService) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return branchService;
  }

  Future<void> deleteBranchService(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Appointment API
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockAppointments();
  }
  
  Future<Appointment> createAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return appointment;
  }
  
  Future<Appointment> getAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    return appointments.firstWhere((a) => a.id == id);
  }
  
  Future<List<Appointment>> getBusinessAppointments(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    return appointments.where((a) => a.businessId == businessId).toList();
  }
  
  Future<List<Appointment>> getCustomerAppointments(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    return appointments.where((a) => a.customerId == customerId).toList();
  }
  
  Future<List<Appointment>> getAppointmentsByDateRange(String businessId, DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    return appointments.where((a) => 
      a.businessId == businessId &&
      a.startTime.isAfter(startDate) && 
      a.startTime.isBefore(endDate)
    ).toList();
  }
  
  Future<Appointment> updateAppointment(String id, Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Validate status transition before returning
    return validateStatusTransition(id, appointment);
  }
  
  Future<Appointment> updateAppointmentStatus(String id, AppointmentStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    final appointment = appointments.firstWhere((a) => a.id == id);
    
    // Create a copy of the appointment with the new status
    final updatedAppointment = appointment.copyWith(status: newStatus);
    
    // Validate status transition before returning
    return validateStatusTransition(id, updatedAppointment);
  }
  
  Future<Appointment> validateStatusTransition(String id, Appointment updatedAppointment) async {
    final appointments = await MockDataService.getMockAppointments();
    final currentAppointment = appointments.firstWhere((a) => a.id == id);
    
    bool isValidTransition = true;
    String errorMessage = '';
    
    // Check if current status is terminal
    if (currentAppointment.status == AppointmentStatus.completed || 
        currentAppointment.status == AppointmentStatus.cancelled ||
        currentAppointment.status == AppointmentStatus.no_show) {
      isValidTransition = false;
      errorMessage = 'Cannot change status from a terminal state';
    } 
    // From Booked can go to any state - always valid
    else if (currentAppointment.status == AppointmentStatus.booked) {
      isValidTransition = true;
    }
    // From Confirmed can go to any state except Booked
    else if (currentAppointment.status == AppointmentStatus.confirmed && 
             updatedAppointment.status == AppointmentStatus.booked) {
      isValidTransition = false;
      errorMessage = 'Cannot change from confirmed to booked';
    }
    // From Checked-in can go to Completed, Cancelled, or NoShow but not Booked or Confirmed
    else if (currentAppointment.status == AppointmentStatus.checked_in && 
             (updatedAppointment.status == AppointmentStatus.booked || 
              updatedAppointment.status == AppointmentStatus.confirmed)) {
      isValidTransition = false;
      errorMessage = 'Cannot change from checked-in to booked or confirmed';
    }
    
    if (!isValidTransition) {
      throw Exception('INVALID_STATUS_TRANSITION: $errorMessage');
    }
    
    return updatedAppointment;
  }
  
  Future<void> deleteAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final appointments = await MockDataService.getMockAppointments();
    final appointment = appointments.firstWhere((a) => a.id == id);
    
    // Can only hard delete canceled or no-show appointments with future start time
    if ((appointment.status != AppointmentStatus.cancelled && 
         appointment.status != AppointmentStatus.no_show) || 
        !appointment.startTime.isAfter(DateTime.now())) {
      throw Exception('Cannot delete this appointment');
    }
  }
  
  // Customer API
  Future<List<Customer>> getCustomers({bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final customers = await MockDataService.getMockCustomers();
    
    if (includeArchived) {
      return customers;
    }
    
    return customers.where((c) => !c.isArchived).toList();
  }
  
  Future<Customer> createCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return customer;
  }
  
  Future<Customer> getCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final customers = await MockDataService.getMockCustomers();
    return customers.firstWhere((c) => c.id == id);
  }
  
  Future<List<Customer>> getBusinessCustomers(String businessId, {bool includeArchived = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final customers = await MockDataService.getMockCustomers();
    var filteredCustomers = customers.where((c) => c.businessId == businessId);
    
    if (!includeArchived) {
      filteredCustomers = filteredCustomers.where((c) => !c.isArchived);
    }
    
    return filteredCustomers.toList();
  }
  
  Future<Customer> updateCustomer(String id, Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return customer;
  }
  
  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Service History API
  Future<List<ServiceHistory>> getServiceHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockServiceHistory();
  }
  
  Future<ServiceHistory> createServiceHistory(ServiceHistory history) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return history;
  }
  
  Future<ServiceHistory> getServiceHistoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final history = MockDataService.getMockServiceHistory();
    return history.firstWhere((h) => h.id == id);
  }
  
  Future<List<ServiceHistory>> getCustomerServiceHistory(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final history = MockDataService.getMockServiceHistory();
    return history.where((h) => h.customerId == customerId).toList();
  }
  
  Future<List<ServiceHistory>> getBusinessServiceHistory(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final history = MockDataService.getMockServiceHistory();
    return history.where((h) => h.businessId == businessId).toList();
  }
  
  Future<List<ServiceHistory>> getServiceHistoryByDateRange(String businessId, DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final history = MockDataService.getMockServiceHistory();
    return history.where((h) => 
      h.businessId == businessId &&
      h.serviceDate.isAfter(startDate) && 
      h.serviceDate.isBefore(endDate)
    ).toList();
  }
  
  // Business Goal API
  Future<List<BusinessGoal>> getBusinessGoals(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      BusinessGoal(
        id: '1',
        businessId: businessId,
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
        businessId: businessId,
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
        businessId: businessId,
        title: '本月新增客戶目標',
        currentValue: 28,
        targetValue: 40,
        unit: '人',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 31),
        type: GoalType.customer_count,
      ),
    ];
  }
  
  Future<BusinessGoal> createBusinessGoal(BusinessGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Recalculate percentage before saving
    final recalculatedGoal = goal.recalculatePercentage();
    return recalculatedGoal;
  }
  
  Future<BusinessGoal> getBusinessGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final goals = await MockDataService.getMockBusinessGoals(null);
    return goals.firstWhere((g) => g.id == id);
  }
  
  Future<BusinessGoal> updateBusinessGoal(String id, BusinessGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Recalculate percentage before saving
    final recalculatedGoal = goal.recalculatePercentage();
    return recalculatedGoal;
  }
  
  Future<void> deleteBusinessGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Business Analysis API
  Future<List<BusinessAnalysis>> getBusinessAnalyses(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockBusinessAnalyses(businessId);
  }
  
  Future<BusinessAnalysis> createBusinessAnalysis(BusinessAnalysis analysis) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return analysis;
  }
  
  Future<BusinessAnalysis> getBusinessAnalysis(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final analyses = await MockDataService.getMockBusinessAnalyses(null);
    return analyses.firstWhere((a) => a.id == id);
  }
  
  Future<BusinessAnalysis> updateBusinessAnalysis(String id, BusinessAnalysis analysis) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return analysis;
  }
  
  Future<BusinessAnalysis> updateBusinessAnalysisStatus(String id, AnalysisStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final analyses = await MockDataService.getMockBusinessAnalyses(null);
    final analysis = analyses.firstWhere((a) => a.id == id);
    return analysis.copyWith(status: status);
  }
  
  Future<List<BusinessAnalysis>> getBusinessAnalysesByType(String businessId, AnalysisType type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final analyses = await MockDataService.getMockBusinessAnalyses(businessId);
    return analyses.where((a) => a.analysisType == type).toList();
  }
  
  Future<List<BusinessAnalysis>> getBusinessAnalysesByPeriod(String businessId, AnalysisPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final analyses = await MockDataService.getMockBusinessAnalyses(businessId);
    return analyses.where((a) => a.period == period).toList();
  }
  
  Future<void> deleteBusinessAnalysis(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Staff API
  Future<List<Staff>> getStaff(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getMockStaff(businessId);
  }

  Future<Staff> createStaff(Staff staff) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return staff;
  }

  Future<Staff> getStaffById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final staff = await MockDataService.getMockStaff('1');
    return staff.firstWhere((s) => s.id == id);
  }

  Future<Staff> updateStaff(String id, Staff staff) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return staff;
  }

  Future<void> deleteStaff(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Staff>> getStaffByBranch(String branchId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allStaff = await MockDataService.getMockStaff('1');
    return allStaff.where((s) => s.branchIds.contains(branchId)).toList();
  }

  Future<List<Staff>> getStaffByService(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allStaff = await MockDataService.getMockStaff('1');
    return allStaff.where((s) => s.serviceIds.contains(serviceId)).toList();
  }
} 