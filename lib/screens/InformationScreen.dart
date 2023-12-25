import 'package:flutter/material.dart';
import 'package:pitcash/components/GlobalScaffold.dart';

class InformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      title: 'Information Screen',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/Asset 6@4x-8.png'),
            ),
            SizedBox(height: 20), // Add some spacing

            // Information Section
            Text(
              'Username: JohnDoe123',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: john.doe@example.com',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Age: 25',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Country: USA',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: InformationScreen()));
}
