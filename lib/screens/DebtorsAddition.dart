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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة المدين بنجاح!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة المدين.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
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
        title: Text('إضافة المدينين'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
              ),
            ),
            TextField(
              controller: mobileNumberController,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                prefixText: '* ',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'الاسم',
                prefixText: '* ',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'العنوان',
              ),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                labelText: 'الدولة',
              ),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'المدينة',
              ),
            ),
            ElevatedButton(
              child: Text('إضافة المدين'),
              onPressed: submitDebtor,
            ),
          ],
        ),
      ),
    );
  }
}
