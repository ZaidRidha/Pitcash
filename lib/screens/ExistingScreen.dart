import 'package:flutter/material.dart';

class ExistingScreen extends StatelessWidget {
  final String screenTitle;
  final List<Map<String, dynamic>> tableData;

  ExistingScreen({required this.screenTitle, required this.tableData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: MyTable(tableData: tableData),
    );
  }
}

class MyTable extends StatefulWidget {
  final List<Map<String, dynamic>> tableData;

  MyTable({required this.tableData});

  @override
  _MyTableState createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  List<Map<String, dynamic>> filteredData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredData = List.from(widget.tableData);
  }

  void filterSearch() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = widget.tableData
          .where((element) => element.values
              .any((value) => value.toString().toLowerCase().contains(query)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var columns = widget.tableData[0].keys
        .map((key) => DataColumn(label: Text(key)))
        .toList();

    var rows = filteredData.map((row) {
      var cells = row.keys.map((key) {
        return DataCell(Text(row[key].toString()));
      }).toList();

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
              ),
              onChanged: (value) => filterSearch(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(columns: columns, rows: rows),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  List<Map<String, dynamic>> sampleData = [
    {
      'Name': 'Habbaniyah Buildings Project',
      'Age': 28,
      'ID': 32,
      'Country': 'USA',
      // ... can add more keys/values
    },
    {'Name': 'Doe', 'Age': 25, 'ID': 123, 'Country': 'Canada'},
    {'Name': 'Alex', 'Age': 19, 'ID': 12, 'Country': 'UK'},
    // ... more rows
  ];
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black, // Change this to your desired color
      ),
      home: ExistingScreen(
          screenTitle: 'Existing Screen', tableData: sampleData)));
}
