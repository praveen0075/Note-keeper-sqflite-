import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_keeper/models/note_model.dart';
import 'package:note_keeper/utils/database_helper.dart';

class NoteAddPage extends StatefulWidget {
  NoteAddPage({super.key, required this.pageTitle});
  String pageTitle;

  @override
  State<NoteAddPage> createState() => _NoteAddPageState();
}

class _NoteAddPageState extends State<NoteAddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  int notePriority = 2;
  String stringPriority = "Low";

  @override
  Widget build(BuildContext context) {
    List<String> _priorities = ["High", "Low"];

    void updatePriority(String val) {
      if (val == "High") {
        stringPriority = "High";
        notePriority = 1;
      } else {
        stringPriority = "Low";
        notePriority = 2; 
      }
    }

    void _goBackScreen() {
      Navigator.pop(context, true);
    }

    void _showSnackBar(String msg, Color clr) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: clr));
    }

    void saveNote() async {
      if (_globalKey.currentState!.validate()) {
        final id = DateTime.timestamp().microsecondsSinceEpoch;
        final title = titleController.text;
        final desc = descriptionController.text;
        final date = DateFormat.yMMMd().format(DateTime.now());
        final note = NoteModel(id, title, desc, date, notePriority);
        int result = await DatabaseHelper().insertNote(note);
        if (result != 0) {
          _goBackScreen();

          _showSnackBar("Note Saved Successfully", Colors.green);
        } else {
          _showSnackBar("Some thing went wrong", Colors.red);
        }
      } else {}
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.pageTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _globalKey,
        child: Column(
          children: [
            ListTile(
              title: DropdownButton(
                items:
                    _priorities.map((dropDownPriotiy) {
                      return DropdownMenuItem(
                        value: dropDownPriotiy,
                        child: Text(dropDownPriotiy),
                      );
                    }).toList(),
                value: stringPriority,
                onChanged: (newValue) {
                  log(notePriority.toString());
                  setState(() {
                    updatePriority(newValue!);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  } else {
                    return null;
                  }
                },
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                minLines: 5,
                maxLines: 45,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  } else {
                    return null;
                  }
                },
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        saveNote();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        titleController.clear();
                        descriptionController.clear();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
