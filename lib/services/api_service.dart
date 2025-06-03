import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../models/service.dart';
import '../models/appointment.dart';
import '../models/customer.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:2345/api';
  
  // Helper method for handling HTTP errors
  void _handleError(http.Response response) {
    print('API Error: ${response.statusCode} - ${response.body}');
    if (response.statusCode >= 400) {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'An error occurred: ${response.statusCode}');
      } catch (e) {
        throw Exception('An error occurred: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // Business API
  Future<List<Business>> getBusinesses() async {
    try {
      print('Fetching businesses from $baseUrl/business');
      final response = await http.get(
        Uri.parse('$baseUrl/business'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      _handleError(response);
      
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Business.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching businesses: $e');
      throw Exception('Failed to get businesses: $e');
    }
  }
  
  Future<Business> createBusiness(Business business) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(business.toJson()),
      );
      _handleError(response);
      
      return Business.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to create business: $e');
    }
  }
  
  Future<Business> getBusiness(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      _handleError(response);
      
      return Business.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }
  
  Future<Business> updateBusiness(String id, Business business) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/business/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(business.toJson()),
      );
      _handleError(response);
      
      return Business.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }
  
  Future<void> deleteBusiness(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/business/$id'));
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete business: ${response.body}');
    }
  }
  
  // Service API
  Future<Service> createService(Service service) async {
    final response = await http.post(
      Uri.parse('$baseUrl/service/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Service.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create service: ${response.body}');
    }
  }
  
  Future<Service> getService(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/service/$id'));
    
    if (response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get service: ${response.body}');
    }
  }
  
  Future<List<Service>> getBusinessServices(String businessId) async {
    final response = await http.get(Uri.parse('$baseUrl/business/$businessId/services'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get business services: ${response.body}');
    }
  }
  
  // Appointment API
  Future<Appointment> createAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointment/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create appointment: ${response.body}');
    }
  }
  
  Future<Appointment> getAppointment(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/appointment/$id'));
    
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get appointment: ${response.body}');
    }
  }
  
  Future<List<Appointment>> getBusinessAppointments(String businessId) async {
    final response = await http.get(Uri.parse('$baseUrl/business/$businessId/appointments'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get business appointments: ${response.body}');
    }
  }
  
  // Customer API
  Future<Customer> createCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create customer: ${response.body}');
    }
  }
  
  Future<Customer> getCustomer(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/customer/$id'));
    
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get customer: ${response.body}');
    }
  }
  
  Future<List<Customer>> getBusinessCustomers(String businessId) async {
    final response = await http.get(Uri.parse('$baseUrl/business/$businessId/customers'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get business customers: ${response.body}');
    }
  }
} 