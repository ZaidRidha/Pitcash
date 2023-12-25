import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this line if you don't have it
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseAddition extends StatefulWidget {
  @override
  _ExpenseAdditionState createState() => _ExpenseAdditionState();
}

class _ExpenseAdditionState extends State<ExpenseAddition> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCreditorId; // Changed from selectedDebtorId
  String? selectedProjectId;
  String? debtorId; // Store debtorId from SharedPreferences
  String? amount;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  List<dynamic> creditors = []; // Changed to creditors
  List<dynamic> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchDebtorId(); // Fetch debtor ID from SharedPreferences
    _fetchCreditorsAndProjects(); // Fetch creditors and projects
  }

  Future<void> _fetchCreditorsAndProjects() async {
    try {
      final usersResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));
      final projectsResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));

      if (usersResponse.statusCode == 200 &&
          projectsResponse.statusCode == 200) {
        setState(() {
          var allUsers = json.decode(usersResponse.body);
          creditors = allUsers
              .where((user) => user['modes'].toString() == "1")
              .toList();
          projects = json.decode(projectsResponse.body); // Set projects list

          // Additional Logging
          print("Fetched Users: ${allUsers.length}");
          print("Filtered Creditors: ${creditors.length}");
          for (var creditor in creditors) {
            print("Creditor: ID=${creditor['id']}, Name=${creditor['name']}");
          }
        });
      } else {
        print("Failed to fetch data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchDebtorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      debtorId = prefs.getString('id'); // Get debtorId from SharedPreferences
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (debtorId == null ||
          selectedCreditorId == null ||
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
        'debtor': selectedCreditorId!,
        'creditor': debtorId!, // Add this line
        'project': selectedProjectId!,
        'date': dateController.text,
      };

      try {
        // Make the POST request
        var response = await http.post(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=expenses'),
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
        title: Text('Add Expense Entry'),
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
                  value: selectedCreditorId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCreditorId = newValue;
                    });
                  },
                  items: creditors.map<DropdownMenuItem<String>>((user) {
                    print("Creating item for: ${user['name']}"); // Debug print
                    return DropdownMenuItem<String>(
                      value: user['id'].toString(),
                      child: Text(user['name'].toString()),
                    );
                  }).toList(),
                  hint: Text('Select Creditor'),
                  // Ensure the dropdown is styled and sized appropriately
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DropdownButtonFormField(
                  value: selectedProjectId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProjectId = newValue; // Correct this line
                    });
                  },
                  items: projects.map<DropdownMenuItem<String>>((project) {
                    return DropdownMenuItem<String>(
                      value: project['id'].toString(),
                      child: Text(project['name'].toString()),
                    );
                  }).toList(),
                  hint: Text('Select Project'),
                  // ... rest of your DropdownButtonFormField code
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
