import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectAddition extends StatefulWidget {
  @override
  _ProjectAdditionState createState() => _ProjectAdditionState();
}

class _ProjectAdditionState extends State<ProjectAddition> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final String apiUrl = "https://www.buraqgrp.com/admin/api.php?table=projects";

  Future<void> submitProject() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'name': projectNameController.text,
        'city': cityController.text,
        'country': countryController.text,
        'address': addressController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Project added successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to add the project: ${responseBody['error']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send data to the server.")),
      );
    }
  }

  @override
  void dispose() {
    projectNameController.dispose();
    cityController.dispose();
    countryController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Addition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
              ),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
              ),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                labelText: 'Country',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: submitProject,
            ),
          ],
        ),
      ),
    );
  }
}
