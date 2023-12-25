import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebtorsAddition extends StatefulWidget {
  @override
  _DebtorsAdditionState createState() => _DebtorsAdditionState();
}

class _DebtorsAdditionState extends State<DebtorsAddition> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sequenceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  // TODO: Add controller for photograph if needed

  final String apiUrl = "https://www.buraqgrp.com/admin/api.php?table=pitusers";

  Future<void> submitDebtor() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': emailController.text,
          'mobile': mobileNumberController.text,
          'name': nameController.text,
          'country': countryController.text,
          'city': cityController.text,
          'address': addressController.text,
          // Add 'photograph' field if necessary
        },
      );
      if (response.statusCode == 200) {
        // Assuming a status code of 200 indicates success.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debtor added successfully!')),
        );
      } else {
        // If server responds with a different status code, assume failure.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add debtor.')),
        );
      }
    } catch (e) {
      // If the request threw an exception, show an error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    mobileNumberController.dispose();
    nameController.dispose();
    sequenceController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debtors Addition'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
              ),
            ),
            TextField(
              controller: mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '* ',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixText: '* ',
              ),
            ),

            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                labelText: 'Country',
              ),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
              ),
            ),
            // Add a widget here for photograph upload if needed
            // You will need to handle the logic for uploading and attaching the photograph
            ElevatedButton(
              child: Text('Add Debtor'),
              onPressed:
                  submitDebtor, // Implement this method to submit the data
            ),
          ],
        ),
      ),
    );
  }
}
