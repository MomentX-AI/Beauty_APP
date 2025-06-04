import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/mock_api_service.dart';
import '../widgets/business_form.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({Key? key}) : super(key: key);

  @override
  _BusinessListScreenState createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final MockApiService _apiService = MockApiService();
  List<Business> _businesses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final businesses = await _apiService.getBusinesses();
      setState(() {
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createBusiness(Business business) async {
    try {
      await _apiService.createBusiness(business);
      _loadBusinesses();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating business: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateBusiness(Business business) async {
    try {
      await _apiService.updateBusiness(business.id!, business);
      _loadBusinesses();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating business: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteBusiness(Business business) async {
    try {
      await _apiService.deleteBusiness(business.id!);
      _loadBusinesses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting business: ${e.toString()}')),
      );
    }
  }

  void _showBusinessForm([Business? business]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(business == null ? 'Create Business' : 'Edit Business'),
        content: SingleChildScrollView(
          child: BusinessForm(
            business: business,
            onSubmit: business == null ? _createBusiness : _updateBusiness,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Businesses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBusinesses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _businesses.isEmpty
                  ? const Center(child: Text('No businesses found'))
                  : ListView.builder(
                      itemCount: _businesses.length,
                      itemBuilder: (context, index) {
                        final business = _businesses[index];
                        return ListTile(
                          title: Text(business.name),
                          subtitle: Text(business.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showBusinessForm(business),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Business'),
                                    content: Text(
                                      'Are you sure you want to delete ${business.name}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteBusiness(business);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBusinessForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 