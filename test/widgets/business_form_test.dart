import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/business.dart';
import 'package:frontend/widgets/business_form.dart';

void main() {
  testWidgets('BusinessForm creates new business', (WidgetTester tester) async {
    Business? submittedBusiness;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessForm(
            onSubmit: (business) {
              submittedBusiness = business;
            },
          ),
        ),
      ),
    );

    // Enter business details
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Business Name'),
      'Test Beauty Salon',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'A test beauty salon',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      '123 Test St',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone'),
      '123-456-7890',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@beautysalon.com',
    );

    // Submit the form
    await tester.tap(find.text('Create Business'));
    await tester.pump();

    // Verify the submitted business
    expect(submittedBusiness, isNotNull);
    expect(submittedBusiness!.name, equals('Test Beauty Salon'));
    expect(submittedBusiness!.description, equals('A test beauty salon'));
    expect(submittedBusiness!.address, equals('123 Test St'));
    expect(submittedBusiness!.phone, equals('123-456-7890'));
    expect(submittedBusiness!.email, equals('test@beautysalon.com'));
  });

  testWidgets('BusinessForm edits existing business', (WidgetTester tester) async {
    final existingBusiness = Business(
      id: '1',
      name: 'Existing Beauty Salon',
      description: 'An existing beauty salon',
      address: '456 Existing St',
      phone: '098-765-4321',
      email: 'existing@beautysalon.com',
    );

    Business? submittedBusiness;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessForm(
            business: existingBusiness,
            onSubmit: (business) {
              submittedBusiness = business;
            },
          ),
        ),
      ),
    );

    // Verify existing business details are displayed
    expect(
      find.widgetWithText(TextFormField, 'Business Name'),
      findsOneWidget,
    );
    expect(
      find.text('Existing Beauty Salon'),
      findsOneWidget,
    );

    // Update business details
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Business Name'),
      'Updated Beauty Salon',
    );

    // Submit the form
    await tester.tap(find.text('Update Business'));
    await tester.pump();

    // Verify the submitted business
    expect(submittedBusiness, isNotNull);
    expect(submittedBusiness!.id, equals('1'));
    expect(submittedBusiness!.name, equals('Updated Beauty Salon'));
    expect(submittedBusiness!.description, equals('An existing beauty salon'));
  });

  testWidgets('BusinessForm validates required fields', (WidgetTester tester) async {
    Business? submittedBusiness;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessForm(
            onSubmit: (business) {
              submittedBusiness = business;
            },
          ),
        ),
      ),
    );

    // Submit empty form
    await tester.tap(find.text('Create Business'));
    await tester.pump();

    // Verify validation messages
    expect(find.text('Please enter a business name'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
    expect(find.text('Please enter an address'), findsOneWidget);
    expect(find.text('Please enter a phone number'), findsOneWidget);
    expect(find.text('Please enter an email'), findsOneWidget);

    // Verify no business was submitted
    expect(submittedBusiness, isNull);
  });
} 