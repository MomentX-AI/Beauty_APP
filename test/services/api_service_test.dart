import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/business.dart';

void main() {
  late ApiService apiService;
  late Business testBusiness;

  setUp(() {
    apiService = ApiService();
    testBusiness = Business(
      name: 'Test Beauty Salon',
      description: 'A test beauty salon',
      address: '123 Test St',
      phone: '123-456-7890',
      email: 'test@beautysalon.com',
    );
  });

  group('Business API Tests', () {
    test('Create business', () async {
      final createdBusiness = await apiService.createBusiness(testBusiness);
      expect(createdBusiness.name, equals(testBusiness.name));
      expect(createdBusiness.description, equals(testBusiness.description));
      expect(createdBusiness.address, equals(testBusiness.address));
      expect(createdBusiness.phone, equals(testBusiness.phone));
      expect(createdBusiness.email, equals(testBusiness.email));
      expect(createdBusiness.id, isNotNull);
    });

    test('Get business', () async {
      // First create a business
      final createdBusiness = await apiService.createBusiness(testBusiness);
      
      // Then retrieve it
      final retrievedBusiness = await apiService.getBusiness(createdBusiness.id!);
      expect(retrievedBusiness.id, equals(createdBusiness.id));
      expect(retrievedBusiness.name, equals(createdBusiness.name));
    });

    test('Update business', () async {
      // First create a business
      final createdBusiness = await apiService.createBusiness(testBusiness);
      
      // Update the business
      final updatedBusiness = createdBusiness.copyWith(
        name: 'Updated Beauty Salon',
        description: 'An updated test beauty salon',
      );
      
      final result = await apiService.updateBusiness(
        createdBusiness.id!,
        updatedBusiness,
      );
      
      expect(result.name, equals(updatedBusiness.name));
      expect(result.description, equals(updatedBusiness.description));
    });

    test('Delete business', () async {
      // First create a business
      final createdBusiness = await apiService.createBusiness(testBusiness);
      
      // Then delete it
      await apiService.deleteBusiness(createdBusiness.id!);
      
      // Verify it's deleted by trying to get it (should throw an exception)
      expect(
        () => apiService.getBusiness(createdBusiness.id!),
        throwsException,
      );
    });
  });
} 