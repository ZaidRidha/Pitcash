import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExistingProject extends StatefulWidget {
  @override
  _ExistingProjectState createState() => _ExistingProjectState();
}

class _ExistingProjectState extends State<ExistingProject> {
  List<Map<String, dynamic>> projectsData = [];
  List<Map<String, dynamic>> filteredProjectsData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi();
  }

  Future<void> _fetchDataFromApi() async {
    try {
      // Get the stored 'id' from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String myId = prefs.getString('id') ?? '';

      if (myId.isEmpty) {
        // Handle case where there is no ID in SharedPreferences
        print('No ID found in SharedPreferences.');
        // Potentially set an error state or inform the user
        return;
      }

      // Fetch all the necessary data (projects, pitcash, and expenses)
      final projectsResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));
      final pitcashResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitcash'));
      final expensesResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=expenses'));

      // Check for successful responses
      if (projectsResponse.statusCode == 200 &&
          pitcashResponse.statusCode == 200 &&
          expensesResponse.statusCode == 200) {
        var projectsResponseBody = json.decode(projectsResponse.body) as List;
        var pitcashResponseBody = json.decode(pitcashResponse.body) as List;
        var expensesResponseBody = json.decode(expensesResponse.body) as List;

        // Filter pitcash and expenses for entries where the 'debtor' or 'creditor' matches 'myId'
        final relevantPitcash = pitcashResponseBody
            .where((pitcash) =>
                pitcash['debtor'].toString() == myId ||
                pitcash['creditor'].toString() == myId)
            .toList();

        final relevantExpenses = expensesResponseBody
            .where((expense) =>
                expense['debtor'].toString() == myId ||
                expense['creditor'].toString() == myId)
            .toList();

        // Get a list of project IDs from the relevant pitcash and expenses entries
        final relevantProjectIds = {
          ...relevantPitcash.map((pitcash) => pitcash['project'].toString()),
          ...relevantExpenses.map((expense) => expense['project'].toString())
        };

        // Calculate sums of pitcash and expenses for each project
        Map<String, double> projectPitcashSums = {};
        Map<String, double> projectExpensesSums = {};

        // Sum amounts from Pitcash by project ID
        for (var pitcashEntry in relevantPitcash) {
          String projectId = pitcashEntry['project'].toString();
          double amount =
              double.tryParse(pitcashEntry['amount'].toString()) ?? 0.0;
          projectPitcashSums[projectId] =
              (projectPitcashSums[projectId] ?? 0) + amount;
        }

        // Sum amounts from Expenses by project ID
        for (var expenseEntry in relevantExpenses) {
          String projectId = expenseEntry['project'].toString();
          double amount =
              double.tryParse(expenseEntry['amount'].toString()) ?? 0.0;
          projectExpensesSums[projectId] =
              (projectExpensesSums[projectId] ?? 0) + amount;
        }

        // Map projects data and include only those with an 'id' in 'relevantProjectIds'
        setState(() {
          projectsData = projectsResponseBody
              .where((project) =>
                  relevantProjectIds.contains(project['id'].toString()))
              .map<Map<String, dynamic>>((item) {
            Map<String, dynamic> projectMap = Map<String, dynamic>.from(item);

            String projectId = projectMap['id'].toString();
            double predecessor = projectPitcashSums[projectId] ?? 0.0;
            double expense = projectExpensesSums[projectId] ?? 0.0;
            double balance = predecessor - expense; // Calculate the balance

            return {
              'ref_no': projectMap['ref_no'].toString(),
              'name': projectMap['name'].toString(),
              'Balance': balance.toString(), // Set the calculated balance
              'Expense': expense.toString(),
              'Predecessor': predecessor.toString(),
            };
          }).toList();
          filteredProjectsData = List<Map<String, dynamic>>.from(projectsData);
        });
      } else {
        // Handle unsuccessful responses
        print(
            "Error fetching data: Projects status code: ${projectsResponse.statusCode}, Pitcash status code: ${pitcashResponse.statusCode}, Expenses status code: ${expensesResponse.statusCode}");
      }
    } catch (e) {
      // Handle any exceptions during the fetch operation
      print("Exception fetching data from the API: $e");
    }
  }

  void _filterProjects(String query) {
    setState(() {
      filteredProjectsData = projectsData
          .where((project) =>
              project['name'].toLowerCase().contains(query.toLowerCase()) ||
              project['ref_no'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Existing Projects'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterProjects(value);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Ref No'),
                  ),
                  DataColumn(
                    label: Text('Name'),
                  ),
                  DataColumn(
                    label: Text('Balance'),
                  ),
                  DataColumn(
                    label: Text('Expense'),
                  ),
                  DataColumn(
                    label: Text('Predecessor'),
                  ),
                ],
                rows: filteredProjectsData
                    .map(
                      (project) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(project['ref_no'] ?? '')),
                          DataCell(Text(project['name'] ?? '')),
                          DataCell(Text(project['Balance'] ?? '')),
                          DataCell(Text(project['Expense'] ?? '')),
                          DataCell(Text(project['Predecessor'] ?? '')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
