import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PredecessorAddition extends StatefulWidget {
  @override
  _PredecessorAdditionState createState() => _PredecessorAdditionState();
}

class _PredecessorAdditionState extends State<PredecessorAddition> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDebtorId;
  String? selectedProjectId;
  String? creditorId;
  String? amount;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  List<dynamic> users = [];
  List<dynamic> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchCreditorId();
    _fetchUsersAndProjects();
  }

  Future<void> _fetchUsersAndProjects() async {
    final usersResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));
    final projectsResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));

    if (usersResponse.statusCode == 200 && projectsResponse.statusCode == 200) {
      setState(() {
        users = json.decode(usersResponse.body);
        projects = json.decode(projectsResponse.body);
      });
    } else {
      print("Failed to fetch data");
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

      var payload = {
        'amount': amount!,
        'debtor': selectedDebtorId!,
        'creditor': creditorId!,
        'project': selectedProjectId!,
        'date': dateController.text,
      };

      try {
        var response = await http.post(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitcash'),
          body: payload,
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['success'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تمت إضافة السلفة بنجاح!')),
            );
          } else {
            String errorMessage = data['error'] ?? 'خطأ غير معروف';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في إضافة السلفة: $errorMessage')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('خطأ في إرسال النموذج: ${response.reasonPhrase}')),
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
        title: Text('إضافة سلفة'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField(
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
                hint: Text('اختر المدين'),
                decoration: InputDecoration(
                  labelText: 'المدين',
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
    );
  }
}
