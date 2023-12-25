import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExistingExpense extends StatefulWidget {
  @override
  _ExistingExpenseState createState() => _ExistingExpenseState();
}

class _ExistingExpenseState extends State<ExistingExpense> {
  List<Map<String, dynamic>> expensesData = [];
  Map<String, String> projectNames = {}; // Stores project IDs and their names
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    if (userId != null) {
      _fetchExpenses();
    }
  }

  Future<void> _fetchExpenses() async {
    final response = await http.get(
      Uri.parse('https://www.buraqgrp.com/admin/api.php?table=expenses'),
    );

    final projectResponse = await http.get(
      Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'),
    );

    if (response.statusCode == 200 && projectResponse.statusCode == 200) {
      List<dynamic> expenses = json.decode(response.body);
      List<dynamic> projects = json.decode(projectResponse.body);

      for (var project in projects) {
        projectNames[project['id'].toString()] = project['name'].toString();
      }

      setState(() {
        expensesData = expenses
            .where((expense) =>
                expense['debtor'].toString() == userId ||
                expense['creditor'].toString() == userId)
            .map((expense) {
          String projectId = expense['project'].toString();
          return {
            'amount': expense['amount'],
            'project':
                projectNames[projectId] ?? 'غير معروف', // Use project name
            'date': expense['date'],
          };
        }).toList();
      });
    } else {
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المصروفات الحالية'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('المبلغ')),
            DataColumn(label: Text('اسم المشروع')),
            DataColumn(label: Text('التاريخ')),
          ],
          rows: expensesData
              .map(
                (expense) => DataRow(cells: [
                  DataCell(Text(expense['amount'].toString())),
                  DataCell(Text(expense['project'].toString())),
                  DataCell(Text(expense['date'].toString())),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
