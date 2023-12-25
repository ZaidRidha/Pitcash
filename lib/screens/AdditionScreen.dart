import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pitcash/components/GlobalScaffold.dart'; // Assuming this is your custom scaffold widget

class AdditionScreen extends StatelessWidget {
  final String screenTitle = "Addition Screen";

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      title: screenTitle,
      body: AdditionForm(),
    );
  }
}

class AdditionForm extends StatefulWidget {
  @override
  _AdditionFormState createState() => _AdditionFormState();
}

class _AdditionFormState extends State<AdditionForm> {
  final TextEditingController dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 1',
              ),
            ),
            TextField(
              readOnly: true,
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Pick a date',
              ),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  dateController.text =
                      date.toLocal().toIso8601String().split('T')[0];
                }
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 3',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 4',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 5',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 6',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input 7 (Long Description)',
              ),
              maxLines: 5,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Image'),
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  _image!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: AdditionScreen()));
}
