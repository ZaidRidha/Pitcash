import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExistingPredecessor extends StatefulWidget {
  @override
  _ExistingPredecessorState createState() => _ExistingPredecessorState();
}

class _ExistingPredecessorState extends State<ExistingPredecessor> {
  List<Map<String, dynamic>> pitcashData = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi();
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String myId = prefs.getString('id') ?? '';

      if (myId.isEmpty) {
        print('No ID found in SharedPreferences.');
        return;
      }

      final pitcashResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitcash'));
      final projectsResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));
      final usersResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));

      if (pitcashResponse.statusCode == 200 &&
          projectsResponse.statusCode == 200 &&
          usersResponse.statusCode == 200) {
        var projectsResponseBody =
            json.decode(projectsResponse.body) as List<dynamic>;
        var pitcashResponseBody =
            json.decode(pitcashResponse.body) as List<dynamic>;
        var usersResponseBody =
            json.decode(usersResponse.body) as List<dynamic>;

        final relevantPitcash = pitcashResponseBody
            .where((pitcash) =>
                pitcash['debtor'].toString() == myId ||
                pitcash['creditor'].toString() == myId)
            .toList();

        Map<String, dynamic> projectNames = {
          for (var project in projectsResponseBody)
            project['id'].toString(): project['name']
        };

        Map<String, dynamic> userNames = {
          for (var user in usersResponseBody)
            user['id'].toString(): user['name']
        };

        setState(() {
          pitcashData = relevantPitcash.map((transaction) {
            bool isCreditor = transaction['creditor'].toString() == myId;
            String counterpartyId = isCreditor
                ? transaction['debtor'].toString()
                : transaction['creditor'].toString();
            String counterpartyName = userNames[counterpartyId] ?? 'مجهول';
            String projectName =
                projectNames[transaction['project'].toString()] ?? 'مجهول';
            String amount = transaction['amount'].toString();
            String date = transaction['date'].toString();

            return {
              'CreditorDebtor': counterpartyName,
              'Amount': amount,
              'ProjectName': projectName,
              'Date': date,
            };
          }).toList();
        });
      } else {
        print("Error fetching data from the API");
      }
    } catch (e) {
      print("Exception fetching data from the API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معاملات Pitcash'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الدائن / المدين')),
            DataColumn(label: Text('المبلغ')),
            DataColumn(label: Text('اسم المشروع')),
            DataColumn(label: Text('التاريخ')),
          ],
          rows: pitcashData
              .map(
                (transaction) => DataRow(cells: [
                  DataCell(Text(transaction['CreditorDebtor'])),
                  DataCell(Text(transaction['Amount'])),
                  DataCell(Text(transaction['ProjectName'])),
                  DataCell(Text(transaction['Date'])),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
