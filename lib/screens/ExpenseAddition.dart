import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseAddition extends StatefulWidget {
  @override
  _ExpenseAdditionState createState() => _ExpenseAdditionState();
}

class _ExpenseAdditionState extends State<ExpenseAddition> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCreditorId;
  String? selectedProjectId;
  String? debtorId;
  String? amount;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  List<dynamic> creditors = [];
  List<dynamic> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchDebtorId();
    _fetchCreditorsAndProjects();
  }

  Future<void> _fetchCreditorsAndProjects() async {
    final usersResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));
    final projectsResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));

    if (usersResponse.statusCode == 200 && projectsResponse.statusCode == 200) {
      setState(() {
        var allUsers = json.decode(usersResponse.body);
        creditors =
            allUsers.where((user) => user['modes'].toString() == "1").toList();
        projects = json.decode(projectsResponse.body);
      });
    } else {
      print("Failed to fetch data");
    }
  }

  Future<void> _fetchDebtorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      debtorId = prefs.getString('id');
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var payload = {
        'amount': amount!,
        'debtor': selectedCreditorId!,
        'creditor': debtorId!,
        'project': selectedProjectId!,
        'date': dateController.text,
      };

      try {
        var response = await http.post(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=expenses'),
          body: payload,
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['success'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تمت إضافة المصروف بنجاح!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في إضافة المصروف.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في إرسال النموذج')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مصروف'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField(
                  value: selectedCreditorId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCreditorId = newValue;
                    });
                  },
                  items: creditors.map<DropdownMenuItem<String>>((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'].toString(),
                      child: Text(user['name'].toString()),
                    );
                  }).toList(),
                  hint: Text('اختر الدائن'),
                  decoration: InputDecoration(
                    labelText: 'الدائن',
                  ),
                ),
                DropdownButtonFormField(
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
                  hint: Text('اختر المشروع'),
                  decoration: InputDecoration(
                    labelText: 'المشروع',
                  ),
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'التاريخ',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'المبلغ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال مبلغ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    amount = value;
                  },
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('تقديم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
