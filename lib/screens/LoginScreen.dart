import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  PhoneNumber? _phoneNumber;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('uid')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<Map<String, String>?> authenticateUser(
      String phoneNumber, String password) async {
    final url = 'https://www.buraqgrp.com/admin/api.php';
    final response = await http.get(Uri.parse('$url?table=pitusers'));

    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      for (var user in users) {
        print('Modes for this user: ${user['modes']}');
        if (user['mobile_no'] == phoneNumber &&
            user['db_password'] == password) {
          return {
            'uid': user['uid'],
            'mode': user['modes'],
            'exp_date': user.containsKey('exp_date') ? user['exp_date'] : '',
            'email': user.containsKey('email') ? user['email'] : '',
            'name': user.containsKey('name') ? user['name'] : '',
            'phoneno': user.containsKey('mobile') ? user['mobile'] : '',
            'id': user.containsKey('id') ? user['id'] : ''
          };
        }
      }
      return null;
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> storeUserData(Map<String, String> userData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Storing the data in SharedPreferences
      await prefs.setString('uid', userData['uid']!);
      await prefs.setString('mode', userData['mode']!);
      await prefs.setString('exp_date', userData['exp_date']!);
      await prefs.setString('email', userData['email']!);
      await prefs.setString('name', userData['name']!);
      await prefs.setString('phoneno', userData['phoneno']!);
      await prefs.setString('id', userData['id']!);

      // For verification
      print("Stored UID: ${prefs.getString('uid')}");
      print("Stored Mode: ${prefs.getString('mode')}");
      print("Stored Expiry Date: ${prefs.getString('exp_date')}");
      print("Stored Email: ${prefs.getString('email')}");
      print("Stored Name: ${prefs.getString('name')}");
      print("Stored Phone Number: ${prefs.getString('phoneno')}");
      print("Stored ID: ${prefs.getString('id')}");
    } catch (e) {
      print("Error Storing to SharedPreferences: $e");
    }
  }

  InputDecoration _inputDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(
        vertical: 10.0, horizontal: 12.0), // Adjust padding
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  );

  void _loginPressed() async {
    try {
      String normalizedPhoneNumber =
          _phoneNumber!.phoneNumber!.replaceFirst('+', '00');
      Map<String, String>? userData = await authenticateUser(
          normalizedPhoneNumber, _passwordController.text);

      if (userData != null) {
        print("Storing UID: ${userData['uid']}");
        print("Storing Mode: ${userData['mode']}");

        await storeUserData(userData);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        print("Stored UID from SharedPreferences: ${prefs.getString('uid')}");
        print("Stored Mode from SharedPreferences: ${prefs.getString('mode')}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone number or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Asset 6@4x-8.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 16),
                Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  width: double
                      .infinity, // Make the container take all available width
                  child: Text(
                    'Phone Number',
                    textAlign: TextAlign.right,
                  ),
                ),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    print("New number: $number");
                    setState(() {
                      _phoneNumber = number;
                    });
                  },
                  searchBoxDecoration: InputDecoration(
                      hintText: 'Search by country name or dial code'),
                  inputDecoration: _inputDecoration,
                  countries: [
                    'IQ',
                    'JO',
                    'GB'
                  ], // Only allow numbers from these countries
                ),
                SizedBox(height: 16),
                Container(
                  width: double
                      .infinity, // Make the container take all available width
                  child: Text(
                    'Password',
                    textAlign: TextAlign.right,
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: _inputDecoration.copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loginPressed,
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
