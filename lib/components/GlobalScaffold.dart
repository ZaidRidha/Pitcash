import 'package:flutter/material.dart';
import 'GlobalDrawer.dart'; // Make sure to import GlobalDrawer

class GlobalScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  GlobalScaffold({required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(title),
      ),
      endDrawer: GlobalDrawer(),
      body: body,
    );
  }
}
