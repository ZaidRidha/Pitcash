import 'package:flutter/material.dart';
import 'package:pitcash/screens/LoginScreen.dart';
import 'package:pitcash/components/GlobalScaffold.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> projectsData = [];
  List<dynamic> pitusersData = [];
  int? userMode;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi();
    _getUserMode();
  }

  Future<void> _getUserMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ;
    print(prefs.getKeys().map((key) => '$key: ${prefs.get(key)}').join('\n'));
  }

  Future<void> _fetchDataFromApi() async {
    try {
      // Fetching Projects data
      final projectsResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=projects'));
      if (projectsResponse.statusCode == 200) {
        projectsData = json.decode(projectsResponse.body);
      } else {
        print("Error fetching Projects data: ${projectsResponse.statusCode}");
      }

      // Fetching Pitusers data
      final pitusersResponse = await http.get(
          Uri.parse('https://www.buraqgrp.com/admin/api.php?table=pitusers'));
      if (pitusersResponse.statusCode == 200) {
        pitusersData = json.decode(pitusersResponse.body);
      } else {
        print("Error fetching Pitusers data: ${pitusersResponse.statusCode}");
      }

      // Update the state to reflect fetched data
      setState(() {});
    } catch (e) {
      print("Error fetching data from the API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      title: 'مجموعة البراق',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/Asset 6@4x-8.png',
                width: 200, height: 200),

            // Optional: Add some creative designs or additional widgets
            // For example, a decorative divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(
                color: Colors.grey,
                thickness: 1.0,
                indent: 30,
                endIndent: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
