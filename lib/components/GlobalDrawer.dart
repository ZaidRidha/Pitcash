import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pitcash/screens/ExistingScreen.dart';
import 'package:pitcash/screens/AdditionScreen.dart';
import 'package:pitcash/screens/ExistingProject.dart';
import 'package:pitcash/screens/LoginScreen.dart';
import 'package:pitcash/screens/ProjectAddition.dart';
import 'package:pitcash/screens/MyInformation.dart';
import 'package:pitcash/screens/DebtorsExisting.dart';
import 'package:pitcash/screens/DebtorsAddition.dart';
import 'package:pitcash/screens/ExistingPredecessor.dart';
import 'package:pitcash/screens/PredecessorAddition.dart';
import 'package:pitcash/screens/ExistingExpense.dart';
import 'package:pitcash/screens/ExpenseAddition.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GlobalDrawer extends StatefulWidget {
  @override
  _GlobalDrawerState createState() => _GlobalDrawerState();
}

class _GlobalDrawerState extends State<GlobalDrawer> {
  List<Map<String, dynamic>> projectsData = [];
  String? userMode;

  @override
  void initState() {
    super.initState();
    _getUserMode();
  }

  Future<void> _getUserMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userMode = prefs.getString('mode');
    });
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[800],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80,
              child: DrawerHeader(
                child: Text(
                  'نظام السلف النقدية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                ),
              ),
            ),
            ExpansionTile(
              title: Text(
                'المشاريع',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              children: [
                ListTile(
                  title: Text('موجود', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExistingProject(),
                      ),
                    );
                  },
                ),
                if (userMode == '1')
                  ListTile(
                    title: Text('يضيف', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectAddition(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (userMode == '1')
              ExpansionTile(
                title: Text(
                  'المدينين',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                children: [
                  ListTile(
                    title: Text('موجود', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DebtorsExisting(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('يضيف', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DebtorsAddition(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ExpansionTile(
              title: Text(
                'السلف',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              children: [
                ListTile(
                  title: Text('موجود', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExistingPredecessor(),
                      ),
                    );
                  },
                ),
                if (userMode == '1')
                  ListTile(
                    title: Text('يضيف', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PredecessorAddition(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'النفقات',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              children: [
                ListTile(
                  title: Text('موجود', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExistingExpense(),
                      ),
                    );
                  },
                ),
                if (userMode == '2')
                  ListTile(
                    title: Text('يضيف', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseAddition(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'معلوماتي',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              children: [
                ListTile(
                  title:
                      Text('معلوماتي', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyInformation(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('تسجيل الخروج',
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('uid');

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
