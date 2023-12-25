import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DebtorsExisting extends StatefulWidget {
  @override
  _DebtorsExistingState createState() => _DebtorsExistingState();
}

class _DebtorsExistingState extends State<DebtorsExisting> {
  List<Map<String, dynamic>> cashData = [];
  List<Map<String, dynamic>> usersData = [];
  List<Map<String, dynamic>> displayData = [];
  int creditorId = 0;

  @override
  void initState() {
    super.initState();
    _loadCreditorId();
  }

  _loadCreditorId() async {
    final prefs = await SharedPreferences.getInstance();
    String? idString = prefs.getString('id');
    int newCreditorId = int.tryParse(idString ?? '') ?? 0;

    if (creditorId != newCreditorId) {
      setState(() {
        creditorId = newCreditorId;
      });
      print(
          'Creditor ID: $creditorId'); // This will log the creditorId to the console
      _fetchCashData();
    }
  }

  _fetchCashData() async {
    print('Fetching cash data...');
    var cashResponse = await http
        .get(Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitcash'));
    var usersResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));

    if (cashResponse.statusCode == 200 && usersResponse.statusCode == 200) {
      cashData =
          List<Map<String, dynamic>>.from(json.decode(cashResponse.body));
      usersData =
          List<Map<String, dynamic>>.from(json.decode(usersResponse.body));

      _filterAndMatchData();
    } else {
      // Handle errors
    }
  }

  _filterAndMatchData() async {
    print('Filtering and matching data...');

    /* 
  // This section is commented out to disable filtering by creditor ID
  // Filter the cashData to only include entries with matching creditor ID
  List<Map<String, dynamic>> filteredCashData = cashData.where((cashEntry) {
    String cashCreditorId = cashEntry['creditor'].toString(); // Assuming 'creditor' is the correct field name
    return cashCreditorId == creditorId.toString(); // Convert both to string to ensure matching
  }).toList();

  // Log the filtered pitcash entries
  for (var cashEntry in filteredCashData) {
    print(cashEntry); // This will log each matching pitcash entry
  }
  */

    // Create a map to store the sum of amounts for each debtor
    Map<String, double> debtorSums = {};

    // Sum the amounts for each debtor in cashData
    for (var cashEntry in cashData) {
      String debtorId = cashEntry['debtor'].toString();
      double amount = double.tryParse(cashEntry['amount'].toString()) ?? 0.0;
      debtorSums.update(debtorId, (currentSum) => currentSum + amount,
          ifAbsent: () => amount);
    }

    // Fetch expense data and process it similarly
    // Placeholder for actual expense data fetching
    var expenseData = await fetchExpenseData(); // Replace with your actual call
    Map<String, double> expensesSums = {};

    // Sum the expenses for each user
    for (var expenseEntry in expenseData) {
      String userId = expenseEntry['debtor']
          .toString(); // Assuming 'debtor' is the correct field
      double expenseAmount =
          double.tryParse(expenseEntry['amount'].toString()) ?? 0.0;
      expensesSums.update(userId, (currentSum) => currentSum + expenseAmount,
          ifAbsent: () => expenseAmount);
    }

    /* 
  // This section is also commented out since it depends on the filteredCashData
  // Get the list of debtor IDs that are relevant for the filteredCashData
  var validDebtorIds = filteredCashData.map((e) => e['debtor'].toString()).toSet();
  */

    setState(() {
      // Filter usersData based on validDebtorIds, only showing users that are relevant
      displayData =
          usersData /*.where((user) {
      String userId = user['id'].toString();
      // This condition is commented out because validDebtorIds is not being calculated
      // return validDebtorIds.contains(userId);
      return true; // Temporarily return true for all users
    })*/
              .map((user) {
        String userId = user['id'].toString();
        double predecessorSum = debtorSums[userId] ?? 0.0;
        double expenseSum = expensesSums[userId] ?? 0.0;
        double balance = predecessorSum - expenseSum;

        // Now add this sum to your user display data as the 'predecessor' value
        return {
          'name': user['name'],
          'predecessor': predecessorSum.toString(),
          'expense': expenseSum.toString(),
          'balance': balance.toString(),
          // ...include other fields that you may want to display
        };
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchExpenseData() async {
    // Placeholder for actual HTTP request
    var expensesResponse = await http.get(
        Uri.parse('https://www.buraqgrp.com/admin/api.php?table=expenses'));
    if (expensesResponse.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          json.decode(expensesResponse.body));
    } else {
      print(
          'Failed to fetch expense data. Status code: ${expensesResponse.statusCode}');
      return [];
    }
  }

  // Function to reorder the list
  _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = usersData.removeAt(oldIndex);
      usersData.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debtors Existing'),
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Expanded(
                    child: Text('Name',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('Predecessor',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('Expense',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('Balance',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              // Added Padding here
              padding:
                  const EdgeInsets.only(top: 8.0), // Adjust the value as needed
              child: ReorderableListView.builder(
                onReorder: _onReorder,
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  var user = displayData[index];
                  String predecessor = user[
                      'predecessor']; // Now contains the actual predecessor value
                  String expense =
                      user['expense']; // Now contains the actual expense value
                  String balance =
                      user['balance']; // Now contains the actual balance value

                  return Card(
                    key: ValueKey(
                        user['name']), // Unique key for ReorderableListView
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: Text(user['name'],
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child: Text(predecessor,
                                  textAlign: TextAlign.center)),
                          Expanded(
                              child:
                                  Text(expense, textAlign: TextAlign.center)),
                          Expanded(
                              child:
                                  Text(balance, textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
