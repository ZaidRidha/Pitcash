import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyInformation extends StatefulWidget {
  @override
  _MyInformationState createState() => _MyInformationState();
}

class _MyInformationState extends State<MyInformation> {
  String? uid;
  String? mode;
  String? expDate;
  String? email;
  String? name;
  String? phoneNo;

  @override
  void initState() {
    super.initState();
    _retrieveUserData();
  }

  Future<void> _retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      mode = prefs.getString('mode');
      expDate = prefs.getString('exp_date');
      email = prefs.getString('email');
      name = prefs.getString('name');
      phoneNo = prefs.getString('phoneno');
    });
  }

  Widget _buildInfoCard(IconData icon, String title, String? data) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data ?? 'N/A'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard(Icons.account_circle, "UID", uid),
            _buildInfoCard(Icons.vpn_lock, "Mode", mode),
            _buildInfoCard(Icons.date_range, "Expiry Date", expDate),
            _buildInfoCard(Icons.email, "Email", email),
            _buildInfoCard(Icons.person, "Name", name),
            _buildInfoCard(Icons.phone, "Phone Number", phoneNo),
          ],
        ),
      ),
    );
  }
}
