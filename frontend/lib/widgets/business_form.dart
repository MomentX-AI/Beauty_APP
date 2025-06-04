import 'package:flutter/material.dart';
import '../models/business.dart';

class BusinessForm extends StatefulWidget {
  final Business? business;
  final Function(Business) onSubmit;

  const BusinessForm({
    Key? key,
    this.business,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business?.name ?? '');
    _descriptionController = TextEditingController(text: widget.business?.description ?? '');
    _addressController = TextEditingController(text: widget.business?.address ?? '');
    _phoneController = TextEditingController(text: widget.business?.phone ?? '');
    _emailController = TextEditingController(text: widget.business?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final business = Business(
        id: widget.business?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        logoUrl: widget.business?.logoUrl,
        createdAt: widget.business?.createdAt,
        updatedAt: widget.business?.updatedAt,
      );
      widget.onSubmit(business);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a business name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.business == null ? 'Create Business' : 'Update Business'),
          ),
        ],
      ),
    );
  }
} 