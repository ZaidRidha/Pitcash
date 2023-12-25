import 'package:flutter/material.dart';
import 'screens/LoginScreen.dart';
// Your import statement for LoginScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fixed syntax

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PitCash', // Changed to your app's name
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Changed from MyHomePage to LoginScreen
    );
  }
}
