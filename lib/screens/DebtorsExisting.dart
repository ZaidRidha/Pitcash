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
      print('Creditor ID: $creditorId');
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

    // Create a map to store the sum of amounts for each debtor
    Map<String, double> debtorSums = {};

    for (var cashEntry in cashData) {
      String debtorId = cashEntry['debtor'].toString();
      double amount = double.tryParse(cashEntry['amount'].toString()) ?? 0.0;
      debtorSums.update(debtorId, (currentSum) => currentSum + amount,
          ifAbsent: () => amount);
    }

    var expenseData = await fetchExpenseData(); // Placeholder for actual call
    Map<String, double> expensesSums = {};

    for (var expenseEntry in expenseData) {
      String userId = expenseEntry['debtor'].toString();
      double expenseAmount =
          double.tryParse(expenseEntry['amount'].toString()) ?? 0.0;
      expensesSums.update(userId, (currentSum) => currentSum + expenseAmount,
          ifAbsent: () => expenseAmount);
    }

    setState(() {
      displayData = usersData.map((user) {
        String userId = user['id'].toString();
        double predecessorSum = debtorSums[userId] ?? 0.0;
        double expenseSum = expensesSums[userId] ?? 0.0;
        double balance = predecessorSum - expenseSum;

        return {
          'name': user['name'],
          'predecessor': predecessorSum.toString(),
          'expense': expenseSum.toString(),
          'balance': balance.toString(),
        };
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchExpenseData() async {
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
        title: Text('المدينون الحاليون'),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Expanded(
                    child: Text('الاسم',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('المبلغ المستحق',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('المصروفات',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
                Expanded(
                    child: Text('الرصيد',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ReorderableListView.builder(
                onReorder: _onReorder,
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  var user = displayData[index];
                  String predecessor = user['predecessor'];
                  String expense = user['expense'];
                  String balance = user['balance'];

                  return Card(
                    key: ValueKey(user['name']),
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
