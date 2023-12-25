import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this line if you don't have it
import 'package:shared_preferences/shared_preferences.dart';

class PredecessorAddition extends StatefulWidget {
  @override
  _PredecessorAdditionState createState() => _PredecessorAdditionState();
}

class _PredecessorAdditionState extends State<PredecessorAddition> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDebtorId;
  String? selectedProjectId;
  String? creditorId; // Add this line
  String? amount;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  List<dynamic> users = [];
  List<dynamic> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchCreditorId(); // Add this line
    _fetchUsersAndProjects();
  }

  Future<void> _fetchUsersAndProjects() async {
    try {
      final usersResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));
      final projectsResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));

      if (usersResponse.statusCode == 200 &&
          projectsResponse.statusCode == 200) {
        setState(() {
          users = json.decode(usersResponse.body);
          projects = json.decode(projectsResponse.body);
        });
      } else {
        print("Failed to fetch data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchCreditorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      creditorId = prefs.getString('id');
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (creditorId == null ||
          selectedDebtorId == null ||
          selectedProjectId == null ||
          amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all the fields')),
        );
        return;
      }

      // Build the request payload
      var payload = {
        'amount': amount!,
        'debtor': selectedDebtorId!,
        'creditor': creditorId!, // Add this line
        'project': selectedProjectId!,
        'date': dateController.text,
      };

      try {
        // Make the POST request
        var response = await http.post(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitcash'),
          body: payload,
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['success'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Entry added successfully!')),
            );
          } else {
            String errorMessage = data['error'] ?? 'Unknown error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add entry: $errorMessage')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error submitting form: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the current date
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Predecessor Entry'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add more padding to the form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Makes the button stretch to fill the width
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DropdownButtonFormField(
                  value: selectedDebtorId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDebtorId = newValue;
                    });
                  },
                  items: users.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'].toString(),
                      child: Text(user['name'].toString()),
                    );
                  }).toList(),
                  hint: Text('Select Debtor'),
                  // ... [rest of your DropdownButtonFormField code]
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DropdownButtonFormField(
                  value: selectedProjectId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProjectId = newValue;
                    });
                  },
                  items: projects.map<DropdownMenuItem<String>>((project) {
                    return DropdownMenuItem<String>(
                      value: project['id'].toString(),
                      child: Text(project['name'].toString()),
                    );
                  }).toList(),
                  hint: Text('Select Project'),
                  // ... [rest of your DropdownButtonFormField code]
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(
                        new FocusNode()); // to prevent opening default keyboard
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    amount = value;
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
